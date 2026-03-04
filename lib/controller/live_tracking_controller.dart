import 'dart:async';
import 'dart:convert';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/intercity_order_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as location;
import 'package:http/http.dart' as http;

class LiveTrackingController extends GetxController {
  GoogleMapController? mapController;
  final flutterMap.MapController osmMapController = flutterMap.MapController();
  RxString title = 'Map view'.obs;

  Rx<location.LatLng> current = location.LatLng(21.1800, 72.8400).obs;
  Rx<location.LatLng> source = location.LatLng(21.1702, 72.8311).obs; // Start (e.g., Surat)
  Rx<location.LatLng> destination = location.LatLng(21.2000, 72.8600).obs; // Destination

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  StreamSubscription? orderSubscription;
  StreamSubscription? driverSubscription;

  @override
  void onClose() {
    orderSubscription?.cancel();
    driverSubscription?.cancel();
    ShowToastDialog.closeLoader();
    super.onClose();
  }

  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<InterCityOrderModel> intercityOrderModel = InterCityOrderModel().obs;

  RxBool isLoading = true.obs;
  RxString type = "".obs;

  Future<void> getArgument() async {
    await addMarkerSetup();
    if (argumentData != null) {
      type.value = argumentData['type'];
      if (type.value == "orderModel") {
        OrderModel argumentOrderModel = argumentData['orderModel'];
        orderSubscription = FireStoreUtils.fireStore.collection(CollectionName.orders).doc(argumentOrderModel.id).snapshots().listen((event) {
          if (event.data() != null) {
            OrderModel orderModelStream = OrderModel.fromJson(event.data()!);
            orderModel.value = orderModelStream;
            driverSubscription = FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(argumentOrderModel.driverId).snapshots().listen((event) {
              if (event.data() != null) {
                driverUserModel.value = DriverUserModel.fromJson(event.data()!);
                if (Constant.selectedMapType != 'osm') {
                  if (orderModel.value.status == Constant.rideInProgress) {
                    getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: orderModel.value.destinationLocationLAtLng!.latitude,
                        destinationLongitude: orderModel.value.destinationLocationLAtLng!.longitude);
                  } else {
                    getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: orderModel.value.sourceLocationLAtLng!.latitude,
                        destinationLongitude: orderModel.value.sourceLocationLAtLng!.longitude);
                  }
                } else {
                  if (orderModel.value.status == Constant.rideInProgress) {
                    current.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0);
                    source.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0);
                    destination.value = location.LatLng(orderModel.value.destinationLocationLAtLng!.latitude ?? 0.0, orderModel.value.destinationLocationLAtLng!.longitude ?? 0.0);
                    fetchRoute(source.value, destination.value);
                    animateToSource();
                  } else {
                    current.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0);
                    source.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0);
                    destination.value = location.LatLng(orderModel.value.sourceLocationLAtLng!.latitude ?? 0.0, orderModel.value.sourceLocationLAtLng!.longitude ?? 0.0);
                    fetchRoute(source.value, destination.value);
                    animateToSource();
                  }
                }
              }
            });

