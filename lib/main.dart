import 'dart:developer';
import 'dart:io';
import 'dart:ui' as prefix0;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

Color fuenteBlanca = Colors.white.withOpacity(0.6);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        canvasColor: Colors.grey.withOpacity(0.1),
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.white30),
        ),
      ),
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
      maxHeight: 640,
      maxWidth: 400,
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
          : ImageAndFaces(imageFile: _imageFile, faces: _faces);
    }));
  }

// Vista inicial con un botón flotante que inicia el procesado
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.photo_camera),
        onPressed: _getAndDetectFaces,
      ),
    );
  }
}

class ImageAndFaces extends StatefulWidget {
  final File imageFile;
  final List<Face> faces;

  const ImageAndFaces({Key key, this.imageFile, this.faces}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ImageAndFacesState(imageFile, faces);
  }
}

// Vista de destino con la imagen Procesada y la Lista de rostros
class ImageAndFacesState extends State<ImageAndFaces> {
  ScreenshotController screenShootController = ScreenshotController();
  final File imageFile;
  final List<Face> faces;

  List<double> blurValors = [2.0];
  void contarRostros() {
    if (!valoresInicialesAgregados) {
      for (var i = 0; i < faces.length; i++) {
        blurValors.add(2.0);
      }
      print('ACAAAAA!!!: $blurValors');
      valoresInicialesAgregados = true;
    }
  }

  double blurvalor = 2.0;
  ImageAndFacesState(this.imageFile, this.faces);
  bool valoresInicialesAgregados = false;
  bool imagenColocada = false;
  bool drawerColocado = false;
  @override
  Widget build(BuildContext context) {
    contarRostros();
    //variable para conseguir las posiciones del primer rostro

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: List.generate(faces.length + 1, (index) {
            if (!drawerColocado) {
              drawerColocado = true;
              return DrawerHeader(
                child: Container(
                  child: Text(
                    'MENU',
                    style: TextStyle(color: fuenteBlanca),
                  ),
                ),
              );
            } else {
              return Slider(
                key: Key('$index'),
                activeColor: Colors.grey.withOpacity(0.60),
                inactiveColor: Colors.grey.withOpacity(0.60),
                max: 4.0,
                min: 0.0,
                value: blurValors[index],
                onChanged: (nuevoBlurvalor) {
                  setState(() {
                    blurValors[index] = nuevoBlurvalor;
                    imagenColocada = false;
                    drawerColocado = false;
                    print('valor: ${blurValors[index]}');
                  });
                },
              );
            }
          }),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
              child: Center(
          child: Stack(
            children: List.generate(faces.length + 1, (index) {
              if (!imagenColocada) {
                imagenColocada = true;
                return Image.file(
                  imageFile,
                );
              } else {
                final pos = faces[index - 1].boundingBox;
                final anchoDeCara = pos.right.toDouble() - pos.left.toDouble();
                final altoDeCara = pos.bottom.toDouble() - pos.top.toDouble();
                return Positioned(
                  key: Key('$index'),
                  left: pos.left.toDouble()* 0.85,
                  top: pos.top.toDouble() * 0.8,
                  child: Container(
                    width: anchoDeCara,
                    height: altoDeCara * 1.18,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: BackdropFilter(
                              filter: prefix0.ImageFilter.blur(
                                  sigmaX: blurValors[index],
                                  sigmaY: blurValors[index]),
                              child: new Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200.withOpacity(0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
          ),
        ),
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
