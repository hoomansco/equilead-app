package org.equilead.equilead


import android.Manifest
import android.app.Activity

import android.content.pm.PackageManager
import android.database.Cursor
import android.content.ComponentName
import android.provider.ContactsContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class ContactHandler : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private val CONTACTS_PERMISSION_REQUEST_CODE = 1
    private var pendingResult: MethodChannel.Result? = null
    private val REQUEST_READ_CONTACTS = 1

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "contact_handler")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestContactsPermission" -> {
                pendingResult = result
                requestContactsPermission()
            }
            "getContacts" -> {
                getContacts(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener { requestCode, permissions, grantResults ->
            if (requestCode == CONTACTS_PERMISSION_REQUEST_CODE) {
                val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
                pendingResult?.success(granted)
                pendingResult = null
                true
            } else {
                false
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private fun requestContactsPermission() {
        activity?.let {
            if (ContextCompat.checkSelfPermission(it, Manifest.permission.READ_CONTACTS)
                != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                    it,
                    arrayOf(Manifest.permission.READ_CONTACTS),
                    CONTACTS_PERMISSION_REQUEST_CODE
                )
            } else {
                pendingResult?.success(true)
                pendingResult = null
            }
        }
    }

    private fun getContacts(result: MethodChannel.Result){
        activity?.let {
            if (ContextCompat.checkSelfPermission(it, Manifest.permission.READ_CONTACTS)
                == PackageManager.PERMISSION_GRANTED) {
                val contacts = mutableListOf<Map<String, String>>()
                val seenPhoneNumbers = HashSet<String>()

                val cursor: Cursor? = it.contentResolver.query(
                    ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                    null, null, null,  "${ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME} ASC"
                )
                cursor?.use { cur ->
                    while (cur.moveToNext()) {
                        val name = cur.getString(cur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)) ?: ""
                        val phoneNumber = cur.getString(cur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)) ?: ""
                        // var photoUri = cur.getString(cur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.PHOTO_URI))
                        if (phoneNumber !in seenPhoneNumbers){
                            seenPhoneNumbers.add(phoneNumber)
                            val number = formatPhoneNumber(phoneNumber)
                            val contact = mapOf("name" to name, "phoneNumber" to number)
                            contacts.add(contact)
                        }
                    }
                }
                result.success(contacts.toList())
            } else {
                result.error("PERMISSION_DENIED", "Contacts permission denied", null)
            }
        }
    }
    private fun formatPhoneNumber(phoneNumber: String): String {
        val cleanedPhoneNumber = phoneNumber.replace("\\s".toRegex(), "")

        return if (cleanedPhoneNumber.length == 10) {
            "+91$cleanedPhoneNumber"
        } else {
            cleanedPhoneNumber
        }
    }

}