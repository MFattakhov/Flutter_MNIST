import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class Classifier {
  Classifier();

  classifyImage(XFile image) async {
    // XFile -> Uint8List
    var file = io.File(image.path);
    img.Image? imageTemp = img.decodeImage(file.readAsBytesSync());
    img.Image resizedImg = img.copyResize(imageTemp!, height: 28, width: 28);
    var imgBytes = resizedImg.getBytes();
    var imgAsList = imgBytes.buffer.asUint8List();

    return getPrediction(imgAsList);
  }

  Future<int> getPrediction(Uint8List imgAsList) async {
    List resultBytes = List.filled(28 * 28, null, growable: false);

    int index = 0;
    for (int i = 0; i < imgAsList.lengthInBytes; i += 4) {
      final r = imgAsList[i];
      final g = imgAsList[i + 1];
      final b = imgAsList[i + 2];

      resultBytes[index] = ((r + g + b) / 3.0) / 255.0;
      index++;
    }

    var input = resultBytes.reshape([1, 28, 28, 1]);
    var output = List.filled(1 * 10, null, growable: false).reshape([1, 10]);

    InterpreterOptions interpreterOptions = InterpreterOptions();

    try {
      Interpreter interpreter = await Interpreter.fromAsset(
        'model.tflite',
        options: interpreterOptions,
      );
      interpreter.run(input, output);
    } catch (e) {
      return -2;
    }

    double highestProbability = 0;
    int digitPredicted = 0;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > highestProbability) {
        highestProbability = output[0][i];
        digitPredicted = i;
      }
    }

    return digitPredicted;
  }

  classifyDrawing(List<Offset> points) async {
    // List<Offset> -> Uint8List
    final picture = toPicture(points);
    final image = await picture.toImage(28, 28);
    ByteData? imgBytes = await image.toByteData();
    var imgAsList = imgBytes!.buffer.asUint8List();

    return getPrediction(imgAsList);
  }

  ui.Picture toPicture(List<Offset> points) {
    final whitePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.white
      ..strokeWidth = 16.0;

    final bgPaint = Paint()..color = Colors.black;
    final canvasCullRect = Rect.fromPoints(
      const Offset(0, 0),
      const Offset(28.0, 28.0),
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, canvasCullRect)
      ..scale(28 / 300);

    canvas.drawRect(const Rect.fromLTWH(0, 0, 28, 28), bgPaint);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], whitePaint);
      }
    }

    return recorder.endRecording();
  }
}
