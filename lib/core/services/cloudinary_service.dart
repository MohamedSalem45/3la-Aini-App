import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  static const _cloudName = 'dvqoqpeni';
  static const _uploadPreset = 'ala_ainy_invoices'; // سننشئه في Cloudinary
  static const _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  Future<String?> uploadInvoice(Uint8List imageBytes, String orderId) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = 'invoices'
        ..fields['public_id'] = 'invoice_$orderId'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'invoice_$orderId.jpg',
        ));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);

      if (response.statusCode == 200) {
        return json['secure_url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
