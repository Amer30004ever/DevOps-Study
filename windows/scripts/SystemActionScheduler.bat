@echo off
setlocal enabledelayedexpansion

:main_menu
cls
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo    SYSTEM ACTION SCHEDULER
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo 1 - Scheduled Action (set exact time)
echo 2 - Countdown Timer (set duration)
echo.
set /p choice=Choose mode (1 or 2): 

if "%choice%"=="1" goto scheduled_action
if "%choice%"=="2" goto countdown_timer

echo Invalid choice! Please try again.
timeout /t 2 /nobreak >nul
goto main_menu

:scheduled_action
cls
echo SCHEDULED ACTION - Set Exact Time
echo --------------------------------
echo.

:get_hour
set /p hour=Enter the hour (0-23): 
if %hour% LSS 0 goto invalid_hour
if %hour% GTR 23 goto invalid_hour
goto get_minute

:invalid_hour
echo Invalid hour! Please enter a value between 0 and 23.
goto get_hour

:get_minute
set /p minute=Enter the minute (0-59): 
if %minute% LSS 0 goto invalid_minute
if %minute% GTR 59 goto invalid_minute
goto get_action

:invalid_minute
echo Invalid minute! Please enter a value between 0 and 59.
goto get_minute

:get_action
echo.
echo Choose an action:
echo 1 - Sleep
echo 2 - Hibernate
echo 3 - Reboot
echo 4 - Shutdown
echo 5 - Return to main menu
echo.
set /p action=Enter the action number (1-5): 

if "%action%"=="1" set command=rundll32.exe powrprof.dll,SetSuspendState 0,1,0 & set action_name=Sleep
if "%action%"=="2" set command=shutdown /h & set action_name=Hibernate
if "%action%"=="3" set command=shutdown /r & set action_name=Reboot
if "%action%"=="4" set command=shutdown /s & set action_name=Shutdown
if "%action%"=="5" goto main_menu

if not defined command (
    echo Invalid selection! Please try again.
    goto get_action
)

echo.
echo You've scheduled a %action_name% at %hour%:%minute%
echo.

:calculate_time
for /f "tokens=1-3 delims=:." %%a in ("%time%") do (
    set current_hour=%%a
    set current_minute=%%b
    set current_second=%%c
)

set current_hour=!current_hour: =0!
set /a target_time=(%hour%*3600) + (%minute%*60)
set /a current_time=(!current_hour!*3600) + (!current_minute!*60) + (!current_second!)

if !target_time! LEQ !current_time! (
    set /a delay_seconds=!target_time! + 86400 - !current_time!
) else (
    set /a delay_seconds=!target_time! - !current_time!
)

echo Waiting until %hour%:%minute% to perform %action_name%...
echo.

set /a delay_hours=!delay_seconds! / 3600
set /a remaining_seconds=!delay_seconds! %% 3600
set /a delay_minutes=!remaining_seconds! / 60
set /a delay_seconds=!remaining_seconds! %% 60

echo Time remaining: !delay_hours! hours, !delay_minutes! minutes, and !delay_seconds! seconds
timeout /t %delay_seconds% /nobreak >nul

echo.
echo Performing %action_name% now...
%command%
goto end

:countdown_timer
cls
echo COUNTDOWN TIMER
echo ---------------
echo.

:get_hours
set /p hours=Enter hours (0-23): 
if %hours% LSS 0 goto invalid_hours
if %hours% GTR 23 goto invalid_hours
goto get_minutes

:invalid_hours
echo Invalid hours! Please enter a value between 0 and 23.
goto get_hours

:get_minutes
set /p minutes=Enter minutes (0-59): 
if %minutes% LSS 0 goto invalid_minutes
if %minutes% GTR 59 goto invalid_minutes
goto timer_action

:invalid_minutes
echo Invalid minutes! Please enter a value between 0 and 59.
goto get_minutes

:timer_action
echo.
echo Choose an action when timer expires:
echo 1 - Sleep
echo 2 - Hibernate
echo 3 - Reboot
echo 4 - Shutdown
echo 5 - Just alert (no action)
echo 6 - Return to main menu
echo.
set /p action=Enter action number (1-6): 

if "%action%"=="1" set "command=rundll32.exe powrprof.dll,SetSuspendState 0,1,0" & set "action_name=Sleep"
if "%action%"=="2" set "command=shutdown /h" & set "action_name=Hibernate"
if "%action%"=="3" set "command=shutdown /r /t 0" & set "action_name=Reboot"
if "%action%"=="4" set "command=shutdown /s /t 0" & set "action_name=Shutdown"
if "%action%"=="5" set "command=echo Timer expired!" & set "action_name=Alert"
if "%action%"=="6" goto main_menu

if not defined command (
    echo Invalid selection! Please try again.
    goto timer_action
)

echo.
set /a total_seconds=(%hours%*3600) + (%minutes%*60)

:timer_countdown
cls
echo COUNTDOWN TIMER - Action: !action_name!
echo -------------------------------
echo.

if %total_seconds% LEQ 0 (
    echo TIMER EXPIRED!
    echo Performing action: !action_name!
    %command%
    pause
    goto end
)

set /a remaining_hours=%total_seconds% / 3600
set /a remaining_minutes=(%total_seconds% %% 3600) / 60
set /a remaining_seconds=%total_seconds% %% 60

echo Time remaining: 
echo !remaining_hours! hours !remaining_minutes! minutes !remaining_seconds! seconds
echo.
echo Press CTRL+C to cancel the timer

ping -n 2 127.0.0.1 >nul
set /a total_seconds-=1
goto timer_countdown

:end
endlocal