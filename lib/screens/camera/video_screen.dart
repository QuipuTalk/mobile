import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quiputalk/screens/answer/answer_screen.dart';
import 'package:video_player/video_player.dart';

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
        color: Colors.white
      ),
      backgroundColor: const Color(0xFF2D4554) ,

      ),
      body: Stack(
      children: [
        Column(
            children: [
            Expanded(
              flex: 6,
              child: _futureBuilder(context),
            ),
            Expanded(
              flex: 2,
              child: _cuttingSection(),
            ),
            Expanded(
              flex: 2,
              child:_buttons(),
            )

          ],
      ),

      Positioned(
        top: screenHeight / 4, 
        left: MediaQuery.of(context).size.width / 2 - 28, 
         
        child: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40)
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
          color: Colors.white ,
        ),
      ),
      ),
        ],
      )
      
      
      
    );
  }
  
  
  Widget _futureBuilder(BuildContext context){
    return FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(
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
  
  Widget _cuttingSection(){
    return const Column();
  }

  Widget _buttons(){
    return  Container(
      color: const Color(0xFF2D4554),
      padding: const EdgeInsets.all(20.0),
      child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
            Expanded(
              child: 
                ElevatedButton(
                onPressed: (){}, 
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color(0xfff7a8892)),
                  foregroundColor: WidgetStateProperty.all(Colors.white), 
                ),
                child: const Text("Volver a cargar")              
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: 
                ElevatedButton(
                onPressed: (){
                  _showLoadingDialogAndNavigate();

                }, 
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color(0xFFDB5050)),
                  foregroundColor: WidgetStateProperty.all(Colors.white), 
                ),
                child: const Text("Traducir")              
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
                )
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




