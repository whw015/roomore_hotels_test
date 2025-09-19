class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.reference,
    required this.createdAt,
    required this.total,
    required this.status,
    required this.statusColorHex,
  });

  final String id;
  final String reference;
  final DateTime createdAt;
  final double total;
  final String status;
  final String statusColorHex;

  factory OrderSummary.fromMap(String id, Map<String, dynamic> data) {
    return OrderSummary(
      id: id,
      reference: (data['reference'] as String?)?.trim() ?? id,
      createdAt: _parseDate(data['createdAt']) ?? DateTime.now(),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: (data['status'] as String?)?.trim() ?? 'unknown',
      statusColorHex: (data['statusColor'] as String?)?.trim() ?? '#FFA726',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
