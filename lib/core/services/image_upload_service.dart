import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  static const String _apiKey = '63b6836c0e81c2c99d475f39f62dc14a';
  static const String _apiUrl = 'https://api.imgbb.com/1/upload';

  /// Uploads an image file to ImgBB and returns the URL of the uploaded image.
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Return the URL of the uploaded image
          return data['data']['url'];
        }
      }
      print('ImgBB Upload Failed: ${response.body}');
      return null;
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      return null;
    }
  }
}
