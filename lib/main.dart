import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
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

class MotivePlayer extends StatefulWidget {
  const MotivePlayer({super.key});

  @override
  State<MotivePlayer> createState() => _MotivePlayerState();
}

class _MotivePlayerState extends State<MotivePlayer> {
  bool _play = false;
  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    int number = next(1, 19);
    _load("audio/$number.mp3");
  }

  @override
  void dispose() {
    _remove();
    super.dispose();
  }

  _remove() async {
    await player.dispose();
  }

  _load(path) async {
    await player.setSource(AssetSource(path));
  }

  _pause() async {
    await player.pause();
  }

  _resume() async {
    await player.resume();
  }

  int next(int min, int max) => min + Random().nextInt(max - min);

  void switchPlay() {
    setState(() {
      _play = !_play;
    });
    if (_play) {
      _resume();
    } else {
      _pause();
    }
  }

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
              children: const [
                Text(
                  "Tap to start motive",
                  style: TextStyle(color: Colors.grey, fontSize: 30),
                ),
                Image(
                  image: AssetImage('assets/icon/motive.png'),
                  width: 70,
                  height: 70,
                ),
              ],
            ),
            const SizedBox(
              height: 50.0,
            ),
            RawMaterialButton(
              onPressed: () {
                switchPlay();
              },
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(15.0),
              shape: const CircleBorder(),
              child: Icon(
                _play ? Icons.pause : Icons.play_arrow,
                size: 100.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
