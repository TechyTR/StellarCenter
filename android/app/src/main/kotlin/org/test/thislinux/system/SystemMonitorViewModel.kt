package org.test.thislinux.system

import android.app.Application
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import androidx.lifecycle.AndroidViewModel
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import java.io.File

class SystemMonitorViewModel(
    application: Application? = null
) {

    private val scope = CoroutineScope(
        SupervisorJob() +
                Dispatchers.Default
    )

    private val _state =
        MutableStateFlow(SystemMonitorState())

    val state: StateFlow<SystemMonitorState> =
        _state

    private var running = false

    fun start() {

        if (running) return

        running = true

        scope.launch {

            while (isActive && running) {

                val cpu =
                    readCpuUsage()

                val ram =
                    readRamUsage()

                val battery =
                    readBattery()

                val temperature =
                    readBatteryTemperature()

                _state.value =
                    SystemMonitorState(
                        cpuUsage = cpu,
                        ramUsage = ram,
                        battery = battery,
                        temperature = temperature
                    )

                /*
                 * Monitor sadece açıkken çalışıyor.
                 *
                 * 1 saniye yerine gerektiğinde
                 * daha düşük polling frekansına
                 * çekebiliriz.
                 */

                delay(1000)
            }
        }
    }

    fun stop() {

        running = false
    }

    private fun readCpuUsage(): Int {

        return try {

            val stat =
                File("/proc/stat")
                    .readLines()
                    .firstOrNull {
                        it.startsWith("cpu ")
                    }
                    ?: return 0

            val values =
                stat.trim()
                    .split(Regex("\\s+"))
                    .drop(1)
                    .mapNotNull {
                        it.toLongOrNull()
                    }

            if (values.size < 4) {
                return 0
            }

            val idle =
                values[3]

            val total =
                values.sum()

            val usage =
                if (total > 0) {
                    ((total - idle) * 100 / total)
                } else {
                    0
                }

            usage
                .coerceIn(0, 100)
                .toInt()

        } catch (_: Exception) {

            0
        }
    }

    private fun readRamUsage(): Int {

        return 0
    }

    private fun readBattery(): Int {

        return 0
    }

    private fun readBatteryTemperature(): Double {

        return 0.0
    }
}
