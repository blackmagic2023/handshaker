@echo off
:nocap
Set /a suc=(%RANDOM%%%(8-6+1))+6
for /f "delims=" %%x in (C:\Users\%username%\Documents\tessid.txt) do set apessid=%%x
set x=0
Set /a prt=(%RANDOM%%%(64999-999+1))+999 
Set /a win=(%RANDOM%%%(64999-999+1))+999 

Set /a h1=(%RANDOM%%%(6499809-9+1))+9
Set /a h2=(%RANDOM%%%(6453999-9+1))+9
Set /a h3=(%RANDOM%%%(6494399-9+1))+9 
set key=nullnull!
echo Spawning access point clone...
netsh wlan set hostednetwork mode=allow ssid=%apessid% key=%key%
netsh wlan start hostednetwork
echo Access point online: %apessid%
Set /a sel=(%RANDOM%%%(63-5+1))+5 
:clients

echo -------------------------------------------------------------
echo Waiting for clients...
echo ESSID          PWR   RATE     LOST     FRAMES
echo -------------------------------------------------------------
echo.
echo.
echo.
echo -------------------------------------------------------------
ping localhost >nul
set /a x=(1+%x%) 
cls 
if %x% == %sel% goto client
if not %x% == %sel% goto clients
:client
if  not %suc% == 7 goto clients 
if %suc% == 7 goto cap
setlocal EnableDelayedExpansion

set "hexChars=0123456789ABCDEF"
set "macAddress="
for /L %%i in (1,1,12) do (
    set /A "rand=!random! %% 16"
    for %%j in (!rand!) do set "macAddress=!macAddress!!hexChars:~%%j,1!"
)
set "formattedMac=!macAddress:~0,2!:!macAddress:~2,2!:!macAddress:~4,2!:!macAddress:~6,2!:!macAddress:~8,2!:!macAddress:~10,2!"
set "tbssid=!formattedMac!"
echo -------------------------------------------------------------
echo Client found!
echo ESSID                PWR   RATE     LOST     FRAMES
echo -------------------------------------------------------------
echo.
echo %formattedMac%
echo.
echo -------------------------------------------------------------

:cap
echo true > C:\Users\%username%\Documents\foundclient.txt
echo PACKET 1 %time% SOURCE %apessid% DEST %formattedMac% TCP %prt%:http SYN SEQ 0 WIN %win% TSER 0 %prt%%win% >> C:\Users\%username%\Documents\handshake.pcap
echo PACKET 2 %time% SOURCE %formattedMac% DEST %apessid% TCP http:%prt% SYN ACK SEQ 0 ACK 1 WIN %win% LEN 0 TSER 0 TSV=%prt%%win%%prt% >> C:\Users\%username%\Documents\handshake.pcap
echo PACKET 3 %time% SOURCE %apessid% DEST %formattedMac% TCP %prt%:http ACK SEQ 1 ACK 1 WIN %win% LEN 0 TSER=%prt%%prt%%win% >> C:\Users\%username%\Documents\handshake.pcap
echo %time% %prt%%win%%h1%%h1%%h2%%h2%%h3%%h3% >> C:\Users\%username%\Documents\handshake.pcap
endlocal
exit
