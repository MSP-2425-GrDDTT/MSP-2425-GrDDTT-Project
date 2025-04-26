import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_test/main.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'speedmetertest.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _addressController = TextEditingController();

  String? eta;
  double currentZoomLevel = 13.5;

  LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  LatLng destinationLocation = LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
      });
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(newLoc.latitude!, newLoc.longitude!),
          zoom: currentZoomLevel,
        ),
      ));
      setState(() {});
    });
  }

  void getPolyPoints() async {
    if (currentLocation == null) {
      //print("Missing location data");
      return;
    }

    polylineCoordinates.clear();

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_maps_key,
      PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!), // 💡 use current location
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
    );

    /*print("Polyline status: ${result.status}");
    print("Polyline error message: ${result.errorMessage}");
    print("Polyline points count: ${result.points.length}");*/

    if (result.points.isNotEmpty) {
      polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      setState(() {});
    }
  }


  Future<void> searchDestinationAndDrawRoute(String address) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      //print("Geocoded locations: $locations");

      if (locations.isNotEmpty) {
        final loc = locations.first;
        //print("LatLng: ${loc.latitude}, ${loc.longitude}");
        destinationLocation = LatLng(loc.latitude, loc.longitude);
        getPolyPoints();
        calculateETAAndDuration();
        setState(() {});
      }
      else {
        //print("No geocoding results.");
      }
    } catch (e) {
      //print("Geocoding error: $e");
    }
  }


  void setCustomMarkerIcon() async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/Pin_source.png")
        .then((icon) {
      sourceIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/Pin_destination.png")
        .then((icon) {
      destinationIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/Badge.png")
        .then((icon) {
      currentLocationIcon = icon;
    });
  }

  void calculateETAAndDuration() async {
    if (currentLocation == null) {
      //print("Missing location data for ETA and duration calculation");
      return;
    }

    // Calculate the distance in meters
    double distanceInMeters = Geolocator.distanceBetween(
      currentLocation!.latitude!,
      currentLocation!.longitude!,
      destinationLocation.latitude,
      destinationLocation.longitude,
    );

    /*print("Distance in meters: $distanceInMeters");

    print("Current Location: ${currentLocation!.latitude}, ${currentLocation!.longitude}");
    print("Destination Location: ${destinationLocation.latitude}, ${destinationLocation.longitude}");*/


    // Use a more realistic average speed in km/h (e.g., 40 km/h for urban driving)
    double averageSpeedInKmPerHour = 50.0;

    // Convert speed to meters per second for consistency
    double averageSpeedInMetersPerSecond = averageSpeedInKmPerHour / 3.6;

    // Calculate time in seconds
    double timeInSeconds = distanceInMeters / averageSpeedInMetersPerSecond;

    // Convert to a readable format
    DateTime arrivalTime = DateTime.now().add(Duration(seconds: timeInSeconds.toInt()));
    String formattedETA = DateFormat('HH:mm').format(arrivalTime);

    // Calculate duration in minutes or hours
    String formattedDuration;
    if (timeInSeconds < 3600) {
      // Less than 1 hour, show only minutes
      formattedDuration = "${(timeInSeconds / 60).toInt()} min";
    } else {
      // 1 hour or more, show hours and minutes
      int hours = (timeInSeconds / 3600).floor();
      int minutes = ((timeInSeconds % 3600) / 60).toInt();
      if (minutes == 0) {
        formattedDuration = "$hours h";
      } else {
        formattedDuration = "$hours h $minutes min";
      }
    }

    setState(() {
      eta = "ETA: $formattedETA, Duration: $formattedDuration";
    });
  }

  @override
  void initState(){
    super.initState();
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return currentLocation == null
        ? const Center(child: Text("Loading..."))
        : Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: currentZoomLevel,
                ),
                onCameraMove: (position) {
                  currentZoomLevel = position.zoom;
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    color: Colors.blue,
                    width: 6,
                    points: polylineCoordinates,
                  )
                },
                markers: {
                  Marker(
                    markerId: const MarkerId("currentLocation"),
                    icon: currentLocationIcon,
                    position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  ),
                  Marker(
                    markerId: const MarkerId("source"),
                    icon: sourceIcon,
                    position: sourceLocation,
                  ),
                  Marker(
                    markerId: const MarkerId("destination"),
                    icon: destinationIcon,
                    position: destinationLocation,
                  )
                },
                onMapCreated: (mapController) {
                  _controller.complete(mapController);
                },
              ),
            ),
            if (eta != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$eta",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        hintText: "Enter destination address",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_addressController.text.isNotEmpty && currentLocation != null) {
                        searchDestinationAndDrawRoute(_addressController.text);
                      } else {
                        print("Current location not available yet.");
                      }
                    },
                    child: const Text("Go"),
                  )
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 100,
          left: 20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.8),
            ),
            child: const FakeSpeedMeter(),
          ),
        ),
      ],
    );
  }
}