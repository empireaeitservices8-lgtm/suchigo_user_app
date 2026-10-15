import 'package:flutter/material.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/wallet_model.dart';
import '../repo/wallet_repo.dart';

class WalletViewModel extends ViewModel {
  final WalletRepository _repository;

  WalletDataModel _walletData = const WalletDataModel();
  final TextEditingController amountController = TextEditingController();
  String? _errorMessage;

  WalletViewModel({WalletRepository? repository})
      : _repository = repository ?? WalletRepositoryImpl() {
    loadWalletData();
  }

  WalletDataModel get walletData => _walletData;
  double get availableBalance => _walletData.availableBalance;
  List<WalletTransactionModel> get transactions => _walletData.transactions;
  String? get errorMessage => _errorMessage;

  void loadWalletData() async {
    isLoading = true;
    _errorMessage = null;
    try {
      _walletData = await _repository.getWalletData(
        onError: (error) {
          _errorMessage = error.message;
        },
      );
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

  Future<RazorpayOrderModel?> initiateRazorpayOrder({
    Function(String message)? onError,
  }) async {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      const msg = 'Please enter a valid amount';
      _errorMessage = msg;
      onError?.call(msg);
      return null;
    }

    isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final receiptId =
          'receipt_refill_${DateTime.now().millisecondsSinceEpoch}';
      final order = await _repository.createRazorpayOrder(
        amount,
        currency: 'INR',
        receipt: receiptId,
        onError: (error) {
          _errorMessage = error.message;
          onError?.call(error.message);
        },
      );
      return order;
    } catch (e) {
      const msg = 'Failed to initiate payment';
      _errorMessage = msg;
      onError?.call(msg);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> proceedToAddMoney({Function(String message)? onError}) async {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      const msg = 'Please enter a valid amount';
      _errorMessage = msg;
      onError?.call(msg);
      return false;
    }

    isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final receiptId =
          'receipt_refill_${DateTime.now().millisecondsSinceEpoch}';
      final success = await _repository.addMoney(
        amount,
        currency: 'INR',
        receipt: receiptId,
        onError: (error) {
          _errorMessage = error.message;
          onError?.call(error.message);
        },
      );
      if (success) {
        amountController.clear();
        loadWalletData();
      }
      return success;
    } catch (e) {
      const msg = 'Failed to proceed with payment';
      _errorMessage = msg;
      onError?.call(msg);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
