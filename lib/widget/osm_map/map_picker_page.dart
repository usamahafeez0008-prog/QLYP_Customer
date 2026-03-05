import 'dart:io';

import 'package:customer/constant/show_toast_dialog.dart';

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
      color: AppColors.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Map Layer
            Obx(
              () => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.pickedPlace.value?.coordinates ??
                      LatLng(31.511, 74.314),
                  initialZoom: 13,
                  onTap: (tapPos, latlng) {
                    controller.addLatLngOnly(latlng);
                    controller.mapController
                        .move(latlng, controller.mapController.camera.zoom);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.goride.customer',
                  ),
                  MarkerLayer(
                    markers: controller.pickedPlace.value != null
                        ? [
                            Marker(
                              point: controller.pickedPlace.value!.coordinates,
                              width: 50,
                              height: 50,
                              child: Icon(
                                Icons.location_on,
                                color: AppColors.qlypDeepNavy,
                                size: 50,
                              ),
                            ),
                          ]
                        : [],
                  ),
                ],
              ),
            ),

            // Top Search Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10)
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.arrow_back,
                              color: AppColors.qlypDeepNavy),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10)
                            ],
                          ),
                          child: TextField(
                            controller: searchController,
                            cursorColor: AppColors.qlypDeepNavy,
                            decoration: InputDecoration(
                              hintText: 'Search location...'.tr,
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey, fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.search,
                                  color: AppColors.qlypDeepNavy),
                            ),
                            onChanged: controller.searchPlace,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search Results
                  Obx(() {
                    if (controller.searchResults.isEmpty)
                      return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10)
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: controller.searchResults.length,
                        itemBuilder: (context, index) {
                          final place = controller.searchResults[index];
                          return ListTile(
                            leading: Icon(Icons.location_on_outlined,
                                color: AppColors.qlypDeepNavy),
                            title: Text(
                              place['display_name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            onTap: () {
                              controller.selectSearchResult(place);
                              final lat = double.parse(place['lat']);
                              final lon = double.parse(place['lon']);
                              final pos = LatLng(lat, lon);
                              controller.mapController.move(pos, 15);
                              searchController.text = place['display_name'];
                              controller.searchResults.clear();
                              FocusScope.of(context).unfocus();
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
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Picked Location".tr,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.qlypDeepNavy,
                      ),
                    ),
                    if (controller.pickedPlace.value != null)
                      IconButton(
                        onPressed: controller.clearAll,
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                  ],
                ),
                if (controller.pickedPlace.value != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    controller.pickedPlace.value!.address,
                    style:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.qlypDeepNavy,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final selected = controller.pickedPlace.value;
                      if (selected != null) {
                        Get.back(result: selected);
                      } else {
                        ShowToastDialog.showToast("Please pick a location");
                      }
                    },
                    child: Text(
                      "Confirm Location".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
