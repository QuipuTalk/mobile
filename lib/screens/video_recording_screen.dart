import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class VideoRecordingScreen extends StatefulWidget {
  @override
  _VideoRecordingScreenState createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  Timer? _timer;
  int _recordDuration = 0;
  String _formattedTime = "00:00";
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grabar Video'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller!), // Vista previa de la cámara
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        _formattedTime,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: _isRecording ? _stopVideoRecording : _startVideoRecording,
                        backgroundColor: Colors.red,
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.videocam,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _startVideoRecording() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      _videoPath = join(directory.path, '${DateTime.now()}.mp4');

      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _startTimer();
      });
    } catch (e) {
      print('Error al iniciar la grabación: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();

      if (_videoPath != null) {
        await videoFile.saveTo(_videoPath!);
        print('Video guardado en: $_videoPath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video guardado en: $_videoPath')),
        );
      } else {
        print('Error: _videoPath es null');
      }

      setState(() {
        _isRecording = false;
        _timer?.cancel();
        _recordDuration = 0;
        _formattedTime = "00:00";
      });
    } catch (e) {
      print('Error al detener la grabación: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _recordDuration++;
        _formattedTime = _formatDuration(_recordDuration);
      });
    });
  }

  String _formatDuration(int duration) {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    String minutesStr = minutes < 10 ? '0$minutes' : '$minutes';
    String secondsStr = seconds < 10 ? '0$seconds' : '$seconds';
    return '$minutesStr:$secondsStr';
  }
}
