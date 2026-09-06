package org.test.thislinux.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val StellarLightColors =
    lightColorScheme()

@Composable
fun StellarTheme(
    content: @Composable () -> Unit
) {

    MaterialTheme(
        colorScheme = StellarLightColors,
        content = content
    )
}
