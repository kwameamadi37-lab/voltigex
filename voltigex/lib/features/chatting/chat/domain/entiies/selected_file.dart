
import 'dart:typed_data';

class SelectedMedia {
  final String name;
  final String? path;      // utile si tu veux File(path)
  final Uint8List? bytes;  // utile pour envoi direct base64
  final String? extension;

  SelectedMedia({
    required this.name,
    this.path,
    this.bytes,
    this.extension,
  });
}