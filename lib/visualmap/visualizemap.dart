import 'package:flutter/material.dart';
import 'package:geoharbor/visualmap/geojsonvisual.dart';
import 'package:geoharbor/visualmap/kmlkmzvisual.dart';

class SelectShapefileFormatPopup extends StatelessWidget {
  // Define a list of shapefile formats
  final List<String> formats = ['GeoJSON', 'KML/KMZ'];

  // Define a variable to store the selected format
  String? selectedFormat;

  // Define a variable to store the selected page widget
  Widget? selectedPage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Shapefile Format',
          style: TextStyle(color: Colors.orange)),
      backgroundColor: Colors.white, // Set background color to white
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use a StatefulBuilder widget to update the state of the dropdown menu and the selected page
          StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                // Set the value to the selected format or null if none is selected
                value: selectedFormat,
                // Set the items to the list of formats mapped to DropdownMenuItem widgets
                items: formats.map((String format) {
                  return DropdownMenuItem<String>(
                    value: format,
                    child: Text(format),
                  );
                }).toList(),
                // Set the onChanged callback to update the selected format and page
                onChanged: (String? newValue) {
                  // Update the selected format
                  setState(() {
                    selectedFormat = newValue;
                  });
                  // Update the selected page based on the selected format
                  switch (selectedFormat) {
                    case 'GeoJSON':
                      selectedPage = GeoJsonVis();
                      break;
                    case 'KML/KMZ':
                    case 'KMZ':
                      selectedPage = KMLVis();
                      break;
                    default:
                      selectedPage = null;
                      break;
                  }
                },
              );
            },
          ),
          // Add a RaisedButton widget to validate and submit the form
          ElevatedButton(
            onPressed: () {
              // Check if the selected page is not null
              if (selectedPage != null) {
                // Navigate to the selected page
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => selectedPage!),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange, // Set text color to white
            ),
            child: Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
