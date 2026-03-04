import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/dash_board_controller.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/inbox_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/ui/chat_screen/chat_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:customer/widget/firebase_pagination/src/models/view_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.lightprimary,
      body: Column(
        children: [
          SizedBox(
            height: Responsive.width(6, context),
            width: Responsive.width(100, context),
          ),
          Expanded(
            child: Container(
              width: Responsive.width(100, context),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FirestorePagination(
                  query: FirebaseFirestore.instance.collection('chat').where("sender_receiver_id", arrayContains: FireStoreUtils.getCurrentUid()).orderBy('createdAt', descending: true),
                  //item builder type is compulsory.
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, documentSnapshots, index) {
                    final data = documentSnapshots[index].data() as Map<String, dynamic>?;
                    log("data?['adminId'] :: ${data?['adminId']}");
                    if (data?['type'] == 'adminchat') {
                      InboxModel inboxModel = InboxModel.fromJson(data!);
                      return InkWell(
                        onTap: () async {
                          DashBoardController dashboardController = Get.put(DashBoardController());
                          dashboardController.selectedDrawerIndex(10);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                              boxShadow: themeChange.getThem()
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2), // changes position of shadow
                                      ),
                                    ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: ClipOval(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300, // optional background
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Admin",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      'Admin',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                    )),
                                    Text(Constant.dateFormatTimestamp(inboxModel.createdAt), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                                  ],
                                ),
                                subtitle: Text(inboxModel.lastMessageType == 'image'
                                    ? 'image'
                                    : inboxModel.lastMessageType == 'video'
                                        ? 'video'
                                        : inboxModel.lastMessage ?? ""),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      InboxModel inboxModel = InboxModel.fromJson(data!);
                      return FutureBuilder<DriverUserModel?>(
                          future: FireStoreUtils.getDriver(inboxModel.receiverId == FireStoreUtils.getCurrentUid() ? inboxModel.senderId! : inboxModel.receiverId!),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                    boxShadow: themeChange.getThem()
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2), // changes position of shadow
                                            ),
                                          ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: ListTile(
                                      leading: ClipOval(
                                        child: CachedNetworkImage(
                                            width: 40,
                                            height: 40,
                                            imageUrl: '',
                                            imageBuilder: (context, imageProvider) => Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  )),
                                                ),
                                            errorWidget: (context, url, error) => ClipRRect(
                                                borderRadius: BorderRadius.circular(5),
                                                child: Image.network(
                                                  Constant.userPlaceHolder,
                                                  fit: BoxFit.cover,
                                                ))),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            'loading..'.tr,
                                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                          )),
                                          Text(Constant.dateFormatTimestamp(inboxModel.createdAt), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                                        ],
                                      ),
                                      subtitle: Text("Ride Id : #${inboxModel.orderId}".tr),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              DriverUserModel? driver = snapshot.data;
                              return InkWell(
                                onTap: () async {
                                  ShowToastDialog.showLoader("Please wait..");
                                  await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
                                    ShowToastDialog.closeLoader();
                                    Get.to(ChatScreens(
                                      driverId: driver!.id,
                                      customerId: value!.id,
                                      customerName: value.fullName,
                                      customerProfileImage: value.profilePic,
                                      driverName: driver.fullName,
                                      driverProfileImage: driver.profilePic,
                                      orderId: inboxModel.orderId,
                                      token: driver.fcmToken,
                                    ));
                                  });
                                  ShowToastDialog.closeLoader();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                      boxShadow: themeChange.getThem()
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2), // changes position of shadow
                                              ),
                                            ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: ListTile(
                                        leading: ClipOval(
                                          child: CachedNetworkImage(
                                              width: 40,
                                              height: 40,
                                              imageUrl: driver?.profilePic ?? '',
                                              imageBuilder: (context, imageProvider) => Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    )),
                                                  ),
                                              errorWidget: (context, url, error) => ClipRRect(
                                                  borderRadius: BorderRadius.circular(5),
                                                  child: Image.network(
                                                    Constant.userPlaceHolder,
                                                    fit: BoxFit.cover,
                                                  ))),
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                              driver?.fullName ?? '',
                                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                            )),
                                            Text(Constant.dateFormatTimestamp(inboxModel.createdAt), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                                          ],
                                        ),
                                        subtitle: Text("Ride Id : #${inboxModel.orderId}".tr),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          });
                    }
                  },
                  shrinkWrap: true,
                  onEmpty: Center(child: Text("No Conversion found".tr)),
                  // orderBy is compulsory to enable pagination

                  //Change types customerId
                  viewType: ViewType.list,
                  initialLoader: Constant.loader(isDarkTheme: themeChange.getThem()),
                  // to fetch real-time data
                  isLive: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
