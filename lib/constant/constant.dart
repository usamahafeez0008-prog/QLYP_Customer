// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/ChatVideoContainer.dart';
import 'package:customer/model/admin_commission.dart';
import 'package:customer/model/airport_model.dart';
import 'package:customer/model/conversation_model.dart';
import 'package:customer/model/currency_model.dart';
import 'package:customer/model/language_description.dart';
import 'package:customer/model/language_model.dart';
import 'package:customer/model/language_name.dart';
import 'package:customer/model/language_privacy_policy.dart';
import 'package:customer/model/language_terms_condition.dart';
import 'package:customer/model/map_model.dart' as mapmodel;
import 'package:customer/model/tax_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Constant {
  static const String phoneLoginType = "phone";
  static const String googleLoginType = "google";
  static const String appleLoginType = "apple";
  static String mapAPIKey = "AIzaSyB_OGDt0ul9dwtsOlnXDzWZ7qV1TBVECnU";
  static String senderId = '';
  static String jsonNotificationFileURL = '';
  static String radius = "10";
  static String distanceType = "";
  static CurrencyModel? currencyModel;
  static AdminCommission? adminCommission;
  static String? referralCustomerAmount = "0";
  static String? referralDriverAmount = "0";
  static String? supportURL = "";
  static const commissionSubscriptionID = "J0RwvxCWhZzQQD7Kc2Ll";

  static List<LanguageTermsCondition> termsAndConditions = [];
  static List<LanguagePrivacyPolicy> privacyPolicy = [];
  static String appVersion = "";

  static String mapType = "google";
  static String selectedMapType = 'osm';
  static String driverLocationUpdate = "10";
  static String regionCode = "";
  static String regionCountry = "";
  static int totalHoldingCharges = 0;

  static const String ridePlaced = "Ride Placed";
  static const String rideActive = "Ride Active";
  static const String rideInProgress = "Ride InProgress";
  static const String rideComplete = "Ride Completed";
  static const String rideCanceled = "Ride Canceled";
  static const String rideHold = "Ride Hold";
  static const String rideHoldAccepted = "Ride Hold Accepted";

  static String globalUrl = "https://goride.siswebapp.com/";
  static const userPlaceHolder =
      "https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115";

  static Position? currentLocation;
  static String? country;
  static String? city;
  static List<TaxModel>? taxList;
  static List<AriPortModel>? airaPortList;

  static String? adminType = "admin";
  static String? currentUserType = "customer";
  static String? driverType = "driver";
  static String ownerType = "owner";

  static Widget loader({double strokeWidth = 4.0, required bool isDarkTheme}) {
    return Center(
      child: CircularProgressIndicator(color: isDarkTheme ? AppColors.qlypPrimaryFreshGreen : AppColors.qlypSecondaryWarmSand, strokeWidth: strokeWidth),
    );
  }

  static String localizationName(List<LanguageName>? name) {
    if (name?.firstWhere((element) => element.type == Constant.getLanguage().code).name?.isNotEmpty == true) {
      return name?.firstWhere((element) => element.type == Constant.getLanguage().code).name ?? '';
    } else {
      return name?.firstWhere((element) => element.type == "en").name ?? '';
    }
  }

  static String localizationTitle(List<LanguageName>? name) {
    if (name?.firstWhere((element) => element.type == Constant.getLanguage().code).title?.isNotEmpty == true) {
      return name?.firstWhere((element) => element.type == Constant.getLanguage().code).title ?? '';
    } else {
      return name?.firstWhere((element) => element.type == "en").title ?? '';
    }
  }

  static String localizationDescription(List<LanguageDescription>? name) {
    if (name!.firstWhere((element) => element.type == Constant.getLanguage().code).description!.isNotEmpty) {
      return name.firstWhere((element) => element.type == Constant.getLanguage().code).description!;
    } else {
      return name.firstWhere((element) => element.type == "en").description.toString();
    }
  }

  static String localizationPrivacyPolicy(List<LanguagePrivacyPolicy>? name) {
    if (name!.firstWhere((element) => element.type == Constant.getLanguage().code).privacyPolicy!.isNotEmpty) {
      return name.firstWhere((element) => element.type == Constant.getLanguage().code).privacyPolicy!;
    } else {
      return name.firstWhere((element) => element.type == "en").privacyPolicy.toString();
    }
  }

  static String localizationTermsCondition(List<LanguageTermsCondition>? name) {
    if (name!.firstWhere((element) => element.type == Constant.getLanguage().code).termsAndConditions!.isNotEmpty) {
      return name.firstWhere((element) => element.type == Constant.getLanguage().code).termsAndConditions!;
    } else {
      return name.firstWhere((element) => element.type == "en").termsAndConditions.toString();
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static bool? validateEmail(String? value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value ?? '')) {
      return false;
    } else {
      return true;
    }
  }

  static bool isPointInPolygon(LatLng point, List<GeoPoint> polygon) {
    int crossings = 0;
    for (int i = 0; i < polygon.length; i++) {
      int next = (i + 1) % polygon.length;
      if (polygon[i].latitude <= point.latitude && polygon[next].latitude > point.latitude || polygon[i].latitude > point.latitude && polygon[next].latitude <= point.latitude) {
        double edgeLong = polygon[next].longitude - polygon[i].longitude;
        double edgeLat = polygon[next].latitude - polygon[i].latitude;
        double interpol = (point.latitude - polygon[i].latitude) / edgeLat;
        if (point.longitude < polygon[i].longitude + interpol * edgeLong) {
          crossings++;
        }
      }
    }
    print("=====isPointInPolygon=${(crossings % 2 != 0)}");
    return (crossings % 2 != 0);
  }

  static Future<mapmodel.MapModel?> getDurationDistance(LatLng departureLatLong, LatLng destinationLatLong) async {
    try {
      String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
      http.Response restaurantToCustomerTime = await http.get(Uri.parse('$url?units=metric&origins=${departureLatLong.latitude},'
          '${departureLatLong.longitude}&destinations=${destinationLatLong.latitude},${destinationLatLong.longitude}&key=${Constant.mapAPIKey}'));

      log(restaurantToCustomerTime.body.toString());
      mapmodel.MapModel mapModel = mapmodel.MapModel.fromJson(jsonDecode(restaurantToCustomerTime.body));

      if (mapModel.status == 'OK' && mapModel.rows!.first.elements!.first.status == "OK") {
        return mapModel;
      } else {
        ShowToastDialog.showToast(mapModel.errorMessage);
      }
      return null;
    } catch (e) {
      ShowToastDialog.closeLoader();
      log("Error :: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> getDurationOsmDistance(LatLng departureLatLong, LatLng destinationLatLong) async {
    try {
      String url = 'http://router.project-osrm.org/route/v1/driving';
      String coordinates = '${departureLatLong.longitude},${departureLatLong.latitude};${destinationLatLong.longitude},${destinationLatLong.latitude}';

      http.Response response = await http.get(Uri.parse('$url/$coordinates?overview=false&steps=false'));

      log(response.body.toString());

      return jsonDecode(response.body);
    } catch (e) {
      ShowToastDialog.closeLoader();
      log("Error :: $e");
      return {};
    }
  }

  static double amountCalculate(String amount, String distance) {
    double finalAmount = 0.0;
    log("------->");
    log(amount);
    log(distance);
    finalAmount = double.parse(amount) * double.parse(distance);
    return finalAmount;
  }

  static String getUuid() {
    return const Uuid().v4();
  }

  String formatTimestamp(Timestamp? timestamp) {
    var format = DateFormat('dd-MM-yyyy hh:mm aa'); // <- use skeleton here
    return format.format(timestamp!.toDate());
  }

  static String dateAndTimeFormatTimestamp(Timestamp? timestamp) {
    var format = DateFormat('dd MMM yyyy hh:mm aa'); // <- use skeleton here
    return format.format(timestamp!.toDate());
  }

  static String dateFormatTimestamp(Timestamp? timestamp) {
    var format = DateFormat('dd MMM yyyy'); // <- use skeleton here
    return format.format(timestamp!.toDate());
  }

  double calculateTax({String? amount, TaxModel? taxModel}) {
    double taxAmount = 0.0;
    if (taxModel != null && taxModel.enable == true) {
      if (taxModel.type == "fix") {
        taxAmount = double.parse(taxModel.tax.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) * double.parse(taxModel.tax!.toString())) / 100;
      }
    }
    return taxAmount;
  }

  static String amountShow({required String? amount}) {
    if (Constant.currencyModel!.symbolAtRight == true) {
      return "${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}${Constant.currencyModel!.symbol.toString()}";
    } else {
      return "${Constant.currencyModel!.symbol.toString()}${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}";
    }
  }

  static double calculateOrderAdminCommission({String? amount, AdminCommission? adminCommission}) {
    double taxAmount = 0.0;
    if (adminCommission != null) {
      if (adminCommission.type == "fix") {
        taxAmount = double.parse(adminCommission.amount ?? '0.0');
      } else {
        taxAmount = (double.parse(amount ?? '0.0') * double.parse(adminCommission.amount ?? '0.0')) / 100;
      }
    }
    return taxAmount;
  }

  static String calculateReview({required String? reviewCount, required String? reviewSum}) {
    if (reviewCount == "0.0" && reviewSum == "0.0") {
      return "0.0";
    }
    return (double.parse(reviewSum.toString()) / double.parse(reviewCount.toString())).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
  }

  static bool IsNegative(double number) {
    return number < 0;
  }

  static LanguageModel getLanguage() {
    final String user = Preferences.getString(Preferences.languageCodeKey);
    Map<String, dynamic> userMap = jsonDecode(user);
    return LanguageModel.fromJson(userMap);
  }

  static String getReferralCode() {
    var rng = math.Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  bool hasValidUrl(String value) {
    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  static Future<String> uploadUserImageToFireStorage(File image, String filePath, String fileName) async {
    Reference upload = FirebaseStorage.instance.ref().child('$filePath/$fileName');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Future<String> uploadVoiceMessage(String filePath) async {
    final file = File(filePath);
    final ref = FirebaseStorage.instance.ref().child("voice_messages/${DateTime.now().millisecondsSinceEpoch}.m4a");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$secs";
  }

  Future<Url> uploadChatImageToFireStorage(File image) async {
    ShowToastDialog.showLoader('Uploading image...');
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('/chat/images/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(image);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  Future<ChatVideoContainer?> uploadChatVideoToFireStorage(File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef = FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );
      await uploadTask;
      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      final Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        maxWidth: 200,
        quality: 75,
      );

      if (thumbnailBytes == null || thumbnailBytes.isEmpty) {
        throw Exception("Failed to generate thumbnail.");
      }

      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef = FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      final UploadTask thumbnailUploadTask = thumbnailRef.putData(
        thumbnailBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await thumbnailUploadTask;
      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      // var metaData =
      await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(videoUrl: Url(url: videoUrl.toString(), mime: 'video/mp4'), thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('/thumbnails/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<Uint8List> getBytesFromUrl(String url, {int width = 100}) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("Failed to load image from $url");
    }

    final Uint8List bytes = response.bodyBytes;

    // Decode & resize
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
