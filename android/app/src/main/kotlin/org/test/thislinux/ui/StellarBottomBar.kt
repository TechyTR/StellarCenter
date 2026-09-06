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
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.Note
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
import org.test.thislinux.ui.theme.StellarThemeStyle

private data class NavItem(
    val label: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector
)

private val navItems = listOf(
    NavItem("System", Icons.Default.Memory),
    NavItem("Notes", Icons.Default.Note),
    NavItem("App", Icons.Default.Info)
)

@Composable
fun StellarBottomBar(
    selectedIndex: Int,
    themeStyle: StellarThemeStyle,
    onSelected: (Int) -> Unit
) {
    val isDark = themeStyle == StellarThemeStyle.LIQUID_GLASS_DARK
    val accent = MaterialTheme.colorScheme.primary
    val muted = MaterialTheme.colorScheme.onSurfaceVariant

    if (themeStyle == StellarThemeStyle.NORMAL) {
        androidx.compose.material3.NavigationBar {
            navItems.forEachIndexed { index, item ->
                androidx.compose.material3.NavigationBarItem(
                    selected = index == selectedIndex,
                    onClick = { onSelected(index) },
                    icon = {
                        Icon(
                            imageVector = item.icon,
                            contentDescription = item.label
                        )
                    },
                    label = {
                        Text(item.label)
                    }
                )
            }
        }

        return
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                start = 20.dp,
                end = 20.dp,
                top = 4.dp,
                bottom = 10.dp
            )
    ) {
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .height(72.dp)
                .clip(RoundedCornerShape(28.dp))
                .background(
                    if (isDark) {
                        Color.Black.copy(alpha = 0.55f)
                    } else {
                        Color.White.copy(alpha = 0.55f)
                    }
                )
                .border(
                    1.dp,
                    if (isDark) {
                        Color.White.copy(alpha = 0.18f)
                    } else {
                        Color.White.copy(alpha = 0.65f)
                    },
                    RoundedCornerShape(28.dp)
                )
                .padding(6.dp)
        ) {
            val itemWidth = maxWidth / navItems.size

            val targetLeft =
                itemWidth * selectedIndex + 3.dp

            val targetWidth =
                itemWidth - 6.dp

            val animatedLeft by animateDpAsState(
                targetValue = targetLeft,
                animationSpec = tween(
                    durationMillis = 300,
                    easing = FastOutSlowInEasing
                ),
                label = "glass-pill-position"
            )

            val animatedWidth by animateDpAsState(
                targetValue = targetWidth,
                animationSpec = tween(
                    durationMillis = 300,
                    easing = FastOutSlowInEasing
                ),
                label = "glass-pill-width"
            )

            Box(
                modifier = Modifier.fillMaxWidth()
            ) {
                Box(
                    modifier = Modifier
                        .padding(
                            start = animatedLeft,
                            top = 3.dp
                        )
                        .width(animatedWidth)
                        .height(58.dp)
                        .shadow(
                            elevation = 8.dp,
                            shape = RoundedCornerShape(22.dp),
                            ambientColor = accent.copy(alpha = 0.10f),
                            spotColor = accent.copy(alpha = 0.16f)
                        )
                        .clip(RoundedCornerShape(22.dp))
                        .background(
                            accent.copy(
                                alpha = if (isDark) 0.28f else 0.18f
                            )
                        )
                        .border(
                            1.dp,
                            if (isDark) {
                                Color.White.copy(alpha = 0.20f)
                            } else {
                                Color.White.copy(alpha = 0.65f)
                            },
                            RoundedCornerShape(22.dp)
                        )
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 14.dp)
                            .height(1.dp)
                            .background(
                                Color.White.copy(
                                    alpha = if (isDark) 0.34f else 0.72f
                                )
                            )
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    navItems.forEachIndexed { index, item ->
                        val selected = index == selectedIndex

                        val scale by animateFloatAsState(
                            targetValue = if (selected) 1.04f else 1f,
                            animationSpec = tween(
                                durationMillis = 200,
                                easing = FastOutSlowInEasing
                            ),
                            label = "glass-item-scale-$index"
                        )

                        Column(
                            modifier = Modifier
                                .width(itemWidth)
                                .height(58.dp)
                                .clip(RoundedCornerShape(22.dp))
                                .clickable {
                                    onSelected(index)
                                }
                                .graphicsLayer {
                                    scaleX = scale
                                    scaleY = scale
                                },
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = item.icon,
                                contentDescription = item.label,
                                tint = if (selected) {
                                    accent
                                } else {
                                    muted
                                },
                                modifier = Modifier.height(23.dp)
                            )

                            Text(
                                text = item.label,
                                color = if (selected) {
                                    accent
                                } else {
                                    muted
                                },
                                fontSize = if (selected) {
                                    androidx.compose.ui.unit.sp(12)
                                } else {
                                    androidx.compose.ui.unit.sp(11)
                                },
                                fontWeight = if (selected) {
                                    androidx.compose.ui.text.font.FontWeight.SemiBold
                                } else {
                                    androidx.compose.ui.text.font.FontWeight.Normal
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
