package org.test.thislinux.ui.navigation

import androidx.compose.runtime.Composable

@Composable
fun StellarNavigation(
    selectedIndex: Int
) {
    when (selectedIndex) {
        0 -> SystemMonitorScreen()
        1 -> NotesScreen()
        2 -> AppScreen()
    }
}
