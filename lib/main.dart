import 'package:flutter/material.dart' hide Icon;
import 'package:google_maps/google_maps.dart';
import 'dart:html';
import 'dart:ui' as ui;

const IMAGE_URL =
    'https://google-developers.appspot.com/maps/documentation/javascript/examples/full';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: getMap(),
      ),
    );
  }

  GMap map;
  DirectionsRenderer directionsDisplay;
  DirectionsService directionsService;
  InfoWindow stepDisplay;
  final markerArray = <Marker>[];

  Widget getMap() {
    String htmlId = "7";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      directionsService = DirectionsService();

      // Create a map and center it on Manhattan.
      final manhattan = LatLng(40.7711329, -73.9741874);
      final mapOptions = MapOptions()
        ..zoom = 13
        ..center = manhattan;
      final elem = document.getElementById('map-canvas');
      final map = GMap(elem, mapOptions);

      final image = Icon()
        ..url = '$IMAGE_URL/images/beachflag.png'
        ..size = Size(20, 32)
        ..origin = Point(0, 0)
        ..anchor = Point(0, 32);
      final shape = MarkerShape()
        ..coords = [1, 1, 1, 20, 18, 20, 18, 1]
        ..type = 'poly';

      final marker = MarkerOptions()
        ..icon = image
        ..shape = shape;
      final polyline = PolylineOptions()
        ..strokeColor = '#5a5aFF'
        ..strokeOpacity = 0.7
        ..strokeWeight = 5;

      // Create a renderer for directions and bind it to the map.
      final rendererOptions = DirectionsRendererOptions()..map = map;
      rendererOptions.markerOptions = marker;
      rendererOptions.polylineOptions = polyline;
      directionsDisplay = DirectionsRenderer(rendererOptions);
      stepDisplay = InfoWindow();

      document.getElementById('start').onChange.listen((e) => calcRoute());
      document.getElementById('end').onChange.listen((e) => calcRoute());

      return elem;
    });

    return HtmlElementView(viewType: htmlId);
  }

  void calcRoute() {
    // First, remove any existing markers from the map.
    for (final marker in markerArray) {
      marker.map = null;
    }
    markerArray.clear();

    final start = (document.getElementById('start') as SelectElement).value;
    final end = (document.getElementById('end') as SelectElement).value;
    final request = DirectionsRequest()
      ..origin = start
      ..destination = end
      ..travelMode = TravelMode.DRIVING;

    directionsService.route(request, (response, status) {
      if (status == DirectionsStatus.OK) {
        querySelector('#warnings_panel').innerHtml =
            '<b>${response.routes[0].warnings}</b>';
        directionsDisplay.directions = response;
      }
    });
  }
}
