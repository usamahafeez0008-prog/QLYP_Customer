import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/information_controller.dart';
import 'package:customer/model/referral_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    final bool isDark = true;

    return GetX<InformationController>(
      init: InformationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.qlypCharcoal,
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.qlypCharcoal,
                      AppColors.qlypOffWhite,
                      AppColors.qlypPrimarySunYellow,
                    ],
                  ),
                ),
              ),

              // Soft glow blobs
              Positioned(
                top: -80,
                left: -60,
                child: _GlowBlob(
                    color: AppColors.qlypDeepNavy.withOpacity(0.35),
                    size: 220),
              ),
              Positioned(
                top: 140,
                right: -90,
                child: _GlowBlob(
                    color: AppColors.qlypSecondaryWarmSand.withOpacity(0.18),
                    size: 260),
              ),
              Positioned(
                bottom: -120,
                left: -80,
                child: _GlowBlob(
                    color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.10),
                    size: 320),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/new_login_image_1.png",
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.cover,
                            ),

                            // Dark overlay
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.qlypCharcoal.withOpacity(0.20),
                                      AppColors.qlypCharcoal.withOpacity(0.78),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Content (Logo + Title + Subtitle)
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "assets/app_logo.png",
                                    width: 60,
                                    color: AppColors.qlypPrimaryFreshGreen,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Sign up".tr,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.qlypPrimaryFreshGreen,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Create your account to start using QlYP"
                                        .tr,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.qlypSecondaryWarmSand
                                          .withOpacity(0.90),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      const SizedBox(height: 18),

                      // Glass card container
                      _GlassCard(
                        child: Column(
                          children: [
                            _GlassTextField(
                              hint: 'Full name'.tr,
                              controller: controller.fullNameController.value,
                              textInputType: TextInputType.name,
                            ),
                            const SizedBox(height: 12),

                            // Phone Field (preserving your enabled logic + country picker)
                            _GlassPhoneField(
                              themeChange: themeChange,
                              enabled: controller.loginType.value ==
                                      Constant.phoneLoginType
                                  ? false
                                  : true,
                              controller:
                                  controller.phoneNumberController.value,
                              initialSelection: controller.countryCode.value,
                              onCountryChanged: (value) => controller
                                  .countryCode
                                  .value = value.dialCode.toString(),
                            ),
                            const SizedBox(height: 12),

                            _GlassTextField(
                              hint: 'Email'.tr,
                              controller: controller.emailController.value,
                              enabled: controller.loginType.value ==
                                      Constant.googleLoginType
                                  ? false
                                  : true,
                              textInputType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),

                            _GlassTextField(
                              hint: 'Referral Code (Optional)'.tr,
                              controller: controller.referralCodeController.value,
                              textInputType: TextInputType.text,
                            ),

                            const SizedBox(height: 18),

                            // Primary CTA (gradient like your OTP button)
                            _PrimaryGradientButton(
                              title: "Create account".tr,
                              onPressed: () async {
                                // --- NO FUNCTIONAL CHANGES BELOW (same logic as your code) ---
                                if (controller
                                    .fullNameController.value.text.isEmpty) {
                                  ShowToastDialog.showToast(
                                      "Please enter full name".tr);
                                } else if (controller.emailController.value.text.isEmpty) {
                                  ShowToastDialog.showToast(
                                      "Please enter email".tr);
                                } else if (controller
                                    .phoneNumberController.value.text.isEmpty) {
                                  ShowToastDialog.showToast(
                                      "Please enter phone".tr);
                                } else if (Constant.validateEmail(controller
                                        .emailController.value.text) ==
                                    false) {
                                  ShowToastDialog.showToast(
                                      "Please enter valid email".tr);
                                } else {
                                  if (controller.referralCodeController.value
                                      .text.isNotEmpty) {
                                    FireStoreUtils.checkReferralCodeValidOrNot(
                                            controller.referralCodeController
                                                .value.text)
                                        .then((value) async {
                                      if (value == true) {
                                        ShowToastDialog.showLoader(
                                            "Please wait".tr);
                                        UserModel userModel =
                                            controller.userModel.value;
                                        userModel.fullName = controller
                                            .fullNameController.value.text;
                                        userModel.email = controller
                                            .emailController.value.text;
                                        userModel.countryCode =
                                            controller.countryCode.value;
                                        userModel.phoneNumber = controller
                                            .phoneNumberController.value.text;
                                        userModel.isActive = true;
                                        userModel.createdAt = Timestamp.now();

                                        await FireStoreUtils
                                                .getReferralUserByCode(
                                                    controller
                                                        .referralCodeController
                                                        .value
                                                        .text)
                                            .then((value) async {
                                          if (value != null) {
                                            ReferralModel ownReferralModel =
                                                ReferralModel(
                                              id: FireStoreUtils
                                                  .getCurrentUid(),
                                              referralBy: value.id,
                                              referralCode:
                                                  Constant.getReferralCode(),
                                            );
                                            await FireStoreUtils.referralAdd(
                                                ownReferralModel);
                                          } else {
                                            ReferralModel referralModel =
                                                ReferralModel(
                                              id: FireStoreUtils
                                                  .getCurrentUid(),
                                              referralBy: "",
                                              referralCode:
                                                  Constant.getReferralCode(),
                                            );

                                            await FireStoreUtils.referralAdd(
                                                referralModel);
                                          }
                                        });

                                        await FireStoreUtils.updateUser(
                                                userModel)
                                            .then((value) {
                                          ShowToastDialog.closeLoader();
                                          if (value == true) {
                                            ShowToastDialog.showToast("Home Screen Coming Soon");
                                            //Get.offAll(const DashBoardScreen());
                                          }
                                        });
                                      } else {
                                        ShowToastDialog.showToast(
                                            "Referral code Invalid".tr);
                                      }
                                    });
                                  } else {
                                    ShowToastDialog.showLoader(
                                        "Please wait".tr);
                                    UserModel userModel =
                                        controller.userModel.value;
                                    userModel.fullName = controller
                                        .fullNameController.value.text;
                                    userModel.email =
                                        controller.emailController.value.text;
                                    userModel.countryCode =
                                        controller.countryCode.value;
                                    userModel.phoneNumber = controller
                                        .phoneNumberController.value.text;
                                    userModel.isActive = true;
                                    userModel.createdAt = Timestamp.now();

                                    ReferralModel referralModel = ReferralModel(
                                      id: FireStoreUtils.getCurrentUid(),
                                      referralBy: "",
                                      referralCode: Constant.getReferralCode(),
                                    );
                                    await FireStoreUtils.referralAdd(
                                        referralModel);

                                    await FireStoreUtils.updateUser(userModel)
                                        .then((value) {
                                      ShowToastDialog.closeLoader();
                                      if (value == true) {
                                        ShowToastDialog.showToast("Home Screen Coming Soon");
                                        //Get.offAll(const DashBoardScreen());
                                      }
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Small footer hint (optional, keeps it classy)
                      Center(
                        child: Text(
                          "By continuing, you agree to our terms.".tr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color:
                                AppColors.qlypSecondaryWarmSand.withOpacity(0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 60,
            spreadRadius: 12,
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            color: AppColors.qlypCharcoal.withOpacity(0.45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: AppColors.qlypSecondaryWarmSand.withOpacity(0.22),
                width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.qlypOffWhite.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType textInputType;

  const _GlassTextField({
    required this.hint,
    required this.controller,
    this.enabled = true,
    this.textInputType = TextInputType.text,
  });

  static const Color qlypPrimaryLight = AppColors.qlypPrimaryFreshGreen;
  static const Color qlypSecondaryLight = AppColors.qlypSecondaryWarmSand;
  static const Color qlypMutedRose = AppColors.qlypDeepNavy;
  static const Color qlypDark = AppColors.qlypCharcoal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: textInputType,
      cursorColor: AppColors.qlypSecondaryWarmSand,
      style: GoogleFonts.poppins(
        fontSize: 13.5,
        color: qlypPrimaryLight.withOpacity(enabled ? 0.95 : 0.60),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13.2,
          color: qlypSecondaryLight.withOpacity(0.65),
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        filled: true,
        fillColor: qlypDark.withOpacity(0.35),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: qlypSecondaryLight.withOpacity(0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: qlypSecondaryLight.withOpacity(0.18)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: qlypSecondaryLight.withOpacity(0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: qlypMutedRose, width: 1.2),
        ),
      ),
    );
  }
}
class _GlassPhoneField extends StatelessWidget {
  final DarkThemeProvider themeChange;
  final bool enabled;
  final TextEditingController controller;
  final String initialSelection;
  final void Function(CountryCode value) onCountryChanged;

  const _GlassPhoneField({
    required this.themeChange,
    required this.enabled,
    required this.controller,
    required this.initialSelection,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();

    return TextFormField(
      validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      cursorColor: AppColors.qlypSecondaryWarmSand,
      enabled: enabled,
      style: GoogleFonts.poppins(
        fontSize: 13.5,
        color: AppColors.qlypPrimaryFreshGreen.withOpacity(enabled ? 0.95 : 0.60),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Phone number".tr,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13.2,
          color: AppColors.qlypSecondaryWarmSand.withOpacity(0.65),
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        filled: true,
        fillColor: AppColors.qlypCharcoal.withOpacity(0.35),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: AppColors.qlypSecondaryWarmSand,
              ),
            ),
            child: CountryCodePicker(
              onChanged: onCountryChanged,
              dialogBackgroundColor:
              isDark ? AppColors.qlypCharcoal : AppColors.qlypPrimaryFreshGreen,
              initialSelection: initialSelection,
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

              // ✅ Search field theme (removes default green, uses QLYP)
              searchDecoration: InputDecoration(
                hintText: "Search country".tr,
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.5),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.qlypSecondaryWarmSand,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.qlypSecondaryWarmSand.withOpacity(0.4),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.qlypSecondaryWarmSand,
                    width: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 110),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.qlypSecondaryWarmSand.withOpacity(0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.qlypSecondaryWarmSand.withOpacity(0.18),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.qlypSecondaryWarmSand.withOpacity(0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.qlypDeepNavy,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
class _PrimaryGradientButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _PrimaryGradientButton({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.qlypPrimaryFreshGreen.withOpacity(0.92),
              AppColors.qlypSecondaryWarmSand.withOpacity(0.92),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.qlypOffWhite.withOpacity(0.55),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: onPressed,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.qlypPrimarySunYellow,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/information_controller.dart';
import 'package:customer/model/referral_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_them.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<InformationController>(
        init: InformationController(),
        builder: (controller) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/images/new_login_image_1.png",
                      width: Responsive.width(100, context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("Sign up".tr,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                              "Create your account to start using QlYP".tr,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFieldThem.buildTextFiled(context,
                            hintText: 'Full name'.tr,
                            controller: controller.fullNameController.value),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                            validator: (value) =>
                                value != null && value.isNotEmpty
                                    ? null
                                    : 'Required',
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.sentences,
                            controller: controller.phoneNumberController.value,
                            textAlign: TextAlign.start,
                            enabled: controller.loginType.value ==
                                    Constant.phoneLoginType
                                ? false
                                : true,
                            style: GoogleFonts.poppins(
                              color: themeChange.getThem()
                                  ? AppColors.textField
                                  : AppColors.darkTextField,
                            ),
                            decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: themeChange.getThem()
                                    ? AppColors.darkTextField
                                    : AppColors.textField,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                prefixIcon: CountryCodePicker(
                                  onChanged: (value) {
                                    controller.countryCode.value =
                                        value.dialCode.toString();
                                  },
                                  dialogBackgroundColor: themeChange.getThem()
                                      ? AppColors.darkBackground
                                      : AppColors.background,
                                  initialSelection:
                                      controller.countryCode.value,
                                  comparator: (a, b) =>
                                      b.name!.compareTo(a.name.toString()),
                                  flagDecoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2)),
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  borderSide: BorderSide(
                                      color: themeChange.getThem()
                                          ? AppColors.darkTextFieldBorder
                                          : AppColors.textFieldBorder,
                                      width: 1),
                                ),
                                hintText: "Phone number".tr)),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFieldThem.buildTextFiled(context,
                            hintText: 'Email'.tr,
                            controller: controller.emailController.value,
                            enable: controller.loginType.value ==
                                    Constant.googleLoginType
                                ? false
                                : true),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFieldThem.buildTextFiled(
                          context,
                          hintText: 'Referral Code (Optional)'.tr,
                          controller: controller.referralCodeController.value,
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        ButtonThem.buildButton(
                          context,
                          btnWidthRatio: 1,
                          title: "Create account".tr,
                          onPress: () async {
                            if (controller
                                .fullNameController.value.text.isEmpty) {
                              ShowToastDialog.showToast(
                                  "Please enter full name".tr);
                            } else if (controller
                                .emailController.value.text.isEmpty) {
                              ShowToastDialog.showToast(
                                  "Please enter email".tr);
                            } else if (controller
                                .phoneNumberController.value.text.isEmpty) {
                              ShowToastDialog.showToast(
                                  "Please enter phone".tr);
                            } else if (Constant.validateEmail(
                                    controller.emailController.value.text) ==
                                false) {
                              ShowToastDialog.showToast(
                                  "Please enter valid email".tr);
                            } else {
                              if (controller.referralCodeController.value.text
                                  .isNotEmpty) {
                                FireStoreUtils.checkReferralCodeValidOrNot(
                                        controller
                                            .referralCodeController.value.text)
                                    .then((value) async {
                                  if (value == true) {
                                    ShowToastDialog.showLoader(
                                        "Please wait".tr);
                                    UserModel userModel =
                                        controller.userModel.value;
                                    userModel.fullName = controller
                                        .fullNameController.value.text;
                                    userModel.email =
                                        controller.emailController.value.text;
                                    userModel.countryCode =
                                        controller.countryCode.value;
                                    userModel.phoneNumber = controller
                                        .phoneNumberController.value.text;
                                    userModel.isActive = true;
                                    userModel.createdAt = Timestamp.now();

                                    await FireStoreUtils.getReferralUserByCode(
                                            controller.referralCodeController
                                                .value.text)
                                        .then((value) async {
                                      if (value != null) {
                                        ReferralModel ownReferralModel =
                                            ReferralModel(
                                          id: FireStoreUtils.getCurrentUid(),
                                          referralBy: value.id,
                                          referralCode:
                                              Constant.getReferralCode(),
                                        );
                                        await FireStoreUtils.referralAdd(
                                            ownReferralModel);
                                      } else {
                                        ReferralModel referralModel =
                                            ReferralModel(
                                          id: FireStoreUtils.getCurrentUid(),
                                          referralBy: "",
                                          referralCode:
                                              Constant.getReferralCode(),
                                        );

                                        await FireStoreUtils.referralAdd(
                                            referralModel);
                                      }
                                    });

                                    await FireStoreUtils.updateUser(userModel)
                                        .then((value) {
                                      ShowToastDialog.closeLoader();

                                      if (value == true) {
                                        Get.offAll(const DashBoardScreen());
                                      }
                                    });
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Referral code Invalid".tr);
                                  }
                                });
                              } else {
                                ShowToastDialog.showLoader("Please wait".tr);
                                UserModel userModel =
                                    controller.userModel.value;
                                userModel.fullName =
                                    controller.fullNameController.value.text;
                                userModel.email =
                                    controller.emailController.value.text;
                                userModel.countryCode =
                                    controller.countryCode.value;
                                userModel.phoneNumber =
                                    controller.phoneNumberController.value.text;
                                userModel.isActive = true;
                                userModel.createdAt = Timestamp.now();

                                ReferralModel referralModel = ReferralModel(
                                  id: FireStoreUtils.getCurrentUid(),
                                  referralBy: "",
                                  referralCode: Constant.getReferralCode(),
                                );
                                await FireStoreUtils.referralAdd(referralModel);

                                await FireStoreUtils.updateUser(userModel)
                                    .then((value) {
                                  ShowToastDialog.closeLoader();
                                  print("------>$value");
                                  if (value == true) {
                                    Get.offAll(const DashBoardScreen());
                                  }
                                });
                              }
                            }
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
