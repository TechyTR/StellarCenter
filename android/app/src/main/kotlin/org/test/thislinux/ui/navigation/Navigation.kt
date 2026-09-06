package org.test.thislinux.ui.navigation

import androidx.compose.runtime.Composable

@Composable
fun Navigation(
    selectedIndex: Int
) {
    when (selectedIndex) {
        0 -> HomeScreen()

        1 -> SystemMonitorScreen()

        2 -> NotesScreen()

        3 -> AppScreen()
    }
}
