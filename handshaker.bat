@echo off
set iface=null
set iip=null
set tessid=null
set station=null
netsh wlan show interfaces
set /p iname=Select an interface by typing the name: 
echo %iname% > C:\Users\%username%\Documents\handshake.pss
setlocal enabledelayedexpansion

for /f "delims=" %%a in ('powershell -Command "(Get-NetIPAddress -InterfaceAlias '%iname%' | Where-Object AddressFamily -eq 'IPv4').IPAddress"') do (
    set "ipAddress=%%a"
)

if defined ipAddress (
    echo IP address of %iname% is: %ipAddress%
	echo %ipAddress% >> C:\Users\%username%\Documents\handshake.pss
	set iface=%iname%
	set iip=%IPAddress%
	goto esc
) else (
    echo Interface %iname% not found or has no IP address.
)

endlocal

:esc
echo %iface%:%iip%
cd "C:\Program Files\Wireshark"
tshark.exe -i %iface% -I
ping localhost -n 1 >nul
netsh wlan show interfaces
ping localhost -n 2 >nul
echo mac80211 monitor mode vif enabled for %iface%...
ping localhost -n 2 >nul
echo mac80211 station mode vif disabled for %iface%
echo.
echo Type the ESSID for target network
echo.
set /p essid=:
set tessid=%essid%
tshark.exe -c 22 -i wlan
echo Selecting handshake victim...
echo.
ping localhost -n 7 >nul
Set /a pwr=(%RANDOM%%%(99-1+1))+1 
Set /a pwr2=(%RANDOM%%%(99-1+1))+1 
Set /a beacons=(%RANDOM%%%(99-1+12))+12 
Set /a channel=(%RANDOM%%%(12-1+1))+1 
Set /a band=(%RANDOM%%%(999-1+1))+1 
Set /a enc=(%RANDOM%%%(9-1+1))+1 
if %enc% == 7 set enc=WPA
if not %enc% == 7 set enc=WPA2
Set /a pck=(%RANDOM%%%(9-1+1))+1 
Set /a frames=(%RANDOM%%%(9-1+1))+1 
set cip=CCMP
set auth=PSK
setlocal EnableDelayedExpansion

set "hexChars=0123456789ABCDEF"
set "macAddress="
for /L %%i in (1,1,12) do (
    set /A "rand=!random! %% 16"
    for %%j in (!rand!) do set "macAddress=!macAddress!!hexChars:~%%j,1!"
)

set "formattedMac=!macAddress:~0,2!:!macAddress:~2,2!:!macAddress:~4,2!:!macAddress:~6,2!:!macAddress:~8,2!:!macAddress:~10,2!"

echo Router: BSSID %formattedMac% PWR -%pwr% Beacons %beacons% Data 0 S 0 CH %channel% MB %band% ENC %enc% CIPHER %cip% AUTH %auth% ESSID %tessid% 
set tbssid=%formattedMac%
echo %formattedMac% > C:\Users\%username%\Documents\tbssid.txt
endlocal
for /f "delims=" %%x in (C:\Users\%username%\Documents\tbssid.txt) do set tbssid=%%x
setlocal EnableDelayedExpansion

set "hexChars=0123456789ABCDEF"
set "macAddress="
for /L %%i in (1,1,12) do (
    set /A "rand=!random! %% 16"
    for %%j in (!rand!) do set "macAddress=!macAddress!!hexChars:~%%j,1!"
)

set "formattedMac=!macAddress:~0,2!:!macAddress:~2,2!:!macAddress:~4,2!:!macAddress:~6,2!:!macAddress:~8,2!:!macAddress:~10,2!"

echo Station BSSID %formattedMac% STATION %tbssid% PWR -%pwr2% RATE 0 - %band% LOST %pck% FRAMES %frames% NOTES  PROBES  
set station=%formattedMac%
echo %formattedMac% > C:\Users\%username%\Documents\station.txt
echo.
endlocal
for /f "delims=" %%x in (C:\Users\%username%\Documents\station.txt) do set station=%%x
echo.
echo Spawning AP Clone, Handshakes will be saved to %username%\Documents\handshake.pcap
echo %tessid% > C:\Users\%username%\Documents\tessid.txt
echo false > C:\Users\%username%\Documents\foundclient.txt
echo %tbssid% > C:\Users\%username%\Documents\tbssid.txt
echo %channel% > C:\Users\%username%\Documents\tchannel.txt
echo %iface% > C:\Users\%username%\Documents\iface.txt
start C:\Users\%username%\Documents\ap.bat
echo.
echo Launching deauthentication attack on %tbssid%...
start C:\Users\%username%\Documents\f.bat
echo.
echo Waiting for handshake...
:check
for /f "delims=" %%x in (C:\Users\%username%\Documents\foundclient.txt) do set client=%%x
if %client%==true goto aq
if not %client%==true goto check
goto check
:aq
echo.
ping localhost -n 2 >nul
echo mac80211 monitor mode vif disabled for %iface%...
ping localhost -n 2 >nul
echo mac80211 station mode vif enabled for %iface%
pause
