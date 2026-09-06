package org.test.thislinux.ui

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Dashboard
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.MonitorHeart
import androidx.compose.material.icons.filled.Note
import androidx.compose.material.icons.outlined.Dashboard
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material.icons.outlined.MonitorHeart
import androidx.compose.material.icons.outlined.Note
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.font.FontWeight
import kotlinx.coroutines.launch
import org.test.thislinux.ui.theme.StellarThemeStyle

private data class NavItem(
    val label: String,
    val selectedIcon: androidx.compose.ui.graphics.vector.ImageVector,
    val unselectedIcon: androidx.compose.ui.graphics.vector.ImageVector
)

@Composable
fun StellarBottomBar(
    selectedIndex: Int,
    themeStyle: StellarThemeStyle,
    onSelected: (Int) -> Unit
) {
    val isGlass =
        themeStyle == StellarThemeStyle.LIQUID_GLASS_LIGHT ||
        themeStyle == StellarThemeStyle.LIQUID_GLASS_DARK

    val isDark =
        themeStyle == StellarThemeStyle.LIQUID_GLASS_DARK

    val accent = Color(0xFF7C4DFF)

    val muted = if (isDark) {
        Color.White.copy(alpha = 0.62f)
    } else {
        Color.Black.copy(alpha = 0.55f)
    }

    val items = listOf(
        NavItem(
            "Ana Sayfa",
            Icons.Filled.Dashboard,
            Icons.Outlined.Dashboard
        ),
        NavItem(
            "Monitor",
            Icons.Filled.MonitorHeart,
            Icons.Outlined.MonitorHeart
        ),
        NavItem(
            "Notlar",
            Icons.Filled.Note,
            Icons.Outlined.Note
        ),
        NavItem(
            "Hakkında",
            Icons.Filled.Info,
            Icons.Outlined.Info
        )
    )

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                start = 28.dp,
                end = 28.dp,
                top = 4.dp,
                bottom = 8.dp
            ),
        contentAlignment = Alignment.BottomCenter
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
            val itemWidth = maxWidth / items.size

            val animatedLeft by animateDpAsState(
                targetValue = itemWidth * selectedIndex + 3.dp,
                animationSpec = tween(
                    durationMillis = 360,
                    easing = FastOutSlowInEasing
                ),
                label = "selectedIndicatorPosition"
            )

            Box(
                modifier = Modifier
                    .offset(
                        x = animatedLeft,
                        y = 3.dp
                    )
                    .width(itemWidth - 6.dp)
                    .height(55.dp)
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
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(1.2.dp)
                        .padding(horizontal = 12.dp)
                        .background(
                            Brush.horizontalGradient(
                                listOf(
                                    Color.Transparent,
                                    Color.White.copy(
                                        alpha = if (isDark) 0.34f else 0.72f
                                    ),
                                    Color.Transparent
                                )
                            )
                        )
                )
            }

            Row(
                modifier = Modifier.fillMaxSize()
            ) {
                items.forEachIndexed { index, item ->

                    val selected = selectedIndex == index

                    val scale by animateFloatAsState(
                        targetValue = if (selected) 1.045f else 1f,
                        animationSpec = tween(
                            durationMillis = 180,
                            easing = FastOutSlowInEasing
                        ),
                        label = "itemScale"
                    )

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .scale(scale)
                            .clip(RoundedCornerShape(19.dp))
                            .clickable {
                                if (selectedIndex != index) {
                                    onSelected(index)
                                }
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = if (selected) {
                                    item.selectedIcon
                                } else {
                                    item.unselectedIcon
                                },
                                contentDescription = item.label,
                                modifier = Modifier.size(22.dp),
                                tint = if (selected) accent else muted
                            )

                            Spacer(
                                modifier = Modifier.height(2.dp)
                            )

                            Text(
                                text = item.label,
                                fontSize = 12.sp,
                                lineHeight = 14.sp,
                                fontWeight = if (selected) {
                                    FontWeight.Bold
                                } else {
                                    FontWeight.Medium
                                },
                                color = if (selected) accent else muted
                            )
                        }
                    }
                }
            }
        }
    }
}

