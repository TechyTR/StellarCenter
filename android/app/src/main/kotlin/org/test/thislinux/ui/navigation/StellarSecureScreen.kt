package org.test.thislinux.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.SystemSecurityUpdateGood
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

private val GlassShape = RoundedCornerShape(26.dp)

@Composable
fun StellarSecureScreen(
    onBack: () -> Unit
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 20.dp,
            end = 20.dp,
            top = 24.dp,
            bottom = 24.dp
        ),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                TextButton(
                    onClick = onBack
                ) {
                    Text(
                        text = "Geri"
                    )
                }

                Spacer(
                    modifier = Modifier.size(4.dp)
                )

                Text(
                    text = "Stellar Secure",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        item {
            SecurityStatusCard()
        }

        item {
            SecurityCheckCard(
                title = "Android güvenliği",
                description = "Android güvenlik bileşenleri kontrol edildi.",
                status = "Kontrol hazır"
            )
        }

        item {
            SecurityCheckCard(
                title = "Sistem bütünlüğü",
                description = "Sistem yapılandırması ve temel cihaz bilgileri incelenebilir.",
                status = "Kontrol hazır"
            )
        }

        item {
            SecurityCheckCard(
                title = "Güvenlik güncellemesi",
                description =
                    "Cihazın güvenlik yaması bilgisi Monitor bölümündeki " +
                            "sistem verileriyle birlikte takip edilebilir.",
                status = "Kontrol hazır"
            )
        }

        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(
                        start = 4.dp,
                        end = 4.dp,
                        top = 4.dp
                    )
            ) {
                Text(
                    text = "Stellar Secure",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )

                Spacer(
                    modifier = Modifier.height(4.dp)
                )

                Text(
                    text =
                        "Bu bölüm Stellar Center'ın cihaz güvenliği " +
                                "teknolojisinin merkezi olacak. Gerçek zamanlı " +
                                "güvenlik taraması ve daha gelişmiş kontroller " +
                                "sonraki aşamalarda eklenecek.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun GlassCard(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    val accent = MaterialTheme.colorScheme.primary

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(GlassShape)
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color.White.copy(alpha = 0.18f),
                        Color.White.copy(alpha = 0.08f),
                        Color.Transparent,
                        accent.copy(alpha = 0.025f)
                    )
                )
            )
            .border(
                width = 1.dp,
                color = Color.White.copy(alpha = 0.48f),
                shape = GlassShape
            )
            .padding(20.dp)
    ) {
        content()
    }
}

@Composable
private fun SecurityStatusCard() {
    GlassCard {
        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            GlassIconContainer {
                Icon(
                    imageVector = Icons.Default.Security,
                    contentDescription = null,
                    modifier = Modifier.size(29.dp),
                    tint = MaterialTheme.colorScheme.primary
                )
            }

            Spacer(
                modifier = Modifier.size(14.dp)
            )

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = "Stellar Secure",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )

                Spacer(
                    modifier = Modifier.height(3.dp)
                )

                Text(
                    text = "Güvenlik merkezi",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        Spacer(
            modifier = Modifier.height(18.dp)
        )

        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.CheckCircle,
                contentDescription = null,
                modifier = Modifier.size(24.dp),
                tint = MaterialTheme.colorScheme.primary
            )

            Spacer(
                modifier = Modifier.size(10.dp)
            )

            Text(
                text = "Temel güvenlik kontrolleri hazır",
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Medium
            )
        }

        Spacer(
            modifier = Modifier.height(14.dp)
        )

        LinearProgressIndicator(
            progress = {
                1f
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(7.dp)
                .clip(
                    RoundedCornerShape(20.dp)
                )
        )
    }
}

@Composable
private fun SecurityCheckCard(
    title: String,
    description: String,
    status: String
) {
    GlassCard {
        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            GlassIconContainer {
                Icon(
                    imageVector = Icons.Default.SystemSecurityUpdateGood,
                    contentDescription = null,
                    modifier = Modifier.size(27.dp),
                    tint = MaterialTheme.colorScheme.primary
                )
            }

            Spacer(
                modifier = Modifier.size(12.dp)
            )

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )

                Spacer(
                    modifier = Modifier.height(3.dp)
                )

                Text(
                    text = description,
