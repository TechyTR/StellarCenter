package org.test.thislinux.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import org.test.thislinux.R

private val bootLines =
    listOf(
        "[  OK  ] Starting Stellar Center...",
        "[  OK  ] Initializing system...",
        "[  OK  ] Loading system information...",
        "[  OK  ] Starting system services...",
        "[  OK  ] Checking device...",
        "[  OK  ] Stellar Center is ready."
    )

private const val TOTAL_BOOT_TIME_MS = 2000L
private const val LOGO_TIME_MS = 500L
private const val LINE_INTERVAL_MS =
    TOTAL_BOOT_TIME_MS / 6L

@Composable
fun BootScreen(
    onFinished: () -> Unit
) {
    var visibleLineCount by remember {
        mutableIntStateOf(0)
    }

    var showLogo by remember {
        mutableStateOf(false)
    }

    LaunchedEffect(Unit) {
        for (index in bootLines.indices) {
            delay(LINE_INTERVAL_MS)
            visibleLineCount = index + 1
        }

        showLogo = true

        delay(LOGO_TIME_MS)

        onFinished()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .safeDrawingPadding()
    ) {
        if (!showLogo) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                horizontalAlignment =
                    Alignment.Start,
                verticalArrangement =
                    Arrangement.Top
            ) {
                Text(
                    text = "Stellar Center",
                    color = Color.White,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(
                    modifier = Modifier.height(18.dp)
                )

                bootLines
                    .take(visibleLineCount)
                    .forEach { line ->
                        Text(
                            text = line,
                            color = Color.White,
                            fontSize = 13.sp,
                            fontFamily =
                                FontFamily.Monospace,
                            modifier =
                                Modifier.padding(
                                    bottom = 5.dp
                                )
                        )
                    }
            }
        } else {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Image(
                    painter =
                        painterResource(
                            id = R.drawable.icon
                        ),
                    contentDescription =
                        "Stellar Center",
                    modifier =
                        Modifier.size(110.dp)
                )
            }
        }
    }
}
