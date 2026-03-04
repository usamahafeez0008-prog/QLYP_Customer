import 'dart:convert';

import 'package:customer/utils/utils.dart';
import 'package:customer/widget/osm_map/place_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSMMapController extends GetxController {
  final mapController = MapController();
  // Store only one picked place instead of multiple
  var pickedPlace = Rxn<PlaceModel>(); // Use Rxn to hold a nullable value
  var searchResults = [].obs;

  Future<void> searchPlace(String query) async {
    if (query.length < 3) {
      searchResults.clear();
      return;
    }

    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=10');

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterMapApp/1.0 (menil.siddhiinfosoft@gmail.com)',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      searchResults.value = data;
    }
  }

  void selectSearchResult(Map<String, dynamic> place) {
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    final address = place['display_name'];
    final city = place['address']['city'] ?? place['address']['town'] ?? place['address']['village'] ?? place['address']['state_district'] ?? place['address']['display_name'];

    // Store only the selected place
    pickedPlace.value = PlaceModel(coordinates: LatLng(lat, lon), address: address, city: city ?? '');
    searchResults.clear();
  }

  void addLatLngOnly(LatLng coords) async {
    final address = await _getAddressFromLatLng(coords);
    final city = address['address']['city'] ?? address['address']['town'] ?? address['address']['village'] ?? address['address']['state_district'] ?? address['address']['display_name'];
    pickedPlace.value = PlaceModel(coordinates: coords, address: address['display_name'] ?? 'Unknown location', city: city);
  }

  Future<dynamic> _getAddressFromLatLng(LatLng coords) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${coords.latitude}&lon=${coords.longitude}&format=json');

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterMapApp/1.0 (menil.siddhiinfosoft@gmail.com)',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return {};
    }
  }

  void clearAll() {
    pickedPlace.value = null; // Clear the selected place
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    Position? location = await Utils.getCurrentLocation();
    LatLng latlng = LatLng(location.latitude, location.longitude);
    addLatLngOnly(LatLng(location.latitude, location.longitude));
    mapController.move(latlng, mapController.camera.zoom);
  }
}
