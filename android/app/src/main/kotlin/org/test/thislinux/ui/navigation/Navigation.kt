package org.test.thislinux.ui.navigation

import androidx.compose.runtime.Composable

@Composable
fun Navigation(
    selectedIndex: Int,
    showSecurity: Boolean,
    onOpenSecurity: () -> Unit,
    onCloseSecurity: () -> Unit
) {
    if (showSecurity) {
        StellarSecureScreen(
            onBack = onCloseSecurity
        )

        return
    }

    when (selectedIndex) {
        0 -> HomeScreen(
            onOpenSecurity = onOpenSecurity
        )

        1 -> SystemMonitorScreen()

        2 -> NotesScreen()

        3 -> AppScreen()
    }
}
