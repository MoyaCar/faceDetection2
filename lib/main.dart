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


  // Metodo a cargo de tomar la foto y de detectar los rostros en la imagen.
  void _getAndDetectFaces() async {

    //Image picker toma una imagen desde la galería(se puede cambiar a camara) y le asigna tamaño maximo para voler
    //el procesado más certero.
    final imageFilex = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 320,
      maxWidth: 320,
    );

    //Envía la imagen a la IA engargada de detectar los rostros
    final image = FirebaseVisionImage.fromFile(imageFilex);

    //Implementa FaceDetector a la imagen
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(mode: FaceDetectorMode.accurate),
    );

    // Devuelve una lista de rostros detectados en la imagen.
    final facesx = await faceDetector.detectInImage(image);

    // Refresca la aplicacion con la lista 
    if (mounted) {
      setState(() {
        _imageFile = imageFilex;
        _faces = facesx;
      });
    }
    // Envia la aplicacion a la vista con la imagen procesada. 
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImagesAndFaces(imageFile: _imageFile, faces: _faces);
    }));
  }

// Vista inicial con un botón flotante que inicia el procesador
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

// Vista de destino con la imagen Procesada y la Lista de rostros
class ImagesAndFaces extends StatelessWidget {
  final File imageFile;
  final List<Face> faces;

  const ImagesAndFaces({Key key, this.imageFile, this.faces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //variable para conseguir las posiciones del primer rostro
    final pos = faces[0].boundingBox;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          
          Image.file(
            imageFile,
         
          ),
          //Texto referencial con posición izquierda del rostro.
          
          Text(
            '${pos.left.toDouble()}',
            style: TextStyle(fontSize: 30),
          ),

          //Bloque que dibuja recuadro censurador de rostros.
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
