package org.equilead.equilead

import android.util.Log
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class FirebaseBackgroudService: FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d("MyFirebaseMsgService", "broadcast received for message");
        super.onMessageReceived(remoteMessage)
        // We don't handle the message here as we already handle it in the receiver and don't want to duplicate.
    }
}