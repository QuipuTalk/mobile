import 'package:camera/camera.dart';

class CameraControllerService {
  static CameraController? _cameraController;
  static bool _isInitialized = false;

  static Future<void> initializeCamera() async {
    if (_isInitialized) return;

    final cameras = await availableCameras();
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: true
    );
    await _cameraController!.initialize();
    _isInitialized = true;
  }

  static Future<void> disposeCamera() async {
    if (_cameraController != null) {
      _isInitialized = false;
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  static Future<void> resetCamera() async {
    await disposeCamera();
    await initializeCamera();
  }

  static CameraController? get cameraController => _cameraController;
}
