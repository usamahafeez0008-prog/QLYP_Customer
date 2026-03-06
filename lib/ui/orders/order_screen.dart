import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/sos_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/ui/chat_screen/chat_screen.dart';
import 'package:customer/ui/hold_timer/hold_timer_screen.dart';
import 'package:customer/ui/orders/complete_order_screen.dart';
import 'package:customer/ui/orders/live_tracking_screen.dart';
import 'package:customer/ui/orders/order_details_screen.dart';
import 'package:customer/ui/orders/payment_order_screen.dart';
import 'package:customer/ui/review/review_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';
import 'package:customer/widget/driver_view.dart';
import 'package:customer/widget/location_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.qlypOffWhite,
      body: Column(
        children: [
          // Container(
          //   height: Responsive.width(10, context),
          //   width: Responsive.width(100, context),
          //   color: AppColors.qlypOffWhite,
          // ),
          Expanded(
            child: Container(
              /* decoration: BoxDecoration(color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(5),
                      topRight: Radius.circular(25))),*/
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTabBar(themeChange),
                      Expanded(
                        child: TabBarView(
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(CollectionName.orders)
                                  .where("userId",
                                      isEqualTo: FireStoreUtils.getCurrentUid())
                                  .where("status", whereIn: [
                                    Constant.ridePlaced,
                                    Constant.rideInProgress,
                                    Constant.rideComplete,
                                    Constant.rideActive,
                                    Constant.rideHoldAccepted,
                                    Constant.rideHold,
                                  ])
                                  .where("paymentStatus", isEqualTo: false)
                                  .orderBy("createdDate", descending: true)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Something went wrong'.tr));
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Constant.loader(
                                      isDarkTheme: themeChange.getThem());
                                }
                                return snapshot.data!.docs.isEmpty
                                    ? Center(
                                        child: Text("No active rides found".tr),
                                      )
                                    : ListView.builder(
                                        itemCount: snapshot.data!.docs.length,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          OrderModel orderModel =
                                              OrderModel.fromJson(snapshot
                                                      .data!.docs[index]
                                                      .data()
                                                  as Map<String, dynamic>);

                                          return InkWell(
                                            onTap: () {
                                             /* Get.to(
                                                  const CompleteOrderScreen(),
                                                  arguments: {
                                                    "orderModel": orderModel,
                                                  });*/
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: themeChange.getThem()
                                                      ? AppColors
                                                          .darkContainerBackground
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppColors
                                                                  .qlypDeepNavy
                                                              : AppColors
                                                                  .qlypDeepNavy,
                                                      width: 0.5),
                                                  boxShadow: themeChange
                                                          .getThem()
                                                      ? null
                                                      : [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.12),
                                                            blurRadius: 20,
                                                            spreadRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                          ),
                                                        ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      orderModel.status ==
                                                                  Constant
                                                                      .rideComplete ||
                                                              orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideActive
                                                          ? const SizedBox()
                                                          : Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    orderModel
                                                                        .status
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  orderModel.status ==
                                                                          Constant
                                                                              .ridePlaced
                                                                      ? Constant.amountShow(
                                                                          amount: double.parse(orderModel.offerRate.toString()).toStringAsFixed(Constant
                                                                              .currencyModel!
                                                                              .decimalDigits!))
                                                                      : Constant.amountShow(
                                                                          amount: double.parse(orderModel.finalRate.toString()).toStringAsFixed(Constant
                                                                              .currencyModel!
                                                                              .decimalDigits!)),
                                                                  style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                      orderModel.status ==
                                                                  Constant
                                                                      .rideComplete ||
                                                              orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideActive
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10),
                                                              child: DriverView(
                                                                driverId: orderModel
                                                                    .driverId
                                                                    .toString(),
                                                              ),
                                                            )
                                                          : Container(),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      LocationView(
                                                        sourceLocation: orderModel
                                                            .sourceLocationName
                                                            .toString(),
                                                        destinationLocation:
                                                            orderModel
                                                                .destinationLocationName
                                                                .toString(),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      orderModel.someOneElse !=
                                                              null
                                                          ? Container(
                                                              decoration: BoxDecoration(
                                                                  color: themeChange.getThem()
                                                                      ? AppColors
                                                                          .darkGray
                                                                      : AppColors
                                                                          .gray,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              10))),
                                                              child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          10),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text(orderModel.someOneElse!.fullName.toString().tr,
                                                                                style: GoogleFonts.poppins()),
                                                                            Text(orderModel.someOneElse!.contactNumber.toString().tr,
                                                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            await Share.share(
                                                                              subject: 'Ride Booked'.tr,
                                                                              'Your ride is booked. and you enjoy this ride and here is a otp to conform this ride ${orderModel.otp}'.tr,
                                                                            );
                                                                          },
                                                                          child:
                                                                              const Icon(Icons.share))
                                                                    ],
                                                                  )),
                                                            )
                                                          : const SizedBox(),
                                                      if (orderModel
                                                                  .acceptHoldTime !=
                                                              null &&
                                                          orderModel.status ==
                                                              Constant
                                                                  .rideHoldAccepted)
                                                        HoldTimerWidget(
                                                          acceptHoldTime:
                                                              orderModel
                                                                  .acceptHoldTime!,
                                                          holdingMinuteCharge:
                                                              orderModel
                                                                      .service
                                                                      ?.prices
                                                                      ?.first
                                                                      .holdingMinuteCharge ??
                                                                  '0.0',
                                                          holdingMinute: orderModel
                                                                  .service
                                                                  ?.prices
                                                                  ?.first
                                                                  .holdingMinute ??
                                                              '0.0',
                                                          orderId:
                                                              orderModel.id!,
                                                          orderModel:
                                                              orderModel,
                                                        ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppColors
                                                                      .darkGray
                                                                  : AppColors
                                                                      .gray,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          10))),
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Expanded(
                                                                    child: orderModel.status == Constant.rideInProgress ||
                                                                            orderModel.status ==
                                                                                Constant
                                                                                    .ridePlaced ||
                                                                            orderModel.status ==
                                                                                Constant
                                                                                    .rideComplete
                                                                        ? Text(orderModel
                                                                            .status
                                                                            .toString())
                                                                        : Row(
                                                                            children: [
                                                                              Text("OTP".tr, style: GoogleFonts.poppins()),
                                                                              Text(" : ${orderModel.otp}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                                                                            ],
                                                                          ),
                                                                  ),
                                                                  Text(
                                                                      Constant().formatTimestamp(
                                                                          orderModel
                                                                              .createdDate),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12)),
                                                                ],
                                                              )),
                                                        ),
                                                      ),
                                                      Visibility(
                                                          visible: orderModel
                                                                  .status ==
                                                              Constant
                                                                  .ridePlaced,
                                                          child: ButtonThem
                                                              .buildButton(
                                                            context,
                                                            title:
                                                                "View bids (${orderModel.acceptedDriverId != null ? orderModel.acceptedDriverId!.length.toString() : "0"})"
                                                                    .tr,
                                                            btnHeight: 48,
                                                            onPress: () async {
                                                              Get.to(
                                                                  const OrderDetailsScreen(),
                                                                  arguments: {
                                                                    "orderModel":
                                                                        orderModel,
                                                                  });
                                                              // paymentMethodDialog(context, controller, orderModel);
                                                            },
                                                          )),
                                                      Visibility(
                                                          visible: orderModel
                                                                  .status !=
                                                              Constant
                                                                  .ridePlaced,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    UserModel?
                                                                        customer =
                                                                        await FireStoreUtils.getUserProfile(orderModel
                                                                            .userId
                                                                            .toString());
                                                                    DriverUserModel?
                                                                        driver =
                                                                        await FireStoreUtils.getDriver(orderModel
                                                                            .driverId
                                                                            .toString());

                                                                    Get.to(
                                                                        ChatScreens(
                                                                      driverId:
                                                                          driver!
                                                                              .id,
                                                                      customerId:
                                                                          customer!
                                                                              .id,
                                                                      customerName:
                                                                          customer
                                                                              .fullName,
                                                                      customerProfileImage:
                                                                          customer
                                                                              .profilePic,
                                                                      driverName:
                                                                          driver
                                                                              .fullName,
                                                                      driverProfileImage:
                                                                          driver
                                                                              .profilePic,
                                                                      orderId:
                                                                          orderModel
                                                                              .id,
                                                                      token: driver
                                                                          .fcmToken,
                                                                    ));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 44,
                                                                    decoration: BoxDecoration(
                                                                        color: themeChange.getThem()
                                                                            ? AppColors
                                                                                .darksecondprimary
                                                                            : AppColors
                                                                                .lightsecondprimary,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    child: Icon(
                                                                        Icons
                                                                            .chat,
                                                                        color: themeChange.getThem()
                                                                            ? Colors.black
                                                                            : Colors.white),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    DriverUserModel?
                                                                        driver =
                                                                        await FireStoreUtils.getDriver(orderModel
                                                                            .driverId
                                                                            .toString());
                                                                    Constant.makePhoneCall(
                                                                        "${driver!.countryCode}${driver.phoneNumber}");
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 44,
                                                                    decoration: BoxDecoration(
                                                                        color: themeChange.getThem()
                                                                            ? AppColors
                                                                                .darksecondprimary
                                                                            : AppColors
                                                                                .lightsecondprimary,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    child: Icon(
                                                                        Icons
                                                                            .call,
                                                                        color: themeChange.getThem()
                                                                            ? Colors.black
                                                                            : Colors.white),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    if (Constant
                                                                            .mapType ==
                                                                        "inappmap") {
                                                                      if (orderModel.status ==
                                                                              Constant
                                                                                  .rideActive ||
                                                                          orderModel.status ==
                                                                              Constant.rideInProgress) {
                                                                        Get.to(
                                                                            const LiveTrackingScreen(),
                                                                            arguments: {
                                                                              "orderModel": orderModel,
                                                                              "type": "orderModel",
                                                                            });
                                                                      }
                                                                    } else {
                                                                      Utils.redirectMap(
                                                                          latitude: orderModel
                                                                              .destinationLocationLAtLng!
                                                                              .latitude!,
                                                                          longLatitude: orderModel
                                                                              .destinationLocationLAtLng!
                                                                              .longitude!,
                                                                          name: orderModel
                                                                              .destinationLocationName
                                                                              .toString());
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 44,
                                                                    decoration: BoxDecoration(
                                                                        color: themeChange.getThem()
                                                                            ? AppColors
                                                                                .darksecondprimary
                                                                            : AppColors
                                                                                .lightsecondprimary,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    child: Icon(
                                                                        Icons
                                                                            .map,
                                                                        color: themeChange.getThem()
                                                                            ? Colors.black
                                                                            : Colors.white),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Visibility(
                                                          visible: orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideInProgress ||
                                                              orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideHold ||
                                                              orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideHoldAccepted,
                                                          child: ButtonThem
                                                              .buildButton(
                                                            context,
                                                            title: "SOS".tr,
                                                            btnHeight: 44,
                                                            onPress: () async {
                                                              await FireStoreUtils.getSOS(
                                                                      orderModel
                                                                          .id
                                                                          .toString())
                                                                  .then(
                                                                      (value) {
                                                                if (value !=
                                                                    null) {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Your request is ${value.status}");
                                                                } else {
                                                                  SosModel
                                                                      sosModel =
                                                                      SosModel();
                                                                  sosModel.id =
                                                                      Constant
                                                                          .getUuid();
                                                                  sosModel.orderId =
                                                                      orderModel
                                                                          .id;
                                                                  sosModel.status =
                                                                      "Initiated";
                                                                  sosModel.orderType =
                                                                      "city";
                                                                  FireStoreUtils
                                                                      .setSOS(
                                                                          sosModel);
                                                                }
                                                              });
                                                            },
                                                          )),
                                                      orderModel.status ==
                                                              Constant
                                                                  .rideInProgress
                                                          ? const SizedBox(
                                                              height: 10,
                                                            )
                                                          : SizedBox.shrink(),
                                                      Visibility(
                                                          visible: orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideInProgress &&
                                                              (orderModel.totalHoldingCharges ==
                                                                      null ||
                                                                  orderModel
                                                                          .totalHoldingCharges ==
                                                                      "0.0"),
                                                          child: ButtonThem
                                                              .buildButton(
                                                            context,
                                                            title: "HOLD".tr,
                                                            btnHeight: 44,
                                                            onPress: () async {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        'Are you sure you want to hold the ride?'
                                                                            .tr),
                                                                    actions: [
                                                                      SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Container(
                                                                            height: 40,
                                                                            width: 70,
                                                                            color: Colors.black,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(top: 12.0),
                                                                              child: Text(
                                                                                'No',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                            )),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          ShowToastDialog.showLoader(
                                                                              "Please wait...".tr);
                                                                          orderModel.status =
                                                                              Constant.rideHold;
                                                                          await FireStoreUtils.setOrder(orderModel)
                                                                              .then((value) {
                                                                            if (value ==
                                                                                true) {
                                                                              ShowToastDialog.closeLoader();
                                                                              ShowToastDialog.showToast("Ride on Hold".tr);
                                                                            }
                                                                          });
                                                                          Get.back();
                                                                        },
                                                                        child: Container(
                                                                            height: 40,
                                                                            width: 70,
                                                                            color: Colors.black,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(top: 12.0),
                                                                              child: Text('Yes'.tr, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          )),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Visibility(
                                                          visible: orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideComplete &&
                                                              (orderModel.paymentStatus ==
                                                                      null ||
                                                                  orderModel
                                                                          .paymentStatus ==
                                                                      false),
                                                          child: ButtonThem
                                                              .buildButton(
                                                            context,
                                                            title: "Pay".tr,
                                                            btnHeight: 44,
                                                            onPress: () async {
                                                              Get.to(
                                                                  const PaymentOrderScreen(),
                                                                  arguments: {
                                                                    "orderModel":
                                                                        orderModel,
                                                                  });
                                                              // paymentMethodDialog(context, controller, orderModel);
                                                            },
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                              },
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(CollectionName.orders)
                                  .where("userId",
                                      isEqualTo: FireStoreUtils.getCurrentUid())
                                  .where("status",
                                      isEqualTo: Constant.rideComplete)
                                  .where("paymentStatus", isEqualTo: true)
                                  .orderBy("createdDate", descending: true)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Something went wrong'.tr));
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Constant.loader(
                                      isDarkTheme: themeChange.getThem());
                                }
                                return snapshot.data!.docs.isEmpty
                                    ? Center(
                                        child:
                                            Text("No completed rides found".tr),
                                      )
                                    : ListView.builder(
                                        itemCount: snapshot.data!.docs.length,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          OrderModel orderModel =
                                              OrderModel.fromJson(snapshot
                                                      .data!.docs[index]
                                                      .data()
                                                  as Map<String, dynamic>);
                                          return Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: themeChange.getThem()
                                                    ? AppColors
                                                        .darkContainerBackground
                                                    : AppColors
                                                        .containerBackground,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                border: Border.all(
                                                    color: themeChange.getThem()
                                                        ? AppColors
                                                            .darkContainerBorder
                                                        : AppColors
                                                            .containerBorder,
                                                    width: 0.5),
                                                boxShadow: themeChange.getThem()
                                                    ? null
                                                    : [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.10),
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                              0,
                                                              4), // changes position of shadow
                                                        ),
                                                      ],
                                              ),
                                              child: InkWell(
                                                  onTap: () {
                                                    Get.to(
                                                        const CompleteOrderScreen(),
                                                        arguments: {
                                                          "orderModel":
                                                              orderModel,
                                                        });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        DriverView(
                                                          driverId: orderModel
                                                              .driverId
                                                              .toString(),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 4),
                                                          child: Divider(
                                                            thickness: 1,
                                                          ),
                                                        ),
                                                        LocationView(
                                                          sourceLocation: orderModel
                                                              .sourceLocationName
                                                              .toString(),
                                                          destinationLocation:
                                                              orderModel
                                                                  .destinationLocationName
                                                                  .toString(),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 14),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: themeChange
                                                                        .getThem()
                                                                    ? AppColors
                                                                        .darkGray
                                                                    : AppColors
                                                                        .gray,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            10))),
                                                            child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        12),
                                                                child: Center(
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                          child: Text(
                                                                              orderModel.status.toString(),
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
                                                                      Text(
                                                                          Constant().formatTimestamp(orderModel
                                                                              .createdDate),
                                                                          style:
                                                                              GoogleFonts.poppins()),
                                                                    ],
                                                                  ),
                                                                )),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: ButtonThem
                                                                    .buildButton(
                                                              context,
                                                              title:
                                                                  "Review".tr,
                                                              btnHeight: 44,
                                                              onPress:
                                                                  () async {
                                                                Get.to(
                                                                    const ReviewScreen(),
                                                                    arguments: {
                                                                      "type":
                                                                          "orderModel",
                                                                      "orderModel":
                                                                          orderModel,
                                                                    });
                                                              },
                                                            )),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          );
                                        });
                              },
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(CollectionName.orders)
                                  .where("userId",
                                      isEqualTo: FireStoreUtils.getCurrentUid())
                                  .where("status",
                                      isEqualTo: Constant.rideCanceled)
                                  .orderBy("createdDate", descending: true)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Something went wrong'.tr));
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Constant.loader(
                                      isDarkTheme: themeChange.getThem());
                                }
                                return snapshot.data!.docs.isEmpty
                                    ? Center(
                                        child:
                                            Text("No canceled rides found".tr),
                                      )
                                    : ListView.builder(
                                        itemCount: snapshot.data!.docs.length,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          OrderModel orderModel =
                                              OrderModel.fromJson(snapshot
                                                      .data!.docs[index]
                                                      .data()
                                                  as Map<String, dynamic>);
                                          return Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: themeChange.getThem()
                                                    ? AppColors
                                                        .darkContainerBackground
                                                    : AppColors
                                                        .containerBackground,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                border: Border.all(
                                                    color: themeChange.getThem()
                                                        ? AppColors
                                                            .darkContainerBorder
                                                        : AppColors
                                                            .containerBorder,
                                                    width: 0.5),
                                                boxShadow: themeChange.getThem()
                                                    ? null
                                                    : [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.10),
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                              0,
                                                              4), // changes position of shadow
                                                        ),
                                                      ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    orderModel.status ==
                                                                Constant
                                                                    .rideComplete ||
                                                            orderModel.status ==
                                                                Constant
                                                                    .rideActive
                                                        ? const SizedBox()
                                                        : Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  orderModel
                                                                      .status
                                                                      .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                              Text(
                                                                Constant.amountShow(
                                                                    amount: double.parse(orderModel
                                                                            .offerRate
                                                                            .toString())
                                                                        .toStringAsFixed(Constant
                                                                            .currencyModel!
                                                                            .decimalDigits!)),
                                                                style: GoogleFonts.poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    LocationView(
                                                      sourceLocation: orderModel
                                                          .sourceLocationName
                                                          .toString(),
                                                      destinationLocation:
                                                          orderModel
                                                              .destinationLocationName
                                                              .toString(),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 14),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppColors
                                                                    .darkGray
                                                                : AppColors
                                                                    .gray,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(
                                                                    Radius.circular(
                                                                        10))),
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                    child: Text(
                                                                        orderModel
                                                                            .status
                                                                            .toString())),
                                                                Text(
                                                                    Constant().formatTimestamp(
                                                                        orderModel
                                                                            .createdDate),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            12)),
                                                              ],
                                                            )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(DarkThemeProvider themeChange) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: _DropdownTabBar(themeChange: themeChange),
    );
  }
}

/// Custom dropdown-style tab bar that controls a TabController.
class _DropdownTabBar extends StatefulWidget {
  final DarkThemeProvider themeChange;

  const _DropdownTabBar({required this.themeChange});

  @override
  State<_DropdownTabBar> createState() => _DropdownTabBarState();
}

class _DropdownTabBarState extends State<_DropdownTabBar> {
  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final isDark = widget.themeChange.getThem();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.index;
        final tabs = [
          "Active Rides".tr,
          "Completed Rides".tr,
          "Canceled Rides".tr
        ];

        return Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkContainerBackground : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: PopupMenuButton<int>(
                initialValue: selected,
                onSelected: (int value) {
                  controller.animateTo(value);
                },
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                itemBuilder: (BuildContext context) {
                  return List.generate(tabs.length, (index) {
                    final isItemSelected = selected == index;
                    return PopupMenuItem<int>(
                      value: index,
                      child: Text(
                        tabs[index],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isItemSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isItemSelected
                              ? AppColors.qlypDeepNavy
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    );
                  });
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Text(
                        tabs[selected],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.qlypDeepNavy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.qlypDeepNavy,
                        size: 24,
                      ),
                      const Spacer(),
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
}
