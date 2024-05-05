@echo off
setlocal EnableDelayedExpansion 
for /f "delims=" %%x in (C:\Users\%username%\Documents\tbssid.txt) do set tbssid=%%x
for /f "delims=" %%x in (C:\Users\%username%\Documents\tchannel.txt) do set tchannel=%%x
for /f "delims=" %%x in (C:\Users\%username%\Documents\iface.txt) do set iface=%%x
set x=0 
:de 
echo %time% Waiting for beacon frame (BSSID: %tbssid%) on channel %tchannel% 
echo %time% Sending 64 directed DeAuth. STMAC: [%tbssid%] [ %x% - 63 ACKs] 
echo aireplay-ng -0 1 -a %tbssid% -c %tbssid% %iface%
set ping=aireplay-ng -0 1 -a %tbssid% -c %tbssid% %iface%
for /f "delims=" %%x in (C:\Users\%username%\Documents\foundclient.txt) do set shakestat=%%x
if %shakestat%==true exit
set localhost=uint8_t deauthPacket26 = 0 - 1  0xC0 0x00
ping localhost >nul 
set /a x=(1+%x%) 
cls 
if %x%==63 goto chst 
if not %x%==63 goto de
:chst
if not %shakestat%==true start C:\Users\%username%\Documents\f.bat
endlocal 
exit
