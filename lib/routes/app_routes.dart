import 'package:flutter/material.dart';
import '../presentation/product_management/product_management.dart';
import '../presentation/add_edit_product/add_edit_product.dart';
import '../presentation/create_quotation/create_quotation.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/invoice_management/invoice_management.dart';
import '../presentation/quotation_list/quotation_list.dart';
import '../presentation/invoice_detail_preview/invoice_detail_preview.dart';
import '../presentation/quotation_detail/quotation_detail_page.dart';
import '../presentation/invoice_detail/invoice_detail_page.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String productManagement = '/product-management';
  static const String addEditProduct = '/add-edit-product';
  static const String createQuotation = '/create-quotation';
  static const String dashboard = '/dashboard';
  static const String invoiceManagement = '/invoice-management';
  static const String quotationList = '/quotation-list';
  static const String invoiceDetailPreview = '/invoice-detail-preview';
  static const String quotationDetail = '/quotation-detail';
  static const String invoiceDetail = '/invoice-detail';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const ProductManagement(),
    productManagement: (context) => const ProductManagement(),
    addEditProduct: (context) => const AddEditProduct(),
    createQuotation: (context) => const CreateQuotation(),
    dashboard: (context) => const Dashboard(),
    invoiceManagement: (context) => const InvoiceManagement(),
    quotationList: (context) => const QuotationList(),
    invoiceDetailPreview: (context) => const InvoiceDetailPreview(),
    quotationDetail: (context) => const QuotationDetailPage(),
    invoiceDetail: (context) => const InvoiceDetailPage(),
    // TODO: Add your other routes here
  };
}
