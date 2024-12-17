import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img; // For image manipulation
import 'dart:convert'; // For loading label file
import 'package:camera/camera.dart'; // Add this import for camera package

class ImageClassifierPage extends StatefulWidget {
  @override
  _ImageClassifierPageState createState() => _ImageClassifierPageState();
}

class _ImageClassifierPageState extends State<ImageClassifierPage> {
  File? _image;
  String _result = "Pick an image to classify.";
  late Interpreter _interpreter;
  late CameraController _cameraController;
  late Future<void> _initializeCamera;
  bool _isCameraReady = false;
  bool _isFromCamera = false; // Flag to check if the image came from the camera or the gallery

  final List<String> _labels = ["Apple", "Banana", "Avocado", "Cherry", "Kiwi", "Mango", "Orange", "Pineapple", "Strawberries", "Watermelon"];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TFLite model

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/fruits10_model.tflite');
  }

  // Initialize the camera and start streaming
  Future<void> _initializeCameraFeed() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(camera, ResolutionPreset.high);
    _initializeCamera = _cameraController.initialize();

    await _initializeCamera;

    setState(() {
      _isCameraReady = true;
      _isFromCamera = true; // Mark the flag to indicate the image source is the camera
    });

    _cameraController.startImageStream((image) {
      // Process image and predict on every frame
      _predictImageFromCamera(image);
    });
  }

 
Future<void> _predictImageFromCamera(CameraImage cameraImage) async {
  if (!_isCameraReady) {
    return; // Don't process if camera is not active
  }

  try {
    var inputImage = _processCameraImage(cameraImage);
    var output = List.generate(1, (i) => List.filled(_labels.length, 0.0));

    _interpreter.run(inputImage, output);

    // Find the class with the highest probability
    int predictedClassIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));

    setState(() {
      _result = _labels[predictedClassIndex]; // Only show the predicted class name
    });
  } catch (e) {
    setState(() {
      _result = "Error: $e";
    });
  }
}

  // Function to process a camera frame into tensor format
  Uint8List _processCameraImage(CameraImage cameraImage) {
    img.Image image = _convertCameraImageToImage(cameraImage);
    img.Image resizedImage = img.copyResize(image, width: 32, height: 32); // Resize to match model input size

    List<double> imageData = [];
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixel(x, y);
        imageData.add(img.getRed(pixel).toDouble());
        imageData.add(img.getGreen(pixel).toDouble());
        imageData.add(img.getBlue(pixel).toDouble());
      }
    }
    return Float32List.fromList(imageData).buffer.asUint8List();
  }

  // Function to convert CameraImage to Image
  img.Image _convertCameraImageToImage(CameraImage cameraImage) {
    final planes = cameraImage.planes;
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image imgImage = img.Image(width, height);

    // Convert the YUV to RGB
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int yIndex = y * width + x;
        int uIndex = yIndex ~/ 4;
        int vIndex = uIndex;

        int yValue = planes[0].bytes[yIndex];
        int uValue = planes[1].bytes[uIndex];
        int vValue = planes[2].bytes[vIndex];

        int r = yValue + (1.402 * (vValue - 128)).toInt();
        int g = yValue - (0.344136 * (uValue - 128) + 0.714136 * (vValue - 128)).toInt();
        int b = yValue + (1.772 * (uValue - 128)).toInt();

        imgImage.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return imgImage;
  }

  // Function to pick an image from the gallery
   // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    // Stop camera image stream to prevent continuous prediction
    _cameraController.stopImageStream();

    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isFromCamera = false; // Mark the flag to indicate the image source is gallery
        _isCameraReady = false; // Hide the camera preview
      });
      _predictImage(_image!);  // Send image for prediction from the gallery
    }
  }


  // Function to preprocess the picked image and send it for prediction
  Future<void> _predictImage(File image) async {
    try {
      var imageBytes = await image.readAsBytes();
      var inputImage = _processImage(imageBytes);

      var output = List.generate(1, (i) => List.filled(_labels.length, 0.0));

      _interpreter.run(inputImage, output);

      setState(() {
        int predictedClass = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
        _result = _isFromCamera
            ? "Camera: " + _labels[predictedClass] // Prefix with 'Camera' text if from camera
            : "Picked Image: " + _labels[predictedClass]; // Prefix with 'Picked Image' text if from gallery
      });
    } catch (e) {
      setState(() {
        _result = "Error: $e";
      });
    }
  }

  // Function to preprocess the picked image
  Uint8List _processImage(Uint8List imageBytes) {
    img.Image? originalImage = img.decodeImage(imageBytes);
    img.Image resizedImage = img.copyResize(originalImage!, width: 32, height: 32);

    List<double> imageData = [];
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixel(x, y);
        imageData.add(img.getRed(pixel).toDouble());
        imageData.add(img.getGreen(pixel).toDouble());
        imageData.add(img.getBlue(pixel).toDouble());
      }
    }
    return Float32List.fromList(imageData).buffer.asUint8List();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text("MobileNet Classifier"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Pick an Image", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeCameraFeed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Start Camera", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (_isCameraReady)
                Stack(
                  children: [
                    Container(
                      width: 300,
                      height: 400,
                      child: CameraPreview(_cameraController),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: Colors.black54,
                        child: Text(
                          _result,
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _image!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                _result,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
