import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';

class GeoJsonFeature {
  final String type;
  final Map<String, dynamic> properties;
  final List<dynamic> coordinates;

  GeoJsonFeature({
    required this.type,
    required this.properties,
    required this.coordinates,
  });
}

class prox extends StatefulWidget {
  const prox({Key? key}) : super(key: key);

  @override
  _proxState createState() => _proxState();
}

class _proxState extends State<prox> {
  String? selectedFilePath;
  List<GeoJsonFeature> geoJsonFeatures = [];
  List<String> propertyColumns = [];
  double selectedRadius = 1.0; // Default radius is 1km

  Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        // You might want to handle this case differently based on your app's requirements.
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
          // You might want to handle this case differently based on your app's requirements.
          throw Exception('Location permissions are denied.');
        }
      }

      Position currentPosition = await Geolocator.getCurrentPosition();
      print(
          'Current position: ${currentPosition.latitude}, ${currentPosition.longitude}');

      return currentPosition; // Return the obtained position
    } catch (e) {
      print('Error getting current position: $e');
      // Handle the error or throw it to be handled elsewhere in your code.
      throw e;
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null) {
        final file = result.files.single;
        setState(() {
          selectedFilePath = file.path!;
        });

        try {
          final content = await File(file.path!).readAsString();
          final geoJson = json.decode(content);

          if (geoJson['type'] == 'FeatureCollection' &&
              geoJson['features'] is List) {
            final features = geoJson['features'] as List;
            setState(() {
              geoJsonFeatures = features.map((feature) {
                final properties =
                    feature['properties'] as Map<String, dynamic>? ?? {};
                if (propertyColumns.isEmpty) {
                  propertyColumns = properties.keys.toList();
                }
                return GeoJsonFeature(
                  type: feature['type'] ?? '',
                  properties: properties,
                  coordinates: feature['geometry']['coordinates'] ?? [],
                );
              }).toList();
            });
          }
        } catch (e) {
          print('Error reading/parsing GeoJSON content: $e');
          setState(() {
            selectedFilePath = null;
            geoJsonFeatures = [];
            propertyColumns = [];
          });
        }
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  List<GeoJsonFeature> getFilteredLocations(Position currentPosition) {
    return geoJsonFeatures
        .where((location) =>
            calculateDistance(
                currentPosition.latitude,
                currentPosition.longitude,
                location.coordinates[1], // latitude
                location.coordinates[0]) <=
            selectedRadius * 1000) // Convert selectedRadius to meters
        .toList();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth radius in km
    final dLat = radians(lat2 - lat1);
    final dLon = radians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c * 1000; // Distance in meters
    return distance;
  }

  double radians(double degrees) {
    return degrees * (pi / 180.0);
  }

  void showDetailsDialog(Position currentPosition) {
    final filteredLocations = getFilteredLocations(currentPosition);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('GeoJSON Features'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                final feature = filteredLocations[index];
                return ListTile(
                  title: Text('Type: ${feature.type}'),
                  subtitle: Text(
                    'Properties: ${feature.properties}\nCoordinates: ${feature.coordinates}',
                  ),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoJSON Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await getCurrentLocation();
                await pickFile();
              },
              child: const Text('Pick GeoJSON File'),
            ),
            const SizedBox(height: 20),
            if (selectedFilePath != null)
              Text(selectedFilePath!)
            else
              const Text('No file selected'),
            const SizedBox(height: 20),
            DropdownButton<double>(
              value: selectedRadius,
              onChanged: (value) {
                setState(() {
                  selectedRadius = value!;
                });
              },
              items: [
                DropdownMenuItem<double>(
                  value: 1.0,
                  child: Text('1 km'),
                ),
                DropdownMenuItem<double>(
                  value: 2.0,
                  child: Text('2 km'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                getCurrentLocation().then((currentPosition) {
                  showDetailsDialog(currentPosition);
                });
              },
              child: const Text('Show Details'),
            ),
            const SizedBox(height: 20),
            if (geoJsonFeatures.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Type')),
                      ...propertyColumns
                          .map((property) => DataColumn(label: Text(property))),
                      DataColumn(label: Text('Coordinates')),
                    ],
                    rows: List.generate(
                      geoJsonFeatures.length,
                      (index) => DataRow(
                        cells: [
                          DataCell(Text(geoJsonFeatures[index].type)),
                          ...propertyColumns.map((property) => DataCell(Text(
                              geoJsonFeatures[index]
                                      .properties[property]
                                      ?.toString() ??
                                  ''))),
                          DataCell(Text(
                              geoJsonFeatures[index].coordinates.toString())),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
