class QRData {
  final String clientName;
  final String productName;
  final String validUntil;
  final String status;

  QRData({
    required this.clientName,
    required this.productName,
    required this.validUntil,
    required this.status,
  });

  factory QRData.fromJson(Map<String, dynamic> json) {
    return QRData(
      clientName: json['clientName'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      validUntil: json['validUntil'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'productName': productName,
      'validUntil': validUntil,
      'status': status,
    };
  }
}




