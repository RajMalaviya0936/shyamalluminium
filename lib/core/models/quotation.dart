class Quotation {
  final String id;
  final String customerName;
  final DateTime quotationDate;
  final double totalAmount;
  final String status;
  final List<QuotationItem> items;

  Quotation({
    required this.id,
    required this.customerName,
    required this.quotationDate,
    required this.totalAmount,
    required this.status,
    required this.items,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
        id: json['id'],
        customerName: json['customerName'],
        quotationDate: DateTime.parse(json['quotationDate']),
        totalAmount: json['totalAmount'],
        status: json['status'],
        items: (json['items'] as List<dynamic>)
            .map((e) => QuotationItem.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'quotationDate': quotationDate.toIso8601String(),
        'totalAmount': totalAmount,
        'status': status,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class QuotationItem {
  final String itemName;
  final String category;
  final String size;
  final double rate;
  final int quantity;
  final String? glassColor;
  final bool hasMosquitoNet;

  QuotationItem({
    required this.itemName,
    required this.category,
    required this.size,
    required this.rate,
    required this.quantity,
    this.glassColor,
    this.hasMosquitoNet = false,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) => QuotationItem(
        itemName: json['itemName'],
        category: json['category'],
        size: json['size'],
        rate: json['rate'],
        quantity: json['quantity'],
        glassColor: json['glassColor'] ?? json['glazing'] ?? '',
        hasMosquitoNet:
            json['hasMosquitoNet'] == true || json['mosquitoNet'] == true,
      );

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'category': category,
        'size': size,
        'rate': rate,
        'quantity': quantity,
        'glassColor': glassColor ?? '',
        'hasMosquitoNet': hasMosquitoNet,
      };
}
