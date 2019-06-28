import 'dart:developer';
import 'dart:io';
import 'dart:ui' as prefix0;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

Color fuenteBlanca = Colors.white.withOpacity(0.6);
Color colorFuentePrincipal = Color(0xfffd5523).withOpacity(0.65);
Color colorFuenteSecundario = Color(0xfff37966f).withOpacity(0.7);
Color colorFondo = Color(0xfffffbe6);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'DancingScript',
        canvasColor: colorFuentePrincipal.withOpacity(0.08),
        textTheme: TextTheme(
          body1: TextStyle(
            color: Color(0xfffd5523).withOpacity(0.65),
          ),
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
      maxHeight: 576,
      maxWidth: 432,
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
        color: Color(0xfffffbe6),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Blured',
              style: TextStyle(fontSize: 64),
            ),
            Container(
              width: 260,
              padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Text(
                'Una forma simple para difuminar rostros en fotografias',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: colorFuenteSecundario,
                ),
              ),
            )
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorFuentePrincipal.withOpacity(0.7),
        child: Icon(
          Icons.image,
          color: colorFondo,
        ),
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
        elevation: 20,
        child: ListView(
          children: List.generate(faces.length + 1, (index) {
            if (!drawerColocado) {
              drawerColocado = true;
              return DrawerHeader(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'MENU',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 32,
                    ),
                  ),
                ),
              );
            } else {
              return Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 24, left: 16),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Icon(
                          Icons.face,
                          color: colorFuentePrincipal.withOpacity(0.5),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 8),
                    child: Slider(
                      key: Key('$index'),
                      activeColor: colorFuenteSecundario,
                      inactiveColor: colorFuenteSecundario,
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
                    ),
                  ),
                ],
              );
            }
          }),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        color: colorFondo,
        child: Center(
          child: FittedBox(
            child: SizedBox(
              width: 432,
              height: 576,
              child: Stack(
                children: List.generate(faces.length + 1, (index) {
                  if (!imagenColocada) {
                    imagenColocada = true;
                    return Image.file(
                      imageFile,
                    );
                  } else {
                    final pos = faces[index - 1].boundingBox;
                    final anchoDeCara =
                        pos.right.toDouble() - pos.left.toDouble();
                    final altoDeCara =
                        pos.bottom.toDouble() - pos.top.toDouble();
                    return Positioned(
                      key: Key('$index'),
                      left: pos.left.toDouble(),
                      top: pos.top.toDouble(),
                      child: Container(
                        width: anchoDeCara,
                        height: altoDeCara,
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
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.grey.shade200.withOpacity(0),
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
