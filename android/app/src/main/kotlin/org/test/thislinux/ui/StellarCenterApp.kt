package org.test.thislinux.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import org.test.thislinux.ui.navigation.StellarNavigation
import org.test.thislinux.ui.theme.StellarTheme

@Composable
fun StellarCenterApp() {

    StellarTheme {

        var selectedIndex by remember {
            mutableIntStateOf(0)
        }

        Scaffold(
            modifier = Modifier.fillMaxSize(),
            bottomBar = {
                StellarBottomBar(
                    selectedIndex = selectedIndex,
                    onSelected = {
                        selectedIndex = it
                    }
                )
            }
        ) { padding ->

            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
            ) {

                StellarNavigation(
                    selectedIndex = selectedIndex
                )
            }
        }
    }
}
