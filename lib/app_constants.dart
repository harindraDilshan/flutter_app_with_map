import 'package:latlong2/latlong.dart';

class AppConstants {
  static const String mapBoxAccessToken =
      'pk.eyJ1IjoiaGFyaW5kcmFkaWxzaGFuMTIzIiwiYSI6ImNtNGs1N2Q4cDBia3Eya3NjOTZ1MnFvaHEifQ.rxQiZDTxcw4qia-NdC976w';

  static const String urlTemplate =
      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$mapBoxAccessToken';

  static const String mapBoxStyleDarkId = 'mapbox/light-v11';
  static const String mapBoxStyleOutdoorId = 'mapbox/outdoors-v12';
  static const String mapBoxStyleStreetId = 'mapbox/satellite-streets-v12';
  static const String mapBoxStyleNightId = 'mapbox/navigation-night-v1';

// 7.2595824990024225, 80.59860743170412
  static const myLocation = LatLng(51.5, -0.09);
}
