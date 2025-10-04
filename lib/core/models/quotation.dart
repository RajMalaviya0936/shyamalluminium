class Quotation {
  final String id;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final bool gstEnabled;
  final double? gstRate;
  final double? discountPercent;
  final double? discountAmount;
  final DateTime quotationDate;
  final double totalAmount;
  final String status;
  final String? remarks;
  final List<QuotationItem> items;

  Quotation({
    required this.id,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.gstEnabled = false,
    this.gstRate,
    this.discountPercent,
    this.discountAmount,
    required this.quotationDate,
    required this.totalAmount,
    required this.status,
    this.remarks,
    required this.items,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
        id: json['id'],
        customerName: json['customerName'],
        customerPhone: json['customerPhone'] ?? '',
        customerAddress: json['customerAddress'] ?? '',
        gstEnabled: json['gstEnabled'] == true,
        gstRate: json['gstRate'] is num
            ? (json['gstRate'] as num).toDouble()
            : (double.tryParse(json['gstRate']?.toString() ?? '') ?? null),
        discountPercent: json['discountPercent'] is num
            ? (json['discountPercent'] as num).toDouble()
            : (double.tryParse(json['discountPercent']?.toString() ?? '') ??
                null),
        discountAmount: json['discountAmount'] is num
            ? (json['discountAmount'] as num).toDouble()
            : (double.tryParse(json['discountAmount']?.toString() ?? '') ??
                null),
        quotationDate: DateTime.parse(json['quotationDate']),
        totalAmount: json['totalAmount'],
        status: json['status'],
        remarks: json['remarks'] ?? '',
        items: (json['items'] as List<dynamic>)
            .map((e) => QuotationItem.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerPhone': customerPhone ?? '',
        'customerAddress': customerAddress ?? '',
        'gstEnabled': gstEnabled,
        'gstRate': gstRate ?? 0,
        'discountPercent': discountPercent ?? 0,
        'discountAmount': discountAmount ?? 0,
        'quotationDate': quotationDate.toIso8601String(),
        'totalAmount': totalAmount,
        'status': status,
        'remarks': remarks ?? '',
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class QuotationItem {
  final String itemName;
  final String? topCategory; // Window, Door, Partitions, Railing, etc.
  final String category;
  final String? subtype;
  final String size;
  final double rate;
  final int quantity;
  final String? glassColor;
  final bool hasMosquitoNet;
  final int? position;
  final String? location;
  final String? system;
  final String? profileColor;
  final String? meshType;
  final String? locking;
  final String? handleColor;
  final String? remarks;
  final bool? hasGrill;
  final String? grillOrientation; // 'horizontal' or 'vertical'
  final int? grillPipeCount;
  final int? pvcWindowCount;
  final double? width;
  final double? height;
  final String? unit;
  final String? measurementType; // 'sqft' or 'runningft'
  final double? unitPrice;
  final double? area;

  QuotationItem({
    required this.itemName,
    this.topCategory,
    required this.category,
    this.subtype,
    required this.size,
    required this.rate,
    required this.quantity,
    this.glassColor,
    this.hasMosquitoNet = false,
    this.position,
    this.location,
    this.system,
    this.profileColor,
    this.meshType,
    this.locking,
    this.handleColor,
    this.remarks,
    this.width,
    this.height,
    this.unit,
    this.measurementType,
    this.unitPrice,
    this.hasGrill,
    this.grillOrientation,
    this.grillPipeCount,
    this.pvcWindowCount,
    this.area,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) => QuotationItem(
        itemName: json['itemName'],
        topCategory: json['topCategory'],
        category: json['category'],
        subtype: json['subtype'],
        size: json['size'],
        rate: json['rate'],
        quantity: json['quantity'],
        glassColor: json['glassColor'] ?? json['glazing'] ?? '',
        hasMosquitoNet:
            json['hasMosquitoNet'] == true || json['mosquitoNet'] == true,
        position: json['position'] is int
            ? json['position']
            : (json['position'] != null
                ? int.tryParse(json['position'].toString())
                : null),
        location: json['location'] ?? '',
        system: json['system'] ?? json['profileSystem'] ?? '',
        profileColor: json['profileColor'] ?? '',
        meshType: json['meshType'] ?? '',
        locking: json['locking'] ?? '',
        handleColor: json['handleColor'] ?? '',
        remarks: json['remarks'] ?? '',
        hasGrill: json['hasGrill'] == true,
        grillOrientation: json['grillOrientation'] ?? 'horizontal',
        grillPipeCount: json['grillPipeCount'] is int
            ? json['grillPipeCount'] as int
            : (json['grillPipeCount'] != null
                ? int.tryParse(json['grillPipeCount'].toString())
                : null),
        pvcWindowCount: json['pvcWindowCount'] is int
            ? json['pvcWindowCount'] as int
            : (json['pvcWindowCount'] != null
                ? int.tryParse(json['pvcWindowCount'].toString())
                : null),
        width: json['width'] is num
            ? (json['width'] as num).toDouble()
            : (double.tryParse(json['width']?.toString() ?? '') ?? null),
        height: json['height'] is num
            ? (json['height'] as num).toDouble()
            : (double.tryParse(json['height']?.toString() ?? '') ?? null),
        unit: json['unit'] ?? '',
        measurementType: json['measurementType'] ?? 'sqft',
        unitPrice: json['unitPrice'] is num
            ? (json['unitPrice'] as num).toDouble()
            : (double.tryParse(json['unitPrice']?.toString() ?? '') ?? null),
        area: json['area'] is num
            ? (json['area'] as num).toDouble()
            : (double.tryParse(json['area']?.toString() ?? '') ?? null),
      );

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'topCategory': topCategory,
        'category': category,
        'subtype': subtype,
        'size': size,
        'rate': rate,
        'quantity': quantity,
        'glassColor': glassColor ?? '',
        'hasMosquitoNet': hasMosquitoNet,
        'position': position ?? 0,
        'location': location ?? '',
        'system': system ?? '',
        'profileColor': profileColor ?? '',
        'meshType': meshType ?? '',
        'locking': locking ?? '',
        'handleColor': handleColor ?? '',
        'remarks': remarks ?? '',
        'width': width ?? 0,
        'height': height ?? 0,
        'unit': unit ?? 'feet',
        'measurementType': measurementType ?? 'sqft',
        'unitPrice': unitPrice ?? 0,
        'hasGrill': hasGrill ?? false,
        'grillOrientation': grillOrientation ?? 'horizontal',
        'grillPipeCount': grillPipeCount ?? 0,
        'pvcWindowCount': pvcWindowCount ?? 1,
        'area': area ?? 0,
      };
}
