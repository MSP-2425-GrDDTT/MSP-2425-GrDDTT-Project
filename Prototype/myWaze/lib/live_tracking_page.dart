import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_test/main.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _addressController = TextEditingController();

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
          zoom: 13.5,
        ),
      ));
      setState(() {});
    });
  }

  void getPolyPoints() async {
    if (currentLocation == null || destinationLocation == null) {
      print("Missing location data");
      return;
    }

    polylineCoordinates.clear();

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_maps_key,
      PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!), // 💡 use current location
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
    );

    print("Polyline status: ${result.status}");
    print("Polyline error message: ${result.errorMessage}");
    print("Polyline points count: ${result.points.length}");

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
      print("Geocoded locations: $locations");

      if (locations.isNotEmpty) {
        final loc = locations.first;
        print("LatLng: ${loc.latitude}, ${loc.longitude}");
        destinationLocation = LatLng(loc.latitude, loc.longitude);
        getPolyPoints();
        setState(() {});
      }
      else {
        print("No geocoding results.");
      }
    } catch (e) {
      print("Geocoding error: $e");
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

  @override
  void initState(){
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentLocation == null
        ? const Center(child: Text("Loading..."))
        : Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              zoom: 14.5,
            ),
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
    );
  }
}