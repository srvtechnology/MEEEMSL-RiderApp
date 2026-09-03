import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/core/network/logger/api_logger.dart';

void main() {
  group('AsyncApiLogger Core Tests', () {
    late AsyncApiLogger logger;

    setUp(() {
      logger = AsyncApiLogger(
        config: const ApiLoggerConfig(
          enabled: true,
          printToConsole: false,
          enableHistory: true,
          historyCapacity: 3,
        ),
      );
    });

    tearDown(() async {
      await logger.dispose();
    });

    test('logRequest returns a valid logId immediately in O(1) time', () {
      final stopwatch = Stopwatch()..start();
      final logId = logger.logRequest(
        method: 'POST',
        url: 'https://api.meeemsl.com/mobileapi/rider/auth/login',
        headers: {'Authorization': 'Bearer super_secret_jwt_token'},
        body: {'phone': '+23276123456', 'password': 'mySecretPassword123'},
      );
      stopwatch.stop();

      expect(logId, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('Processes request and response asynchronously with credential sanitization', () async {
      final receivedRecords = <ApiLogRecord>[];
      final subscription = logger.onLogRecord.listen(receivedRecords.add);

      final logId = logger.logRequest(
        method: 'POST',
        url: 'https://api.meeemsl.com/mobileapi/rider/auth/login',
        headers: {
          'Authorization': 'Bearer raw_jwt_token_123',
          'Custom-Key': 'my-api-key-val',
        },
        body: {
          'phoneNumber': '+23276123456',
          'password': 'plain_password',
          'otp': '987654',
        },
      );

      logger.logResponse(
        logId: logId,
        statusCode: 200,
        statusMessage: 'OK',
        headers: {'content-type': 'application/json'},
        body: {
          'success': true,
          'token': 'secret_return_token',
          'data': {'riderId': 'R-1001'},
        },
        durationMs: 85,
      );

      // Allow background microtask queue to process
      await Future.delayed(const Duration(milliseconds: 100));

      expect(receivedRecords.length, greaterThanOrEqualTo(2));
      final completedRecord = receivedRecords.last;

      expect(completedRecord.id, equals(logId));
      expect(completedRecord.statusCode, equals(200));
      expect(completedRecord.durationMs, equals(85));
      expect(completedRecord.isSuccess, isTrue);
      expect(completedRecord.isError, isFalse);

      // Verify header sanitization
      expect(
        completedRecord.requestHeaders?['Authorization'],
        equals('Bearer [REDACTED]'),
      );

      // Verify request payload sanitization
      final sanitizedReq = completedRecord.requestBody as Map<String, dynamic>;
      expect(sanitizedReq['password'], equals('[REDACTED]'));
      expect(sanitizedReq['otp'], equals('[REDACTED]'));
      expect(sanitizedReq['phoneNumber'], equals('+23276123456'));

      // Verify response payload is preserved completely without hiding any data
      final responseBody = completedRecord.responseBody as Map<String, dynamic>;
      expect(responseBody['token'], equals('secret_return_token'));
      expect(responseBody['data']['riderId'], equals('R-1001'));

      await subscription.cancel();
    });

    test('Processes error event asynchronously and marks isError = true', () async {
      final receivedRecords = <ApiLogRecord>[];
      final subscription = logger.onLogRecord.listen(receivedRecords.add);

      final logId = logger.logRequest(
        method: 'GET',
        url: 'https://api.meeemsl.com/mobileapi/rider/orders/active',
      );

      logger.logError(
        logId: logId,
        error: 'SocketException: Connection refused',
        statusCode: 503,
        statusMessage: 'Service Unavailable',
        durationMs: 150,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(receivedRecords.length, greaterThanOrEqualTo(2));
      final errorRecord = receivedRecords.last;

      expect(errorRecord.isError, isTrue);
      expect(errorRecord.statusCode, equals(503));
      expect(errorRecord.error.toString(), contains('Connection refused'));

      await subscription.cancel();
    });

    test('Enforces ring buffer capacity and drops oldest records', () async {
      for (int i = 1; i <= 5; i++) {
        final id = logger.logRequest(
          method: 'GET',
          url: 'https://api.meeemsl.com/test/$i',
        );
        logger.logResponse(
          logId: id,
          statusCode: 200,
          durationMs: 10 * i,
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));

      final history = logger.getHistory();
      expect(history.length, equals(3)); // Max capacity is 3

      // Oldest (1 and 2) dropped, 3, 4, 5 retained
      expect(history[0].url, contains('/test/3'));
      expect(history[1].url, contains('/test/4'));
      expect(history[2].url, contains('/test/5'));
    });

    test('Exports diagnostic logs as formatted text and JSON', () async {
      final id = logger.logRequest(
        method: 'POST',
        url: 'https://api.meeemsl.com/export-test',
        body: {'key': 'value'},
      );
      logger.logResponse(
        logId: id,
        statusCode: 200,
        body: {'status': 'ok'},
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final textReport = logger.exportLogsAsText();
      expect(textReport, contains('MEEEM RIDER - API DIAGNOSTIC LOGS'));
      expect(textReport, contains('[POST] https://api.meeemsl.com/export-test'));
      expect(textReport, contains('Status: 200'));

      final jsonReport = logger.exportLogsAsJson();
      final decodedJson = jsonDecode(jsonReport) as List;
      expect(decodedJson.length, equals(1));
      expect(decodedJson[0]['method'], equals('POST'));
      expect(decodedJson[0]['statusCode'], equals(200));
    });

    test('clearHistory empties the ring buffer', () async {
      final id = logger.logRequest(
        method: 'GET',
        url: 'https://api.meeemsl.com/clear-test',
      );
      logger.logResponse(logId: id, statusCode: 200);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(logger.getHistory().length, equals(1));

      logger.clearHistory();
      expect(logger.getHistory(), isEmpty);
    });
  });

  group('CurlFormatter Tests', () {
    test('Builds valid cURL with GET request and headers', () {
      final curl = CurlFormatter.buildCurl(
        method: 'GET',
        url: 'https://api.meeemsl.com/test',
        headers: {'Accept': 'application/json'},
      );

      expect(curl, contains('curl -X GET "https://api.meeemsl.com/test"'));
      expect(curl, contains('-H "Accept: application/json"'));
    });

    test('Builds valid cURL with POST request and JSON body', () {
      final curl = CurlFormatter.buildCurl(
        method: 'POST',
        url: 'https://api.meeemsl.com/auth/login',
        headers: {'Content-Type': 'application/json'},
        body: {'phone': '+23212345678'},
      );

      expect(curl, contains('curl -X POST "https://api.meeemsl.com/auth/login"'));
      expect(curl, contains('-d \'{"phone":"+23212345678"}\''));
    });
  });

  group('AsyncDioLoggerInterceptor Tests', () {
    late AsyncApiLogger logger;
    late Dio dio;

    setUp(() {
      logger = AsyncApiLogger(
        config: const ApiLoggerConfig(
          enabled: true,
          printToConsole: false,
          enableHistory: true,
        ),
      );
      dio = Dio();
      dio.interceptors.add(AsyncDioLoggerInterceptor(logger));
    });

    tearDown(() async {
      await logger.dispose();
      dio.close();
    });

    test('Intercepts simulated Dio requests and records in AsyncApiLogger', () async {
      // Add custom interceptor to simulate server response
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                statusMessage: 'OK',
                data: {'status': 'healthy', 'version': '1.0.0'},
              ),
              true,
            );
          },
        ),
      );

      final response = await dio.get(
        'https://api.meeemsl.com/health',
        options: Options(headers: {'Authorization': 'Bearer fake_token'}),
      );

      expect(response.statusCode, equals(200));

      await Future.delayed(const Duration(milliseconds: 100));

      final history = logger.getHistory();
      expect(history.length, equals(1));
      expect(history.first.url, equals('https://api.meeemsl.com/health'));
      expect(history.first.statusCode, equals(200));
      expect(
        history.first.requestHeaders?['Authorization'],
        equals('Bearer [REDACTED]'),
      );
    });

    test('Intercepts simulated Dio error and records error in AsyncApiLogger', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 404,
                  statusMessage: 'Not Found',
                  data: {'message': 'Rider not found'},
                ),
                type: DioExceptionType.badResponse,
              ),
              true,
            );
          },
        ),
      );

      try {
        await dio.get('https://api.meeemsl.com/rider/999');
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 100));

      final history = logger.getHistory();
      expect(history.length, equals(1));
      expect(history.first.statusCode, equals(404));
      expect(history.first.isError, isTrue);
    });
  });

  group('ConsoleLogFormatter Tests', () {
    final record = ApiLogRecord(
      id: 'test-id-123',
      url: 'https://api.meeemsl.com/test',
      method: 'POST',
      requestHeaders: {'Content-Type': 'application/json'},
      requestBody: {'key': 'value'},
      requestTime: DateTime.now(),
      statusCode: 200,
      statusMessage: 'OK',
      responseHeaders: {'content-type': 'application/json'},
      responseBody: {'status': 'success'},
      responseTime: DateTime.now().add(const Duration(milliseconds: 120)),
      durationMs: 120,
      curlCommand: 'curl -X POST "https://api.meeemsl.com/test"',
    );

    test('Renders compact view without errors', () {
      const compactConfig = ApiLoggerConfig(
        enabled: true,
        compactView: true,
        printToConsole: true,
      );

      expect(() => ConsoleLogFormatter.printRequest(record, compactConfig), returnsNormally);
      expect(() => ConsoleLogFormatter.printResponse(record, compactConfig), returnsNormally);
      expect(() => ConsoleLogFormatter.printError(record, compactConfig), returnsNormally);
    });

    test('Does not truncate large response bodies when truncateResponseBody is false', () {
      final largeRegions = List.generate(50, (index) => 'REGION_$index');
      final largeRecord = record.copyWith(
        responseBody: {
          'zones': [
            {'regions': largeRegions}
          ]
        },
      );

      const config = ApiLoggerConfig(
        enabled: true,
        compactView: true,
        truncateResponseBody: false,
        printToConsole: true,
      );

      expect(
        () => ConsoleLogFormatter.printResponse(largeRecord, config),
        returnsNormally,
      );
    });
  });
}

