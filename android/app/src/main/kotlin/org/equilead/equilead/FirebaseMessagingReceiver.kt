package org.equilead.equilead

import android.content.BroadcastReceiver
import android.content.Intent
import android.util.Log
import android.content.ComponentName
import android.content.Context
import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugin.common.PluginRegistry.Registrar

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import android.content.pm.PackageManager
import com.google.firebase.messaging.FirebaseMessagingService

import android.app.AlarmManager
import android.app.PendingIntent
import java.util.*
import android.app.NotificationChannel
import android.app.NotificationManager
import androidx.core.app.NotificationCompat
import android.os.Build

 class FirebaseMessagingReceiver: BroadcastReceiver() {
    override fun onReceive (context: Context,intent: Intent ){
        Log.d("MyFirebaseMsgService", "broadcast received for message");
        val extras = intent.getExtras()
        var remote = RemoteMessage(extras)
        remote.data.isNotEmpty().let {
            Log.d("RemoteNotification", "Message data payload: ${remote.data}")
            val iconName = remote.data["icon_name"]
            // changeIcon(context,iconName)
        }

    }
    // private fun showNotification(context: Context, title: String, body: String) {
    //     val channelId = "default_channel_id"
    //     val channelName = "Default Channel"

    //     val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    //     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    //         val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
    //         notificationManager.createNotificationChannel(channel)
    //     }

    //     val notification = NotificationCompat.Builder(context, channelId)
    //         .setContentTitle(title)
    //         .setContentText(body)
    //         .setSmallIcon(R.mipmap.ic_launcher)
    //         .build()

    //     notificationManager.notify(1, notification)
    // }

   private fun scheduleNotification(context: Context, title: String, body: String, timeInMillis: Long) {
        val intent = Intent(context, FirebaseMessagingReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("body", body)
        }
    
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeInMillis, pendingIntent)
    }

//     private fun changeIcon(context: Context,iconName: String?) {
//         val pm = context.packageManager
//         pm.setComponentEnabledSetting(
//             ComponentName(context, "com.hoomans.equilead.MainActivityAron"),
//             PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
//             PackageManager.DONT_KILL_APP
//         )
//         pm.setComponentEnabledSetting(
//                 ComponentName(context, "com.hoomans.equilead.MainActivity"),
//                 PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
//                 PackageManager.DONT_KILL_APP
//             )
//         when (iconName) {
//             "aron" -> pm.setComponentEnabledSetting(
//                 ComponentName(context, "com.hoomans.equilead.MainActivityAron"),
//                 PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
//                 PackageManager.DONT_KILL_APP
//               ) else -> pm.setComponentEnabledSetting(
//                 ComponentName(context, "com.hoomans.equilead.MainActivity"),
//                 PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
//                 PackageManager.DONT_KILL_APP
//             )       
//      }
// }

}