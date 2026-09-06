package org.test.thislinux.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.material3.Text

@Composable
fun StellarNavigation(
    selectedIndex: Int
) {

    when (selectedIndex) {

        0 -> HomeScreen()

        1 -> SystemMonitorScreen()

        2 -> StorageScreen()

        3 -> SettingsScreen()
    }
}
