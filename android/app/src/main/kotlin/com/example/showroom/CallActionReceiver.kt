package kz.dominium.stroymarket

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.app.NotificationManager

class CallActionReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_ACCEPT = "kz.dominium.stroymarket.ACTION_ACCEPT"
        const val ACTION_DECLINE = "kz.dominium.stroymarket.ACTION_DECLINE"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        val callerName = intent.getStringExtra("caller_name") ?: "Неизвестный"

        Log.d("CallActionReceiver", "Received action=$action for caller=$callerName")

        // Остановить сервис и удалить уведомление
        runCatching { context.stopService(Intent(context, IncomingCallService::class.java)) }
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .cancel(IncomingCallService.NOTIF_ID)

        when (action) {
            ACTION_ACCEPT -> {
                Log.d("CallActionReceiver", "User accepted call → launching MainActivity")

                val openIntent = Intent(context, MainActivity::class.java).apply {
                    addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                Intent.FLAG_ACTIVITY_CLEAR_TOP
                    )
                    putExtra("navigate_to", "rtc_page")
                }

                try {
                    context.startActivity(openIntent)
                    Log.d("CallActionReceiver", "MainActivity launched with navigate_to=rtc_page")
                } catch (e: Exception) {
                    Log.e("CallActionReceiver", "Failed to launch MainActivity: ${e.message}")
                }
            }

            ACTION_DECLINE -> {
                Log.d("CallActionReceiver", "User declined the call")
            }
        }
    }
}
