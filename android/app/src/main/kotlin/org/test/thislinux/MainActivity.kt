package org.test.thislinux

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import org.test.thislinux.ui.BootScreen
import org.test.thislinux.ui.StellarCenterApp

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        enableEdgeToEdge()

        setContent {
            var bootFinished by remember {
                mutableStateOf(false)
            }

            if (bootFinished) {
                StellarCenterApp()
            } else {
                BootScreen(
                    onFinished = {
                        bootFinished = true
                    }
                )
            }
        }
    }
}

