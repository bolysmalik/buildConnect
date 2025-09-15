package kz.dominium.stroymarket

import android.app.Activity
import android.content.Intent
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

class CallScreenActivity : Activity() {

    private var ringtone: Ringtone? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ Показ при заблокированном экране
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }

        setContentView(R.layout.activity_call_screen)

        val callerName = intent.getStringExtra("caller_name")
            ?: intent.getStringExtra("callerName")
            ?: "Неизвестный абонент"

        findViewById<TextView>(R.id.callerName).text = callerName

        // 🔔 Проигрывание рингтона
        try {
            val uri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            ringtone = RingtoneManager.getRingtone(applicationContext, uri)
            ringtone?.play()
        } catch (e: Exception) {
            Log.w("CallScreen", "Ошибка рингтона: ${e.message}")
        }

        // ✅ Кнопка «Принять»
        findViewById<Button>(R.id.acceptButton).setOnClickListener {
            stopRingtone()
            Log.d("CallScreen", "✅ Звонок принят")

            // Открываем MainActivity c navigate_to=rtc_page
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("navigate_to", "rtc_page")
            }
            startActivity(intent)
            finish()
        }

        // ✅ Кнопка «Отклонить»
        findViewById<Button>(R.id.declineButton).setOnClickListener {
            stopRingtone()
            Log.d("CallScreen", "❌ Звонок отклонён")
            finish()
        }
    }

    private fun stopRingtone() {
        try {
            ringtone?.stop()
        } catch (e: Exception) {
            Log.w("CallScreen", "Ошибка при остановке рингтона: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopRingtone()
    }
}
