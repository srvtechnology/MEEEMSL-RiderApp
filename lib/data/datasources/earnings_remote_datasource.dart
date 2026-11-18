import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/earnings_entity.dart';
import '../models/earnings_model.dart';
import '../models/rider_ledger_model.dart';
import '../models/rider_revenue_model.dart';
import '../models/transaction_model.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getEarnings(String period);
  Future<bool> requestPayout(double amount, String paymentMethod);
  Future<RiderRevenueDataModel> getRiderRevenue({
    String status = 'all',
    String period = 'all',
    String search = '',
  });
  Future<RiderBalanceLedgerModel> getBalanceTransactions();
  Future<RiderPayoutStatusModel> getPayoutRequests();
  Future<RiderPayoutRequestModel> submitPayoutRequest({String? sellerNote});
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final DioClient _dioClient;

  EarningsRemoteDataSourceImpl(this._dioClient);

  Never _rethrowDioError(DioException e, String fallbackMessage) {
    if (e.error is RateLimitException) {
      throw e.error as RateLimitException;
    }
    final respData = e.response?.data is Map ? e.response!.data as Map : const {};
    final message = respData['error']?.toString() ??
        respData['message']?.toString() ??
        e.message ??
        fallbackMessage;
    throw ServerException(
      message: message.isNotEmpty ? message : fallbackMessage,
      statusCode: e.response?.statusCode,
    );
  }

  Map<String, dynamic>? _extractMapPayload(dynamic rawData) {
    if (rawData is! Map) return null;
    final map = Map<String, dynamic>.from(rawData);
    if (map['data'] is Map) {
      return Map<String, dynamic>.from(map['data'] as Map);
    }
    return map;
  }

  @override
  Future<EarningsModel> getEarnings(String period) async {
    double todayEarnings = 0.0;
    double weeklyEarnings = 0.0;
    double monthlyEarnings = 0.0;
    double totalAvailable = 0.0;
    int completedTrips = 0;
    final Map<String, double> weekdayEarnings = {
      'Mon': 0.0,
      'Tue': 0.0,
      'Wed': 0.0,
      'Thu': 0.0,
      'Fri': 0.0,
      'Sat': 0.0,
      'Sun': 0.0,
    };
    final List<TransactionModel> transactions = [];

    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': 'completed'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          completedTrips = data.length;
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final weekStart = now.subtract(const Duration(days: 7));
          final monthStart = now.subtract(const Duration(days: 30));

          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final earnings = (item['riderEarnings'] as num?)?.toDouble() ??
                  (item['order']?['deliveryFee'] as num?)?.toDouble() ??
                  0.0;
              final dateStr = item['deliveredAt'] ?? item['createdAt'] ?? item['updatedAt'];
              final date = dateStr != null ? (DateTime.tryParse(dateStr.toString()) ?? now) : now;
              final orderNum = item['order']?['orderNumber']?.toString() ??
                  item['orderNumber']?.toString() ??
                  '#${item['id']}';

              totalAvailable += earnings;

              if (date.isAfter(todayStart)) {
                todayEarnings += earnings;
              }
              if (date.isAfter(weekStart)) {
                weeklyEarnings += earnings;
                final dayKey = _weekdayString(date.weekday);
                weekdayEarnings[dayKey] = (weekdayEarnings[dayKey] ?? 0.0) + earnings;
              }
              if (date.isAfter(monthStart)) {
                monthlyEarnings += earnings;
              }

              transactions.add(
                TransactionModel(
                  id: item['id']?.toString() ?? 'tx_${transactions.length}',
                  orderNumber: orderNum.startsWith('#') ? orderNum : '#$orderNum',
                  amount: earnings,
                  tip: 0.0,
                  date: date,
                  type: 'trip_earnings',
                  status: 'completed',
                ),
              );
            }
          }
        }
      }
    } catch (_) {}

    final dailyData = weekdayEarnings.entries
        .map((e) => DailyChartData(day: e.key, amount: e.value))
        .toList();

    return EarningsModel(
      todayEarnings: todayEarnings,
      weeklyEarnings: weeklyEarnings,
      monthlyEarnings: monthlyEarnings,
      availablePayout: totalAvailable,
      completedTrips: completedTrips,
      basePay: totalAvailable,
      tips: 0.0,
      surgeBonuses: 0.0,
      dailyData: dailyData,
      recentTransactions: transactions,
    );
  }

  static String _weekdayString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
      default:
        return 'Sun';
    }
  }

  @override
  Future<bool> requestPayout(double amount, String paymentMethod) async {
    await submitPayoutRequest(
      sellerNote: paymentMethod.trim().isNotEmpty ? 'Payout via $paymentMethod' : null,
    );
    return true;
  }

  @override
  Future<RiderRevenueDataModel> getRiderRevenue({
    String status = 'all',
    String period = 'all',
    String search = '',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': status,
        'period': period,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      };

      final response = await _dioClient.dio.get(
        ApiEndpoints.revenue,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final payload = _extractMapPayload(response.data);
        if (payload != null) {
          return RiderRevenueDataModel.fromJson(payload);
        }
      }
      throw const ServerException(message: 'Invalid response from revenue API');
    } on DioException catch (e) {
      _rethrowDioError(e, 'Failed to load revenue');
    } catch (e) {
      if (e is ServerException || e is RateLimitException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<RiderBalanceLedgerModel> getBalanceTransactions() async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.balanceTransactions,
      );

      if (response.statusCode == 200 && response.data != null) {
        final payload = _extractMapPayload(response.data);
        if (payload != null) {
          return RiderBalanceLedgerModel.fromJson(payload);
        }
      }
      throw const ServerException(
        message: 'Invalid response from balance transactions API',
      );
    } on DioException catch (e) {
      _rethrowDioError(e, 'Failed to load balance ledger');
    } catch (e) {
      if (e is ServerException || e is RateLimitException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<RiderPayoutStatusModel> getPayoutRequests() async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.payoutRequests,
      );

      if (response.statusCode == 200 && response.data != null) {
        final payload = _extractMapPayload(response.data);
        if (payload != null) {
          return RiderPayoutStatusModel.fromJson(payload);
        }
      }
      throw const ServerException(
        message: 'Invalid response from payout requests API',
      );
    } on DioException catch (e) {
      _rethrowDioError(e, 'Failed to load payout requests');
    } catch (e) {
      if (e is ServerException || e is RateLimitException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<RiderPayoutRequestModel> submitPayoutRequest({String? sellerNote}) async {
    try {
      final trimmedNote = sellerNote?.trim();
      final body = <String, dynamic>{
        if (trimmedNote != null && trimmedNote.isNotEmpty) 'sellerNote': trimmedNote,
      };

      final response = await _dioClient.dio.post(
        ApiEndpoints.payoutRequests,
        data: body,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final raw = response.data;
        if (raw is Map) {
          final map = Map<String, dynamic>.from(raw);
          if (map['success'] == false) {
            throw ServerException(
              message: map['error']?.toString() ??
                  map['message']?.toString() ??
                  'Failed to submit payout request',
              statusCode: response.statusCode,
            );
          }
          Map<String, dynamic>? reqMap;
          if (map['payoutRequest'] is Map) {
            reqMap = Map<String, dynamic>.from(map['payoutRequest'] as Map);
          } else if (map['data'] is Map) {
            final dataMap = Map<String, dynamic>.from(map['data'] as Map);
            if (dataMap['payoutRequest'] is Map) {
              reqMap = Map<String, dynamic>.from(dataMap['payoutRequest'] as Map);
            } else {
              reqMap = dataMap;
            }
          }
          if (reqMap != null) {
            return RiderPayoutRequestModel.fromJson(reqMap);
          }
        }
      }
      throw const ServerException(
        message: 'Invalid response from submit payout request API',
      );
    } on DioException catch (e) {
      _rethrowDioError(e, 'Failed to submit payout request');
    } catch (e) {
      if (e is ServerException || e is RateLimitException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
