import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:eslister/model/item.dart';

import 'package:eslister/main.dart' show cameras;

/// A screen that allows users to take a picture using a given camera.
/// Adapted from https://flutter.dev/docs/cookbook/plugins/picture-using-camera
class TakePictureScreen extends StatefulWidget {
  // static const String routeName = '/takepicture'; // Not needed?
  final CameraDescription? camera;

  const TakePictureScreen({
    Key? key,
    this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late Future<void> _initializeControllerFuture;
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Maybe get a specific camera from the list of available cameras?
      cameras[0], // Maybe a chooser??
      ResolutionPreset.high,
    );

    // Next, initialize the camera controller.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription description) {
    print("New camera selected: $description");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // if the controller hasn't yet finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Camera plugin failure: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          print("Tapped! Trying to take a picture");
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;
          } catch (e) {
            print(e);
            return; // XXX Must alert gui user
          }

          // Attempt to take a picture and log where it's been saved.
          XFile picPath = await _controller.takePicture();
          String path = picPath.path;
          print("Image Path is $path}");

          if (!mounted) {
            return;
          }

          // If the picture was taken, display it on a new screen.
          print("Showing new picture for verification");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder:  (context) => AlertDialog(
                    title: const Text("Picture Preview"),
                    content: Image.file(File(path)),
                    actions: <Widget> [
                      TextButton(
                          child: const Text("OK"),
                          onPressed: () async {
                            print("Returning $path");
                            Navigator.of(context).pop(); // Alert
                            Navigator.of(context).pop(path); // CameraScreen
                          }
                      ),
                      TextButton(
                        child: Text("Try again"),
                        onPressed: () {
                          print("User rejected pic; pop Preview to try again.");
                          Navigator.of(context).pop(); // pop AlertDialog
                        },
                      ),
                    ]
                )
            ),
          ).then( (_) {} );
        },
      ),
    );
  }
}
