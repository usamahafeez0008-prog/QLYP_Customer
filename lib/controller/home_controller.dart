import 'dart:convert';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/dash_board_controller.dart';
import 'package:customer/model/airport_model.dart';
import 'package:customer/model/banner_model.dart';
import 'package:customer/model/contact_model.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/payment_model.dart';
import 'package:customer/model/service_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/model/zone_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  DashBoardController dashboardController = Get.put(DashBoardController());

  Rx<TextEditingController> sourceLocationController = TextEditingController().obs;
  Rx<TextEditingController> destinationLocationController = TextEditingController().obs;
  Rx<TextEditingController> offerYourRateController = TextEditingController().obs;
  Rx<ServiceModel> selectedType = ServiceModel().obs;

  Rx<LocationLatLng> sourceLocationLAtLng = LocationLatLng().obs;
  Rx<LocationLatLng> destinationLocationLAtLng = LocationLatLng().obs;

  RxString currentLocation = "".obs;
  RxBool isLoading = true.obs;
  RxList<ServiceModel> serviceList = <ServiceModel>[].obs;
  RxList bannerList = <BannerModel>[].obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  Rx<ZoneModel> selectedZone = ZoneModel().obs;
  Rx<UserModel> userModel = UserModel().obs;
  RxBool isAcSelected = false.obs;
  RxDouble extraDistance = 0.0.obs;
  final PageController pageController = PageController(viewportFraction: 0.96, keepPage: true);

  var colors = [
    AppColors.serviceColor1,
    AppColors.serviceColor2,
    AppColors.serviceColor3,
  ];

  String? startNightTime;
  String? endNightTime;
  DateTime startNightTimeString = DateTime.now();
  DateTime endNightTimeString = DateTime.now();

  @override
  void onInit() {
    // TODO: implement onInit
    getLocation();
    getServiceType();
    getPaymentData();
    getContact();
    super.onInit();
  }

  Future<void> getLocation() async {
    try {
      Constant.currentLocation = await Utils.getCurrentLocation();
      if (Constant.currentLocation == null) return;

      List<Placemark> placeMarks = await placemarkFromCoordinates(
        Constant.currentLocation!.latitude,
        Constant.currentLocation!.longitude,
      );
      Constant.country = placeMarks.first.country;
      Constant.city = placeMarks.first.locality;
      currentLocation.value =
          "${placeMarks.first.name}, ${placeMarks.first.subLocality}, ${placeMarks.first.locality}, ${placeMarks.first.administrativeArea}, ${placeMarks.first.postalCode}, ${placeMarks.first.country}";
      getTax();
    } catch (e) {
      ShowToastDialog.showToast(
        "Location access permission is currently unavailable. You're unable to retrieve any location data. Please grant permission from your device settings.",
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> getTax() async {
    await FireStoreUtils().getTaxList().then((value) {
      if (value != null) {
        Constant.taxList = value;
      }
    });
  }

  Future<void> getServiceType() async {
    await FireStoreUtils.getService().then((value) {
      serviceList.value = value;
      if (serviceList.isNotEmpty) {
        selectedType.value = serviceList.first;
      }
    });

    await FireStoreUtils.getBanner().then((value) {
      bannerList.value = value;
    });

    await FireStoreUtils().getAirports().then((value) {
      if (value != null) {
        Constant.airaPortList = value;
      }
    });

    String token = await NotificationService.getToken();
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      userModel.value = value!;
      userModel.value.fcmToken = token;
      FireStoreUtils.updateUser(userModel.value);
    });

    isLoading.value = false;
  }

  RxString duration = "".obs;
  RxString distance = "".obs;
  RxString amount = "".obs;
  RxString acCharge = "".obs;
  RxString nonAcCharge = "".obs;
  RxString basicFare = "".obs;
  RxString basicFareCharge = "".obs;
  RxString nightCharge = "".obs;
  RxDouble totalAmount = 0.0.obs;
  RxDouble totalNightFare = 0.0.obs;
  RxBool isAcNonAc = false.obs;
  DateTime currentTime = DateTime.now();
  DateTime currentDate = DateTime.now();

  double convertToMinutes(String duration) {
    double durationValue = 0.0;

    try {
      final RegExp hoursRegex = RegExp(r"(\d+)\s*hour");
      final RegExp minutesRegex = RegExp(r"(\d+)\s*min");

      final Match? hoursMatch = hoursRegex.firstMatch(duration);
      if (hoursMatch != null) {
        int hours = int.parse(hoursMatch.group(1)!.trim());
        durationValue += hours * 60;
      }

      final Match? minutesMatch = minutesRegex.firstMatch(duration);
      if (minutesMatch != null) {
        int minutes = int.parse(minutesMatch.group(1)!.trim());
        durationValue += minutes;
      }
    } catch (e) {
      print("Exception: $e");
      throw FormatException("Invalid duration format: $duration");
    }

    return durationValue;
  }

  Future<void> calculateDurationAndDistance() async {
    if (Constant.selectedMapType == 'osm') {
      if (sourceLocationLAtLng.value.latitude != null && destinationLocationLAtLng.value.latitude != null) {
        ShowToastDialog.showLoader("Please wait");
        await Constant.getDurationOsmDistance(
                LatLng(sourceLocationLAtLng.value.latitude!, sourceLocationLAtLng.value.longitude!), LatLng(destinationLocationLAtLng.value.latitude!, destinationLocationLAtLng.value.longitude!))
            .then((value) {
          if (value != {} && value.isNotEmpty) {
            int hours = value['routes'].first['duration'] ~/ 3600;
            int minutes = ((value['routes'].first['duration'] % 3600) / 60).round();
            duration.value = '$hours hours $minutes minutes'.trim();
            if (Constant.distanceType == "Km") {
              distance.value = (value['routes'].first['distance'] / 1000).toString();
            } else {
              distance.value = (value['routes'].first['distance'] / 1609.34).toString();
            }
          }
          update();
        });
      }
      ShowToastDialog.closeLoader();
    } else {
      if (sourceLocationLAtLng.value.latitude != null && destinationLocationLAtLng.value.latitude != null) {
        ShowToastDialog.showLoader("Please wait");
        await Constant.getDurationDistance(
                LatLng(sourceLocationLAtLng.value.latitude!, sourceLocationLAtLng.value.longitude!), LatLng(destinationLocationLAtLng.value.latitude!, destinationLocationLAtLng.value.longitude!))
            .then((value) {
          if (value != null) {
            duration.value = value.rows!.first.elements!.first.duration!.text.toString();
            print("duration :: 00 :: ${duration.value}");
            if (Constant.distanceType == "Km") {
              distance.value = (value.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toString();
            } else {
              distance.value = (value.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toString();
            }
          }
          update();
        });
        ShowToastDialog.closeLoader();
      }
    }
  }

  Future<void> calculateAmount() async {
    acCharge.value = selectedType.value.prices?.first.acCharge ?? '0.0';
    nonAcCharge.value = selectedType.value.prices?.first.nonAcCharge ?? '0.0';
    basicFare.value = selectedType.value.prices?.first.basicFare ?? '0.0';
    basicFareCharge.value = selectedType.value.prices?.first.basicFareCharge ?? '0.0';
    isAcNonAc.value = selectedType.value.prices?.first.isAcNonAc ?? false;
    String formatTime(String? time) {
      if (time == null || !time.contains(":")) {
        return "00:00";
      }
      List<String> parts = time.split(':');
      if (parts.length != 2) return "00:00";
      return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
    }

    startNightTime = formatTime(selectedType.value.prices?.first.startNightTime);
    endNightTime = formatTime(selectedType.value.prices?.first.endNightTime);

    List<String> startParts = startNightTime!.split(':');
    List<String> endParts = endNightTime!.split(':');

    startNightTimeString = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(startParts[0]), int.parse(startParts[1]));
    endNightTimeString = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(endParts[0]), int.parse(endParts[1]));

    nightCharge.value = selectedType.value.prices?.first.nightCharge ?? '0.0';
    if (sourceLocationLAtLng.value.latitude != null && destinationLocationLAtLng.value.latitude != null) {
      double durationValueInMinutes = convertToMinutes(duration.toString());
      if (double.parse(distance.value) <= double.parse(basicFare.value)) {
        amount.value = ((double.parse(basicFareCharge.value.toString())) + (double.parse(durationValueInMinutes.toString()) * double.parse(selectedType.value.prices?.first.perMinuteCharge ?? '0.0')))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);

        totalNightFare.value = double.parse(amount.value);
        if (currentTime.isAfter(startNightTimeString) && currentTime.isBefore(endNightTimeString)) {
          amount.value = (totalNightFare.value * double.parse(nightCharge.value.toString())).toStringAsFixed(2);
        }
      } else {
        double distanceValue = double.tryParse(distance.value) ?? 0.0;
        double basicFareValue = double.tryParse(basicFare.value) ?? 0.0;
        double extraDist = distanceValue - basicFareValue;
        extraDistance.value = extraDist;
        double nonAcChargeValue = double.tryParse(nonAcCharge.value.toString()) ?? 0.0;
        double acChargeValue = double.tryParse(acCharge.value.toString()) ?? 0.0;
        double perKmCharge = isAcNonAc.value == true
            ? isAcSelected.value == false
                ? nonAcChargeValue
                : acChargeValue
            : double.parse(selectedType.value.prices?.first.kmCharge ?? '0.0');
        double perMinuteCharge = double.parse(selectedType.value.prices?.first.perMinuteCharge ?? '0.0');
        double durationInMinutes = double.parse(durationValueInMinutes.toString());
        double basicFareChargeValue = double.parse(basicFareCharge.value.toString());
        totalAmount.value = (perKmCharge * extraDist) + (durationInMinutes * perMinuteCharge) + basicFareChargeValue;

        totalNightFare.value = totalAmount.value;
        amount.value = totalNightFare.value.toStringAsFixed(2);

        if (currentTime.isAfter(startNightTimeString) && currentTime.isBefore(endNightTimeString)) {
          amount.value = (totalNightFare.value * double.parse(nightCharge.value.toString())).toStringAsFixed(2);
        }
      }
      offerYourRateController.value.text = amount.value;
    }
    update();
  }

  Rx<PaymentModel> paymentModel = PaymentModel().obs;

  RxString selectedPaymentMethod = "".obs;
  final selectedServiceCategory = "Taxi".obs;


  RxList airPortList = <AriPortModel>[].obs;

  Future<void> getPaymentData() async {
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
      }
    });

    await FireStoreUtils().getZone().then((value) {
      if (value != null) {
        zoneList.value = value;
      }
    });
  }

  RxList<ContactModel> contactList = <ContactModel>[].obs;
  Rx<ContactModel> selectedTakingRide = ContactModel(fullName: "Myself", contactNumber: "").obs;
  Rx<AriPortModel> selectedAirPort = AriPortModel().obs;

  setContact() {
    print(jsonEncode(contactList));
    Preferences.setString(Preferences.contactList, json.encode(contactList.map<Map<String, dynamic>>((music) => music.toJson()).toList()));
    getContact();
  }

  getContact() {
    String contactListJson = Preferences.getString(Preferences.contactList);

    if (contactListJson.isNotEmpty) {
      print("---->");
      contactList.clear();
      contactList.value = (json.decode(contactListJson) as List<dynamic>).map<ContactModel>((item) => ContactModel.fromJson(item)).toList();
    }
  }
}
