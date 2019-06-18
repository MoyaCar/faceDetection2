import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

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

  void pickImage() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
        enableLandmarks: true,
      ),
    );
    final faces = await faceDetector.detectInImage(image);
    setState(() {
      _faces = faces;
      _imageFile = imageFile;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageAndFaces(
        faces: _faces,
        imageFile: _imageFile,
      );
    }));
  }

//vista principal de la Aplicacion
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.photo),
      ),
    );
  }
}

//vista con la imagen cargada
class ImageAndFaces extends StatelessWidget {
  final File imageFile;
  final List<Face> faces;
  ImageAndFaces({this.imageFile, this.faces});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        
        children: <Widget>[
          Image.file(imageFile, fit: BoxFit.none),
          Positioned(
            top: 57,
            left: 180 ,
            child: Container(
              color: Colors.amber,
              width: 100,
              height: 100,
            ),
          ),
          Text(faces[0].boundingBox.topLeft.toString(),style: TextStyle(fontSize: 32,color:Colors.green),)
        ],
      ),
    );
  }
}
