import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiputalk/screens/camera/video_screen.dart';

import '../../providers/camera_controller_service.dart';
import '../../routes/conversation_navigator.dart';

// Al inicio de camera_screen.dart:
import 'package:shared_preferences/shared_preferences.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  CameraController? get _cameraController => CameraControllerService.cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Pedimos permisos y luego inicializamos la cámara
    _requestPermissionsAndInitialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    super.dispose();
  }

  // Manejo del ciclo de vida: si la app se pausa o reanuda
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      // Al reanudar, sólo reinicializa si la cámara se había cerrado
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        // Pedimos permisos de nuevo en caso de que hayan cambiado
        await _requestPermissionsAndInitialize();
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Liberamos la cámara si la app no está activa
      CameraControllerService.disposeCamera();
    }
  }

  Future<void> _requestPermissionsAndInitialize() async {
    // 1. Pedir permisos de cámara y micrófono
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    // 2. Verificar si ambos fueron concedidos
    if (cameraStatus.isGranted && micStatus.isGranted) {
      // Ahora sí, inicializamos la cámara (una sola vez)
      await CameraControllerService.initializeCamera();
      if (mounted) setState(() {});
    } else {
      // El usuario negó permisos o algo salió mal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se concedieron permisos de cámara/micrófono')),
      );
      Navigator.of(context).pop(); // salir de la pantalla de cámara
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si la cámara no está lista, mostramos un loading
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
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

  /// Comprueba y, si es la primera grabación, muestra un diálogo de recomendaciones.
  Future<void> _maybeShowVideoTips() async {
    final prefs = await SharedPreferences.getInstance();
    bool shown = prefs.getBool('shown_video_tips') ?? false;

    if (!shown) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Consejos para una buena grabación'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('• Asegúrate de tener buena iluminación.'),
                Text('• Evita el contraluz o fuentes de luz directa.'),
                Text('• Sujeta el teléfono firmemente o usa un trípode.'),
                Text('• Mantén el encuadre estable y al nivel de los hombros.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      await prefs.setBool('shown_video_tips', true);
    }
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
    //if (_cameraController == null ||
    //    !_cameraController!.value.isInitialized ||
    //    _cameraController!.value.isRecordingVideo) {
    //  return;
    //}
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _cameraController!.value.isRecordingVideo) {
      return;
    }

    // 1) Mostrar consejos la PRIMERA vez que inician grabación
    await _maybeShowVideoTips();

    try {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
      _startTimer();
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null ||
        !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() => _isRecording = false);
      _stopTimer();

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await File(videoFile.path).copy(tempPath);

      // Navegar a VideoScreen y pasar la ruta del video
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(
            videoPath: tempPath,
            useAssetVideo: false,
          ),
        ),
      );
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  void _startTimer() {
    _recordingDuration = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingDuration++);
      if (_recordingDuration >= 30) {
        _stopRecording(); // Automatic stop after 30s
      }
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }
}
