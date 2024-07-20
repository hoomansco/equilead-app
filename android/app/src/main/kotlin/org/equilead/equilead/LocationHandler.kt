package org.equilead.equilead

import android.Manifest
import android.app.Activity

import android.util.Log

import android.content.pm.PackageManager
import android.location.Location
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import io.flutter.plugin.common.MethodChannel

class LocationHandler(private val activity: Activity, private val result: MethodChannel.Result,private var targetLat: Double, private var targetLon: Double) {

    private lateinit var fusedLocationClient: FusedLocationProviderClient

    init {
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(activity)
        checkPermissions()
    }

    private fun checkPermissions() {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 1)
        } else {
            checkLocationMatch()
        }
    }

     fun getLastLocation() {
        fusedLocationClient.lastLocation.addOnSuccessListener { location: Location? ->
            if (location != null) {
                val locationString = "Lat: ${location.latitude}, Lon: ${location.longitude}"
                result.success(locationString)
            } else {
                result.error("UNAVAILABLE", "Location not available", null)
            }
        }.addOnFailureListener { e ->
            result.error("ERROR", e.localizedMessage, null)
        }
    }

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray) {
        Log.d("HandlingPermission","Request Permision")
        if (requestCode == 1 && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            checkLocationMatch()
        } else {
            result.error("PERMISSION_DENIED", "Location permission denied", null)
        }
    }

    fun checkLocationMatch() {
        fusedLocationClient.lastLocation.addOnSuccessListener { location: Location? ->
            if (location != null) {
                val distanceInMeters = location.distanceTo(Location("").apply {
                    latitude = targetLat
                    longitude = targetLon
                })
                val withinRange = distanceInMeters <= 50 // Adjust the range as needed
                result.success(withinRange)
            } else {
                result.error("UNAVAILABLE", "Location not available", null)
            }
        }.addOnFailureListener { e ->
            result.error("ERROR", e.localizedMessage, null)
        }
    }
}
