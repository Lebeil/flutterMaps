import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_page.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference housingRef = firestore.collection('Housing');
QueryDocumentSnapshot? currentHousing;
GlobalKey<_BottomSectionState> bottomKey = GlobalKey();

//initialisation Firebase
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

  //Charger les marqueurs dès le lancement de notre application.
  @override
  void initState() {
    super.initState();
    getFirebaseMarkers();
  }

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
            markers: Set<Marker>.of(_markers),
            mapType: _currentMapType,
            zoomControlsEnabled: true,
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
                  floatingButton(Icons.add_location, _openPage),
                ],
              ),
            ),
          ),
          BottomSection(key: bottomKey),
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

  void _openPage() {
    var lat = _lastMapPosition.latitude;
    var long = _lastMapPosition.longitude;
    print('position:' + lat.toString() + '/' + long.toString());
    Route route = MaterialPageRoute(
      builder: (context) => AddPage(lat, long),
      fullscreenDialog: true,
    );
    Navigator.push(context, route).then(refreshMarkers);
  }

  void refreshMarkers(dynamic value) {
    print("refresh");
    _markers.clear();
    currentHousing = null;
    getFirebaseMarkers();
    setState((){});
  }

  void getFirebaseMarkers() {
    housingRef.get().then(
          (QuerySnapshot querySnapshot) => {
        for (var doc in querySnapshot.docs)
          {
            print('new marker'),
            _addMarker(doc),
          }
      },
    );
  }

  void _addMarker(QueryDocumentSnapshot markerInfo) {
    Marker newMarker = Marker(
      markerId: MarkerId(markerInfo.id),
      position: LatLng(markerInfo['lat'], markerInfo['lng']),
      infoWindow: InfoWindow(title: markerInfo['price'] + ' €'),
      onTap: () {
        currentHousing = markerInfo;
        bottomKey.currentState!.setState(() {});
      },
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

class BottomSection extends StatefulWidget {
  const BottomSection({Key? key}) : super(key: key);
  @override
  _BottomSectionState createState() => _BottomSectionState();
}

class _BottomSectionState extends State<BottomSection> {
  @override
  Widget build(BuildContext context) {
    if (currentHousing == null) {
      return Container();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      height: 200,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(currentHousing!['photoUrl']),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentHousing!['description'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 17, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              currentHousing!['title'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 20, color: Colors.grey[900]),
                            ),
                            const SizedBox(height: 10),
                            Container(height: 1, width: 50, color: Colors.grey),
                            const SizedBox(height: 10),
                            Text(
                              currentHousing!['equipment'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  currentHousing!['price'] + ' €',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.grey[900]),
                                ),
                                Text(
                                  ' / nuit',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.grey[900]),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      );
    }
  }
}