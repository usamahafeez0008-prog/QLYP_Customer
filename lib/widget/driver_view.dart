import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DriverView extends StatelessWidget {
  final String? driverId;
  final String? driverOfferRate;

  const DriverView({super.key, this.driverId, this.driverOfferRate});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return FutureBuilder<DriverUserModel?>(
        future: FireStoreUtils.getDriver(driverId.toString()),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const SizedBox();
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                if (snapshot.data == null) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: CachedNetworkImage(
                              height: 50,
                              width: 50,
                              imageUrl: Constant.userPlaceHolder,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Constant.loader(
                                  isDarkTheme: themeChange.getThem()),
                              errorWidget: (context, url, error) =>
                                  Image.network(Constant.userPlaceHolder),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Asynchronous user",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 22,
                                            color: AppColors.ratingColour,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  Constant.calculateReview(
                                                      reviewCount: "0.0",
                                                      reviewSum: "0.0"),
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              if (driverOfferRate != null)
                                                Text(
                                                  Constant.amountShow(
                                                      amount: driverOfferRate ??
                                                          '0.0'),
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                DriverUserModel driverModel = snapshot.data!;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            child: CachedNetworkImage(
                              height: 55,
                              width: 55,
                              imageUrl: driverModel.profilePic.toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Constant.loader(
                                  isDarkTheme: themeChange.getThem()),
                              errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.person,
                                      color: Colors.grey.shade400, size: 30)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driverModel.fullName.toString(),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 16, color: Color(0xffFFC107)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                        "${Constant.calculateReview(reviewCount: driverModel.reviewsCount.toString(), reviewSum: driverModel.reviewsSum.toString())} • Driver",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: Colors.grey.shade600)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        if (driverOfferRate != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Constant.amountShow(
                                    amount: driverOfferRate ?? '0.0'),
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: const Color(0xff22B55E)),
                              ),
                              Text(
                                "OFFER RATE".tr,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                );
              }
            default:
              return const Text('Error');
          }
        });
  }
}

class CustomerView extends StatelessWidget {
  final String? customerId;

  const CustomerView({super.key, this.customerId});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return FutureBuilder<UserModel?>(
        future: FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const SizedBox();
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                if (snapshot.data == null) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: CachedNetworkImage(
                              height: 50,
                              width: 50,
                              imageUrl: Constant.userPlaceHolder,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Constant.loader(
                                  isDarkTheme: themeChange.getThem()),
                              errorWidget: (context, url, error) =>
                                  Image.network(Constant.userPlaceHolder),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Asynchronous user",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 22,
                                            color: AppColors.ratingColour,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                UserModel driverModel = snapshot.data!;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(
                            height: 50,
                            width: 50,
                            imageUrl: driverModel.profilePic.toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Constant.loader(
                                isDarkTheme: themeChange.getThem()),
                            errorWidget: (context, url, error) =>
                                Image.network(Constant.userPlaceHolder),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driverModel.fullName.toString(),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 22,
                                          color: AppColors.ratingColour,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Text(
                                              Constant.calculateReview(
                                                  reviewCount: driverModel
                                                      .reviewsCount
                                                      .toString(),
                                                  reviewSum: driverModel
                                                      .reviewsSum
                                                      .toString()),
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            default:
              return const Text('Error');
          }
        });
  }
}
