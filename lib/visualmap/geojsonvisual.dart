import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:convert';

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

class GeoJsonVis extends StatefulWidget {
  const GeoJsonVis({Key? key}) : super(key: key);

  @override
  State<GeoJsonVis> createState() => _GeoJsonVisState();
}

class _GeoJsonVisState extends State<GeoJsonVis> {
  GeoJsonParser geoJsonParser = GeoJsonParser();
  late MapController mapController;

  bool loadingData = false;
  String? filePath;
  TextEditingController searchController = TextEditingController();
  List<GeoJsonFeature> geoJsonFeatures = [];
  List<String> featureNames = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  Future<void> processGeoJsonFile(String geoJsonContent) async {
    geoJsonParser.parseGeoJsonAsString(geoJsonContent);

    final geoJson = json.decode(geoJsonContent);

    if (geoJson['type'] == 'FeatureCollection' && geoJson['features'] is List) {
      final features = geoJson['features'] as List;
      setState(() {
        geoJsonFeatures = features.map((feature) {
          final properties =
              feature['properties'] as Map<String, dynamic>? ?? {};
          featureNames.add(properties['name'] ?? '');
          return GeoJsonFeature(
            type: feature['type'] ?? '',
            properties: properties,
            coordinates: feature['geometry']['coordinates'] ?? [],
          );
        }).toList();
      });
    }
  }

  Future<void> pickGeoJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String geoJsonContent =
          await File(result.files.single.path!).readAsString();

      setState(() {
        filePath = result.files.single.path;
        loadingData = true;
      });

      await processGeoJsonFile(geoJsonContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected File: $filePath'),
          duration: Duration(seconds: 3),
        ),
      );

      setState(() {
        loadingData = false;
      });
    }
  }

  void clearMap() {
    setState(() {
      filePath = null;
      geoJsonParser.polygons.clear();
      geoJsonParser.polylines.clear();
      geoJsonParser.markers.clear();
      geoJsonParser.circles.clear();
      geoJsonFeatures.clear();
      featureNames.clear();
    });
  }

  void performSearch(String searchTerm) {
    searchTerm = searchTerm.toLowerCase();
    GeoJsonFeature? selectedFeature = geoJsonFeatures.firstWhere(
      (feature) => feature.properties.values
          .any((value) => value.toString().toLowerCase().contains(searchTerm)),
      orElse: () => GeoJsonFeature(
        type: '',
        properties: {},
        coordinates: [],
      ),
    );

    if (selectedFeature != null) {
      LatLng coordinates = LatLng(
        selectedFeature.coordinates[1],
        selectedFeature.coordinates[0],
      );

      Marker marker = Marker(
          width: 80.0,
          height: 80.0,
          point: coordinates,
          child: Icon(
            Icons.place,
            color: Colors.red,
            size: 40.0,
          ));

      mapController.move(coordinates, 15.0);

      setState(() {
        // Filter the geoJsonFeatures list to only keep the matching feature
        geoJsonFeatures = geoJsonFeatures
            .where((feature) => feature.properties.values.any(
                (value) => value.toString().toLowerCase().contains(searchTerm)))
            .toList();

        // Clear all layers and markers
        geoJsonParser.polygons.clear();
        geoJsonParser.polylines.clear();
        geoJsonParser.markers.clear();
        geoJsonParser.circles.clear();

        // Re-add markers for the filtered features
        geoJsonFeatures.forEach((feature) {
          // ... (your existing marker creation logic)
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected Feature: $searchTerm'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No matching feature found for: $searchTerm'),
        ),
      );
    }
  }

  void _showPropertiesTable(Map<String, dynamic> properties) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: DataTable(
            columns: [
              DataColumn(label: Text('Property')),
              DataColumn(label: Text('Value')),
            ],
            rows: properties.entries.map((entry) {
              return DataRow(cells: [
                DataCell(Text(entry.key)),
                DataCell(Text(entry.value.toString())),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GeoJSON Visualization'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search by Name or Feature',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  performSearch(searchController.text);
                },
              ),
            ),
          ),

          // Autocomplete widget for suggestions
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return featureNames
                  .where((name) => name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()))
                  .toList();
            },
            onSelected: (String selectedName) {
              // Handle selection
              searchController.text = selectedName;
              performSearch(selectedName);
            },
          ),
          Expanded(
            child: Container(
              height: 200,
              child: FlutterMap(
                mapController: mapController,
                options: const MapOptions(
                  initialCenter: LatLng(28.4089, 77.3178),
                  initialZoom: 9,
                ),
                children: [
                  TileLayer(
                    wmsOptions: WMSTileLayerOptions(
                      baseUrl:
                          'https://bhuvan-vec1.nrsc.gov.in/bhuvan/gwc/service/wms?',
                      layers: const ['india3'],
                    ),
                  ),
                  loadingData
                      ? const Center(child: CircularProgressIndicator())
                      : PolygonLayer(
                          polygons: geoJsonParser.polygons,
                        ),
                  if (!loadingData)
                    PolylineLayer(polylines: geoJsonParser.polylines),
                  if (!loadingData)
                    MarkerLayer(
                      markers: geoJsonFeatures.map((feature) {
                        return Marker(
                            width: 30.0,
                            height: 30.0,
                            point: LatLng(
                              feature.coordinates[1],
                              feature.coordinates[0],
                            ),
                            child: IconButton(
                                onPressed: () {
                                  _showPropertiesTable(feature.properties);
                                },
                                icon: Icon(Icons.location_pin)
                                // builder: (BuildContext context) {
                                //   return IconButton(
                                //     onPressed: () {
                                //       _showPropertiesTable(feature.properties);
                                //     },
                                //     icon: Icon(Icons.location_pin),
                                //   );
                                // },
                                ));
                      }).toList(),
                    ),
                  if (!loadingData) CircleLayer(circles: geoJsonParser.circles),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange[400],
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.file_upload),
                onPressed: pickGeoJsonFile,
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: clearMap,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
