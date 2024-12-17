import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lab12_m22/screens/image_classifier.dart';
import 'package:lab12_m22/screens/loginpage.dart'; // Ensure this path is correct

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('home'),
        position: LatLng(45.521563, -122.677433),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'Current Location'),
      ),
    ].toSet();
  }

  Set<Circle> _circles = Set.from([
    Circle(
      circleId: CircleId('Infection'),
      center: LatLng(45.521563, -122.677433),
      radius: 450,
      strokeColor: Colors.pinkAccent,
    ),
  ]);
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Map COVID-19 Tracker'),
      backgroundColor: Colors.pinkAccent,
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            // Handle logout action
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()), // Replace with your Login page
            );
          },
        ),
      ],
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COVID-Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/covid.png'), // Your image path
                    ),
                    SizedBox(width: 10),
                    Text(
                      'AYYAAA', // The name to display next to the avatar
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
            ),
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Map'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Model'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ImageClassifierPage()), // Ensure Login is the correct class
              ); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()), // Ensure Login is the correct class
              );
            },
          ),
        ],
      ),
    ),
    body: GoogleMap(
      markers: _createMarker(),
      circles: _circles,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 14.0,
      ),
    ),
  );
}
}