            if (orderModel.value.status == Constant.rideComplete) {
              Get.back();
            }
          }
        });
      } else {
        InterCityOrderModel argumentOrderModel = argumentData['interCityOrderModel'];
        FireStoreUtils.fireStore.collection(CollectionName.ordersIntercity).doc(argumentOrderModel.id).snapshots().listen((event) {
          if (event.data() != null) {
            InterCityOrderModel orderModelStream = InterCityOrderModel.fromJson(event.data()!);
            print(orderModelStream.status.toString());
            intercityOrderModel.value = orderModelStream;
            FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(argumentOrderModel.driverId).snapshots().listen((event) {
              if (event.data() != null) {
                driverUserModel.value = DriverUserModel.fromJson(event.data()!);
                if (Constant.selectedMapType != 'osm') {
                  if (intercityOrderModel.value.status == Constant.rideInProgress) {
                    getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: intercityOrderModel.value.destinationLocationLAtLng!.latitude,
                        destinationLongitude: intercityOrderModel.value.destinationLocationLAtLng!.longitude);
                  } else {
                    getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: intercityOrderModel.value.sourceLocationLAtLng!.latitude,
                        destinationLongitude: intercityOrderModel.value.sourceLocationLAtLng!.longitude);
                  }
                } else {
                  if (intercityOrderModel.value.status == Constant.rideInProgress) {
                    current.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0);
                    source.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0);
                    destination.value = location.LatLng(intercityOrderModel.value.destinationLocationLAtLng!.latitude ?? 0.0, intercityOrderModel.value.destinationLocationLAtLng!.longitude ?? 0.0);
                    fetchRoute(source.value, destination.value);
                    animateToSource();
                  } else {
                    current.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0);
                    source.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0);
                    destination.value = location.LatLng(intercityOrderModel.value.sourceLocationLAtLng!.latitude ?? 0.0, intercityOrderModel.value.sourceLocationLAtLng!.longitude ?? 0.0);
                    fetchRoute(source.value, destination.value);
                    animateToSource();
                  }
                }
              }
            });

            if (intercityOrderModel.value.status == Constant.rideComplete) {
              Get.back();
            }
          }
        });
      }
    }
    isLoading.value = false;
    update();
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  void getPolyline({required double? sourceLatitude, required double? sourceLongitude, required double? destinationLatitude, required double? destinationLongitude}) async {
    if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];
      PolylineRequest polylineRequest = PolylineRequest(
        origin: PointLatLng(sourceLatitude, sourceLongitude),
        destination: PointLatLng(destinationLatitude, destinationLongitude),
        mode: TravelMode.driving,
      );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: polylineRequest,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print(result.errorMessage.toString());
      }

      if (type.value == "orderModel") {
        addMarker(latitude: orderModel.value.sourceLocationLAtLng!.latitude, longitude: orderModel.value.sourceLocationLAtLng!.longitude, id: "Departure", descriptor: departureIcon!, rotation: 0.0);
        addMarker(
            latitude: orderModel.value.destinationLocationLAtLng!.latitude,
            longitude: orderModel.value.destinationLocationLAtLng!.longitude,
            id: "Destination",
            descriptor: destinationIcon!,
            rotation: 0.0);
        addMarker(
            latitude: driverUserModel.value.location!.latitude, longitude: driverUserModel.value.location!.longitude, id: "Driver", descriptor: driverIcon!, rotation: driverUserModel.value.rotation);

        _addPolyLine(polylineCoordinates);
      } else {
        addMarker(
            latitude: intercityOrderModel.value.sourceLocationLAtLng!.latitude,
            longitude: intercityOrderModel.value.sourceLocationLAtLng!.longitude,
            id: "Departure",
            descriptor: departureIcon!,
            rotation: 0.0);
        addMarker(
            latitude: intercityOrderModel.value.destinationLocationLAtLng!.latitude,
            longitude: intercityOrderModel.value.destinationLocationLAtLng!.longitude,
            id: "Destination",
            descriptor: destinationIcon!,
            rotation: 0.0);
        addMarker(
            latitude: driverUserModel.value.location!.latitude, longitude: driverUserModel.value.location!.longitude, id: "Driver", descriptor: driverIcon!, rotation: driverUserModel.value.rotation);

        _addPolyLine(polylineCoordinates);
      }
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  void addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  Rx<String> serviceMarkerIcon = ''.obs;
  dynamic argumentData = Get.arguments;
  Future<void> addMarkerSetup() async {
    if (argumentData != null) {
      type.value = argumentData['type'];
      if (type.value == "orderModel") {
        OrderModel argumentOrderModel = argumentData['orderModel'];
        serviceMarkerIcon.value = argumentOrderModel.service?.markerIcon ?? '';
      } else {
        InterCityOrderModel argumentOrderCityModel = argumentData['interCityOrderModel'];
        final drivermodel = await FireStoreUtils.getDriver(argumentOrderCityModel.driverId!);
        final service = await FireStoreUtils.getServiceById(drivermodel!.serviceId!);
        serviceMarkerIcon.value = service.markerIcon ?? "";
      }

      if (Constant.selectedMapType != 'osm') {
        final Uint8List departure = await Constant().getBytesFromAsset('assets/images/pickup.png', 120);
        final Uint8List destination = await Constant().getBytesFromAsset('assets/images/dropoff.png', 120);
        final Uint8List driver =
            serviceMarkerIcon.value == '' ? await Constant().getBytesFromAsset('assets/images/ic_cab.png', 50) : await Constant().getBytesFromUrl(serviceMarkerIcon.value, width: 120);
        departureIcon = BitmapDescriptor.fromBytes(departure);
        destinationIcon = BitmapDescriptor.fromBytes(destination);
        driverIcon = BitmapDescriptor.fromBytes(driver);
      }
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(
    apiKey: Constant.mapAPIKey,
  );

  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      startCap: Cap.roundCap,
      width: 6,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, mapController);
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  RxList<location.LatLng> routePoints = <location.LatLng>[].obs;

  Future<void> fetchRoute(location.LatLng source, location.LatLng destination) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final geometry = decoded['routes'][0]['geometry']['coordinates'];

      routePoints.clear();
      for (var coord in geometry) {
        final lon = coord[0];
        final lat = coord[1];
        routePoints.add(location.LatLng(lat, lon));
      }
    } else {
      print("Failed to get route: ${response.body}");
    }
  }

  void animateToSource() {
    osmMapController.move(location.LatLng(driverUserModel.value.location!.latitude ?? 0.0, driverUserModel.value.location!.longitude ?? 0.0), 16);
  }
}
