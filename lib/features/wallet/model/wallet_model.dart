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

  const WalletTransactionModel({
    required this.id,
    required this.title,
    required this.dateString,
    required this.amount,
    required this.type,
    this.isWelcomeIncentive = false,
  });

  String get formattedAmount {
    if (isWelcomeIncentive || type == TransactionType.credit) {
      return '+ ₹${amount.toStringAsFixed(2)}';
    } else {
      return '- ₹${amount.toStringAsFixed(2)}';
    }
  }
}

class WalletDataModel {
  final double availableBalance;
  final bool isActive;
  final List<WalletTransactionModel> transactions;

  const WalletDataModel({
    this.availableBalance = 0.0,
    this.isActive = true,
    this.transactions = const [],
  });
}
