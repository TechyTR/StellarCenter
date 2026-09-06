package org.test.thislinux.system

data class SystemMonitorState(
    val cpuUsage: Int = 0,
    val ramUsage: Int = 0,
    val battery: Int = 0,
    val temperature: Double = 0.0
)

data class StaticSystemMonitorState(
    val model: String = "Bilinmiyor",
    val manufacturer: String = "Bilinmiyor",

    val androidVersion: String = "Bilinmiyor",
    val sdk: Int = 0,
    val securityPatch: String = "Bilinmiyor",
    val kernel: String = "Bilinmiyor",

    val board: String = "Bilinmiyor",
    val device: String = "Bilinmiyor",
    val product: String = "Bilinmiyor",
    val hardware: String = "Bilinmiyor",
    val bootloader: String = "Bilinmiyor",

    val cpuCount: Int = 0,
    val supportedAbis: String = "Bilinmiyor",

    val totalRamBytes: Long = 0L,
    val availableRamBytes: Long = 0L,

    val totalStorageBytes: Long = 0L,
    val availableStorageBytes: Long = 0L,

    val screenWidth: Int = 0,
    val screenHeight: Int = 0,
    val density: Float = 0f,
    val refreshRate: Float = 0f
)
