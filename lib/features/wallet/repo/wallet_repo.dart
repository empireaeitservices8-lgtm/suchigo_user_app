import 'package:dio/dio.dart';
import 'package:suchigo_user_app/features/bills/model/bill_model.dart';
import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/wallet_model.dart';

abstract class WalletRepository {
  Future<WalletDataModel> getWalletData({
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
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();

    double availableBalance = 0.0;
    List<WalletTransactionModel> transactions = [];

    // 1. Fetch live Pickups: GET https://suchigoapis.pythonanywhere.com/api/pickups/
    try {
      final pickupsRes = await _apiService.dio.get(urlPickups);
      List rawPickups = [];
      if (pickupsRes.data is List) {
        rawPickups = pickupsRes.data as List;
      } else if (pickupsRes.data is Map) {
        final map = pickupsRes.data as Map;
        if (map.containsKey('data') && map['data'] is List) {
          rawPickups = map['data'] as List;
        } else if (map.containsKey('results') && map['results'] is List) {
          rawPickups = map['results'] as List;
        }
      }

      if (rawPickups.isNotEmpty) {
        transactions = rawPickups.whereType<Map>().map((p) {
          final id = p['id']?.toString() ?? '';
          final wasteName = p['waste_type_name']?.toString();
          final title = (wasteName != null && wasteName.isNotEmpty)
              ? wasteName
              : 'Waste Pickup #$id';
          final dateStr = p['pickup_date']?.toString() ??
              p['created_at']?.toString().split('T').first ??
              '';
          final status = p['status']?.toString().toLowerCase() ?? 'pending';
          final type = status == 'completed'
              ? TransactionType.credit
              : TransactionType.pending;

          return WalletTransactionModel(
            id: id,
            title: title,
            dateString: dateStr,
            amount: 0.0,
            type: type,
            paymentMethod: p['status']?.toString() ?? '',
          );
        }).toList();
      }
    } on DioException catch (e) {
      if (onError != null) {
        onError(AppError(
          message: e.response?.data?['message']?.toString() ??
              e.message ??
              'Failed to load pickups',
        ));
      }
    } catch (_) {}

    // 2. Fetch live Profile: GET https://suchigoapis.pythonanywhere.com/api/profile/
    try {
      final profileRes = await _apiService.dio.get(urlProfile);
      if (profileRes.data is Map) {
        final data = profileRes.data as Map;
        availableBalance = double.tryParse(
              data['wallet_balance']?.toString() ?? '',
            ) ??
            0.0;
      }
    } on DioException catch (e) {
      if (onError != null) {
        onError(AppError(
          message: e.response?.data?['message']?.toString() ??
              e.message ??
              'Failed to load wallet profile',
        ));
      }
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load wallet balance: $e'));
      }
    }

    // 3. Fallback/merge bill history if transactions are empty
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
          }
        }

        if (rawBills.isNotEmpty) {
          transactions = rawBills.whereType<Map>().map((b) {
            final bill = BillModel.fromJson(b);
            final isPaid = bill.isPaid;
            return WalletTransactionModel(
              id: bill.id.toString(),
              title: bill.description.isNotEmpty
                  ? bill.description
                  : 'Waste Collection Invoice ${bill.invoiceNumber}',
              dateString: bill.dateString,
              amount: bill.amount,
              type: isPaid ? TransactionType.credit : TransactionType.pending,
              paymentMethod: bill.paymentMethod,
            );
          }).toList();
        }
      } catch (_) {}
    }

    return WalletDataModel(
      availableBalance: availableBalance,
      isActive: true,
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
