package com.example.drive_map

import android.Manifest
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.Executors

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val main = Handler(Looper.getMainLooper())
    private val io = Executors.newCachedThreadPool()
    private val lock = Any()
    private var socket: BluetoothSocket? = null
    private var generation = 0
    private var sink: EventChannel.EventSink? = null
    private var permissionResult: MethodChannel.Result? = null
    private val adapter get() = (getSystemService(BLUETOOTH_SERVICE) as BluetoothManager).adapter
    private val spp = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "drivemap/obd").setMethodCallHandler(this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "drivemap/obd_bytes").setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "devices" -> {
                if (Build.VERSION.SDK_INT >= 31 &&
                    (checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED ||
                     checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED)) {
                    if (permissionResult != null) { result.error("busy", "Richiesta permessi già in corso.", null); return }
                    permissionResult = result
                    requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_SCAN), 410)
                } else listDevices(result)
            }
            "pairing" -> {
                try { startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS)); result.success(null) }
                catch (e: Exception) { result.error("settings", e.message, null) }
            }
            "connect" -> {
                val id = call.argument<String>("id")
                if (id == null) result.error("device", "Dispositivo mancante.", null)
                else connect(id, result)
            }
            "write" -> {
                val bytes = call.arguments as? ByteArray
                val current = synchronized(lock) { socket }
                if (bytes == null || current == null) { result.error("disconnected", "Bluetooth disconnesso.", null); return }
                io.execute {
                    try {
                        current.outputStream.write(bytes)
                        current.outputStream.flush()
                        main.post { result.success(null) }
                    } catch (e: Exception) { main.post { result.error("write", e.message, null) } }
                }
            }
            "disconnect" -> { close(); result.success(null) }
            else -> result.notImplemented()
        }
    }

    @Suppress("MissingPermission")
    private fun listDevices(result: MethodChannel.Result) {
        try {
            val bt = adapter
            if (bt == null) { result.error("unavailable", "Bluetooth non disponibile.", null); return }
            if (!bt.isEnabled) { result.error("disabled", "Attiva il Bluetooth nelle impostazioni.", null); return }
            result.success(bt.bondedDevices.map {
                mapOf("id" to it.address, "name" to (it.name ?: "Dispositivo Bluetooth"), "paired" to true)
            }.sortedByDescending { (it["name"] as String).contains("OBD", ignoreCase = true) })
        } catch (e: SecurityException) { result.error("permission", "Consenti l’accesso ai dispositivi nelle vicinanze nelle impostazioni dell’app.", null) }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != 410) return
        val result = permissionResult ?: return
        permissionResult = null
        if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) listDevices(result)
        else result.error("permission", "Permesso Bluetooth negato. Consenti Dispositivi nelle vicinanze nelle impostazioni dell’app e riprova.", null)
    }

    @Suppress("MissingPermission")
    private fun connect(id: String, result: MethodChannel.Result) {
        close()
        val token = synchronized(lock) { generation }
        io.execute {
            var candidate: BluetoothSocket? = null
            var connectionReported = false
            try {
                val bt = adapter ?: throw IllegalStateException("Bluetooth non disponibile.")
                if (!bt.isEnabled) throw IllegalStateException("Attiva il Bluetooth.")
                bt.cancelDiscovery()
                val connection = bt.getRemoteDevice(id).createRfcommSocketToServiceRecord(spp)
                candidate = connection
                synchronized(lock) {
                    if (generation != token) throw IllegalStateException("Connessione annullata.")
                    socket = connection // Allows disconnect to cancel a blocking connect.
                }
                connection.connect()
                synchronized(lock) { if (generation != token) throw IllegalStateException("Connessione annullata.") }
                connectionReported = true
                main.post {
                    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    result.success(null)
                }
                val buffer = ByteArray(4096)
                while (synchronized(lock) { generation == token }) {
                    val count = connection.inputStream.read(buffer)
                    if (count < 0) break
                    val packet = buffer.copyOf(count)
                    main.post { if (synchronized(lock) { generation == token }) sink?.success(packet) }
                }
                main.post { if (synchronized(lock) { generation == token }) sink?.error("disconnected", "Connessione OBD interrotta.", null) }
            } catch (e: Exception) {
                main.post {
                    if (!connectionReported) result.error("connect", "Collegamento non riuscito: ${e.message}", null)
                    else if (synchronized(lock) { generation == token }) sink?.error("disconnected", e.message, null)
                }
            } finally {
                try { candidate?.close() } catch (_: Exception) { }
                synchronized(lock) { if (socket === candidate) socket = null }
            }
        }
    }

    private fun close() {
        val old = synchronized(lock) { generation++; val old = socket; socket = null; old }
        try { old?.close() } catch (_: Exception) { }
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onDestroy() {
        close()
        permissionResult?.error("closed", "Attività chiusa.", null)
        permissionResult = null
        io.shutdownNow()
        super.onDestroy()
    }
}
