import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VideoCallPage extends StatefulWidget {
  final String userId;

  VideoCallPage({required this.userId});

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late WebSocketChannel _channel;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  late RTCPeerConnection _peerConnection;

  @override
  void initState() {
    super.initState();
    _initWebSocket();
    _initRenderers();
  }

  // Initialize WebSocket connection to the signaling server
  void _initWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse('ws://<your-server>/ws/signaling/${widget.userId}'));

    _channel.stream.listen((message) async {
      final data = json.decode(message);

      if (data['type'] == 'offer') {
        await _handleOffer(data);
      } else if (data['type'] == 'answer') {
        await _handleAnswer(data);
      } else if (data['type'] == 'ice_candidate') {
        await _handleIceCandidate(data);
      }
    });
  }

  // Initialize video renderers
  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // Create a peer connection
  Future<void> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
    _peerConnection = await createPeerConnection(configuration);

    _peerConnection.onIceCandidate = (candidate) {
      _channel.sink.add(json.encode({
        'type': 'ice_candidate',
        'candidate': candidate.toMap(),
        'to': '<remote-user-id>', // Replace with the target user ID
      }));
    };

    _peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    // Get user media (camera and microphone)
    final mediaStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });
    _localRenderer.srcObject = mediaStream;
    mediaStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, mediaStream);
    });
  }

  // Handle offer from remote peer
  Future<void> _handleOffer(Map<String, dynamic> data) async {
    await _createPeerConnection();
    await _peerConnection.setRemoteDescription(RTCSessionDescription(data['sdp'], 'offer'));

    final answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);

    _channel.sink.add(json.encode({
      'type': 'answer',
      'sdp': answer.sdp,
      'to': data['from'], // The ID of the user sending the offer
    }));
  }

  // Handle answer from remote peer
  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    await _peerConnection.setRemoteDescription(RTCSessionDescription(data['sdp'], 'answer'));
  }

  // Handle ICE candidates
  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex']
    );

    // Use addCandidate instead of addIceCandidate
    await _peerConnection.addCandidate(candidate);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.close();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Call')),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer)),
          Expanded(child: RTCVideoView(_remoteRenderer)),
        ],
      ),
    );
  }
}
