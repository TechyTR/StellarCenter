package org.test.thislinux.ui.navigation

import androidx.compose.runtime.Composable

@Composable
fun Navigation(
    selectedIndex: Int,
    onOpenSecurity: () -> Unit = {},
    onOpenShizuku: () -> Unit = {}
) {
    when (selectedIndex) {
        0 -> HomeScreen(
            onOpenSecurity = onOpenSecurity,
            onOpenShizuku = onOpenShizuku
        )

        1 -> SystemMonitorScreen()

        2 -> NotesScreen()

        3 -> AppScreen()
    }
}
