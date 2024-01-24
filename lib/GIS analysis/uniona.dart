import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class unionui extends StatefulWidget {
  @override
  _unionuiState createState() => _unionuiState();
}

class _unionuiState extends State<unionui> {
  List<Map<String, dynamic>> geojsonData1 = [];
  List<Map<String, dynamic>> geojsonData2 = [];
  List<Map<String, dynamic>> unionResult = [];
  bool isFile1Selected = false;
  bool isFile2Selected = false;

  Future<void> _pickFile(int datasetNumber) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        if (result.files.first.extension?.toLowerCase() == 'geojson') {
          String content = await File(result.files.single.path!).readAsString();

          try {
            Map<String, dynamic> parsedData = json.decode(content);
            if (parsedData.containsKey('features') &&
                parsedData['features'] is List) {
              List<Map<String, dynamic>> featureList =
                  parsedData['features'].cast<Map<String, dynamic>>();
              setState(() {
                if (datasetNumber == 1) {
                  geojsonData1 = featureList;
                  isFile1Selected = true;
                } else {
                  geojsonData2 = featureList;
                  isFile2Selected = true;
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Invalid GeoJSON format. Missing "features" property.'),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error parsing GeoJSON: $e'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select a GeoJSON file.'),
            ),
          );
        }
      }
    } catch (e) {
      print('File picking error: $e');
    }
  }

  void _performUnion() {
    // Simple example: Union of points by combining them
    List<Map<String, dynamic>> pointsUnion = [];

    for (var point in geojsonData1) {
      pointsUnion.add(point);
    }

    for (var point in geojsonData2) {
      pointsUnion.add(point);
    }

    setState(() {
      unionResult = pointsUnion;
    });
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
        title: Text('GeoJSON Union App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            if (unionResult.isNotEmpty)
              Flexible(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        LatLng(28.4089, 77.3178), // Adjust the center as needed
                    initialZoom: 9, // Adjust the zoom level as needed
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
                      markers: unionResult
                          .map<Marker?>((feature) {
                            var geometry = feature['geometry'];
                            var properties = feature['properties'];
                            if (geometry != null) {
                              List<dynamic> coordinates =
                                  geometry['coordinates'];
                              double latitude = coordinates[1];
                              double longitude = coordinates[0];

                              return Marker(
                                width: 30.0,
                                height: 30.0,
                                point: LatLng(latitude, longitude),
                                child: IconButton(
                                  onPressed: () {
                                    _showPropertiesTable(properties);
                                  },
                                  icon: Icon(Icons.location_pin),
                                ),
                              );
                            } else {
                              return null; // Skip features without geometry
                            }
                          })
                          .whereType<
                              Marker>() // Remove null values from the list
                          .toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
                onPressed: isFile1Selected ? null : () => _pickFile(1),
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.file_upload),
                onPressed: isFile2Selected ? null : () => _pickFile(2),
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {},
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  if (geojsonData1.isNotEmpty && geojsonData2.isNotEmpty) {
                    _performUnion();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select both GeoJSON datasets.'),
                      ),
                    );
                  }
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
