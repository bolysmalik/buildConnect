import 'package:latlong2/latlong.dart';

List<LatLng> decodeValhallaPolyline(String encoded) {
  int index = 0;
  int lat = 0;
  int lng = 0;
  final coordinates = <LatLng>[];

  while (index < encoded.length) {
    int shift = 0;
    int result = 0;
    int byte;

    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += deltaLat;

    shift = 0;
    result = 0;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += deltaLng;

    coordinates.add(LatLng(lat / 1e6, lng / 1e6));
  }

  return coordinates;
}
