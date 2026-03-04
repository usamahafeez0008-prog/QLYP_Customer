import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/model/subscription_plan_model.dart';

class OwnerUserModel {
  String? phoneNumber;
  String? loginType;
  String? countryCode;
  String? profilePic;
  bool? documentVerification;
  String? fullName;
  String? id;
  String? fcmToken;
  String? email;
  String? walletAmount;
  Timestamp? createdAt;
  String? subscriptionTotalOrders;
  String? subscriptionTotalDrivers;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  SubscriptionPlanModel? subscriptionPlan;

  OwnerUserModel(
      {this.phoneNumber,
      this.loginType,
      this.countryCode,
      this.profilePic,
      this.documentVerification,
      this.fullName,
      this.id,
      this.fcmToken,
      this.email,
      this.walletAmount,
      this.createdAt,
      this.subscriptionTotalOrders,
      this.subscriptionTotalDrivers,
      this.subscriptionPlanId,
      this.subscriptionExpiryDate,
      this.subscriptionPlan});

  OwnerUserModel.fromJson(Map<String, dynamic> json) {
    phoneNumber = json['phoneNumber'];
    loginType = json['loginType'];
    countryCode = json['countryCode'];
    profilePic = json['profilePic'] ?? '';
    documentVerification = json['documentVerification'];
    fullName = json['fullName'];
    id = json['id'];
    fcmToken = json['fcmToken'];
    email = json['email'];
    walletAmount = json['walletAmount'] ?? "0.0";
    createdAt = json['createdAt'];
    subscriptionTotalOrders = json['subscriptionTotalOrders'];
    subscriptionTotalDrivers = json['subscriptionTotalDrivers'];
    subscriptionPlanId = json['subscriptionPlanId'];
    subscriptionExpiryDate = json['subscriptionExpiryDate'];
    subscriptionPlan = json['subscription_plan'] != null ? SubscriptionPlanModel.fromJson(json['subscription_plan']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phoneNumber'] = phoneNumber;
    data['loginType'] = loginType;
    data['countryCode'] = countryCode;
    data['profilePic'] = profilePic;
    data['documentVerification'] = documentVerification;
    data['fullName'] = fullName;
    data['id'] = id;
    data['fcmToken'] = fcmToken;
    data['email'] = email;
    data['createdAt'] = createdAt;
    data['walletAmount'] = walletAmount;
    data['subscriptionTotalOrders'] = subscriptionTotalOrders;
    data['subscriptionTotalDrivers'] = subscriptionTotalDrivers;
    data['subscriptionPlanId'] = subscriptionPlanId;
    data['subscriptionExpiryDate'] = subscriptionExpiryDate;
    data['subscription_plan'] = subscriptionPlan?.toJson();
    return data;
  }
}
