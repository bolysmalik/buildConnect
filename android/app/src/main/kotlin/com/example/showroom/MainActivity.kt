package kz.dominium.stroymarket

import ValhallaConfigBuilder
import android.content.Context
import android.content.Intent
import android.os.*
import android.util.Log
import android.view.WindowManager
import com.google.gson.Gson
import com.valhalla.api.models.*
import com.valhalla.valhalla.Valhalla
import com.valhalla.valhalla.ValhallaResponse
import com.valhalla.valhalla.config.ValhallaConfigManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File

class MainActivity : FlutterActivity() {

    private val VALHALLA_CHANNEL = "valhalla_channel"
    private val CALL_CHANNEL = "kz.dominium.stroymarket/call_channel"

    private lateinit var valhalla: Valhalla
    private var isInitialized = false
    private var tilesPath: String? = null
    private lateinit var configManager: ValhallaConfigManager

    private lateinit var callChannel: MethodChannel
    private var pendingRtcIntent = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Разрешаем показ при заблокированном экране
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )

        handleIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // --- Valhalla channel ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VALHALLA_CHANNEL)
            .setMethodCallHandler(::handleValhallaMethods)

        // --- Call channel ---
        callChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_CHANNEL)
        callChannel.setMethodCallHandler(::handleCallMethods)

        // ✅ Проверяем, есть ли отложенный переход в RTCPage
        if (pendingRtcIntent || intent?.getStringExtra("navigate_to") == "rtc_page") {
            Log.d("MainActivity", "✅ Flutter ready — opening RTCPage after engine init")
            openRtcPageSafely()
            intent?.removeExtra("navigate_to")
            pendingRtcIntent = false
        }
    }

    // ----------------- Valhalla -----------------
    private fun handleValhallaMethods(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init_valhalla" -> initValhalla(call, result)
            "get_route" -> getRoute(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initValhalla(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("tilesPath") ?: return result.error("NO_PATH", "Path is null", null)
        try {
            val file = File(path)
            if (!file.exists()) return result.error("FILE_NOT_FOUND", "Tiles not found", null)

            configManager = ValhallaConfigManager(this)
            val config = ValhallaConfigBuilder().withTileExtract(path).build()
            valhalla = Valhalla(this, config, configManager)
            tilesPath = path
            isInitialized = true

            Log.d("ValhallaINIT", "✅ Initialized with $path")
            result.success(true)
        } catch (e: Exception) {
            Log.e("ValhallaINIT", "Init failed", e)
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun getRoute(call: MethodCall, result: MethodChannel.Result) {
        if (!isInitialized || tilesPath == null)
            return result.error("NOT_INITIALIZED", "Valhalla not initialized", null)

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val fromLat = call.argument<Double>("from_lat")!!
                val fromLon = call.argument<Double>("from_lon")!!
                val toLat = call.argument<Double>("to_lat")!!
                val toLon = call.argument<Double>("to_lon")!!
                val costingStr = call.argument<String>("costing") ?: "auto"
                val viaPoints = call.argument<List<Map<String, Double>>>("via_points") ?: emptyList()

                val waypoints = mutableListOf<RoutingWaypoint>().apply {
                    add(RoutingWaypoint(fromLat, fromLon))
                    viaPoints.forEach { p -> p["lat"]?.let { lat -> p["lon"]?.let { lon -> add(RoutingWaypoint(lat, lon)) } } }
                    add(RoutingWaypoint(toLat, toLon))
                }

                val costing = when (costingStr) {
                    "pedestrian" -> CostingModel.pedestrian
                    "bicycle" -> CostingModel.bicycle
                    "truck" -> CostingModel.truck
                    "bus" -> CostingModel.bus
                    "motor_scooter" -> CostingModel.motor_scooter
                    else -> CostingModel.auto
                }

                val request = RouteRequest(
                    locations = waypoints,
                    costing = costing,
                    directionsOptions = DirectionsOptions(format = DirectionsOptions.Format.osrm)
                )

                val response = valhalla.route(request)
                val jsonString = Gson().toJson(response)
                withContext(Dispatchers.Main) { result.success(jsonString) }

            } catch (e: Exception) {
                Log.e("ValhallaRoute", "Route error", e)
                withContext(Dispatchers.Main) { result.error("ROUTE_ERROR", e.message, null) }
            }
        }
    }

    // ----------------- Call -----------------
    private fun handleCallMethods(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startIncomingCallService" -> startIncomingCallService(call, result)
            "wakeScreen" -> wakeScreen(result)
            else -> result.notImplemented()
        }
    }

    private fun startIncomingCallService(call: MethodCall, result: MethodChannel.Result) {
        val callerName = call.argument<String>("caller_name") ?: "Неизвестный"
        val intent = Intent(this, IncomingCallService::class.java).apply {
            putExtra("caller_name", callerName)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                startForegroundService(intent)
            else
                startService(intent)
            result.success(true)
        } catch (e: Exception) {
            Log.e("CallChannel", "Failed to start IncomingCallService", e)
            result.error("SERVICE_ERROR", e.message, null)
        }
    }

    private fun wakeScreen(result: MethodChannel.Result) {
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!pm.isInteractive) {
                val wakeLock = pm.newWakeLock(
                    PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                    "stroymarket:CallWakeLock"
                )
                wakeLock.acquire(3000L)
                wakeLock.release()
            }
            result.success(true)
        } catch (e: Exception) {
            Log.e("CallChannel", "Wake screen failed", e)
            result.error("WAKE_ERROR", e.message, null)
        }
    }

    // ----------------- Intent Handling -----------------
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent ?: return
        if (intent.getStringExtra("navigate_to") == "rtc_page") {
            Log.d("MainActivity", "navigate_to=rtc_page detected in handleIntent")
            openRtcPageSafely()
        }
    }

    override fun onPostResume() {
        super.onPostResume()
        if (intent?.getStringExtra("navigate_to") == "rtc_page") {
            Log.d("MainActivity", "onPostResume: navigate_to=rtc_page")
            openRtcPageSafely()
            intent?.removeExtra("navigate_to")
        }
    }

    // ----------------- Надёжный запуск RTC -----------------
    private fun openRtcPageSafely() {
        if (::callChannel.isInitialized) {
            Log.d("MainActivity", "✅ openRtcPage via Flutter channel")
            callChannel.invokeMethod("openRtcPage", null)
            pendingRtcIntent = false
        } else {
            Log.d("MainActivity", "⚠️ Flutter not ready — set pendingRtcIntent")
            pendingRtcIntent = true
        }
    }
}
