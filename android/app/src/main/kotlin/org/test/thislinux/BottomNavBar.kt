package org.test.thislinux.ui

import android.graphics.RenderEffect
import android.graphics.Shader
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedDefaultTextStyle
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
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
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.test.thislinux.ui.theme.StellarThemeStyle

private data class NavItem(
    val label: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector,
    val selectedIcon: androidx.compose.ui.graphics.vector.ImageVector
)

@Composable
fun BottomNavBar(
    selectedIndex: Int,
    themeStyle: StellarThemeStyle,
    onSelected: (Int) -> Unit
) {
    val isLight =
        themeStyle == StellarThemeStyle.LIQUID_GLASS_LIGHT

    val isDark =
        themeStyle == StellarThemeStyle.LIQUID_GLASS_DARK

    val isGlass = isLight || isDark

    val accent = Color(0xFF7C4DFF)

    val mutedColor = if (isDark) {
        Color.White.copy(alpha = 0.82f)
    } else {
        Color.Black.copy(alpha = 0.82f)
    }

    val items = listOf(
        NavItem(
            label = "Menü",
            icon = Icons.Outlined.Dashboard,
            selectedIcon = Icons.Filled.Dashboard
        ),
        NavItem(
            label = "Monitor",
            icon = Icons.Outlined.MonitorHeart,
            selectedIcon = Icons.Filled.MonitorHeart
        ),
        NavItem(
            label = "Notes",
            icon = Icons.Outlined.Note,
            selectedIcon = Icons.Filled.Note
        ),
        NavItem(
            label = "App",
            icon = Icons.Outlined.Info,
            selectedIcon = Icons.Filled.Info
        )
    )

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                start = 14.dp,
                end = 14.dp,
                top = 8.dp,
                bottom = 10.dp
            ),
        contentAlignment = Alignment.BottomCenter
    ) {
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .height(70.dp)
                .clip(RoundedCornerShape(32.dp))
                .background(
                    when {
                        isLight -> Color.White.copy(alpha = 0.22f)
                        isDark -> Color.Black.copy(alpha = 0.28f)
                        else -> Color.Transparent
                    }
                )
                .border(
                    width = 1.dp,
                    color = when {
                        isLight -> Color.White.copy(alpha = 0.68f)
                        isDark -> Color.White.copy(alpha = 0.28f)
                        else -> Color.Transparent
                    },
                    shape = RoundedCornerShape(32.dp)
                )
                .graphicsLayer {
                    if (isGlass) {
                        renderEffect = RenderEffect.createBlurEffect(
                            30f,
                            30f,
                            Shader.TileMode.CLAMP
                        )
                    }
                }
        ) {
            if (isGlass) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(1.5.dp)
                        .padding(horizontal = 14.dp)
                        .background(
                            Brush.horizontalGradient(
                                listOf(
                                    Color.Transparent,
                                    Color.White.copy(
                                        alpha = if (isLight) 0.80f else 0.38f
                                    ),
                                    Color.Transparent
                                )
                            )
                        )
                )

                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.verticalGradient(
                                listOf(
                                    Color.White.copy(
                                        alpha = if (isLight) 0.12f else 0.07f
                                    ),
                                    Color.Transparent,
                                    Color.Black.copy(
                                        alpha = if (isLight) 0.025f else 0.08f
                                    )
                                )
                            )
                        )
                )
            }

            val itemWidth = maxWidth / items.size

            val indicatorOffset by animateDpAsState(
                targetValue = itemWidth * selectedIndex + 5.dp,
                animationSpec = tween(
                    durationMillis = 500,
                    easing = FastOutSlowInEasing
                ),
                label = "navigationIndicatorPosition"
            )

            Box(
                modifier = Modifier
                    .offset(
                        x = indicatorOffset,
                        y = 7.dp
                    )
                    .width(itemWidth - 10.dp)
                    .height(56.dp)
                    .clip(RoundedCornerShape(25.dp))
                    .background(
                        if (isLight) {
                            Color.White.copy(alpha = 0.16f)
                        } else {
                            Color.White.copy(alpha = 0.08f)
                        }
                    )
                    .border(
                        width = 1.dp,
                        color = if (isLight) {
                            Color.White.copy(alpha = 0.72f)
                        } else {
                            Color.White.copy(alpha = 0.32f)
                        },
                        shape = RoundedCornerShape(25.dp)
                    )
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(1.5.dp)
                        .padding(horizontal = 10.dp)
                        .background(
                            Brush.horizontalGradient(
                                listOf(
                                    Color.Transparent,
                                    Color.White.copy(
                                        alpha = if (isLight) 0.72f else 0.34f
                                    ),
                                    Color.Transparent
                                )
                            )
                        )
                )

                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.verticalGradient(
                                listOf(
                                    Color.White.copy(
                                        alpha = if (isLight) 0.08f else 0.04f
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
                        targetValue = if (selected) 1.06f else 1f,
                        animationSpec = tween(
                            durationMillis = 300,
                            easing = FastOutSlowInEasing
                        ),
                        label = "navigationItemScale"
                    )

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .clickable {
                                onSelected(index)
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
                                    item.icon
                                },
                                contentDescription = item.label,
                                modifier = Modifier
                                    .size(21.dp)
                                    .graphicsLayer {
                                        scaleX = scale
                                        scaleY = scale
                                    },
                                tint = if (selected) {
                                    accent
                                } else {
                                    mutedColor
                                }
                            )

                            Spacer(
                                modifier = Modifier.height(3.dp)
                            )

                            Text(
                                text = item.label,
                                fontSize = if (selected) 10.5.sp else 10.sp,
                                fontWeight = if (selected) {
                                    FontWeight.SemiBold
                                } else {
                                    FontWeight.Normal
                                },
                                color = if (selected) {
                                    accent
                                } else {
                                    mutedColor
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
