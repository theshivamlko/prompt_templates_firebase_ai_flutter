import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? imageBytes;
  bool isLoading = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> loadImage() async {
    final data = await rootBundle.load('assets/image.jpg');
    setState(() {
      imageBytes = data.buffer.asUint8List();
    });
  }

  Future<void> generateAnime(String filter) async {
    setState(() {
      isLoading = true;
    });

    String base64Image = base64Encode(imageBytes!);

    try {
      var _model = FirebaseAI.googleAI().templateGenerativeModel();

      print(filter);
      var response = await _model.generateContent(
        'imagen-generation-advanced',

        inputs: {'styleReference': filter, "style": "painting","imageBase64":base64Image},
      );

      final image = response.inlineDataParts.first;
      setState(() {
        imageBytes = image.bytes;
        isLoading = false;
      });
    } catch (e, stack) {
      print(e);
      print(stack);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter filter style',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(20)),
              if (imageBytes != null) Image.memory(imageBytes!),
              if (isLoading) CircularProgressIndicator(),
              ElevatedButton(
                onPressed: () => generateAnime(controller.text),
                child: Text('Change into anime'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
