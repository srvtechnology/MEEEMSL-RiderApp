import os

files = {}

# 1. test/data/models/order_model_test.dart
files['test/data/models/order_model_test.dart'] = '''import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/order_model.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';

void main() {
  const tOrderModel = OrderModel(
    id: 'ord_123',
    orderNumber: '#MM-1001',
    status: OrderStatus.inTransit,
    customerName: 'Alice Smith',
    customerPhone: '+1 555 123 4567',
    customerAvatar: '',
    pickupName: 'Pizza Bistro',
    pickupAddress: '100 Main St',
    pickupPhone: '+1 555 999 8888',
    dropoffAddress: '200 Oak Ave',
    pickupLat: 40.7128,
    pickupLng: -74.0060,
    dropoffLat: 40.7306,
    dropoffLng: -73.9352,
    items: [],
    subtotal: 35.0,
    riderEarnings: 12.5,
    distanceKm: 2.5,
    estimatedDurationMin: 15,
    createdAt: null,
  );

  test('OrderModel should be a subclass of OrderEntity', () {
    expect(tOrderModel, isA<OrderEntity>());
  });

  test('OrderModel fromJson should parse JSON correctly', () {
    final json = {
      'id': 'ord_123',
      'orderNumber': '#MM-1001',
      'status': 'in_transit',
      'customerName': 'Alice Smith',
      'customerPhone': '+1 555 123 4567',
      'pickupName': 'Pizza Bistro',
      'pickupAddress': '100 Main St',
      'dropoffAddress': '200 Oak Ave',
      'subtotal': 35.0,
      'riderEarnings': 12.5,
      'distanceKm': 2.5,
      'estimatedDurationMin': 15,
    };

    final result = OrderModel.fromJson(json);

    expect(result.id, 'ord_123');
    expect(result.orderNumber, '#MM-1001');
    expect(result.status, OrderStatus.inTransit);
    expect(result.customerName, 'Alice Smith');
    expect(result.riderEarnings, 12.5);
  });
}
'''

# 2. test/domain/usecases/auth_usecases_test.dart
files['test/domain/usecases/auth_usecases_test.dart'] = '''import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/repositories/auth_repository.dart';
import 'package:meeem_rider/domain/usecases/auth/login_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late VerifyOtpUseCase verifyOtpUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    verifyOtpUseCase = VerifyOtpUseCase(mockRepository);
  });

  const tPhone = '+1 555 234 5678';
  const tOtp = '123456';
  const tRider = RiderEntity(
    id: 'rider_1',
    name: 'Alex Johnson',
    phone: tPhone,
    email: 'alex@example.com',
    avatar: '',
    rating: 4.9,
    totalTrips: 100,
    isOnline: true,
    walletBalance: 150.0,
    approvalStatus: 'approved',
  );

  test('LoginUseCase should call repository.login with phone number', () async {
    when(() => mockRepository.login(any())).thenAnswer((_) async => const Right(true));

    final result = await loginUseCase(tPhone);

    expect(result, const Right(true));
    verify(() => mockRepository.login(tPhone)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('VerifyOtpUseCase should call repository.verifyOtp and return RiderEntity', () async {
    when(() => mockRepository.verifyOtp(any(), any()))
        .thenAnswer((_) async => const Right(tRider));

    final result = await verifyOtpUseCase(tPhone, tOtp);

    expect(result, const Right(tRider));
    verify(() => mockRepository.verifyOtp(tPhone, tOtp)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
'''

# 3. test/domain/usecases/order_usecases_test.dart
files['test/domain/usecases/order_usecases_test.dart'] = '''import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/repositories/order_repository.dart';
import 'package:meeem_rider/domain/usecases/orders/get_active_orders_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/accept_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/update_order_status_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository mockRepository;
  late GetActiveOrdersUseCase getActiveOrdersUseCase;
  late AcceptOrderUseCase acceptOrderUseCase;
  late UpdateOrderStatusUseCase updateOrderStatusUseCase;

  setUp(() {
    mockRepository = MockOrderRepository();
    getActiveOrdersUseCase = GetActiveOrdersUseCase(mockRepository);
    acceptOrderUseCase = AcceptOrderUseCase(mockRepository);
    updateOrderStatusUseCase = UpdateOrderStatusUseCase(mockRepository);
  });

  final tOrder = OrderEntity(
    id: 'ord_99',
    orderNumber: '#MM-99',
    status: OrderStatus.accepted,
    customerName: 'John',
    customerPhone: '1234',
    customerAvatar: '',
    pickupName: 'Store',
    pickupAddress: 'Addr',
    pickupPhone: '5678',
    dropoffAddress: 'Drop',
    pickupLat: 0,
    pickupLng: 0,
    dropoffLat: 0,
    dropoffLng: 0,
    items: const [],
    subtotal: 20,
    riderEarnings: 10,
    distanceKm: 2,
    estimatedDurationMin: 10,
    createdAt: DateTime.now(),
  );

  test('GetActiveOrdersUseCase should fetch active orders', () async {
    when(() => mockRepository.getActiveOrders())
        .thenAnswer((_) async => Right([tOrder]));

    final result = await getActiveOrdersUseCase();

    expect(result, Right([tOrder]));
    verify(() => mockRepository.getActiveOrders()).called(1);
  });

  test('AcceptOrderUseCase should accept order by ID', () async {
    when(() => mockRepository.acceptOrder(any()))
        .thenAnswer((_) async => Right(tOrder));

    final result = await acceptOrderUseCase('ord_99');

    expect(result, Right(tOrder));
    verify(() => mockRepository.acceptOrder('ord_99')).called(1);
  });

  test('UpdateOrderStatusUseCase should update order status', () async {
    final updatedOrder = tOrder.copyWith(status: OrderStatus.delivered);
    when(() => mockRepository.updateOrderStatus(any(), any(), proofPhotoUrl: any(named: 'proofPhotoUrl'), customerOtp: any(named: 'customerOtp')))
        .thenAnswer((_) async => Right(updatedOrder));

    final result = await updateOrderStatusUseCase('ord_99', OrderStatus.delivered);

    expect(result, Right(updatedOrder));
    verify(() => mockRepository.updateOrderStatus('ord_99', OrderStatus.delivered)).called(1);
  });
}
'''

# 4. test/widget_test.dart
files['test/widget_test.dart'] = '''import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:meeem_rider/app.dart';
import 'package:meeem_rider/core/constants/app_strings.dart';

void main() {
  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MeeemRiderApp());

    // Verify App Name is present on the splash screen
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
  });
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

