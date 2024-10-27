import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // Import TFLite Flutter package
import 'dart:io';

class PredictivePage extends StatefulWidget {
  @override
  _PredictivePageState createState() => _PredictivePageState();
}

class _PredictivePageState extends State<PredictivePage> {
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter; // Declare an interpreter for model inference
  bool _isModelLoaded = false; // Track if the model is loaded

  // Load the model
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('trained_model.tflite');
    setState(() {
      _isModelLoaded = true; // Update model load status
    });
    print("Model loaded");
  }

  @override
  void initState() {
    super.initState();
    loadModel(); // Load the model when the app starts
  }

  Future<void> _sendImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _messages.add({'image': File(pickedFile.path)});
      });

      // Ensure the model is loaded before predicting
      if (_isModelLoaded) {
        // Predict the image type
        String prediction = await predictImage(pickedFile.path);

        // Add the prediction result to the chat
        setState(() {
          _messages.add({'text': prediction, 'image': null});
        });
      } else {
        setState(() {
          _messages.add({'text': "Model not loaded yet.", 'image': null});
        });
      }
    }
  }

  Future<String> predictImage(String imagePath) async {
    if (_interpreter == null) {
      return "Interpreter not initialized.";
    }

    var inputImage = await _preprocessImage(imagePath);
    if (inputImage != null) {
      var output = List.filled(5, 0).reshape([1, 5]); // Adjust according to your model's output shape
      _interpreter.run(inputImage, output);

      // Process the output to get a human-readable response
      String result = processOutput(output);
      return result;
    } else {
      return "Image processing failed.";
    }
  }

  Future<List<List<List<List<double>>>>?> _preprocessImage(String imagePath) async {
    // Load the image and preprocess it to match your model's input shape
    // Return the processed image as a tensor
    // Placeholder for image processing code
    return []; // Return the preprocessed image in the required format
  }

  String processOutput(List<dynamic> output) {
    // Convert the model's output to a user-friendly message
    // Placeholder logic - adjust based on your model's predictions
    return "Predicted class: ${output[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Predictive Page"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                if (_messages[index]['text'] != null) {
                  return ListTile(
                    title: Text(_messages[index]['text']),
                  );
                } else if (_messages[index]['image'] != null) {
                  return ListTile(
                    title: Image.file(_messages[index]['image']),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _isModelLoaded ? _sendImage : null, // Disable button if model not loaded
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
