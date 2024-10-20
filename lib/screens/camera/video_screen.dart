import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quiputalk/screens/answer/answer_screen.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:quiputalk/screens/edit/trimmer_view.dart';

class VideoScreen extends StatefulWidget {
  final String videoPath;

  const VideoScreen({super.key, required this.videoPath});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
  }

  @override
  void dispose() {
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
              backgroundColor: Color.fromRGBO(37, 69, 88, 1.0),
              onPressed: () {
                // Navegar a la pantalla de recorte de video usando el video grabado actualmente
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return TrimmerView(File(widget.videoPath));
                    },
                  ),
                );
              },
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
              onPressed: () {
                // Dispose the current controller
                _controller.dispose();

                // Navigate back to the recording screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
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

  void _showLoadingDialogAndNavigate() {
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

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AnswerScreen()),
      );
    });
  }
}
