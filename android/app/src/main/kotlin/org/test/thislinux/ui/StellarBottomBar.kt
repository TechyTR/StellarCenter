package org.test.thislinux.ui

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.isSystemInDarkTheme

private data class NavItem(
    val label: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector
)

private val navItems = listOf(
    NavItem("Home", Icons.Default.Home),
    NavItem("Monitor", Icons.Default.Speed),
    NavItem("Storage", Icons.Default.Storage),
    NavItem("Settings", Icons.Default.Settings)
)

@Composable
fun StellarBottomBar(
    selectedIndex: Int,
    onSelected: (Int) -> Unit
) {
    val isDark = isSystemInDarkTheme()
    val accent = MaterialTheme.colorScheme.primary
    val muted = MaterialTheme.colorScheme.onSurfaceVariant

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                start = 28.dp,
                end = 28.dp,
                top = 4.dp,
                bottom = 8.dp
            )
    ) {
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .height(66.dp)
                .clip(RoundedCornerShape(24.dp))
                .background(
                    if (isDark) {
                        Color.Black.copy(alpha = 0.18f)
                    } else {
                        Color.White.copy(alpha = 0.82f)
                    }
                )
                .border(
                    width = 1.dp,
                    color = if (isDark) {
                        Color.White.copy(alpha = 0.10f)
                    } else {
                        Color.Black.copy(alpha = 0.06f)
                    },
                    shape = RoundedCornerShape(24.dp)
                )
                .padding(5.dp)
        ) {
            val itemWidth = maxWidth / navItems.size

            val selectedLeftTarget =
                itemWidth * selectedIndex + 3.dp

            val selectedWidthTarget =
                itemWidth - 6.dp

            val selectedLeft by animateDpAsState(
                targetValue = selectedLeftTarget,
                animationSpec = tween(
                    durationMillis = 360,
                    easing = FastOutSlowInEasing
                ),
                label = "navigation-pill-position"
            )

            val selectedWidth by animateDpAsState(
                targetValue = selectedWidthTarget,
                animationSpec = tween(
                    durationMillis = 360,
                    easing = FastOutSlowInEasing
                ),
                label = "navigation-pill-width"
            )

            Box(
                modifier = Modifier.fillMaxWidth()
            ) {

                // Liquid Glass seçili hap
                Box(
                    modifier = Modifier
                        .padding(
                            start = selectedLeft,
                            top = 3.dp
                        )
                        .width(selectedWidth)
                        .height(55.dp)
                        .shadow(
                            elevation = 8.dp,
                            shape = RoundedCornerShape(19.dp),
                            ambientColor = accent.copy(alpha = 0.10f),
                            spotColor = accent.copy(alpha = 0.16f)
                        )
                        .clip(RoundedCornerShape(19.dp))
                        .background(
                            if (isDark) {
                                Color.White.copy(alpha = 0.075f)
                            } else {
                                Color.White.copy(alpha = 0.24f)
                            }
                        )
                        .border(
                            width = 1.dp,
                            color = if (isDark) {
                                Color.White.copy(alpha = 0.25f)
                            } else {
                                Color.White.copy(alpha = 0.68f)
                            },
                            shape = RoundedCornerShape(19.dp)
                        )
                ) {

                    // Üst parlaklık çizgisi
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 12.dp)
                            .height(1.dp)
                            .background(
                                Color.White.copy(
                                    alpha = if (isDark) {
                                        0.34f
                                    } else {
                                        0.72f
                                    }
                                )
                            )
                            .align(Alignment.TopCenter)
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    navItems.forEachIndexed { index, item ->

                        val selected =
                            index == selectedIndex

                        val scale by animateFloatAsState(
                            targetValue =
                                if (selected) 1.045f else 1f,
                            animationSpec = tween(
                                durationMillis = 180,
                                easing = FastOutSlowInEasing
                            ),
                            label = "navigation-item-scale-$index"
                        )

                        Column(
                            modifier = Modifier
                                .width(itemWidth)
                                .height(55.dp)
                                .clip(
                                    RoundedCornerShape(19.dp)
                                )
                                .clickable {
                                    onSelected(index)
                                }
                                .graphicsLayer {
                                    scaleX = scale
                                    scaleY = scale
                                },
                            horizontalAlignment =
                                Alignment.CenterHorizontally,
                            verticalArrangement =
                                Arrangement.Center
                        ) {

                            Icon(
                                imageVector = item.icon,
                                contentDescription = item.label,
                                tint =
                                    if (selected) {
                                        accent
                                    } else {
                                        muted
                                    },
                                modifier = Modifier.height(22.dp)
                            )

                            Text(
                                text = item.label,
                                color =
                                    if (selected) {
                                        accent
                                    } else {
                                        muted
                                    },
                                style =
                                    MaterialTheme.typography.labelSmall
                            )
                        }
                    }
                }
            }
        }
    }
}
