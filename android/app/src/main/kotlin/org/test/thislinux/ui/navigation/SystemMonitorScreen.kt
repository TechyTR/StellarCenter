package org.test.thislinux.ui.navigation

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import org.test.thislinux.system.SystemMonitorViewModel

@Composable
fun SystemMonitorScreen() {

    val viewModel = remember {
        SystemMonitorViewModel()
    }

    DisposableEffect(Unit) {

        viewModel.start()

        onDispose {
            viewModel.stop()
        }
    }

    val state by viewModel.state.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {

        Text(
            text = "System Monitor",
            style = MaterialTheme.typography.headlineMedium
        )

        Text("CPU: ${state.cpuUsage}%")

        Text("RAM: ${state.ramUsage}%")

        Text("Battery: ${state.battery}%")

        Text("Temperature: ${state.temperature}°C")
    }
}
