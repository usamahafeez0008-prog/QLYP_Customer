import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/model/driver_rules_model.dart';
import 'package:customer/model/language_name.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/order/positions.dart';
import 'package:customer/model/subscription_plan_model.dart';

class DriverUserModel {
  bool? isEnabled;
  String? phoneNumber;
  String? loginType;
  String? countryCode;
  String? profilePic;
  bool? documentVerification;
  String? fullName;
  bool? isOnline;
  String? id;
  String? serviceId;
  List<LanguageName>? serviceName;
  String? fcmToken;
  String? email;
  VehicleInformation? vehicleInformation;
  String? reviewsCount;
  String? reviewsSum;
  String? walletAmount;
  LocationLatLng? location;
  double? rotation;
  Positions? position;
  Timestamp? createdAt;
  List<dynamic>? zoneIds;
  String? subscriptionTotalOrders;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  SubscriptionPlanModel? subscriptionPlan;
  String? ownerId;

  DriverUserModel(
      {this.isEnabled,
      this.phoneNumber,
      this.loginType,
      this.countryCode,
      this.profilePic,
      this.documentVerification,
      this.fullName,
      this.isOnline,
      this.id,
      this.serviceId,
      this.serviceName,
      this.fcmToken,
      this.email,
      this.location,
      this.vehicleInformation,
      this.reviewsCount,
      this.reviewsSum,
      this.rotation,
      this.position,
      this.walletAmount,
      this.createdAt,
      this.zoneIds,
      this.subscriptionTotalOrders,
      this.subscriptionPlanId,
      this.subscriptionExpiryDate,
      this.subscriptionPlan,
      this.ownerId});

  DriverUserModel.fromJson(Map<String, dynamic> json) {
    isEnabled = json['isEnabled'];
    phoneNumber = json['phoneNumber'];
    loginType = json['loginType'];
    countryCode = json['countryCode'];
    profilePic = json['profilePic'] ?? '';
    documentVerification = json['documentVerification'];
    fullName = json['fullName'];
    isOnline = json['isOnline'];
    id = json['id'];
    serviceId = json['serviceId'];
    fcmToken = json['fcmToken'];
    email = json['email'];
    vehicleInformation = json['vehicleInformation'] != null ? VehicleInformation.fromJson(json['vehicleInformation']) : null;
    reviewsCount = json['reviewsCount'] ?? '0.0';
    reviewsSum = json['reviewsSum'] ?? '0.0';
    rotation = json['rotation'] != null ? double.parse(json['rotation'].toString()) : 0.0;
    walletAmount = json['walletAmount'] ?? "0.0";
    location = json['location'] != null ? LocationLatLng.fromJson(json['location']) : null;
    position = json['position'] != null ? Positions.fromJson(json['position']) : null;
    createdAt = json['createdAt'];
    zoneIds = json['zoneIds'];
    subscriptionTotalOrders = json['subscriptionTotalOrders'];
    subscriptionPlanId = json['subscriptionPlanId'];
    subscriptionExpiryDate = json['subscriptionExpiryDate'];
    subscriptionPlan = json['subscription_plan'] != null ? SubscriptionPlanModel.fromJson(json['subscription_plan']) : null;
    ownerId = json['ownerId'];
    if (json['serviceName'] != null) {
      serviceName = <LanguageName>[];
      json['serviceName'].forEach((v) {
        serviceName!.add(LanguageName.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isEnabled'] = isEnabled;
    data['phoneNumber'] = phoneNumber;
    data['loginType'] = loginType;
    data['countryCode'] = countryCode;
    data['profilePic'] = profilePic;
    data['documentVerification'] = documentVerification;
    data['fullName'] = fullName;
    data['isOnline'] = isOnline;
    data['id'] = id;
    data['serviceId'] = serviceId;
    data['fcmToken'] = fcmToken;
    data['email'] = email;
    data['rotation'] = rotation;
    data['createdAt'] = createdAt;
    if (vehicleInformation != null) {
      data['vehicleInformation'] = vehicleInformation!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['reviewsCount'] = reviewsCount;
    data['reviewsSum'] = reviewsSum;
    data['walletAmount'] = walletAmount;
    data['zoneIds'] = zoneIds;
    if (position != null) {
      data['position'] = position!.toJson();
    }
    data['subscriptionTotalOrders'] = subscriptionTotalOrders;
    data['subscriptionPlanId'] = subscriptionPlanId;
    data['subscriptionExpiryDate'] = subscriptionExpiryDate;
    data['subscription_plan'] = subscriptionPlan?.toJson();
    data['ownerId'] = ownerId;
    if (serviceName != null) {
      data['serviceName'] = serviceName!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleInformation {
  Timestamp? registrationDate;
  String? vehicleColor;
  String? vehicleNumber;
  String? seats;
  List<DriverRulesModel>? driverRules;
  List<RateModel>? rates;

  VehicleInformation({
    this.registrationDate,
    this.vehicleColor,
    this.vehicleNumber,
    this.seats,
    this.driverRules,
    this.rates,
  });

  VehicleInformation.fromJson(Map<String, dynamic> json) {
    registrationDate = json['registrationDate'];
    vehicleColor = json['vehicleColor'];
    vehicleNumber = json['vehicleNumber'];
    seats = json['seats'];
    if (json['driverRules'] != null) {
      driverRules = <DriverRulesModel>[];
      json['driverRules'].forEach((v) {
        driverRules!.add(DriverRulesModel.fromJson(v));
      });
    }
    if (json['rates'] != null) {
      rates = <RateModel>[];
      json['rates'].forEach((v) {
        rates!.add(RateModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['registrationDate'] = registrationDate;
    data['vehicleColor'] = vehicleColor;
    data['vehicleNumber'] = vehicleNumber;
    data['seats'] = seats;
    if (driverRules != null) {
      data['driverRules'] = driverRules!.map((v) => v.toJson()).toList();
    }
    if (rates != null) {
      data['rates'] = rates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RateModel {
  String? acPerKmRate;
  String? nonAcPerKmRate;
  String? perKmRate;
  String? zoneId;

  RateModel({this.acPerKmRate, this.nonAcPerKmRate, this.perKmRate, this.zoneId});

  RateModel.fromJson(Map<String, dynamic> json) {
    acPerKmRate = json['acPerKmRate'];
    nonAcPerKmRate = json['nonAcPerKmRate'];
    perKmRate = json['perKmRate'];
    zoneId = json['zoneId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['acPerKmRate'] = acPerKmRate;
    data['nonAcPerKmRate'] = nonAcPerKmRate;
    data['perKmRate'] = perKmRate;
    data['zoneId'] = zoneId;
    return data;
  }
}
