import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/data/datasources/auth_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late Dio dio;
  late MockDioClient dioClient;
  late AuthRemoteDataSourceImpl remoteDataSource;
  late List<RequestOptions> capturedRequests;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://www.meeemsl.com/mobileapi/rider'));
    capturedRequests = [];
    dioClient = MockDioClient();
    when(() => dioClient.dio).thenReturn(dio);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedRequests.add(options);
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Rider onboarding completed successfully!',
                'data': {
                  'onboardingCompleted': true,
                  'rider': {
                    'id': 'cm7rider0001',
                    'name': 'Samuel Taylor',
                    'phone': '76145892',
                    'phoneCountryCode': '+232',
                    'email': 'hadane3655@fanzher.com',
                    'isApproved': true,
                    'status': 'APPROVED',
                    'onboardingCompleted': true,
                    'isFirstLogin': false,
                    'vehicleType': '2_WHEELER',
                    'vehicleTypes': ['2_WHEELER'],
                    'vehicleName': 'Honda CB Shine 125',
                    'vehicleNumber': 'SL-AA-9988',
                    'drivingLicenseNo': 'DL-10928374',
                    'profileImage': 'https://s3.amazonaws.com/meeem/profiles/rider.jpg',
                    'drivingLicenseDoc': 'https://s3.amazonaws.com/meeem/docs/dl.png',
                    'nationalIdDoc': 'https://s3.amazonaws.com/meeem/docs/id.png',
                    'vehicleInsuranceDoc': 'https://s3.amazonaws.com/meeem/docs/ins.png',
                    'selectedZones': ['ZONE 1', 'ZONE 2'],
                    'selectedLocations': ['NO 2 RIVER', 'BAW BAW'],
                  }
                }
              },
            ),
          );
        },
      ),
    );

    remoteDataSource = AuthRemoteDataSourceImpl(dioClient);
  });

  test('submitOnboarding formats multipart/form-data according to API Doc Part 1 and parses response', () async {
    final result = await remoteDataSource.submitOnboarding(
      name: 'Samuel Taylor',
      phone: '76145892',
      phoneCountryCode: '+232',
      vehicleType: '2_WHEELER',
      vehicleTypes: ['2_WHEELER'],
      vehicleName: 'Honda CB Shine 125',
      vehicleNumber: 'SL-AA-9988',
      drivingLicenseNo: 'DL-10928374',
      selectedZones: ['ZONE 1', 'ZONE 2'],
      selectedLocations: ['NO 2 RIVER', 'BAW BAW'],
    );

    expect(capturedRequests.length, 1);
    final req = capturedRequests.first;
    expect(req.path, ApiEndpoints.onboarding);
    expect(req.data, isA<FormData>());

    final formData = req.data as FormData;
    final fieldsMap = <String, dynamic>{};
    for (final field in formData.fields) {
      fieldsMap[field.key] = field.value;
    }

    expect(fieldsMap['vehicleType'], '2_WHEELER');
    expect(fieldsMap['vehicleTypes'], jsonEncode(['2_WHEELER']));
    expect(fieldsMap['name'], 'Samuel Taylor');
    expect(fieldsMap['phone'], '76145892');
    expect(fieldsMap['phoneCountryCode'], '+232');
    expect(fieldsMap['vehicleName'], 'Honda CB Shine 125');
    expect(fieldsMap['vehicleNumber'], 'SL-AA-9988');
    expect(fieldsMap['drivingLicenseNo'], 'DL-10928374');
    expect(fieldsMap['selectedZones'], jsonEncode(['ZONE 1', 'ZONE 2']));
    expect(fieldsMap['selectedLocations'], jsonEncode(['NO 2 RIVER', 'BAW BAW']));

    expect(result.id, 'cm7rider0001');
    expect(result.name, 'Samuel Taylor');
    expect(result.vehicleType, '2_WHEELER');
    expect(result.drivingLicenseNo, 'DL-10928374');
    expect(result.onboardingCompleted, true);
    expect(result.selectedZones, ['ZONE 1', 'ZONE 2']);
    expect(result.selectedLocations, ['NO 2 RIVER', 'BAW BAW']);
  });
}
