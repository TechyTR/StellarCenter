package org.test.thislinux.ui.navigation

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BatteryChargingFull
import androidx.compose.material.icons.filled.Construction
import androidx.compose.material.icons.filled.NetworkCheck
import androidx.compose.material.icons.filled.Sensors
import androidx.compose.material.icons.filled.Settings
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
    val icon: androidx.compose.ui.graphics.vector.ImageVector,
    val inDevelopment: Boolean = false
)

private val tools = listOf(
    AppTool(
        title = "Benchmark",
        description = "A separate Stellar Benchmark application is being developed.",
        icon = Icons.Default.Construction,
        inDevelopment = true
    ),
    AppTool(
        title = "Storage Manager",
        description = "View storage usage and available space.",
        icon = Icons.Default.Storage
    ),
    AppTool(
        title = "Battery Lab",
        description = "Monitor battery information and charging state.",
        icon = Icons.Default.BatteryChargingFull
    ),
    AppTool(
        title = "Network Lab",
        description = "Inspect network information and connectivity.",
        icon = Icons.Default.NetworkCheck
    ),
    AppTool(
        title = "SensorLab",
        description = "View available device sensors.",
        icon = Icons.Default.Sensors
    ),
    AppTool(
        title = "Settings",
        description = "Configure Stellar Center.",
        icon = Icons.Default.Settings
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
        onClick = {}
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp)
        ) {
            Icon(
                imageVector = tool.icon,
                contentDescription = tool.title
            )

            Column(
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

                if (tool.inDevelopment) {
                    Text(
                        text = "Yapım aşamasında",
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.padding(top = 8.dp)
                    )
                }
            }
        }
    }
}
