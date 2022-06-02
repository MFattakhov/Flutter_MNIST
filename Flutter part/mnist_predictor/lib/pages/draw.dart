import 'package:flutter/material.dart';
import 'package:mnist_predictor/dl_model/classifier.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({Key? key}) : super(key: key);

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  Classifier classifier = Classifier();
  List<Offset> points = <Offset>[];
  int digit = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          points.clear();
          setState(() {
            digit = -1;
          });
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.close),
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
              'Draw a digit inside the box',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 300 + 2 * 2.0,
              width: 300 + 2 * 2.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  )),
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  Offset localPosition = details.localPosition;
                  setState(() {
                    if (300 >= localPosition.dx &&
                        localPosition.dx >= 0 &&
                        300 >= localPosition.dy &&
                        localPosition.dy >= 0) {
                      points.add(localPosition);
                    }
                  });
                },
                onPanEnd: (DragEndDetails details) async {
                  points.add(Offset.infinite);
                  digit = await classifier.classifyDrawing(points);
                  setState(() {});
                },
                child: CustomPaint(
                  painter: Painter(points: points),
                ),
              ),
            ),
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

class Painter extends CustomPainter {
  final List<Offset> points;
  Painter({required this.points});

  final Paint paintDetails = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paintDetails);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
