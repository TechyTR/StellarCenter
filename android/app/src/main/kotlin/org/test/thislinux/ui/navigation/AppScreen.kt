package org.test.thislinux.ui.navigation

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BatteryChargingFull
import androidx.compose.material.icons.filled.NetworkCheck
import androidx.compose.material.icons.filled.Sensors
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

private data class AppTool(
    val title: String,
    val description: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector
)

private val tools = listOf(
    AppTool(
        "Benchmark",
        "Test CPU, memory and storage performance.",
        Icons.Default.Speed
    ),
    AppTool(
        "Storage Manager",
        "View storage usage and available space.",
        Icons.Default.Storage
    ),
    AppTool(
        "Battery Lab",
        "Monitor battery information and charging state.",
        Icons.Default.BatteryChargingFull
    ),
    AppTool(
        "Network Lab",
        "Inspect network information and connectivity.",
        Icons.Default.NetworkCheck
    ),
    AppTool(
        "SensorLab",
        "View available device sensors.",
        Icons.Default.Sensors
    ),
    AppTool(
        "Settings",
        "Configure Stellar Center.",
        Icons.Default.Settings
    )
)

@Composable
fun AppScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 20.dp)
    ) {
        Text(
            text = "App",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(
                top = 20.dp,
                bottom = 16.dp
            )
        )

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(tools) { tool ->
                AppToolCard(tool)
            }
        }
    }
}

@Composable
private fun AppToolCard(
    tool: AppTool
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        onClick = {
            // Araçların gerçek ekranları bir sonraki aşamada bağlanacak.
        }
    ) {
        androidx.compose.foundation.layout.Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp)
        ) {
            Icon(
                imageVector = tool.icon,
                contentDescription = tool.title
            )

            androidx.compose.foundation.layout.Column(
                modifier = Modifier.padding(start = 16.dp)
            ) {
                Text(
                    text = tool.title,
                    style = MaterialTheme.typography.titleMedium
                )

                Text(
                    text = tool.description,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 4.dp)
                )
            }
        }
    }
}
