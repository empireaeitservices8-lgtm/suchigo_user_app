import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/sp_keys.dart' as sp_keys;
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/wallet_model.dart';

abstract class WalletRepository {
  Future<WalletDataModel> getWalletData({
    String? userId,
    Function(AppError error)? onError,
  });
  Future<bool> addMoney(
    double amount, {
    String currency = 'INR',
    String? receipt,
    Function(AppError error)? onError,
  });
  Future<RazorpayOrderModel?> createRazorpayOrder(
    double amount, {
    String currency = 'INR',
    String? receipt,
    Function(AppError error)? onError,
  });
}

class WalletRepositoryImpl implements WalletRepository {
  final WebAPIService _apiService;

  WalletRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<WalletDataModel> getWalletData({
    String? userId,
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();

    double availableBalance = 0.0;
    List<WalletTransactionModel> transactions = [];
    int count = 0;
    int? userIdInt;

    // 1. Resolve user_id dynamically from param, SharedPreferences, or fallback to live profile API
    String? resolvedUserId = userId;
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      try {
        final sp = await SpHelper.getSP();
        resolvedUserId = sp.get(sp_keys.keyUserId)?.toString() ??
            sp.get('user_id')?.toString() ??
            sp.get('userId')?.toString();
      } catch (_) {
        resolvedUserId = await SpHelper.getString(sp_keys.keyUserId);
      }
    }

    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      try {
        final profileRes = await _apiService.dio.get(urlProfile);
        if (profileRes.data is Map) {
          final data = profileRes.data as Map;
          final rootMap = data['data'] is Map
              ? data['data'] as Map
              : (data['profile'] is Map ? data['profile'] as Map : data);
          final userObj = rootMap['user'];
          final userMap = userObj is Map ? userObj as Map : null;

          final pid = rootMap['user_id']?.toString() ??
              rootMap['userId']?.toString() ??
              userMap?['id']?.toString() ??
              userMap?['user_id']?.toString() ??
              (userObj != null && userObj is! Map ? userObj.toString() : null) ??
              rootMap['id']?.toString();

          if (pid != null && pid.isNotEmpty) {
            resolvedUserId = pid;
            await SpHelper.saveString(sp_keys.keyUserId, pid);
          }
          final balance = double.tryParse(
                (rootMap['wallet_balance'] ?? data['wallet_balance'])
                        ?.toString() ??
                    '',
              ) ??
              0.0;
          if (balance > 0.0) {
            availableBalance = balance;
          }
        }
      } catch (e) {
        debugPrint('[WalletRepo] Profile fetch fallback error: $e');
      }
    }

    debugPrint('[WalletRepo] Calling wallet history with user_id: $resolvedUserId');

    // 2. Fetch wallet history dynamically: GET https://suchigoapis.pythonanywhere.com/api/wallet/history/?user_id=<resolvedUserId>
    try {
      final response = await _apiService.dio.get(
        urlWalletHistory,
        queryParameters: {'user_id': resolvedUserId},
      );

      if (response.data is Map) {
        final data = response.data as Map;
        final walletData = WalletDataModel.fromJson(data);
        availableBalance = walletData.availableBalance;
        transactions = walletData.transactions;
        count = walletData.count;
        userIdInt = walletData.userId ?? int.tryParse(resolvedUserId ?? '');
        if (walletData.userId != null) {
          await SpHelper.saveString(
            sp_keys.keyUserId,
            walletData.userId.toString(),
          );
        }
      } else if (response.data is List) {
        transactions = (response.data as List)
            .whereType<Map>()
            .map((t) => WalletTransactionModel.fromJson(t))
            .toList();
        count = transactions.length;
      }
    } on DioException catch (e) {
      debugPrint('[WalletRepo] Wallet history API error: $e');
      if (onError != null) {
        onError(AppError(
          message: e.response?.data?['message']?.toString() ??
              e.message ??
              'Failed to load wallet history',
        ));
      }
    } catch (e) {
      debugPrint('[WalletRepo] Wallet history unexpected error: $e');
    }

    // 3. Fallback for wallet balance if balance is still 0.0
    if (availableBalance == 0.0) {
      try {
        final profileRes = await _apiService.dio.get(urlProfile);
        if (profileRes.data is Map) {
          final data = profileRes.data as Map;
          final balance = double.tryParse(
                data['wallet_balance']?.toString() ?? '',
              ) ??
              0.0;
          if (balance > 0.0) {
            availableBalance = balance;
          }
        }
      } catch (_) {}
    }

    // 4. Fallback if wallet history returned empty transactions: check collector bill history
    if (transactions.isEmpty) {
      try {
        final billsRes = await _apiService.dio.get(urlBillHistoryFromCollector);
        List rawBills = [];
        if (billsRes.data is List) {
          rawBills = billsRes.data as List;
        } else if (billsRes.data is Map) {
          final map = billsRes.data as Map;
          if (map.containsKey('data') && map['data'] is List) {
            rawBills = map['data'] as List;
          } else if (map.containsKey('results') && map['results'] is List) {
            rawBills = map['results'] as List;
          } else if (map.containsKey('bills') && map['bills'] is List) {
            rawBills = map['bills'] as List;
          }
        }

        if (rawBills.isNotEmpty) {
          transactions = rawBills
              .whereType<Map>()
              .map((b) => WalletTransactionModel.fromJson(b))
              .toList();
          count = transactions.length;
        }
      } catch (_) {}
    }

    return WalletDataModel(
      availableBalance: availableBalance,
      isActive: true,
      count: count > 0 ? count : transactions.length,
      userId: userIdInt ?? int.tryParse(resolvedUserId ?? ''),
      transactions: transactions,
    );
  }

  @override
  Future<bool> addMoney(
    double amount, {
    String currency = 'INR',
    String? receipt,
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();
    final receiptId =
        receipt ?? 'receipt_refill_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'amount': amount,
      'currency': currency,
      'receipt': receiptId,
    };

    try {
      final response = await _apiService.dio.post(
        urlRazorpayAddToWallet,
        data: payload,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return true;
      }
      return true;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString() ??
                e.response?.data['detail']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to add money to wallet',
        ));
      }
      return false;
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to add money: $e'));
      }
      return false;
    }
  }

  @override
  Future<RazorpayOrderModel?> createRazorpayOrder(
    double amount, {
    String currency = 'INR',
    String? receipt,
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();
    final receiptId =
        receipt ?? 'receipt_refill_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'amount': amount,
      'currency': currency,
      'receipt': receiptId,
    };

    try {
      final response = await _apiService.dio.post(
        urlRazorpayAddToWallet,
        data: payload,
      );

      if (response.data is Map) {
        return RazorpayOrderModel.fromJson(response.data as Map);
      }
      return null;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString() ??
                e.response?.data['detail']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to initiate Razorpay order',
        ));
      }
      return null;
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to initiate Razorpay order: $e'));
      }
      return null;
    }
  }
}
