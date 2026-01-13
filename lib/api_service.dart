import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // 使用硬编码方式配置，根据用户提供的值设置API_HOST和API_PORT
  static const String BACKEND_URL = "https://coachwriting.vercel.app"; // 端口443使用HTTPS协议

  // Evaluate text using the backend API
  static Future<Map<String, dynamic>?> evaluateText(String text) async {
    try {
      final payload = {
        "text": text,
        "user_id": "flutter_user",
        "title": "Flutter Writing Coach"
      };

      final response = await http.post(
        Uri.parse('$BACKEND_URL/evaluate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Backend error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Connection error: $e');
      return null;
    }
  }

  // Evaluate file using the backend API
  static Future<Map<String, dynamic>?> evaluateFile(PlatformFile file) async {
    // Determine if it's an image file or pdf file
    String lowerFileName = file.name.toLowerCase();
    bool isImageFile = ['.png', '.jpg', '.jpeg'].any((ext) => lowerFileName.endsWith(ext));
    bool isPdfFile = lowerFileName.endsWith('.pdf');
    bool isTextFile = ['.txt', '.md', '.csv'].any((ext) => lowerFileName.endsWith(ext));

    if (isImageFile || isPdfFile) {
      // Handle image and pdf files using evaluate-image endpoint
      return await _evaluateImageFile(file);
    } else if (isTextFile) {
      // Handle text files by reading content and sending to evaluate endpoint
      return await _evaluateTextFile(file);
    } else {
      // For unsupported files, attempt to send as image
      return await _evaluateImageFile(file);
    }
  }

  // Evaluate image file using the backend API
  static Future<Map<String, dynamic>?> _evaluateImageFile(PlatformFile file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$BACKEND_URL/evaluate-image'),
      );

      // Add the form fields like in the Python implementation
      request.fields['user_id'] = 'flutter_user';
      request.fields['title'] = 'Flutter Writing Coach File Upload';

      // Determine the media type based on file extension
      MediaType mediaType = _getMediaType(file.name);

      // Add the file to the request with the correct field name
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Using 'image' field name to match the Python backend
          file.bytes!,
          filename: file.name,
          contentType: mediaType, // Set the correct content type
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Backend error: ${response.statusCode}, body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Connection error: $e');
      return null;
    }
  }

  // Evaluate text file by reading its content and sending to text evaluation endpoint
  static Future<Map<String, dynamic>?> _evaluateTextFile(PlatformFile file) async {
    try {
      // Decode the bytes to string
      String content = utf8.decode(file.bytes!);
      
      // Send the content to the text evaluation endpoint
      return await evaluateText(content);
    } catch (e) {
      print('Error reading text file: $e');
      return null;
    }
  }

  // Helper function to determine media type based on file extension
  static MediaType _getMediaType(String fileName) {
    final ext = fileName.toLowerCase();
    if (ext.endsWith('.png')) {
      return MediaType('image', 'png');
    } else if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    } else if (ext.endsWith('.pdf')) {
      return MediaType('application', 'pdf');
    } else if (ext.endsWith('.txt')) {
      return MediaType('text', 'plain');
    } else if (ext.endsWith('.csv')) {
      return MediaType('text', 'csv');
    } else if (ext.endsWith('.doc')) {
      return MediaType('application', 'msword');
    } else if (ext.endsWith('.docx')) {
      return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
    } else if (ext.endsWith('.md')) {
      return MediaType('text', 'markdown');
    } else {
      // Default to octet-stream if unknown
      return MediaType('application', 'octet-stream');
    }
  }

  // Check backend health status
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$BACKEND_URL/health'));

      if (response.statusCode == 200) {
        final healthData = jsonDecode(response.body);
        return healthData['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }
}