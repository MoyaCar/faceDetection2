import 'dart:io';
import 'dart:ui' as prefix0;

import 'package:image/image.dart' as img;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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

//Widget con vista central.
class HomeWidgetState extends State<HomeWidget> {
  File _imageFile;
  List<Face> _faces;
  Image imageresized;
  void _getAndDetectFaces() async {
    final imageFilex = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 320,
      maxWidth: 320,
    );

    final image = FirebaseVisionImage.fromFile(imageFilex);

    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(mode: FaceDetectorMode.accurate),
    );
    final facesx = await faceDetector.detectInImage(image);
    if (mounted) {
      setState(() {
        _imageFile = imageFilex;
        _faces = facesx;
      });
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImagesAndFaces(imageFile: _imageFile, faces: _faces);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 320,
        height: 640,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.photo_camera),
        onPressed: _getAndDetectFaces,
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
    final pos = faces[0].boundingBox;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Image.file(
            imageFile,
         
          ),
          Text(
            '${pos.left.toDouble()}',
            style: TextStyle(fontSize: 30),
          ),
          Positioned(
            left: pos.left.toDouble(),
            top: pos.top.toDouble(),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.amber.withOpacity(0.2),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter:
                            prefix0.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: new Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200.withOpacity(0),
                          ),
                          child: Center(
                            child: Text('Blured'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
