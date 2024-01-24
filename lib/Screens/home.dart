import 'package:flutter/material.dart';
import 'package:geoharbor/Screens/annot.dart';
import 'package:geoharbor/Screens/popupview.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geoharbor/noti.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> mapLayerOptions = ['OpenStreetMap', 'Bhuvan'];

  final MapController _mapController = MapController();
  LatLng currentLocation = LatLng(0, 0);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 31, 5, 76),
      appBar: AppBar(
        title: Text(
          'GeoHarbor',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NotificationWidget()),
              );
              // Add your notification button logic here
            },
            color: Colors.orange,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search here...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        // Add your sidebar button logic here
        child: ListView(
          children: [
            ListTile(
              title: Text('About'),
              onTap: () {
                // Add your sidebar item 1 logic here
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Add your sidebar item 2 logic here
              },
            ),
            // Add more sidebar items as needed
          ],
        ),
      ),
      body: currentLocation.latitude != 0 && currentLocation.longitude != 0
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  wmsOptions: WMSTileLayerOptions(
                    baseUrl:
                        'https://bhuvan-vec1.nrsc.gov.in/bhuvan/gwc/service/wms?',
                    layers: const ['india3'],
                  ),
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: currentLocation,
                    child: Icon(
                      Icons.location_searching,
                      color: Colors.blue,
                      size: 28.0,
                    ),
                  )
                ])
              ],
            )
          : Center(
              child:
                  CircularProgressIndicator(), // Show a loading indicator while waiting for the location
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
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => annott()),
                  );
                  // Add your additional button 1 logic here
                },
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  // Add your home button logic here
                },
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  // Add your settings button logic here
                },
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  // Add your additional button 2 logic here
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return FloatingActionPopup();
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
