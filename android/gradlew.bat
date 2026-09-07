@echo off
setlocal

set "APP_HOME=%~dp0"
set "GRADLE_VERSION=9.3.1"

if "%GRADLE_USER_HOME%"=="" (
    set "GRADLE_USER_HOME=%USERPROFILE%\.gradle"
)

set "GRADLE_DIST=%GRADLE_USER_HOME%\wrapper\dists\gradle-%GRADLE_VERSION%"
set "GRADLE_DIR=%GRADLE_DIST%\gradle-%GRADLE_VERSION%"
set "GRADLE_ZIP=%GRADLE_DIST%\gradle-%GRADLE_VERSION%-bin.zip"

if not exist "%GRADLE_DIR%\bin\gradle.bat" (
    if not exist "%GRADLE_DIST%" mkdir "%GRADLE_DIST%"

    if not exist "%GRADLE_ZIP%" (
        echo Downloading Gradle %GRADLE_VERSION%...

        powershell -NoProfile -ExecutionPolicy Bypass -Command ^
          "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip' -OutFile '%GRADLE_ZIP%'"
    )

    echo Installing Gradle %GRADLE_VERSION%...

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Expand-Archive -Path '%GRADLE_ZIP%' -DestinationPath '%GRADLE_DIST%' -Force"
)

call "%GRADLE_DIR%\bin\gradle.bat" --project-dir "%APP_HOME%" %*
exit /b %ERRORLEVEL%
