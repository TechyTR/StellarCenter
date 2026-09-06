package org.test.thislinux.system

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
import java.io.File
import kotlin.math.max

class SystemMonitorViewModel(
    context: Context
) {

    private val appContext = context.applicationContext

    private val scope = CoroutineScope(
        SupervisorJob() + Dispatchers.Default
    )

    private val _state = MutableStateFlow(
        SystemMonitorState()
    )

    val state: StateFlow<SystemMonitorState> = _state

    private var running = false
    private var monitorJob: Job? = null

    private var previousCpuTotal = 0L
    private var previousCpuIdle = 0L

    fun start() {
        if (running) return

        running = true

        monitorJob = scope.launch {
            while (isActive && running) {

                val cpuUsage = readCpuUsage()
                val memory = readMemory()
                val battery = readBatteryInfo()

                _state.value = SystemMonitorState(
                    cpuUsage = cpuUsage,
                    ramUsage = memory.usagePercent,
                    battery = battery.level,
                    temperature = battery.temperature,

                    model = Build.MODEL,
                    manufacturer = Build.MANUFACTURER,

                    androidVersion = Build.VERSION.RELEASE ?: "Bilinmiyor",
                    sdk = Build.VERSION.SDK_INT,
                    securityPatch =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            Build.VERSION.SECURITY_PATCH ?: "Bilinmiyor"
                        } else {
                            "Bilinmiyor"
                        },

                    kernel = readKernelVersion(),

                    board = Build.BOARD,
                    device = Build.DEVICE,
                    product = Build.PRODUCT,
                    hardware = Build.HARDWARE,
                    bootloader = Build.BOOTLOADER,

                    cpuCount = Runtime.getRuntime().availableProcessors(),
                    supportedAbis = readSupportedAbis(),

                    totalRamBytes = memory.totalBytes,
                    availableRamBytes = memory.availableBytes,

                    totalStorageBytes = readTotalStorage(),
                    availableStorageBytes = readAvailableStorage(),

                    screenWidth = readScreenWidth(),
                    screenHeight = readScreenHeight(),
                    density = readDensity(),
                    refreshRate = readRefreshRate()
                )

                delay(1000)
            }
        }
    }

    fun stop() {
        running = false
        monitorJob?.cancel()
        monitorJob = null
    }

    private data class MemoryInfo(
        val totalBytes: Long,
        val availableBytes: Long,
        val usagePercent: Int
    )

    private data class BatteryInfo(
        val level: Int,
        val temperature: Double
    )

    private fun readMemory(): MemoryInfo {
        return try {
            val activityManager =
                appContext.getSystemService(
                    Context.ACTIVITY_SERVICE
                ) as android.app.ActivityManager

            val info = android.app.ActivityManager.MemoryInfo()

            activityManager.getMemoryInfo(info)

            val total = max(info.totalMem, 0L)
            val available = max(info.availMem, 0L)

            val used = max(total - available, 0L)

            val usage = if (total > 0L) {
                ((used.toDouble() / total.toDouble()) * 100.0)
                    .toInt()
                    .coerceIn(0, 100)
            } else {
                0
            }

            MemoryInfo(
                totalBytes = total,
                availableBytes = available,
                usagePercent = usage
            )
        } catch (_: Exception) {
            MemoryInfo(
                totalBytes = 0L,
                availableBytes = 0L,
                usagePercent = 0
            )
        }
    }

    private fun readBatteryInfo(): BatteryInfo {
        return try {
            val intent = appContext.registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            )

            if (intent == null) {
                return BatteryInfo(
                    level = 0,
                    temperature = 0.0
                )
            }

            val level = intent.getIntExtra(
                BatteryManager.EXTRA_LEVEL,
                0
            )

            val scale = intent.getIntExtra(
                BatteryManager.EXTRA_SCALE,
                100
            )

            val rawTemperature = intent.getIntExtra(
                BatteryManager.EXTRA_TEMPERATURE,
                0
            )

            val percentage = if (scale > 0) {
                ((level.toDouble() / scale.toDouble()) * 100.0)
                    .toInt()
                    .coerceIn(0, 100)
            } else {
                0
            }

            BatteryInfo(
                level = percentage,
                temperature = rawTemperature / 10.0
            )
        } catch (_: Exception) {
            BatteryInfo(
                level = 0,
                temperature = 0.0
            )
        }
    }

    private fun readCpuUsage(): Int {
        return try {
            val stat = File("/proc/stat")
                .readLines()
                .firstOrNull {
                    it.startsWith("cpu ")
                }
                ?: return 0

            val values = stat
                .trim()
                .split(Regex("\\s+"))
                .drop(1)
                .mapNotNull { it.toLongOrNull() }

            if (values.size < 4) {
                return 0
            }

            val user = values.getOrElse(0) { 0L }
            val nice = values.getOrElse(1) { 0L }
            val system = values.getOrElse(2) { 0L }
            val idle = values.getOrElse(3) { 0L }
            val iowait = values.getOrElse(4) { 0L }
            val irq = values.getOrElse(5) { 0L }
            val softIrq = values.getOrElse(6) { 0L }
            val steal = values.getOrElse(7) { 0L }

            val idleTime = idle + iowait

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
                previousCpuTotal = totalTime
                previousCpuIdle = idleTime
                return 0
            }

            val totalDelta =
                totalTime - previousCpuTotal

            val idleDelta =
                idleTime - previousCpuIdle

            previousCpuTotal = totalTime
            previousCpuIdle = idleTime

            if (totalDelta <= 0L) {
                return 0
            }

            (((totalDelta - idleDelta).toDouble() /
                    totalDelta.toDouble()) * 100.0)
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
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                Build.SUPPORTED_ABIS.joinToString(", ")
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
            val statFs = android.os.StatFs(
                appContext.filesDir.absolutePath
            )

            statFs.totalBytes
        } catch (_: Exception) {
            0L
        }
    }

    private fun readAvailableStorage(): Long {
        return try {
            val statFs = android.os.StatFs(
                appContext.filesDir.absolutePath
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

            val metrics = android.util.DisplayMetrics()

            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getRealMetrics(metrics)

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

            val metrics = android.util.DisplayMetrics()

            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getRealMetrics(metrics)

            metrics.heightPixels
        } catch (_: Exception) {
            0
        }
    }

    private fun readDensity(): Float {
        return try {
            appContext.resources.displayMetrics.density
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
            windowManager.defaultDisplay.refreshRate
        } catch (_: Exception) {
            0f
        }
    }
}
