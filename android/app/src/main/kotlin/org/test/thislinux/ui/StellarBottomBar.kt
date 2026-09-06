package org.test.thislinux.ui

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material3.*
import androidx.compose.runtime.Composable

@Composable
fun StellarBottomBar(
    selectedIndex: Int,
    onSelected: (Int) -> Unit
) {

    NavigationBar {

        NavigationBarItem(
            selected = selectedIndex == 0,
            onClick = {
                onSelected(0)
            },
            icon = {
                Icon(
                    Icons.Default.Home,
                    contentDescription = "Home"
                )
            },
            label = {
                Text("Home")
            }
        )

        NavigationBarItem(
            selected = selectedIndex == 1,
            onClick = {
                onSelected(1)
            },
            icon = {
                Icon(
                    Icons.Default.Speed,
                    contentDescription = "Monitor"
                )
            },
            label = {
                Text("Monitor")
            }
        )

        NavigationBarItem(
            selected = selectedIndex == 2,
            onClick = {
                onSelected(2)
            },
            icon = {
                Icon(
                    Icons.Default.Storage,
                    contentDescription = "Storage"
                )
            },
            label = {
                Text("Storage")
            }
        )

        NavigationBarItem(
            selected = selectedIndex == 3,
            onClick = {
                onSelected(3)
            },
            icon = {
                Icon(
                    Icons.Default.Settings,
                    contentDescription = "Settings"
                )
            },
            label = {
                Text("Settings")
            }
        )
    }
}
