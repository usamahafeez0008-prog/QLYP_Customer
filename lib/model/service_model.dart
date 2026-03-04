import 'package:customer/model/admin_commission.dart';
import 'package:customer/model/language_name.dart';

class ServiceModel {
  String? image;
  bool? enable;
  bool? offerRate;
  bool? intercityType;
  String? id;
  List<LanguageName>? title;
  String? markerIcon;
  AdminCommission? adminCommission;
  List<Price>? prices;

  ServiceModel({this.image, this.enable, this.intercityType, this.offerRate, this.id, this.markerIcon, this.title, this.adminCommission, this.prices});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    enable = json['enable'];
    offerRate = json['offerRate'];
    id = json['id'];
    markerIcon = json['markerIcon'];
    intercityType = json['intercityType'];
    adminCommission = json['adminCommission'] != null ? AdminCommission.fromJson(json['adminCommission']) : AdminCommission(isEnabled: true, amount: "", type: "");
    if (json['title'] != null) {
      title = <LanguageName>[];
      json['title'].forEach((v) {
        title!.add(LanguageName.fromJson(v));
      });
    }
    if (json['prices'] != null) {
      prices = List<Price>.from(
        (json['prices'] as List).map((item) => Price.fromMap(item)),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['enable'] = enable;
    data['offerRate'] = offerRate;
    data['id'] = id;
    data['markerIcon'] = markerIcon;
    data['title'] = title;
    data['intercityType'] = intercityType;
    if (title != null) {
      data['title'] = title!.map((v) => v.toJson()).toList();
    }

    if (adminCommission != null) {
      data['adminCommission'] = adminCommission!.toJson();
    }
    data['prices'] = prices?.map((e) => e.toMap()).toList();
    return data;
  }
}

class Price {
  String? acCharge;
  String? basicFare;
  String? basicFareCharge;
  String? endNightTime;
  String? holdingMinute;
  String? holdingMinuteCharge;
  bool? isAcNonAc;
  String? kmCharge;
  String? nightCharge;
  String? nonAcCharge;
  String? perMinuteCharge;
  String? startNightTime;
  String? zoneId;

  Price({
    this.acCharge,
    this.basicFare,
    this.basicFareCharge,
    this.endNightTime,
    this.holdingMinute,
    this.holdingMinuteCharge,
    this.isAcNonAc,
    this.kmCharge,
    this.nightCharge,
    this.nonAcCharge,
    this.perMinuteCharge,
    this.startNightTime,
    this.zoneId,
  });

  factory Price.fromMap(Map<String, dynamic> map) {
    return Price(
      acCharge: map['acCharge'],
      basicFare: map['basicFare'] ?? '',
      basicFareCharge: map['basicFareCharge'] ?? '',
      endNightTime: map['endNightTime'] ?? '',
      holdingMinute: map['holdingMinute'] ?? '',
      holdingMinuteCharge: map['holdingMinuteCharge'] ?? '',
      isAcNonAc: map['isAcNonAc'] ?? false,
      kmCharge: map['kmCharge'] ?? '',
      nightCharge: map['nightCharge'] ?? '',
      nonAcCharge: map['nonAcCharge'],
      perMinuteCharge: map['perMinuteCharge'] ?? '',
      startNightTime: map['startNightTime'] ?? '',
      zoneId: map['zoneId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'acCharge': acCharge,
      'basicFare': basicFare,
      'basicFareCharge': basicFareCharge,
      'endNightTime': endNightTime,
      'holdingMinute': holdingMinute,
      'holdingMinuteCharge': holdingMinuteCharge,
      'isAcNonAc': isAcNonAc,
      'kmCharge': kmCharge,
      'nightCharge': nightCharge,
      'nonAcCharge': nonAcCharge,
      'perMinuteCharge': perMinuteCharge,
      'startNightTime': startNightTime,
      'zoneId': zoneId,
    };
  }
}
