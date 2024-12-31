import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/app_constants.dart';
import 'package:my_app/main.dart';
import 'package:exif/exif.dart';

class PolyllineMarkersPage extends StatefulWidget {
  final ImageCollection collection;

  const PolyllineMarkersPage({Key? key, required this.collection})
      : super(key: key);

  @override
  _PolyllineMarkersPageState createState() => _PolyllineMarkersPageState();
}

Future<Map<String, double>?> extractGeoLocation(String imagePath) async {
  print('imagePath+++++++++++++++: $imagePath');
  try {
    final File imageFile = File(imagePath);
    final Uint8List bytes = await imageFile.readAsBytes();

    final data = await readExifFromBytes(bytes);

    if (data == null) {
      print('No EXIF data found');
      return null;
    }

    if (data.containsKey('GPS GPSLatitude') &&
        data.containsKey('GPS GPSLongitude') &&
        data.containsKey('GPS GPSLatitudeRef') &&
        data.containsKey('GPS GPSLongitudeRef')) {
      final latValues = data['GPS GPSLatitude']!.values as List;
      final longValues = data['GPS GPSLongitude']!.values as List;
      print('=========================+++++========= :$latValues');
      final latRef = data['GPS GPSLatitudeRef']!.printable;
      final longRef = data['GPS GPSLongitudeRef']!.printable;

      var latitude = _convertToDecimal(latValues);
      var longitude = _convertToDecimal(longValues);

      if (latRef == 'S') latitude = -latitude;
      if (longRef == 'W') longitude = -longitude;

      print('**************Latitude: $latitude° $latRef');
      print('**************Longitude: $longitude° $longRef');

      return {'latitude': latitude, 'longitude': longitude};
    }
  } catch (e) {
    print('Error reading EXIF data: $e');
  }
  return null;
}

double _convertToDecimal(List values) {
  // Simplified conversion that matches your Python implementation
  double degrees = (values[0] as Ratio).toDouble();
  double minutes = (values[1] as Ratio).toDouble();
  double seconds = (values[2] as Ratio).toDouble();

  return degrees + (minutes / 60.0) + (seconds / 3600.0);
}

// Helper extension to convert Ratio to double
extension RatioExtension on Ratio {
  double toDouble() {
    return this.numerator / this.denominator;
  }
}

class _PolyllineMarkersPageState extends State<PolyllineMarkersPage> {
  // go through the collection and image path input in to the extractGeoLocation function
  @override
  void initState() {
    super.initState();
    widget.collection.imagePaths.forEach((image) {
      extractGeoLocation(image);
    });
  }

  List<LatLng> tappedPoints = [
    const LatLng(51.5, -0.9),
    const LatLng(51.506678, -0.097124),
  ];

  @override
  Widget build(BuildContext context) {
    final markers = tappedPoints
        .map((latlng) => Marker(
            point: latlng,
            child: const Icon(
              Icons.pin_drop,
              color: Colors.red,
              size: 60,
            )))
        .toList();

    return Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: FlutterMap(
          options: MapOptions(
              initialCenter: AppConstants.myLocation,
              initialZoom: 13.0,
              minZoom: 5,
              maxZoom: 18,
              onTap: (_, latlng) {
                setState(() {
                  tappedPoints.add(latlng);
                  debugPrint(latlng.toString());
                });
              }),
          children: [
            TileLayer(
              urlTemplate: AppConstants.urlTemplate,
              fallbackUrl: AppConstants.urlTemplate,
              additionalOptions: const {
                'id': AppConstants.mapBoxStyleOutdoorId,
              },
            ),
            MarkerLayer(markers: markers),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    const LatLng(51.5, -0.09),
                    const LatLng(51.498557, -0.072061),
                    const LatLng(51.482418, -0.081503),
                    const LatLng(51.493855, -0.104677),
                    const LatLng(51.506678, -0.097124),
                  ],
                  color: Colors.red,
                  strokeWidth: 5.0,
                ),
              ],
            )
          ],
        ));
  }
}
