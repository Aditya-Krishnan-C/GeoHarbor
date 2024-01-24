import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class GeoJsonIntr extends StatefulWidget {
  const GeoJsonIntr({Key? key}) : super(key: key);

  @override
  State<GeoJsonIntr> createState() => _GeoJsonVisState();
}

class _GeoJsonVisState extends State<GeoJsonIntr> {
  GeoJsonParser geoJsonParser1 = GeoJsonParser();
  GeoJsonParser geoJsonParser2 = GeoJsonParser();

  bool loadingData1 = false;
  bool loadingData2 = false;
  String? filePath1;
  String? filePath2;

  Future<void> processGeoJsonFile(String geoJsonContent, bool isFile1) async {
    // Parse the selected GeoJSON content
    GeoJsonParser parser = isFile1 ? geoJsonParser1 : geoJsonParser2;
    parser.parseGeoJsonAsString(geoJsonContent);
  }

  Future<void> pickGeoJsonFile(bool isFile1) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String geoJsonContent =
          await File(result.files.single.path!).readAsString();

      setState(() {
        if (isFile1) {
          filePath1 = result.files.single.path;
          loadingData1 = true;
        } else {
          filePath2 = result.files.single.path;
          loadingData2 = true;
        }
      });

      await processGeoJsonFile(geoJsonContent, isFile1);

      // Display selected file path as a snackbar for 3 seconds
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFile1
              ? 'Selected File 1: $filePath1'
              : 'Selected File 2: $filePath2'),
          duration: Duration(seconds: 3),
        ),
      );

      setState(() {
        if (isFile1) {
          loadingData1 = false;
        } else {
          loadingData2 = false;
        }
      });
    }
  }

  void clearMap() {
    setState(() {
      filePath1 = null;
      filePath2 = null;
      geoJsonParser1.polygons.clear();
      geoJsonParser1.polylines.clear();
      geoJsonParser1.markers.clear();
      geoJsonParser1.circles.clear();
      geoJsonParser2.polygons.clear();
      geoJsonParser2.polylines.clear();
      geoJsonParser2.markers.clear();
      geoJsonParser2.circles.clear();
    });
  }

  // Perform intersection operation and update the map accordingly
  void performIntersectionOperation() {
    // Implement your intersection operation logic here
    // Keep only the common polygons between geoJsonParser1 and geoJsonParser2
    geoJsonParser1.polygons.retainWhere(
      (polygon1) => geoJsonParser2.polygons.any(
        (polygon2) => polygonComparisonCondition(polygon1, polygon2),
      ),
    );

    // Update the UI
    setState(() {});
  }

  // Placeholder condition for comparing polygons
  bool polygonComparisonCondition(Polygon polygon1, Polygon polygon2) {
    // Replace this condition with the appropriate logic for your data
    // Example: return polygon1 == polygon2;
    return false;
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
          SizedBox(height: 40),
          Expanded(
            child: Container(
              height: 200,
              child: FlutterMap(
                mapController: MapController(),
                options: const MapOptions(
                  initialCenter: LatLng(28.4089, 77.3178),
                  initialZoom: 2,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  loadingData1 || loadingData2
                      ? const Center(child: CircularProgressIndicator())
                      : PolygonLayer(
                          polygons: geoJsonParser1.polygons,
                        ),
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
                onPressed: () => pickGeoJsonFile(true),
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.file_upload),
                onPressed: () => pickGeoJsonFile(false),
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: clearMap,
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.compare_arrows),
                onPressed: performIntersectionOperation,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
