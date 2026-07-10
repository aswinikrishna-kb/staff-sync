class InvoiceModel {
  final String id;
  final String staffId;
  final String staffName;
  final String officeId;
  final String officeEmail;
  final String companyName;
  final String officeAddress;
  final String officePhone;
  final String officeGSTIN;
  final String officePAN;
  final String clientName;
  final String clientEmail;
  final String clientOfficeName;
  final String clientAddress;
  final String clientPhone;
  final String clientGSTIN;
  final String bankName;
  final String bankAccNo;
  final String bankBranch;
  final String bankIFSC;
  final List<InvoiceItem> items;
  final double totalAmount;
  final String status; // Draft, Pending, Approved, Rejected
  final String createdAt;
  final String? adminComment;

  InvoiceModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.officeId,
    required this.officeEmail,
    required this.companyName,
    this.officeAddress = '',
    this.officePhone = '',
    this.officeGSTIN = '',
    this.officePAN = '',
    required this.clientName,
    required this.clientEmail,
    required this.clientOfficeName,
    this.clientAddress = '',
    this.clientPhone = '',
    this.clientGSTIN = '',
    this.bankName = '',
    this.bankAccNo = '',
    this.bankBranch = '',
    this.bankIFSC = '',
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.adminComment,
  });

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'officeId': officeId,
      'officeEmail': officeEmail,
      'companyName': companyName,
      'officeAddress': officeAddress,
      'officePhone': officePhone,
      'officeGSTIN': officeGSTIN,
      'officePAN': officePAN,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientOfficeName': clientOfficeName,
      'clientAddress': clientAddress,
      'clientPhone': clientPhone,
      'clientGSTIN': clientGSTIN,
      'bankName': bankName,
      'bankAccNo': bankAccNo,
      'bankBranch': bankBranch,
      'bankIFSC': bankIFSC,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
      'adminComment': adminComment,
    };
  }

  factory InvoiceModel.fromMap(String id, Map<String, dynamic> map) {
    return InvoiceModel(
      id: id,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      officeId: map['officeId'] ?? '',
      officeEmail: map['officeEmail'] ?? '',
      companyName: map['companyName'] ?? '',
      officeAddress: map['officeAddress'] ?? '',
      officePhone: map['officePhone'] ?? '',
      officeGSTIN: map['officeGSTIN'] ?? '',
      officePAN: map['officePAN'] ?? '',
      clientName: map['clientName'] ?? '',
      clientEmail: map['clientEmail'] ?? '',
      clientOfficeName: map['clientOfficeName'] ?? '',
      clientAddress: map['clientAddress'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      clientGSTIN: map['clientGSTIN'] ?? '',
      bankName: map['bankName'] ?? '',
      bankAccNo: map['bankAccNo'] ?? '',
      bankBranch: map['bankBranch'] ?? '',
      bankIFSC: map['bankIFSC'] ?? '',
      items: (map['items'] as List? ?? [])
          .map((item) => InvoiceItem.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'Draft',
      createdAt: map['createdAt'] ?? '',
      adminComment: map['adminComment'],
    );
  }
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    );
  }
}
