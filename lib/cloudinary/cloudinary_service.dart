import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  String cloudName = 'dpktkeda7';
  String apiKey = '578586723454899';
  String apiSecret = '7UG6Ny__sB-_KCybTbMJYsqoMK8';

  Future<String?> uploadImageToCloudinary({
    required File imageFile,
    required String folderName,
  }) async {
    print('Entered image upload method');
    final url =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Create the signature
    final signatureData = 'folder=$folderName&timestamp=$timestamp$apiSecret';
    final signature = sha1.convert(utf8.encode(signatureData)).toString();

    // Prepare request
    var request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['folder'] = folderName
      ..fields['signature'] = signature
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    // Send request
    var response = await request.send();
    if (response.statusCode == 200) {
      print('upload success');
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);
      print(resJson['secure_url']);
      return resJson['secure_url']; // This is the public URL
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }
}
