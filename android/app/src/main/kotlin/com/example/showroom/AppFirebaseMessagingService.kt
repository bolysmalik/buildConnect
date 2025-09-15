package kz.dominium.stroymarket

import android.content.Intent
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.os.Build
import android.content.Context

class AppFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        Log.d("AppFirebaseMessaging", "FCM message received: ${remoteMessage.data}")

        val type = remoteMessage.data["type"]
        if (type == "incoming_call" || type == "call") {
            val callerName = remoteMessage.data["caller"] ?: remoteMessage.data["caller_name"] ?: "Неизвестный"

            val svcIntent = Intent(this, IncomingCallService::class.java).apply {
                putExtra("caller_name", callerName)
                putExtra("caller_id", remoteMessage.data["caller_id"])
            }

            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(svcIntent)
                } else {
                    startService(svcIntent)
                }
            } catch (e: Exception) {
                Log.e("AppFirebaseMessaging", "Failed to start IncomingCallService: ${e.message}")
            }
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("AppFirebaseMessaging", "New FCM token: $token")
        // TODO: отправить токен на свой сервер
    }
}