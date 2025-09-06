import 'dart:convert';

class Transaction {
  final String orderId;
  final String userId;
  final double grossAmount;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime transactionTime;
  final List<TransactionItem> items;

  Transaction({
    required this.orderId,
    required this.userId,
    required this.grossAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionTime,
    required this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    List<TransactionItem> items = [];
    if (json['item_details'] != null) {
      final rawItems = json['item_details'];
      if (rawItems is String) {
        try {
          final parsed = jsonDecode(rawItems);
          if (parsed is List) {
            items = parsed.map((i) => TransactionItem.fromJson(i)).toList();
          }
        } catch (e) {
          print("❌ Gagal parsing item_details: $e");
        }
      } else if (rawItems is List) {
        items = rawItems.map((i) => TransactionItem.fromJson(i)).toList();
      }
    }

    // transaction_time
    DateTime transactionTime = DateTime.now();
    if (json['transaction_time'] != null) {
      try {
        transactionTime = DateTime.parse(json['transaction_time'].toString());
      } catch (_) {}
    }

    // gross_amount
    double grossAmount = 0.0;
    if (json['gross_amount'] != null) {
      final ga = json['gross_amount'];
      if (ga is int) {
        grossAmount = ga.toDouble();
      } else if (ga is double) {
        grossAmount = ga;
      } else if (ga is String) {
        grossAmount = double.tryParse(ga) ?? 0.0;
      }
    }

    return Transaction(
      orderId: json['order_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      grossAmount: grossAmount,
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString() ?? '',
      transactionTime: transactionTime,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'gross_amount': grossAmount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'transaction_time': transactionTime.toIso8601String(),
      'item_details': items.map((i) => i.toJson()).toList(),
    };
  }
}

class TransactionItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  TransactionItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    double price = 0.0;
    if (json['price'] != null) {
      final p = json['price'];
      if (p is int) {
        price = p.toDouble();
      } else if (p is double) {
        price = p;
      } else if (p is String) {
        price = double.tryParse(p) ?? 0.0;
      }
    }

    return TransactionItem(
      productId: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: price,
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}
