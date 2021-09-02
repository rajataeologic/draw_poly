import 'package:draw_poly/Loc.dart';
import 'package:draw_poly/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Location? location;

  CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(0.0, 0.0));

  @override
  void initState() {
    super.initState();
    getUserLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google MAP Sample"),
      ),
      body: location != null
          ? Column(
              children: [
                Expanded(
                  child: GoogleMap(
                      initialCameraPosition: initialCameraPosition,
                      myLocationEnabled: true,
                      polygons: myPolygon(),
                      // polylines: myPolyline(),
                      onMapCreated: (map) {}),
                ),
                MaterialButton(
                  onPressed: () {},
                  child: Text("Click here.."),
                )
              ],
            )
          : Container(),
    );
  }

  void getUserLoc() async {
    Map<String, dynamic> map = await getUserLocation();
    location = map['location'] as Location;
    print(location);
    initialCameraPosition = CameraPosition(
      target: LatLng(location?.latitude ?? 0.0, location?.longitude ?? 0.0),
      zoom: 14.0,
    );
    setState(() {});
  }

  Set<Polyline> myPolyline() {
    List<LatLng> polygonCoords = new List.empty(growable: true);
    polygonCoords.add(LatLng(24.657002173279082, 75.93423843383789));
    polygonCoords.add(LatLng(24.65651288056014, 75.94084597934571));
    polygonCoords.add(LatLng(24.643329325667604, 75.94136096347657));
    polygonCoords.add(LatLng(24.64373002433451, 75.93453813249513));
    polygonCoords.add(LatLng(24.657002173279082, 75.93423843383789));

    Set<Polyline> polylineSet = new Set();
    polylineSet.add(Polyline(
        polylineId: PolylineId("s"),
        width: 2,
        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
        points: polygonCoords,
        jointType: JointType.round,
        color: Colors.white));
    return polylineSet;
  }

  Set<Polygon> myPolygon() {
    List<LatLng> polygonCoords = new List.empty(growable: true);
    polygonCoords.add(LatLng(24.657002173279082, 75.93423843383789));
    polygonCoords.add(LatLng(24.65651288056014, 75.94084597934571));
    polygonCoords.add(LatLng(24.643329325667604, 75.94136096347657));
    polygonCoords.add(LatLng(24.647501226954645, 75.94025803488707));

    Set<Polygon> polygonSet = new Set();
    polygonSet.add(Polygon(
        polygonId: PolygonId('test'),
        points: polygonCoords,
        fillColor: Colors.green.shade100,
        geodesic: true,
        strokeWidth: 1,
        consumeTapEvents: true,
        onTap: () {
          print("Click");
        },
        strokeColor: Colors.green));

    return polygonSet;
  }
}
