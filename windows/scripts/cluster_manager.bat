@echo off
title Kubernetes Cluster VM Manager
color 0A

REM ====== CONFIGURATION ======
set "VMRUN=C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
set "MASTER_VM=D:\Machines\k8s cluster\k8s master ubuntu 22.04.6\master-node.vmx"
set "WORKER1_VM=D:\Machines\k8s cluster\k8s worker 1 ubuntu 22.04.6\worker-node01.vmx"
set "WORKER2_VM=D:\Machines\k8s cluster\k8s worker 2 ubuntu 22.04\worker02.vmx"

REM ====== MAIN MENU ======
:menu
cls
echo Kubernetes Cluster VM Manager
echo ============================
echo.
echo 1. Start Cluster VMs
echo 2. Stop Cluster VMs
echo 3. Exit
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto start_vms
if "%choice%"=="2" goto stop_vms
if "%choice%"=="3" exit /b
echo Invalid choice, please try again
timeout /t 2 >nul
goto menu

REM ====== START VMs ======
:start_vms
cls
echo Starting Kubernetes Cluster VMs...
echo.

REM Check if vmrun exists
if not exist "%VMRUN%" (
    echo ERROR: vmrun.exe not found at:
    echo "%VMRUN%"
    echo Check VMware installation.
    pause
    goto menu
)

REM Start Master Node
echo Starting Master Node...
"%VMRUN%" -T ws start "%MASTER_VM%" nogui
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Master Node!
    echo Check: 
    echo 1. Is the VM already running?
    echo 2. Is VMware running?
    echo "%MASTER_VM%"
) else (
    echo [SUCCESS] Master Node started.
)

REM Start Worker 1
echo Starting Worker Node 1...
"%VMRUN%" -T ws start "%WORKER1_VM%" nogui
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Worker 1!
) else (
    echo [SUCCESS] Worker 1 started.
)

REM Start Worker 2
echo Starting Worker Node 2...
"%VMRUN%" -T ws start "%WORKER2_VM%" nogui
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Worker 2!
) else (
    echo [SUCCESS] Worker 2 started.
)

echo.
echo Operation completed. Check logs above.
pause
goto menu

REM ====== STOP VMs ======
:stop_vms
cls
echo Stopping Kubernetes Cluster VMs...
echo.

REM Stop Master Node
echo Stopping Master Node...
"%VMRUN%" -T ws stop "%MASTER_VM%" soft
if %errorlevel% neq 0 (
    echo [ERROR] Failed to stop Master Node!
) else (
    echo [SUCCESS] Master Node stopped.
)

REM Stop Worker 1
echo Stopping Worker Node 1...
"%VMRUN%" -T ws stop "%WORKER1_VM%" soft
if %errorlevel% neq 0 (
    echo [ERROR] Failed to stop Worker 1!
) else (
    echo [SUCCESS] Worker 1 stopped.
)

REM Stop Worker 2
echo Stopping Worker Node 2...
"%VMRUN%" -T ws stop "%WORKER2_VM%" soft
if %errorlevel% neq 0 (
    echo [ERROR] Failed to stop Worker 2!
) else (
    echo [SUCCESS] Worker 2 stopped.
)

echo.
echo Operation completed. Check logs above.
pause
goto menu