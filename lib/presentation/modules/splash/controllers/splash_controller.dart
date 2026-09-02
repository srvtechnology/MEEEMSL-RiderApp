import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  bool _hasNavigated = false;

  void navigateToNextScreen() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final storage = GetStorage();
    final token = storage.read<String>(AppConstants.tokenKey);

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}

