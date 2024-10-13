import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'video_player_screen.dart'; // Importa la pantalla de reproducción de video

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  late Future<List<File>> _videoFiles;

  @override
  void initState() {
    super.initState();
    _videoFiles = _getVideoFiles();
  }

  Future<List<File>> _getVideoFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final videoDir = Directory(directory.path);
    List<File> videoFiles = [];

    try {
      videoFiles = videoDir.listSync().where((item) {
        return item.path.endsWith(".mp4");
      }).map((item) => File(item.path)).toList();
    } catch (e) {
      print("Error obteniendo los videos: $e");
    }

    return videoFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videos Grabados')),
      body: FutureBuilder<List<File>>(
        future: _videoFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final videoFile = snapshot.data![index];
                  return ListTile(
                    title: Text('Video ${index + 1}'),
                    subtitle: Text(videoFile.path),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(videoPath: videoFile.path),
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return const Center(child: Text('No se encontraron videos.'));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
