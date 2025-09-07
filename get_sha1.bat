@echo off
echo Getting SHA-1 fingerprint for your release keystore
echo.
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
"%JAVA_HOME%\bin\keytool" -list -v -keystore app/keystore/celia_release_key.jks -alias celia
echo.
echo *** Important: Add this SHA-1 fingerprint to your Firebase project! ***
echo.
pause 