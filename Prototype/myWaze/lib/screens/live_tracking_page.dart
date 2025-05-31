import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;

const String google_maps_key = "AIzaSyABzruSY9X5pBiD50bfYUUEOUO8zloO1jE";
const String google_places_key = "YOUR_GOOGLE_PLACES_API_KEY";

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

  BitmapDescriptor policeIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  BitmapDescriptor gasStationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  BitmapDescriptor hazardIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

  bool _isTrafficEnabled = false;

  // Visibility toggles
  bool _showPoliceAlerts = true;
  bool _showHazardAlerts = true;
  bool _showGasStations = true;

  List<Alert> alerts = []; // all alerts (police + hazard)
  List<Marker> alertMarkers = []; // all alert markers (police + hazard)
  List<Marker> gasStationMarkers = []; // gas station markers

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    _loadMockAlerts();
  }

  void _loadMockAlerts() {
    // Mock police and hazard alerts near destinationLocation
    alerts = [
      Alert(
        id: "police1",
        type: "police",
        position: LatLng(destinationLocation.latitude + 0.001, destinationLocation.longitude + 0.001),
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      Alert(
        id: "hazard1",
        type: "hazard",
        position: LatLng(destinationLocation.latitude + 0.002, destinationLocation.longitude - 0.002),
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      ),
    ];
    _updateAlertMarkers();
  }

  void _updateAlertMarkers() {
    List<Marker> markers = [];
    for (var alert in alerts) {
      BitmapDescriptor icon;
      String title = "";
      if (alert.type == "police") {
        icon = policeIcon;
        title = "Police Reported";
      } else if (alert.type == "hazard") {
        icon = hazardIcon;
        title = "Road Hazard";
      } else {
        continue;
      }

      markers.add(
        Marker(
          markerId: MarkerId(alert.id),
          position: alert.position,
          icon: icon,
          infoWindow: InfoWindow(title: title, snippet: "Reported at ${DateFormat('hh:mm a').format(alert.timestamp)}"),
        ),
      );
    }
    setState(() {
      alertMarkers = markers;
    });
  }

  Future<void> _fetchNearbyGasStations() async {
    if (currentLocation == null) return;
    final lat = currentLocation!.latitude!;
    final lng = currentLocation!.longitude!;

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=3000&type=gas_station&key=$google_places_key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List results = json['results'];
      List<Marker> gasMarkers = [];
      for (var place in results) {
        final loc = place['geometry']['location'];
        gasMarkers.add(Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(loc['lat'], loc['lng']),
          icon: gasStationIcon,
          infoWindow: InfoWindow(title: place['name']),
        ));
      }
      setState(() {
        gasStationMarkers = gasMarkers;
      });
    } else {
      print('Failed to fetch gas stations: ${response.statusCode}');
    }
  }
