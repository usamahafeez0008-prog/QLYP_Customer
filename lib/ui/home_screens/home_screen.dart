import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/home_controller.dart';
import 'package:customer/model/admin_commission.dart';
import 'package:customer/model/airport_model.dart';
import 'package:customer/model/contact_model.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/order/positions.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/service_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:customer/widget/geoflutterfire/src/models/point.dart';
import 'package:customer/widget/osm_map/map_picker_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // -------------------- QLYP UI helpers --------------------

  static Widget _dot(Color color, double size) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color),
      );

  static BoxDecoration _glass({
    double radius = 18,
    Color? color,
    Color? borderColor,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: color ??
          AppColors.qlypCharcoal.withOpacity(0.55),
      border: Border.all(
        color: borderColor ??
            AppColors.qlypPrimaryFreshGreen
                .withOpacity(0.10),
        width: 1.2,
      ),
      boxShadow: shadow ??
          [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.28),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
    );
  }

  static Widget _qlypPrimaryButton(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    IconData? icon,
    bool enabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.qlypSecondaryWarmSand,
                  AppColors.qlypPrimarySunYellow,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.qlypPrimarySunYellow
                      .withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors
                      .qlypSecondaryWarmSand
                      .withOpacity(0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.qlypCharcoal,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 10),
                    Icon(icon,
                        color: AppColors.qlypCharcoal,
                        size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) =>
      Text(
        text.tr,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.qlypPrimaryFreshGreen
              .withOpacity(0.95),
          letterSpacing: -0.2,
        ),
      );

  static Widget _subtleText(String text) => Text(
        text.tr,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: AppColors.qlypPrimaryFreshGreen
              .withOpacity(0.70),
        ),
      );

  Widget _qlypPickerRow({
    required IconData leftIcon,
    required Color leftColor,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onAirportTap,
    bool showAirport = false,

    // ✅ new
    Widget? valueWidget,
    String?
        value, // keep old param if you still use it elsewhere
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            14, 12, 10, 12),
        child: Row(
          children: [
            Icon(leftIcon,
                size: 18, color: leftColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors
                          .qlypPrimaryFreshGreen
                          .withOpacity(0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // ✅ use ValueListenableBuilder output if provided
                  valueWidget ??
                      Text(
                        value ?? "",
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            GoogleFonts.poppins(
                          fontSize: 13.5,
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
          /*  if (showAirport)
              InkWell(
                onTap: onAirportTap,
                child: Icon(
                  Icons.flight_takeoff,
                  size: 18,
                  color: AppColors
                      .qlypPrimaryLight
                      .withOpacity(0.8),
                ),
              ),*/
          ],
        ),
      ),
    );
  }

  static Widget _qlypSelectTile({
    required Widget leading,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: _glass(
            radius: 16,
            color: AppColors.qlypCharcoal
                .withOpacity(0.65)),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors
                      .qlypPrimaryFreshGreen
                      .withOpacity(0.88),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down_outlined,
                color: AppColors.qlypPrimaryFreshGreen
                    .withOpacity(0.65)),
          ],
        ),
      ),
    );
  }

  // -------------------- Screen --------------------

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    return GetX<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: controller.isLoading.value
              ? Constant.loader(isDarkTheme: isDark)
              : Stack(
            children: [
              // ✅ FULL BACKGROUND MAP
              Positioned.fill(
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  initialCameraPosition: CameraPosition(
                    zoom: 14,
                    target: LatLng(
                      Constant.currentLocation != null
                          ? Constant.currentLocation!.latitude
                          : 31.506432,
                      Constant.currentLocation != null
                          ? Constant.currentLocation!.longitude
                          : 74.3276544,
                    ),
                  ),
                  onMapCreated: (GoogleMapController mapController) {},
                ),
              ),

              // ✅ Small dark overlay for contrast
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.10),
                ),
              ),

              // ✅ ONE scrollable card (bottom sheet style)
              DraggableScrollableSheet(
                initialChildSize: 0.62,
                minChildSize: 0.50,
                maxChildSize: 0.92,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.qlypPrimarySunYellow,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(26),
                        topRight: Radius.circular(26),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 24,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: buildScrollableCardContent(
                              context: context,
                              controller: controller,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget qlypModernServiceCard({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String subtitle,
    required String priceText,
    required Widget imageWidget, // Image.asset(...) or CachedNetworkImage(...)
    required VoidCallback onTap,
  }) {
    // Card colors inspired by your 2nd screenshot
    final bg = const Color(0xFFF6E6B6); // warm cream
    final textDark = const Color(0xFF1A1A1A);
    final muted = const Color(0xFF5F5F5F);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: Responsive.width(58, context), // adjust to fit your list
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected
                ? AppColors.qlypPrimarySunYellow // selected outline
                : Colors.black.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.25 : 0.14),
              blurRadius: isSelected ? 28 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Arrow button bottom-right
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC83D),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.arrow_outward_rounded, color: Colors.black, size: 22),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),

                // Big image area
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: Responsive.height(10.5, context),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: imageWidget,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: muted.withOpacity(0.80),
                  ),
                ),
                const SizedBox(height: 10),

                // Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      priceText,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        "/ Per Day",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: muted.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  /// ✅ THIS IS A CLASS METHOD (no more "referenced before declared" issue)
  Widget buildScrollableCardContent({
    required BuildContext context,
    required HomeController controller,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Where you want to go?".tr,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.qlypPrimaryFreshGreen,
          ),
        ),
        const SizedBox(height: 10),

        //  PICKUP / DROPOFF BLOCK (YOUR LOGIC KEPT)
        Obx(() {
          final hasSource = controller.sourceLocationLAtLng.value.latitude != null;

          // ---------------- BEFORE SOURCE PICKED ----------------
          if (!hasSource) {
            return InkWell(
              onTap: () async {
                // ✅ SAME LOGIC AS YOUR OLD CODE (copied exactly)
                print("::::::::::22::::::::::::");
                if (Constant.selectedMapType == 'osm') {
                  final result = await Get.to(() => MapPickerPage());
                  if (result != null) {
                    final firstPlace = result;
                    final lat = firstPlace.coordinates.latitude;
                    final lng = firstPlace.coordinates.longitude;
                    final address = firstPlace.address;

                    controller.sourceLocationController.value.text = address;
                    controller.sourceLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                    // Selected Zone
                    for (int i = 0; i < controller.zoneList.length; i++) {
                      if (Constant.isPointInPolygon(
                        LatLng(
                          double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                          double.parse(controller.sourceLocationLAtLng.value.longitude.toString()),
                        ),
                        controller.zoneList[i].area!,
                      )) {
                        controller.selectedZone.value = controller.zoneList[i];
                      }
                    }

                    // Serviceid and Zoneid to set controller.selectedType.value.price
                    if (controller.selectedZone.value.id?.isNotEmpty == true) {
                      Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                            (price) => price.zoneId == controller.selectedZone.value.id,
                        orElse: () => Price(),
                      );
                      if (selectedPrice?.zoneId != null) {
                        controller.selectedType.value.prices = [selectedPrice!];
                        log("SelectedPrice :: ${controller.selectedType.value.prices?.length}");
                      }
                    }

                    await controller.calculateDurationAndDistance();
                    controller.calculateAmount();
                  }
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                        apiKey: Constant.mapAPIKey,
                        onPlacePicked: (result) async {
                          Get.back();

                          controller.sourceLocationController.value.text = result.formattedAddress.toString();
                          controller.sourceLocationLAtLng.value = LocationLatLng(
                            latitude: result.geometry!.location.lat,
                            longitude: result.geometry!.location.lng,
                          );

                          // Selected Zone
                          for (int i = 0; i < controller.zoneList.length; i++) {
                            if (Constant.isPointInPolygon(
                              LatLng(
                                double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                                double.parse(controller.sourceLocationLAtLng.value.longitude.toString()),
                              ),
                              controller.zoneList[i].area!,
                            )) {
                              controller.selectedZone.value = controller.zoneList[i];
                            }
                          }

                          // Serviceid and Zoneid to set controller.selectedType.value.price
                          if (controller.selectedZone.value.id?.isNotEmpty == true) {
                            Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                                  (price) => price.zoneId == controller.selectedZone.value.id,
                              orElse: () => Price(),
                            );
                            if (selectedPrice?.zoneId != null) {
                              controller.selectedType.value.prices = [selectedPrice!];
                              log("SelectedPrice :: ${controller.selectedType.value.prices?.length}");
                            }
                          }

                          await controller.calculateDurationAndDistance();
                          controller.calculateAmount();
                        },
                        region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                        initialPosition: const LatLng(-33.8567844, 151.213108),
                        useCurrentLocation: true,
                        autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                            ? [Component(Component.country, Constant.regionCode)]
                            : [],
                        selectInitialPosition: true,
                        usePinPointingSearch: true,
                        usePlaceDetailSearch: true,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: true,
                        resizeToAvoidBottomInset: false,
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: _glass(radius: 16, color: AppColors.qlypCharcoal.withOpacity(0.70)),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.9),
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enter Your Current Location'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.85),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.my_location_rounded,
                      size: 18,
                      color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.75),
                    ),
                  ],
                ),
              ),
            );
          }

          // ---------------- AFTER SOURCE PICKED (WHITE CARD UI) ----------------
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                // PICKUP
                InkWell(
                  onTap: () async {
                    print("::::::::::33::::::::::::");
                    if (Constant.selectedMapType == 'osm') {
                      final result = await Get.to(() => MapPickerPage());
                      if (result != null) {
                        final firstPlace = result;
                        final lat = firstPlace.coordinates.latitude;
                        final lng = firstPlace.coordinates.longitude;
                        final address = firstPlace.address;

                        controller.sourceLocationController.value.text = address.toString();
                        controller.sourceLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                        await controller.calculateDurationAndDistance();
                        controller.calculateAmount();
                      }
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlacePicker(
                            apiKey: Constant.mapAPIKey,
                            onPlacePicked: (result) async {
                              Get.back();
                              controller.sourceLocationController.value.text = result.formattedAddress.toString();
                              controller.sourceLocationLAtLng.value = LocationLatLng(
                                latitude: result.geometry!.location.lat,
                                longitude: result.geometry!.location.lng,
                              );
                              await controller.calculateDurationAndDistance();
                              controller.calculateAmount();
                            },
                            region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                            initialPosition: const LatLng(-33.8567844, 151.213108),
                            useCurrentLocation: true,
                            autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                ? [Component(Component.country, Constant.regionCode)]
                                : [],
                            selectInitialPosition: true,
                            usePinPointingSearch: true,
                            usePlaceDetailSearch: true,
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: true,
                            resizeToAvoidBottomInset: false,
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                    child: Row(
                      children: [
                        Icon(Icons.radio_button_unchecked, size: 18, color: Colors.black.withOpacity(0.75)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller.sourceLocationController.value,
                            builder: (context, v, _) {
                              final text = v.text.trim();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pick-up Location'.tr,
                                      style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(text.isEmpty ? "Select pickup".tr : text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.90))),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Divider(height: 1, thickness: 1, color: Colors.black.withOpacity(0.08)),

                // DROP OFF
                InkWell(
                  onTap: () async {
                    print("::::::::::11::::::::::::");
                    if (Constant.selectedMapType == 'osm') {
                      final result = await Get.to(() => MapPickerPage());
                      if (result != null) {
                        final firstPlace = result;
                        final lat = firstPlace.coordinates.latitude;
                        final lng = firstPlace.coordinates.longitude;
                        final address = firstPlace.address;

                        controller.destinationLocationController.value.text = address.toString();
                        controller.destinationLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                        await controller.calculateDurationAndDistance();
                        controller.calculateAmount();
                      }
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlacePicker(
                            apiKey: Constant.mapAPIKey,
                            onPlacePicked: (result) async {
                              Get.back();
                              controller.destinationLocationController.value.text = result.formattedAddress.toString();
                              controller.destinationLocationLAtLng.value = LocationLatLng(
                                latitude: result.geometry!.location.lat,
                                longitude: result.geometry!.location.lng,
                              );
                              await controller.calculateDurationAndDistance();
                              controller.calculateAmount();
                            },
                            region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                            initialPosition: const LatLng(-33.8567844, 151.213108),
                            useCurrentLocation: true,
                            autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                ? [Component(Component.country, Constant.regionCode)]
                                : [],
                            selectInitialPosition: true,
                            usePinPointingSearch: true,
                            usePlaceDetailSearch: true,
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: true,
                            resizeToAvoidBottomInset: false,
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: Colors.black.withOpacity(0.75)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller.destinationLocationController.value,
                            builder: (context, v, _) {
                              final text = v.text.trim();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Drop-off Location'.tr,
                                      style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(text.isEmpty ? "Select drop-off".tr : text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.90))),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(
            height:
            18),

        // ================= SERVICE TYPES (Taxi / Logistics / B2B) =================
        const SizedBox(
            height:
            18),
        Text(
          "Service Types"
              .tr,
          style: GoogleFonts
              .poppins(
            fontWeight:
            FontWeight.w700,
            fontSize:
            15,
            color: AppColors
                .qlypPrimaryFreshGreen
                .withOpacity(0.9),
          ),
        ),
        const SizedBox(
            height:
            10),

        SizedBox(
          height: Responsive
              .height(
              18,
              context),
          child: ListView
              .separated(
            scrollDirection:
            Axis.horizontal,
            itemCount:
            2,
            separatorBuilder:
                (_, __) =>
            const SizedBox(width: 10),
            itemBuilder:
                (context,
                index) {
              final items =
              [
                {
                  "title": "Taxi",
                  "asset": "assets/icons/ic_taxi.png",
                },
                {
                  "title": "Logistics",
                  "asset": "assets/icons/ic_logistics.png",
                },

              ];

              final item =
              items[index];

              return Obx(
                      () {
                    final isSelected =
                        controller.selectedServiceCategory.value == item["title"];

                    return InkWell(
                      onTap: () { controller.selectedServiceCategory.value = item["title"]!; },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: Responsive.width(43, context),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isSelected ? AppColors.qlypSecondaryWarmSand.withOpacity(0.18) : AppColors.qlypCharcoal.withOpacity(0.55),
                          border: Border.all(
                            color: isSelected ? AppColors.qlypSecondaryWarmSand.withOpacity(0.95) : AppColors.qlypPrimaryFreshGreen.withOpacity(0.10),
                            width: 1.4,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppColors.qlypSecondaryWarmSand.withOpacity(0.30),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ] : [],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.qlypCharcoal.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.08),
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                item["asset"]!,
                                height: Responsive.height(7.5, context),
                                width: Responsive.width(18, context),
                                fit: BoxFit.contain,
                                color: item["title"]!.tr == "B2B" ? Colors.white : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item["title"]!.tr,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.qlypPrimaryFreshGreen : AppColors.qlypPrimaryFreshGreen.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            },
          ),
        ),

        const SizedBox(
            height:
            18),

        _sectionTitle(
            "Select Vehicle"),
        const SizedBox(
            height:
            8),

        //  Service list (same selection logic, QLYP look)
        SizedBox(
          height: Responsive
              .height(
              18,
              context),
          child: ListView
              .builder(
            itemCount: controller
                .serviceList
                .length,
            scrollDirection:
            Axis.horizontal,
            shrinkWrap:
            true,
            itemBuilder:
                (context,
                index) {
              final serviceModel =
              controller.serviceList[index];
              return Obx(
                      () {
                    final isSelected =
                        controller.selectedType.value == serviceModel;
                    return InkWell(
                      onTap: () {
                        controller.selectedType.value = serviceModel;
                        Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                              (price) => price.zoneId == controller.selectedZone.value.id,
                          orElse: () => Price(),
                        );
                        if (selectedPrice?.zoneId != null) {
                          controller.selectedType.value.prices = [
                            selectedPrice!
                          ];
                        }
                        controller.calculateAmount();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          width: Responsive.width(42, context),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected ? AppColors.qlypSecondaryWarmSand.withOpacity(0.18) : AppColors.qlypCharcoal.withOpacity(0.55),
                            border: Border.all(
                              color: isSelected ? AppColors.qlypSecondaryWarmSand : AppColors.qlypPrimaryFreshGreen.withOpacity(0.10),
                              width: 1.4,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: AppColors.qlypSecondaryWarmSand.withOpacity(0.30),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ]
                                : [],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.qlypCharcoal.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.08)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: serviceModel.image.toString(),
                                      fit: BoxFit.contain,
                                      height: Responsive.height(7.5, context),
                                      width: Responsive.width(18, context),
                                      placeholder: (context, url) => Constant.loader(isDarkTheme: isDark),
                                      errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  Constant.localizationTitle(serviceModel.title),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.qlypPrimaryFreshGreen : AppColors.qlypPrimaryFreshGreen.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
        ),

        // ✅ Price summary (same logic, styled)
        Obx(() {
          final ok = controller.sourceLocationLAtLng.value.latitude != null &&
              controller.destinationLocationLAtLng.value.latitude !=
                  null &&
              controller
                  .amount
                  .value
                  .isNotEmpty;
          if (!ok)
            return const SizedBox
                .shrink();

          return Padding(
            padding: const EdgeInsets
                .only(
                top:
                12),
            child:
            Container(
              width:
              double.infinity,
              decoration: _glass(
                  radius: 18,
                  color: AppColors.qlypCharcoal.withOpacity(0.45)),
              padding: const EdgeInsets
                  .all(
                  14),
              child:
              Text(
                controller.selectedType.value.offerRate == true
                    ? 'Recommended Price is ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}'.tr
                    : 'Your Price is ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}'.tr,
                style:
                GoogleFonts.poppins(
                  color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.85),
                  fontSize: 12.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),

        const SizedBox(
            height:
            12),

        // ✅ AC toggle (same logic)
        if (controller
            .selectedType
            .value
            .prices?[0]
            .isAcNonAc ==
            true)
          Obx(
                () =>
                Container(
                  decoration: _glass(
                      radius: 18,
                      color: AppColors.qlypCharcoal.withOpacity(0.40)),
                  child:
                  SwitchListTile.adaptive(
                    activeColor:
                    AppColors.qlypSecondaryWarmSand,
                    title:
                    Text(
                      'A/C'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value:
                    controller.isAcSelected.value,
                    onChanged:
                        (bool newValue) {
                      if (controller.sourceLocationLAtLng.value.latitude != null && controller.destinationLocationLAtLng.value.latitude != null && controller.amount.value.isNotEmpty) {
                        controller.isAcSelected.value = newValue;
                        controller.calculateAmount();
                      } else {
                        ShowToastDialog.showToast("Please select source and destination location".tr);
                      }
                    },
                  ),
                ),
          ),

        const SizedBox(
            height:
            12),

        // ✅ Offer rate input (same widget, themed cursor)
        Visibility(
          visible: controller
              .selectedType
              .value
              .offerRate ==
              true,
          child:
          Container(
            height:
            54,
            padding: const EdgeInsets
                .symmetric(
                horizontal:
                14),
            decoration:
            BoxDecoration(
              color: AppColors
                  .qlypCharcoal
                  .withOpacity(0.75),
              borderRadius:
              BorderRadius.circular(14),
              border:
              Border.all(
                color:
                AppColors.qlypPrimaryFreshGreen.withOpacity(0.14),
              ),
            ),
            child:
            Row(
              children: [
                Text(
                  Constant.currencyModel!.symbol.toString(),
                  style: GoogleFonts.poppins(
                    color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.85),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 22,
                  color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller.offerYourRateController.value,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9*]')),
                    ],
                    cursorColor: AppColors.qlypSecondaryWarmSand,
                    style: GoogleFonts.poppins(
                      color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.95),
                      // ✅ visible text
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your offer rate".tr,
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.40),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),



        const SizedBox(
            height:
            12),

        // ✅ Someone taking (same logic)
        _qlypSelectTile(
          leading: Icon(
              Icons
                  .person,
              color: AppColors
                  .qlypPrimaryFreshGreen
                  .withOpacity(0.85)),
          text: controller.selectedTakingRide.value.fullName ==
              "Myself"
              ? "Myself"
              .tr
              : controller
              .selectedTakingRide
              .value
              .fullName
              .toString(),
          onTap: () => someOneTakingDialog(
              context,
              controller),
        ),

        const SizedBox(
            height:
            12),

        // ✅ Payment method (same logic)
        _qlypSelectTile(
          leading: SvgPicture.asset(
              'assets/icons/ic_payment.svg',
              width:
              24,
              color:
              AppColors.qlypSecondaryWarmSand),
          text: controller
              .selectedPaymentMethod
              .value
              .isNotEmpty
              ? controller
              .selectedPaymentMethod
              .value
              : "Select Payment type"
              .tr,
          onTap: () => paymentMethodDialog(
              context,
              controller),
        ),

        const SizedBox(
            height:
            14),

        // ✅ Book Ride button (same onPress logic)
        qlypBookRidePillButton(
          context: context,
          title: "Book Ride".tr,
          priceText: controller.amount.value.isNotEmpty
              ? Constant.amountShow(amount: controller.amount.value)
              : "${Constant.currencyModel?.symbol ?? ''}0",
          onTap:
              () async {
            bool
            isPaymentNotCompleted =
            await FireStoreUtils.paymentStatusCheck();
            if (controller
                .selectedPaymentMethod
                .value
                .isEmpty) {
              ShowToastDialog.showToast(
                  "Please select Payment Method".tr);
            } else if (controller
                .sourceLocationController
                .value
                .text
                .isEmpty) {
              ShowToastDialog.showToast(
                  "Please select source location".tr);
            } else if (controller
                .destinationLocationController
                .value
                .text
                .isEmpty) {
              ShowToastDialog.showToast(
                  "Please select destination location".tr);
            } else if (double.parse(controller.distance.value) <=
                2) {
              ShowToastDialog.showToast(
                  "Please select more than two ${Constant.distanceType} location".tr);
            } else if (controller.selectedType.value.offerRate ==
                true &&
                controller.offerYourRateController.value.text.isEmpty) {
              ShowToastDialog.showToast(
                  "Please Enter offer rate".tr);
            } else if (isPaymentNotCompleted) {
              showAlertDialog(
                  context);
            } else {
              ShowToastDialog.showLoader(
                  "Please wait");
              OrderModel
              orderModel =
              OrderModel();
              orderModel.id =
                  Constant.getUuid();
              orderModel.userId =
                  FireStoreUtils.getCurrentUid();
              orderModel.sourceLocationName = controller
                  .sourceLocationController
                  .value
                  .text;
              orderModel.destinationLocationName = controller
                  .destinationLocationController
                  .value
                  .text;
              orderModel.sourceLocationLAtLng = controller
                  .sourceLocationLAtLng
                  .value;
              orderModel.destinationLocationLAtLng = controller
                  .destinationLocationLAtLng
                  .value;
              orderModel.distance = controller
                  .distance
                  .value;
              orderModel.acNonAcCharges =
              '';
              orderModel.duration = controller
                  .duration
                  .value;
              orderModel.distanceType =
                  Constant.distanceType;
              orderModel
                  .offerRate = controller.selectedType.value.offerRate ==
                  true
                  ? controller.offerYourRateController.value.text
                  : controller.amount.value;
              orderModel.serviceId = controller
                  .selectedType
                  .value
                  .id;

              GeoFirePoint
              position =
              Geoflutterfire().point(
                latitude:
                controller.sourceLocationLAtLng.value.latitude!,
                longitude:
                controller.sourceLocationLAtLng.value.longitude!,
              );

              orderModel.position = Positions(
                  geoPoint: position.geoPoint,
                  geohash: position.hash);
              orderModel.createdDate =
                  Timestamp.now();
              orderModel.status =
                  Constant.ridePlaced;
              orderModel.paymentType = controller
                  .selectedPaymentMethod
                  .value;
              orderModel.paymentStatus =
              false;
              orderModel.service = controller
                  .selectedType
                  .value;

              AdminCommission?
              adminCommissionGlobal;
              if (Constant.adminCommission?.isEnabled !=
                  true) {
                adminCommissionGlobal =
                    Constant.adminCommission ?? AdminCommission();
                adminCommissionGlobal.amount =
                '0';
              }

              log("controller.selectedType.value.adminCommission?.isEnabled :: ${controller.selectedType.value.adminCommission?.isEnabled} :: ${Constant.adminCommission?.isEnabled}");

              orderModel
                  .adminCommission = controller.selectedType.value.adminCommission?.isEnabled ==
                  false
                  ? controller.selectedType.value.adminCommission!
                  : Constant.adminCommission?.isEnabled == false
                  ? adminCommissionGlobal
                  : Constant.adminCommission;

              orderModel.otp =
                  Constant.getReferralCode();
              orderModel
                  .isAcSelected = controller.selectedType.value.prices?[0].isAcNonAc ==
                  true
                  ? controller.isAcSelected.value
                  : false;
              orderModel.taxList =
                  Constant.taxList;

              if (controller.selectedTakingRide.value.fullName !=
                  "Myself") {
                orderModel.someOneElse =
                    controller.selectedTakingRide.value;
              }

              for (int i = 0;
              i < controller.zoneList.length;
              i++) {
                if (Constant.isPointInPolygon(
                  LatLng(
                    double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                    double.parse(controller.sourceLocationLAtLng.value.longitude.toString()),
                  ),
                  controller.zoneList[i].area!,
                ) ==
                    true) {
                  controller.selectedZone.value = controller.zoneList[i];
                  break;
                }
              }

              if (controller.selectedZone.value.id !=
                  null) {
                orderModel.zoneId =
                    controller.selectedZone.value.id;
                orderModel.zone =
                    controller.selectedZone.value;

                await FireStoreUtils().sendOrderDataFuture(orderModel).then((eventData) async {
                  for (var driver in eventData) {
                    if (driver.fcmToken != null) {
                      Map<String, dynamic> playLoad = <String, dynamic>{
                        "type": "city_order",
                        "orderId": orderModel.id
                      };
                      await SendNotification.sendOneNotification(
                        token: driver.fcmToken.toString(),
                        title: 'New Ride Available'.tr,
                        body: 'A customer has placed a ride near your location.'.tr,
                        payload: playLoad,
                      );
                    }
                  }
                });

                await FireStoreUtils.setOrder(orderModel).then((value) {
                  ShowToastDialog.showToast("Ride Placed successfully".tr);
                  controller.dashboardController.selectedDrawerIndex(2);
                  ShowToastDialog.closeLoader();
                });
              } else {
                ShowToastDialog.closeLoader();
                ShowToastDialog.showToast(
                  "Services are currently unavailable on the selected location. Please reach out to the administrator for assistance.",
                );
                return;
              }
            }
          },
        ),

        const SizedBox(
            height:
            12),


        const SizedBox(height: 20),
      ],
    );
  }


  static Widget qlypBookRidePillButton({
    required BuildContext context,
    required String priceText, // e.g. Constant.amountShow(amount: controller.amount.value)
    required String title, // "Book Ride"
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final pillRadius = 28.0;

    return SizedBox(
      height: 64,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Main pill button (with left cut feeling by padding for badge)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(pillRadius),
                onTap: enabled ? onTap : null,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(pillRadius),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.qlypSecondaryWarmSand,
                        AppColors.qlypPrimarySunYellow,
                      ],
                    ),

                    border: Border.all(
                      color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 96, right: 18),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.qlypPrimaryFreshGreen,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Left price badge (overlapping)
          Positioned(
            left: 6,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: AppColors.qlypPrimaryFreshGreen,
                borderRadius: BorderRadius.circular(1050),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
                border: Border.all(
                  color: AppColors.qlypSecondaryWarmSand.withOpacity(0.35),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  priceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.qlypCharcoal,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
          ),

          // Optional little connector bump (creates that “joined” look)
          Positioned(
            left: 72,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.qlypSecondaryWarmSand,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.qlypSecondaryWarmSand.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



/*
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    // ✅ height of the top area where map should appear
    final double mapAreaHeight = MediaQuery.of(context).size.height * 0.42;

    return GetX<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: controller.isLoading.value
              ? Constant.loader(isDarkTheme: isDark)
              : Stack(
            children: [
              // ============================================================
              // ✅ 1) MAP IN BACKGROUND (TOP AREA) - MUST BE FIRST CHILD
              // ============================================================
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: mapAreaHeight,
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                  },
                  initialCameraPosition: CameraPosition(
                    zoom: 14,
                    target: LatLng(
                      Constant.currentLocation != null ? Constant.currentLocation!.latitude : 31.5204,
                      Constant.currentLocation != null ? Constant.currentLocation!.longitude : 74.3587,
                    ),
                  ),
                  onMapCreated: (GoogleMapController mapController) {
                    // keep minimal
                  },
                ),
              ),

              // ✅ Optional: soft dark overlay on map to match theme
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: mapAreaHeight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ============================================================
              // ✅ 2) GRADIENT BG BELOW MAP ONLY (so map stays visible!)
              // ============================================================
              Positioned.fill(
                child: Column(
                  children: [
                    SizedBox(height: mapAreaHeight),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.qlypDeepPurple.withOpacity(0.98),
                              AppColors.qlypDark,
                              AppColors.qlypDark.withOpacity(0.95),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // ✅ 4) MAIN CONTENT (STARTS BELOW MAP)
              // ============================================================
              SafeArea(
                child: Column(
                  children: [
                    // ✅ push content below the map area
                    SizedBox(height: mapAreaHeight - 10),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            Text(
                              "Where you want to go?".tr,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppColors.qlypPrimaryLight.withOpacity(0.95),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // ======================================================
                            //  PICKUP / DROPOFF BLOCK (YOUR LOGIC KEPT)
                            // ======================================================
                            Obx(() {
                              final hasSource = controller.sourceLocationLAtLng.value.latitude != null;

                              // ---------------- BEFORE SOURCE PICKED ----------------
                              if (!hasSource) {
                                return InkWell(
                                  onTap: () async {
                                    // ✅ SAME LOGIC AS YOUR OLD CODE (copied exactly)
                                    print("::::::::::22::::::::::::");
                                    if (Constant.selectedMapType == 'osm') {
                                      final result = await Get.to(() => MapPickerPage());
                                      if (result != null) {
                                        final firstPlace = result;
                                        final lat = firstPlace.coordinates.latitude;
                                        final lng = firstPlace.coordinates.longitude;
                                        final address = firstPlace.address;

                                        controller.sourceLocationController.value.text = address;
                                        controller.sourceLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                                        // Selected Zone
                                        for (int i = 0; i < controller.zoneList.length; i++) {
                                          if (Constant.isPointInPolygon(
                                            LatLng(
                                              double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                                              double.parse(controller.sourceLocationLAtLng.value.longitude.toString()),
                                            ),
                                            controller.zoneList[i].area!,
                                          )) {
                                            controller.selectedZone.value = controller.zoneList[i];
                                          }
                                        }

                                        // Serviceid and Zoneid to set controller.selectedType.value.price
                                        if (controller.selectedZone.value.id?.isNotEmpty == true) {
                                          Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                                                (price) => price.zoneId == controller.selectedZone.value.id,
                                            orElse: () => Price(),
                                          );
                                          if (selectedPrice?.zoneId != null) {
                                            controller.selectedType.value.prices = [selectedPrice!];
                                            log("SelectedPrice :: ${controller.selectedType.value.prices?.length}");
                                          }
                                        }

                                        await controller.calculateDurationAndDistance();
                                        controller.calculateAmount();
                                      }
                                    } else {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlacePicker(
                                            apiKey: Constant.mapAPIKey,
                                            onPlacePicked: (result) async {
                                              Get.back();

                                              controller.sourceLocationController.value.text = result.formattedAddress.toString();
                                              controller.sourceLocationLAtLng.value = LocationLatLng(
                                                latitude: result.geometry!.location.lat,
                                                longitude: result.geometry!.location.lng,
                                              );

                                              // Selected Zone
                                              for (int i = 0; i < controller.zoneList.length; i++) {
                                                if (Constant.isPointInPolygon(
                                                  LatLng(
                                                    double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                                                    double.parse(controller.sourceLocationLAtLng.value.longitude.toString()),
                                                  ),
                                                  controller.zoneList[i].area!,
                                                )) {
                                                  controller.selectedZone.value = controller.zoneList[i];
                                                }
                                              }

                                              // Serviceid and Zoneid to set controller.selectedType.value.price
                                              if (controller.selectedZone.value.id?.isNotEmpty == true) {
                                                Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                                                      (price) => price.zoneId == controller.selectedZone.value.id,
                                                  orElse: () => Price(),
                                                );
                                                if (selectedPrice?.zoneId != null) {
                                                  controller.selectedType.value.prices = [selectedPrice!];
                                                  log("SelectedPrice :: ${controller.selectedType.value.prices?.length}");
                                                }
                                              }

                                              await controller.calculateDurationAndDistance();
                                              controller.calculateAmount();
                                            },
                                            region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                                            initialPosition: const LatLng(-33.8567844, 151.213108),
                                            useCurrentLocation: true,
                                            autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                ? [Component(Component.country, Constant.regionCode)]
                                                : [],
                                            selectInitialPosition: true,
                                            usePinPointingSearch: true,
                                            usePlaceDetailSearch: true,
                                            zoomGesturesEnabled: true,
                                            zoomControlsEnabled: true,
                                            resizeToAvoidBottomInset: false,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    height: 54,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: _glass(radius: 16, color: AppColors.qlypDark.withOpacity(0.70)),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Enter Your Current Location'.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.qlypPrimaryLight.withOpacity(0.85),
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.my_location_rounded,
                                          size: 18,
                                          color: AppColors.qlypPrimaryLight.withOpacity(0.75),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // ---------------- AFTER SOURCE PICKED (WHITE CARD UI) ----------------
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.96),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 22,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // PICKUP
                                    InkWell(
                                      onTap: () async {
                                        print("::::::::::33::::::::::::");
                                        if (Constant.selectedMapType == 'osm') {
                                          final result = await Get.to(() => MapPickerPage());
                                          if (result != null) {
                                            final firstPlace = result;
                                            final lat = firstPlace.coordinates.latitude;
                                            final lng = firstPlace.coordinates.longitude;
                                            final address = firstPlace.address;

                                            controller.sourceLocationController.value.text = address.toString();
                                            controller.sourceLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                                            await controller.calculateDurationAndDistance();
                                            controller.calculateAmount();
                                          }
                                        } else {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey: Constant.mapAPIKey,
                                                onPlacePicked: (result) async {
                                                  Get.back();
                                                  controller.sourceLocationController.value.text = result.formattedAddress.toString();
                                                  controller.sourceLocationLAtLng.value = LocationLatLng(
                                                    latitude: result.geometry!.location.lat,
                                                    longitude: result.geometry!.location.lng,
                                                  );
                                                  await controller.calculateDurationAndDistance();
                                                  controller.calculateAmount();
                                                },
                                                region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                                                initialPosition: const LatLng(-33.8567844, 151.213108),
                                                useCurrentLocation: true,
                                                autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                    ? [Component(Component.country, Constant.regionCode)]
                                                    : [],
                                                selectInitialPosition: true,
                                                usePinPointingSearch: true,
                                                usePlaceDetailSearch: true,
                                                zoomGesturesEnabled: true,
                                                zoomControlsEnabled: true,
                                                resizeToAvoidBottomInset: false,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.radio_button_unchecked, size: 18, color: Colors.black.withOpacity(0.75)),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ValueListenableBuilder<TextEditingValue>(
                                                valueListenable: controller.sourceLocationController.value,
                                                builder: (context, v, _) {
                                                  final text = v.text.trim();
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Pick-up Location'.tr,
                                                          style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w500)),
                                                      const SizedBox(height: 2),
                                                      Text(text.isEmpty ? "Select pickup".tr : text,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.90))),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Divider(height: 1, thickness: 1, color: Colors.black.withOpacity(0.08)),

                                    // DROP OFF
                                    InkWell(
                                      onTap: () async {
                                        print("::::::::::11::::::::::::");
                                        if (Constant.selectedMapType == 'osm') {
                                          final result = await Get.to(() => MapPickerPage());
                                          if (result != null) {
                                            final firstPlace = result;
                                            final lat = firstPlace.coordinates.latitude;
                                            final lng = firstPlace.coordinates.longitude;
                                            final address = firstPlace.address;

                                            controller.destinationLocationController.value.text = address.toString();
                                            controller.destinationLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                                            await controller.calculateDurationAndDistance();
                                            controller.calculateAmount();
                                          }
                                        } else {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey: Constant.mapAPIKey,
                                                onPlacePicked: (result) async {
                                                  Get.back();
                                                  controller.destinationLocationController.value.text = result.formattedAddress.toString();
                                                  controller.destinationLocationLAtLng.value = LocationLatLng(
                                                    latitude: result.geometry!.location.lat,
                                                    longitude: result.geometry!.location.lng,
                                                  );
                                                  await controller.calculateDurationAndDistance();
                                                  controller.calculateAmount();
                                                },
                                                region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                                                initialPosition: const LatLng(-33.8567844, 151.213108),
                                                useCurrentLocation: true,
                                                autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                    ? [Component(Component.country, Constant.regionCode)]
                                                    : [],
                                                selectInitialPosition: true,
                                                usePinPointingSearch: true,
                                                usePlaceDetailSearch: true,
                                                zoomGesturesEnabled: true,
                                                zoomControlsEnabled: true,
                                                resizeToAvoidBottomInset: false,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on, size: 18, color: Colors.black.withOpacity(0.75)),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ValueListenableBuilder<TextEditingValue>(
                                                valueListenable: controller.destinationLocationController.value,
                                                builder: (context, v, _) {
                                                  final text = v.text.trim();
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Drop-off Location'.tr,
                                                          style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w500)),
                                                      const SizedBox(height: 2),
                                                      Text(text.isEmpty ? "Select drop-off".tr : text,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.90))),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(
                                height:
                                18),

                            // ================= SERVICE TYPES (Taxi / Logistics / B2B) =================
                            const SizedBox(
                                height:
                                18),
                            Text(
                              "Service Types"
                                  .tr,
                              style: GoogleFonts
                                  .poppins(
                                fontWeight:
                                FontWeight.w700,
                                fontSize:
                                15,
                                color: AppColors
                                    .qlypPrimaryLight
                                    .withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(
                                height:
                                10),

                            SizedBox(
                              height: Responsive
                                  .height(
                                  18,
                                  context),
                              child: ListView
                                  .separated(
                                scrollDirection:
                                Axis.horizontal,
                                itemCount:
                                2,
                                separatorBuilder:
                                    (_, __) =>
                                const SizedBox(width: 10),
                                itemBuilder:
                                    (context,
                                    index) {
                                  final items =
                                  [
                                    {
                                      "title": "Taxi",
                                      "asset": "assets/icons/ic_taxi.png",
                                      // ✅ replace with your asset
                                    },
                                    {
                                      "title": "Logistics",
                                      "asset": "assets/icons/ic_logistics.png",
                                      // ✅ replace with your asset
                                    },
                                    */
/* {
                                                "title": "B2B",
                                                "asset": "assets/icons/ic_b2b_1.png",
                                                // ✅ replace with your asset
                                              },*//*

                                  ];

                                  final item =
                                  items[index];

                                  //  You need ONE rx variable in controller: selectedServiceCategory
                                  // controller.selectedServiceCategory.value = "Taxi" / "Logistics" / "B2B"
                                  return Obx(
                                          () {
                                        final isSelected =
                                            controller.selectedServiceCategory.value == item["title"];

                                        return InkWell(
                                          onTap: () {
                                            controller.selectedServiceCategory.value = item["title"]!;
                                            // ✅ keep only UI selection OR call your filter logic here
                                            // controller.filterServicesByCategory(item["title"]!);
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            width: Responsive.width(43, context),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: isSelected ? AppColors.qlypSecondaryLight.withOpacity(0.18) : AppColors.qlypDark.withOpacity(0.55),
                                              border: Border.all(
                                                color: isSelected ? AppColors.qlypSecondaryLight.withOpacity(0.95) : AppColors.qlypPrimaryLight.withOpacity(0.10),
                                                width: 1.4,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                BoxShadow(
                                                  color: AppColors.qlypSecondaryLight.withOpacity(0.30),
                                                  blurRadius: 22,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ]
                                                  : [],
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.qlypDark.withOpacity(0.65),
                                                    borderRadius: BorderRadius.circular(18),
                                                    border: Border.all(
                                                      color: AppColors.qlypPrimaryLight.withOpacity(0.08),
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.all(10),
                                                  child: Image.asset(
                                                    item["asset"]!,
                                                    height: Responsive.height(7.5, context),
                                                    width: Responsive.width(18, context),
                                                    fit: BoxFit.contain,
                                                    color: item["title"]!.tr == "B2B" ? Colors.white : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  item["title"]!.tr,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected ? AppColors.qlypPrimaryLight : AppColors.qlypPrimaryLight.withOpacity(0.75),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                              ),
                            ),

                            const SizedBox(
                                height:
                                18),

                            _sectionTitle(
                                "Select Vehicle"),
                            const SizedBox(
                                height:
                                8),

                            // ✅ Service list (same selection logic, QLYP look)
                            SizedBox(
                              height: Responsive
                                  .height(
                                  18,
                                  context),
                              child: ListView
                                  .builder(
                                itemCount: controller
                                    .serviceList
                                    .length,
                                scrollDirection:
                                Axis.horizontal,
                                shrinkWrap:
                                true,
                                itemBuilder:
                                    (context,
                                    index) {
                                  final serviceModel =
                                  controller.serviceList[index];
                                  return Obx(
                                          () {
                                        final isSelected =
                                            controller.selectedType.value == serviceModel;
                                        return InkWell(
                                          onTap: () {
                                            controller.selectedType.value = serviceModel;
                                            Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                                                  (price) => price.zoneId == controller.selectedZone.value.id,
                                              orElse: () => Price(),
                                            );
                                            if (selectedPrice?.zoneId != null) {
                                              controller.selectedType.value.prices = [
                                                selectedPrice!
                                              ];
                                            }
                                            controller.calculateAmount();
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Container(
                                              width: Responsive.width(28, context),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                color: isSelected ? AppColors.qlypSecondaryLight.withOpacity(0.18) : AppColors.qlypDark.withOpacity(0.55),
                                                border: Border.all(
                                                  color: isSelected ? AppColors.qlypSecondaryLight : AppColors.qlypPrimaryLight.withOpacity(0.10),
                                                  width: 1.4,
                                                ),
                                                boxShadow: isSelected
                                                    ? [
                                                  BoxShadow(
                                                    color: AppColors.qlypSecondaryLight.withOpacity(0.30),
                                                    blurRadius: 22,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ]
                                                    : [],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: AppColors.qlypDark.withOpacity(0.65),
                                                        borderRadius: BorderRadius.circular(18),
                                                        border: Border.all(color: AppColors.qlypPrimaryLight.withOpacity(0.08)),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: CachedNetworkImage(
                                                          imageUrl: serviceModel.image.toString(),
                                                          fit: BoxFit.contain,
                                                          height: Responsive.height(7.5, context),
                                                          width: Responsive.width(18, context),
                                                          placeholder: (context, url) => Constant.loader(isDarkTheme: isDark),
                                                          errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      Constant.localizationTitle(serviceModel.title),
                                                      textAlign: TextAlign.center,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: isSelected ? AppColors.qlypPrimaryLight : AppColors.qlypPrimaryLight.withOpacity(0.75),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                              ),
                            ),

                            // ✅ Price summary (same logic, styled)
                            Obx(() {
                              final ok = controller.sourceLocationLAtLng.value.latitude != null &&
                                  controller.destinationLocationLAtLng.value.latitude !=
                                      null &&
                                  controller
                                      .amount
                                      .value
                                      .isNotEmpty;
                              if (!ok)
                                return const SizedBox
                                    .shrink();

                              return Padding(
                                padding: const EdgeInsets
                                    .only(
                                    top:
                                    12),
                                child:
                                Container(
                                  width:
                                  double.infinity,
                                  decoration: _glass(
                                      radius: 18,
                                      color: AppColors.qlypDark.withOpacity(0.45)),
                                  padding: const EdgeInsets
                                      .all(
                                      14),
                                  child:
                                  Text(
                                    controller.selectedType.value.offerRate == true
                                        ? 'Recommended Price is ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}'.tr
                                        : 'Your Price is ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}'.tr,
                                    style:
                                    GoogleFonts.poppins(
                                      color: AppColors.qlypPrimaryLight.withOpacity(0.85),
                                      fontSize: 12.8,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(
                                height:
                                12),

                            // ✅ AC toggle (same logic)
                            if (controller
                                .selectedType
                                .value
                                .prices?[0]
                                .isAcNonAc ==
                                true)
                              Obx(
                                    () =>
                                    Container(
                                      decoration: _glass(
                                          radius: 18,
                                          color: AppColors.qlypDark.withOpacity(0.40)),
                                      child:
                                      SwitchListTile.adaptive(
                                        activeColor:
                                        AppColors.qlypSecondaryLight,
                                        title:
                                        Text(
                                          'A/C'.tr,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        value:
                                        controller.isAcSelected.value,
                                        onChanged:
                                            (bool newValue) {
                                          if (controller.sourceLocationLAtLng.value.latitude != null && controller.destinationLocationLAtLng.value.latitude != null && controller.amount.value.isNotEmpty) {
                                            controller.isAcSelected.value = newValue;
                                            controller.calculateAmount();
                                          } else {
                                            ShowToastDialog.showToast("Please select source and destination location".tr);
                                          }
                                        },
                                      ),
                                    ),
                              ),

                            const SizedBox(
                                height:
                                12),

                            // ✅ Offer rate input (same widget, themed cursor)
                            Visibility(
                              visible: controller
                                  .selectedType
                                  .value
                                  .offerRate ==
                                  true,
                              child:
                              Container(
                                height:
                                54,
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal:
                                    14),
                                decoration:
                                BoxDecoration(
                                  color: AppColors
                                      .qlypDark
                                      .withOpacity(0.75),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border:
                                  Border.all(
                                    color:
                                    AppColors.qlypPrimaryLight.withOpacity(0.14),
                                  ),
                                ),
                                child:
                                Row(
                                  children: [
                                    Text(
                                      Constant.currencyModel!.symbol.toString(),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.qlypPrimaryLight.withOpacity(0.85),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 1,
                                      height: 22,
                                      color: AppColors.qlypPrimaryLight.withOpacity(0.12),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: controller.offerYourRateController.value,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9*]')),
                                        ],
                                        cursorColor: AppColors.qlypSecondaryLight,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.qlypPrimaryLight.withOpacity(0.95),
                                          // ✅ visible text
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Enter your offer rate".tr,
                                          hintStyle: GoogleFonts.poppins(
                                            color: AppColors.qlypPrimaryLight.withOpacity(0.40),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),



                            const SizedBox(
                                height:
                                12),

                            // ✅ Someone taking (same logic)
                            _qlypSelectTile(
                              leading: Icon(
                                  Icons
                                      .person,
                                  color: AppColors
                                      .qlypPrimaryLight
                                      .withOpacity(0.85)),
                              text: controller.selectedTakingRide.value.fullName ==
                                  "Myself"
                                  ? "Myself"
                                  .tr
                                  : controller
                                  .selectedTakingRide
                                  .value
                                  .fullName
                                  .toString(),
                              onTap: () => someOneTakingDialog(
                                  context,
                                  controller),
                            ),

                            const SizedBox(
                                height:
                                12),

                            // ✅ Payment method (same logic)
                            _qlypSelectTile(
                              leading: SvgPicture.asset(
                                  'assets/icons/ic_payment.svg',
                                  width:
                                  24,
                                  color:
                                  AppColors.qlypSecondaryLight),
                              text: controller
                                  .selectedPaymentMethod
                                  .value
                                  .isNotEmpty
                                  ? controller
                                  .selectedPaymentMethod
                                  .value
                                  : "Select Payment type"
                                  .tr,
                              onTap: () => paymentMethodDialog(
                                  context,
                                  controller),
                            ),

                            const SizedBox(
                                height:
                                14),

                            // ✅ Book Ride button (same onPress logic)
                            _qlypPrimaryButton(
                              context,
                              title:
                              "Book Ride"
                                  .tr,
                              icon: Icons
                                  .arrow_forward_rounded,
                              onTap:
                                  () async {
                                bool
                                isPaymentNotCompleted =
                                await FireStoreUtils.paymentStatusCheck();
                                if (controller
                                    .selectedPaymentMethod
                                    .value
                                    .isEmpty) {
                                  ShowToastDialog.showToast(
                                      "Please select Payment Method".tr);
                                } else if (controller
                                    .sourceLocationController
                                    .value
                                    .text
                                    .isEmpty) {
                                  ShowToastDialog.showToast(
                                      "Please select source location".tr);
                                } else if (controller
                                    .destinationLocationController
                                    .value
                                    .text
                                    .isEmpty) {
                                  ShowToastDialog.showToast(
                                      "Please select destination location".tr);
                                } else if (double.parse(controller.distance.value) <=
                                    2) {
                                  ShowToastDialog.showToast(
                                      "Please select more than two ${Constant.distanceType} location".tr);
                                } else if (controller.selectedType.value.offerRate ==
                                    true &&
                                    controller.offerYourRateController.value.text.isEmpty) {
                                  ShowToastDialog.showToast(
                                      "Please Enter offer rate".tr);
                                } else if (isPaymentNotCompleted) {
                                  showAlertDialog(
                                      context);
                                } else {
                                  ShowToastDialog.showLoader(
                                      "Please wait");
                                  OrderModel
                                  orderModel =
                                  OrderModel();
                                  orderModel.id =
                                      Constant.getUuid();
                                  orderModel.userId =
                                      FireStoreUtils.getCurrentUid();
                                  orderModel.sourceLocationName = controller
                                      .sourceLocationController
                                      .value
                                      .text;
                                  orderModel.destinationLocationName = controller
                                      .destinationLocationController
                                      .value
                                      .text;
                                  orderModel.sourceLocationLAtLng = controller
                                      .sourceLocationLAtLng
                                      .value;
                                  orderModel.destinationLocationLAtLng = controller
                                      .destinationLocationLAtLng
                                      .value;
                                  orderModel.distance = controller
                                      .distance
                                      .value;
                                  orderModel.acNonAcCharges =
                                  '';
                                  orderModel.duration = controller
                                      .duration
                                      .value;
                                  orderModel.distanceType =
                                      Constant.distanceType;
                                  orderModel
                                      .offerRate = controller.selectedType.value.offerRate ==
                                      true
                                      ? controller.offerYourRateController.value.text
                                      : controller.amount.value;
                                  orderModel.serviceId = controller
                                      .selectedType
                                      .value
                                      .id;

                                  GeoFirePoint
                                  position =
                                  Geoflutterfire().point(
                                    latitude:
                                    controller.sourceLocationLAtLng.value.latitude!,
                                    longitude:
                                    controller.sourceLocationLAtLng.value.longitude!,
                                  );

                                  orderModel.position = Positions(
                                      geoPoint: position.geoPoint,
                                      geohash: position.hash);
                                  orderModel.createdDate =
                                      Timestamp.now();
                                  orderModel.status =
                                      Constant.ridePlaced;
                                  orderModel.paymentType = controller
                                      .selectedPaymentMethod
                                      .value;
                                  orderModel.paymentStatus =
                                  false;
                                  orderModel.service = controller
                                      .selectedType
                                      .value;

                                  AdminCommission?
                                  adminCommissionGlobal;
                                  if (Constant.adminCommission?.isEnabled !=
                                      true) {
                                    adminCommissionGlobal =
                                        Constant.adminCommission ?? AdminCommission();
                                    adminCommissionGlobal.amount =
                                    '0';
                                  }

                                  log("controller.selectedType.value.adminCommission?.isEnabled :: ${controller.selectedType.value.adminCommission?.isEnabled} :: ${Constant.adminCommission?.isEnabled}");

                                  orderModel
                                      .adminCommission = controller.selectedType.value.adminCommission?.isEnabled ==
                                      false
                                      ? controller.selectedType.value.adminCommission!
                                      : Constant.adminCommission?.isEnabled == false
                                      ? adminCommissionGlobal
                                      : Constant.adminCommission;

                                  orderModel.otp =
                                      Constant.getReferralCode();
                                  orderModel
                                      .isAcSelected = controller.selectedType.value.prices?[0].isAcNonAc ==
                                      true
                                      ? controller.isAcSelected.value
                                      : false;
                                  orderModel.taxList =
                                      Constant.taxList;

                                  if (controller.selectedTakingRide.value.fullName !=
                                      "Myself") {
                                    orderModel.someOneElse =
                                        controller.selectedTakingRide.value;
                                  }

                                  for (int i = 0;
                                  i < controller.zoneList.length;
                                  i++) {
                                    if (Constant.isPointInPolygon(
                                      LatLng(
                                        double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                                        double.parse(controller.sourceLocationLAtLng.value.longitude.toString()),
                                      ),
                                      controller.zoneList[i].area!,
                                    ) ==
                                        true) {
                                      controller.selectedZone.value = controller.zoneList[i];
                                      break;
                                    }
                                  }

                                  if (controller.selectedZone.value.id !=
                                      null) {
                                    orderModel.zoneId =
                                        controller.selectedZone.value.id;
                                    orderModel.zone =
                                        controller.selectedZone.value;

                                    await FireStoreUtils().sendOrderDataFuture(orderModel).then((eventData) async {
                                      for (var driver in eventData) {
                                        if (driver.fcmToken != null) {
                                          Map<String, dynamic> playLoad = <String, dynamic>{
                                            "type": "city_order",
                                            "orderId": orderModel.id
                                          };
                                          await SendNotification.sendOneNotification(
                                            token: driver.fcmToken.toString(),
                                            title: 'New Ride Available'.tr,
                                            body: 'A customer has placed a ride near your location.'.tr,
                                            payload: playLoad,
                                          );
                                        }
                                      }
                                    });

                                    await FireStoreUtils.setOrder(orderModel).then((value) {
                                      ShowToastDialog.showToast("Ride Placed successfully".tr);
                                      controller.dashboardController.selectedDrawerIndex(2);
                                      ShowToastDialog.closeLoader();
                                    });
                                  } else {
                                    ShowToastDialog.closeLoader();
                                    ShowToastDialog.showToast(
                                      "Services are currently unavailable on the selected location. Please reach out to the administrator for assistance.",
                                    );
                                    return;
                                  }
                                }
                              },
                            ),

                            const SizedBox(
                                height:
                                12),
                            _subtleText(
                                "Tip: You can use airport icon to pick Airport quickly."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
*/

  Widget _paymentTile(
    BuildContext context, {
    required DarkThemeProvider themeChange,
    required HomeController controller,
    required bool visible,
    required String title,
    required Widget leading,
  }) {
    if (!visible) return const SizedBox.shrink();

    final isSelected =
        controller.selectedPaymentMethod.value ==
            title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => controller
            .selectedPaymentMethod.value = title,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            color: AppColors.qlypCharcoal
                .withOpacity(0.55),
            border: Border.all(
              color: isSelected
                  ? AppColors.qlypSecondaryWarmSand
                  : AppColors.qlypPrimaryFreshGreen
                      .withOpacity(0.10),
              width: 1.3,
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 84,
                decoration: BoxDecoration(
                  color: AppColors.qlypCharcoal
                      .withOpacity(0.70),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors
                          .qlypPrimaryFreshGreen
                          .withOpacity(0.10)),
                ),
                child: Center(child: leading),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors
                        .qlypPrimaryFreshGreen
                        .withOpacity(0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Radio(
                value: title,
                groupValue: controller
                    .selectedPaymentMethod.value,
                activeColor:
                    AppColors.qlypSecondaryWarmSand,
                onChanged: (value) => controller
                    .selectedPaymentMethod
                    .value = title,
              ),
            ],
          ),
        ),
      ),
    );
  }

  paymentMethodDialog(BuildContext context,
      HomeController controller) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context1) {
        final themeChange =
            Provider.of<DarkThemeProvider>(
                context1);

        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Container(
            decoration: _glass(
                radius: 26,
                color: AppColors.qlypCharcoal
                    .withOpacity(0.96)),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                        16, 12, 16, 16),
                child: Obx(
                  () => Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () =>
                                Get.back(),
                            borderRadius:
                                BorderRadius
                                    .circular(14),
                            child: Container(
                              decoration: _glass(
                                  radius: 14,
                                  color: AppColors
                                      .qlypCharcoal
                                      .withOpacity(
                                          0.65)),
                              padding:
                                  const EdgeInsets
                                      .all(10),
                              child: Icon(
                                  Icons
                                      .arrow_back_rounded,
                                  color: AppColors
                                      .qlypPrimaryFreshGreen
                                      .withOpacity(
                                          0.9)),
                            ),
                          ),
                          const SizedBox(
                              width: 12),
                          Expanded(
                            child: Text(
                              "Select Payment Method"
                                  .tr,
                              textAlign: TextAlign
                                  .center,
                              style: GoogleFonts
                                  .poppins(
                                fontWeight:
                                    FontWeight
                                        .w800,
                                fontSize: 16,
                                color: AppColors
                                    .qlypPrimaryFreshGreen
                                    .withOpacity(
                                        0.95),
                              ),
                            ),
                          ),
                          const SizedBox(
                              width: 48),
                          // symmetry
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child:
                            SingleChildScrollView(
                          child: Column(
                            children: [
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .cash
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .cash
                                        ?.name
                                        ?.toString() ??
                                    "Cash",
                                leading: const Icon(
                                    Icons.money,
                                    color: Colors
                                        .white),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .wallet
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .wallet
                                        ?.name
                                        ?.toString() ??
                                    "Wallet",
                                leading: SvgPicture.asset(
                                    'assets/icons/ic_wallet.svg',
                                    color: AppColors
                                        .qlypPrimaryFreshGreen,
                                    width: 22),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .strip
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .strip
                                        ?.name
                                        ?.toString() ??
                                    "Stripe",
                                leading: Image.asset(
                                    'assets/images/stripe.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .paypal
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .paypal
                                        ?.name
                                        ?.toString() ??
                                    "PayPal",
                                leading: Image.asset(
                                    'assets/images/paypal.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .payStack
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .payStack
                                        ?.name
                                        ?.toString() ??
                                    "PayStack",
                                leading: Image.asset(
                                    'assets/images/paystack.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .mercadoPago
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .mercadoPago
                                        ?.name
                                        ?.toString() ??
                                    "MercadoPago",
                                leading: Image.asset(
                                    'assets/images/mercadopago.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .flutterWave
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .flutterWave
                                        ?.name
                                        ?.toString() ??
                                    "FlutterWave",
                                leading: Image.asset(
                                    'assets/images/flutterwave.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .payfast
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .payfast
                                        ?.name
                                        ?.toString() ??
                                    "Payfast",
                                leading: Image.asset(
                                    'assets/images/payfast.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .paytm
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .paytm
                                        ?.name
                                        ?.toString() ??
                                    "Paytm",
                                leading: Image.asset(
                                    'assets/images/paytam.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                        .paymentModel
                                        .value
                                        .razorpay
                                        ?.enable ==
                                    true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .razorpay
                                        ?.name
                                        ?.toString() ??
                                    "Razorpay",
                                leading: Image.asset(
                                    'assets/images/razorpay.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                            .paymentModel
                                            .value
                                            .midtrans !=
                                        null &&
                                    controller
                                            .paymentModel
                                            .value
                                            .midtrans!
                                            .enable ==
                                        true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .midtrans
                                        ?.name
                                        ?.toString() ??
                                    "Midtrans",
                                leading: Image.asset(
                                    'assets/images/midtrans.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                            .paymentModel
                                            .value
                                            .xendit !=
                                        null &&
                                    controller
                                            .paymentModel
                                            .value
                                            .xendit!
                                            .enable ==
                                        true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .xendit
                                        ?.name
                                        ?.toString() ??
                                    "Xendit",
                                leading: Image.asset(
                                    'assets/images/xendit.png'),
                              ),
                              _paymentTile(
                                context1,
                                themeChange:
                                    themeChange,
                                controller:
                                    controller,
                                visible: controller
                                            .paymentModel
                                            .value
                                            .orangePay !=
                                        null &&
                                    controller
                                            .paymentModel
                                            .value
                                            .orangePay!
                                            .enable ==
                                        true,
                                title: controller
                                        .paymentModel
                                        .value
                                        .orangePay
                                        ?.name
                                        ?.toString() ??
                                    "Orange Money",
                                leading: Image.asset(
                                    'assets/images/orange_money.png'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _qlypPrimaryButton(
                        context1,
                        title: "Pay".tr,
                        icon: Icons.lock_rounded,
                        onTap: () async {
                          Get.back();
                        },
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

  someOneTakingDialog(BuildContext context,
      HomeController controller) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context1) {
        final themeChange =
            Provider.of<DarkThemeProvider>(
                context1);

        return Obx(
          () => FractionallySizedBox(
            heightFactor: 0.90,
            child: Container(
              decoration: _glass(
                  radius: 26,
                  color: AppColors.qlypCharcoal
                      .withOpacity(0.96)),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                          16, 12, 16, 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () =>
                                  Get.back(),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          14),
                              child: Container(
                                decoration: _glass(
                                    radius: 14,
                                    color: AppColors
                                        .qlypCharcoal
                                        .withOpacity(
                                            0.65)),
                                padding:
                                    const EdgeInsets
                                        .all(10),
                                child: Icon(
                                    Icons
                                        .arrow_back_rounded,
                                    color: AppColors
                                        .qlypPrimaryFreshGreen
                                        .withOpacity(
                                            0.9)),
                              ),
                            ),
                            const SizedBox(
                                width: 12),
                            Expanded(
                              child: Text(
                                "Someone else taking this ride?"
                                    .tr,
                                textAlign:
                                    TextAlign
                                        .center,
                                style: GoogleFonts
                                    .poppins(
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  fontSize: 16,
                                  color: AppColors
                                      .qlypPrimaryFreshGreen
                                      .withOpacity(
                                          0.95),
                                ),
                              ),
                            ),
                            const SizedBox(
                                width: 48),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _subtleText(
                            "Choose a contact and share a code to conform that ride."),
                        const SizedBox(
                            height: 14),

                        // Myself
                        _contactTile(
                          context1,
                          themeChange:
                              themeChange,
                          selected: controller
                                  .selectedTakingRide
                                  .value
                                  .fullName ==
                              "Myself",
                          title: "Myself",
                          onTap: () => controller
                                  .selectedTakingRide
                                  .value =
                              ContactModel(
                                  fullName:
                                      "Myself",
                                  contactNumber:
                                      ""),
                        ),

                        const SizedBox(
                            height: 10),

                        // Contacts list
                        ListView.builder(
                          itemCount: controller
                              .contactList.length,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemBuilder:
                              (context, index) {
                            final contactModel =
                                controller
                                        .contactList[
                                    index];
                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                      bottom: 10),
                              child: _contactTile(
                                context1,
                                themeChange:
                                    themeChange,
                                selected: controller
                                        .selectedTakingRide
                                        .value
                                        .fullName ==
                                    contactModel
                                        .fullName,
                                title: contactModel
                                    .fullName
                                    .toString(),
                                subtitle: contactModel
                                        .contactNumber
                                        ?.toString() ??
                                    "",
                                onTap: () => controller
                                        .selectedTakingRide
                                        .value =
                                    contactModel,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 6),

                        // Choose another contact (same logic)
                        InkWell(
                          onTap: () async {
                            try {
                              final FlutterNativeContactPicker
                                  contactPicker =
                                  FlutterNativeContactPicker();
                              Contact? contact =
                                  await contactPicker
                                      .selectContact();
                              ContactModel
                                  contactModel =
                                  ContactModel();
                              contactModel
                                      .fullName =
                                  contact!.fullName ??
                                      "";
                              contactModel
                                      .contactNumber =
                                  contact
                                      .selectedPhoneNumber;

                              if (!controller
                                  .contactList
                                  .contains(
                                      contactModel)) {
                                controller
                                    .contactList
                                    .add(
                                        contactModel);
                                controller
                                    .setContact();
                              }
                            } catch (e) {
                              rethrow;
                            }
                          },
                          borderRadius:
                              BorderRadius
                                  .circular(16),
                          child: Container(
                            decoration: _glass(
                                radius: 16,
                                color: AppColors
                                    .qlypCharcoal
                                    .withOpacity(
                                        0.65)),
                            padding:
                                const EdgeInsets
                                    .symmetric(
                                    horizontal:
                                        14,
                                    vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                    Icons
                                        .contacts,
                                    color: AppColors
                                        .qlypPrimaryFreshGreen
                                        .withOpacity(
                                            0.85)),
                                const SizedBox(
                                    width: 10),
                                Expanded(
                                  child: Text(
                                    "Choose another contact"
                                        .tr,
                                    style: GoogleFonts
                                        .poppins(
                                      color: AppColors
                                          .qlypPrimaryFreshGreen
                                          .withOpacity(
                                              0.88),
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                    Icons
                                        .add_circle_outline_rounded,
                                    color: AppColors
                                        .qlypSecondaryWarmSand),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 14),

                        _qlypPrimaryButton(
                          context1,
                          title:
                              "Book for ${controller.selectedTakingRide.value.fullName}"
                                  .tr,
                          icon: Icons
                              .check_circle_rounded,
                          onTap: () async {
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _contactTile(
    BuildContext context, {
    required DarkThemeProvider themeChange,
    required bool selected,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.qlypCharcoal
              .withOpacity(0.55),
          border: Border.all(
            color: selected
                ? AppColors.qlypSecondaryWarmSand
                : AppColors.qlypPrimaryFreshGreen
                    .withOpacity(0.10),
            width: 1.3,
          ),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(14),
                color: AppColors.qlypCharcoal
                    .withOpacity(0.70),
                border: Border.all(
                    color: AppColors
                        .qlypPrimaryFreshGreen
                        .withOpacity(0.10)),
              ),
              child: Icon(Icons.person,
                  color: AppColors
                      .qlypPrimaryFreshGreen
                      .withOpacity(0.9)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title.tr,
                    style: GoogleFonts.poppins(
                      color: AppColors
                          .qlypPrimaryFreshGreen
                          .withOpacity(0.92),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null &&
                      subtitle.trim().isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                              top: 2),
                      child: Text(
                        subtitle,
                        style:
                            GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors
                              .qlypPrimaryFreshGreen
                              .withOpacity(0.65),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Radio(
              value: title,
              groupValue: selected ? title : "",
              activeColor:
                  AppColors.qlypSecondaryWarmSand,
              onChanged: (_) => onTap(),
            )
          ],
        ),
      ),
    );
  }

  ariPortDialog(BuildContext context,
      HomeController controller, bool isSource) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context1) {
        final themeChange =
            Provider.of<DarkThemeProvider>(
                context1);

        return FractionallySizedBox(
          heightFactor: 0.90,
          child: Container(
            decoration: _glass(
                radius: 26,
                color: AppColors.qlypCharcoal
                    .withOpacity(0.96)),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                        16, 12, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () =>
                                Get.back(),
                            borderRadius:
                                BorderRadius
                                    .circular(14),
                            child: Container(
                              decoration: _glass(
                                  radius: 14,
                                  color: AppColors
                                      .qlypCharcoal
                                      .withOpacity(
                                          0.65)),
                              padding:
                                  const EdgeInsets
                                      .all(10),
                              child: Icon(
                                  Icons
                                      .arrow_back_rounded,
                                  color: AppColors
                                      .qlypPrimaryFreshGreen
                                      .withOpacity(
                                          0.9)),
                            ),
                          ),
                          const SizedBox(
                              width: 12),
                          Expanded(
                            child: Text(
                              "AirPort".tr,
                              textAlign: TextAlign
                                  .center,
                              style: GoogleFonts
                                  .poppins(
                                fontWeight:
                                    FontWeight
                                        .w800,
                                fontSize: 16,
                                color: AppColors
                                    .qlypPrimaryFreshGreen
                                    .withOpacity(
                                        0.95),
                              ),
                            ),
                          ),
                          const SizedBox(
                              width: 48),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _subtleText(
                          "Choose a single AirPort"),
                      const SizedBox(height: 14),
                      ListView.builder(
                        itemCount: Constant
                            .airaPortList!.length,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemBuilder:
                            (context, index) {
                          AriPortModel
                              airPortModel =
                              Constant.airaPortList![
                                  index];
                          return Obx(
                            () {
                              final selected =
                                  controller
                                          .selectedAirPort
                                          .value
                                          .id ==
                                      airPortModel
                                          .id;
                              return Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                        bottom:
                                            10),
                                child: InkWell(
                                  onTap: () => controller
                                          .selectedAirPort
                                          .value =
                                      airPortModel,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              18),
                                  child:
                                      Container(
                                    decoration:
                                        BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                              18),
                                      color: AppColors
                                          .qlypCharcoal
                                          .withOpacity(
                                              0.55),
                                      border:
                                          Border
                                              .all(
                                        color: selected
                                            ? AppColors
                                                .qlypSecondaryWarmSand
                                            : AppColors
                                                .qlypPrimaryFreshGreen
                                                .withOpacity(0.10),
                                        width:
                                            1.3,
                                      ),
                                    ),
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal:
                                            12,
                                        vertical:
                                            12),
                                    child: Row(
                                      children: [
                                        Container(
                                          height:
                                              42,
                                          width:
                                              42,
                                          decoration:
                                              BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            color: AppColors
                                                .qlypCharcoal
                                                .withOpacity(0.70),
                                            border:
                                                Border.all(color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.10)),
                                          ),
                                          child: Icon(
                                              Icons
                                                  .airplanemode_active,
                                              color:
                                                  AppColors.qlypPrimaryFreshGreen.withOpacity(0.9)),
                                        ),
                                        const SizedBox(
                                            width:
                                                12),
                                        Expanded(
                                          child:
                                              Text(
                                            airPortModel
                                                .airportName
                                                .toString(),
                                            style:
                                                GoogleFonts.poppins(
                                              color:
                                                  AppColors.qlypPrimaryFreshGreen.withOpacity(0.92),
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Radio(
                                          value: airPortModel
                                              .id
                                              .toString(),
                                          groupValue: controller
                                              .selectedAirPort
                                              .value
                                              .id,
                                          activeColor:
                                              AppColors.qlypSecondaryWarmSand,
                                          onChanged: (_) => controller
                                              .selectedAirPort
                                              .value = airPortModel,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      _qlypPrimaryButton(
                        context1,
                        title: "Book".tr,
                        icon: Icons
                            .check_circle_rounded,
                        onTap: () async {
                          if (controller
                                  .selectedAirPort
                                  .value
                                  .id !=
                              null) {
                            if (isSource) {
                              controller
                                      .sourceLocationController
                                      .value
                                      .text =
                                  controller
                                      .selectedAirPort
                                      .value
                                      .airportName
                                      .toString();
                              controller
                                      .sourceLocationLAtLng
                                      .value =
                                  LocationLatLng(
                                latitude: double
                                    .parse(controller
                                        .selectedAirPort
                                        .value
                                        .airportLat
                                        .toString()),
                                longitude: double
                                    .parse(controller
                                        .selectedAirPort
                                        .value
                                        .airportLng
                                        .toString()),
                              );
                              controller
                                  .calculateAmount();
                            } else {
                              controller
                                      .destinationLocationController
                                      .value
                                      .text =
                                  controller
                                      .selectedAirPort
                                      .value
                                      .airportName
                                      .toString();
                              controller
                                      .destinationLocationLAtLng
                                      .value =
                                  LocationLatLng(
                                latitude: double
                                    .parse(controller
                                        .selectedAirPort
                                        .value
                                        .airportLat
                                        .toString()),
                                longitude: double
                                    .parse(controller
                                        .selectedAirPort
                                        .value
                                        .airportLng
                                        .toString()),
                              );
                              controller
                                  .calculateAmount();
                            }
                            Get.back();
                          } else {
                            ShowToastDialog.showToast(
                                "Please select one airport");
                          }
                        },
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

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () => Get.back(),
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Warning"),
      content: const Text(
          "You are not able book new ride please complete previous ride payment"),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
}

/*import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/home_controller.dart';
import 'package:customer/model/admin_commission.dart';
import 'package:customer/model/airport_model.dart';
import 'package:customer/model/banner_model.dart';
import 'package:customer/model/contact_model.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/order/positions.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/service_model.dart';
import 'package:customer/services/helper.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:customer/widget/geoflutterfire/src/models/point.dart';
import 'package:customer/widget/osm_map/map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.lightprimary,
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : SafeArea(
                    child: Column(
                      children: [
                        SizedBox(
                          height: Responsive.width(22, context),
                          width: Responsive.width(100, context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(controller.userModel.value.fullName.toString(), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 1)),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/icons/ic_location.svg', width: 16),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(child: Text(controller.currentLocation.value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration:
                                BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.20,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: GoogleMap(
                                            myLocationEnabled: true,
                                            myLocationButtonEnabled: false,
                                            zoomControlsEnabled: false,
                                            mapToolbarEnabled: false,
                                            initialCameraPosition: CameraPosition(
                                              zoom: 14,
                                              target: LatLng(
                                                Constant.currentLocation != null
                                                    ? Constant.currentLocation!.latitude
                                                    : 31.5204, // fallback (Lahore)
                                                Constant.currentLocation != null
                                                    ? Constant.currentLocation!.longitude
                                                    : 74.3587,
                                              ),
                                            ),
                                            onMapCreated: (GoogleMapController mapController) {
                                              // no extra logic (kept minimal)
                                            },
                                          ),
                                        ),
                                      ),





                                      const SizedBox(
                                        height: 10
                                      ),
                                      Text("Where you want to go?".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 1)),
                                      const SizedBox(height: 10),

                                      controller.sourceLocationLAtLng.value.latitude == null
                                          ? InkWell(
                                        onTap: () async {
                                          // ✅ SAME LOGIC AS YOUR OLD CODE (copied exactly)
                                          print("::::::::::22::::::::::::");
                                          if (Constant.selectedMapType == 'osm') {
                                            final result = await Get.to(() => MapPickerPage());
                                            if (result != null) {
                                              final firstPlace = result;
                                              final lat = firstPlace.coordinates.latitude;
                                              final lng = firstPlace.coordinates.longitude;
                                              final address = firstPlace.address;

                                              controller.sourceLocationController.value.text = address;
                                              controller.sourceLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                                              // Selected Zone
                                              for (int i = 0; i < controller.zoneList.length; i++) {
                                                if (Constant.isPointInPolygon(
                                                  LatLng(
                                                    double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                                                    double.parse(controller.sourceLocationLAtLng.value.longitude.toString()),
                                                  ),
                                                  controller.zoneList[i].area!,
                                                )) {
                                                  controller.selectedZone.value = controller.zoneList[i];
                                                }
                                              }

                                              // Serviceid and Zoneid to set controller.selectedType.value.price
                                              if (controller.selectedZone.value.id?.isNotEmpty == true) {
                                                Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                                                      (price) => price.zoneId == controller.selectedZone.value.id,
                                                  orElse: () => Price(),
                                                );
                                                if (selectedPrice?.zoneId != null) {
                                                  controller.selectedType.value.prices = [selectedPrice!];
                                                  log("SelectedPrice :: ${controller.selectedType.value.prices?.length}");
                                                }
                                              }

                                              await controller.calculateDurationAndDistance();
                                              controller.calculateAmount();
                                            }
                                          } else {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PlacePicker(
                                                  apiKey: Constant.mapAPIKey,
                                                  onPlacePicked: (result) async {
                                                    Get.back();

                                                    controller.sourceLocationController.value.text = result.formattedAddress.toString();
                                                    controller.sourceLocationLAtLng.value = LocationLatLng(
                                                      latitude: result.geometry!.location.lat,
                                                      longitude: result.geometry!.location.lng,
                                                    );

                                                    // Selected Zone
                                                    for (int i = 0; i < controller.zoneList.length; i++) {
                                                      if (Constant.isPointInPolygon(
                                                        LatLng(
                                                          double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                                                          double.parse(controller.sourceLocationLAtLng.value.longitude.toString()),
                                                        ),
                                                        controller.zoneList[i].area!,
                                                      )) {
                                                        controller.selectedZone.value = controller.zoneList[i];
                                                      }
                                                    }

                                                    // Serviceid and Zoneid to set controller.selectedType.value.price
                                                    if (controller.selectedZone.value.id?.isNotEmpty == true) {
                                                      Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                                                            (price) => price.zoneId == controller.selectedZone.value.id,
                                                        orElse: () => Price(),
                                                      );
                                                      if (selectedPrice?.zoneId != null) {
                                                        controller.selectedType.value.prices = [selectedPrice!];
                                                        log("SelectedPrice :: ${controller.selectedType.value.prices?.length}");
                                                      }
                                                    }

                                                    await controller.calculateDurationAndDistance();
                                                    controller.calculateAmount();
                                                  },
                                                  region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                                                  initialPosition: const LatLng(-33.8567844, 151.213108),
                                                  useCurrentLocation: true,
                                                  autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                      ? [Component(Component.country, Constant.regionCode)]
                                                      : [],
                                                  selectInitialPosition: true,
                                                  usePinPointingSearch: true,
                                                  usePlaceDetailSearch: true,
                                                  zoomGesturesEnabled: true,
                                                  zoomControlsEnabled: true,
                                                  resizeToAvoidBottomInset: false,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 54,
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          decoration: BoxDecoration(
                                            color: AppColors.qlypDark.withOpacity(0.75),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: AppColors.qlypPrimaryLight.withOpacity(0.14),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Enter Your Current Location'.tr,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    color: AppColors.qlypPrimaryLight.withOpacity(0.85),
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.my_location_rounded,
                                                size: 18,
                                                color: AppColors.qlypPrimaryLight.withOpacity(0.75),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                          : Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.qlypDark.withOpacity(0.78),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: AppColors.qlypPrimaryLight.withOpacity(0.14),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            // ================= PICKUP =================
                                            InkWell(
                                              onTap: () async {
                                                // ✅ SAME SOURCE onTap logic (copied exactly)
                                                print("::::::::::33::::::::::::");
                                                if (Constant.selectedMapType == 'osm') {
                                                  final result = await Get.to(() => MapPickerPage());
                                                  if (result != null) {
                                                    final firstPlace = result;
                                                    final lat = firstPlace.coordinates.latitude;
                                                    final lng = firstPlace.coordinates.longitude;
                                                    final address = firstPlace.address;

                                                    controller.sourceLocationController.value.text = address.toString();
                                                    controller.sourceLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                                                    await controller.calculateDurationAndDistance();
                                                    controller.calculateAmount();
                                                  }
                                                } else {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PlacePicker(
                                                        apiKey: Constant.mapAPIKey,
                                                        onPlacePicked: (result) async {
                                                          Get.back();

                                                          controller.sourceLocationController.value.text = result.formattedAddress.toString();
                                                          controller.sourceLocationLAtLng.value = LocationLatLng(
                                                            latitude: result.geometry!.location.lat,
                                                            longitude: result.geometry!.location.lng,
                                                          );

                                                          await controller.calculateDurationAndDistance();
                                                          controller.calculateAmount();
                                                        },
                                                        region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                                                        initialPosition: const LatLng(-33.8567844, 151.213108),
                                                        useCurrentLocation: true,
                                                        autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                            ? [Component(Component.country, Constant.regionCode)]
                                                            : [],
                                                        selectInitialPosition: true,
                                                        usePinPointingSearch: true,
                                                        usePlaceDetailSearch: true,
                                                        zoomGesturesEnabled: true,
                                                        zoomControlsEnabled: true,
                                                        resizeToAvoidBottomInset: false,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.radio_button_unchecked,
                                                      size: 18,
                                                      color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Pick-up Location'.tr,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 11.5,
                                                              color: AppColors.qlypPrimaryLight.withOpacity(0.55),
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            controller.sourceLocationController.value.text,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 13.5,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        ariPortDialog(context, controller, true);
                                                      },
                                                      child: Icon(
                                                        Icons.flight_takeoff,
                                                        size: 18,
                                                        color: AppColors.qlypPrimaryLight.withOpacity(0.8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: AppColors.qlypPrimaryLight.withOpacity(0.10),
                                            ),

                                            // ================= DROP OFF =================
                                            InkWell(
                                              onTap: () async {
                                                // ✅ SAME DESTINATION onTap logic (copied exactly)
                                                print("::::::::::11::::::::::::");
                                                if (Constant.selectedMapType == 'osm') {
                                                  final result = await Get.to(() => MapPickerPage());
                                                  if (result != null) {
                                                    final firstPlace = result;
                                                    final lat = firstPlace.coordinates.latitude;
                                                    final lng = firstPlace.coordinates.longitude;
                                                    final address = firstPlace.address;

                                                    controller.destinationLocationController.value.text = address.toString();
                                                    controller.destinationLocationLAtLng.value = LocationLatLng(latitude: lat, longitude: lng);

                                                    await controller.calculateDurationAndDistance();
                                                    controller.calculateAmount();
                                                  }
                                                } else {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PlacePicker(
                                                        apiKey: Constant.mapAPIKey,
                                                        onPlacePicked: (result) async {
                                                          Get.back();

                                                          controller.destinationLocationController.value.text = result.formattedAddress.toString();
                                                          controller.destinationLocationLAtLng.value = LocationLatLng(
                                                            latitude: result.geometry!.location.lat,
                                                            longitude: result.geometry!.location.lng,
                                                          );

                                                          await controller.calculateDurationAndDistance();
                                                          controller.calculateAmount();
                                                        },
                                                        region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty ? Constant.regionCode : null,
                                                        initialPosition: const LatLng(-33.8567844, 151.213108),
                                                        useCurrentLocation: true,
                                                        autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                            ? [Component(Component.country, Constant.regionCode)]
                                                            : [],
                                                        selectInitialPosition: true,
                                                        usePinPointingSearch: true,
                                                        usePlaceDetailSearch: true,
                                                        zoomGesturesEnabled: true,
                                                        zoomControlsEnabled: true,
                                                        resizeToAvoidBottomInset: false,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 18,
                                                      color: AppColors.qlypSecondaryLight.withOpacity(0.95),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Drop-off Location'.tr,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 11.5,
                                                              color: AppColors.qlypPrimaryLight.withOpacity(0.55),
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            controller.destinationLocationController.value.text,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 13.5,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppColors.qlypPrimaryLight.withOpacity(0.9),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        ariPortDialog(context, controller, false);
                                                      },
                                                      child: Icon(
                                                        Icons.flight_takeoff,
                                                        size: 18,
                                                        color: AppColors.qlypPrimaryLight.withOpacity(0.8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Text("Select Vehicle".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, letterSpacing: 1)),
                                      const SizedBox(height: 05),
                                      SizedBox(
                                        height: Responsive.height(18, context),
                                        child: ListView.builder(
                                          itemCount: controller.serviceList.length,
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            ServiceModel serviceModel = controller.serviceList[index];
                                            return Obx(
                                              () => InkWell(
                                                onTap: () {
                                                  controller.selectedType.value = serviceModel;
                                                  Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
                                                    (price) => price.zoneId == controller.selectedZone.value.id,
                                                    orElse: () => Price(),
                                                  );
                                                  if (selectedPrice?.zoneId != null) {
                                                    controller.selectedType.value.prices = [selectedPrice!];
                                                  }
                                                  controller.calculateAmount();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: Container(
                                                    width: Responsive.width(28, context),
                                                    decoration: BoxDecoration(
                                                        color: controller.selectedType.value == serviceModel
                                                            ? themeChange.getThem()
                                                                ? AppColors.darksecondprimary
                                                                : AppColors.lightsecondprimary
                                                            : themeChange.getThem()
                                                                ? AppColors.darkService
                                                                : controller.colors[index % controller.colors.length],
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(20),
                                                        )),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(context).colorScheme.background,
                                                              borderRadius: const BorderRadius.all(
                                                                Radius.circular(20),
                                                              )),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: CachedNetworkImage(
                                                              imageUrl: serviceModel.image.toString(),
                                                              fit: BoxFit.contain,
                                                              height: Responsive.height(8, context),
                                                              width: Responsive.width(18, context),
                                                              placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                                              errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10
                                                        ),
                                                        Text(Constant.localizationTitle(serviceModel.title),
                                                            style: GoogleFonts.poppins(
                                                                color: controller.selectedType.value == serviceModel
                                                                    ? themeChange.getThem()
                                                                        ? Colors.black
                                                                        : Colors.white
                                                                    : themeChange.getThem()
                                                                        ? Colors.white
                                                                        : Colors.black)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Obx(() =>
                                            controller.sourceLocationLAtLng.value.latitude != null && controller.destinationLocationLAtLng.value.latitude != null && controller.amount.value.isNotEmpty
                                                ? Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        child: Container(
                                                          width: Responsive.width(100, context),
                                                          decoration: const BoxDecoration(color: AppColors.gray, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                          child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                              child: Center(
                                                                child: controller.selectedType.value.offerRate == true
                                                                    ? RichText(
                                                                        text: TextSpan(
                                                                          text:
                                                                              'Recommended Price is ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}'
                                                                                  .tr,
                                                                          style: GoogleFonts.poppins(color: Colors.black),
                                                                        ),
                                                                      )
                                                                    : RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                'Your Price is ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}'
                                                                                    .tr,
                                                                            style: GoogleFonts.poppins(color: Colors.black)),
                                                                      ),
                                                              )),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      controller.selectedType.value.prices?[0].isAcNonAc == true
                                          ? Obx(
                                              () => Column(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      "Select A/C OR Non A/C".tr,
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  SwitchListTile.adaptive(
                                                    activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                    title: Text(
                                                      'A/C'.tr.tr,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: isDarkMode(context) ? Colors.white : Colors.black,
                                                        fontFamily: "Poppins",
                                                      ),
                                                    ),
                                                    value: controller.isAcSelected.value,
                                                    onChanged: (bool newValue) {
                                                      if (controller.sourceLocationLAtLng.value.latitude != null &&
                                                          controller.destinationLocationLAtLng.value.latitude != null &&
                                                          controller.amount.value.isNotEmpty) {
                                                        controller.isAcSelected.value = newValue;
                                                        controller.calculateAmount();
                                                      } else {
                                                        ShowToastDialog.showToast("Please select source and destination location".tr);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      controller.selectedType.value.offerRate == true
                                          ? const SizedBox(
                                              height: 10,
                                            )
                                          : SizedBox.shrink(),
                                      Visibility(
                                        visible: controller.selectedType.value.offerRate == true,
                                        child: TextFieldThem.buildTextFiledWithPrefixIcon(
                                          context,
                                          hintText: "Enter your offer rate".tr,
                                          controller: controller.offerYourRateController.value,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9*]')),
                                          ],
                                          prefix: Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Text(Constant.currencyModel!.symbol.toString()),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          someOneTakingDialog(context, controller);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                            border: Border.all(color: AppColors.textFieldBorder, width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.person),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                    child: Text(
                                                  controller.selectedTakingRide.value.fullName == "Myself" ? "Myself".tr : controller.selectedTakingRide.value.fullName.toString(),
                                                  style: GoogleFonts.poppins(),
                                                )),
                                                const Icon(Icons.arrow_drop_down_outlined)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          paymentMethodDialog(context, controller);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                            border: Border.all(color: AppColors.textFieldBorder, width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/ic_payment.svg',
                                                  width: 26,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                    child: Text(
                                                  controller.selectedPaymentMethod.value.isNotEmpty ? controller.selectedPaymentMethod.value : "Select Payment type".tr,
                                                  style: GoogleFonts.poppins(),
                                                )),
                                                const Icon(Icons.arrow_drop_down_outlined)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ButtonThem.buildButton(
                                        context,
                                        title: "Book Ride".tr,
                                        btnWidthRatio: Responsive.width(100, context),
                                        onPress: () async {
                                          bool isPaymentNotCompleted = await FireStoreUtils.paymentStatusCheck();
                                          if (controller.selectedPaymentMethod.value.isEmpty) {
                                            ShowToastDialog.showToast("Please select Payment Method".tr);
                                          } else if (controller.sourceLocationController.value.text.isEmpty) {
                                            ShowToastDialog.showToast("Please select source location".tr);
                                          } else if (controller.destinationLocationController.value.text.isEmpty) {
                                            ShowToastDialog.showToast("Please select destination location".tr);
                                          } else if (double.parse(controller.distance.value) <= 2) {
                                            ShowToastDialog.showToast("Please select more than two ${Constant.distanceType} location".tr);
                                          } else if (controller.selectedType.value.offerRate == true && controller.offerYourRateController.value.text.isEmpty) {
                                            ShowToastDialog.showToast("Please Enter offer rate".tr);
                                          } else if (isPaymentNotCompleted) {
                                            showAlertDialog(context);
                                            // showDialog(context: context, builder: (BuildContext context) => warningDailog());
                                          } else {
                                            ShowToastDialog.showLoader("Please wait");
                                            OrderModel orderModel = OrderModel();
                                            orderModel.id = Constant.getUuid();
                                            orderModel.userId = FireStoreUtils.getCurrentUid();
                                            orderModel.sourceLocationName = controller.sourceLocationController.value.text;
                                            orderModel.destinationLocationName = controller.destinationLocationController.value.text;
                                            orderModel.sourceLocationLAtLng = controller.sourceLocationLAtLng.value;
                                            orderModel.destinationLocationLAtLng = controller.destinationLocationLAtLng.value;
                                            orderModel.distance = controller.distance.value;
                                            orderModel.acNonAcCharges = '';
                                            orderModel.duration = controller.duration.value;
                                            orderModel.distanceType = Constant.distanceType;
                                            orderModel.offerRate = controller.selectedType.value.offerRate == true ? controller.offerYourRateController.value.text : controller.amount.value;
                                            orderModel.serviceId = controller.selectedType.value.id;
                                            GeoFirePoint position =
                                                Geoflutterfire().point(latitude: controller.sourceLocationLAtLng.value.latitude!, longitude: controller.sourceLocationLAtLng.value.longitude!);

                                            orderModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
                                            orderModel.createdDate = Timestamp.now();
                                            orderModel.status = Constant.ridePlaced;
                                            orderModel.paymentType = controller.selectedPaymentMethod.value;
                                            orderModel.paymentStatus = false;
                                            orderModel.service = controller.selectedType.value;
                                            AdminCommission? adminCommissionGlobal;
                                            if (Constant.adminCommission?.isEnabled != true) {
                                              adminCommissionGlobal = Constant.adminCommission ?? AdminCommission();
                                              adminCommissionGlobal.amount = '0';
                                            }
                                            log("controller.selectedType.value.adminCommission?.isEnabled :: ${controller.selectedType.value.adminCommission?.isEnabled} :: ${Constant.adminCommission?.isEnabled}");
                                            orderModel.adminCommission = controller.selectedType.value.adminCommission?.isEnabled == false
                                                ? controller.selectedType.value.adminCommission!
                                                : Constant.adminCommission?.isEnabled == false
                                                    ? adminCommissionGlobal
                                                    : Constant.adminCommission;
                                            orderModel.otp = Constant.getReferralCode();
                                            orderModel.isAcSelected = controller.selectedType.value.prices?[0].isAcNonAc == true ? controller.isAcSelected.value : false;
                                            orderModel.taxList = Constant.taxList;
                                            if (controller.selectedTakingRide.value.fullName != "Myself") {
                                              orderModel.someOneElse = controller.selectedTakingRide.value;
                                            }

                                            for (int i = 0; i < controller.zoneList.length; i++) {
                                              if (Constant.isPointInPolygon(
                                                      LatLng(double.parse(controller.sourceLocationLAtLng.value.latitude.toString()),
                                                          double.parse(controller.sourceLocationLAtLng.value.longitude.toString())),
                                                      controller.zoneList[i].area!) ==
                                                  true) {
                                                controller.selectedZone.value = controller.zoneList[i];
                                                break;
                                              }
                                            }
                                            if (controller.selectedZone.value.id != null) {
                                              orderModel.zoneId = controller.selectedZone.value.id;
                                              orderModel.zone = controller.selectedZone.value;
                                              await FireStoreUtils().sendOrderDataFuture(orderModel).then((eventData) async {
                                                for (var driver in eventData) {
                                                  if (driver.fcmToken != null) {
                                                    Map<String, dynamic> playLoad = <String, dynamic>{"type": "city_order", "orderId": orderModel.id};
                                                    await SendNotification.sendOneNotification(
                                                        token: driver.fcmToken.toString(),
                                                        title: 'New Ride Available'.tr,
                                                        body: 'A customer has placed a ride near your location.'.tr,
                                                        payload: playLoad);
                                                  }
                                                }
                                              });
                                              await FireStoreUtils.setOrder(orderModel).then((value) {
                                                ShowToastDialog.showToast("Ride Placed successfully".tr);
                                                controller.dashboardController.selectedDrawerIndex(2);
                                                ShowToastDialog.closeLoader();
                                              });
                                            } else {
                                              ShowToastDialog.closeLoader();
                                              ShowToastDialog.showToast(
                                                "Services are currently unavailable on the selected location. Please reach out to the administrator for assistance.",
                                              );
                                              return;
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }

  paymentMethodDialog(BuildContext context, HomeController controller) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: StatefulBuilder(builder: (context1, setState) {
              return Obx(
                () => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: const Icon(Icons.arrow_back_ios)),
                              const Expanded(
                                  child: Center(
                                      child: Text(
                                "Select Payment Method",
                              ))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Visibility(
                                  visible: controller.paymentModel.value.cash!.enable == true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod.value = controller.paymentModel.value.cash!.name.toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller.selectedPaymentMethod.value == controller.paymentModel.value.cash!.name.toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.darksecondprimary
                                                          : AppColors.lightsecondprimary
                                                      : AppColors.textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: Icon(Icons.money, color: Colors.black),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel.value.cash!.name.toString(),
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller.paymentModel.value.cash!.name.toString(),
                                                    groupValue: controller.selectedPaymentMethod.value,
                                                    activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                    onChanged: (value) {
                                                      controller.selectedPaymentMethod.value = controller.paymentModel.value.cash!.name.toString();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.wallet!.enable == true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod.value = controller.paymentModel.value.wallet!.name.toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller.selectedPaymentMethod.value == controller.paymentModel.value.wallet!.name.toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.darksecondprimary
                                                          : AppColors.lightsecondprimary
                                                      : AppColors.textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SvgPicture.asset('assets/icons/ic_wallet.svg', color: AppColors.lightprimary),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel.value.wallet!.name.toString(),
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller.paymentModel.value.wallet!.name.toString(),
                                                    groupValue: controller.selectedPaymentMethod.value,
                                                    activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                    onChanged: (value) {
                                                      controller.selectedPaymentMethod.value = controller.paymentModel.value.wallet!.name.toString();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.strip!.enable == true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller.selectedPaymentMethod.value == controller.paymentModel.value.strip!.name.toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.darksecondprimary
                                                          : AppColors.lightsecondprimary
                                                      : AppColors.textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Image.asset('assets/images/stripe.png'),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel.value.strip!.name.toString(),
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller.paymentModel.value.strip!.name.toString(),
                                                    groupValue: controller.selectedPaymentMethod.value,
                                                    activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                    onChanged: (value) {
                                                      controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.paypal!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paypal!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paypal.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.paypal!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.paypal!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.payStack!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payStack!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paystack.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payStack!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.payStack!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.mercadoPago!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.mercadoPago!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/mercadopago.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.mercadoPago!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.mercadoPago!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.flutterWave!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.flutterWave!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/flutterwave.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.flutterWave!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.flutterWave!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.payfast!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payfast!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/payfast.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payfast!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.payfast!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.paytm!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paytm!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paytam.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.paytm!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.paytm!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.razorpay!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.razorpay!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/razorpay.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.razorpay!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.razorpay!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                controller.paymentModel.value.midtrans != null && controller.paymentModel.value.midtrans!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.midtrans!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.midtrans!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/midtrans.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.midtrans!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.midtrans!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.midtrans!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                controller.paymentModel.value.xendit != null && controller.paymentModel.value.xendit!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.xendit!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/xendit.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.xendit!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.xendit!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                controller.paymentModel.value.orangePay != null && controller.paymentModel.value.orangePay!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.orangePay!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.orangePay!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/orange_money.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.orangePay!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.orangePay!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.orangePay!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ButtonThem.buildButton(
                          context,
                          title: "Pay",
                          onPress: () async {
                            Get.back();
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  someOneTakingDialog(BuildContext context, HomeController controller) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);
          return StatefulBuilder(builder: (context1, setState) {
            return Obx(
              () => Container(
                constraints: BoxConstraints(maxHeight: Responsive.height(90, context)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Someone else taking this ride?",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Choose a contact and share a code to conform that ride.",
                            style: GoogleFonts.poppins(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              controller.selectedTakingRide.value = ContactModel(fullName: "Myself", contactNumber: "");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                    color: controller.selectedTakingRide.value.fullName == "Myself"
                                        ? themeChange.getThem()
                                            ? AppColors.darksecondprimary
                                            : AppColors.lightsecondprimary
                                        : AppColors.textFieldBorder,
                                    width: 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.person, color: Colors.black),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Myself",
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    Radio(
                                      value: "Myself",
                                      groupValue: controller.selectedTakingRide.value.fullName,
                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                      onChanged: (value) {
                                        controller.selectedTakingRide.value = ContactModel(fullName: "Myself", contactNumber: "");
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            itemCount: controller.contactList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              ContactModel contactModel = controller.contactList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: InkWell(
                                  onTap: () {
                                    controller.selectedTakingRide.value = contactModel;
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(
                                          color: controller.selectedTakingRide.value.fullName == contactModel.fullName
                                              ? themeChange.getThem()
                                                  ? AppColors.darksecondprimary
                                                  : AppColors.lightsecondprimary
                                              : AppColors.textFieldBorder,
                                          width: 1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.person, color: Colors.black),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              contactModel.fullName.toString(),
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                          Radio(
                                            value: contactModel.fullName.toString(),
                                            groupValue: controller.selectedTakingRide.value.fullName,
                                            activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                            onChanged: (value) {
                                              controller.selectedTakingRide.value = contactModel;
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              try {
                                final FlutterNativeContactPicker contactPicker = FlutterNativeContactPicker();
                                Contact? contact = await contactPicker.selectContact();
                                ContactModel contactModel = ContactModel();
                                contactModel.fullName = contact!.fullName ?? "";
                                contactModel.contactNumber = contact.selectedPhoneNumber;

                                if (!controller.contactList.contains(contactModel)) {
                                  controller.contactList.add(contactModel);
                                  controller.setContact();
                                }
                              } catch (e) {
                                rethrow;
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.contacts, color: Colors.black),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Choose another contact",
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ButtonThem.buildButton(
                            context,
                            title: "Book for ${controller.selectedTakingRide.value.fullName}",
                            onPress: () async {
                              Get.back();
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  ariPortDialog(BuildContext context, HomeController controller, bool isSource) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);

          return StatefulBuilder(builder: (context1, setState) {
            return Container(
              constraints: BoxConstraints(maxHeight: Responsive.height(90, context)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Do you want to travel for AirPort?",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Choose a single AirPort",
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        itemCount: Constant.airaPortList!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          AriPortModel airPortModel = Constant.airaPortList![index];
                          return Obx(
                            () => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: InkWell(
                                onTap: () {
                                  controller.selectedAirPort.value = airPortModel;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                        color: controller.selectedAirPort.value.id == airPortModel.id
                                            ? themeChange.getThem()
                                                ? AppColors.darksecondprimary
                                                : AppColors.lightsecondprimary
                                            : AppColors.textFieldBorder,
                                        width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(Icons.airplanemode_active, color: Colors.black),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            airPortModel.airportName.toString(),
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                        Radio(
                                          value: airPortModel.id.toString(),
                                          groupValue: controller.selectedAirPort.value.id,
                                          activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                          onChanged: (value) {
                                            controller.selectedAirPort.value = airPortModel;
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonThem.buildButton(
                        context,
                        title: "Book",
                        onPress: () async {
                          if (controller.selectedAirPort.value.id != null) {
                            if (isSource) {
                              controller.sourceLocationController.value.text = controller.selectedAirPort.value.airportName.toString();
                              controller.sourceLocationLAtLng.value = LocationLatLng(
                                  latitude: double.parse(controller.selectedAirPort.value.airportLat.toString()), longitude: double.parse(controller.selectedAirPort.value.airportLng.toString()));
                              controller.calculateAmount();
                            } else {
                              controller.destinationLocationController.value.text = controller.selectedAirPort.value.airportName.toString();
                              controller.destinationLocationLAtLng.value = LocationLatLng(
                                  latitude: double.parse(controller.selectedAirPort.value.airportLat.toString()), longitude: double.parse(controller.selectedAirPort.value.airportLng.toString()));
                              controller.calculateAmount();
                            }
                            Get.back();
                          } else {
                            ShowToastDialog.showToast("Please select one airport");
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
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
      content: const Text("You are not able book new ride please complete previous ride payment"),
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
}*/

// warningDailog() {
//   return Dialog(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
//     child: SizedBox(
//       height: 300.0,
//       width: 300.0,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           const Padding(
//             padding: EdgeInsets.all(15.0),
//             child: Text(
//               'Warning!',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(15.0),
//             child: Text(
//               'You are not able book new ride please complete previous ride payment',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//           const Padding(padding: EdgeInsets.only(top: 50.0)),
//           TextButton(
//               onPressed: () {
//                 Get.back();
//               },
//               child: const Text(
//                 'Ok',
//                 style: TextStyle(color: Colors.purple, fontSize: 18.0),
//               ))
//         ],
//       ),
//     ),
//   );
// }

/*Visibility(
                                        visible: controller.bannerList.isNotEmpty,
                                        child: SizedBox(
                                            height: MediaQuery.of(context).size.height * 0.20,
                                            child: PageView.builder(
                                                padEnds: false,
                                                itemCount: controller.bannerList.length,
                                                scrollDirection: Axis.horizontal,
                                                controller: controller.pageController,
                                                itemBuilder: (context, index) {
                                                  BannerModel bannerModel = controller.bannerList[index];
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: CachedNetworkImage(
                                                      imageUrl: bannerModel.image.toString(),
                                                      imageBuilder: (context, imageProvider) => Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20),
                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                        ),
                                                      ),
                                                      color: Colors.black.withOpacity(0.5),
                                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  );
                                                })),
                                      ),*/
