import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';
import 'dart:convert';

class InvoiceService {
  static const _key = 'invoices';

  Future<List<Invoice>> getInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = prefs.getString(_key);
    if (invoicesJson == null) return [];
    final List<dynamic> list = jsonDecode(invoicesJson);
    return list.map((e) => Invoice.fromJson(e)).toList();
  }

  Future<void> addInvoice(Invoice invoice) async {
    final invoices = await getInvoices();
    invoices.add(invoice);
    await _save(invoices);
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final invoices = await getInvoices();
    final index = invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      invoices[index] = invoice;
      await _save(invoices);
    }
  }

  Future<void> deleteInvoice(String id) async {
    final invoices = await getInvoices();
    invoices.removeWhere((i) => i.id == id);
    await _save(invoices);
  }

  Future<void> _save(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = jsonEncode(invoices.map((e) => e.toJson()).toList());
    await prefs.setString(_key, invoicesJson);
  }
}
