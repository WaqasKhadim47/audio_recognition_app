import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recognition App',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _sound = "Press the button to start";
  bool _recording = false;
  Stream<Map<dynamic, dynamic>>? result;

  @override
  void initState() {
    super.initState();
    TfliteAudio.loadModel(
        model: 'assets/soundclassifier.tflite',
        label: 'assets/labels.txt',
        inputType: 'rawAudio',
        numThreads: 1,
        isAsset: true);
  }

  void _recorder() {
    String recognition = "";
    if (!_recording) {
      setState(() => _recording = true);
      result = TfliteAudio.startAudioRecognition(
        numOfInferences: 1,
        sampleRate: 44100,
        bufferSize: 22016,
      );
      result?.listen((event) {
        print("Printed ===> ${event.toString()}");
        recognition = event["recognitionResult"];
      }).onDone(() {
        setState(() {
          _recording = false;
          _sound = recognition.split(" ")[1];
        });
      });
    }
  }

  void stop() {
    TfliteAudio.stopAudioRecognition();
    setState(() => _recording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                "What's this sound?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            MaterialButton(
              onPressed: _recorder,
              color: _recording ? Colors.grey : Colors.pink,
              textColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(25),
              child: const Icon(Icons.mic, size: 60),
            ),
            Text(
              _sound,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ),
    );
  }
}
