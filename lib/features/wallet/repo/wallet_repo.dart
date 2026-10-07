import '../model/wallet_model.dart';

abstract class WalletRepository {
  Future<WalletDataModel> getWalletData();
  Future<bool> addMoney(double amount);
}

class WalletRepositoryImpl implements WalletRepository {
  @override
  Future<WalletDataModel> getWalletData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const WalletDataModel(
      availableBalance: 0.00,
      isActive: true,
      transactions: [
        WalletTransactionModel(
          id: '1',
          title: 'Pending Collection Ref #115',
          dateString: 'Yesterday, 12:00 AM',
          amount: 0.00,
          type: TransactionType.pending,
        ),
        WalletTransactionModel(
          id: '2',
          title: 'Welcome Gift Incentive',
          dateString: 'Account Opening',
          amount: 200.00,
          type: TransactionType.credit,
          isWelcomeIncentive: true,
        ),
        WalletTransactionModel(
          id: '3',
          title: 'Pending Collection Ref #94',
          dateString: '21 Sep 2026, 12:00 AM',
          amount: 0.00,
          type: TransactionType.pending,
        ),
      ],
    );
  }

  @override
  Future<bool> addMoney(double amount) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
