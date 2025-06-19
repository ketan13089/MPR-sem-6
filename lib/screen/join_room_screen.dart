import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'detect.dart';
import 'room_manager.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _roomIdController = TextEditingController();
  bool _isCreatingRoom = false;
  bool _isJoiningRoom = false;
  String _errorMessage = '';
  String? _createdRoomId; // Store the created room ID

  Future<void> _createNewRoom() async {
    setState(() {
      _isCreatingRoom = true;
      _errorMessage = '';
    });

    try {
      final roomId = await RoomManager.createRoom();
      if (!mounted) return;

      setState(() {
        _createdRoomId = roomId; // Store the room ID to display
      });

      // Automatically navigate if you prefer
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => HandSignDetectionPage(
      //       roomId: roomId,
      //       isHost: true,
      //     ),
      //   ),
      // );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isCreatingRoom = false);
      }
    }
  }

  Future<void> _joinExistingRoom() async {
    if (_roomIdController.text.isEmpty) return;

    setState(() {
      _isJoiningRoom = true;
      _errorMessage = '';
    });

    try {
      final isValid = await RoomManager.validateRoom(_roomIdController.text);
      if (!mounted) return;

      if (isValid) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HandSignDetectionPage(
              roomId: _roomIdController.text,
              isHost: false,
            ),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Invalid room ID');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isJoiningRoom = false);
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_createdRoomId == null) return;
    await Clipboard.setData(ClipboardData(text: _createdRoomId!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room ID copied to clipboard!')),
    );
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Video Call')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isCreatingRoom ? null : _createNewRoom,
              child: _isCreatingRoom
                  ? const CircularProgressIndicator()
                  : const Text('Create New Call'),
            ),
            const SizedBox(height: 30),

            // Display created room ID if available
            if (_createdRoomId != null) ...[
              const SizedBox(height: 20),
              const Text('Share this Room ID:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _createdRoomId!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyToClipboard,
                      tooltip: 'Copy to clipboard',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HandSignDetectionPage(
                        roomId: _createdRoomId!,
                        isHost: true,
                      ),
                    ),
                  );
                },
                child: const Text('Join Your Call'),
              ),
            ],

            const SizedBox(height: 30),
            const Text('OR', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 30),

            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Room ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isJoiningRoom ? null : _joinExistingRoom,
              child: _isJoiningRoom
                  ? const CircularProgressIndicator()
                  : const Text('Join Existing Call'),
            ),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}