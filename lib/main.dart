import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeWidgetState();
  }
}

class HomeWidgetState extends State<HomeWidget> {
  File _imageFile;
  List<Face> _faces;

  void _getAndDetectFaces() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(mode: FaceDetectorMode.accurate),
    );
    final faces = await faceDetector.detectInImage(image);
    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:ImagesAndFaces(),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> _getAndDetectFaces,
      ),
    );
  }
}

class ImagesAndFaces extends StatelessWidget {
  final File imageFile;
  final List<Face> faces;

  const ImagesAndFaces({Key key, this.imageFile, this.faces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Image.file(imageFile),
        ),
        Flexible(
          flex: 1,
          child: ListView(
            children: faces
                .map<Widget>((f) => FaceCoordinates(
                      face: f,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  final Face face;

  const FaceCoordinates({Key key, this.face}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text('(${pos.top},${pos.left},${pos.right},${pos.bottom})'),
    );
  }
}
