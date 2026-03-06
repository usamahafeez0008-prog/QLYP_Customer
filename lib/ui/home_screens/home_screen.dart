import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/controller/home_controller.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/widget/osm_map/map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';

import '../../constant/send_notification.dart';
import '../../model/order/positions.dart';
import '../../model/order_model.dart';
import '../../utils/fire_store_utils.dart';
import '../../widget/geoflutterfire/src/geoflutterfire.dart';
import '../../widget/geoflutterfire/src/models/point.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.background,
            drawer: DashBoardScreen()
                .buildAppDrawer(context, controller.dashboardController),
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : Stack(
                    children: [
                      // 1. Map Layer
                      Positioned.fill(
                        child: Obx(() => GoogleMap(
                              onMapCreated: (mapCont) {
                                controller.mapController = mapCont;
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                    controller.sourceLocationLAtLng.value
                                            .latitude ??
                                        31.511750025123046,
                                    controller.sourceLocationLAtLng.value
                                            .longitude ??
                                        74.31415762965483),
                                zoom: 14.0,
                              ),
                              markers: controller.markerSet,
                              polylines: controller.polylineSet,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                            )),
                      ),

                      // 2. Top UI Layer (Header & Service Tabs)
                      SafeArea(
                        child: Column(
                          children: [
                            // Main Services Tabs
                            Obx(() => SizedBox(
                                  height: 75,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    children: controller.mainServiceList
                                        .map((service) {
                                      return _buildServiceTab(
                                        context,
                                        title: (service.serviceName ?? "").tr,
                                        iconPath: service.image,
                                        isSelected: controller
                                                .selectedServiceCategory
                                                .value ==
                                            service.serviceName,
                                        onTap: () {
                                          controller.selectedServiceCategory
                                                  .value =
                                              service.serviceName ?? "";
                                          controller
                                                  .selectedMainServiceId.value =
                                              service.mainServiceID ?? "";
                                          controller.getServices(
                                              service.mainServiceID ?? "");
                                        },
                                      );
                                    }).toList(),
                                  ),
                                )),
                          ],
                        ),
                      ),

                      // 3. Bottom UI Layer (Booking Card)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildBottomBookingCard(context, controller),
                      ),
                    ],
                  ),
          );
        });
  }

  // --- Helper Widgets ---

  Widget _buildServiceTab(BuildContext context,
      {required String title,
      String? iconPath,
      IconData? iconData,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF5F7F8),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.qlypDeepNavy : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null)
              CachedNetworkImage(
                  imageUrl: iconPath,
                  width: 30,
                  height: 30,
                  placeholder: (context, url) =>
                      Constant.loader(isDarkTheme: false),
                  errorWidget: (context, url, error) => Icon(
                      iconData ?? Icons.category,
                      size: 20,
                      color: isSelected
                          ? AppColors.qlypDeepNavy
                          : AppColors.qlypDeepNavy.withOpacity(0.6)))
            else
              Icon(iconData ?? Icons.category,
                  color: isSelected
                      ? AppColors.qlypDeepNavy
                      : AppColors.qlypDeepNavy.withOpacity(0.6),
                  size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected
                    ? AppColors.qlypDeepNavy
                    : AppColors.qlypDeepNavy.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBookingCard(
      BuildContext context, HomeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36), topRight: Radius.circular(36)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.60,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5)),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildLocationField(
                    context,
                    hint: "Where are you leaving from?",
                    controller: controller.sourceLocationController.value,
                    iconColor: Colors.green,
                    onTap: () async {
                      final result = await Get.to(() => MapPickerPage());

                      if (result != null) {
                        final lat = result.coordinates.latitude;
                        final lng = result.coordinates.longitude;
                        final address = result.address;

                        controller.sourceLocationController.value.text =
                            address;

                        controller.sourceLocationLAtLng.value = LocationLatLng(
                          latitude: lat,
                          longitude: lng,
                        );

                        await controller.calculateDurationAndDistance();
                        controller.calculateAmount();
                        controller.drawRoute();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildLocationField(
                    context,
                    hint: "Which destination?",
                    controller: controller.destinationLocationController.value,
                    iconColor: Colors.red,
                    onTap: () async {
                      final result = await Get.to(() => MapPickerPage());

                      if (result != null) {
                        final lat = result.coordinates.latitude;
                        final lng = result.coordinates.longitude;
                        final address = result.address;

                        controller.destinationLocationController.value.text =
                            address;

                        controller.destinationLocationLAtLng.value =
                            LocationLatLng(
                          latitude: lat,
                          longitude: lng,
                        );

                        await controller.calculateDurationAndDistance();
                        controller.calculateAmount();
                        controller.drawRoute();
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  /// Service Category Card
                  Obx(() => controller.isServicesLoading.value
                      ? Constant.loader(isDarkTheme: false)
                      : controller.serviceList.isEmpty
                          ? const SizedBox()
                          : SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.serviceList.length,
                                itemBuilder: (context, index) {
                                  var subService =
                                      controller.serviceList[index];
                                  return Obx(() {
                                    bool isSelected =
                                        controller.selectedType.value.id ==
                                            subService.id;
                                    return InkWell(
                                      onTap: () {
                                        controller.selectedType.value =
                                            subService;
                                        controller.calculateAmount();
                                      },
                                      child: Container(
                                        width: 130,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.qlypDeepNavy
                                                  .withOpacity(0.05)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.qlypDeepNavy
                                                : AppColors.qlypCharcoal
                                                    .withOpacity(0.2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: subService.image ?? "",
                                              height: 50,
                                              width: 60,
                                              placeholder: (context, url) =>
                                                  Constant.loader(
                                                      isDarkTheme: false),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  const Icon(Icons.car_rental),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              Constant.localizationTitle(
                                                  subService.title),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppColors.qlypDeepNavy
                                                    : AppColors.qlypCharcoal
                                                        .withOpacity(0.5),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                },
                              ),
                            )),
                  const SizedBox(height: 20),

                  // Urgent, Later booking Card
                  Obx(() => (controller.selectedServiceCategory.value ==
                              "Livraison" ||
                          controller.selectedServiceCategory.value ==
                              "Logistique")
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            _buildModernBookingOptionsRow(controller),
                            const SizedBox(height: 20),
                          ],
                        )),

                  // Delivery Details Section (Visible only for Livraison)
                  Obx(() =>
                      controller.selectedServiceCategory.value == "Livraison"
                          ? _buildDeliveryDetailsSection(context, controller)
                          : const SizedBox.shrink()),

                  // Estimated Fare Card
                  Obx(() =>
                      controller.selectedServiceCategory.value == "Logistique"
                          ? const SizedBox.shrink()
                          : _buildEstimatedFareCard(controller)),
                  // Logistique Details Section
                  Obx(() =>
                      controller.selectedServiceCategory.value == "Logistique"
                          ? _buildLogistiqueDetailsSection(context, controller)
                          : const SizedBox.shrink()),

                  const SizedBox(height: 16),
                  // Ride Booking Button
                  Obx(() {
                    final isLogistique =
                        controller.selectedServiceCategory.value ==
                            "Logistique";
                    return SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.qlypDeepNavy,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () async {
                          bool isPaymentNotCompleted =
                              await FireStoreUtils.paymentStatusCheck();
                          bool isActiveRide =
                              await FireStoreUtils.checkActiveRide();

                          if (controller
                              .sourceLocationController.value.text.isEmpty) {
                            ShowToastDialog.showToast(
                                "Please select source location");
                            return;
                          }

                          if (controller.destinationLocationController.value
                              .text.isEmpty) {
                            ShowToastDialog.showToast(
                                "Please select destination location");
                            return;
                          }

                          if (isPaymentNotCompleted) {
                            showAlertDialog(context);
                            return;
                          }

                          if (isActiveRide) {
                            controller.dashboardController
                                .selectedDrawerIndex(2);
                            ShowToastDialog.showToast(
                                "You already have an active ride. Please complete it first.");
                            return;
                          }

                          ShowToastDialog.showLoader("Please wait");
                          try {
                            await controller.calculateDurationAndDistance();

                            OrderModel orderModel = OrderModel();
                            orderModel.id = Constant.getUuid();
                            orderModel.userId = FireStoreUtils.getCurrentUid();
                            orderModel.sourceLocationName =
                                controller.sourceLocationController.value.text;
                            orderModel.destinationLocationName = controller
                                .destinationLocationController.value.text;
                            orderModel.sourceLocationLAtLng =
                                controller.sourceLocationLAtLng.value;
                            orderModel.destinationLocationLAtLng =
                                controller.destinationLocationLAtLng.value;
                            orderModel.distance = controller.distance.value;
                            orderModel.duration = controller.duration.value;
                            orderModel.distanceType = Constant.distanceType;
                            orderModel.offerRate =
                                controller.amount.value.isEmpty
                                    ? "10"
                                    : controller.amount.value;
                            orderModel.serviceId =
                                controller.selectedType.value.id;
                            orderModel.service = controller.selectedType.value;

                            GeoFirePoint position = Geoflutterfire().point(
                              latitude: controller
                                  .sourceLocationLAtLng.value.latitude!,
                              longitude: controller
                                  .sourceLocationLAtLng.value.longitude!,
                            );
                            orderModel.position = Positions(
                                geoPoint: position.geoPoint,
                                geohash: position.hash);
                            orderModel.createdDate = Timestamp.now();
                            orderModel.status = Constant.ridePlaced;
                            orderModel.paymentType = "Cash";
                            orderModel.paymentStatus = false;
                            orderModel.otp = Constant.getReferralCode();
                            orderModel.taxList = Constant.taxList;
                            orderModel.adminCommission =
                                controller.selectedType.value.adminCommission;

                            if (controller.selectedType.value.prices != null &&
                                controller
                                    .selectedType.value.prices!.isNotEmpty) {
                              orderModel.zoneId = controller
                                  .selectedType.value.prices!.first.zoneId;
                              for (var zone in controller.zoneList) {
                                if (zone.id == orderModel.zoneId) {
                                  orderModel.zone = zone;
                                  break;
                                }
                              }
                            }

                            orderModel.mainServiceType =
                                controller.selectedServiceCategory.value;
                            orderModel.mainServiceID =
                                controller.selectedType.value.mainServiceID;

                            Map<String, dynamic> details = {};

                            if (controller.selectedServiceCategory.value ==
                                "Logistique") {
                              details['roomCount'] =
                                  controller.logistiqueRoomCount.value;
                              details['hasElevator'] =
                                  controller.logistiqueHasElevator.value;
                              details['floor'] =
                                  controller.logistiqueFloor.value;
                              details['weight'] =
                                  controller.logistiqueWeight.text;
                              details['dimensions'] =
                                  "${controller.logistiqueDimL.text} x ${controller.logistiqueDimW.text} x ${controller.logistiqueDimH.text}";
                              details['description'] =
                                  controller.logistiqueDescription.text;
                              details['logistiquePickupDate'] =
                                  Timestamp.fromDate(
                                      controller.logistiquePickupDate.value);
                            } else if (controller
                                    .selectedServiceCategory.value ==
                                "Livraison") {
                              details['deliveryType'] =
                                  controller.livraisonDeliveryType.value;
                              if (controller.livraisonParcelImage.value !=
                                  null) {
                                ShowToastDialog.showLoader(
                                    "Uploading image...");
                                String imageUrl =
                                    await Constant.uploadUserImageToFireStorage(
                                        controller.livraisonParcelImage.value!,
                                        'parcelImages',
                                        '${DateTime.now().millisecondsSinceEpoch}.png');
                                details['parcelImage'] = imageUrl;
                                ShowToastDialog.closeLoader();
                              }
                            }
                            orderModel.serviceDetails = details;

                            await FireStoreUtils()
                                .sendOrderDataFuture(orderModel)
                                .then((eventData) async {
                              for (var driver in eventData) {
                                if (driver.fcmToken != null) {
                                  Map<String, dynamic> playLoad =
                                      <String, dynamic>{
                                    "type": "city_order",
                                    "orderId": orderModel.id
                                  };
                                  await SendNotification.sendOneNotification(
                                    token: driver.fcmToken.toString(),
                                    title: 'New Ride Available',
                                    body:
                                        'A customer has placed a ride near your location.',
                                    payload: playLoad,
                                  );
                                }
                              }
                            });

                            await FireStoreUtils.setOrder(orderModel);
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast(
                                "Ride Placed Successfully");
                            controller.dashboardController
                                .selectedDrawerIndex(2);
                          } catch (e) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast("Error booking ride: $e");
                          }
                        },
                        child: isLogistique
                            ? Row(
                                children: [
                                  // Left: RÉSERVER un transport
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "BOOK",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                letterSpacing: 0.5),
                                          ),
                                          Text(
                                            "a transport",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Divider
                                  Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.white24),
                                  // Right: à partir de X$
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "starting at",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                  fontSize: 11),
                                            ),
                                            Obx(() => Text(
                                                  controller.amount.value
                                                              .isEmpty ||
                                                          controller.amount
                                                                  .value ==
                                                              "0.0" ||
                                                          controller.amount
                                                                  .value ==
                                                              "0"
                                                      ? "---"
                                                      : Constant.amountShow(
                                                          amount: controller
                                                              .amount.value),
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                )),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded,
                                            color: Colors.white, size: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "Book Now",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  //Build Social Icon
                  Obx(() => (controller.selectedServiceCategory.value ==
                              "Livraison" ||
                          controller.selectedServiceCategory.value ==
                              "Logistique")
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Or Book Via",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.qlypDeepNavy,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                _buildSocialIcon(
                                    'assets/images/ic_btn_phone.png'),
                                const SizedBox(width: 5),
                                _buildSocialIcon(
                                    'assets/images/ic_btn_sms.png'),
                                const SizedBox(width: 5),
                                _buildSocialIcon(
                                    'assets/images/ic_btn_whatsApp.png'),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        )),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField(BuildContext context,
      {required String hint,
      required TextEditingController controller,
      required Color iconColor,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, color: iconColor, size: 12),
            const SizedBox(width: 12),
            Expanded(
              // ValueListenableBuilder ensures the text updates reactively
              // whenever the TextEditingController value changes (e.g., after
              // the user picks a location from MapPickerPage).
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  return Text(
                    value.text.isEmpty ? hint : value.text,
                    style: GoogleFonts.poppins(
                      color: value.text.isEmpty
                          ? Colors.grey[400]
                          : Colors.black87,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetailsSection(
      BuildContext context, HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Details",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.qlypDeepNavy,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Obx(() => DropdownButton<String>(
                      value: controller.livraisonDeliveryType.value,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.qlypDeepNavy),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.qlypDeepNavy,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.livraisonDeliveryType.value = newValue;
                        }
                      },
                      items: <String>['Standard', 'Express', 'Fragile']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showImagePickerDialog(context, controller),
              child: Obx(() => Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: controller.livraisonParcelImage.value != null
                              ? AppColors.qlypDeepNavy
                              : Colors.transparent),
                      image: controller.livraisonParcelImage.value != null
                          ? DecorationImage(
                              image: FileImage(
                                  controller.livraisonParcelImage.value!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: controller.livraisonParcelImage.value == null
                        ? const Icon(Icons.add_a_photo_outlined,
                            size: 24, color: AppColors.qlypDeepNavy)
                        : null,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showImagePickerDialog(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select an image".tr,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera".tr,
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    if (image != null) {
                      controller.livraisonParcelImage.value = File(image.path);
                    }
                  },
                ),
                _pickerOption(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery".tr,
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      controller.livraisonParcelImage.value = File(image.path);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _pickerOption(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.qlypDeepNavy.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.qlypDeepNavy, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLogistiqueDetailsSection(
      BuildContext context, HomeController controller) {
    const inputDecoration = InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF1A2340), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );

    final floorOptions = [
      "Ground floor",
      "1st Floor",
      "2nd Floor",
      "3rd Floor",
      "4th Floor",
      "5th Floor",
      "6th Floor+",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section 1: Location details ──────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.home_outlined,
                      size: 20, color: Color(0xFF1A2340)),
                  const SizedBox(width: 8),
                  Text(
                    "Location details",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2340),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Nombre de pièces
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Number of rooms",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          "Includes living room, bedrooms, kitchen",
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => Row(
                        children: [
                          // Minus
                          GestureDetector(
                            onTap: () {
                              if (controller.logistiqueRoomCount.value > 1) {
                                controller.logistiqueRoomCount.value--;
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.remove, size: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              "${controller.logistiqueRoomCount.value}",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          // Plus
                          GestureDetector(
                            onTap: () => controller.logistiqueRoomCount.value++,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2340),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
              const SizedBox(height: 18),

              // Ascenseur + Étage
              Row(
                children: [
                  // Ascenseur toggle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Elevator",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 6),
                        Obx(() => Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _elevatorToggleChip(
                                    label: "No",
                                    selected:
                                        !controller.logistiqueHasElevator.value,
                                    onTap: () => controller
                                        .logistiqueHasElevator.value = false,
                                  ),
                                  _elevatorToggleChip(
                                    label: "Yes",
                                    selected:
                                        controller.logistiqueHasElevator.value,
                                    onTap: () => controller
                                        .logistiqueHasElevator.value = true,
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Étage dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Floor",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 6),
                        Obx(() => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: floorOptions.contains(
                                          controller.logistiqueFloor.value)
                                      ? controller.logistiqueFloor.value
                                      : floorOptions.first,
                                  isDense: true,
                                  isExpanded: true,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, color: Colors.black87),
                                  items: floorOptions
                                      .map((f) => DropdownMenuItem(
                                          value: f, child: Text(f)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      controller.logistiqueFloor.value = v;
                                    }
                                  },
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Section 2: Load estimation ──────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.scale_outlined,
                      size: 20, color: Color(0xFF1A2340)),
                  const SizedBox(width: 8),
                  Text(
                    "Load estimation",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2340),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Poids + Dimensions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poids
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WEIGHT (KG)",
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.logistiqueWeight,
                          keyboardType: TextInputType.number,
                          decoration: inputDecoration.copyWith(
                              hintText: "0",
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade400)),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dimensions
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DIMENSIONS L X W X H (CM)",
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.logistiqueDimL,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration,
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text("x",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500)),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: controller.logistiqueDimW,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration,
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text("x",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500)),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: controller.logistiqueDimH,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration,
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: controller.logistiqueDescription,
                maxLines: 3,
                decoration: inputDecoration.copyWith(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  hintText:
                      "Description of items (ex: Piano, large fragile mirror, 10 boxes of books...)",
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF1A2340), width: 1.5)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Section 3: Pickup date ──────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_outlined,
                    size: 22, color: Color(0xFFE6A817)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PICKUP DATE",
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final d = controller.logistiquePickupDate.value;
                      final now = DateTime.now();
                      final isToday = d.year == now.year &&
                          d.month == now.month &&
                          d.day == now.day;
                      final label = isToday
                          ? "Today, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}"
                          : "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
                      return Text(
                        label,
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      );
                    }),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: controller.logistiquePickupDate.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.qlypDeepNavy,
                          onPrimary: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        dialogBackgroundColor: Colors.white,
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.qlypDeepNavy,
                          ),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          controller.logistiquePickupDate.value),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.qlypDeepNavy,
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                          dialogBackgroundColor: Colors.white,
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.qlypDeepNavy,
                            ),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (pickedTime != null) {
                      controller.logistiquePickupDate.value = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_calendar_outlined,
                      size: 20, color: AppColors.qlypDeepNavy),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _elevatorToggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A2340) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String imagePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Image.asset(
        imagePath,
        width: 34,
        height: 34,
        fit: BoxFit.cover, // e.g., cover, contain, fill
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Warning"),
      content: const Text(
          "You are not able book new ride please complete previous ride payment"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _buildEstimatedFareCard(HomeController controller) {
    return Obx(() {
      bool hasLocations =
          controller.sourceLocationController.value.text.isNotEmpty &&
              controller.destinationLocationController.value.text.isNotEmpty;

      if (!hasLocations &&
          (controller.amount.value.isEmpty ||
              controller.amount.value == "0.0" ||
              controller.amount.value == "0")) {
        return const SizedBox.shrink();
      }

      String displayAmount = controller.amount.value.isEmpty ||
              controller.amount.value == "0.0" ||
              controller.amount.value == "0"
          ? "---"
          : Constant.amountShow(amount: controller.amount.value);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.qlypDeepNavy.withOpacity(0.8),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: Colors.black, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ESTIMATED".tr,
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "Based on distance".tr,
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              displayAmount,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    });
  }

  /*
  // PRESERVED ORIGINAL FUNCTIONALITY (COMMENTED OUT AS REQUESTED)
  
  // Originally in build method:
  // Scaffold(
  //   backgroundColor: AppColors.lightprimary,
  //   body: controller.isLoading.value
  //       ? Constant.loader(isDarkTheme: themeChange.getThem())
  //       : SafeArea(
  //           child: Column(
  //             children: [
  //               SizedBox(
  //                 height: Responsive.width(22, context),
  //                 width: Responsive.width(100, context),
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 10),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(controller.userModel.value.fullName.toString(),
  //                           style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 1)),
  //                       const SizedBox(height: 4),
  //                       Row(
  //                         children: [
  //                           SvgPicture.asset('assets/icons/ic_location.svg', width: 16),
  //                           const SizedBox(width: 10),
  //                           Expanded(child: Text(controller.currentLocation.value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400))),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Container(
  //                   decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
  //                   child: Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 10),
  //                     child: SingleChildScrollView(
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(top: 10),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             // Banners, Location selection, Vehicle type, AC/Non-AC switch, Offer rate, Payment method, etc.
  //                             // ButtonThem.buildButton(context, title: "Book Ride".tr, onPress: () async { ... booking logic ... }),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //   floatingActionButton: FloatingActionButton(onPressed: () { ariPortDialog(context, controller, true); }, ...),
  // );

  // someOneTakingDialog(BuildContext context, HomeController controller) {
  //   showModalBottomSheet(context: context, builder: (context) {
  //     return Column(children: [
  //       ListTile(title: Text("Myself"), onTap: () { controller.selectedTakingRide.value = ContactModel(fullName: "Myself"); Get.back(); }),
  //       ListTile(title: Text("Choose from contacts"), onTap: () async { ... contact picker ... }),
  //     ]);
  //   });
  // }
  
  // paymentMethodDialog(BuildContext context, HomeController controller) {
  //   showModalBottomSheet(context: context, builder: (context) {
  //     return ListView(children: [ ... payment methods ... ]);
  //   });
  // }
  
  // ariPortDialog(BuildContext context, HomeController controller, bool isSource) {
  //   showDialog(context: context, builder: (context) {
  //     return AlertDialog(title: Text("Select Airport"), content: ...);
  //   });
  // }
  */

  Widget _buildModernBookingOptionsRow(HomeController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Now / Later toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F8), // Light grey background
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildModernToggleChip(
                  icon: Icons.flash_on,
                  label: "Now",
                  isSelected: true,
                  onTap: () {},
                ),
                _buildModernToggleChip(
                  icon: Icons.access_time,
                  label: "Later",
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Person / Luggage card
          _buildPersonLuggageCard(controller),
        ],
      ),
    );
  }

  Widget _buildModernToggleChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isSelected
                    ? AppColors.qlypDeepNavy
                    : const Color(0xFF6B7B8A)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected
                    ? AppColors.qlypDeepNavy
                    : const Color(0xFF6B7B8A),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonLuggageCard(HomeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE0E5EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPersonIconAndCount(controller),
          Container(
            height: 20,
            width: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFFE0E5EA),
          ),
          const Icon(Icons.work_outline, size: 20, color: Color(0xFF4B5A6A)),
        ],
      ),
    );
  }

  Widget _buildPersonIconAndCount(HomeController controller) {
    return PopupMenuButton<int>(
      onSelected: (int value) {
        controller.personCount.value = value;
      },
      child: Row(
        children: [
          const Icon(Icons.person, size: 20, color: Color(0xFF4B5A6A)),
          const SizedBox(width: 8),
          Obx(() => Text(
                controller.personCount.value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4B5A6A),
                ),
              )),
        ],
      ),
      itemBuilder: (BuildContext context) => [1, 2, 3, 4]
          .map((int value) => PopupMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              ))
          .toList(),
    );
  }
}
