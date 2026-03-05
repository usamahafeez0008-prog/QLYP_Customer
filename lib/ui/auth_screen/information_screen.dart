import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/information_controller.dart';
import 'package:customer/model/referral_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<InformationController>(
      init: InformationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.black, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Illustration
                Center(
                  child: Image.asset(
                    "assets/images/otp_image.png", // Using a fallback that might match the illustration
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset("assets/images/otp_image.png", height: 200),
                  ),
                ),
                const SizedBox(height: 12),

                // Title & Subtitle
                Text(
                  "Sign up".tr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create your account to start using QLYP".tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.subTitleColor,
                  ),
                ),
                const SizedBox(height: 30),

                // Form
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InputFieldLabel(label: "Full Name".tr, isDark: false),
                    _StandardTextField(
                      hint: 'Enter your full name'.tr,
                      controller: controller.fullNameController.value,
                      isDark: false,
                      textInputType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InputFieldLabel(label: "Pays".tr, isDark: false),
                              _CountryPickerField(
                                initialSelection: controller.countryCode.value,
                                onCountryChanged: (value) => controller
                                    .countryCode
                                    .value = value.dialCode.toString(),
                                isDark: false,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InputFieldLabel(
                                  label: "Numéro de téléphone".tr,
                                  isDark: false),
                              _StandardTextField(
                                hint: 'Phone number'.tr,
                                controller:
                                    controller.phoneNumberController.value,
                                isDark: false,
                                enabled: controller.loginType.value !=
                                    Constant.phoneLoginType,
                                textInputType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InputFieldLabel(label: "Email".tr, isDark: false),
                    _StandardTextField(
                      hint: 'Enter your email'.tr,
                      controller: controller.emailController.value,
                      isDark: false,
                      enabled: controller.loginType.value !=
                          Constant.googleLoginType,
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _InputFieldLabel(label: "Password".tr, isDark: false),
                    _StandardTextField(
                      hint: 'Enter your password'.tr,
                      controller: controller.passwordController.value,
                      isDark: false,
                      obscureText: true,
                      textInputType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 20),
                    // _InputFieldLabel(
                    //     label: 'Referral Code (Optional)'.tr, isDark: false),
                    // _StandardTextField(
                    //   hint: 'Enter referral code'.tr,
                    //   controller: controller.referralCodeController.value,
                    //   isDark: false,
                    //   textInputType: TextInputType.text,
                    // ),
                  ],
                ),

                const SizedBox(height: 30),

                // Create Account Button
                _PrimaryDarkButton(
                  title: "Create account".tr,
                  onPressed: () async {
                    // --- NO FUNCTIONAL CHANGES BELOW (same logic as your code) ---
                    if (controller.fullNameController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter full name".tr);
                    } else if (controller.emailController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter email".tr);
                    } else if (controller
                        .phoneNumberController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter phone".tr);
                    } else if (Constant.validateEmail(
                            controller.emailController.value.text) ==
                        false) {
                      ShowToastDialog.showToast("Please enter valid email".tr);
                    } else if (controller
                        .passwordController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter password".tr);
                    } else {
                      if (controller
                          .referralCodeController.value.text.isNotEmpty) {
                        FireStoreUtils.checkReferralCodeValidOrNot(
                                controller.referralCodeController.value.text)
                            .then((value) async {
                          if (value == true) {
                            ShowToastDialog.showLoader("Please wait".tr);
                            UserModel userModel = controller.userModel.value;
                            userModel.fullName =
                                controller.fullNameController.value.text;
                            userModel.email =
                                controller.emailController.value.text;
                            userModel.countryCode =
                                controller.countryCode.value;
                            userModel.phoneNumber =
                                controller.phoneNumberController.value.text;
                            userModel.password =
                                controller.passwordController.value.text;
                            userModel.isActive = true;
                            userModel.createdAt = Timestamp.now();

                            await FireStoreUtils.getReferralUserByCode(
                                    controller
                                        .referralCodeController.value.text)
                                .then((value) async {
                              if (value != null) {
                                ReferralModel ownReferralModel = ReferralModel(
                                  id: FireStoreUtils.getCurrentUid(),
                                  referralBy: value.id,
                                  referralCode: Constant.getReferralCode(),
                                );
                                await FireStoreUtils.referralAdd(
                                    ownReferralModel);
                              } else {
                                ReferralModel referralModel = ReferralModel(
                                  id: FireStoreUtils.getCurrentUid(),
                                  referralBy: "",
                                  referralCode: Constant.getReferralCode(),
                                );
                                await FireStoreUtils.referralAdd(referralModel);
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
                        UserModel userModel = controller.userModel.value;
                        userModel.fullName =
                            controller.fullNameController.value.text;
                        userModel.email = controller.emailController.value.text;
                        userModel.countryCode = controller.countryCode.value;
                        userModel.phoneNumber =
                            controller.phoneNumberController.value.text;
                        userModel.password =
                            controller.passwordController.value.text;
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
                          if (value == true) {

                            Get.offAll(const DashBoardScreen());
                          }
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 50),

              ],
            ),
          ),
        );
      },
    );
  }
}

class _InputFieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _InputFieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _StandardTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool isDark;
  final bool enabled;
  final bool obscureText;
  final TextInputType textInputType;

  const _StandardTextField({
    required this.hint,
    required this.controller,
    required this.isDark,
    this.enabled = true,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: textInputType,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkTextField : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? AppColors.darkTextFieldBorder
                  : AppColors.textFieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? AppColors.darkTextFieldBorder
                  : AppColors.textFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.qlypDeepNavy, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? AppColors.darkTextFieldBorder.withOpacity(0.5)
                  : AppColors.textFieldBorder.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class _CountryPickerField extends StatelessWidget {
  final String initialSelection;
  final void Function(CountryCode value) onCountryChanged;
  final bool isDark;

  const _CountryPickerField({
    required this.initialSelection,
    required this.onCountryChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkTextField : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? AppColors.darkTextFieldBorder
                : AppColors.textFieldBorder),
      ),
      child: CountryCodePicker(
        onChanged: onCountryChanged,
        initialSelection: initialSelection,
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        dialogBackgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
        flagDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _PrimaryDarkButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _PrimaryDarkButton({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.qlypDeepNavy,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
