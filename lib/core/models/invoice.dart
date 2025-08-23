class Invoice {
  final String id;
  final String customerName;
  final DateTime invoiceDate;
  final double totalAmount;
  final String status;

  Invoice({
    required this.id,
    required this.customerName,
    required this.invoiceDate,
    required this.totalAmount,
    required this.status,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        customerName: json['customerName'],
        invoiceDate: DateTime.parse(json['invoiceDate']),
        totalAmount: json['totalAmount'],
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'invoiceDate': invoiceDate.toIso8601String(),
        'totalAmount': totalAmount,
        'status': status,
      };
}
