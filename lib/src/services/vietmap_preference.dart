import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vietmap_tracking_plugin/vietmap_tracking_plugin.dart';

class VietMapPreference {
  static final VietMapPreference _singleton = VietMapPreference._internal();
  final _sharedPreference = SharedPreferences.getInstance();
  final _endPointCache = 'vm-endpoint';
  final _apiKeyCache = 'vm-apikey';
  final _listGPSCache = 'vm-list-gps-cache';
  final _trackingIntervalCache = 'vm-tracking-interval'; // New cache key

  factory VietMapPreference() {
    return _singleton;
  }
  VietMapPreference._internal();

  Future<void> refresh() async {
    await (await _sharedPreference).reload();
  }

  /// GET SHARE PREFERENCE

  Future<String?> getEndPoint() async {
    String? value = (await _sharedPreference).getString(_endPointCache);
    if (value == null) return null;
    return value;
  }

  Future<String?> getApiKey() async {
    String? value = (await _sharedPreference).getString(_apiKeyCache);
    if (value == null) return null;
    return value;
  }

  Future<List<GpsLocation>?> getListGPSCache() async {
    String? value = (await _sharedPreference).getString(_listGPSCache);
    if (value == null) return null;
    List<GpsLocation> result = [];
    List<dynamic> listViewerBuilder = jsonDecode(value);
    listViewerBuilder
        .map((e) => result.add(GpsLocation.fromJson(jsonDecode(e))))
        .toList();
    return result;
  }

  Future<int> getTrackingInterval() async {
    int? value = (await _sharedPreference).getInt(_trackingIntervalCache);
    if (value == null) return 30; // Default 30 seconds
    return value;
  }

  /// SAVE SHARE PREFERENCE
  Future<void> setEndPoint(String data) async {
    (await _sharedPreference).setString(_endPointCache, data);
  }

  Future<void> setApiKey(String data) async {
    (await _sharedPreference).setString(_apiKeyCache, data);
  }

  Future<void> setTrackingInterval(int seconds) async {
    (await _sharedPreference).setInt(_trackingIntervalCache, seconds);
  }

  Future setListGPS(List<GpsLocation> listData) async {
    List<String> listViewerBuilderString = [];
    for (var item in listData) {
      var result = item.toJson();
      listViewerBuilderString.add(jsonEncode(result));
    }
    var fwText = jsonEncode(listViewerBuilderString);
    (await _sharedPreference).setString(_listGPSCache, fwText);
  }

  /// REMOVE SHARE PREFERENCE
  Future<void> removeStore() async {
    (await _sharedPreference).clear();
  }

  Future<void> removeEndPoint() async {
    (await _sharedPreference).remove(_endPointCache);
  }

  Future<void> removeApiKey() async {
    (await _sharedPreference).remove(_apiKeyCache);
  }
}
