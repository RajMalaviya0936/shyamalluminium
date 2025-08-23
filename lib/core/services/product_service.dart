import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ProductService {
  static const _key = 'products';

  // Export product list to PDF and save to local storage
  Future<File> exportProductsToPdf() async {
    final products = await getProducts();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Product List', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['ID', 'Name', 'Description', 'Price', 'Stock'],
                data: products
                    .map((product) => [
                          product.id,
                          product.name,
                          product.description,
                          product.price.toString(),
                          product.stock.toString(),
                        ])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/products_list.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_key);
    if (productsJson == null) return [];
    final List<dynamic> list = jsonDecode(productsJson);
    return list.map((e) => Product.fromJson(e)).toList();
  }

  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await _save(products);
  }

  Future<void> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      await _save(products);
    }
  }

  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == id);
    await _save(products);
  }

  Future<void> _save(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = jsonEncode(products.map((e) => e.toJson()).toList());
    await prefs.setString(_key, productsJson);
  }
}
