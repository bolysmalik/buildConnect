import Foundation
import Flutter
import Valhalla
import ValhallaModels
import ValhallaConfigModels

@MainActor
class ValhallaRoutingService: NSObject {

    private static var _valhalla: Valhalla?

    private static var valhalla: Valhalla? {
        get { return _valhalla }
        set { _valhalla = newValue }
    }

    func decodePolyline6(_ polyline: String) -> [[String: Double]] {
        var coordinates: [[String: Double]] = []
        var index = polyline.startIndex
        var lat: Int64 = 0
        var lon: Int64 = 0

        while index < polyline.endIndex {
            let (deltaLat, newIndex1) = decodeNextValue(from: polyline, start: index)
            index = newIndex1
            let (deltaLon, newIndex2) = decodeNextValue(from: polyline, start: index)
            index = newIndex2

            lat += deltaLat
            lon += deltaLon

            coordinates.append([
                "lat": Double(lat) / 1e6,
                "lon": Double(lon) / 1e6
            ])
        }

        return coordinates
    }

    func decodeNextValue(from polyline: String, start: String.Index) -> (Int64, String.Index) {
        var index = start
        var result: Int64 = 0
        var shift: Int64 = 0
        var byte: Int64

        repeat {
            let char = polyline[index]
            byte = Int64(char.asciiValue!) - 63
            result |= (byte & 0x1F) << shift
            shift += 5
            index = polyline.index(after: index)
        } while byte >= 0x20

        let decoded = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
        return (decoded, index)
    }

    // === ВАЖНО: `@MainActor` должен быть здесь ===
    @objc @MainActor static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let service = ValhallaRoutingService()

        switch call.method {
        case "init_valhalla":
            // ✅ Если уже инициализировано – возвращаем сразу
            if let _ = valhalla {
                result("Valhalla already initialized")
                return
            }

            // ✅ ИСПРАВЛЕНО: имя аргумента должно соответствовать Dart-коду
            guard let args = call.arguments as? [String: Any],
                  let tilesPath = args["tilesAsset"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing tilesAsset", details: nil))
                return
            }

            do {
                // ✅ Используем переданный путь напрямую
                let tilesURL = URL(fileURLWithPath: tilesPath)
                let config = try ValhallaConfig(tileExtractTar: tilesURL)
                valhalla = try Valhalla(config)

                result("Valhalla initialized")
            } catch {
                result(FlutterError(code: "INIT_FAILED", message: error.localizedDescription, details: nil))
            }

        case "get_route":
            guard let valhalla = valhalla else {
                result(FlutterError(code: "NOT_INITIALIZED", message: "Call init_valhalla first", details: nil))
                return
            }

            guard let args = call.arguments as? [String: Any],
                  let fromLat = args["from_lat"] as? Double,
                  let fromLon = args["from_lon"] as? Double,
                  let toLat = args["to_lat"] as? Double,
                  let toLon = args["to_lon"] as? Double else {
                result(FlutterError(code: "INVALID_COORDS", message: "Missing or invalid coordinates", details: nil))
                return
            }

            do {
                var locations: [RoutingWaypoint] = [
                    RoutingWaypoint(lat: fromLat, lon: fromLon)
                ]

                if let viaList = args["via_points"] as? [[String: Double]] {
                    for via in viaList {
                        if let lat = via["lat"], let lon = via["lon"] {
                            locations.append(RoutingWaypoint(lat: lat, lon: lon))
                        }
                    }
                }

                locations.append(RoutingWaypoint(lat: toLat, lon: toLon))
                let costingStr = args["costing"] as? String ?? "auto"
                let costing: CostingModel
                switch costingStr {
                case "auto": costing = .auto
                case "pedestrian": costing = .pedestrian
                case "bicycle": costing = .bicycle
                case "bus": costing = .bus
                case "truck": costing = .truck
                case "motor_scooter": costing = .motorScooter
                default: costing = .auto
                }

                let request = RouteRequest(
                    locations: locations,
                    costing: costing,
                    directionsOptions: DirectionsOptions(units: .km, shapeFormat: .polyline6)
                )

                let response = try valhalla.route(request: request)
                var allCoordinates: [[String: Double]] = []

                for (index, leg) in response.trip.legs.enumerated() {
                    let shape = leg.shape
                    let coords = service.decodePolyline6(shape)
                    allCoordinates += (index > 0) ? Array(coords.dropFirst()) : coords
                }

                result(allCoordinates)

            } catch {
                result(FlutterError(code: "ROUTE_ERROR", message: error.localizedDescription, details: nil))
            }


        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

