import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(FacePage());

class FacePage extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _FacePageState createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  File _imageFile;
  List<Face> _faces;

  void _getImageAndDetectFaces() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector =
        FirebaseVision.instance.faceDetector(FaceDetectorOptions(
      mode: FaceDetectorMode.accurate,
    ));
    final faces = await faceDetector.processImage(image);
    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New_Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('New_Project'),
        ),
        body:
          _imageFile != null ?
          ImageAndFaces(
          imageFile: _imageFile,
          faces: _faces,
        ) : Text('Нет загруженного файла'),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _getImageAndDetectFaces();
          },
          tooltip: 'Выберите фото',
          child: Icon(Icons.add_a_photo),
        ),
      ),
    );
  }
}

class ImageAndFaces extends StatelessWidget {
  ImageAndFaces({this.imageFile, this.faces})
      : assert(imageFile != null, faces != null);

  final File imageFile;
  final List<Face> faces;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: ListView(
            children: faces.map<Widget>((f) => FaceCoordinates(f)).toList(),
          ),
        )
      ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);

  final Face face;

  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text('${pos.top},${pos.left},${pos.bottom},${pos.right},'),
    );
  }
}

//import 'dart:io';
//import 'dart:ui' as ui;
//
//import 'package:flutter/material.dart';
//import 'package:firebase_ml_vision/firebase_ml_vision.dart';
//import 'package:image_picker/image_picker.dart';
//
//void main() => runApp(
//  MaterialApp(
//    title: 'Flutter Demo',
//    theme: ThemeData(
//      primarySwatch: Colors.blue,
//    ),
//    home: FacePage(),
//  ),
//);
//
//class FacePage extends StatefulWidget {
//  @override
//  _FacePageState createState() => _FacePageState();
//}
//
//class _FacePageState extends State<FacePage> {
//  File _imageFile;
//  List<Face> _faces;
//  bool isLoading = false;
//  ui.Image _image;
//
//  _getImageAndDetectFaces() async {
//    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
//    setState(() {
//      isLoading = true;
//    });
//    final image = FirebaseVisionImage.fromFile(imageFile);
//    final faceDetector = FirebaseVision.instance.faceDetector();
//    List<Face> faces = await faceDetector.processImage(image);
//    if (mounted) {
//      setState(() {
//        _imageFile = imageFile;
//        _faces = faces;
//        _loadImage(imageFile);
//      });
//    }
//  }
//
//  _loadImage(File file) async {
//    final data = await file.readAsBytes();
//    await decodeImageFromList(data).then(
//          (value) => setState(() {
//        _image = value;
//        isLoading = false;
//      }),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: isLoading
//          ? Center(child: CircularProgressIndicator())
//          : (_imageFile == null)
//          ? Center(child: Text('No image selected'))
//          : Center(
//        child: FittedBox(
//          child: SizedBox(
//            width: _image.width.toDouble(),
//            height: _image.height.toDouble(),
//            child: CustomPaint(
//              painter: FacePainter(_image, _faces),
//            ),
//          ),
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _getImageAndDetectFaces,
//        tooltip: 'Pick Image',
//        child: Icon(Icons.add_a_photo),
//      ),
//    );
//  }
//}
//
//class FacePainter extends CustomPainter {
//  final ui.Image image;
//  final List<Face> faces;
//  final List<Rect> rects = [];
//
//  FacePainter(this.image, this.faces) {
//    for (var i = 0; i < faces.length; i++) {
//      rects.add(faces[i].boundingBox);
//    }
//  }
//
//  @override
//  void paint(ui.Canvas canvas, ui.Size size) {
//    final Paint paint = Paint()
//      ..style = PaintingStyle.stroke
//      ..strokeWidth = 15.0
//      ..color = Colors.yellow;
//
//    canvas.drawImage(image, Offset.zero, Paint());
//    for (var i = 0; i < faces.length; i++) {
//      canvas.drawRect(rects[i], paint);
//    }
//  }
//
//  @override
//  bool shouldRepaint(FacePainter oldDelegate) {
//    return image != oldDelegate.image || faces != oldDelegate.faces;
//  }
//}