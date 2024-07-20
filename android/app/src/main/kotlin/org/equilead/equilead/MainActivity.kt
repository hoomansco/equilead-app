package org.equilead.equilead
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.net.Uri
import android.app.ActivityManager
import io.flutter.embedding.android.FlutterActivity
import androidx.core.content.ContextCompat
import android.content.Context   
import android.util.Log

import android.Manifest

import android.content.ComponentName

import android.content.pm.PackageManager
import android.database.Cursor
import android.os.Bundle
import android.provider.ContactsContract
import androidx.core.app.ActivityCompat
import io.flutter.view.FlutterMain

class MainActivity: FlutterActivity() {
   private val CHANNEL = "app.hub.dev/openSettings"
    private val REQUEST_READ_CONTACTS = 1
    private var locationHandler: LocationHandler? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ContactHandler())
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
          call, result ->
          if (call.method == "openSettingsApp") {
            openAppSettings()
          } else if (call.method == "changeIcon") {
            val iconName = call.argument<String>("iconName")
            // changeIcon(iconName)
            result.success(null)
          } else if(call.method == "getLocation") {
              val targetLat = call.argument<Double>("lat")
              val targetLon = call.argument<Double>("lon")
              if (targetLat != null && targetLon != null) {
                  locationHandler = LocationHandler(this, result,targetLat,targetLon)
              } else {
                  result.error("INVALID_ARGUMENTS", "Invalid target location", null)
              }     
          } 
           else {
            result.notImplemented()
           }
         }
    }
    
    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", getPackageName(), null)
        }
        startActivity(intent)
    }
    private fun getAvailableMemory(): ActivityManager.MemoryInfo {
      val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
      return ActivityManager.MemoryInfo().also { memoryInfo ->
          activityManager.getMemoryInfo(memoryInfo)
      }
  }

private fun changeIcon(iconName: String?) {
      val pm = packageManager

      when (iconName) {
          "aron" -> pm.setComponentEnabledSetting(
              ComponentName(applicationContext, "org.equilead.equilead.MainActivityAron"),
              PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
              PackageManager.DONT_KILL_APP
          )
          else -> pm.setComponentEnabledSetting(
              ComponentName(applicationContext, "org.equilead.equilead.MainActivity"),
              PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
              PackageManager.DONT_KILL_APP
          )
      }
      if (iconName == "aron"){
        pm.setComponentEnabledSetting(
          ComponentName(applicationContext, "org.equilead.equilead.MainActivity"),
          PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
          PackageManager.DONT_KILL_APP
       )
      } else {
        pm.setComponentEnabledSetting(
          ComponentName(applicationContext, "org.equilead.equilead.MainActivityAron"),
          PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
          PackageManager.DONT_KILL_APP
      )
      }
}
override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
  super.onRequestPermissionsResult(requestCode, permissions, grantResults)
  locationHandler?.handlePermissionResult(requestCode, grantResults)
}

}
