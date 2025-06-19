import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:http_parser/http_parser.dart';

class HandSignDetectionPage1 extends StatefulWidget {
  const HandSignDetectionPage1({Key? key}) : super(key: key);

  @override
  State<HandSignDetectionPage1> createState() => _HandSignDetectionPage1State();
}

class _HandSignDetectionPage1State extends State<HandSignDetectionPage1> {
  // Camera controllers
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  // Camera state
  bool _isCameraReady = false;
  bool _isFrontCamera = true;
  bool _cameraError = false;
  String _errorMessage = "";

  // Detection state
  String _detectedSign = "";
  bool _isProcessing = false;
  DateTime? _lastDetectionTime;
  final String _apiUrl = "http://192.168.1.3:8000/detect-hand-sign";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startDetectionLoop();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _isCameraReady = false;
          _cameraError = true;
          _errorMessage = "No cameras found on device";
        });
        return;
      }

      int selectedCameraIndex = 0;
      for (int i = 0; i < _cameras.length; i++) {
        if (_cameras[i].lensDirection == CameraLensDirection.front) {
          selectedCameraIndex = i;
          _isFrontCamera = true;
          break;
        }
      }

      await _initializeCameraController(_cameras[selectedCameraIndex]);

    } catch (e) {
      log('Error initializing camera: $e');
      setState(() {
        _isCameraReady = false;
        _cameraError = true;
        _errorMessage = "Camera initialization error: ${e.toString()}";
      });
    }
  }

  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isCameraReady = true;
          _cameraError = false;
        });
      }
    } catch (e) {
      log('Error initializing camera controller: $e');
      if (mounted) {
        setState(() {
          _isCameraReady = false;
          _cameraError = true;
          _errorMessage = "Camera controller error: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Only one camera available on this device"),
        ),
      );
      return;
    }

    late CameraDescription newCamera;
    for (CameraDescription camera in _cameras) {
      if (_isFrontCamera && camera.lensDirection == CameraLensDirection.back) {
        newCamera = camera;
        _isFrontCamera = false;
        break;
      } else if (!_isFrontCamera && camera.lensDirection == CameraLensDirection.front) {
        newCamera = camera;
        _isFrontCamera = true;
        break;
      }
    }

    setState(() {
      _isCameraReady = false;
    });

    await _initializeCameraController(newCamera);
  }

  void _reInitializeCamera() {
    _initializeCamera();
  }

  void _startDetectionLoop() async {
    while (true) {
      if (_isCameraReady && !_isProcessing && mounted) {
        await _captureAndDetect();
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _captureAndDetect() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    // Throttle detection to prevent too many requests
    if (_lastDetectionTime != null &&
        DateTime.now().difference(_lastDetectionTime!) < const Duration(seconds: 1)) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture image
      final image = await _cameraController!.takePicture();
      final imageFile = File(image.path);

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Send request
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (mounted) {
        setState(() {
          _detectedSign = jsonResponse['sign'] ?? "No sign detected";
          _lastDetectionTime = DateTime.now();
        });
      }

      // Delete the temporary image file
      await imageFile.delete();
    } catch (e) {
      log('Error detecting hand sign: $e');
      if (mounted) {
        setState(() {
          _detectedSign = "Detection error";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hand Sign Detection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _toggleCamera,
            tooltip: "Switch camera",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBody(),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Detected Sign: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _detectedSign,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_cameraError) {
      return _buildErrorView();
    } else if (!_isCameraReady) {
      return _buildLoadingView();
    } else {
      return _buildCameraView();
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            "Camera Error",
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage.isNotEmpty ? _errorMessage : "Failed to initialize camera",
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _reInitializeCamera,
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Initializing camera..."),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return _isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized
        ? Stack(
      children: [
        CameraPreview(_cameraController!),
        if (_isProcessing)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    )
        : const Center(child: CircularProgressIndicator());
  }
}