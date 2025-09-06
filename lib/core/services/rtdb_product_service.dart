import 'package:firebase_database/firebase_database.dart';
import '../models/product.dart';

class RtdbProductService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('products');

  Stream<List<Product>> productsStream() {
    return _ref.onValue.map((event) {
      final snap = event.snapshot;
      if (snap.value == null) return <Product>[];
      final map = Map<String, dynamic>.from(snap.value as Map);
      return map.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        data['id'] = e.key;
        return Product.fromJson(data);
      }).toList();
    });
  }

  Future<String> createProduct(Product p) async {
    final newRef = _ref.push();
    final data = p.toJson()..remove('id');
    data['createdAt'] = DateTime.now().toUtc().toIso8601String();
    await newRef.set(data);
    return newRef.key!;
  }

  Future<void> updateProduct(Product p) async {
    final id = p.id;
    final data = p.toJson()..remove('id');
    data['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await _ref.child(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _ref.child(id).remove();
  }
}
