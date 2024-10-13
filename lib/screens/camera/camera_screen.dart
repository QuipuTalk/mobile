import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiputalk/screens/camera/video_screen.dart'; 

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

enum WidgetState {
  NONE, 
  LOADING, 
  LOADED, 
  ERROR
}

class _CameraScreenState extends State<CameraScreen> {
  WidgetState _widgetState = WidgetState.NONE;
  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  bool _isRecording = false;
  late int _timer = 0;  // Temporizador en segundos
  late String _formattedTime = "00:00"; // Tiempo formateado
  late Timer _timerInstance;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    switch(_widgetState) {
      case WidgetState.NONE:
      case WidgetState.LOADING:
        return _buildScaffold(
          context,
          const Center(
            child: CircularProgressIndicator(),
          )
        );
      case WidgetState.LOADED:
        return _buildScaffold(
          context,
          Stack(
          alignment: Alignment.bottomCenter,
          children: [
          Column(
            children: [
              Expanded(
                flex: 8, // Esto hará que ocupe el 70% de la pantalla
                child: _buildCameraPreview(),
              ),
              Expanded(
                flex: 2, // Esto hará que ocupe el 30% de la pantalla
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Centrar los elementos en el 30% restante
                  children: [
                    _buildTimer(),
                    _buildRecordButton(),
                  ],
                ),
              ),
            ],
          ),
        ],
    ),
        );
      case WidgetState.ERROR:
        return _buildScaffold(
          context,
          const Center(
            child: Text("No se pudo inicializar la cámara"),
          )
        );
    }
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF2D4554), // Color de fondo #2D4554
      body: body,
    );
  }

  Widget _buildCameraPreview() {
    return Container(
  
      child: SizedBox(
        width: MediaQuery.of(context).size.width, 
        child: ClipRRect(
          child: CameraPreview(_cameraController),
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Positioned(
      bottom: 80,
      child: Text(
        _formattedTime,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return FloatingActionButton(
      onPressed: _isRecording ? _stopRecording : _startRecording,
      backgroundColor: Colors.red,
      child: Icon(_isRecording ? Icons.stop : Icons.videocam, color: Colors.white),
    );
  }

  void _startTimer() {
    _timer = 0;
    _timerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timer++;
        _formattedTime = _formatTime(_timer);
      });
    });
  }

  void _stopTimer() {
    _timerInstance.cancel();
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  initializeCamera() async {
    _widgetState = WidgetState.LOADING;
    if (mounted) setState(() {});

    _cameras = await availableCameras();

    _cameraController = CameraController(_cameras[0], ResolutionPreset.high, enableAudio: true);

    try {
      await _cameraController.initialize();
      _widgetState = WidgetState.LOADED;
    } catch (e) {
      _widgetState = WidgetState.ERROR;
    }

    if (mounted) setState(() {});
  }

  Future<void> _startRecording() async {
    if (_cameraController.value.isRecordingVideo) {
      return;
    }

    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      await _cameraController.startVideoRecording();
      _isRecording = true;
      _startTimer(); // Inicia el temporizador cuando empieza la grabación
      setState(() {});
    } catch (e) {
      _isRecording = false;
      setState(() {});
      print("Error al iniciar la grabación: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      XFile videoFile = await _cameraController.stopVideoRecording();
      _isRecording = false;
      _stopTimer(); // Detiene el temporizador cuando se detiene la grabación

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      final File tempVideo = await File(videoFile.path).copy(tempPath);
      print(tempPath);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(videoPath: tempPath,))
        
      );
    } catch (e) {
      print("Error al detener la grabación: $e");
    }

    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _stopTimer(); // Asegura detener el temporizador al salir
    super.dispose();
  }
}
