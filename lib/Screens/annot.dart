import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'dart:async';

class annott extends StatefulWidget {
  const annott({Key? key}) : super(key: key);

  @override
  State<annott> createState() => _annottState();
}

class _annottState extends State<annott> {
  final MapController _mapController = MapController();
  LatLng currentLocation = LatLng(0, 0);
  LatLng selectedLocation = LatLng(0, 0);
  LatLng tappedLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  double calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371; // in kilometers

    double lat1 = from.latitude;
    double lon1 = from.longitude;
    double lat2 = to.latitude;
    double lon2 = to.longitude;

    double dLat = math.pi / 180 * (lat2 - lat1);
    double dLon = math.pi / 180 * (lon2 - lon1);
    double a = (dLat / 2) * (dLat / 2) +
        lat1 * math.pi / 180 * lat2 * math.pi / 180 * (dLon / 2) * (dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  void _showDistancePopup(BuildContext context) {
    double distance = calculateDistance(currentLocation, tappedLocation);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Distance to tapped location:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text('$distance km'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapping'),
      ),
      body: currentLocation.latitude != 0 && currentLocation.longitude != 0
          ? FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation,
                onTap: (tapPosition, latLng) {
                  setState(() {
                    tappedLocation = latLng;
                  });
                  _showDistancePopup(context);
                  Marker(point: tappedLocation, child: Icon(Icons.location_on));
                },
              ),
              children: [
                TileLayer(
                  wmsOptions: WMSTileLayerOptions(
                    baseUrl:
                        'https://bhuvan-vec1.nrsc.gov.in/bhuvan/gwc/service/wms?',
                    layers: const ['india3'],
                  ),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation,
                      child: IconButton(
                        icon: Icon(
                          Icons.location_searching,
                          color: Colors.blue,
                          size: 28.0,
                        ),
                        onPressed: () {
                          // Handle marker press for current location
                        },
                      ),
                    ),
                    Marker(
                      point: selectedLocation,
                      child: IconButton(
                        icon: Icon(
                          Icons.location_searching,
                          color: Colors.red,
                          size: 28.0,
                        ),
                        onPressed: () {
                          _showDistancePopup(context);
                        },
                      ),
                    ),
                    if (tappedLocation.latitude != 0 &&
                        tappedLocation.longitude != 0)
                      Marker(
                        point: selectedLocation,
                        child: IconButton(
                          icon: Icon(
                            Icons.location_searching,
                            color: Colors.red,
                            size: 28.0,
                          ),
                          onPressed: () {
                            _showDistancePopup(context);
                          },
                        ),
                      ),
                  ],
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
