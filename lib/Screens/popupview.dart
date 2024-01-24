import 'package:flutter/material.dart';
import 'package:geoharbor/GIS%20analysis/gispopup.dart';
import 'package:geoharbor/visualmap/visualizemap.dart';

class FloatingActionPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PopupItem(
            icon: Icons.map,
            text: 'Visualize Map',
            color: Colors.red,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SelectShapefileFormatPopup();
                },
              );

              // Add your logic for 'Visualize Map' here
              print('Visualize Map tapped!');
            },
          ),
          PopupItem(
            icon: Icons.search,
            text: 'GIS Analysis',
            color: Colors.yellow,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GISAnalysisPopup();
                },
              );

              // Add your logic for 'GIS Analysis' here
              print('GIS Analysis tapped!');
            },
          ),
          PopupItem(
            icon: Icons.more_horiz_outlined,
            text: 'More',
            color: Colors.blue,
            onPressed: () {
              // Add your logic for 'Item 3' here
              print('Item 3 tapped!');
            },
          ),
        ],
      ),
    );
  }
}

class PopupItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  PopupItem(
      {required this.icon,
      required this.text,
      required this.color,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          onPressed, // Use the provided onPressed callback when the item is tapped
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32.0),
            SizedBox(width: 16.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
