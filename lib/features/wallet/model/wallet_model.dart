import 'package:intl/intl.dart';

enum TransactionType {
  credit,
  debit,
  pending,
}

class WalletTransactionModel {
  final String id;
  final String title;
  final String dateString;
  final double amount;
  final TransactionType type;
  final bool isWelcomeIncentive;
  final String paymentMethod;
  final String status;
  final String reference;
  final int? userId;

  const WalletTransactionModel({
    required this.id,
    required this.title,
    required this.dateString,
    required this.amount,
    required this.type,
    this.isWelcomeIncentive = false,
    this.paymentMethod = '',
    this.status = '',
    this.reference = '',
    this.userId,
  });

  String get formattedAmount {
    if (isWelcomeIncentive || type == TransactionType.credit) {
      return '+ ₹${amount.toStringAsFixed(2)}';
    } else if (type == TransactionType.pending) {
      return '₹${amount.toStringAsFixed(2)}';
    } else {
      return '- ₹${amount.toStringAsFixed(2)}';
    }
  }

  factory WalletTransactionModel.fromJson(Map<dynamic, dynamic> json) {
    final id = json['id']?.toString() ??
        json['transaction_id']?.toString() ??
        json['txn_id']?.toString() ??
        '';

    final rawType = (json['transaction_type'] ??
            json['type'] ??
            json['payment_type'] ??
            '')
        .toString()
        .toLowerCase();

    final isCredit = rawType == 'credit' ||
        rawType == 'cr' ||
        rawType == 'add_money' ||
        rawType == 'refund' ||
        rawType == 'deposit' ||
        rawType.contains('credit');

    final rawStatus = (json['status'] ??
            json['payment_status'] ??
            '')
        .toString();

    final isPaid = rawStatus.toLowerCase() == 'paid' ||
        rawStatus.toLowerCase() == 'success' ||
        rawStatus.toLowerCase() == 'completed' ||
        json['is_paid'] == true ||
        json['is_paid']?.toString().toLowerCase() == 'true';

    final isPending = rawType == 'pending' ||
        rawStatus.toLowerCase() == 'pending';

    final TransactionType type = isCredit
        ? TransactionType.credit
        : (isPending ? TransactionType.pending : TransactionType.debit);

    // Title / description
    final desc = (json['description'] ??
            json['title'] ??
            json['remarks'] ??
            json['note'] ??
            json['reason'] ??
            json['waste_type_name'] ??
            '')
        .toString()
        .trim();

    final title = desc.isNotEmpty
        ? desc
        : (isCredit
            ? 'Wallet Top-up'
            : (id.isNotEmpty ? 'Transaction #$id' : 'Wallet Transaction'));

    // Amount
    double amount = double.tryParse(json['amount']?.toString() ??
            json['total_amount']?.toString() ??
            json['transaction_amount']?.toString() ??
            json['total']?.toString() ??
            '') ??
        0.0;
    final weight = double.tryParse(json['weight']?.toString() ?? '') ?? 0.0;
    final rate = double.tryParse(json['rate']?.toString() ?? '') ?? 0.0;
    if (amount == 0.0 && weight > 0 && rate > 0) {
      amount = weight * rate;
    }

    // Date & Time
    final apiDate = json['date']?.toString() ?? '';
    final apiTime = json['time']?.toString() ?? '';
    final createdAt = (json['created_at'] ??
            json['timestamp'] ??
            json['transaction_date'] ??
            json['created_on'] ??
            json['due_date'] ??
            '')
        .toString();

    String dateStr = '';
    if (apiDate.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(apiDate);
        final formattedDate = DateFormat('d MMM yyyy').format(parsedDate);
        dateStr = apiTime.isNotEmpty ? '$formattedDate, $apiTime' : formattedDate;
      } catch (_) {
        dateStr = apiTime.isNotEmpty ? '$apiDate, $apiTime' : apiDate;
      }
    } else if (createdAt.isNotEmpty) {
      try {
        final parsed = DateTime.parse(createdAt);
        dateStr = DateFormat('d MMM yyyy, h:mm a').format(parsed.toLocal());
      } catch (_) {
        dateStr = createdAt;
      }
    }

    // Status
    final status = rawStatus.isNotEmpty
        ? rawStatus
        : (isPaid ? 'Completed' : (isPending ? 'Pending' : 'Completed'));

    // Payment Method & Reference
    final paymentMethod = (json['payment_method'] ??
            json['payment_mode'] ??
            json['method'] ??
            '')
        .toString();

    final reference = (json['reference'] ??
            json['reference_id'] ??
            json['ref'] ??
            '')
        .toString();

    final userId = int.tryParse(json['user_id']?.toString() ?? '');

    final isWelcome = (json['is_welcome_incentive'] == true) ||
        title.toLowerCase().contains('welcome');

    return WalletTransactionModel(
      id: id,
      title: title,
      dateString: dateStr,
      amount: amount,
      type: type,
      isWelcomeIncentive: isWelcome,
      paymentMethod: paymentMethod,
      status: status,
      reference: reference,
      userId: userId,
    );
  }
}

class WalletDataModel {
  final double availableBalance;
  final bool isActive;
  final int count;
  final int? userId;
  final List<WalletTransactionModel> transactions;

  const WalletDataModel({
    this.availableBalance = 0.0,
    this.isActive = true,
    this.count = 0,
    this.userId,
    this.transactions = const [],
  });

  factory WalletDataModel.fromJson(Map<dynamic, dynamic> json) {
    final balance = double.tryParse(json['wallet_balance']?.toString() ??
            json['balance']?.toString() ??
            json['available_balance']?.toString() ??
            '') ??
        0.0;

    final count = int.tryParse(json['count']?.toString() ?? '') ?? 0;
    final userId = int.tryParse(json['user_id']?.toString() ?? '');

    List rawList = [];
    if (json['transactions'] is List) {
      rawList = json['transactions'] as List;
    } else if (json['data'] is List) {
      rawList = json['data'] as List;
    } else if (json['results'] is List) {
      rawList = json['results'] as List;
    }

    final txns = rawList
        .whereType<Map>()
        .map((t) => WalletTransactionModel.fromJson(t))
        .toList();

    return WalletDataModel(
      availableBalance: balance,
      isActive: true,
      count: count > 0 ? count : txns.length,
      userId: userId,
      transactions: txns,
    );
  }

  WalletDataModel copyWith({
    double? availableBalance,
    bool? isActive,
    int? count,
    int? userId,
    List<WalletTransactionModel>? transactions,
  }) {
    return WalletDataModel(
      availableBalance: availableBalance ?? this.availableBalance,
      isActive: isActive ?? this.isActive,
      count: count ?? this.count,
      userId: userId ?? this.userId,
      transactions: transactions ?? this.transactions,
    );
  }
}

class RazorpayOrderModel {
  final String orderId;
  final int amount;
  final String currency;
  final String keyId;

  const RazorpayOrderModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory RazorpayOrderModel.fromJson(Map<dynamic, dynamic> json) {
    return RazorpayOrderModel(
      orderId: json['order_id']?.toString() ?? '',
      amount: int.tryParse(json['amount']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      keyId: json['key_id']?.toString() ?? '',
    );
  }
}

