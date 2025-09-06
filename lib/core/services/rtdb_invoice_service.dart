import 'package:firebase_database/firebase_database.dart';
import '../models/invoice.dart';

class RtdbInvoiceService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('invoices');

  Stream<List<Invoice>> invoicesStream() {
    return _ref.onValue.map((event) {
      final snap = event.snapshot;
      if (snap.value == null) return <Invoice>[];
      final map = Map<String, dynamic>.from(snap.value as Map);
      return map.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        data['id'] = e.key;
        return Invoice.fromJson(data);
      }).toList();
    });
  }

  Future<String> createInvoice(Invoice q) async {
    final newRef = _ref.push();
    final data = q.toJson()..remove('id');
    data['createdAt'] = DateTime.now().toUtc().toIso8601String();
    await newRef.set(data);
    return newRef.key!;
  }

  Future<void> updateInvoice(Invoice q) async {
    final id = q.id;
    final data = q.toJson()..remove('id');
    data['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await _ref.child(id).update(data);
  }

  Future<void> deleteInvoice(String id) async {
    await _ref.child(id).remove();
  }
}
