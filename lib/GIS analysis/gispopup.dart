import 'package:flutter/material.dart';
import 'package:geoharbor/GIS%20analysis/intra.dart';
import 'package:geoharbor/GIS%20analysis/uniona.dart';
import 'package:geoharbor/Screens/prox.dart';

class GISAnalysisPopup extends StatefulWidget {
  @override
  _GISAnalysisPopupState createState() => _GISAnalysisPopupState();
}

class _GISAnalysisPopupState extends State<GISAnalysisPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'GIS Analysis',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
      content: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GISAnalysisOption(
              text: 'Union',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => unionui()),
                );
                // Add your logic for 'Union' here
                print('Union tapped!');
              },
            ),
            GISAnalysisOption(
              text: 'Intersection',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => GeoJsonIntr()),
                );
                // Add your logic for 'Intersection' here
                print('Intersection tapped!');
              },
            ),
            GISAnalysisOption(
              text: 'Proximity Analysis',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => prox()),
                );
                // Add your logic for 'Proximity Analysis' here
                print('Proximity Analysis tapped!');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GISAnalysisOption extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  GISAnalysisOption({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.orange,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
