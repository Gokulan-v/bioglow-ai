import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // Import TFLite Flutter package
import 'dart:io';
import 'package:image/image.dart' as img;

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter; // Declare an interpreter for model inference

  // Load the model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/trained_model.tflite');
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Predict the image
  Future<void> predictImage(String imagePath) async {
    var inputImage = await _preprocessImage(imagePath);

    if (inputImage != null) {
      // Create an output array with the appropriate size
      var output = List.generate(1, (_) => List.filled(5, 0.0)); // Adjust according to your model's output shape
      _interpreter.run(inputImage, output);
      print("Prediction output: $output");

      // Extract the prediction result and send it as a message
      String response = outputToResponse(output);
      _sendResponseMessage(response);
    } else {
      print("Input image is null, unable to run inference.");
      _sendResponseMessage("Error processing image for prediction.");
    }
  }

  String outputToResponse(List<List<dynamic>> output) {
    // Convert the output into a user-friendly message
    // You can customize this based on your model's specific output format
    return "Predicted class: ${output[0].toString()}"; // Placeholder response
  }

  // Implement image preprocessing
  Future<List<List<List<List<double>>>>?> _preprocessImage(String imagePath) async {
    var imageFile = File(imagePath);
    img.Image originalImage = img.decodeImage(imageFile.readAsBytesSync())!;

    // Resize the image to match the model's input size (example: 224x224)
    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    // Prepare the image tensor
    List<List<List<List<double>>>> imageTensor = List.generate(
      1,
          (_) => List.generate(
        224,
            (i) => List.generate(
          224,
              (j) {
            // Get the pixel using the getPixel method
            int pixel = resizedImage.getPixel(j, i) as int;

            // Extract RGB values from the pixel value
            int r = (pixel >> 16) & 0xFF; // Get red channel
            int g = (pixel >> 8) & 0xFF;  // Get green channel
            int b = pixel & 0xFF;         // Get blue channel

            return [
              r / 255.0, // Normalize R
              g / 255.0, // Normalize G
              b / 255.0  // Normalize B
            ];
          },
        ),
      ),
    );

    return imageTensor;
  }

  void _sendResponseMessage(String response) {
    setState(() {
      _messages.add({'text': response, 'image': null});
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel(); // Load the model when the app starts
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({'text': _messageController.text, 'image': null});
        _messageController.clear();
      });
    }
  }

  Future<void> _sendImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _messages.add({'text': null, 'image': File(pickedFile.path)});
      });
      await predictImage(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot"),
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
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: "Type your message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
