package org.test.thislinux.ui.navigation

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
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.MonitorHeart
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material.icons.filled.Thermostat
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import org.test.thislinux.system.StaticSystemMonitorState
import org.test.thislinux.system.SystemMonitorState
import org.test.thislinux.system.SystemMonitorViewModel

@Composable
fun SystemMonitorScreen() {

    val context = LocalContext.current

    val viewModel = remember(context) {
        SystemMonitorViewModel(context)
    }

    DisposableEffect(viewModel) {
        viewModel.start()

        onDispose {
            viewModel.stop()
        }
    }

    val liveState by viewModel.liveState.collectAsState()
    val staticState by viewModel.staticState.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 16.dp,
            end = 16.dp,
            top = 20.dp,
            bottom = 28.dp
        ),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {

        item {
            MonitorHeader()
        }

        item {
            LiveMonitorSection(
                state = liveState
            )
        }

        item {
            StaticSystemSection(
                state = staticState
            )
        }
    }
}

@Composable
private fun MonitorHeader() {
    Column {
        Text(
            text = "Monitor",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )

        Spacer(
            modifier = Modifier.height(2.dp)
        )

        Text(
            text = "Canlı sistem durumu",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun LiveMonitorSection(
    state: SystemMonitorState
) {
    Column(
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {

        LiveMetricCard(
            icon = {
                Icon(
                    imageVector = Icons.Default.MonitorHeart,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            },
            title = "CPU kullanımı",
            value = "%${state.cpuUsage}",
            progress = state.cpuUsage / 100f
        )

        LiveMetricCard(
            icon = {
                Icon(
                    imageVector = Icons.Default.Memory,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            },
            title = "RAM kullanımı",
            value = "%${state.ramUsage}",
            progress = state.ramUsage / 100f
        )

        LiveMetricCard(
            icon = {
                Icon(
                    imageVector = Icons.Default.BatteryFull,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            },
            title = "Pil",
            value = "%${state.battery}",
            progress = state.battery / 100f
        )

        InfoCard(
            icon = {
                Icon(
                    imageVector = Icons.Default.Thermostat,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            },
            title = "Pil sıcaklığı",
            value = "${state.temperature} °C"
        )
    }
}

@Composable
private fun StaticSystemSection(
    state: StaticSystemMonitorState
) {
    Column(
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {

        SectionTitle("Cihaz")

        InfoCard(
            icon = {
                Icon(
                    imageVector = Icons.Default.PhoneAndroid,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            },
            title = "Model",
            value = state.model
        )

        InfoCard(
            title = "Üretici",
            value = state.manufacturer
        )

        InfoCard(
            title = "Android",
            value = "${state.androidVersion} • SDK ${state.sdk}"
        )

        InfoCard(
            title = "Güvenlik yaması",
            value = state.securityPatch
        )

        InfoCard(
            title = "Kernel",
            value = state.kernel
        )

        SectionTitle("İşlemci")

        InfoCard(
            icon = {
                Icon(
                    imageVector = Icons.Default.Memory,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            },
            title = "Çekirdek sayısı",
            value = "${state.cpuCount}"
        )

        InfoCard(
            title = "Desteklenen ABI",
            value = state.supportedAbis
        )

        SectionTitle("Bellek ve depolama")

        InfoCard(
            icon = {
                Icon(
                    imageVector = Icons.Default.Memory,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            },
            title = "RAM",
            value =
                "${formatBytes(state.availableRamBytes)} boş / " +
                    "${formatBytes(state.totalRamBytes)} toplam"
        )

        InfoCard(
            icon = {
                Icon(
                    imageVector = Icons.Default.Storage,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            },
            title = "Depolama",
            value =
                "${formatBytes(state.availableStorageBytes)} boş / " +
                    "${formatBytes(state.totalStorageBytes)} toplam"
        )

        InfoCard(
            title = "Depolama kullanımı",
            value = calculateStorageUsage(state)
        )

        SectionTitle("Ekran")

        InfoCard(
            title = "Çözünürlük",
            value =
                if (
                    state.screenWidth > 0 &&
                    state.screenHeight > 0
                ) {
                    "${state.screenWidth} × ${state.screenHeight}"
                } else {
                    "Bilinmiyor"
                }
        )

        InfoCard(
            title = "Ekran yoğunluğu",
            value =
                if (state.density > 0f) {
                    "${"%.2f".format(state.density)}x"
                } else {
                    "Bilinmiyor"
                }
        )

        InfoCard(
            title = "Yenileme hızı",
            value =
                if (state.refreshRate > 0f) {
                    "${"%.1f".format(state.refreshRate)} Hz"
                } else {
                    "Bilinmiyor"
                }
        )

        SectionTitle("Donanım")

        InfoCard(
            title = "Board",
            value = state.board
        )

        InfoCard(
            title = "Device",
            value = state.device
        )

        InfoCard(
            title = "Product",
            value = state.product
        )

        InfoCard(
            title = "Hardware",
            value = state.hardware
        )

        InfoCard(
            title = "Bootloader",
            value = state.bootloader
        )
    }
}

@Composable
private fun SectionTitle(
    title: String
) {
    Text(
        text = title,
        modifier = Modifier.padding(
            start = 4.dp,
            top = 12.dp,
            bottom = 2.dp
        ),
        style = MaterialTheme.typography.titleMedium,
        fontWeight = FontWeight.Bold,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )
}

@Composable
private fun LiveMetricCard(
    icon: @Composable () -> Unit,
    title: String,
    value: String,
    progress: Float
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor =
                MaterialTheme.colorScheme.surfaceContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(18.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                icon()

                Spacer(
                    modifier = Modifier.size(14.dp)
                )

                Text(
                    text = title,
                    modifier = Modifier.weight(1f),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )

                Text(
                    text = value,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
            }

            Spacer(
                modifier = Modifier.height(12.dp)
            )

            LinearProgressIndicator(
                progress = {
                    progress.coerceIn(0f, 1f)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
            )
        }
    }
}

@Composable
private fun InfoCard(
    icon: (@Composable () -> Unit)? = null,
    title: String,
    value: String
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
                .padding(17.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (icon != null) {
                icon()

                Spacer(
                    modifier = Modifier.size(14.dp)
                )
            }

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold
                )

                Spacer(
                    modifier = Modifier.height(4.dp)
                )

                Text(
                    text = value,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

private fun formatBytes(
    bytes: Long
): String {
    if (bytes <= 0L) {
        return "Bilinmiyor"
    }

    val kb = 1024.0
    val mb = kb * 1024.0
    val gb = mb * 1024.0
    val tb = gb * 1024.0

    return when {
        bytes >= tb ->
            "${"%.2f".format(bytes / tb)} TB"

        bytes >= gb ->
            "${"%.2f".format(bytes / gb)} GB"

        bytes >= mb ->
            "${"%.2f".format(bytes / mb)} MB"

        bytes >= kb ->
            "${"%.2f".format(bytes / kb)} KB"

        else ->
            "$bytes B"
    }
}

private fun calculateStorageUsage(
    state: StaticSystemMonitorState
): String {
    if (state.totalStorageBytes <= 0L) {
        return "Bilinmiyor"
    }

    val used =
        state.totalStorageBytes -
            state.availableStorageBytes

    val percentage =
        (
            used.toDouble() /
                state.totalStorageBytes.toDouble()
        ) * 100.0

    return "${"%.1f".format(
        percentage.coerceIn(0.0, 100.0)
    )}% kullanılıyor"
}
