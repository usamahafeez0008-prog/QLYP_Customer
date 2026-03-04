import 'package:customer/constant/constant.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class CompleteOrderController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Future<void> getDriver() async {
    await FireStoreUtils.getDriver(orderModel.value.driverId.toString()).then(
      (value) {
        if (value != null) {
          driverModel.value = value;
        }
      },
    );
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;

  RxString couponAmount = "0.0".obs;

  // double calculateAmount() {
  //   RxString taxAmount = "0.0".obs;
  //   if (orderModel.value.taxList != null) {
  //     for (var element in orderModel.value.taxList!) {
  //       taxAmount.value = (double.parse(taxAmount.value) +
  //               Constant().calculateTax(
  //                   amount:
  //                       (double.parse(orderModel.value.finalRate.toString()) -
  //                               double.parse(couponAmount.value.toString()))
  //                           .toString(),
  //                   taxModel: element))
  //           .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
  //     }
  //   }
  //   String totalHoldingCharge = orderModel.value.totalHoldingCharges != null
  //       ? orderModel.value.totalHoldingCharges.toString()
  //       : "0.0";
  //   return (double.parse(orderModel.value.finalRate.toString()) -
  //           double.parse(couponAmount.value.toString())) +
  //       double.parse(totalHoldingCharge.toString()) +
  //       double.parse(taxAmount.value);
  // }

  RxDouble amount = 0.0.obs;
  RxDouble subTotal = 0.0.obs;
  RxDouble total = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxString startNightTime = "".obs;
  RxString endNightTime = "".obs;
  RxDouble totalNightFare = 0.0.obs;
  RxDouble totalChargeOfMinute = 0.0.obs;
  RxDouble basicFareCharge = 0.0.obs;
  RxDouble holdingCharge = 0.0.obs;
  DateTime currentTime = DateTime.now();
  DateTime currentDate = DateTime.now();
  DateTime startNightTimeString = DateTime.now();
  DateTime endNightTimeString = DateTime.now();

  Future<void> calculateAmount() async {
    String formatTime(String? time) {
      if (time == null || !time.contains(":")) {
        return "00:00";
      }
      List<String> parts = time.split(':');
      if (parts.length != 2) return "00:00";
      return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
    }

    startNightTime.value = formatTime(orderModel.value.service?.prices?.first.startNightTime);
    endNightTime.value = formatTime(orderModel.value.service?.prices?.first.endNightTime);

    List<String> startParts = startNightTime.split(':');
    List<String> endParts = endNightTime.split(':');

    startNightTimeString = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(startParts[0]), int.parse(startParts[1]));
    endNightTimeString = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(endParts[0]), int.parse(endParts[1]));

    double durationValueInMinutes = convertToMinutes(orderModel.value.duration.toString());
    double distance = double.tryParse(orderModel.value.distance.toString()) ?? 0.0;
    double nonAcChargeValue = 0.0;
    double acChargeValue = 0.0;
    double kmCharge = 0.0;

    if (orderModel.value.driverId != null && orderModel.value.driverId!.isNotEmpty) {
      String nonAcPerKmRateData = driverModel.value.vehicleInformation?.rates?.firstWhere((prices) => prices.zoneId == orderModel.value.zoneId).nonAcPerKmRate ?? '1.0';
      String acPerKmRateData = driverModel.value.vehicleInformation?.rates?.firstWhere((prices) => prices.zoneId == orderModel.value.zoneId).acPerKmRate ?? '1.0';
      String perKmRateData = driverModel.value.vehicleInformation?.rates?.firstWhere((prices) => prices.zoneId == orderModel.value.zoneId).perKmRate ?? '1.0';
      nonAcChargeValue = double.tryParse(nonAcPerKmRateData) ?? 1.0;
      acChargeValue = double.tryParse(acPerKmRateData) ?? 1.0;
      kmCharge = double.tryParse(perKmRateData) ?? 1.0;
    } else {
      nonAcChargeValue = double.tryParse(orderModel.value.service!.prices!.first.nonAcCharge!) ?? 1.0;
      acChargeValue = double.tryParse(orderModel.value.service!.prices!.first.acCharge!) ?? 1.0;
      kmCharge = double.tryParse(orderModel.value.service!.prices!.first.kmCharge!) ?? 1.0;
    }

    totalChargeOfMinute.value = durationValueInMinutes * (double.tryParse(orderModel.value.service!.prices!.first.perMinuteCharge!) ?? 1.0);
    basicFareCharge.value = (double.tryParse(orderModel.value.service!.prices!.first.basicFareCharge!)) ?? 1.0;
    holdingCharge.value = double.tryParse(orderModel.value.totalHoldingCharges!) ?? 1.0;
    if (distance <= double.parse(orderModel.value.service!.prices!.first.basicFare!)) {
      if (currentTime.isAfter(startNightTimeString) && currentTime.isBefore(endNightTimeString)) {
        amount.value = amount.value * (double.tryParse(orderModel.value.service!.prices!.first.nightCharge!) ?? 1.0);
      } else {
        amount.value = double.parse(orderModel.value.service?.prices?.first.basicFareCharge ?? '0.0');
      }
    } else {
      double distanceValue = double.tryParse(orderModel.value.distance.toString()) ?? 0.0;
      double basicFareValue = double.tryParse(orderModel.value.service!.prices!.first.basicFare!) ?? 0.0;
      double extraDist = distanceValue - basicFareValue;

      double perKmCharge = orderModel.value.service?.prices?.first.isAcNonAc == true
          ? orderModel.value.isAcSelected == false
              ? nonAcChargeValue
              : acChargeValue
          : kmCharge;
      if (perKmCharge == 0.0) {
        amount.value = extraDist;
      } else {
        amount.value = (perKmCharge * extraDist);
      }

      if (currentTime.isAfter(startNightTimeString) && currentTime.isBefore(endNightTimeString)) {
        totalChargeOfMinute.value = totalChargeOfMinute.value * (double.tryParse(orderModel.value.service!.prices!.first.nightCharge!) ?? 1.0);
        basicFareCharge.value = basicFareCharge.value * (double.tryParse(orderModel.value.service!.prices!.first.nightCharge!) ?? 1.0);
        holdingCharge.value = holdingCharge.value * (double.tryParse(orderModel.value.service!.prices!.first.nightCharge!) ?? 1.0);
      }
    }

    if (orderModel.value.finalRate != null && orderModel.value.finalRate != '0.0') {
      amount.value = double.parse(orderModel.value.finalRate.toString()) - basicFareCharge.value - totalChargeOfMinute.value - holdingCharge.value;
    } else {
      amount.value = amount.value * (double.tryParse(orderModel.value.service!.prices!.first.nightCharge!) ?? 0.0);
    }

    subTotal.value = amount.value + basicFareCharge.value + totalChargeOfMinute.value + holdingCharge.value;

    if (orderModel.value.taxList != null) {
      for (var element in orderModel.value.taxList!) {
        taxAmount.value = taxAmount.value + Constant().calculateTax(amount: (subTotal.value - double.parse(couponAmount.value)).toString(), taxModel: element);
      }
    }
    total.value = (subTotal.value - double.parse(couponAmount.value)) + taxAmount.value;
  }

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];

      if (orderModel.value.coupon != null) {
        if (orderModel.value.coupon?.code != null) {
          if (orderModel.value.coupon!.type == "fix") {
            couponAmount.value = orderModel.value.coupon!.amount.toString();
          } else {
            couponAmount.value = ((double.parse(orderModel.value.finalRate.toString()) * double.parse(orderModel.value.coupon!.amount.toString())) / 100).toString();
          }
        }
      }
    }
    await getDriver();
    calculateAmount();
    isLoading.value = false;
    update();
  }

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
}
