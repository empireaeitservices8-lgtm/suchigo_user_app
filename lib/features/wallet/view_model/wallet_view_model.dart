import 'package:flutter/material.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/wallet_model.dart';
import '../repo/wallet_repo.dart';

class WalletViewModel extends ViewModel {
  final WalletRepository _repository;

  WalletDataModel _walletData = const WalletDataModel();
  final TextEditingController amountController = TextEditingController();

  WalletViewModel({WalletRepository? repository})
      : _repository = repository ?? WalletRepositoryImpl() {
    loadWalletData();
  }

  WalletDataModel get walletData => _walletData;
  double get availableBalance => _walletData.availableBalance;
  List<WalletTransactionModel> get transactions => _walletData.transactions;

  void loadWalletData() async {
    isLoading = true;
    try {
      _walletData = await _repository.getWalletData();
    } catch (e) {
      _walletData = const WalletDataModel();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setQuickAmount(double amount) {
    amountController.text = amount.toStringAsFixed(0);
    notifyListeners();
  }

  Future<bool> proceedToAddMoney() async {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return false;

    isLoading = true;
    try {
      final success = await _repository.addMoney(amount);
      if (success) {
        amountController.clear();
        loadWalletData();
      }
      return success;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
