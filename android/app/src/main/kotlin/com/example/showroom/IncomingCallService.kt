package kz.dominium.stroymarket

import android.app.*
import android.content.Context
import android.content.Intent
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import android.view.WindowManager
import android.app.KeyguardManager
import androidx.core.app.NotificationCompat

class IncomingCallService : Service() {

    companion object {
        const val CHANNEL_ID = "calls_channel"
        const val CHANNEL_NAME = "Incoming Calls"
        const val NOTIF_ID = 1001

        /** Флаг для предотвращения дублирующих звонков */
        @Volatile
        var isCallActive = false
    }

    private var ringtone: Ringtone? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var keyguardLock: KeyguardManager.KeyguardLock? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        Log.d("IncomingCallService", "Service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val callerName = intent?.getStringExtra("caller_name") ?: intent?.getStringExtra("callerName")
        ?: "Неизвестный абонент"

        Log.i("IncomingCallService", "onStartCommand for $callerName")

        // Предотвращаем дублирующий вызов
        if (isCallActive) {
            Log.w("IncomingCallService", "Duplicate call ignored")
            return START_NOT_STICKY
        }
        isCallActive = true

        // Собираем уведомление и запускаем foreground
        val notification = buildCallNotification(callerName)
        try {
            startForeground(NOTIF_ID, notification)
        } catch (e: Exception) {
            Log.e("IncomingCallService", "startForeground failed: ${e.message}")
        }

        // Пробуждаем экран и снимаем кейгард
        wakeScreenAndUnlock()

        // Воспроизводим рингтон
        playRingtone()

        // Если сервис был запущен для демонстрации только уведомления, можно вернуть STICKY/NOT_STICKY
        return START_NOT_STICKY
    }

    private fun buildCallNotification(callerName: String): Notification {
        // Full-screen intent -> Activity, который откроет UI звонка поверх экрана/блокировки
        val fullScreenIntent = Intent(this, CallScreenActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("caller_name", callerName)
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this, 0, fullScreenIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Accept / Decline actions -> BroadcastReceiver
        val acceptIntent = Intent(this, CallActionReceiver::class.java).apply {
            action = CallActionReceiver.ACTION_ACCEPT
            putExtra("caller_name", callerName)
        }
        val declineIntent = Intent(this, CallActionReceiver::class.java).apply {
            action = CallActionReceiver.ACTION_DECLINE
            putExtra("caller_name", callerName)
        }

        val acceptPending = PendingIntent.getBroadcast(
            this, 1, acceptIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val declinePending = PendingIntent.getBroadcast(
            this, 2, declineIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Входящий звонок")
            .setContentText(callerName)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setOngoing(true)
            .setAutoCancel(false)
            .addAction(android.R.drawable.ic_menu_call, "Принять", acceptPending)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Отклонить", declinePending)
            .build()
    }

    private fun wakeScreenAndUnlock() {
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            // Для совместимости используем старые флаги (на новых версиях система предпочитает setTurnScreenOn/setShowWhenLocked в Activity)
            wakeLock = pm.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or
                        PowerManager.ACQUIRE_CAUSES_WAKEUP or
                        PowerManager.ON_AFTER_RELEASE,
                "stroymarket:CallWakeLock"
            ).apply {
                setReferenceCounted(false)
                acquire(10_000L) // 10s
            }

            val keyguardManager =
                getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardLock = keyguardManager.newKeyguardLock("stroymarket:KeyguardLock")
            try {
                keyguardLock?.disableKeyguard()
            } catch (t: Throwable) {
                // Некоторые Android версии не поддерживают. Игнорируем.
                Log.w("IncomingCallService", "disableKeyguard failed: ${t.message}")
            }

            Log.d("IncomingCallService", "Screen wake and keyguard unlocked")
        } catch (e: Exception) {
            Log.w("IncomingCallService", "wakeScreen failed: ${e.message}")
        }
    }

    private fun playRingtone() {
        try {
            val uri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            ringtone = RingtoneManager.getRingtone(applicationContext, uri)?.apply {
                // Безопасно задаём атрибуты, если поддерживается
                try {
                    audioAttributes = android.media.AudioAttributes.Builder()
                        .setUsage(android.media.AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                        .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                } catch (_: Throwable) {}
                play()
            }
            Log.d("IncomingCallService", "Ringtone started")
        } catch (e: Exception) {
            Log.w("IncomingCallService", "Ringtone failed: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopRingtone()
        releaseWakeLock()
        releaseKeyguard()
        isCallActive = false
        Log.d("IncomingCallService", "Service destroyed")
    }

    private fun stopRingtone() {
        try {
            ringtone?.stop()
            ringtone = null
        } catch (_: Exception) {}
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
            wakeLock = null
        } catch (_: Exception) {}
    }

    private fun releaseKeyguard() {
        try {
            keyguardLock?.reenableKeyguard()
            keyguardLock = null
        } catch (_: Exception) {}
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            val existing = manager.getNotificationChannel(CHANNEL_ID)
            if (existing == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifications for incoming calls"
                    setSound(null, null) // звук управляем вручную через Ringtone
                    enableVibration(true)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                manager.createNotificationChannel(channel)
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
