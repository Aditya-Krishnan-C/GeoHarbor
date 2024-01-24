import 'dart:convert' show utf8;
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide PolylineLayerOptions;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart' as xml;
import 'package:file_picker/file_picker.dart';

class KMLVis extends StatefulWidget {
  @override
  _KMLVisState createState() => _KMLVisState();
}

class _KMLVisState extends State<KMLVis> {
  List<LatLng> _coordinates = [];
  String _selectedFileType = 'KML';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('KML/KMZ Visualization'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _coordinates.isNotEmpty
                      ? _coordinates.first
                      : LatLng(28.4089, 77.3178),
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
                  MarkerLayer(
                    markers: _coordinates
                        .map(
                          (latLng) => Marker(
                            point: latLng,
                            child: Icon(Icons.location_pin),
                          ),
                        )
                        .toList(),
                  ),
                ],
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
                  onPressed: _pickFile,
                  color: Colors.white,
                ),
                DropdownButton(
                  value: _selectedFileType,
                  items: ['KML', 'KMZ'].map((String fileType) {
                    return DropdownMenuItem<String>(
                      value: fileType,
                      child: Text(fileType),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedFileType = value;
                      });
                    }
                  },
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
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result;
    if (_selectedFileType == 'KML') {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['kml'],
      );
    } else if (_selectedFileType == 'KMZ') {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['kmz'],
      );
    }

    if (result != null && result.files.isNotEmpty) {
      String pickedFilePath = result.files.first.path!;
      String fileContent = await _extractFileContent(pickedFilePath);
      List<LatLng> coordinates = _parseFileCoordinates(fileContent);
      setState(() {
        _coordinates = coordinates;
      });
    }
  }

  Future<String> _extractFileContent(String filePath) async {
    if (_selectedFileType == 'KMZ') {
      Archive archive =
          ZipDecoder().decodeBytes(await File(filePath).readAsBytes());
      for (ArchiveFile file in archive) {
        if (file.name.toLowerCase().endsWith('.kml')) {
          return utf8.decode(file.content as List<int>);
        }
      }
      throw Exception('No KML file found in KMZ archive.');
    } else {
      return await File(filePath).readAsString();
    }
  }

  List<LatLng> _parseFileCoordinates(String fileContent) {
    final document = xml.XmlDocument.parse(fileContent);
    final coordinates = document
        .findAllElements('coordinates')
        .expand((node) => node.innerText.trim().split(' '))
        .where((s) => s.isNotEmpty)
        .map((s) {
      final parts = s.split(',').map((coord) => double.parse(coord.trim()));
      return LatLng(parts.elementAt(1), parts.elementAt(0));
    }).toList();
    return coordinates;
  }

  void clearMap() {
    setState(() {
      _coordinates.clear();
    });
  }
}
