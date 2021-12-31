import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  CameraPosition _initialLocation =
  CameraPosition(target: LatLng(37.3, 126.858), zoom: 18.0);
  late GoogleMapController mapController;
  final Geolocator _geolocator = Geolocator();
  late Position _currentPosition;
  final List<LatLng> points = <LatLng>[];

  double _originLatitude = 37.3, _originLongitude = 126.848;
  double _destLatitude = 37.3, _destLongitude = 126.956;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;
  int _counter = 0;
  String googleAPiKey = "AIzaSyB3eCHj9pwdozFg4wHeeRcweKmMXFTue3Y";
  Widget build(BuildContext context) {
    // Determining the screen width & height
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            // TODO: Add Map View
            GoogleMap(
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(_mapPolylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createPoints,
          label: Text("Test"),
          icon: Icon(Icons.directions_bike),
        ),
      ),
    );
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;
        //_getPolyline();
        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }
  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }
  void _add() {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);
    print(polylineIdVal);
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.red,
      width: 5,
      points: points,
    );

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }
  void _createPoints() {
    _getCurrentLocation();
    points.add(LatLng(_currentPosition.latitude,_currentPosition.longitude));
    _add();
  }

  @override
  void initState() {

    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));

    _getCurrentLocation();
    super.initState();
  }
}