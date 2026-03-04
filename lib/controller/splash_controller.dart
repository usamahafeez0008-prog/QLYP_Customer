import 'dart:async';
import 'dart:developer';
import 'package:customer/ui/auth_screen/login_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

import '../constant/show_toast_dialog.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  Future<void> redirectScreen() async {
    if (Preferences.getBoolean(Preferences.notificationPlayload) == true) {
      await Preferences.setBoolean(Preferences.notificationPlayload, false);
      log("Preferences.getBoolean(Preferences.notificationPlayload) :::::: ${Preferences.getBoolean(Preferences.notificationPlayload)}");
    }
    bool isLogin = await FireStoreUtils.isLogin();
    if (isLogin == true) {
      Get.offAll(const DashBoardScreen());
      //ShowToastDialog.showToast("Home Screen Coming Soon");
    } else {
      Get.offAll(const LoginScreen());
    }
  }
}

/*
//import 'package:customer/ui/on_boarding_screen.dart';

else { if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        Get.offAll(const OnBoardingScreen());
      } else {

      }*/
