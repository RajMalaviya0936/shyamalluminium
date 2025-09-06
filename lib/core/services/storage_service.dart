import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadQuotationPdf(Uint8List bytes, String quotationId) async {
    final path = 'quotations/$quotationId.pdf';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> deleteQuotationPdf(String quotationId) async {
    final path = 'quotations/$quotationId.pdf';
    final ref = _storage.ref().child(path);
    await ref.delete();
  }
}
