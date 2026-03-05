import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/auth_screen/login_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginWithPasswordScreen extends StatefulWidget {
  const LoginWithPasswordScreen({Key? key}) : super(key: key);

  @override
  State<LoginWithPasswordScreen> createState() =>
      _LoginWithPasswordScreenState();
}

class _LoginWithPasswordScreenState extends State<LoginWithPasswordScreen> {
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool rememberMe = false;

  void _performLogin() async {
    String input = emailOrPhoneController.text.trim();
    String password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ShowToastDialog.showToast("Please enter credentials".tr);
      return;
    }

    ShowToastDialog.showLoader("Please wait".tr);

    try {
      bool isEmail = input.contains('@');
      UserModel? matchedUser;

      if (isEmail) {
        var query = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: input)
            .where('password', isEqualTo: password)
            .get();
        if (query.docs.isNotEmpty) {
          matchedUser = UserModel.fromJson(query.docs.first.data());
        }
      } else {
        String cleanInput =
            input.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '');

        // Test different lengths to find the phone number separately from country code
        for (int i = 0; i <= 4; i++) {
          if (i >= cleanInput.length) break;
          String possiblePhone = cleanInput.substring(i);

          var query = await FirebaseFirestore.instance
              .collection('users')
              .where('phoneNumber', isEqualTo: possiblePhone)
              .where('password', isEqualTo: password)
              .get();

          if (query.docs.isNotEmpty) {
            for (var doc in query.docs) {
              var data = doc.data();
              String cCode =
                  (data['countryCode']?.toString() ?? '').replaceAll('+', '');
              String pNumber = data['phoneNumber']?.toString() ?? '';

              if (cCode + pNumber == cleanInput || pNumber == cleanInput) {
                matchedUser = UserModel.fromJson(data);
                break;
              }
            }
            if (matchedUser != null) break;
          }
        }
      }

      ShowToastDialog.closeLoader();

      if (matchedUser != null) {
        if (matchedUser.isActive == true) {
          await Preferences.setString(
              Preferences.userId, matchedUser.id.toString());
          Get.offAll(() => const DashBoardScreen());
          ShowToastDialog.showToast("Login Successfully".tr);
        } else {
          ShowToastDialog.showToast(
              "This user is disabled please contact administrator".tr);
        }
      } else {
        ShowToastDialog.showToast(
            "Incorrect Credentials or Create an account".tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "Incorrect Credentials or Create an account".tr);
      print("Login Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Header
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/app_logo.png", // Attempting standard app logo name
                      height: 50,
                      errorBuilder: (context, error, stackTrace) => Text(
                        "Qlyp",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.qlypDeepNavy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Email / Phone Field
              Text(
                "Email or Phone Number",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.qlypDeepNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(
                  color: Colors
                      .black, // Sets the color of the text as the user types
                ),
                controller: emailOrPhoneController,
                decoration: InputDecoration(
                  hintText: "Enter your email or phone",
                  hintStyle:
                      GoogleFonts.plusJakartaSans(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.qlypDeepNavy),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              Text(
                "Password",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.qlypDeepNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(
                  color: Colors
                      .black, // Sets the color of the text as the user types
                ),
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle:
                      GoogleFonts.plusJakartaSans(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.qlypDeepNavy),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (val) {
                            setState(() {
                              rememberMe = val ?? false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Remember me",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      "Forgot password?",
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.qlypDeepNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _performLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xff12223b), // Match exact navy from screenshot
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sign In",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.login_rounded,
                          color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Divider
              Row(
                children: [
                  Expanded(
                      child:
                          Divider(color: Colors.grey.shade200, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Or sign in with",
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ),
                  Expanded(
                      child:
                          Divider(color: Colors.grey.shade200, thickness: 1)),
                ],
              ),

              const SizedBox(height: 24),

              // Social Logins
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton("assets/images/google_btn.png"),
                  const SizedBox(width: 20),
                  _socialButton("assets/images/fb_button.png"),
                  if (Platform.isIOS) ...[
                    const SizedBox(width: 20),
                    _socialButton("assets/images/apple_btn.png"),
                  ],
                ],
              ),

              const SizedBox(height: 140),

              // Create Account
              Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => const LoginScreen());
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'New driver? ',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey.shade600, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Create account',
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.qlypDeepNavy,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xff12223b),
        child: const Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }

  Widget _socialButton(String asset) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Image.asset(asset,
            width: 34,
            height: 34,
            errorBuilder: (ctx, err, stack) => const Icon(Icons.error)),
      ),
    );
  }
}
