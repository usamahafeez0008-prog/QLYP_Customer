import 'dart:io';

import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/widget/osm_map/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapPickerPage extends StatelessWidget {
  final OSMMapController controller = Get.put(OSMMapController());
  final TextEditingController searchController = TextEditingController();

  MapPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    return Container(
      // ✅ QLYP background (doesn't affect functionality)
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            // ✅ Map (unchanged functionality)
            Obx(
                  () => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter:
                  controller.pickedPlace.value?.coordinates ?? LatLng(20.5937, 78.9629),
                  initialZoom: 13,
                  onTap: (tapPos, latlng) {
                    controller.addLatLngOnly(latlng);
                    controller.mapController.move(latlng, controller.mapController.camera.zoom);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: Platform.isAndroid
                        ? 'com.goride.customer'
                        : 'com.goride.customer',
                  ),
                  MarkerLayer(
                    markers: controller.pickedPlace.value != null
                        ? [
                      Marker(
                        point: controller.pickedPlace.value!.coordinates,
                        width: 60,
                        height: 60,
                        child: SvgPicture.asset(
                          'assets/icons/ic_destination.svg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.fill,
                          color: AppColors.qlypPrimaryFreshGreen,
                        ),
                      ),
                    ]
                        : [],
                  ),
                ],
              ),
            ),

            // ✅ top blobs (visual only)
            Positioned(
              top: -90,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.qlypDeepNavy.withOpacity(0.22),
                      AppColors.qlypDeepNavy.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.qlypPrimaryFreshGreen.withOpacity(0.14),
                      AppColors.qlypPrimaryFreshGreen.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Top bar + search (same logic)
            Positioned(
              top: 18,
              left: 16,
              right: 16,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Back button (no drawer logic touched)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.qlypCharcoal.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Search field (functionality unchanged)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.qlypCharcoal.withOpacity(0.55),
                        border: Border.all(
                          color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.12),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor: AppColors.qlypSecondaryWarmSand,
                            selectionColor: AppColors.qlypSecondaryWarmSand.withOpacity(0.25),
                            selectionHandleColor: AppColors.qlypSecondaryWarmSand,
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          cursorColor: AppColors.qlypSecondaryWarmSand,
                          style: TextStyle(
                            color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.95),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: 'Search location...'.tr,
                            hintStyle: TextStyle(
                              color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.45),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.qlypSecondaryWarmSand,
                            ),
                          ),
                          onChanged: controller.searchPlace,
                        ),
                      ),
                    ),

                    // Search results (same logic)
                    Obx(() {
                      if (controller.searchResults.isEmpty) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppColors.qlypCharcoal.withOpacity(0.72),
                          border: Border.all(
                            color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.10),
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.searchResults.length,
                          itemBuilder: (context, index) {
                            final place = controller.searchResults[index];
                            return ListTile(
                              title: Text(
                                place['display_name'],
                                style: TextStyle(
                                  color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () {
                                controller.selectSearchResult(place);
                                final lat = double.parse(place['lat']);
                                final lon = double.parse(place['lon']);
                                final pos = LatLng(lat, lon);
                                controller.mapController.move(pos, 15);
                                searchController.text = place['display_name'];
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ✅ Bottom sheet-like bar (same confirm + delete logic)
        bottomNavigationBar: Obx(() {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: AppColors.qlypCharcoal.withOpacity(0.55),
                  border: Border.all(
                    color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.pickedPlace.value != null
                          ? "Picked Location:".tr
                          : "No Location Picked".tr,
                      style: TextStyle(
                        color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (controller.pickedPlace.value != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          "${controller.pickedPlace.value!.address}\n(${controller.pickedPlace.value!.coordinates.latitude.toStringAsFixed(5)}, ${controller.pickedPlace.value!.coordinates.longitude.toStringAsFixed(5)})",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.70),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () async {
                                  final selected = controller.pickedPlace.value;
                                  if (selected != null) {
                                    Get.back(result: selected); // ✅ SAME LOGIC
                                    // ignore: avoid_print
                                    print("Selected location: $selected");
                                  }
                                },
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
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
                                        color: AppColors.qlypPrimarySunYellow.withOpacity(0.45),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.35),
                                        blurRadius: 24,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.10),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Confirm Location".tr,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.qlypCharcoal,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),


                          /*ButtonThem.buildButton(
                            context,
                            title: "Confirm Location".tr,
                            onPress: () async {
                              final selected = controller.pickedPlace.value;
                              if (selected != null) {
                                Get.back(result: selected); // ✅ Return the selected place
                                // ignore: avoid_print
                                print("Selected location: $selected");
                              }
                            },
                          ),*/
                        ),
                        const SizedBox(width: 10),

                        // Delete button (same function)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: AppColors.qlypCharcoal.withOpacity(0.55),
                            border: Border.all(
                              color: AppColors.qlypDeepNavy.withOpacity(0.35),
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_forever_rounded,
                              color: AppColors.qlypDeepNavy,
                            ),
                            onPressed: controller.clearAll,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}



/*
import 'dart:io';

import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/widget/osm_map/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapPickerPage extends StatelessWidget {
  final OSMMapController controller = Get.put(OSMMapController());
  final TextEditingController searchController = TextEditingController();

  MapPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.pickedPlace.value?.coordinates ?? LatLng(20.5937, 78.9629), // Default India center
                initialZoom: 13,
                onTap: (tapPos, latlng) {
                  controller.addLatLngOnly(latlng);
                  controller.mapController.move(latlng, controller.mapController.camera.zoom);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: Platform.isAndroid ? 'com.goride.customer' : 'com.goride.customer',
                ),
                MarkerLayer(
                  markers: controller.pickedPlace.value != null
                      ? [
                          Marker(
                              point: controller.pickedPlace.value!.coordinates,
                              width: 60,
                              height: 60,
                              child: SvgPicture.asset(
                                'assets/icons/ic_destination.svg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.fill,
                                color: AppColors.darkBackground,
                              )),
                        ]
                      : [],
                ),
              ],
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.darkContainerBackground,
                    ),
                  ),
                ),
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: searchController,
                    cursorColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                      hintText: 'Search location...'.tr,
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary),
                    ),
                    onChanged: controller.searchPlace,
                  ),
                ),
                Obx(() {
                  if (controller.searchResults.isEmpty) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final place = controller.searchResults[index];
                        return ListTile(
                          title: Text(place['display_name']),
                          onTap: () {
                            controller.selectSearchResult(place);
                            final lat = double.parse(place['lat']);
                            final lon = double.parse(place['lon']);
                            final pos = LatLng(lat, lon);
                            controller.mapController.move(pos, 15);
                            searchController.text = place['display_name'];
                          },
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          padding: const EdgeInsets.all(16),
          color: themeChange.getThem() ? AppColors.darkBackground : AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.pickedPlace.value != null ? "Picked Location:".tr : "No Location Picked".tr,
                style: TextStyle(
                  color: themeChange.getThem() ? AppColors.background : AppColors.darkBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (controller.pickedPlace.value != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    "${controller.pickedPlace.value!.address}\n(${controller.pickedPlace.value!.coordinates.latitude.toStringAsFixed(5)}, ${controller.pickedPlace.value!.coordinates.longitude.toStringAsFixed(5)})",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ButtonThem.buildButton(
                      context,
                      title: "Confirm Location".tr,
                      onPress: () async {
                        final selected = controller.pickedPlace.value;
                        if (selected != null) {
                          Get.back(result: selected); // ✅ Return the selected place
                          print("Selected location: $selected");
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: controller.clearAll,
                  )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
*/
