import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/vip_controller.dart';
import '../../service/local_service/local_auth_service.dart';
import '../../service/remote_auth_service.dart';
import '../login_register/service/auth_service.dart';

class VipCheckService extends GetxService {
  final VipService _vipService = Get.find<VipService>();
  final AuthService _authService = Get.find<AuthService>();

  Future<void> init() async {
    // Kiểm tra và lấy AuthController một cách an toàn
    final authController = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    if (authController != null) {
      // Sử dụng authController nếu không null
      // Thực hiện các thao tác với authController
    } else {
      // Xử lý tình huống khi authController là null
      print("AuthController is not registered");
    }
  }

  Future<void> checkVipStatus() async {
    final LocalAuthService _localAuthService = LocalAuthService();
    AuthController authController = Get.find();
    await _localAuthService.init(); // Ensure initialization
    String? token = _localAuthService.getToken();
    if (token == null) {
      throw Exception("Token is not available");
    }

    String userEmail = authController.user.value?.email ?? '';
    if (userEmail.isEmpty || token.isEmpty) {
      print('Email or token is empty.');
      return;
    }

    var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
    if (userId == null) {
      print('User not found for email: $userEmail');
      return;
    }
    if (userId != null) {
      final vip = await VipService.getVipByUserId(userId);
      if (vip != null) {
        final now = DateTime.now();
        if (now.isAfter(vip.dayEnd) && vip.status) {
          await VipService.updateVipStatus(vip.id, false);
        }
      }
    }
  }
}