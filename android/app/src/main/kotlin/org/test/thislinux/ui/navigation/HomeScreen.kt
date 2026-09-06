package org.test.thislinux.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BatteryChargingFull
import androidx.compose.material.icons.filled.BatteryFull
import androidx.compose.material.icons.filled.BatteryStd
import androidx.compose.material.icons.filled.Smartphone
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

data class DeviceInfo(
    val model: String = "Bilinmiyor",
    val manufacturer: String = "Bilinmiyor",
    val androidVersion: String = "Bilinmiyor",
    val ram: String = "--"
)

@Composable
fun HomeScreen() {

    var deviceInfo by remember {
        mutableStateOf(DeviceInfo())
    }

    var batteryLevel by remember {
        mutableIntStateOf(-1)
    }

    var batteryCharging by remember {
        mutableStateOf(false)
    }

    LaunchedEffect(Unit) {

        // Şimdilik native bridge bağlanana kadar
        // güvenli varsayılan değerler kullanıyoruz.

        deviceInfo = DeviceInfo(
            model = android.os.Build.MODEL,
            manufacturer = android.os.Build.MANUFACTURER,
            androidVersion = android.os.Build.VERSION.RELEASE,
            ram = "--"
        )

        while (true) {

            val manager =
                androidx.compose.ui.platform.LocalContext.current
                    .getSystemService(android.content.Context.BATTERY_SERVICE)
                    as android.os.BatteryManager

            batteryLevel =
                manager.getIntProperty(
                    android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY
                )

            delay(10_000)
        }
    }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 20.dp),
        contentPadding = PaddingValues(
            top = 20.dp,
            bottom = 24.dp
        ),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {

        item {
            Text(
                text = "Stellar Center",
                style = MaterialTheme.typography.headlineLarge,
                fontWeight = FontWeight.Bold
            )

            Spacer(
                modifier = Modifier.height(4.dp)
            )

            Text(
                text = "Android Native",
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
                level = batteryLevel,
                charging = batteryCharging
            )
        }

        item {
            SecurityCard()
        }

        item {
            ShizukuCard()
        }
    }
}


@Composable
private fun DeviceCard(
    deviceInfo: DeviceInfo
) {

    val scheme = MaterialTheme.colorScheme

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp)
    ) {

        Row(
            modifier = Modifier.padding(18.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {

            Box(
                modifier = Modifier
                    .size(64.dp)
                    .clip(RoundedCornerShape(20.dp))
                    .background(
                        scheme.primary.copy(alpha = 0.12f)
                    ),
                contentAlignment = Alignment.Center
            ) {

                Icon(
                    imageVector = Icons.Default.Smartphone,
                    contentDescription = null,
                    tint = scheme.primary,
                    modifier = Modifier.size(33.dp)
                )
            }

            Spacer(
                modifier = Modifier.width(16.dp)
            )

            Column(
                modifier = Modifier.weight(1f)
            ) {

                Text(
                    text = deviceInfo.model,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.ExtraBold,
                    maxLines = 1
                )

                Spacer(
                    modifier = Modifier.height(4.dp)
                )

                Text(
                    text = deviceInfo.manufacturer,
                    color = scheme.onSurfaceVariant
                )

                Spacer(
                    modifier = Modifier.height(7.dp)
                )

                Text(
                    text =
                        "Android ${deviceInfo.androidVersion} • ${deviceInfo.ram} RAM",
                    fontSize = 12.sp,
                    color = scheme.onSurfaceVariant
                )
            }
        }
    }
}


@Composable
private fun BatteryCard(
    level: Int,
    charging: Boolean
) {

    val scheme = MaterialTheme.colorScheme

    val icon = when {

        charging ->
            Icons.Default.BatteryChargingFull

        level >= 75 ->
            Icons.Default.BatteryFull

        else ->
            Icons.Default.BatteryStd
    }

    val status = when {

        charging ->
            "Şarj oluyor"

        level >= 0 ->
            "Pil kullanılıyor"

        else ->
            "Bilinmiyor"
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp)
    ) {

        Column(
            modifier = Modifier.padding(18.dp)
        ) {

            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {

                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = scheme.primary,
                    modifier = Modifier.size(30.dp)
                )

                Spacer(
                    modifier = Modifier.width(13.dp)
                )

                Column(
                    modifier = Modifier.weight(1f)
                ) {

                    Text(
                        text = "Pil durumu",
                        fontWeight = FontWeight.Bold
                    )

                    Spacer(
                        modifier = Modifier.height(3.dp)
                    )

                    Text(
                        text = status,
                        fontSize = 12.sp,
                        color = scheme.onSurfaceVariant
                    )
                }

                Text(
                    text =
                        if (level >= 0) "$level%"
                        else "--",
                    fontSize = 21.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = scheme.primary
                )
            }

            Spacer(
                modifier = Modifier.height(15.dp)
            )

            LinearProgressIndicator(
                progress = {
                    if (level >= 0)
                        level.coerceIn(0, 100) / 100f
                    else
                        0f
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(9.dp)
                    .clip(RoundedCornerShape(10.dp))
            )
        }
    }
}


@Composable
private fun SecurityCard() {

    val scheme = MaterialTheme.colorScheme

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        onClick = {
            // Stellar Secure ekranı sonraki aşamada bağlanacak.
        }
    ) {

        Row(
            modifier = Modifier.padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {

            Box(
                modifier = Modifier
                    .size(58.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(
                        scheme.primary.copy(alpha = 0.11f)
                    ),
                contentAlignment = Alignment.Center
            ) {

                Text(
                    text = "✓",
                    color = scheme.primary,
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(
                modifier = Modifier.width(16.dp)
            )

            Column(
                modifier = Modifier.weight(1f)
            ) {

                Text(
                    text = "Güvenlik denetlemesi",
                    fontSize = 17.sp,
                    fontWeight = FontWeight.ExtraBold
                )

                Spacer(
                    modifier = Modifier.height(5.dp)
                )

                Text(
                    text =
                        "Stellar Secure ile telefonunuzun güvenliğini kontrol edin.",
                    fontSize = 12.sp,
                    color = scheme.onSurfaceVariant
                )
            }

            Text(
                text = "›",
                fontSize = 28.sp,
                color = scheme.onSurfaceVariant
            )
        }
    }
}


@Composable
private fun ShizukuCard() {

    val scheme = MaterialTheme.colorScheme

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        onClick = {
            // Shizuku ekranı sonraki aşamada bağlanacak.
        }
    ) {

        Row(
            modifier = Modifier.padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {

            Box(
                modifier = Modifier
                    .size(58.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(
                        scheme.primary.copy(alpha = 0.11f)
                    ),
                contentAlignment = Alignment.Center
            ) {

                Text(
                    text = "S",
                    color = scheme.primary,
                    fontSize = 25.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(
                modifier = Modifier.width(16.dp)
            )

            Column(
                modifier = Modifier.weight(1f)
            ) {

                Text(
                    text = "Shizuku bağlantısı",
                    fontSize = 17.sp,
                    fontWeight = FontWeight.ExtraBold
                )

                Spacer(
                    modifier = Modifier.height(5.dp)
                )

                Text(
                    text =
                        "Gelişmiş Android yetkilerini ve bağlantı durumunu yönetin.",
                    fontSize = 12.sp,
                    color = scheme.onSurfaceVariant
                )
            }

            Text(
                text = "›",
                fontSize = 28.sp,
                color = scheme.onSurfaceVariant
            )
        }
    }
}

