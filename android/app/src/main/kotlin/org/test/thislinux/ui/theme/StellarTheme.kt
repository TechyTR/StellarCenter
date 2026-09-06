package org.test.thislinux.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

enum class StellarThemeStyle {
    NORMAL,
    LIQUID_GLASS_LIGHT,
    LIQUID_GLASS_DARK
}

enum class StellarAccent {
    PURPLE,
    BLUE,
    GREEN,
    ORANGE
}

private val Purple = Color(0xFF7C4DFF)
private val Blue = Color(0xFF2979FF)
private val Green = Color(0xFF00C853)
private val Orange = Color(0xFFFF6D00)

private fun accentColor(accent: StellarAccent): Color {
    return when (accent) {
        StellarAccent.PURPLE -> Purple
        StellarAccent.BLUE -> Blue
        StellarAccent.GREEN -> Green
        StellarAccent.ORANGE -> Orange
    }
}

@Composable
fun StellarTheme(
    style: StellarThemeStyle = StellarThemeStyle.NORMAL,
    accent: StellarAccent = StellarAccent.PURPLE,
    content: @Composable () -> Unit
) {
    val primary = accentColor(accent)

    val colors = when (style) {
        StellarThemeStyle.NORMAL,
        StellarThemeStyle.LIQUID_GLASS_LIGHT -> {
            lightColorScheme(
                primary = primary,
                secondary = primary,
                tertiary = primary
            )
        }

        StellarThemeStyle.LIQUID_GLASS_DARK -> {
            darkColorScheme(
                primary = primary,
                secondary = primary,
                tertiary = primary
            )
        }
    }

    MaterialTheme(
        colorScheme = colors,
        content = content
    )
}
