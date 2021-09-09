import 'package:draw_poly/Loc.dart';
import 'package:draw_poly/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Location? location;
  List<LatLng> polylineCoordinates = [];
  List<LatLng> polygonCoords = new List.empty(growable: true);
  GoogleMapController? _controller;
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> m = {
    Marker(
      markerId: MarkerId("1"),
      position: LatLng(26.45854065013806, 74.64073777867344),
    ),
    Marker(
        markerId: MarkerId("2"),
        position: LatLng(26.458310128334023, 74.6482050485709),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)),
    Marker(
        markerId: MarkerId("3"),
        position: LatLng(26.470142984568138, 74.64743257237461),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta)),
    Marker(
        markerId: MarkerId("4"),
        position: LatLng(26.470046943554404, 74.64048028660801),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet))
  };
  CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(26.45854065013806, 74.64073777867344), zoom: 14.0);

  // var polylineCoordinates;

  @override
  void initState() {
    super.initState();

    polygonCoords.add(LatLng(26.45854065013806, 74.64073777867344));
    polygonCoords.add(LatLng(26.458310128334023, 74.6482050485709));
    polygonCoords.add(LatLng(26.470142984568138, 74.64743257237461));
    // polygonCoords.add(LatLng(26.469958360799392, 74.64437484741211));
    polygonCoords.add(LatLng(26.470046943554404, 74.64048028660801));

    // getUserLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Google MAP Sample"),
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  myLocationEnabled: true,
                  onTap: (l) {
                    print('${l.latitude},${l.longitude}');
                    polylineCoordinates.clear();
                    bool s = _checkIfValidMarker(l, polygonCoords);
                    if (s) {
                      var d = map_tool.PolygonUtil.distanceToLine(
                          map_tool.LatLng(l.latitude, l.longitude),
                          map_tool.LatLng(polygonCoords.elementAt(0).latitude,
                              polygonCoords.elementAt(0).longitude),
                          map_tool.LatLng(polygonCoords.elementAt(3).latitude,
                              polygonCoords.elementAt(3).longitude));
                      print(d);
                      LatLng lat = getPointOnLine(d, Direction.W, l);

                      print('${lat.latitude},${lat.longitude}');

                      var dd = map_tool.PolygonUtil.distanceToLine(
                          map_tool.LatLng(l.latitude, l.longitude),
                          map_tool.LatLng(polygonCoords.elementAt(1).latitude,
                              polygonCoords.elementAt(1).longitude),
                          map_tool.LatLng(polygonCoords.elementAt(2).latitude,
                              polygonCoords.elementAt(2).longitude));

                      LatLng lat1 = getPointOnLine(dd, Direction.E, l);
                      print('lat1: ${lat1.latitude},${lat1.longitude}');

                      addPoint(lat, lat1);
                    }
                  },
                  markers: m,
                  polygons: myPolygon(),
                  // polylines: myPolyline(),

                  polylines: Set<Polyline>.of(polylines.values),
                  onMapCreated: (map) {
                    _controller = map;
                  }),
            ),
            MaterialButton(
              onPressed: () {},
              child: Text("Click here.."),
            )
          ],
        ));
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

  Set<Polygon> myPolygon() {
    Set<Polygon> polygonSet = new Set();
    polygonSet.add(Polygon(
        polygonId: PolygonId('test'),
        points: polygonCoords,
        fillColor: Colors.green.shade100,
        geodesic: true,
        strokeWidth: 1,
        strokeColor: Colors.green));

    return polygonSet;
  }


  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 2,
        patterns: [PatternItem.dash(10), PatternItem.gap(10)],
        jointType: JointType.round);
    polylines[id] = polyline;

    setState(() {});
  }

   bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }

  LatLng getPointOnLine(var distance, Direction direction, LatLng l) {
    LatLng lat = new LatLng(0.0, 0.0);
    switch (direction) {
      case Direction.E:
        for (int i = 0; i < distance + 1; i++) {
          LatLng ll = fromEPosition(l, i / 1000);
          print('${ll.latitude},${ll.longitude}');
          print(_checkIfValidMarker(ll, polygonCoords));
          if (_checkIfValidMarker(ll, polygonCoords)) {
            lat = ll;
            continue;
          } else {
            print('${ll.latitude},${ll.longitude}');
            lat = ll;
          }
        }
        break;
      case Direction.W:
        for (int i = 0; i < distance + 1; i++) {
          LatLng ll = fromWPosition(l, i / 1000);
          print('${ll.latitude},${ll.longitude}');
          print(_checkIfValidMarker(ll, polygonCoords));
          if (_checkIfValidMarker(ll, polygonCoords)) {
            lat = ll;
            continue;
          } else {
            print('${ll.latitude},${ll.longitude}');
            lat = ll;
          }
        }
        break;
    }
    return lat;
  }

  //West Direction
  LatLng fromWPosition(LatLng position, double m) {
    double radiusEarth = 6378;
    var newLongitude = position.longitude -
        (m / radiusEarth) * (180 / pi) / cos(position.latitude * pi / 180);
    return new LatLng(position.latitude, newLongitude);
  }

  //East Direction
  LatLng fromEPosition(LatLng position, double m) {
    double radiusEarth = 6378;

    var newLongitude = position.longitude +
        (m / radiusEarth) * (180 / pi) / cos(position.latitude * pi / 180);
    return new LatLng(position.latitude, newLongitude);
  }

  void addPoint(LatLng l1, LatLng l2) {
    polylineCoordinates.add(polygonCoords.elementAt(0));
    polylineCoordinates.add(polygonCoords.elementAt(1));
    polylineCoordinates.add(l2);
    polylineCoordinates.add(l1);
    polylineCoordinates.add(polygonCoords.elementAt(0));
    _addPolyLine();
  }
}

enum Direction { E, W, N, S }
