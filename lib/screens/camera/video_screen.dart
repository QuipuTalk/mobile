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

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';


class VideoScreen extends StatefulWidget {
  final String videoPath;
  final bool useAssetVideo; // Añadido para decidir qué video usar

  const VideoScreen({
    Key? key,
    required this.videoPath,
    this.useAssetVideo = false, // Por defecto es false
  }) : super(key: key);

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
    // Cargar el video desde la ruta proporcionada
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
                  quarterTurns: 4,
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

  Future<String> _getCorrectedText(String text) async {
    try {
      final url = Uri.parse('https://backendquipu.vercel.app/get_text_correction/');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"text": text}),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));

        // Extraer el texto corregido
        String correctedText = jsonData['corrected_text'];

        // Si el texto corregido comienza con 'Respuesta: "', lo eliminamos
        if (correctedText.startsWith('Respuesta: "')) {
          correctedText = correctedText.substring(11, correctedText.length - 1); // Eliminar 'Respuesta: "' y el último '"'
        }

        return correctedText;
      } else {
        print('Error al obtener el texto corregido: ${response.statusCode}');
        return text; // Devolver el texto original si hay un error
      }
    } catch (e) {
      print('Exception al obtener el texto corregido: $e');
      return text; // Devolver el texto original si hay una excepción
    }
  }


  Widget _futureBuilder(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: RotatedBox(
                quarterTurns: 1, // Cambia este valor si necesitas más ajustes
                child: VideoPlayer(_controller),
              ),
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
              onPressed: () async {
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

    try {
      final sessionService = Provider.of<SessionService>(context, listen: false);
      // Verificar si ya existe un sessionId activo
      String? sessionId = sessionService.sessionId;

      // Si no existe un sessionId, iniciar una nueva sesión
      if (sessionId == null) {
        sessionId = await _backendService.startSession();
        sessionService.setSessionId(sessionId!); // Almacenar el nuevo sessionId en el SessionService
      }

      // URL HACIA EL BACKEND DEL MODELO
      // ANTIGUA : https://lsp-api-447652637002.southamerica-west1.run.app/predict
      // NUEVA : https://lsp-api-447652637002.southamerica-west1.run.app/predict
      // NEUVA V2: https://lsp-api-447652637002.southamerica-west1.run.app/predict
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lsp-api-447652637002.southamerica-west1.run.app/predict'),
      );


      // Variable para el archivo de video
      File? videoFile;

      if (widget.useAssetVideo) {
        // Leer el video de los assets y escribirlo en un archivo temporal
        final byteData = await rootBundle.load('assets/videos/sample_video.mp4');
        final tempDir = await getTemporaryDirectory();
        final tempVideoPath = '${tempDir.path}/sample_video.mp4';
        videoFile = await File(tempVideoPath).writeAsBytes(
          byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      } else {
        // Usar el video de _currentVideoPath
        videoFile = File(_currentVideoPath);
      }

      // Agregar el archivo de video a la solicitud
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          _currentVideoPath, // Usar la ruta del video grabado
          contentType: MediaType('video', 'mp4'),
        ),
      );

      //Si el servicio está caído , usar un mock
      const bool useMockTranslation = true;
      String translatedMessage;
      if (useMockTranslation) {
        translatedMessage = "Esta es una traducción por defecto para continuar con el desarrollo.";
      } else {
        // Enviar la solicitud al primer backend
        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var jsonData = json.decode(responseData);
          translatedMessage = jsonData['sentence'] ?? "Mensaje vacío";
        } else {
          // fallback en caso de status!=200
          translatedMessage = "Traducción no disponible, usando traducción por defecto.";
        }
      }

      // Imprimir el mensaje traducido en la consola
      print('Translated Message: $translatedMessage');

      // Ahora enviar el texto traducido al segundo backend para corrección
      String correctedMessage = await _getCorrectedText(translatedMessage);

      // Cerrar el diálogo de carga
      if (mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo de carga

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ¡Tu traducción está lista!'),
            duration: Duration(seconds: 3),
          ),
        );

        // Navegar a AnswerScreen pasando el mensaje corregido y sessionId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnswerScreen(
              initialMessage: correctedMessage,
              sessionId: sessionId!,
            ),
          ),
        );
      }
    } catch (e) {
      // Manejar excepciones
      print('Exception: $e');
      // Cerrar el diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }
      // Mostrar mensaje de error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Error al procesar el video. Por favor, inténtalo de nuevo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToTrimmer() async {
    // Navega directamente a TrimmerView sin verificar permisos
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
  }
}