import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/otp_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<OtpController>(
      init: OtpController(),
      builder: (controller) {

        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Color(0xff0C1A30), size: 20),
              onPressed: () => Get.back(),
            ),
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(height: 10),

                  /// Illustration
                  Image.asset(
                    "assets/images/otp_image.png",
                    height: 200,
                  ),

                  const SizedBox(height: 24),

                  /// Title
                  Text(
                    "Check Your SMS".tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Subtitle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${"We sent a 6-digit code to".tr} ",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      const SizedBox(width: 2),

                      Text(
                        controller.countryCode.value + controller.phoneNumber.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 38),

                  /// OTP BOX
                  LayoutBuilder(
                    builder: (context, constraints) {

                      const int len = 6;
                      const double gap = 10;

                      final w = constraints.maxWidth;

                      double fieldW = (w - (gap * (len - 1))) / len;
                      fieldW = fieldW.clamp(40.0, 54.0);

                      return PinCodeTextField(
                        length: len,
                        appContext: context,
                        keyboardType: TextInputType.phone,
                        autoDisposeControllers: false,
                        controller: controller.otpController.value,
                        enableActiveFill: true,
                        cursorColor: const Color(0xff0C1A30),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: gap),

                        textStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0C1A30),
                        ),

                        pinTheme: PinTheme(
                          fieldHeight: fieldW,
                          fieldWidth: fieldW,
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),

                          activeColor: const Color(0xff000000),
                          selectedColor: const Color(0xff0C1A30),
                          inactiveColor: const Color(0xffE2E5EA),

                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                        ),

                        onChanged: (_) {},
                        onCompleted: (_) {},
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  /// VERIFY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      onPressed: () async {

                        /// CUSTOMER LOGIC — UNCHANGED
                        if (controller.otpController.value.text.length != 6) {
                          ShowToastDialog.showToast(
                              "Please Enter Valid OTP".tr);
                          return;
                        }

                        ShowToastDialog.showLoader("Verify OTP".tr);

                        try {

                          PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                            verificationId:
                            controller.verificationId.value,
                            smsCode:
                            controller.otpController.value.text,
                          );

                          final value = await FirebaseAuth.instance
                              .signInWithCredential(credential);

                          ShowToastDialog.closeLoader();

                          if (value.additionalUserInfo!.isNewUser) {

                            UserModel userModel = UserModel();

                            userModel.id = value.user!.uid;
                            userModel.countryCode =
                                controller.countryCode.value;
                            userModel.phoneNumber =
                                controller.phoneNumber.value;
                            userModel.loginType =
                                Constant.phoneLoginType;

                            Get.to(const InformationScreen(),
                                arguments: {"userModel": userModel});

                          } else {

                            final role =
                            await FireStoreUtils
                                .userExitCustomerOrDriverRole(
                                value.user!.uid);

                            if (role == Constant.currentUserType) {

                              Get.offAll(const InformationScreen());

                            } else {

                              await FirebaseAuth.instance.signOut();

                              ShowToastDialog.showToast(
                                "This mobile number is already registered with a different role."
                                    .tr,
                              );
                            }
                          }

                        } catch (e) {

                          ShowToastDialog.closeLoader();

                          ShowToastDialog.showToast(
                              "Code is Invalid".tr);
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff12223b),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),

                      child: Text(
                        "Verify".tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


/*
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/otp_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OtpController>(
        init: OtpController(),
        builder: (controller) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/images/new_login_image_1.png"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text("Verify Phone Number".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text("We just send a verification code to \n${controller.countryCode.value + controller.phoneNumber.value}".tr, style: GoogleFonts.poppins()),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: PinCodeTextField(
                            length: 6,
                            appContext: context,
                            keyboardType: TextInputType.phone,
                            pinTheme: PinTheme(
                              fieldHeight: 50,
                              fieldWidth: 50,
                              activeColor: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
                              selectedColor: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
                              inactiveColor: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
                              activeFillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                              inactiveFillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                              selectedFillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enableActiveFill: true,
                            cursorColor: AppColors.lightprimary,
                            controller: controller.otpController.value,
                            onCompleted: (v) async {},
                            onChanged: (value) {},
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ButtonThem.buildButton(
                          context,
                          title: "Verify".tr,
                          onPress: () async {
                            if (controller.otpController.value.text.length == 6) {
                              ShowToastDialog.showLoader("Verify OTP".tr);

                              PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: controller.verificationId.value, smsCode: controller.otpController.value.text);
                              await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                                if (value.additionalUserInfo!.isNewUser) {
                                  print("----->new user");
                                  UserModel userModel = UserModel();
                                  userModel.id = value.user!.uid;
                                  userModel.countryCode = controller.countryCode.value;
                                  userModel.phoneNumber = controller.phoneNumber.value;
                                  userModel.loginType = Constant.phoneLoginType;

                                  ShowToastDialog.closeLoader();
                                  Get.to(const InformationScreen(), arguments: {
                                    "userModel": userModel,
                                  });
                                } else {
                                  await FireStoreUtils.userExitCustomerOrDriverRole(value.user!.uid).then((userExit) async {
                                    ShowToastDialog.closeLoader();
                                    if (userExit == '') {
                                      UserModel userModel = UserModel();
                                      userModel.id = value.user!.uid;
                                      userModel.countryCode = controller.countryCode.value;
                                      userModel.phoneNumber = controller.phoneNumber.value;
                                      userModel.loginType = Constant.phoneLoginType;

                                      ShowToastDialog.closeLoader();
                                      Get.to(const InformationScreen(), arguments: {
                                        "userModel": userModel,
                                      });
                                    } else if (userExit == Constant.currentUserType) {
                                      UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);
                                      if (userModel != null) {
                                        if (userModel.isActive == true) {
                                          Get.offAll(const DashBoardScreen());
                                        } else {
                                          await FirebaseAuth.instance.signOut();
                                          ShowToastDialog.showToast("This user is disable please contact administrator".tr);
                                        }
                                      }
                                    } else {
                                      await FirebaseAuth.instance.signOut();
                                      ShowToastDialog.showToast('This mobile number is already registered with a different role.'.tr);
                                    }
                                  });
                                }
                              }).catchError((error) {
                                ShowToastDialog.closeLoader();
                                ShowToastDialog.showToast("Code is Invalid".tr);
                              });
                            } else {
                              ShowToastDialog.showToast("Please Enter Valid OTP".tr);
                            }

                            // print(controller.countryCode.value);
                            // print(controller.phoneNumberController.value.text);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
*/
