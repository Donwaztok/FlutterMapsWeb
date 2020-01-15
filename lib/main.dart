import 'package:flutter/material.dart';
import 'package:google_maps/google_maps.dart' hide Icon;
import 'dart:html';
import 'dart:ui' as ui;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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

      // Create a renderer for directions and bind it to the map.
      final rendererOptions = DirectionsRendererOptions()..map = map;
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

    // Now, clear the array itself.
    markerArray.clear();

    // Retrieve the start and end locations and create
    // a DirectionsRequest using WALKING directions.
    final start = (document.getElementById('start') as SelectElement).value;
    final end = (document.getElementById('end') as SelectElement).value;
    final request = DirectionsRequest()
      ..origin = start
      ..destination = end
      ..travelMode = TravelMode.DRIVING;

    // Route the directions and pass the response to a
    // function to create markers for each step.
    directionsService.route(request, (response, status) {
      if (status == DirectionsStatus.OK) {
        querySelector('#warnings_panel').innerHtml =
            '<b>${response.routes[0].warnings}</b>';
        directionsDisplay.directions = response;
        showSteps(response);
      }
    });
  }

  void showSteps(DirectionsResult directionResult) {
    // For each step, place a marker, and add the text to the marker's
    // info window. Also attach the marker to an array so we
    // can keep track of it and remove it when calculating new
    // routes.
    final myRoute = directionResult.routes[0].legs[0];

    for (final step in myRoute.steps) {
      final marker = Marker(MarkerOptions()
        ..position = step.startLocation
        ..map = map);
      attachInstructionText(marker, step.instructions);
      markerArray.add(marker);
    }
  }

  void attachInstructionText(Marker marker, String text) {
    marker.onClick.listen((e) {
      // Open an info window when the marker is clicked on,
      // containing the text of the step.
      stepDisplay.content = text;
      stepDisplay.open(map, marker);
    });
  }
}