void _reportEvent(String eventType) {
  if (currentLocation == null) return;

  final LatLng userPosition = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
  final newAlert = Alert(
    id: '${eventType}_${DateTime.now().millisecondsSinceEpoch}',
    type: eventType,
    position: userPosition,
    timestamp: DateTime.now(),
  );

  alerts.add(newAlert);
  _updateAlertMarkers();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$eventType reported!')),
  );
}

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
      });
      _fetchNearbyGasStations();
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
      _fetchNearbyGasStations();
      _checkNearbyHazards();

      setState(() {});
    });
  }

  void _checkNearbyHazards() {
    if (currentLocation == null) return;

    final userLat = currentLocation!.latitude!;
    final userLng = currentLocation!.longitude!;

    for (var alert in alerts) {
      if (alert.type == "hazard") {
        double distanceMeters = Geolocator.distanceBetween(
          userLat,
          userLng,
          alert.position.latitude,
          alert.position.longitude,
        );
        if (distanceMeters < 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Warning: Road hazard nearby!')),
          );
          break;
        }
      }
    }
  }

  void getPolyPoints() async {
    if (currentLocation == null) return;

    polylineCoordinates.clear();

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_maps_key,
      PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      setState(() {});
    }
  }

  Future<void> searchDestinationAndDrawRoute(String address) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        destinationLocation = LatLng(loc.latitude, loc.longitude);
        getPolyPoints();
        calculateETAAndDuration();
        _loadMockAlerts(); // refresh alerts near new destination
        setState(() {});
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
  }

  void setCustomMarkerIcon() async {
    policeIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    gasStationIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

    hazardIcon = await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    sourceIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/Pin_source.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/Pin_destination.png");
    currentLocationIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/Badge.png");

    setState(() {});
  }

  void calculateETAAndDuration() async {
    if (currentLocation == null) return;

    double distanceInMeters = Geolocator.distanceBetween(
      currentLocation!.latitude!,
      currentLocation!.longitude!,
      destinationLocation.latitude,
      destinationLocation.longitude,
    );

    double averageSpeedInKmPerHour = 50.0;
    double averageSpeedInMetersPerSecond = averageSpeedInKmPerHour / 3.6;

    double timeInSeconds = distanceInMeters / averageSpeedInMetersPerSecond;

    DateTime arrivalTime = DateTime.now().add(Duration(seconds: timeInSeconds.toInt()));
    String formattedETA = DateFormat('HH:mm').format(arrivalTime);

    String formattedDuration;
    if (timeInSeconds < 3600) {
      formattedDuration = "${(timeInSeconds / 60).toInt()} min";
    } else {
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

  void _reportEvent2(String eventType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$eventType reported!')),
    );
  }

  void _toggleTraffic() {
    setState(() {
      _isTrafficEnabled = !_isTrafficEnabled;
    });
  }

  void _togglePoliceAlerts() {
    setState(() {
      _showPoliceAlerts = !_showPoliceAlerts;
    });
  }

  void _toggleHazardAlerts() {
    setState(() {
      _showHazardAlerts = !_showHazardAlerts;
    });
  }

  void _toggleGasStations() {
    setState(() {
      _showGasStations = !_showGasStations;
    });
  }

  void _showEmergencyDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => EmergencyAssistSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Center(child: Text("Loading..."));
    }

    // Filter markers based on toggles
    List<Marker> displayedAlertMarkers = alertMarkers.where((marker) {
      final alert = alerts.firstWhere((a) => a.id == marker.markerId.value);
      if (alert.type == "police" && !_showPoliceAlerts) return false;
      if (alert.type == "hazard" && !_showHazardAlerts) return false;
      return true;
    }).toList();

    return Scaffold(
      body: Stack(
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
                  trafficEnabled: _isTrafficEnabled,
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
                    ),
                    ...displayedAlertMarkers,
                    if (_showGasStations) ...gasStationMarkers,
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
            top: 40,
            right: 20,
            child: FloatingActionButton(
              onPressed: _showEmergencyDialog,
              backgroundColor: Colors.red,
              child: const Icon(Icons.sos, color: Colors.white),
              tooltip: 'Emergency SOS',
            ),
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
        Positioned(
          top: 120,
          right: 20,
          child: FloatingActionButton (
           onPressed: () => _reportEvent("police"),

            backgroundColor: Colors.blue,
              child: const Icon(Icons.local_police, color: Colors.white),
             
          ),
        ),

         Positioned(
            bottom: 200,
            right: 20, 
             child: Center(
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Colors.white,
              children: [
                SpeedDialChild(
                  child: Icon(_showPoliceAlerts ? Icons.local_police : Icons.local_police_outlined),
                  label: _showPoliceAlerts ? 'Hide Police Alerts' : 'Show Police Alerts',
                  onTap: _togglePoliceAlerts,
                ),
                SpeedDialChild(
                  child: Icon(_showGasStations ? Icons.local_gas_station : Icons.local_gas_station_outlined),
                  label: _showGasStations ? 'Hide Gas Stations' : 'Show Gas Stations',
                  onTap: _toggleGasStations,
                ),
                SpeedDialChild(
                  child: Icon(_showHazardAlerts ? Icons.warning : Icons.warning_amber_outlined),
                  label: _showHazardAlerts ? 'Hide Road Hazards' : 'Show Road Hazards',
                  onTap: _toggleHazardAlerts,
                ),
                SpeedDialChild(
                  child: Icon(_isTrafficEnabled ? Icons.visibility_off : Icons.traffic),
                  label: _isTrafficEnabled ? 'Disable Traffic' : 'Enable Traffic',
                  onTap: _toggleTraffic,
                ),
                SpeedDialChild(
                  child: const Icon(Icons.call),
                  label: 'Emergency Assist',
                  onTap: _showEmergencyDialog,
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model for alerts 
class Alert {
  final String id;
  final String type; // police, hazard, gas_station  
  final LatLng position;
  final DateTime timestamp;

  Alert({
    required this.id,
    required this.type,
    required this.position,
    required this.timestamp,
  });
}

class FakeSpeedMeter extends StatelessWidget {
  const FakeSpeedMeter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Speed\n65 km/h",
        style: TextStyle(color: Colors.white, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class EmergencyAssistSheet extends StatelessWidget {
  const EmergencyAssistSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Emergency Assist',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Add call emergency contact functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling emergency contact...')),
              );
            },
            icon: Icon(Icons.call),
            label: Text('Call Emergency Contact'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
               Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('SOS alert sent!')),
              );
            },
            icon: Icon(Icons.warning_amber_rounded),
            label: Text('Send SOS Alert'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
               Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Location shared with contacts!')),
              );
            },
            icon: Icon(Icons.share_location),
            label: Text('Share Location'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }
}