import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/admin_commission.dart';
import 'package:customer/model/airport_model.dart';
import 'package:customer/model/banner_model.dart';
import 'package:customer/model/conversation_model.dart';
import 'package:customer/model/coupon_model.dart';
import 'package:customer/model/currency_model.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/faq_model.dart';
import 'package:customer/model/freight_vehicle.dart';
import 'package:customer/model/inbox_model.dart';
import 'package:customer/model/intercity_order_model.dart';
import 'package:customer/model/intercity_service_model.dart';
import 'package:customer/model/language_model.dart';
import 'package:customer/model/language_privacy_policy.dart';
import 'package:customer/model/language_terms_condition.dart';
import 'package:customer/model/on_boarding_model.dart';
import 'package:customer/model/order/driverId_accept_reject.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/owner_user_model.dart';
import 'package:customer/model/payment_model.dart';
import 'package:customer/model/referral_model.dart';
import 'package:customer/model/review_model.dart';
import 'package:customer/model/service_model.dart';
import 'package:customer/model/sos_model.dart';
import 'package:customer/model/tax_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/model/wallet_transaction_model.dart';
import 'package:customer/model/zone_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:customer/widget/geoflutterfire/src/models/point.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExitOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  Future<void> getSettings() async {
    await fireStore.collection(CollectionName.settings).doc("globalValue").get().then((value) {
      if (value.exists) {
        AppColors.darksecondprimary = Color(int.parse(value.data()!['app_customer_color'].replaceFirst("#", "0xff")));
        AppColors.lightsecondprimary = Color(int.parse(value.data()!['app_customer_light_color'].replaceFirst("#", "0xff")));
        Constant.distanceType = value.data()!["distanceType"];
        Constant.radius = value.data()!["radius"];
        Constant.mapType = value.data()!["mapType"];
        Constant.selectedMapType = value.data()!["selectedMapType"];
        Constant.driverLocationUpdate = value.data()!["driverLocationUpdate"];
        Constant.regionCode = value.data()!["regionCode"];
        Constant.regionCountry = value.data()!["regionCountry"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("globalKey").get().then((value) {
      if (value.exists) {
        Constant.mapAPIKey = value.data()!["googleMapKey"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("notification_setting").get().then((value) {
      if (value.exists) {
        if (value.data() != null) {
          Constant.senderId = value.data()!['senderId'].toString();
          Constant.jsonNotificationFileURL = value.data()!['serviceJson'].toString();
        }
      }
    });

    await fireStore.collection(CollectionName.settings).doc("global").get().then((value) {
      if (value.exists) {
        if (value.data()!["privacyPolicy"] != null) {
          Constant.privacyPolicy = <LanguagePrivacyPolicy>[];
          value.data()!["privacyPolicy"].forEach((v) {
            Constant.privacyPolicy.add(LanguagePrivacyPolicy.fromJson(v));
          });
        }

        if (value.data()!["termsAndConditions"] != null) {
          Constant.termsAndConditions = <LanguageTermsCondition>[];
          value.data()!["termsAndConditions"].forEach((v) {
            Constant.termsAndConditions.add(LanguageTermsCondition.fromJson(v));
          });
        }

        Constant.appVersion = value.data()!["appVersion"];
        // Constant.globalUrl = value.data()!["websiteUrl"] ?? '';
      }
    });

    fireStore.collection(CollectionName.settings).doc("adminCommission").snapshots().listen((value) {
      if (value.data() != null) {
        AdminCommission adminCommission = AdminCommission.fromJson(value.data()!);
        if (adminCommission.isEnabled == true) {
          Constant.adminCommission = adminCommission;
        }
      }
    });

    await fireStore.collection(CollectionName.settings).doc("referral").get().then((value) {
      if (value.exists) {
        Constant.referralCustomerAmount = value.data()!["referralAmount"];
        Constant.referralDriverAmount = value.data()!["referralAmountDriver"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("contact_us").get().then((value) {
      if (value.exists) {
        Constant.supportURL = value.data()!["supportURL"];
      }
    });
  }

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future updateReferralAmount(OrderModel orderModel) async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(orderModel.userId).get().then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel?.referralBy != null && referralModel?.referralBy?.isNotEmpty == true) {
        await fireStore.collection(CollectionName.users).doc(referralModel?.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;

          if (userDocument.data() != null && userDocument.exists) {
            try {
              UserModel user = UserModel.fromJson(userDocument.data()!);
              double referralAmount = double.parse(Constant.referralCustomerAmount ?? '0.0');
              bool? isUpdatedWallet = await updatedCustomerWalletById(customerId: user.id!, referralAmount: referralAmount);

              if (isUpdatedWallet == true) {
                WalletTransactionModel transactionModel = WalletTransactionModel(
                    id: Constant.getUuid(),
                    amount: referralAmount.toString(),
                    createdDate: Timestamp.now(),
                    paymentType: "Wallet",
                    transactionId: orderModel.id,
                    userId: user.id.toString(),
                    orderType: "city",
                    userType: "customer",
                    note: "Referral Amount");

                await FireStoreUtils.setWalletTransaction(transactionModel);
              }
            } catch (error) {
              print(error);
            }
          }
        });

        await fireStore.collection(CollectionName.driverUsers).doc(referralModel?.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> driverDocument = value;

          if (driverDocument.data() != null && driverDocument.exists) {
            try {
              DriverUserModel driver = DriverUserModel.fromJson(driverDocument.data()!);
              double referralAmount = double.parse(Constant.referralDriverAmount ?? '0.0');
              bool? isUpdatedWallet = await updatedDriverWalletById(driverId: driver.id!, referralAmount: referralAmount);

              if (isUpdatedWallet == true) {
                WalletTransactionModel transactionModel = WalletTransactionModel(
                    id: Constant.getUuid(),
                    amount: referralAmount.toString(),
                    createdDate: Timestamp.now(),
                    paymentType: "Wallet",
                    transactionId: orderModel.id,
                    userId: driver.id.toString(),
                    orderType: "city",
                    userType: "driver",
                    note: "Referral Amount");

                await FireStoreUtils.setWalletTransaction(transactionModel);
              }
            } catch (error) {
              print(error);
            }
          }
        });
      } else {
        return;
      }
    }
  }

  static Future updateDriverReferralAmount(OrderModel orderModel) async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(orderModel.driverId).get().then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel!.referralBy != null && referralModel!.referralBy!.isNotEmpty) {
        await fireStore.collection(CollectionName.driverUsers).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;

          if (userDocument.data() != null && userDocument.exists) {
            try {
              DriverUserModel driver = DriverUserModel.fromJson(userDocument.data()!);
              double referralAmount = double.parse(Constant.referralDriverAmount ?? '0.0');
              bool? isUpdatedWallet = await updatedDriverWalletById(driverId: driver.id!, referralAmount: referralAmount);

              if (isUpdatedWallet == true) {
                WalletTransactionModel transactionModel = WalletTransactionModel(
                    id: Constant.getUuid(),
                    amount: referralAmount.toString(),
                    createdDate: Timestamp.now(),
                    paymentType: "Wallet",
                    transactionId: orderModel.id,
                    userId: driver.id.toString(),
                    orderType: "city",
                    userType: "driver",
                    note: "Referral Amount");

                await FireStoreUtils.setWalletTransaction(transactionModel);
              }
            } catch (error) {
              print(error);
            }
          }
        });

        await fireStore.collection(CollectionName.users).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;

          if (userDocument.data() != null && userDocument.exists) {
            try {
              UserModel user = UserModel.fromJson(userDocument.data()!);
              double referralAmount = double.parse(Constant.referralCustomerAmount ?? '0.0');
              bool? isUpdatedWallet = await updatedCustomerWalletById(customerId: user.id!, referralAmount: referralAmount);

              if (isUpdatedWallet == true) {
                WalletTransactionModel transactionModel = WalletTransactionModel(
                    id: Constant.getUuid(),
                    amount: referralAmount.toString(),
                    createdDate: Timestamp.now(),
                    paymentType: "Wallet",
                    transactionId: orderModel.id,
                    userId: user.id.toString(),
                    orderType: "city",
                    userType: "customer",
                    note: "Referral Amount");

                await FireStoreUtils.setWalletTransaction(transactionModel);
              }
            } catch (error) {
              print(error);
            }
          }
        });
      } else {
        return;
      }
    }
  }

  static Future updateIntercityReferralAmount(InterCityOrderModel orderModel) async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(orderModel.userId).get().then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel!.referralBy != null && referralModel!.referralBy!.isNotEmpty) {
        await fireStore.collection(CollectionName.users).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              UserModel user = UserModel.fromJson(userDocument.data()!);
              double referralAmount = double.parse(Constant.referralCustomerAmount ?? '0.0');
              bool? isUpdatedWallet = await updatedCustomerWalletById(customerId: user.id!, referralAmount: referralAmount);

              if (isUpdatedWallet == true) {
                WalletTransactionModel transactionModel = WalletTransactionModel(
                    id: Constant.getUuid(),
                    amount: referralAmount.toString(),
                    createdDate: Timestamp.now(),
                    paymentType: "Wallet",
                    transactionId: orderModel.id,
                    userId: user.id.toString(),
                    orderType: "intercity",
                    userType: "customer",
                    note: "Referral Amount");

                await FireStoreUtils.setWalletTransaction(transactionModel);
              }
            } catch (error) {
              print(error);
            }
          }
        });

        await fireStore.collection(CollectionName.driverUsers).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              DriverUserModel driver = DriverUserModel.fromJson(userDocument.data()!);
              double referralAmount = double.parse(Constant.referralDriverAmount ?? '0.0');
              bool? isUpdatedWallet = await updatedDriverWalletById(driverId: driver.id!, referralAmount: referralAmount);

              if (isUpdatedWallet == true) {
                WalletTransactionModel transactionModel = WalletTransactionModel(
                    id: Constant.getUuid(),
                    amount: referralAmount.toString(),
                    createdDate: Timestamp.now(),
                    paymentType: "Wallet",
                    transactionId: orderModel.id,
                    userId: driver.id.toString(),
                    orderType: "intercity",
                    userType: "driver",
                    note: "Referral Amount");

                await FireStoreUtils.setWalletTransaction(transactionModel);
              }
            } catch (error) {
              print(error);
            }
          }
        });
      } else {
        return;
      }
    }
  }

  static Future updateDriverIntercityReferralAmount(InterCityOrderModel orderModel) async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(orderModel.driverId).get().then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel!.referralBy != null && referralModel!.referralBy!.isNotEmpty) {
        await fireStore.collection(CollectionName.driverUsers).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              DriverUserModel driver = DriverUserModel.fromJson(userDocument.data()!);
              double referralAmount = double.parse(Constant.referralDriverAmount ?? '0.0');
              bool? isUpdatedWallet = await updatedDriverWalletById(driverId: driver.id!, referralAmount: referralAmount);

              if (isUpdatedWallet == true) {
                WalletTransactionModel transactionModel = WalletTransactionModel(
                    id: Constant.getUuid(),
                    amount: referralAmount.toString(),
                    createdDate: Timestamp.now(),
                    paymentType: "Wallet",
                    transactionId: orderModel.id,
                    userId: driver.id.toString(),
                    orderType: "intercity",
                    userType: "driver",
                    note: "Referral Amount");

                await FireStoreUtils.setWalletTransaction(transactionModel);
              }
            } catch (error) {
              print(error);
            }
          }
        });

        await fireStore.collection(CollectionName.users).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              UserModel user = UserModel.fromJson(userDocument.data()!);
              double referralAmount = double.parse(Constant.referralCustomerAmount ?? '0.0');
              bool? isUpdatedWallet = await updatedCustomerWalletById(customerId: user.id!, referralAmount: referralAmount);

              if (isUpdatedWallet == true) {
                WalletTransactionModel transactionModel = WalletTransactionModel(
                    id: Constant.getUuid(),
                    amount: referralAmount.toString(),
                    createdDate: Timestamp.now(),
                    paymentType: "Wallet",
                    transactionId: orderModel.id,
                    userId: user.id.toString(),
                    orderType: "intercity",
                    userType: "customer",
                    note: "Referral Amount");

                await FireStoreUtils.setWalletTransaction(transactionModel);
              }
            } catch (error) {
              print(error);
            }
          }
        });
      } else {
        return;
      }
    }
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data() as Map<String, dynamic>);
        log("Intercity :: userModel :: ${userModel?.id}");
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<DriverUserModel?> getDriver(String uuid) async {
    DriverUserModel? driverUserModel;
    await fireStore.collection(CollectionName.driverUsers).doc(uuid).get().then((value) {
      if (value.exists) {
        driverUserModel = DriverUserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      driverUserModel = null;
    });
    return driverUserModel;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.users).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<bool?> updatedCustomerWalletById({required double referralAmount, required String customerId}) async {
    bool isAdded = false;
    await getUserProfile(customerId).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount = (double.parse(userModel.walletAmount ?? '0.0') + referralAmount).toStringAsFixed(2);
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool?> updatedDriverWalletById({required double referralAmount, required String driverId}) async {
    bool isAdded = false;
    await getDriver(driverId).then((value) async {
      if (value != null) {
        DriverUserModel userModel = value;
        userModel.walletAmount = (double.parse(userModel.walletAmount ?? '0.0') + referralAmount).toStringAsFixed(2);
        await FireStoreUtils.updateDriver(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool> updateDriver(DriverUserModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.driverUsers).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
      log("Intercity :: userModel :::::::: ${userModel.id} :: ${userModel.walletAmount}");
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<bool> getCustomerFirstOrderOrNOt({required String customerId, required String orderType}) async {
    try {
      final ordersSnapshot = await fireStore.collection(CollectionName.orders).where('userId', isEqualTo: customerId).where('status', isEqualTo: Constant.rideComplete).get();

      final intercitySnapshot = await fireStore.collection(CollectionName.ordersIntercity).where('userId', isEqualTo: customerId).where('status', isEqualTo: Constant.rideComplete).get();
      if (orderType == 'order') {
        if (ordersSnapshot.docs.length <= 1 && intercitySnapshot.docs.isEmpty) {
          return true;
        } else {
          return false;
        }
      } else {
        if (intercitySnapshot.docs.length <= 1 && ordersSnapshot.docs.isEmpty) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> getDriverFirstOrderOrNOt({required String driverId, required String orderType}) async {
    try {
      final cityOrders = await fireStore.collection(CollectionName.orders).where('driverId', isEqualTo: driverId).where('status', isEqualTo: Constant.rideComplete).get();

      final interCityOrders = await fireStore.collection(CollectionName.ordersIntercity).where('driverId', isEqualTo: driverId).where('status', isEqualTo: Constant.rideComplete).get();

      if (orderType == 'order') {
        if (cityOrders.docs.length <= 1 && interCityOrders.docs.isEmpty) {
          return true;
        } else {
          return false;
        }
      } else {
        if (interCityOrders.docs.length <= 1 && cityOrders.docs.isEmpty) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool?> rejectRide(OrderModel orderModel, DriverIdAcceptReject driverIdAcceptReject) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.orders).doc(orderModel.id).collection("rejectedDriver").doc(driverIdAcceptReject.driverId).set(driverIdAcceptReject.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<OrderModel?> getOrder(String orderId) async {
    OrderModel? orderModel;
    await fireStore.collection(CollectionName.orders).doc(orderId).get().then((value) {
      if (value.data() != null) {
        orderModel = OrderModel.fromJson(value.data()!);
      }
    });
    return orderModel;
  }

  static Future<InterCityOrderModel?> getInterCityOrder(String orderId) async {
    InterCityOrderModel? orderModel;
    await fireStore.collection(CollectionName.ordersIntercity).doc(orderId).get().then((value) {
      if (value.data() != null) {
        orderModel = InterCityOrderModel.fromJson(value.data()!);
      }
    });
    return orderModel;
  }

  static Future<bool> userExitOrNot(String uid) async {
    bool isExit = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then((value) {
      if (value.exists) {
        isExit = true;
      } else {
        isExit = false;
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      isExit = false;
    });
    return isExit;
  }

  static Future<String> userExitCustomerOrDriverRole(String uid) async {
    String role = '';
    try {
      await fireStore.collection(CollectionName.users).doc(uid).get().then((value) {
        if (value.exists) {
          role = Constant.currentUserType!;
        } else {
          role = '';
        }
      });
      if (role == '') {
        await fireStore.collection(CollectionName.driverUsers).doc(uid).get().then((value) {
          if (value.exists) {
            role = Constant.driverType!;
          } else {
            role = '';
          }
        });
      }
      if (role == '') {
        await fireStore.collection(CollectionName.ownerUsers).doc(uid).get().then((value) {
          if (value.exists) {
            role = Constant.ownerType;
          } else {
            role = '';
          }
        });
      }
    } catch (e) {
      role = '';
    }
    return role;
  }

  static Future<List<ServiceModel>> getService() async {
    List<ServiceModel> serviceList = [];
    await fireStore.collection(CollectionName.service).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        ServiceModel documentModel = ServiceModel.fromJson(element.data());
        serviceList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return serviceList;
  }

  static Future<List<BannerModel>> getBanner() async {
    List<BannerModel> bannerList = [];
    await fireStore.collection(CollectionName.banner).where('enable', isEqualTo: true).where('isDeleted', isEqualTo: false).orderBy('position', descending: false).get().then((value) {
      for (var element in value.docs) {
        BannerModel documentModel = BannerModel.fromJson(element.data());
        bannerList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return bannerList;
  }

  static Future<List<IntercityServiceModel>> getIntercityService() async {
    List<IntercityServiceModel> serviceList = [];
    await fireStore.collection(CollectionName.intercityService).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        IntercityServiceModel documentModel = IntercityServiceModel.fromJson(element.data());
        serviceList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return serviceList;
  }

  static Future<List<FreightVehicle>> getFreightVehicle() async {
    List<FreightVehicle> freightVehicle = [];
    await fireStore.collection(CollectionName.freightVehicle).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        FreightVehicle documentModel = FreightVehicle.fromJson(element.data());
        freightVehicle.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return freightVehicle;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.orders).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  StreamController<List<DriverUserModel>>? getNearestOrderRequestController;

  Stream<List<DriverUserModel>> sendOrderData(OrderModel orderModel) async* {
    getNearestOrderRequestController ??= StreamController<List<DriverUserModel>>.broadcast();

    List<DriverUserModel> ordersList = [];

    Query<Map<String, dynamic>> query =
        fireStore.collection(CollectionName.driverUsers).where('serviceId', isEqualTo: orderModel.serviceId).where('zoneIds', arrayContains: orderModel.zoneId).where('isOnline', isEqualTo: true);

    GeoFirePoint center = Geoflutterfire().point(latitude: orderModel.sourceLocationLAtLng!.latitude ?? 0.0, longitude: orderModel.sourceLocationLAtLng!.longitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = Geoflutterfire().collection(collectionRef: query).within(center: center, radius: double.parse(Constant.radius), field: 'position', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      if (getNearestOrderRequestController != null) {
        for (var document in documentList) {
          final data = document.data() as Map<String, dynamic>;

          DriverUserModel orderModel = DriverUserModel.fromJson(data);

          ordersList.add(orderModel);
        }

        if (!getNearestOrderRequestController!.isClosed) {
          getNearestOrderRequestController!.sink.add(ordersList);
        }
        closeStream();
      }
    });
    yield* getNearestOrderRequestController!.stream;
  }

  Future<List<DriverUserModel>> sendOrderDataFuture(OrderModel orderModel) async {
    List<DriverUserModel> ordersList = [];

    Query<Map<String, dynamic>> query =
        fireStore.collection(CollectionName.driverUsers).where('serviceId', isEqualTo: orderModel.serviceId).where('zoneIds', arrayContains: orderModel.zoneId).where('isOnline', isEqualTo: true);

    GeoFirePoint center = Geoflutterfire().point(
      latitude: orderModel.sourceLocationLAtLng!.latitude ?? 0.0,
      longitude: orderModel.sourceLocationLAtLng!.longitude ?? 0.0,
    );

    // Fetching documents using GeoFlutterFire's `within` function.
    List<DocumentSnapshot> documentList = await Geoflutterfire()
        .collection(collectionRef: query)
        .within(
          center: center,
          radius: double.parse(Constant.radius),
          field: 'position',
          strictMode: true,
        )
        .first; // Get the first batch of documents.

    for (var document in documentList) {
      final data = document.data() as Map<String, dynamic>;
      DriverUserModel orderModel = DriverUserModel.fromJson(data);
      ordersList.add(orderModel);
    }

    return ordersList;
  }

  closeStream() {
    if (getNearestOrderRequestController != null) {
      getNearestOrderRequestController == null;
      getNearestOrderRequestController!.close();
    }
  }

  static Future<bool?> setInterCityOrder(InterCityOrderModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.ordersIntercity).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<DriverIdAcceptReject?> getAcceptedOrders(String orderId, String driverId) async {
    DriverIdAcceptReject? driverIdAcceptReject;
    await fireStore.collection(CollectionName.orders).doc(orderId).collection("acceptedDriver").doc(driverId).get().then((value) async {
      if (value.exists) {
        driverIdAcceptReject = DriverIdAcceptReject.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      driverIdAcceptReject = null;
    });
    return driverIdAcceptReject;
  }

  static Future<DriverIdAcceptReject?> getInterCItyAcceptedOrders(String orderId, String driverId) async {
    DriverIdAcceptReject? driverIdAcceptReject;
    await fireStore.collection(CollectionName.ordersIntercity).doc(orderId).collection("acceptedDriver").doc(driverId).get().then((value) async {
      if (value.exists) {
        driverIdAcceptReject = DriverIdAcceptReject.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      driverIdAcceptReject = null;
    });
    return driverIdAcceptReject;
  }

  static Future<OrderModel?> getOrderById(String orderId) async {
    OrderModel? orderModel;
    await fireStore.collection(CollectionName.orders).doc(orderId).get().then((value) async {
      if (value.exists) {
        orderModel = OrderModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      orderModel = null;
    });
    return orderModel;
  }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    await fireStore.collection(CollectionName.settings).doc("payment").get().then((value) {
      paymentModel = PaymentModel.fromJson(value.data()!);
    });
    return paymentModel;
  }

  Future<CurrencyModel?> getCurrency() async {
    CurrencyModel? currencyModel;
    await fireStore.collection(CollectionName.currency).where("enable", isEqualTo: true).get().then((value) {
      if (value.docs.isNotEmpty) {
        currencyModel = CurrencyModel.fromJson(value.docs.first.data());
      }
    });
    return currencyModel;
  }

  Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];
    await fireStore.collection(CollectionName.tax).where('country', isEqualTo: Constant.country).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return taxList;
  }

  Future<List<CouponModel>?> getCoupon() async {
    List<CouponModel> couponModel = [];

    await fireStore
        .collection(CollectionName.coupon)
        .where('enable', isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .where('validity', isGreaterThanOrEqualTo: Timestamp.now())
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        couponModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return couponModel;
  }

  static Future<bool?> setReview(ReviewModel reviewModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.reviewDriver).doc(reviewModel.id).set(reviewModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    ReviewModel? reviewModel;
    await fireStore.collection(CollectionName.reviewDriver).doc(orderId).get().then((value) {
      if (value.data() != null) {
        reviewModel = ReviewModel.fromJson(value.data()!);
      }
    });
    return reviewModel;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionModel = [];

    await fireStore.collection(CollectionName.walletTransaction).where('userId', isEqualTo: FireStoreUtils.getCurrentUid()).orderBy('createdDate', descending: true).get().then((value) {
      for (var element in value.docs) {
        WalletTransactionModel taxModel = WalletTransactionModel.fromJson(element.data());
        walletTransactionModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionModel;
  }

  static Future<bool?> setWalletTransaction(WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.walletTransaction).doc(walletTransactionModel.id).set(walletTransactionModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> updateUserWallet({required String amount}) async {
    bool isAdded = false;
    await getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount = (double.parse(userModel.walletAmount.toString()) + double.parse(amount)).toString();
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool?> updateDriverWallet({required String driverId, required String amount}) async {
    bool isAdded = false;
    log("Intercity :: userModel :::: $driverId");
    await getDriver(driverId).then((value) async {
      if (value?.id != null) {
        DriverUserModel userModel = value!;
        userModel.walletAmount = (double.parse(userModel.walletAmount ?? '0.0') + double.parse(amount)).toString();
        log("Intercity :: userModel :::::: ${userModel.id} :: ${userModel.walletAmount}");
        await FireStoreUtils.updateDriver(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<List<LanguageModel>?> getLanguage() async {
    List<LanguageModel> languageList = [];

    await fireStore.collection(CollectionName.languages).where("enable", isEqualTo: true).where("isDeleted", isEqualTo: false).get().then((value) {
      for (var element in value.docs) {
        LanguageModel taxModel = LanguageModel.fromJson(element.data());
        languageList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return languageList;
  }

  static Future<ReferralModel?> getReferral() async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        referralModel = ReferralModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      referralModel = null;
    });
    return referralModel;
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<ReferralModel?> getReferralUserByCode(String referralCode) async {
    ReferralModel? referralModel;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        referralModel = ReferralModel.fromJson(value.docs.first.data());
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await fireStore.collection(CollectionName.referral).doc(ratingModel.id).set(ratingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore.collection(CollectionName.onBoarding).where("type", isEqualTo: "customerApp").get().then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel = OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future addInBox(InboxModel inboxModel) async {
    return await fireStore.collection("chat").doc(inboxModel.orderId).set(inboxModel.toJson()).then((document) {
      return inboxModel;
    });
  }

  static Future addChat(ConversationModel conversationModel) async {
    return await fireStore.collection("chat").doc(conversationModel.orderId).collection("thread").doc(conversationModel.id).set(conversationModel.toJson()).then((document) {
      return conversationModel;
    });
  }

  static Future<List<FaqModel>> getFaq() async {
    List<FaqModel> faqModel = [];
    await fireStore.collection(CollectionName.faq).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        FaqModel documentModel = FaqModel.fromJson(element.data());
        faqModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return faqModel;
  }

  static Future<bool> deleteUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return false;
      }
      final String userId = currentUser.uid;
      if (userId.isEmpty) {
        return false;
      }
      await fireStore.collection(CollectionName.users).doc(userId).delete();
      await FireStoreUtils.deleteReferralCode(userId);
      await FireStoreUtils.deleteAuthUser(FireStoreUtils.getCurrentUid());
      //await FirebaseAuth.instance.currentUser?.delete();
      return true;
    } catch (e, s) {
      log('deleteUser: Failed to delete user. Error: $e\nStackTrace: $s');
      return false;
    }
  }

  static Future<bool?> deleteReferralCode(String uid) async {
    bool? isDelete;
    try {
      await fireStore.collection(CollectionName.referral).doc(uid).delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  static Future<bool?> setSOS(SosModel sosModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.sos).doc(sosModel.id).set(sosModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<SosModel?> getSOS(String orderId) async {
    SosModel? sosModel;
    try {
      await fireStore.collection(CollectionName.sos).where("orderId", isEqualTo: orderId).get().then((value) {
        sosModel = SosModel.fromJson(value.docs.first.data());
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return sosModel;
  }

  Future<List<AriPortModel>?> getAirports() async {
    List<AriPortModel> airPortList = [];

    await fireStore.collection(CollectionName.airPorts).where('cityLocation', isEqualTo: Constant.city).get().then((value) {
      for (var element in value.docs) {
        AriPortModel ariPortModel = AriPortModel.fromJson(element.data());
        airPortList.add(ariPortModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return airPortList;
  }

  static Future<bool> paymentStatusCheck() async {
    ShowToastDialog.showLoader("Please wait");
    bool isFirst = false;
    await fireStore
        .collection(CollectionName.orders)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .where("status", isEqualTo: Constant.rideComplete)
        .where("paymentStatus", isEqualTo: false)
        .get()
        .then((value) {
      ShowToastDialog.closeLoader();
      if (value.size >= 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future<bool> paymentStatusCheckIntercity() async {
    ShowToastDialog.showLoader("Please wait");
    bool isFirst = false;
    await fireStore
        .collection(CollectionName.ordersIntercity)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .where("status", isEqualTo: Constant.rideComplete)
        .where("paymentStatus", isEqualTo: false)
        .get()
        .then((value) {
      ShowToastDialog.closeLoader();
      print(value.size);
      if (value.size >= 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  Future<List<ZoneModel>?> getZone() async {
    List<ZoneModel> airPortList = [];
    await fireStore.collection(CollectionName.zone).where('publish', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        ZoneModel ariPortModel = ZoneModel.fromJson(element.data());
        airPortList.add(ariPortModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return airPortList;
  }

  static late StreamSubscription<QuerySnapshot> adminChatSeenSubscription;
  static void setSeen() {
    final currentUserId = FireStoreUtils.getCurrentUid();

    adminChatSeenSubscription = FirebaseFirestore.instance
        .collection(CollectionName.chat)
        .doc(currentUserId)
        .collection("thread")
        .where('senderId', isEqualTo: Constant.adminType)
        .where('seen', isEqualTo: false)
        .snapshots()
        .listen((querySnapshot) async {
      for (final doc in querySnapshot.docs) {
        try {
          await doc.reference.update({'seen': true});
        } catch (e) {
          log(e.toString());
        }
      }
    }, onError: (error) {
      log(error.toString());
    });
  }

  static void stopSeenListener() {
    adminChatSeenSubscription.cancel();
  }

  static late StreamSubscription<QuerySnapshot> driverChatSeenSubscription;
  static void setDriverChatSeen({required String orderId, required String driverId}) {
    driverChatSeenSubscription =
        fireStore.collection("chat").doc(orderId).collection("thread").where('senderId', isEqualTo: driverId).where('seen', isEqualTo: false).snapshots().listen((querySnapshot) async {
      for (final doc in querySnapshot.docs) {
        try {
          await doc.reference.update({'seen': true});
        } catch (e) {
          log(e.toString());
        }
      }
    }, onError: (error) {
      log(error.toString());
    });
  }

  static void stopDriverSeenListener() {
    driverChatSeenSubscription.cancel();
  }

  static Future addInAdminBox(InboxModel inboxModel) async {
    return await fireStore.collection(CollectionName.chat).doc(FireStoreUtils.getCurrentUid()).set(inboxModel.toJson()).then((document) {
      return inboxModel;
    });
  }

  static Future addAdminChat(ConversationModel conversationModel) async {
    return await fireStore.collection(CollectionName.chat).doc(conversationModel.senderId).collection("thread").doc(conversationModel.id).set(conversationModel.toJson()).then((document) {
      return conversationModel;
    });
  }

  static Future<OwnerUserModel?> getOwnerProfile(String uuid) async {
    OwnerUserModel? ownerModel;
    await fireStore.collection(CollectionName.ownerUsers).doc(uuid).get().then((value) {
      if (value.exists) {
        ownerModel = OwnerUserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      ownerModel = null;
    });
    return ownerModel;
  }

  static Future<bool?> updatedOwnerWallet({required String amount, required String ownerId}) async {
    bool isAdded = false;
    await getOwnerProfile(ownerId).then((value) async {
      if (value != null) {
        OwnerUserModel userModel = value;
        userModel.walletAmount = (double.parse(userModel.walletAmount.toString()) + double.parse(amount)).toString();
        await FireStoreUtils.updateOwnerUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool> updateOwnerUser(OwnerUserModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.ownerUsers).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<ServiceModel> getServiceById(String? id) async {
    ServiceModel serviceList = ServiceModel();
    await fireStore.collection(CollectionName.service).where('id', isEqualTo: id).where('enable', isEqualTo: true).get().then((value) {
      serviceList = ServiceModel.fromJson(value.docs.first.data());
    }).catchError((error) {
      log(error.toString());
    });
    return serviceList;
  }

  static Future<void> deleteAuthUser(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      if (idToken == null) {
        print("No user is logged in to get ID token.");
        return;
      }

      const projectId = "goride-1a752";
      final url = Uri.parse("https://us-central1-$projectId.cloudfunctions.net/deleteUser");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({
          "data": {"uid": uid},
        }),
      );

      if (response.statusCode == 200) {
        print("User deleted successfully: ${response.body}");
      } else {
        print(" Error deleting user: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception while deleting user: $e");
    }
  }
}
