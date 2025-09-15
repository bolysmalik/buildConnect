package com.example.showroom

object PolylineDecoder {
    fun decode(encoded: String): List<Map<String, Double>> {
        val coordinates = mutableListOf<Map<String, Double>>()
        var index = 0
        val len = encoded.length
        var lat = 0
        var lon = 0

        while (index < len) {
            var result = 1
            var shift = 0
            var b: Int
            do {
                b = encoded[index++].code - 63 - 1
                result += b shl shift
                shift += 5
            } while (b >= 0x1f)
            lat += if (result and 1 != 0) (result shr 1).inv() else result shr 1

            result = 1
            shift = 0
            do {
                b = encoded[index++].code - 63 - 1
                result += b shl shift
                shift += 5
            } while (b >= 0x1f)
            lon += if (result and 1 != 0) (result shr 1).inv() else result shr 1

            coordinates.add(
                mapOf(
                    "lat" to lat.toDouble() * 1e-6,
                    "lon" to lon.toDouble() * 1e-6
                )
            )
        }
        return coordinates
    }
}
