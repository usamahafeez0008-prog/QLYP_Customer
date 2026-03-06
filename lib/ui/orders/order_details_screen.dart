import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/order_details_controller.dart';

import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/order/driverId_accept_reject.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/location_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<OrderDetailsController>(
        init: OrderDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.qlypDeepNavy,
            body: Column(
              children: [
                // ── Dark navy header ──────────────────────────────────────
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Close / back button
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                            const Spacer(),
                            // Location chip
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection(CollectionName.orders)
                                  .doc(controller.orderModel.value.id)
                                  .snapshots(),
                              builder: (context, snap) {
                                if (!snap.hasData) return const SizedBox();
                                final om =
                                    OrderModel.fromJson(snap.data!.data()!);
                                final src = (om.sourceLocationName ?? '')
                                    .split(',')
                                    .first
                                    .toUpperCase();
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    src,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Available drivers".tr,
                          style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Select your preferred ride".tr,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),

                // ── White content area ─────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeChange.getThem()
                          ? const Color(0xFF121212)
                          : AppColors.qlypOffWhite,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                    ),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(CollectionName.orders)
                          .doc(controller.orderModel.value.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Something went wrong'.tr));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Constant.loader(
                              isDarkTheme: themeChange.getThem());
                        }

                        OrderModel orderModel =
                            OrderModel.fromJson(snapshot.data!.data()!);

                        return Column(
                          children: [
                            // ── Order summary (location + OTP + cancel) ───
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status + amount
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          orderModel.status.toString(),
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Text(
                                        orderModel.status == Constant.ridePlaced
                                            ? Constant.amountShow(
                                                amount: orderModel.offerRate
                                                    .toString())
                                            : Constant.amountShow(
                                                amount:
                                                    orderModel.finalRate == null
                                                        ? "0.0"
                                                        : orderModel.finalRate
                                                            .toString()),
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: const Color(0xFF22B55E)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Location view
                                  LocationView(
                                    sourceLocation: orderModel
                                        .sourceLocationName
                                        .toString(),
                                    destinationLocation: orderModel
                                        .destinationLocationName
                                        .toString(),
                                  ),
                                  const SizedBox(height: 12),
                                  // OTP + date row
                                  Container(
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem()
                                          ? AppColors.darkContainerBackground
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: themeChange.getThem()
                                          ? null
                                          : [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.10),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4))
                                            ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.lock_outline_rounded,
                                              size: 18,
                                              color: Color(0xFF22B55E)),
                                          const SizedBox(width: 8),
                                          Text("OTP".tr,
                                              style: GoogleFonts.poppins(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13)),
                                          const SizedBox(width: 6),
                                          Text(" ${orderModel.otp}",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          const Spacer(),
                                          Text(
                                            Constant().formatTimestamp(
                                                orderModel.createdDate),
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Cancel button
                                  ButtonThem.buildButton(
                                    context,
                                    title: "Cancel Ride".tr,
                                    //title: "Annuler la course".tr,
                                    btnHeight: 44,
                                    onPress: () async {
                                      List<dynamic> acceptDriverId = [];
                                      orderModel.status = Constant.rideCanceled;
                                      orderModel.acceptedDriverId =
                                          acceptDriverId;
                                      await FireStoreUtils.setOrder(orderModel)
                                          .then((value) {
                                        Get.back();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 1),

                            // ── Driver list ────────────────────────────────
                            Expanded(
                              child: orderModel.acceptedDriverId == null ||
                                      orderModel.acceptedDriverId!.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.directions_car_outlined,
                                              size: 60,
                                              color: Colors.grey.shade300),
                                          const SizedBox(height: 12),
                                          Text("Waiting for drivers...".tr,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500)),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 12, 16, 16),
                                      itemCount:
                                          orderModel.acceptedDriverId!.length,
                                      itemBuilder: (context, index) {
                                        final isFirst = index == 0;
                                        return FutureBuilder<DriverUserModel?>(
                                          future: FireStoreUtils.getDriver(
                                              orderModel
                                                  .acceptedDriverId![index]),
                                          builder: (context, snapshot) {
                                            switch (snapshot.connectionState) {
                                              case ConnectionState.waiting:
                                                return Constant.loader(
                                                    isDarkTheme:
                                                        themeChange.getThem());
                                              case ConnectionState.done:
                                                if (snapshot.hasError)
                                                  return Text(snapshot.error
                                                      .toString());
                                                DriverUserModel driverModel =
                                                    snapshot.data!;
                                                return FutureBuilder<
                                                    DriverIdAcceptReject?>(
                                                  future: FireStoreUtils
                                                      .getAcceptedOrders(
                                                          orderModel.id
                                                              .toString(),
                                                          driverModel.id
                                                              .toString()),
                                                  builder: (context, snapshot) {
                                                    switch (snapshot
                                                        .connectionState) {
                                                      case ConnectionState
                                                            .waiting:
                                                        return Constant.loader(
                                                            isDarkTheme:
                                                                themeChange
                                                                    .getThem());
                                                      case ConnectionState.done:
                                                        if (snapshot.hasError)
                                                          return Text(snapshot
                                                              .error
                                                              .toString());
                                                        DriverIdAcceptReject
                                                            driverIdAcceptReject =
                                                            snapshot.data!;
                                                        return _DriverCard(
                                                          driverModel:
                                                              driverModel,
                                                          driverIdAcceptReject:
                                                              driverIdAcceptReject,
                                                          orderModel:
                                                              orderModel,
                                                          themeChange:
                                                              themeChange,
                                                          controller:
                                                              controller,
                                                          isRecommended:
                                                              isFirst,
                                                          context: context,
                                                        );
                                                      default:
                                                        return Text('Error'.tr);
                                                    }
                                                  },
                                                );
                                              default:
                                                return Text('Error'.tr);
                                            }
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildServiceDetails(
      OrderModel orderModel, DarkThemeProvider themeChange) {
    if (orderModel.mainServiceType == "Logistique" &&
        orderModel.serviceDetails != null) {
      final details = orderModel.serviceDetails!;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: themeChange.getThem()
              ? AppColors.darkContainerBackground
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: themeChange.getThem()
              ? null
              : [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Logistics details",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const Divider(height: 16),
            _detailRow("Number of rooms", "${details['roomCount'] ?? 0}"),
            _detailRow(
                "Elevator", details['hasElevator'] == true ? "Yes" : "No"),
            _detailRow("Floor", "${details['floor'] ?? 'N/A'}"),
            _detailRow("Weight", "${details['weight'] ?? '0'} kg"),
            _detailRow("Dimensions", "${details['dimensions'] ?? 'N/A'}"),
            _detailRow("Description", "${details['description'] ?? 'N/A'}"),
            if (details['logistiquePickupDate'] != null)
              _detailRow("Pickup date",
                  Constant().formatTimestamp(details['logistiquePickupDate'])),
          ],
        ),
      );
    } else if (orderModel.mainServiceType == "Livraison" &&
        orderModel.serviceDetails != null) {
      final details = orderModel.serviceDetails!;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: themeChange.getThem()
              ? AppColors.darkContainerBackground
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: themeChange.getThem()
              ? null
              : [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Delivery details",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const Divider(height: 16),
            _detailRow(
                "Delivery type", "${details['deliveryType'] ?? 'Standard'}"),
            if (details['parcelImage'] != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: details['parcelImage'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Constant.loader(
                      isDarkTheme: themeChange.getThem(), strokeWidth: 2),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Driver card widget — matches screenshot layout
// ─────────────────────────────────────────────────────────────────────────────
class _DriverCard extends StatelessWidget {
  final DriverUserModel driverModel;
  final DriverIdAcceptReject driverIdAcceptReject;
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;
  final OrderDetailsController controller;
  final bool isRecommended;
  final BuildContext context;

  const _DriverCard({
    required this.driverModel,
    required this.driverIdAcceptReject,
    required this.orderModel,
    required this.themeChange,
    required this.controller,
    required this.isRecommended,
    required this.context,
  });

  // Build colored avatar with initials
  Widget _buildAvatar() {
    final name = driverModel.fullName ?? '';
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'
        : (name.isNotEmpty ? name[0] : '?');

    final avatarColors = [
      const Color(0xFF4A90D9),
      const Color(0xFFE86BBA),
      const Color(0xFFF5A623),
      const Color(0xFF7ED321),
      const Color(0xFF9B59B6),
    ];

    final colorIndex =
        (driverModel.id?.hashCode ?? 0).abs() % avatarColors.length;
    final bgColor = avatarColors[colorIndex];

    if (driverModel.profilePic != null && driverModel.profilePic!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: driverModel.profilePic!,
          height: 52,
          width: 52,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _initialsCircle(initials, bgColor),
          placeholder: (_, __) => _initialsCircle(initials, bgColor),
        ),
      );
    }
    return _initialsCircle(initials, bgColor);
  }

  Widget _initialsCircle(String initials, Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final isDark = themeChange.getThem();
    final offerAmount = driverIdAcceptReject.offerAmount ?? '0.0';
    final vehicleName = driverModel.serviceName ?? '';
    final rating = Constant.calculateReview(
      reviewCount: driverModel.reviewsCount.toString(),
      reviewSum: driverModel.reviewsSum.toString(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkContainerBackground : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isRecommended
            ? Border.all(color: AppColors.qlypDeepNavy, width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.12),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: avatar + name + price ───────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverModel.fullName ?? '',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            Constant.localizationTitle(driverModel.serviceName),
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Color(0xFFFFB800)),
                              const SizedBox(width: 3),
                              Text(rating,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              if (isRecommended) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Top Driver",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.qlypCharcoal
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Price + time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Constant.amountShow(
                              amount: double.tryParse(offerAmount)
                                      ?.toStringAsFixed(Constant
                                              .currencyModel?.decimalDigits ??
                                          2) ??
                                  offerAmount),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 14, color: Color(0xFF5B7EDB)),
                              const SizedBox(width: 4),
                              Text(
                                "2 min",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF5B7EDB)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Recommended checkmark
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                            color: AppColors.qlypDeepNavy,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 13),
                      ),
                    ],
                  ],
                ),

                // ── Vehicle image from service ──────────────────────────
                if (orderModel.service?.image != null &&
                    orderModel.service!.image!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: orderModel.service!.image!,
                        height: 100,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const SizedBox(height: 100),
                        errorWidget: (_, __, ___) =>
                            const SizedBox(height: 100),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 8),

                // ── Vehicle info row ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _InfoChip(
                      icon: Icons.directions_car_outlined,
                      label:
                          Constant.localizationTitle(driverModel.serviceName),
                      isDark: isDark,
                    ),
                    _InfoChip(
                      icon: Icons.palette_outlined,
                      label: driverModel.vehicleInformation?.vehicleColor ?? '',
                      isDark: isDark,
                    ),
                    _InfoChip(
                      icon: Icons.confirmation_number_outlined,
                      label:
                          driverModel.vehicleInformation?.vehicleNumber ?? '',
                      isDark: isDark,
                    ),
                  ],
                ),

                // ── Driver rules ──────────────────────────────────────────
                if (driverModel.vehicleInformation?.driverRules != null &&
                    driverModel
                        .vehicleInformation!.driverRules!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...driverModel.vehicleInformation!.driverRules!.map((rule) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: rule.image.toString(),
                            fit: BoxFit.fill,
                            height: Responsive.width(4, context),
                            width: Responsive.width(4, context),
                            placeholder: (ctx, url) =>
                                Constant.loader(isDarkTheme: isDark),
                            errorWidget: (ctx, url, error) =>
                                Image.network(Constant.userPlaceHolder),
                          ),
                          const SizedBox(width: 8),
                          Text(Constant.localizationName(rule.name)),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          // ── Distance + RECOMMANDÉ footer ─────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.near_me_outlined,
                    size: 15, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  "${orderModel.distance} km away",
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
                const Spacer(),
                if (isRecommended)
                  Text(
                    "RECOMMANDÉ",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.qlypDeepNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ),

          // ── Accept / Reject buttons ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                /* Expanded(
                  child: ButtonThem.buildBorderButton(
                    context,
                    title: "Rejeter".tr,
                    btnHeight: 48,
                    iconVisibility: false,
                    onPress: () async {
                      List<dynamic> rejectDriverId = [];
                      if (controller.orderModel.value.rejectedDriverId !=
                          null) {
                        rejectDriverId =
                            controller.orderModel.value.rejectedDriverId!;
                      }
                      rejectDriverId.add(driverModel.id);

                      List<dynamic> acceptDriverId = [];
                      if (controller.orderModel.value.acceptedDriverId !=
                          null) {
                        acceptDriverId =
                            controller.orderModel.value.acceptedDriverId!;
                      }
                      acceptDriverId.remove(driverModel.id);

                      controller.orderModel.value.rejectedDriverId =
                          rejectDriverId;
                      controller.orderModel.value.acceptedDriverId =
                          acceptDriverId;

                      await SendNotification.sendOneNotification(
                        token: driverModel.fcmToken.toString(),
                        title: 'Ride Canceled'.tr,
                        body:
                            'The passenger has canceled the ride. No action is required from your end.'
                                .tr,
                        payload: {},
                      );
                      await FireStoreUtils.setOrder(
                          controller.orderModel.value);
                    },
                  ),
                ),
                const SizedBox(width: 12),*/
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.qlypDeepNavy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      ShowToastDialog.showToast("Ride Confirm");
                      /*
                      orderModel.acceptedDriverId = [];
                      orderModel.driverId =
                          driverIdAcceptReject.driverId.toString();
                      orderModel.status = Constant.rideActive;
                      orderModel.finalRate = driverIdAcceptReject.offerAmount;
                      orderModel.vehicleInformation =
                          driverModel.vehicleInformation;
                      if (driverModel.ownerId != null) {
                        orderModel.ownerId = driverModel.ownerId;
                      }
                      // if (orderModel.isAcSelected == true) {
                      //   String acPerKmRateData = driverModel.vehicleInformation!.rates!
                      //       .firstWhere((prices) => prices.zoneId == orderModel.zoneId, orElse: () => RateModel()).acPerKmRate!;
                      //   orderModel.acNonAcCharges = acPerKmRateData;
                      // } else {
                      //   String nonAcPerKmRateData = driverModel.vehicleInformation!.rates!
                      //       .firstWhere((prices) => prices.zoneId == orderModel.zoneId, orElse: () => RateModel()).nonAcPerKmRate!;
                      //   orderModel.acNonAcCharges = nonAcPerKmRateData;
                      // }
                      await FireStoreUtils.setOrder(orderModel);
                      await SendNotification.sendOneNotification(
                        token: driverModel.fcmToken.toString(),
                        title: 'Ride Confirmed'.tr,
                        body:
                            'Your ride request has been accepted by the passenger. Please proceed to the pickup location.'
                                .tr,
                        payload: {},
                      );
                      Get.back();
                      */
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Confirmer ${driverModel.fullName?.split(' ').first ?? ''} →",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

// ── Small icon + label chip ────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoChip(
      {required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14, color: isDark ? Colors.white54 : Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87),
        ),
      ],
    );
  }
}
