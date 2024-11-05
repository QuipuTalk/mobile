import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:quiputalk/screens/edit/trimmer_view.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/camera_controller_service.dart';
import '../../providers/session_service.dart';
import '../../routes/conversation_navigator.dart';
import '../../providers/backend_service.dart';
import '../answer/answer_screen.dart';

class VideoScreen extends StatefulWidget {
  final String videoPath;
  const VideoScreen({super.key, required this.videoPath});
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late String _currentVideoPath;
  final BackendService _backendService = BackendService(); // Instancia de BackendService

  @override
  void initState() {
    super.initState();
    _currentVideoPath = widget.videoPath;
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(_currentVideoPath));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF2D4554),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 10,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: _futureBuilder(context),
                ),
              ),
              Expanded(
                flex: 2,
                child: _buttons(),
              ),
            ],
          ),
          Positioned(
            top: screenHeight / 3,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              backgroundColor: const Color(0xFF2D4554),
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "cutButton",
              mini: true,
              backgroundColor: const Color.fromRGBO(37, 69, 88, 1.0),
              onPressed: _navigateToTrimmer,
              child: const Icon(
                Icons.content_cut,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _futureBuilder(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buttons() {
    return Container(
      color: const Color(0xFF2D4554),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: ()  async{
                // 1. Detener y liberar el reproductor de video
                await _controller.pause();
                await _controller.dispose();

                // 2. Eliminar el archivo temporal de video si es necesario
                try {
                  final videoFile = File(_currentVideoPath);
                  if (await videoFile.exists()) {
                await videoFile.delete();
                }
                } catch (e) {
                print('Error al eliminar el archivo de video: $e');
                }

                // 3. Reinicializar la cámara y navegar
                if (mounted) {
                await CameraControllerService.resetCamera();
                await ConversationNavigator.navigateToCameraScreen(context);
                }
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(const Color(0xfff7a8892)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text("Volver a grabar"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showLoadingDialogAndNavigate();
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(const Color(0xFFDB5050)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text("Traducir"),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showLoadingDialogAndNavigate() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(50),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF2D4554),
              ),
              SizedBox(height: 20),
              Text(
                "El video se está procesando",
                style: TextStyle(
                  color: Color(0xFF2D4554),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );


    final sessionService = Provider.of<SessionService>(context, listen: false);
    // Verificar si ya existe un sessionId activo
    String? sessionId = sessionService.sessionId;

    // Si no existe un sessionId, iniciar una nueva sesión
    if (sessionId == null) {
      sessionId = await _backendService.startSession();
      sessionService.setSessionId(sessionId!); // Almacenar el nuevo sessionId en el SessionService
    }

    // Cerrar el diálogo después de un tiempo simulado de procesamiento
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Cierra el diálogo

      if (sessionId != null) {
        // Aquí iría la traducción real del video
        String translatedMessage =
            "Mi nombre es Julio, ayuda con un trámite";

        // Navegar a AnswerScreen pasando el session_id
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnswerScreen(
              initialMessage: translatedMessage,
              sessionId: sessionId!,
            ),
          ),
        );
      } else {
        // Manejar el caso de error si no se pudo obtener el session_id
        print("Error al iniciar una nueva sesión");
      }
    });
  }

  void _navigateToTrimmer() async {
    var status = await Permission.videos.request();
    if (status.isGranted) {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => TrimmerView(File(_currentVideoPath)),
        ),
      );

      if (result != null) {
        setState(() {
          _currentVideoPath = result;
          _controller.dispose();
          _initializeVideoPlayer();
        });
      }
    } else {
      final snackBar = SnackBar(
        content: Text('Permiso de acceso a videos requerido para recortar el video.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

}
