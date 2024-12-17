import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class FruitDetectionPage extends StatefulWidget {
  @override
  _FruitDetectionPageState createState() => _FruitDetectionPageState();
}

class _FruitDetectionPageState extends State<FruitDetectionPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;
  String _resultText = '';
  String _imageUrl = '';
  List<Map<String, dynamic>> _predictions = [];
  double _imageWidth = 0;
  double _imageHeight = 0;

  // Upload image and get predictions
  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    final String apiUrl = 'https://94f4-41-250-212-200.ngrok-free.app/predict';
  // Update with your backend URL

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var data = json.decode(responseData.body);

      setState(() {
        _isLoading = false;
        _resultText = 'Predictions: ${data['predictions']}';
        _imageUrl = data['image_url'];  // Get the URL of the image with bounding boxes
        _predictions = List<Map<String, dynamic>>.from(data['predictions']);
      });
    } else {
      setState(() {
        _isLoading = false;
        _resultText = 'Error: ${response.statusCode}';
      });
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
       // Clear predictions on new image pick
            _predictions = []; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fruit Detection'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null && _predictions.isEmpty)
  // Show picked image without bounding boxes
  FutureBuilder(
    future: _loadImageSize(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return Center(
          child: Image.file(
            _image!,
            // Ensure the image fits within the container
          ),
        );
      } else {
        return CircularProgressIndicator();
      }
    },
  ),
if (_image != null && _predictions.isNotEmpty)
  // Show image with bounding boxes after prediction
  FutureBuilder(
    future: _loadImageSize(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return Stack(
          children: [
            // Display image centered
            Center(
              child: Image.file(
                _image!,
                width: _imageWidth,
                height: _imageHeight,
                fit: BoxFit.contain, // Ensure the image fits within the container
              ),
            ),
            CustomPaint(
              size: Size(_imageWidth, _imageHeight), // Use dynamic size
              painter: BoundingBoxPainter(_predictions, _imageWidth, _imageHeight),
            ),
          ],
        );
      } else {
        return CircularProgressIndicator();
      }
    },
  ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick an Image'),
              ),
              SizedBox(height: 20),
              if (_isLoading) CircularProgressIndicator(),
              if (!_isLoading && _resultText.isNotEmpty) Text(_resultText),
              SizedBox(height: 20),
              if (_imageUrl.isNotEmpty)
                Image.network(_imageUrl),  // Show the image with bounding boxes
              
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload and Predict'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Load image size
  Future<void> _loadImageSize() async {
    final image = Image.file(_image!);
    final completer = Completer<void>();

    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        setState(() {
          _imageWidth = info.image.width.toDouble();
          _imageHeight = info.image.height.toDouble();
        });
        completer.complete();
      }),
    );
    return completer.future;
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> predictions;
  final double imageWidth;
  final double imageHeight;
  final double modelImageWidth = 330; // Width of the image the model was trained on
  final double modelImageHeight = 220; // Height of the image the model was trained on

  BoundingBoxPainter(this.predictions, this.imageWidth, this.imageHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calculate scaling factors based on the actual image size and the model's image size
    double scaleX = imageWidth / modelImageWidth;
    double scaleY = imageHeight / modelImageHeight;

    for (var prediction in predictions) {
      // Apply scaling to bounding box coordinates
      final x = prediction['x'] * scaleX;
      final y = prediction['y'] * scaleY;
      final width = prediction['width'] * scaleX;
      final height = prediction['height'] * scaleY;

      // Draw the bounding box on the canvas
      canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
