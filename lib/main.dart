import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomeScreen(camera: firstCamera),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  void _openCamera(BuildContext context) async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              TakePictureScreen(camera: camera, title: 'Flutter Demo Camera'),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Camera App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Camera App'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Tap the button bellow to open the camera.'),
            ElevatedButton(
              child: const Text('Open cameras'),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TakePictureScreen(
                          title: 'Flutter Demo Camera', camera: camera)),
                )
              },
            ),
          ],
        )),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.title,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;
  final String title;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(child: Text('Confirmar foto')),
          backgroundColor: Colors.black),
      body: Center(
        heightFactor: 1.04,
        child: Image.file(File(imagePath), scale: 0.5),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: 'Reject',
              backgroundColor: Colors.transparent,
              child: const Icon(
                Icons.close,
                size: 30,
                color: Colors.white,
              ),
              heroTag: null),
          FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: 'Accept',
              backgroundColor: Colors.transparent,
              child: const Icon(
                Icons.check,
                size: 30,
                color: Colors.white,
              ),
              heroTag: null)
        ],
      ),
    );
  }
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  void _takePircture() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to take a picture and then get the location
      // where the image file is saved.
      final image = await _controller.takePicture();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            // Pass the automatically generated path to
            // the DisplayPictureScreen widget.
            imagePath: image.path,
          ),
        ),
      );
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final scale = 1 /
    //     (_controller.value.aspectRatio *
    //         MediaQuery.of(context).size.aspectRatio);
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white,
              tooltip: 'Close camera',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return Transform.scale(
                  scale: 1,
                  alignment: Alignment.topCenter,
                  child: CameraPreview(_controller),
                );
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            onPressed: _takePircture,
            tooltip: 'Take Photo',
            backgroundColor: Colors.transparent,
            child: const Icon(
              Icons.camera,
              size: 56,
              color: Colors.white,
            )));
  }
}
