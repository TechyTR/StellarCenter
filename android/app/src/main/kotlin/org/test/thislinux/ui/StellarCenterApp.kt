package org.test.thislinux.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import org.test.thislinux.ui.navigation.Navigation
import org.test.thislinux.ui.theme.StellarAccent
import org.test.thislinux.ui.theme.StellarTheme
import org.test.thislinux.ui.theme.StellarThemeStyle

@Composable
fun StellarCenterApp() {
    val themeStyle = StellarThemeStyle.LIQUID_GLASS_LIGHT
    val accent = StellarAccent.PURPLE

    StellarTheme(
        style = themeStyle,
        accent = accent
    ) {
        var selectedIndex by remember {
            mutableIntStateOf(0)
        }

        var showSecurity by remember {
            mutableStateOf(false)
        }

        Scaffold(
            modifier = Modifier.fillMaxSize(),
            bottomBar = {
                if (!showSecurity) {
                    BottomNavBar(
                        selectedIndex = selectedIndex,
                        themeStyle = themeStyle,
                        onSelected = { index ->
                            selectedIndex = index
                        }
                    )
                }
            }
        ) { padding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
            ) {
                Navigation(
                    selectedIndex = selectedIndex,
                    showSecurity = showSecurity,
                    onOpenSecurity = {
                        showSecurity = true
                    },
                    onCloseSecurity = {
                        showSecurity = false
                    }
                )
            }
        }
    }
}
