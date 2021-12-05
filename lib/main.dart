import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

main() {
  runApp(const MaterialApp(
    title: 'Flutter Google Maps',
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  late MapType _currentMapType = MapType.normal;
  final LatLng _center = const LatLng(45.5016889, -73.567256);
  final List<Marker> _markers = <Marker>[];
  late LatLng _lastMapPosition;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      //Stack pour positionner les widgets les un par dessus les autres.
      body: Stack(
        children: [
          GoogleMap(
            onCameraMove: _onCameraMove,
            markers: Set<Marker>.of(_markers,),
            mapType: _currentMapType,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  floatingButton(Icons.map, _changeMapType),
                  const SizedBox(height: 16.0),
                  floatingButton(Icons.add_location, _addMarker),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _addMarker() {
    var count = _markers.length + 1;
    Marker newMarker = Marker(
      markerId: MarkerId(count.toString()),
      position: LatLng(_lastMapPosition.latitude, _lastMapPosition.longitude),
      infoWindow: InfoWindow(title: 'Marqueur $count'),
    );
    setState(() {
      _markers.add(newMarker);
    });
  }
}

Widget floatingButton(IconData buttonIcon, VoidCallback buttonFunction) {
  return FloatingActionButton(
    heroTag: null,
    onPressed: buttonFunction,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    backgroundColor: const Color(0xffFF0052),
    child: Icon(
      buttonIcon,
      size: 36.0,
    ),
  );
}