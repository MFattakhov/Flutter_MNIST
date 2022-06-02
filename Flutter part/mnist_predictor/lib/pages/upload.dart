import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnist_predictor/dl_model/classifier.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final picker = ImagePicker();
  Classifier classifier = Classifier();
  late XFile image;
  int digit = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          image = (await picker.pickImage(source: ImageSource.gallery))!;
          digit = await classifier.classifyImage(image);
          setState(() {});
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.camera_alt_outlined),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: const Text('Handwritten number recognition'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            const Text(
              'Image will be shown below',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2.0),
                  image: DecorationImage(
                    image: digit == -1
                        ? const AssetImage('assets/white_background.jpg')
                            as ImageProvider
                        : FileImage(File(image.path)),
                  ),
                )),
            const SizedBox(
              height: 45,
            ),
            const Text(
              'Current prediction',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              digit == -1 ? '' : '$digit',
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
