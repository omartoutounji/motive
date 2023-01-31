import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

late AudioHandler _audioHandler;
Future<void> main() async {
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.app.nano.motivation',
      androidNotificationChannelName: 'Motive',
      androidNotificationOngoing: true,
    ),
  );
  runApp(const MyApp());
}

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  @override
  AudioPlayerHandler() {
    int number = next(1, 19);

    // Broadcast that we're loading, and what controls are available.
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play],
      processingState: AudioProcessingState.loading,
    ));
    // Connect to the URL
    _player
        .setAudioSource(AudioSource.uri(
            Uri.parse("asset:///assets/audio/$number.mp3"),
            tag: MediaItem(
                id: '$number',
                title: "Motive",
                album: "Motive",
                artUri: Uri.parse("asset:///assets/icon/motive.png"))))
        .then((_) {
      // Broadcast that we've finished loading
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
      ));
    });
  }

  int next(int min, int max) => min + Random().nextInt(max - min);

  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));
    await _player.play();
  }

  @override
  Future<void> stop() async {
    // Release any audio decoders back to the system
    await _player.stop();

    // Set the audio_service state to `idle` to deactivate the notification.
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
    ));
    await _player.pause();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: const MotivePlayer(),
    );
  }
}

class MotivePlayer extends StatelessWidget {
  const MotivePlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tap to start motive",
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.w100,
                      fontSize: 30,
                      color: Colors.grey),
                ),
                const Image(
                  image: AssetImage('assets/icon/motive.png'),
                  width: 70,
                  height: 70,
                ),
              ],
            ),
            const SizedBox(
              height: 50.0,
            ),
            StreamBuilder<PlaybackState>(
              stream: _audioHandler.playbackState,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                final processingState =
                    snapshot.data?.processingState ?? AudioProcessingState.idle;
                return (RawMaterialButton(
                  onPressed: () {
                    if (playing) {
                      _audioHandler.pause();
                    } else {
                      _audioHandler.play();
                    }
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(15.0),
                  shape: const CircleBorder(),
                  child: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    size: 100.0,
                  ),
                ));
              },
            )
          ],
        ),
      ),
    );
  }
}
