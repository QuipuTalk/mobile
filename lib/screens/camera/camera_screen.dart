import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiputalk/screens/camera/video_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high, enableAudio: true);

    try {
      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildLoadingScreen();
    }
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCameraPreview(),
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Spacer(),
              _buildBottomControls(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildCameraPreview() {
    return CameraPreview(_cameraController!);
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black54,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          _buildTimer(),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    final minutes = _recordingDuration ~/ 60;
    final seconds = _recordingDuration % 60;
    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRecordButton(),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording ? Colors.white : Colors.red,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.videocam,
          color: _isRecording ? Colors.red : Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_cameraController!.value.isRecordingVideo) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
      _startTimer();
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_cameraController!.value.isRecordingVideo) return;

    try {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() => _isRecording = false);
      _stopTimer();

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await File(videoFile.path).copy(tempPath);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoScreen(videoPath: tempPath)),
      );
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  void _startTimer() {
    _recordingDuration = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingDuration++);
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }
}