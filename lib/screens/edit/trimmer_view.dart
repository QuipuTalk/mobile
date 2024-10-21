import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:path_provider/path_provider.dart';


class TrimmerView extends StatefulWidget {
  final File file;

  TrimmerView(this.file);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<void> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    try {
      // Cambiar la ruta de salida a un directorio externo confiable
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw Exception("No se pudo acceder al directorio externo");
      }
      final String outputPath = '${externalDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      print('Output path: $outputPath');

      await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        outputFormat: FileFormat.mp4,
        onSave: (savedVideoPath) async {
          setState(() {
            _progressVisibility = false;
          });

          if (savedVideoPath != null) {
            try {
              final File trimmedVideo = File(savedVideoPath);
              print('Trimmed video path: ${trimmedVideo.path}');
              print('Original video path: ${widget.file.path}');

              await trimmedVideo.copy(widget.file.path);

              final snackBar = SnackBar(content: Text('Video guardado exitosamente.'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              Navigator.of(context).pop(widget.file.path);
            } catch (e) {
              print('Error copying trimmed video: $e');
              final snackBar = SnackBar(content: Text('Error al guardar el video: $e'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          } else {
            print('Saved video path is null');
            final snackBar = SnackBar(content: Text('No se pudo guardar el video.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      );
    } catch (e) {
      print('Error during video trimming: $e');
      setState(() {
        _progressVisibility = false;
      });

      final snackBar = SnackBar(content: Text('Error al recortar el video: $e'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }


  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Trimmer"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 10.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _trimmer.videoPlayerController!.value.aspectRatio,
                        child: VideoViewer(trimmer: _trimmer),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: const Duration(seconds: 10),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(
                    Icons.pause,
                    size: 80.0,
                    color: Colors.white,
                  )
                      : Icon(
                    Icons.play_arrow,
                    size: 80.0,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                ),
                SizedBox(height: 10), // Espacio antes del botón
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                    await _saveVideo();
                  },
                  child: Text("SAVE"),
                ),
                SizedBox(height: 20), // Espacio para separar del borde inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
}
