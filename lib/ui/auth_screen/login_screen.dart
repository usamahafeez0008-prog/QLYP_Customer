import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/login_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/auth_screen/login_with_password_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return Stack(
          children: [
            /// BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                "assets/images/login_bg.jpg",
                fit: BoxFit.cover,
              ),
            ),

            Scaffold(
              backgroundColor: Colors.transparent,

              // appBar: AppBar(
              //   backgroundColor: Colors.transparent,
              //   elevation: 0,
              //   leading: IconButton(
              //     icon: const Icon(Icons.arrow_back_ios,
              //         color: Colors.grey, size: 20),
              //     onPressed: () => Get.back(),
              //   ),
              // ),

              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      /// Illustration
                      Image.asset(
                        "assets/images/login_image.png",
                        height: 220,
                      ),

                      const SizedBox(height: 12),

                      /// Title
                      Text(
                        "Enter your number".tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Subtitle
                      Text(
                        "We will send you a code by SMS".tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// COUNTRY + PHONE INPUT
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Country picker
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Country".tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xffE2E5EA)),
                                ),
                                child: CountryCodePicker(
                                  onChanged: (value) {
                                    controller.countryCode.value =
                                        value.dialCode.toString();
                                  },
                                  dialogBackgroundColor:
                                      AppColors.qlypCharcoal.withOpacity(0.8),
                                  initialSelection:
                                      controller.countryCode.value,
                                  comparator: (a, b) =>
                                      b.name!.compareTo(a.name.toString()),
                                  flagDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  textStyle: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  padding: EdgeInsets.zero,
                                  showDropDownButton: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 14),

                          /// Phone number input
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Phone number".tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xffE2E5EA)),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Center(
                                    child: TextFormField(
                                      validator: (value) =>
                                          value != null && value.isNotEmpty
                                              ? null
                                              : 'Required'.tr,
                                      keyboardType: TextInputType.number,
                                      controller: controller
                                          .phoneNumberController.value,
                                      cursorColor: const Color(0xff0C1A30),
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xff0C1A30),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "(514) 000-0000",
                                        hintStyle: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xffC4C5C4),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      /// CONTINUE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => controller.sendCode(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff12223b),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Continue".tr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Navigate to Password Login
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            Get.to(() => const LoginWithPasswordScreen());
                          },
                          child: Text(
                            "Already Have An Account! Login".tr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// Divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xffE2E5EA),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              "Or sign in with".tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Color(0xffE2E5EA),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// SOCIAL LOGIN ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// GOOGLE
                          InkWell(
                            onTap: () {},
                            child: Image.asset(
                              "assets/images/google_btn.png",
                              width: 70,
                              height: 70,
                            ),
                          ),

                          /// FACEBOOK
                          InkWell(
                            onTap: () {},
                            child: Image.asset(
                              "assets/images/fb_button.png",
                              width: 70,
                              height: 70,
                            ),
                          ),

                          /// APPLE
                          if (Platform.isIOS)
                            InkWell(
                              onTap: () async {
                                ShowToastDialog.showLoader("Please wait".tr);

                                await controller
                                    .signInWithApple()
                                    .then((value) async {
                                  ShowToastDialog.closeLoader();

                                  /// ORIGINAL APPLE LOGIN CODE REMAINS UNCHANGED
                                });
                              },
                              child: Image.asset(
                                "assets/images/apple_btn.png",
                                width: 70,
                                height: 70,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      /// TERMS
                      /* Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text:
                          'By continuing, you agree to our '
                              .tr,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          children: [

                            TextSpan(
                              text: 'Terms'.tr,
                              recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(
                                      const TermsAndConditionScreen(
                                          type:
                                          "terms"));
                                },
                              style:
                              GoogleFonts.poppins(
                                fontWeight:
                                FontWeight.w600,
                                decoration:
                                TextDecoration
                                    .underline,
                              ),
                            ),

                            const TextSpan(
                                text: " and "),

                            TextSpan(
                              text: 'Privacy Policy'.tr,
                              recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(
                                      const TermsAndConditionScreen(
                                          type:
                                          "privacy"));
                                },
                              style:
                              GoogleFonts.poppins(
                                fontWeight:
                                FontWeight.w600,
                                decoration:
                                TextDecoration
                                    .underline,
                              ),
                            ),
                          ],
                        ),
                      ),*/

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
/*
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/login_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<LoginController>(
      init: LoginController(),
      builder: (controller) {
        final isDark = themeChange.getThem();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.qlypOffWhite.withOpacity(0.98),
                AppColors.qlypCharcoal,
                AppColors.qlypCharcoal.withOpacity(0.95),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),

          /// SCAFFOLD INSIDE
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,

            /// ================= BODY =================
            body: Stack(
              children: [
                // Background blobs
                Positioned(top: -100,  right: -50,
                  child: Container( width: 300,  height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.qlypDeepNavy.withOpacity(0.25),
                          AppColors.qlypDeepNavy.withOpacity(0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.qlypPrimaryFreshGreen.withOpacity(0.15),
                          AppColors.qlypPrimaryFreshGreen.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating particles
                Positioned(
                  top: 150,
                  left: 30,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.qlypSecondaryWarmSand.withOpacity(0.40),
                    ),
                  ),
                ),
                Positioned(
                  top: 280,
                  right: 40,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.qlypPrimarySunYellow.withOpacity(0.30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 200,
                  right: 60,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.qlypDeepNavy.withOpacity(0.30),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    // space for bottom text
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.vertical,
                      ),
                      child: Column(
                        children: [
                          // Hero Section
                          SizedBox(
                            height: Responsive.width(65, context),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    "assets/images/new_login_image_1.png",
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),

                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.qlypCharcoal.withOpacity(0.95),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),

                                // Logo and Welcome Text
                                Positioned(
                                  left: 24,
                                  bottom: 24,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        "assets/app_logo.png",
                                        width: 70,
                                        height: 70,
                                        color: AppColors.qlypPrimaryFreshGreen,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Welcome Back".tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.qlypPrimaryFreshGreen,
                                          letterSpacing: -0.5,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Login to continue your journey".tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.qlypPrimaryFreshGreen
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 60),

                          // Login Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: AppColors.qlypCharcoal.withOpacity(0.4),
                                border: Border.all(
                                  color: AppColors.qlypPrimaryFreshGreen
                                      .withOpacity(0.08),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                  BoxShadow(
                                    color: AppColors.qlypPrimaryFreshGreen
                                        .withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Padding(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Phone Number".tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.qlypPrimaryFreshGreen
                                              .withOpacity(0.9),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Phone input
                                      Container(
                                        height: 58,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppColors.qlypPrimaryFreshGreen
                                                .withOpacity(0.15),
                                            width: 1.5,
                                          ),
                                          color: AppColors.qlypCharcoal
                                              .withOpacity(0.6),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: AppColors.qlypCharcoal
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  bottomLeft:
                                                      Radius.circular(16),
                                                ),
                                              ),
                                              child: Theme(
                                                data: Theme.of(context).copyWith(
                                                  textSelectionTheme: TextSelectionThemeData(
                                                    cursorColor: AppColors.qlypSecondaryWarmSand,
                                                  ),
                                                ),
                                                child: CountryCodePicker(
                                                  onChanged: (value) {
                                                    controller.countryCode.value = value.dialCode.toString();
                                                  },
                                                  dialogBackgroundColor: isDark ? AppColors.qlypCharcoal : AppColors.qlypPrimaryFreshGreen,
                                                  initialSelection: controller.countryCode.value,
                                                  comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                                                  flagDecoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  textStyle: GoogleFonts.poppins(
                                                    color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.9),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  padding: EdgeInsets.zero,

                                                  // ✅ This removes the green color
                                                  searchDecoration: InputDecoration(
                                                    hintText: "Search country".tr,
                                                    hintStyle: GoogleFonts.poppins(
                                                      color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.5),
                                                      fontSize: 14,
                                                    ),
                                                    prefixIcon: Icon(
                                                      Icons.search,
                                                      color: AppColors.qlypSecondaryWarmSand,
                                                    ),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors.qlypSecondaryWarmSand.withOpacity(0.4),
                                                      ),
                                                    ),
                                                    focusedBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors.qlypSecondaryWarmSand,
                                                        width: 1.6,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              */
/* CountryCodePicker(
                                                onChanged: (value) {
                                                  controller.countryCode.value =
                                                      value.dialCode.toString();
                                                },
                                                dialogBackgroundColor: isDark
                                                    ? AppColors.qlypDark
                                                    : AppColors
                                                        .qlypPrimaryLight,
                                                initialSelection: controller
                                                    .countryCode.value,
                                                comparator: (a, b) => b.name!
                                                    .compareTo(
                                                        a.name.toString()),
                                                flagDecoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                textStyle: GoogleFonts.poppins(
                                                  color: AppColors
                                                      .qlypPrimaryLight
                                                      .withOpacity(0.9),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),*//*

                                            ),
                                            Container(
                                              width: 1,
                                              height: 24,
                                              color: AppColors.qlypPrimaryFreshGreen
                                                  .withOpacity(0.15),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: TextFormField(
                                                  validator: (value) =>
                                                      value != null &&
                                                              value.isNotEmpty
                                                          ? null
                                                          : 'Required',
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller: controller
                                                      .phoneNumberController
                                                      .value,
                                                  style: GoogleFonts.poppins(
                                                    color: AppColors
                                                        .qlypPrimaryFreshGreen
                                                        .withOpacity(0.95),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText:
                                                        "Enter phone number".tr,
                                                    hintStyle:
                                                        GoogleFonts.poppins(
                                                      color: AppColors
                                                          .qlypPrimaryFreshGreen
                                                          .withOpacity(0.4),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Continue button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 60,
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            onTap: () => controller.sendCode(),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    AppColors
                                                        .qlypSecondaryWarmSand,
                                                    AppColors.qlypPrimarySunYellow,
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.qlypPrimarySunYellow
                                                        .withOpacity(0.4),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                  BoxShadow(
                                                    color: AppColors
                                                        .qlypSecondaryWarmSand
                                                        .withOpacity(0.3),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Continue".tr,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            AppColors.qlypCharcoal,
                                                        letterSpacing: -0.2,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color: AppColors.qlypCharcoal,
                                                      size: 22,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Apple Login (iOS only) - logic unchanged
                                      if (Platform.isIOS)
                                        Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppColors.qlypPrimaryFreshGreen
                                                  .withOpacity(0.15),
                                              width: 1.5,
                                            ),
                                            color: AppColors.qlypCharcoal
                                                .withOpacity(0.4),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              onTap: () async {
                                                ShowToastDialog.showLoader(
                                                    "Please wait".tr);
                                                await controller
                                                    .signInWithApple()
                                                    .then((value) async {
                                                  ShowToastDialog.closeLoader();

                                                  if (value != null) {
                                                    Map<String, dynamic> map =
                                                        value;
                                                    AuthorizationCredentialAppleID
                                                        appleCredential =
                                                        map['appleCredential'];
                                                    UserCredential
                                                        userCredential =
                                                        map['userCredential'];

                                                    if (userCredential
                                                        .additionalUserInfo!
                                                        .isNewUser) {
                                                      UserModel userModel =
                                                          UserModel();
                                                      userModel.id =
                                                          userCredential
                                                              .user!.uid;
                                                      userModel.profilePic =
                                                          userCredential
                                                              .user!.photoURL;
                                                      userModel.loginType =
                                                          Constant
                                                              .appleLoginType;
                                                      userModel.email =
                                                          userCredential
                                                              .additionalUserInfo!
                                                              .profile!['email'];
                                                      userModel.fullName =
                                                          "${appleCredential.givenName} ${appleCredential.familyName}";

                                                      Get.to(
                                                          const InformationScreen(),
                                                          arguments: {
                                                            "userModel":
                                                                userModel,
                                                          });
                                                    } else {
                                                      await FireStoreUtils
                                                              .userExitCustomerOrDriverRole(
                                                                  userCredential
                                                                      .user!
                                                                      .uid)
                                                          .then(
                                                              (userExit) async {
                                                        if (userExit == '') {
                                                          UserModel userModel =
                                                              UserModel();
                                                          userModel.id =
                                                              userCredential
                                                                  .user!.uid;
                                                          userModel.profilePic =
                                                              userCredential
                                                                  .user!
                                                                  .photoURL;
                                                          userModel.loginType =
                                                              Constant
                                                                  .appleLoginType;
                                                          userModel.email =
                                                              userCredential
                                                                      .additionalUserInfo!
                                                                      .profile![
                                                                  'email'];
                                                          userModel.fullName =
                                                              "${appleCredential.givenName} ${appleCredential.familyName}";

                                                          Get.to(
                                                              const InformationScreen(),
                                                              arguments: {
                                                                "userModel":
                                                                    userModel,
                                                              });
                                                        } else if (userExit ==
                                                            Constant
                                                                .currentUserType) {
                                                          UserModel? userModel =
                                                              await FireStoreUtils
                                                                  .getUserProfile(
                                                                      userCredential
                                                                          .user!
                                                                          .uid);
                                                          if (userModel !=
                                                              null) {
                                                            if (userModel
                                                                    .isActive ==
                                                                true) {
                                                              ShowToastDialog.showToast("Home Screen Coming Soon");

                                                              //Get.offAll(const DashBoardScreen());
                                                            } else {
                                                              await FirebaseAuth
                                                                  .instance
                                                                  .signOut();
                                                              ShowToastDialog
                                                                  .showToast(
                                                                "This user is disable please contact administrator"
                                                                    .tr,
                                                              );
                                                            }
                                                          }
                                                        } else {
                                                          await FirebaseAuth
                                                              .instance
                                                              .signOut();
                                                          ShowToastDialog
                                                              .showToast(
                                                            'This account is already registered with a different role.'
                                                                .tr,
                                                          );
                                                        }
                                                      });
                                                    }
                                                  }
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      'assets/icons/ic_apple.png',
                                                      width: 22,
                                                      height: 22,
                                                      color: AppColors
                                                          .qlypPrimaryFreshGreen
                                                          .withOpacity(0.9),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      "Continue with Apple".tr,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .qlypPrimaryFreshGreen
                                                            .withOpacity(0.9),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// ================= TERMS FIXED =================
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text: 'By continuing, you agree to our '.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.6),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(
                                const TermsAndConditionScreen(type: "terms"));
                          },
                        text: 'Terms'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.qlypSecondaryWarmSand,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.6),
                        ),
                      ),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(
                                const TermsAndConditionScreen(type: "privacy"));
                          },
                        text: 'Privacy Policy'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.qlypSecondaryWarmSand,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
*/




/////////////////////////////////////////// Older Commented
/*class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<LoginController>(
      init: LoginController(),
      builder: (controller) {
        final isDark = themeChange.getThem();

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.qlypDeepPurple.withOpacity(0.98),
                  AppColors.qlypDark,
                  AppColors.qlypDark.withOpacity(0.95),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Background blobs
                Positioned(
                  top: -100,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.qlypMutedRose.withOpacity(0.25),
                          AppColors.qlypMutedRose.withOpacity(0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.qlypPrimaryLight.withOpacity(0.15),
                          AppColors.qlypPrimaryLight.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating particles
                Positioned(
                  top: 150,
                  left: 30,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.qlypSecondaryLight.withOpacity(0.40),
                    ),
                  ),
                ),
                Positioned(
                  top: 280,
                  right: 40,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.qlypPrimary.withOpacity(0.30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 200,
                  right: 60,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.qlypMutedRose.withOpacity(0.30),
                    ),
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    // ✅ Reserve space so content doesn't collide with bottom terms
                    padding: const EdgeInsets.only(bottom: 90),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.vertical,
                      ),
                      child: Column(
                        children: [
                          // Hero Section
                          SizedBox(
                            height: Responsive.width(55, context),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    "assets/images/new_login_image_1.png",
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),

                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.qlypDark.withOpacity(0.95),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),

                                // Logo and Welcome Text
                                Positioned(
                                  left: 24,
                                  bottom: 24,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        "assets/app_logo.png",
                                        width: 70,
                                        height: 70,
                                        color: AppColors.qlypPrimaryLight,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Welcome Back".tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.qlypPrimaryLight,
                                          letterSpacing: -0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Login to continue your journey".tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.qlypPrimaryLight.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Login Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: AppColors.qlypDark.withOpacity(0.4),
                                border: Border.all(
                                  color: AppColors.qlypPrimaryLight.withOpacity(0.08),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                  BoxShadow(
                                    color: AppColors.qlypPrimaryLight.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Padding(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Phone Number".tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Phone input
                                      Container(
                                        height: 58,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppColors.qlypPrimaryLight.withOpacity(0.15),
                                            width: 1.5,
                                          ),
                                          color: AppColors.qlypDark.withOpacity(0.6),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: AppColors.qlypDark.withOpacity(0.8),
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  bottomLeft: Radius.circular(16),
                                                ),
                                              ),
                                              child: CountryCodePicker(
                                                onChanged: (value) {
                                                  controller.countryCode.value =
                                                      value.dialCode.toString();
                                                },
                                                dialogBackgroundColor:
                                                isDark ? AppColors.qlypDark : AppColors.qlypPrimaryLight,
                                                initialSelection: controller.countryCode.value,
                                                comparator: (a, b) =>
                                                    b.name!.compareTo(a.name.toString()),
                                                flagDecoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                textStyle: GoogleFonts.poppins(
                                                  color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),

                                            Container(
                                              width: 1,
                                              height: 24,
                                              color: AppColors.qlypPrimaryLight.withOpacity(0.15),
                                            ),

                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: TextFormField(
                                                  validator: (value) =>
                                                  value != null && value.isNotEmpty ? null : 'Required',
                                                  keyboardType: TextInputType.number,
                                                  textCapitalization: TextCapitalization.sentences,
                                                  controller: controller.phoneNumberController.value,
                                                  style: GoogleFonts.poppins(
                                                    color: AppColors.qlypPrimaryLight.withOpacity(0.95),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Enter phone number".tr,
                                                    hintStyle: GoogleFonts.poppins(
                                                      color: AppColors.qlypPrimaryLight.withOpacity(0.4),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                    contentPadding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Continue button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 60,
                                        child: Material(
                                          borderRadius: BorderRadius.circular(18),
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(18),
                                            onTap: () => controller.sendCode(),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(18),
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    AppColors.qlypSecondaryLight,
                                                    AppColors.qlypPrimary,
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.qlypPrimary.withOpacity(0.4),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                  BoxShadow(
                                                    color: AppColors.qlypSecondaryLight.withOpacity(0.3),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Continue".tr,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.qlypDark,
                                                        letterSpacing: -0.2,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Icon(
                                                      Icons.arrow_forward_rounded,
                                                      color: AppColors.qlypDark,
                                                      size: 22,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Apple Login (iOS only) - logic unchanged
                                      if (Platform.isIOS)
                                        Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppColors.qlypPrimaryLight.withOpacity(0.15),
                                              width: 1.5,
                                            ),
                                            color: AppColors.qlypDark.withOpacity(0.4),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(16),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(16),
                                              onTap: () async {
                                                ShowToastDialog.showLoader("Please wait".tr);
                                                await controller.signInWithApple().then((value) async {
                                                  ShowToastDialog.closeLoader();

                                                  if (value != null) {
                                                    Map<String, dynamic> map = value;
                                                    AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
                                                    UserCredential userCredential = map['userCredential'];

                                                    if (userCredential.additionalUserInfo!.isNewUser) {
                                                      UserModel userModel = UserModel();
                                                      userModel.id = userCredential.user!.uid;
                                                      userModel.profilePic = userCredential.user!.photoURL;
                                                      userModel.loginType = Constant.appleLoginType;
                                                      userModel.email = userCredential.additionalUserInfo!.profile!['email'];
                                                      userModel.fullName =
                                                      "${appleCredential.givenName} ${appleCredential.familyName}";

                                                      Get.to(const InformationScreen(), arguments: {
                                                        "userModel": userModel,
                                                      });
                                                    } else {
                                                      await FireStoreUtils.userExitCustomerOrDriverRole(userCredential.user!.uid)
                                                          .then((userExit) async {
                                                        if (userExit == '') {
                                                          UserModel userModel = UserModel();
                                                          userModel.id = userCredential.user!.uid;
                                                          userModel.profilePic = userCredential.user!.photoURL;
                                                          userModel.loginType = Constant.appleLoginType;
                                                          userModel.email =
                                                          userCredential.additionalUserInfo!.profile!['email'];
                                                          userModel.fullName =
                                                          "${appleCredential.givenName} ${appleCredential.familyName}";

                                                          Get.to(const InformationScreen(), arguments: {
                                                            "userModel": userModel,
                                                          });
                                                        } else if (userExit == Constant.currentUserType) {
                                                          UserModel? userModel =
                                                          await FireStoreUtils.getUserProfile(userCredential.user!.uid);
                                                          if (userModel != null) {
                                                            if (userModel.isActive == true) {
                                                              Get.offAll(const DashBoardScreen());
                                                            } else {
                                                              await FirebaseAuth.instance.signOut();
                                                              ShowToastDialog.showToast(
                                                                "This user is disable please contact administrator".tr,
                                                              );
                                                            }
                                                          }
                                                        } else {
                                                          await FirebaseAuth.instance.signOut();
                                                          ShowToastDialog.showToast(
                                                            'This account is already registered with a different role.'.tr,
                                                          );
                                                        }
                                                      });
                                                    }
                                                  }
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      'assets/icons/ic_apple.png',
                                                      width: 22,
                                                      height: 22,
                                                      color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      "Continue with Apple".tr,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ TERMS FIXED AT BOTTOM ABOVE SYSTEM NAV BAR
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: Colors.transparent, // 🔥 remove grey background
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'By continuing, you agree to our '.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.qlypPrimaryLight.withOpacity(0.6),
                  ),
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(const TermsAndConditionScreen(type: "terms"));
                        },
                      text: 'Terms'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.qlypSecondaryLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.qlypPrimaryLight.withOpacity(0.6),
                      ),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(const TermsAndConditionScreen(type: "privacy"));
                        },
                      text: 'Privacy Policy'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.qlypSecondaryLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),



        );
      },
    );
  }
}*/

/*
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/login_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LoginController>(
        init: LoginController(),
        builder: (controller) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/images/login_image.png", width: Responsive.width(100, context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text("Login".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text("Welcome Back! We are happy to have \n you back".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w400)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                            validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.sentences,
                            controller: controller.phoneNumberController.value,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(color: themeChange.getThem() ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                prefixIcon: CountryCodePicker(
                                  onChanged: (value) {
                                    controller.countryCode.value = value.dialCode.toString();
                                  },
                                  dialogBackgroundColor: themeChange.getThem() ? AppColors.darkBackground : AppColors.background,
                                  initialSelection: controller.countryCode.value,
                                  comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                                  flagDecoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(2)),
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                ),
                                hintText: "Phone number".tr)),
                        const SizedBox(
                          height: 30,
                        ),
                        ButtonThem.buildButton(
                          context,
                          title: "Next".tr,
                          onPress: () {
                            controller.sendCode();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                          child: Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                height: 1,
                              )),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "OR".tr,
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(
                                height: 1,
                              )),
                            ],
                          ),
                        ),
                        ButtonThem.buildBorderButton(
                          context,
                          title: "Login with google".tr,
                          iconVisibility: true,
                          iconAssetImage: 'assets/icons/ic_google.png',
                          onPress: () async {
                            ShowToastDialog.showLoader("Please wait".tr);
                            await controller.signInWithGoogle().then((value) async {
                              ShowToastDialog.closeLoader();
                              if (value != null) {
                                if (value.additionalUserInfo!.isNewUser) {
                                  print("----->new user");
                                  UserModel userModel = UserModel();
                                  userModel.id = value.user!.uid;
                                  userModel.email = value.user!.email;
                                  userModel.fullName = value.user!.displayName;
                                  userModel.profilePic = value.user!.photoURL;
                                  userModel.loginType = Constant.googleLoginType;

                                  ShowToastDialog.closeLoader();
                                  Get.to(const InformationScreen(), arguments: {
                                    "userModel": userModel,
                                  });
                                } else {
                                  print("----->old user");
                                  await FireStoreUtils.userExitCustomerOrDriverRole(value.user!.uid).then((userExit) async {
                                    ShowToastDialog.closeLoader();
                                    if (userExit == '') {
                                      UserModel userModel = UserModel();
                                      userModel.id = value.user!.uid;
                                      userModel.email = value.user!.email;
                                      userModel.fullName = value.user!.displayName;
                                      userModel.profilePic = value.user!.photoURL;
                                      userModel.loginType = Constant.googleLoginType;

                                      ShowToastDialog.closeLoader();
                                      Get.to(const InformationScreen(), arguments: {
                                        "userModel": userModel,
                                      });
                                    } else if (userExit == Constant.currentUserType) {
                                      UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);
                                      if (userModel != null) {
                                        if (userModel.isActive == true) {
                                          String token = await NotificationService.getToken();
                                          userModel.fcmToken = token;
                                          await FireStoreUtils.updateUser(userModel);
                                          Get.offAll(const DashBoardScreen());
                                        } else {
                                          await FirebaseAuth.instance.signOut();
                                          ShowToastDialog.showToast("This user is disable please contact administrator".tr);
                                        }
                                      }
                                    } else {
                                      await FirebaseAuth.instance.signOut();
                                      ShowToastDialog.showToast('This account is already registered with a different role.'.tr);
                                    }
                                  });
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Visibility(
                            visible: Platform.isIOS,
                            child: ButtonThem.buildBorderButton(
                              context,
                              title: "Login with apple".tr,
                              iconVisibility: true,
                              iconAssetImage: 'assets/icons/ic_apple.png',
                              iconColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                              onPress: () async {
                                ShowToastDialog.showLoader("Please wait".tr);
                                await controller.signInWithApple().then((value) async {
                                  ShowToastDialog.closeLoader();

                                  if (value != null) {
                                    Map<String, dynamic> map = value;
                                    AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
                                    UserCredential userCredential = map['userCredential'];

                                    if (userCredential.additionalUserInfo!.isNewUser) {
                                      UserModel userModel = UserModel();
                                      userModel.id = userCredential.user!.uid;
                                      userModel.profilePic = userCredential.user!.photoURL;
                                      userModel.loginType = Constant.appleLoginType;
                                      userModel.email = userCredential.additionalUserInfo!.profile!['email'];
                                      userModel.fullName = "${appleCredential.givenName} ${appleCredential.familyName}";

                                      ShowToastDialog.closeLoader();
                                      Get.to(const InformationScreen(), arguments: {
                                        "userModel": userModel,
                                      });
                                    } else {
                                      await FireStoreUtils.userExitCustomerOrDriverRole(userCredential.user!.uid).then((userExit) async {
                                        ShowToastDialog.closeLoader();
                                        if (userExit == '') {
                                          UserModel userModel = UserModel();
                                          userModel.id = userCredential.user!.uid;
                                          userModel.profilePic = userCredential.user!.photoURL;
                                          userModel.loginType = Constant.appleLoginType;
                                          userModel.email = userCredential.additionalUserInfo!.profile!['email'];
                                          userModel.fullName = "${appleCredential.givenName} ${appleCredential.familyName}";

                                          ShowToastDialog.closeLoader();
                                          Get.to(const InformationScreen(), arguments: {
                                            "userModel": userModel,
                                          });
                                        } else if (userExit == Constant.currentUserType) {
                                          UserModel? userModel = await FireStoreUtils.getUserProfile(userCredential.user!.uid);
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
                                          ShowToastDialog.showToast('This account is already registered with a different role.'.tr);
                                        }
                                      });
                                    }
                                  }
                                });
                              },
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text: 'By tapping "Next" you agree to '.tr,
                    style: GoogleFonts.poppins(),
                    children: <TextSpan>[
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(const TermsAndConditionScreen(
                                type: "terms",
                              ));
                            },
                          text: 'Terms and conditions'.tr,
                          style: GoogleFonts.poppins(decoration: TextDecoration.underline)),
                      TextSpan(text: ' and ', style: GoogleFonts.poppins()),
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(const TermsAndConditionScreen(
                                type: "privacy",
                              ));
                            },
                          text: 'privacy policy'.tr,
                          style: GoogleFonts.poppins(decoration: TextDecoration.underline)),
                      // can add more TextSpans here...
                    ],
                  ),
                )),
          );
        });
  }
}
*/
