import 'package:shared_preferences/shared_preferences.dart';
import '../models/quotation.dart';
import 'dart:convert';

class QuotationService {
  static const _key = 'quotations';

  Future<List<Quotation>> getQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final quotationsJson = prefs.getString(_key);
    if (quotationsJson == null) return [];
    final List<dynamic> list = jsonDecode(quotationsJson);
    return list.map((e) => Quotation.fromJson(e)).toList();
  }

  Future<void> addQuotation(Quotation quotation) async {
    final quotations = await getQuotations();
    quotations.add(quotation);
    await _save(quotations);
  }

  Future<void> updateQuotation(Quotation quotation) async {
    final quotations = await getQuotations();
    final index = quotations.indexWhere((q) => q.id == quotation.id);
    if (index != -1) {
      quotations[index] = quotation;
      await _save(quotations);
    }
  }

  Future<void> deleteQuotation(String id) async {
    final quotations = await getQuotations();
    quotations.removeWhere((q) => q.id == id);
    await _save(quotations);
  }

  Future<void> _save(List<Quotation> quotations) async {
    final prefs = await SharedPreferences.getInstance();
    final quotationsJson =
        jsonEncode(quotations.map((e) => e.toJson()).toList());
    await prefs.setString(_key, quotationsJson);
  }
}
