package org.test.thislinux.ui.navigation

import android.content.Context
import android.os.BatteryManager
import android.os.Build
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BatteryFull
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Smartphone
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import kotlin.math.max

private data class DeviceInfo(
    val model: String,
    val manufacturer: String,
    val androidVersion: String,
    val totalRamGb: Double
)

@Composable
fun HomeScreen(
    onOpenSecurity: () -> Unit = {}
) {
    val context = LocalContext.current

    var batteryLevel by remember {
        mutableIntStateOf(
            readBatteryLevel(context)
        )
    }

    var totalRam by remember {
        mutableLongStateOf(
            readTotalRam(context)
        )
    }

    LaunchedEffect(Unit) {
        while (true) {
            batteryLevel = readBatteryLevel(context)
            totalRam = readTotalRam(context)
            delay(10_000)
        }
    }

    val deviceInfo = remember(totalRam) {
        DeviceInfo(
            model = Build.MODEL,
            manufacturer = Build.MANUFACTURER,
            androidVersion =
                Build.VERSION.RELEASE ?: "Bilinmiyor",
            totalRamGb =
                totalRam /
                        1024.0 /
                        1024.0 /
                        1024.0
        )
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 20.dp,
            end = 20.dp,
            top = 24.dp,
            bottom = 20.dp
        ),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {

        item {
            Text(
                text = getGreeting(),
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
        }

        item {
            Text(
                text = "Stellar Center",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        item {
            DeviceCard(
                deviceInfo = deviceInfo
            )
        }

        item {
            BatteryCard(
                batteryLevel = batteryLevel
            )
        }

        item {
            SecurityTechnologyCard(
                onClick = onOpenSecurity
            )
        }
    }
}

@Composable
private fun DeviceCard(
    deviceInfo: DeviceInfo
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor =
                MaterialTheme.colorScheme.surfaceContainer
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Smartphone,
                contentDescription = null,
                modifier = Modifier.size(42.dp),
                tint = MaterialTheme.colorScheme.primary
            )

            Spacer(
                modifier = Modifier.size(16.dp)
            )

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = deviceInfo.model,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )

                Spacer(
                    modifier = Modifier.height(3.dp)
                )

                Text(
                    text = deviceInfo.manufacturer,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(
                    modifier = Modifier.height(5.dp)
                )

                Text(
                    text =
                        "Android ${deviceInfo.androidVersion} • " +
                                "${"%.1f".format(
                                    deviceInfo.totalRamGb
                                )} GB RAM",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun BatteryCard(
    batteryLevel: Int
) {
    val progress =
        batteryLevel
            .coerceIn(0, 100) / 100f

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor =
                MaterialTheme.colorScheme.surfaceContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.BatteryFull,
                    contentDescription = null,
                    modifier = Modifier.size(30.dp),
                    tint = MaterialTheme.colorScheme.primary
                )

                Spacer(
                    modifier = Modifier.size(12.dp)
                )

                Column(
                    modifier = Modifier.weight(1f)
                ) {
                    Text(
                        text = "Pil durumu",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )

                    Text(
                        text = "%$batteryLevel",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Spacer(
                modifier = Modifier.height(14.dp)
            )

            LinearProgressIndicator(
                progress = {
                    progress
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(9.dp)
            )
        }
    }
}

@Composable
private fun SecurityTechnologyCard(
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor =
                MaterialTheme.colorScheme.surfaceContainer
        ),
        onClick = onClick
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Security,
                    contentDescription = null,
                    modifier = Modifier.size(34.dp),
                    tint = MaterialTheme.colorScheme.primary
                )

                Spacer(
                    modifier = Modifier.size(14.dp)
                )

                Column(
                    modifier = Modifier.weight(1f)
                ) {
                    Text(
                        text = "Güvenlik Teknolojisi",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold
                    )

                    Spacer(
                        modifier = Modifier.height(3.dp)
                    )

                    Text(
                        text = "Stellar Secure",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
            }

            Spacer(
                modifier = Modifier.height(12.dp)
            )

            Text(
                text =
                    "Cihazınızın güvenlik durumunu " +
                            "Stellar Secure teknolojisiyle kontrol edin.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

private fun readBatteryLevel(
    context: Context
): Int {
    val batteryManager =
        context.getSystemService(
            Context.BATTERY_SERVICE
        ) as BatteryManager

    return batteryManager
        .getIntProperty(
            BatteryManager.BATTERY_PROPERTY_CAPACITY
        )
        .coerceIn(0, 100)
}

private fun readTotalRam(
    context: Context
): Long {
    val activityManager =
        context.getSystemService(
            Context.ACTIVITY_SERVICE
        ) as android.app.ActivityManager

    val memoryInfo =
        android.app.ActivityManager.MemoryInfo()

    activityManager.getMemoryInfo(memoryInfo)

    return max(
        memoryInfo.totalMem,
        0L
    )
}

private fun getGreeting(): String {
    val hour =
        java.util.Calendar
            .getInstance()
            .get(
                java.util.Calendar.HOUR_OF_DAY
            )

    return when {
        hour < 6 -> "İyi geceler"
        hour < 12 -> "Günaydın"
        hour < 18 -> "İyi günler"
        else -> "İyi akşamlar"
    }
}
