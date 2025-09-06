import 'package:firebase_database/firebase_database.dart';
import '../models/quotation.dart';

class RtdbQuotationService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('quotations');

  Stream<List<Quotation>> quotationsStream() {
    return _ref.onValue.map((event) {
      final snap = event.snapshot;
      if (snap.value == null) return <Quotation>[];
      final map = Map<String, dynamic>.from(snap.value as Map);
      return map.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        data['id'] = e.key;
        return Quotation.fromJson(data);
      }).toList();
    });
  }

  Future<String> createQuotation(Quotation q) async {
    final newRef = _ref.push();
    final data = q.toJson()..remove('id');
    data['createdAt'] = DateTime.now().toUtc().toIso8601String();
    await newRef.set(data);
    final itemsRef = newRef.child('items');
    for (var item in q.items) {
      await itemsRef.push().set(item.toJson());
    }
    return newRef.key!;
  }

  Future<void> updateQuotation(Quotation q) async {
    final id = q.id;
    final data = q.toJson()..remove('id');
    data['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    final nodeRef = _ref.child(id);
    await nodeRef.update(data);
    final itemsRef = nodeRef.child('items');
    final snapshot = await itemsRef.get();
    if (snapshot.exists) {
      for (final child in snapshot.children) {
        await itemsRef.child(child.key!).remove();
      }
    }
    for (var item in q.items) {
      await itemsRef.push().set(item.toJson());
    }
  }

  Future<void> deleteQuotation(String id) async {
    await _ref.child(id).remove();
  }

  Stream<List<QuotationItem>> itemsStream(String quotationId) {
    final itemsRef = _ref.child(quotationId).child('items');
    return itemsRef.onValue.map((event) {
      final snap = event.snapshot;
      if (snap.value == null) return <QuotationItem>[];
      final map = Map<String, dynamic>.from(snap.value as Map);
      return map.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        data['id'] = e.key;
        return QuotationItem.fromJson(data);
      }).toList();
    });
  }
}
