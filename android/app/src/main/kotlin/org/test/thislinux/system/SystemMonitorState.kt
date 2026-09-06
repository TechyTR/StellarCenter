package org.test.thislinux.system

data class SystemMonitorState(

    val cpuUsage: Int = 0,

    val ramUsage: Int = 0,

    val battery: Int = 0,

    val temperature: Double = 0.0
)
