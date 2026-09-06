package org.test.thislinux.system

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.view.WindowManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import kotlin.math.max

class SystemMonitorViewModel(
    context: Context
) {

    private val appContext = context.applicationContext

    private val scope = CoroutineScope(
        SupervisorJob() + Dispatchers.Default
    )

    private val _liveState = MutableStateFlow(
        SystemMonitorState()
    )

    val liveState: StateFlow<SystemMonitorState> = _liveState

    private val _staticState = MutableStateFlow(
        StaticSystemMonitorState()
    )

    val staticState: StateFlow<StaticSystemMonitorState> = _staticState

    private val activityManager =
        appContext.getSystemService(
            Context.ACTIVITY_SERVICE
        ) as android.app.ActivityManager

    private val memoryInfo =
        android.app.ActivityManager.MemoryInfo()

    private val batteryReceiver =
        object : BroadcastReceiver() {

            override fun onReceive(
                context: Context?,
                intent: Intent?
            ) {
                if (intent == null) {
                    return
                }

                updateBatteryCache(intent)
            }
        }

    private var batteryReceiverRegistered = false

    @Volatile
    private var batteryLevel = 0

    @Volatile
    private var batteryTemperature = 0.0

    private var running = false
    private var monitorJob: Job? = null

    private var previousCpuTotal = 0L
    private var previousCpuIdle = 0L

    fun start() {
        if (running) {
            return
        }

        running = true

        registerBatteryReceiver()

        monitorJob = scope.launch {

            if (_staticState.value.model == "Bilinmiyor") {
                _staticState.value =
                    readStaticSystemInfo()
            }

            while (isActive && running) {

                val cpuUsage = readCpuUsage()
                val ramUsage = readRamUsage()

                _liveState.value =
                    SystemMonitorState(
                        cpuUsage = cpuUsage,
                        ramUsage = ramUsage,
                        battery = batteryLevel,
                        temperature = batteryTemperature
                    )

                delay(1000L)
            }
        }
    }

    fun stop() {
        running = false

        monitorJob?.cancel()
        monitorJob = null

        unregisterBatteryReceiver()

        previousCpuTotal = 0L
        previousCpuIdle = 0L
    }

    private fun registerBatteryReceiver() {
        if (batteryReceiverRegistered) {
            return
        }

        try {
            val filter =
                IntentFilter(
                    Intent.ACTION_BATTERY_CHANGED
                )

            val initialIntent =
                appContext.registerReceiver(
                    batteryReceiver,
                    filter
                )

            if (initialIntent != null) {
                updateBatteryCache(initialIntent)
            }

            batteryReceiverRegistered = true
        } catch (_: Exception) {
            batteryReceiverRegistered = false
        }
    }

    private fun unregisterBatteryReceiver() {
        if (!batteryReceiverRegistered) {
            return
        }

        try {
            appContext.unregisterReceiver(
                batteryReceiver
            )
        } catch (_: Exception) {
        }

        batteryReceiverRegistered = false
    }

    private fun updateBatteryCache(
        intent: Intent
    ) {
        val level =
            intent.getIntExtra(
                BatteryManager.EXTRA_LEVEL,
                0
            )

        val scale =
            intent.getIntExtra(
                BatteryManager.EXTRA_SCALE,
                100
            )

        val rawTemperature =
            intent.getIntExtra(
                BatteryManager.EXTRA_TEMPERATURE,
                0
            )

        batteryLevel =
            if (scale > 0) {
                (
                    level.toDouble() /
                        scale.toDouble() *
                        100.0
                )
                    .toInt()
                    .coerceIn(0, 100)
            } else {
                0
            }

        batteryTemperature =
            rawTemperature / 10.0
    }

    private fun readStaticSystemInfo():
        StaticSystemMonitorState {

        val totalRam =
            readMemoryInfo()

        return StaticSystemMonitorState(
            model = Build.MODEL,
            manufacturer = Build.MANUFACTURER,

            androidVersion =
                Build.VERSION.RELEASE ?: "Bilinmiyor",

            sdk =
                Build.VERSION.SDK_INT,

            securityPatch =
                if (
                    Build.VERSION.SDK_INT >=
                    Build.VERSION_CODES.M
                ) {
                    Build.VERSION.SECURITY_PATCH
                        ?: "Bilinmiyor"
                } else {
                    "Bilinmiyor"
                },

            kernel =
                readKernelVersion(),

            board =
                Build.BOARD,

            device =
                Build.DEVICE,

            product =
                Build.PRODUCT,

            hardware =
                Build.HARDWARE,

            bootloader =
                Build.BOOTLOADER,

            cpuCount =
                Runtime.getRuntime()
                    .availableProcessors(),

            supportedAbis =
                readSupportedAbis(),

            totalRamBytes =
                totalRam,

            availableRamBytes =
                memoryInfo.availMem
                    .coerceAtLeast(0L),

            totalStorageBytes =
                readTotalStorage(),

            availableStorageBytes =
                readAvailableStorage(),

            screenWidth =
                readScreenWidth(),

            screenHeight =
                readScreenHeight(),

            density =
                readDensity(),

            refreshRate =
                readRefreshRate()
        )
    }

    private fun readRamUsage(): Int {
        return try {
            readMemoryInfo()

            val total =
                memoryInfo.totalMem
                    .coerceAtLeast(0L)

            val available =
                memoryInfo.availMem
                    .coerceAtLeast(0L)

            if (total <= 0L) {
                return 0
            }

            val used =
                (
                    total - available
                ).coerceAtLeast(0L)

            (
                used.toDouble() /
                    total.toDouble() *
                    100.0
            )
                .toInt()
                .coerceIn(0, 100)

        } catch (_: Exception) {
            0
        }
    }

    private fun readMemoryInfo(): Long {
        activityManager.getMemoryInfo(
            memoryInfo
        )

        return max(
            memoryInfo.totalMem,
            0L
        )
    }

    private fun readCpuUsage(): Int {
        return try {
            val reader =
                BufferedReader(
                    FileReader("/proc/stat")
                )

            val line =
                reader.use {
                    var result: String? = null

                    while (true) {
                        val current =
                            it.readLine()
                                ?: break

                        if (
                            current.length >= 5 &&
                            current[0] == 'c' &&
                            current[1] == 'p' &&
                            current[2] == 'u' &&
                            current[3] == ' '
                        ) {
                            result = current
                            break
                        }
                    }

                    result
                }
                ?: return 0

            var index = 0
            var number = 0L
            var readingNumber = false

            var user = 0L
            var nice = 0L
            var system = 0L
            var idle = 0L
            var iowait = 0L
            var irq = 0L
            var softIrq = 0L
            var steal = 0L

            var i = 4

            while (
                i < line.length &&
                index < 8
            ) {
                val char =
                    line[i]

                if (
                    char >= '0' &&
                    char <= '9'
                ) {
                    if (!readingNumber) {
                        number = 0L
                        readingNumber = true
                    }

                    number =
                        number * 10L +
                            (char.code - '0'.code)

                } else if (readingNumber) {

                    when (index) {
                        0 -> user = number
                        1 -> nice = number
                        2 -> system = number
                        3 -> idle = number
                        4 -> iowait = number
                        5 -> irq = number
                        6 -> softIrq = number
                        7 -> steal = number
                    }

                    index++
                    readingNumber = false
                }

                i++
            }

            if (
                readingNumber &&
                index < 8
            ) {
                when (index) {
                    0 -> user = number
                    1 -> nice = number
                    2 -> system = number
                    3 -> idle = number
                    4 -> iowait = number
                    5 -> irq = number
                    6 -> softIrq = number
                    7 -> steal = number
                }

                index++
            }

            if (index < 4) {
                return 0
            }

            val idleTime =
                idle + iowait

            val totalTime =
                user +
                    nice +
                    system +
                    idle +
                    iowait +
                    irq +
                    softIrq +
                    steal

            if (previousCpuTotal == 0L) {
                previousCpuTotal =
                    totalTime

                previousCpuIdle =
                    idleTime

                return 0
            }

            val totalDelta =
                totalTime -
                    previousCpuTotal

            val idleDelta =
                idleTime -
                    previousCpuIdle

            previousCpuTotal =
                totalTime

            previousCpuIdle =
                idleTime

            if (totalDelta <= 0L) {
                return 0
            }

            val activeDelta =
                (
                    totalDelta -
                        idleDelta
                ).coerceAtLeast(0L)

            (
                activeDelta.toDouble() /
                    totalDelta.toDouble() *
                    100.0
            )
                .toInt()
                .coerceIn(0, 100)

        } catch (_: Exception) {
            0
        }
    }

    private fun readKernelVersion(): String {
        return try {
            File("/proc/version")
                .readText()
                .trim()
                .ifEmpty {
                    "Bilinmiyor"
                }
        } catch (_: Exception) {
            "Bilinmiyor"
        }
    }

    private fun readSupportedAbis(): String {
        return try {
            if (
                Build.VERSION.SDK_INT >=
                Build.VERSION_CODES.LOLLIPOP
            ) {
                Build.SUPPORTED_ABIS
                    .joinToString(", ")
            } else {
                @Suppress("DEPRECATION")
                Build.CPU_ABI
            }
        } catch (_: Exception) {
            "Bilinmiyor"
        }
    }

    private fun readTotalStorage(): Long {
        return try {
            val statFs =
                android.os.StatFs(
                    appContext.filesDir
                        .absolutePath
                )

            statFs.totalBytes
        } catch (_: Exception) {
            0L
        }
    }

    private fun readAvailableStorage(): Long {
        return try {
            val statFs =
                android.os.StatFs(
                    appContext.filesDir
                        .absolutePath
                )

            statFs.availableBytes
        } catch (_: Exception) {
            0L
        }
    }

    private fun readScreenWidth(): Int {
        return try {
            val windowManager =
                appContext.getSystemService(
                    Context.WINDOW_SERVICE
                ) as WindowManager

            val metrics =
                android.util.DisplayMetrics()

            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
                .getRealMetrics(metrics)

            metrics.widthPixels
        } catch (_: Exception) {
            0
        }
    }

    private fun readScreenHeight(): Int {
        return try {
            val windowManager =
                appContext.getSystemService(
                    Context.WINDOW_SERVICE
                ) as WindowManager

            val metrics =
                android.util.DisplayMetrics()

            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
                .getRealMetrics(metrics)

            metrics.heightPixels
        } catch (_: Exception) {
            0
        }
    }

    private fun readDensity(): Float {
        return try {
            appContext.resources
                .displayMetrics
                .density
        } catch (_: Exception) {
            0f
        }
    }

    private fun readRefreshRate(): Float {
        return try {
            val windowManager =
                appContext.getSystemService(
                    Context.WINDOW_SERVICE
                ) as WindowManager

            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
                .refreshRate
        } catch (_: Exception) {
            0f
        }
    }
}

