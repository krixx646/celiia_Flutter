@echo off
set JAVA_HOME=C:\Users\ADMIN\AppData\Local\Android\Sdk\jdk\jdk-17
echo Using JAVA_HOME: %JAVA_HOME%
call gradlew.bat assembleDebug
echo Build completed with exit code: %ERRORLEVEL%
pause 