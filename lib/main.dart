import 'dart:io';
import 'dart:ui' as prefix0;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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
      return _faces.isEmpty
          ? NoImage()
          : ImagesAndFaces(imageFile: _imageFile, faces: _faces);
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
    File screenshot;
    ScreenshotController screenShootController = ScreenshotController();
    //variable para conseguir las posiciones del primer rostro
    final pos = faces[0].boundingBox;
    final anchoDeCara = pos.right.toDouble() - pos.left.toDouble();
    final altoDeCara = pos.bottom.toDouble() - pos.top.toDouble();

    return Scaffold(
      body: Screenshot(
        controller: screenShootController,
        child: Center(
          child: Stack(
            children: <Widget>[
              Image.file(
                imageFile,
              ),
              //Texto referencial con posición izquierda del rostro.

              Text(
                '${pos.left.toDouble()} \n ${pos.right.toDouble()} \n ${pos.top.toDouble()} \n ${pos.bottom.toDouble()}',
                style: TextStyle(fontSize: 30),
              ),

              //Bloque que dibuja recuadro censurador de rostros.
              Positioned(
                left: pos.left.toDouble(),
                top: pos.top.toDouble(),
                child: Container(
                  width: anchoDeCara,
                  height: altoDeCara,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: BackdropFilter(
                            filter: prefix0.ImageFilter.blur(
                                sigmaX: 4.0, sigmaY: 4.0),
                            child: new Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200.withOpacity(0)),
                              child: Center(
                                child: Text('Blured',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12)),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          screenShootController.capture().then((File image) async{
            screenshot = image;
            final result =
                await ImageGallerySaver.save(image.readAsBytesSync()); 
            print("File Saved to Gallery");
          });
        },
        child: Icon(Icons.share),
      ),
    );
  }
}

class NoImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NO DATA!'),
      ),
    );
  }
}
