import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RoutingMap extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;
  final List<LatLng> polylinePoints;
  final List<LatLng> passedRoutePoints; // 👈 добавляем сюда
  final Function(LatLng point) onTap;

  const RoutingMap({
    super.key,
    required this.mapController,
    required this.markers,
    required this.polylinePoints,
    required this.passedRoutePoints, // 👈 обязательно передать
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final center = polylinePoints.isNotEmpty
        ? polylinePoints.first
        : markers.isNotEmpty
        ? markers.first.point
        : const LatLng(43.238949, 76.889709);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: center,
        zoom: 13,
        onTap: (tapPosition, point) => onTap(point),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.flutter_valhalla',
        ),
        PolylineLayer(
        polylineCulling: false,
        polylines: [
          Polyline(
            points: polylinePoints,
            color: Colors.blue,
            strokeWidth: 4,
          ),
          Polyline(
        points: passedRoutePoints,
        color: Colors.green,
        strokeWidth: 6,
        ),

        ],
        ),
        MarkerLayer(
          markers: markers,
        ),

      ],
    );
  }
}
