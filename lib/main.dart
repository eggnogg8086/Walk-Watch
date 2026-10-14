import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: lightDynamic ??
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6750A4),
                ),
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6750A4),
                  brightness: Brightness.dark,
                ),
          ),
          themeMode: ThemeMode.system,
          home: const MyHomePage(title: 'Flutdter'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();


}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _startPositionStream();
  }

  GoogleMapController? mapController;

  StreamSubscription<Position>? positionStream;

  LatLng _center = const LatLng(14.5995, 120.9842);

  Future<void> _startPositionStream() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint('Please enable device location services.');
      return;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Location permission not granted.');
      return;
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      final target = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _center = target;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLng(target),
      );
    });
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    controller.animateCamera(
      CameraUpdate.newLatLng(_center),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 18,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
          onPressed: null,
          tooltip: 'Increment',
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }
}

