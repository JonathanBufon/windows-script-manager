@echo off
setlocal enabledelayedexpansion
title Windows Script Manager - Pos Formatacao

:: ============================================================================
::  WINDOWS SCRIPT MANAGER
::  Script unificado de pos-formatacao para Windows 10/11
::
::  Unifica dois projetos, com modulos novos de instalacao e associacao:
::    - clean-windows  https://github.com/yanpenalva/clean-windows  (GPL-3.0)
::    - debloat        https://github.com/micheg/debloat            (MIT)
::
::  Licenca: GPL-3.0, herdada do clean-windows. Ver LICENSE.
::
::  Uso:
::    windows-setup.bat          -> abre o menu interativo
::    windows-setup.bat /auto    -> executa tudo sem perguntar nada
::    windows-setup.bat /clean   -> executa apenas limpeza de disco
::
::  ATENCAO: sem acentos de proposito, para nao quebrar no console do cmd.
:: ============================================================================


:: ---------------------------------------------------------------------------
::  CONFIGURACAO - ligue (1) ou desligue (0) cada modulo
:: ---------------------------------------------------------------------------
set "DO_RESTOREPOINT=1"      && rem Cria ponto de restauracao antes de tudo
set "DO_TELEMETRY=1"         && rem Desativa telemetria, DiagTrack e tarefas
set "DO_ONEDRIVE=1"          && rem Desinstala o OneDrive por completo
set "DO_DEBLOAT=1"           && rem Remove apps de consumo (Xbox, Skype, etc)
set "DO_INSTALL=1"           && rem Instala meus programas via winget
set "DO_DEFAULTS=1"          && rem Define WinRAR e VLC como programa padrao
set "DO_PRIVACY=1"           && rem Recentes, thumbcache, relatorios de erro
set "DO_BROWSERCACHE=0"      && rem Cache dos navegadores (FECHA os navegadores)
set "DO_DISKCLEAN=1"         && rem Temp, lixeira, cache do Update, Windows.old
set "DO_DISM_RESETBASE=0"    && rem DISM /ResetBase (irreversivel, ver aviso)
set "DO_OPTIMIZE=1"          && rem Otimiza / TRIM do disco do sistema
set "ASK_REBOOT=1"           && rem Pergunta se quer reiniciar no final

:: Programas instalados pelo modulo DO_INSTALL (IDs exatos do winget).
:: Para descobrir o ID de outro programa:  winget search "nome"
set "WINGET_APPS=Discord.Discord Valve.Steam Mozilla.Firefox RARLab.WinRAR VideoLAN.VLC"

:: Extensoes associadas pelo modulo DO_DEFAULTS.
set "EXT_WINRAR=.rar .zip .7z .tar .gz .tgz .bz2 .xz .cab .arj .lzh .ace .z .iso"
set "EXT_VLC_VIDEO=.mp4 .mkv .avi .mov .wmv .flv .webm .mpg .mpeg .m4v .3gp .ts .m2ts .vob .ogv .divx"
set "EXT_VLC_AUDIO=.mp3 .flac .wav .aac .ogg .oga .m4a .wma .opus .mka .aiff"


:: ---------------------------------------------------------------------------
::  ELEVACAO AUTOMATICA (UAC)
:: ---------------------------------------------------------------------------
>nul 2>&1 net session
if errorlevel 1 (
    echo.
    echo  Solicitando privilegios de administrador...
    if "%~1"=="" (
        powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    ) else (
        powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs"
    )
    exit /b 0
)


:: ---------------------------------------------------------------------------
::  LOG
:: ---------------------------------------------------------------------------
set "LOGDIR=%~dp0logs"
if not exist "%LOGDIR%" md "%LOGDIR%" >nul 2>&1
if not exist "%LOGDIR%" set "LOGDIR=%SystemDrive%\"

set "STAMP="
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "STAMP=%%i"
if not defined STAMP set "STAMP=%RANDOM%"
set "LOG=%LOGDIR%\wsm-%STAMP%.log"

> "%LOG%" echo ==== Windows Script Manager - %date% %time% ====
>>"%LOG%" echo Host: %COMPUTERNAME%  Usuario: %USERNAME%
>>"%LOG%" echo.

set "MODULES_RUN=0"
set "AUTOMODE=0"


:: ---------------------------------------------------------------------------
::  ARGUMENTOS
:: ---------------------------------------------------------------------------
if /i "%~1"=="/auto" ( set "AUTOMODE=1" & goto :RUN_ALL )
if /i "%~1"=="/all"  ( set "AUTOMODE=1" & goto :RUN_ALL )
if /i "%~1"=="/clean" (
    set "AUTOMODE=1"
    set "DO_RESTOREPOINT=0" & set "DO_TELEMETRY=0" & set "DO_ONEDRIVE=0"
    set "DO_DEBLOAT=0"      & set "DO_PRIVACY=1"   & set "DO_DISKCLEAN=1"
    set "DO_INSTALL=0"     & set "DO_DEFAULTS=0"
    set "DO_OPTIMIZE=1"
    goto :RUN_ALL
)


:: ===========================================================================
::  MENU
:: ===========================================================================
:MENU
cls
call :BANNER
echo   [1]  Executar TUDO                 (recomendado em PC recem formatado)
echo   [2]  Escolher modulos um a um
echo   [3]  Somente limpeza de disco      (temp, lixeira, cache, Windows.old)
echo   [4]  Somente privacidade + debloat (telemetria, OneDrive, apps)
echo   [5]  Somente instalar programas + definir padroes
echo   [6]  Ver configuracao atual
echo.
echo   [0]  Sair
echo.
set "OPT="
set /p "OPT=  Escolha uma opcao: "

if "%OPT%"=="1" goto :CONFIRM
if "%OPT%"=="2" goto :PICK
if "%OPT%"=="3" (
    set "DO_RESTOREPOINT=0" & set "DO_TELEMETRY=0" & set "DO_ONEDRIVE=0"
    set "DO_DEBLOAT=0"      & set "DO_INSTALL=0"  & set "DO_DEFAULTS=0"
    goto :CONFIRM
)
if "%OPT%"=="4" (
    set "DO_DISKCLEAN=0" & set "DO_OPTIMIZE=0" & set "DO_BROWSERCACHE=0"
    set "DO_INSTALL=0"   & set "DO_DEFAULTS=0"
    goto :CONFIRM
)
if "%OPT%"=="5" (
    set "DO_RESTOREPOINT=0" & set "DO_TELEMETRY=0" & set "DO_ONEDRIVE=0"
    set "DO_DEBLOAT=0"      & set "DO_PRIVACY=0"   & set "DO_BROWSERCACHE=0"
    set "DO_DISKCLEAN=0"    & set "DO_OPTIMIZE=0"  & set "DO_INSTALL=1"
    set "DO_DEFAULTS=1"
    goto :CONFIRM
)
if "%OPT%"=="6" goto :SHOWCFG
if "%OPT%"=="0" exit /b 0
goto :MENU


:SHOWCFG
cls
call :BANNER
echo   Modulos habilitados nesta execucao:
echo.
call :CFGLINE "Ponto de restauracao"        "%DO_RESTOREPOINT%"
call :CFGLINE "Telemetria desativada"       "%DO_TELEMETRY%"
call :CFGLINE "Remocao do OneDrive"         "%DO_ONEDRIVE%"
call :CFGLINE "Debloat de apps"             "%DO_DEBLOAT%"
call :CFGLINE "Instalar programas (winget)" "%DO_INSTALL%"
call :CFGLINE "Definir programas padrao"    "%DO_DEFAULTS%"
call :CFGLINE "Privacidade / rastros"       "%DO_PRIVACY%"
call :CFGLINE "Cache dos navegadores"       "%DO_BROWSERCACHE%"
call :CFGLINE "Limpeza de disco"            "%DO_DISKCLEAN%"
call :CFGLINE "DISM /ResetBase"             "%DO_DISM_RESETBASE%"
call :CFGLINE "Otimizacao do disco"         "%DO_OPTIMIZE%"
echo.
echo   Programas: %WINGET_APPS%
echo.
echo   Log desta execucao: %LOG%
echo.
pause
goto :MENU


:PICK
cls
call :BANNER
echo   Responda S ou N para cada modulo.
echo.
call :ASK "Criar ponto de restauracao antes de tudo"          DO_RESTOREPOINT
call :ASK "Desativar telemetria e tarefas de diagnostico"     DO_TELEMETRY
call :ASK "Desinstalar o OneDrive"                            DO_ONEDRIVE
call :ASK "Remover apps de consumo (Xbox, Skype, Bing...)"    DO_DEBLOAT
call :ASK "Instalar meus programas via winget"                DO_INSTALL
call :ASK "Definir WinRAR e VLC como programa padrao"         DO_DEFAULTS
call :ASK "Limpar rastros de privacidade (recentes, WER)"     DO_PRIVACY
call :ASK "Limpar cache dos navegadores (FECHA navegadores)"  DO_BROWSERCACHE
call :ASK "Limpeza de disco (temp, lixeira, Windows.old)"     DO_DISKCLEAN
call :ASK "DISM /ResetBase (libera mais espaco, irreversivel)" DO_DISM_RESETBASE
call :ASK "Otimizar / TRIM do disco do sistema"               DO_OPTIMIZE
goto :CONFIRM


:CONFIRM
cls
call :BANNER
echo   Prestes a executar os modulos selecionados neste computador.
echo.
if "%DO_BROWSERCACHE%"=="1" echo   ^> AVISO: os navegadores abertos serao FECHADOS.
if "%DO_DISM_RESETBASE%"=="1" echo   ^> AVISO: /ResetBase impede desinstalar atualizacoes antigas.
if "%DO_ONEDRIVE%"=="1" echo   ^> AVISO: arquivos ainda nao sincronizados do OneDrive serao perdidos.
echo.
set "GO="
set /p "GO=  Continuar? (S/N): "
if /i not "%GO%"=="S" goto :MENU
goto :RUN_ALL


:: ===========================================================================
::  EXECUCAO
:: ===========================================================================
:RUN_ALL
cls
call :BANNER
if "%DO_RESTOREPOINT%"=="1"  call :MOD_RESTOREPOINT
if "%DO_TELEMETRY%"=="1"     call :MOD_TELEMETRY
if "%DO_ONEDRIVE%"=="1"      call :MOD_ONEDRIVE
if "%DO_DEBLOAT%"=="1"       call :MOD_DEBLOAT
if "%DO_INSTALL%"=="1"       call :MOD_INSTALL
if "%DO_DEFAULTS%"=="1"      call :MOD_DEFAULTS
if "%DO_PRIVACY%"=="1"       call :MOD_PRIVACY
if "%DO_BROWSERCACHE%"=="1"  call :MOD_BROWSERCACHE
if "%DO_DISKCLEAN%"=="1"     call :MOD_DISKCLEAN
if "%DO_OPTIMIZE%"=="1"      call :MOD_OPTIMIZE

goto :FINISH


:: ---------------------------------------------------------------------------
:MOD_RESTOREPOINT
call :HDR "PONTO DE RESTAURACAO"
call :LOG "Habilitando protecao do sistema em %SystemDrive%"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v SystemRestorePointCreationFrequency /t REG_DWORD /d 0 /f >>"%LOG%" 2>&1
powershell -NoProfile -Command "Enable-ComputerRestore -Drive '%SystemDrive%\' -ErrorAction SilentlyContinue" >>"%LOG%" 2>&1
call :LOG "Criando ponto de restauracao (pode demorar 1-2 min)"
powershell -NoProfile -Command "Checkpoint-Computer -Description 'Windows Script Manager' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue" >>"%LOG%" 2>&1
if errorlevel 1 (
    call :WARN "Nao foi possivel criar o ponto de restauracao (protecao desligada?)"
) else (
    call :OK "Ponto de restauracao criado"
)
set /a MODULES_RUN+=1
exit /b 0


:: ---------------------------------------------------------------------------
:MOD_TELEMETRY
call :HDR "TELEMETRIA E DIAGNOSTICO"

call :LOG "AllowTelemetry = 0"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >>"%LOG%" 2>&1

call :LOG "Parando e desabilitando o servico DiagTrack"
sc stop DiagTrack >>"%LOG%" 2>&1
sc config DiagTrack start= disabled >>"%LOG%" 2>&1
sc stop dmwappushservice >>"%LOG%" 2>&1
sc config dmwappushservice start= disabled >>"%LOG%" 2>&1

call :LOG "Desativando notificacoes do Feedback do Windows"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feedback" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f >>"%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feedback" /v FeedbackFrequency /t REG_DWORD /d 0 /f >>"%LOG%" 2>&1

call :LOG "Desativando tarefas agendadas de telemetria"
for %%T in (
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Autochk\Proxy"
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
) do schtasks /Change /TN %%T /DISABLE >>"%LOG%" 2>&1

call :OK "Telemetria desativada"
set /a MODULES_RUN+=1
exit /b 0


:: ---------------------------------------------------------------------------
:MOD_ONEDRIVE
call :HDR "REMOCAO DO ONEDRIVE"

call :LOG "Encerrando processos do OneDrive"
taskkill /f /im OneDrive.exe >>"%LOG%" 2>&1

call :LOG "Desinstalando OneDrive (x64 e x86)"
if exist "%SystemRoot%\System32\OneDriveSetup.exe" "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall >>"%LOG%" 2>&1
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall >>"%LOG%" 2>&1
ping -n 4 127.0.0.1 >nul

call :LOG "Removendo pastas residuais"
rd /s /q "%UserProfile%\OneDrive"          >>"%LOG%" 2>&1
rd /s /q "%LocalAppData%\Microsoft\OneDrive" >>"%LOG%" 2>&1
rd /s /q "%ProgramData%\Microsoft OneDrive"  >>"%LOG%" 2>&1
rd /s /q "%SystemDrive%\OneDriveTemp"        >>"%LOG%" 2>&1

call :LOG "Removendo o OneDrive do painel do Explorer"
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >>"%LOG%" 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >>"%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f >>"%LOG%" 2>&1

call :OK "OneDrive removido"
set /a MODULES_RUN+=1
exit /b 0


:: ---------------------------------------------------------------------------
:MOD_DEBLOAT
call :HDR "DEBLOAT DE APPS (LISTA SEGURA)"

set "APPS=Microsoft.Xbox.TCUI Microsoft.XboxGamingOverlay Microsoft.XboxGameOverlay"
set "APPS=%APPS% Microsoft.XboxIdentityProvider Microsoft.GamingApp Microsoft.XboxApp"
set "APPS=%APPS% Microsoft.SkypeApp Microsoft.GetHelp Microsoft.Getstarted"
set "APPS=%APPS% Microsoft.MicrosoftOfficeHub Microsoft.Todos"
set "APPS=%APPS% Microsoft.ZuneMusic Microsoft.ZuneVideo Microsoft.YourPhone"
set "APPS=%APPS% Microsoft.BingNews Microsoft.BingWeather Clipchamp.Clipchamp"

set "PSLIST="
for %%A in (%APPS%) do set "PSLIST=!PSLIST!'%%A',"
if defined PSLIST set "PSLIST=!PSLIST:~0,-1!"

>>"%LOG%" echo Apps alvo: %APPS%
call :LOG "Removendo apps pre-instalados (uma unica chamada ao PowerShell)"
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$apps = @(!PSLIST!);" ^
  "foreach ($a in $apps) {" ^
  "  Write-Host ('   - ' + $a) -ForegroundColor DarkGray;" ^
  "  Get-AppxPackage -Name $a -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue;" ^
  "  Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $a } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null;" ^
  "}"
echo.

call :LOG "Desativando widgets da barra de tarefas"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >>"%LOG%" 2>&1

call :LOG "Desativando sugestoes e conteudo recomendado"
for %%V in (
    SubscribedContent-338393Enabled
    SubscribedContent-353694Enabled
    SubscribedContent-353696Enabled
    SystemPaneSuggestionsEnabled
    SilentInstalledAppsEnabled
) do reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v %%V /t REG_DWORD /d 0 /f >>"%LOG%" 2>&1

call :LOG "Desativando recomendacoes no menu Iniciar"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_IrisRecommendations /t REG_DWORD /d 0 /f >>"%LOG%" 2>&1

call :OK "Debloat concluido"
set /a MODULES_RUN+=1
exit /b 0



:: ---------------------------------------------------------------------------
:MOD_INSTALL
call :HDR "INSTALACAO DE PROGRAMAS (WINGET)"

where winget >nul 2>&1
if errorlevel 1 (
    call :WARN "winget nao encontrado neste sistema"
    call :LOG "Instale o 'Instalador de Aplicativo' (App Installer) pela Microsoft Store"
    call :LOG "e rode de novo:  windows-setup.bat  ->  opcao [5]"
    exit /b 0
)

call :LOG "Aceitando os termos das fontes do winget"
winget source update >>"%LOG%" 2>&1

>>"%LOG%" echo Programas alvo: %WINGET_APPS%
call :LOG "Instalando (pode demorar, depende da conexao)"
for %%A in (%WINGET_APPS%) do call :WINGET_ONE "%%A"

call :OK "Instalacao de programas concluida"
set /a MODULES_RUN+=1
exit /b 0


:: Instala um pacote e traduz o codigo de saida do winget.
:WINGET_ONE
set "PKG=%~1"
echo    - %PKG% ...
>>"%LOG%" echo [%time%] winget install %PKG%
winget install --exact --id "%PKG%" --silent --accept-package-agreements --accept-source-agreements --disable-interactivity >>"%LOG%" 2>&1
set "RC=%errorlevel%"
if "%RC%"=="0" (
    call :OK "%PKG% instalado"
    exit /b 0
)
:: -1978335135 = pacote ja instalado; -1978335189 = ja atualizado
if "%RC%"=="-1978335135" (
    call :OK "%PKG% ja estava instalado"
    exit /b 0
)
if "%RC%"=="-1978335189" (
    call :OK "%PKG% ja esta na versao mais recente"
    exit /b 0
)
call :WARN "%PKG% falhou (codigo %RC%) - detalhes no log"
exit /b 0


:: ---------------------------------------------------------------------------
:MOD_DEFAULTS
call :HDR "PROGRAMAS PADRAO"

:: PCT guarda um sinal de porcento literal, para montar o "%1" do comando.
set "PCT=%%"

set "WINRAR="
if exist "%ProgramFiles%\WinRAR\WinRAR.exe"      set "WINRAR=%ProgramFiles%\WinRAR\WinRAR.exe"
if not defined WINRAR if exist "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"

set "VLC="
if exist "%ProgramFiles%\VideoLAN\VLC\vlc.exe"      set "VLC=%ProgramFiles%\VideoLAN\VLC\vlc.exe"
if not defined VLC if exist "%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe" set "VLC=%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe"

if defined WINRAR (
    call :LOG "WinRAR: !WINRAR!"
    call :REGPROGID "WinRAR.Archive" "Arquivo compactado" "!WINRAR!" ""
    for %%E in (%EXT_WINRAR%) do call :SETEXT "%%E" "WinRAR.Archive"
    call :OK "WinRAR associado a: %EXT_WINRAR%"
) else (
    call :WARN "WinRAR nao encontrado - associacoes ignoradas"
)

if defined VLC (
    call :LOG "VLC: !VLC!"
    call :REGPROGID "VLC.Video" "Video" "!VLC!" "--started-from-file"
    call :REGPROGID "VLC.Audio" "Audio" "!VLC!" "--started-from-file"
    for %%E in (%EXT_VLC_VIDEO%) do call :SETEXT "%%E" "VLC.Video"
    for %%E in (%EXT_VLC_AUDIO%) do call :SETEXT "%%E" "VLC.Audio"
    call :OK "VLC associado aos formatos de video e audio"
) else (
    call :WARN "VLC nao encontrado - associacoes ignoradas"
)

call :LOG "Reiniciando o Explorer para atualizar icones e associacoes"
taskkill /f /im explorer.exe >>"%LOG%" 2>&1
:: O Windows costuma religar o shell sozinho (AutoRestartShell). So subimos
:: o Explorer na mao se ele nao voltar, para nao deixa-lo rodando elevado.
ping -n 4 127.0.0.1 >nul
tasklist /fi "IMAGENAME eq explorer.exe" | find /i "explorer.exe" >nul 2>&1
if errorlevel 1 start "" explorer.exe

echo.
echo    NOTA: o Windows 10/11 protege a escolha final do usuario com um hash
echo    em UserChoice, que nenhum script consegue gravar. O que foi feito aqui
echo    resolve num PC recem formatado; se ainda assim o Windows abrir outro
echo    programa, confirme UMA vez em:
echo      Configuracoes ^> Aplicativos ^> Aplicativos padrao ^> WinRAR / VLC
echo.
if "%AUTOMODE%"=="0" (
    set "ABRIR="
    set /p "ABRIR=  Abrir essa tela agora? (S/N): "
    if /i "!ABRIR!"=="S" start "" "ms-settings:defaultapps"
)

call :OK "Programas padrao configurados"
set /a MODULES_RUN+=1
exit /b 0


:: Cria um ProgID: %1 id, %2 nome amigavel, %3 executavel, %4 argumentos extras
:REGPROGID
set "PID=%~1"
set "EXE=%~3"
reg add "HKCR\%PID%" /ve /d "%~2" /f >>"%LOG%" 2>&1
reg add "HKCR\%PID%\DefaultIcon" /ve /d "\"%EXE%\",0" /f >>"%LOG%" 2>&1
reg add "HKCR\%PID%\shell\open\command" /ve /d "\"%EXE%\" %~4 \"%PCT%1\"" /f >>"%LOG%" 2>&1
exit /b 0


:: Aponta uma extensao para um ProgID: %1 extensao, %2 ProgID
:SETEXT
reg add "HKCR\%~1" /ve /d "%~2" /f >>"%LOG%" 2>&1
reg add "HKCR\%~1\OpenWithProgids" /v "%~2" /t REG_NONE /f >>"%LOG%" 2>&1
:: Remove a escolha anterior do usuario para a nova associacao valer
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%~1\UserChoice" /f >>"%LOG%" 2>&1
exit /b 0

:: ---------------------------------------------------------------------------
:MOD_PRIVACY
call :HDR "PRIVACIDADE E RASTROS LOCAIS"

call :LOG "Limpando itens recentes e jump lists"
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >>"%LOG%" 2>&1
rd /s /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations" >>"%LOG%" 2>&1
rd /s /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations"    >>"%LOG%" 2>&1

call :LOG "Limpando cache de miniaturas"
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*" >>"%LOG%" 2>&1

call :LOG "Limpando relatorios de erro do Windows (WER)"
rd /s /q "%LOCALAPPDATA%\Microsoft\Windows\WER\ReportQueue"   >>"%LOG%" 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Windows\WER\ReportArchive" >>"%LOG%" 2>&1
rd /s /q "%PROGRAMDATA%\Microsoft\Windows\WER\ReportQueue"    >>"%LOG%" 2>&1
rd /s /q "%PROGRAMDATA%\Microsoft\Windows\WER\ReportArchive"  >>"%LOG%" 2>&1

call :LOG "Limpando cache DNS"
ipconfig /flushdns >>"%LOG%" 2>&1

call :OK "Rastros removidos"
set /a MODULES_RUN+=1
exit /b 0


:: ---------------------------------------------------------------------------
:MOD_BROWSERCACHE
call :HDR "CACHE DOS NAVEGADORES"

call :LOG "Encerrando navegadores"
for %%P in (msedge.exe chrome.exe firefox.exe brave.exe opera.exe) do taskkill /F /IM %%P >>"%LOG%" 2>&1
ping -n 3 127.0.0.1 >nul

call :LOG "Chrome / Edge / Brave"
for %%B in (
    "%LOCALAPPDATA%\Google\Chrome\User Data"
    "%LOCALAPPDATA%\Microsoft\Edge\User Data"
    "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data"
) do (
    for /d %%P in ("%%~B\*") do (
        rd /s /q "%%~fP\Cache"                       >>"%LOG%" 2>&1
        rd /s /q "%%~fP\Code Cache"                  >>"%LOG%" 2>&1
        rd /s /q "%%~fP\GPUCache"                    >>"%LOG%" 2>&1
        rd /s /q "%%~fP\Service Worker\CacheStorage" >>"%LOG%" 2>&1
    )
)

call :LOG "Firefox"
for /d %%P in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do rd /s /q "%%~fP\cache2" >>"%LOG%" 2>&1
for /d %%P in ("%APPDATA%\Mozilla\Firefox\Profiles\*")      do rd /s /q "%%~fP\cache2" >>"%LOG%" 2>&1

call :OK "Cache dos navegadores limpo"
set /a MODULES_RUN+=1
exit /b 0


:: ---------------------------------------------------------------------------
:MOD_DISKCLEAN
call :HDR "LIMPEZA DE DISCO"
call :FREESPACE "Espaco livre antes"

call :LOG "[1/7] Temporarios do usuario"
del /f /s /q "%TEMP%\*" >>"%LOG%" 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >>"%LOG%" 2>&1

call :LOG "[2/7] Temporarios do sistema"
del /f /s /q "%SystemRoot%\Temp\*" >>"%LOG%" 2>&1
for /d %%D in ("%SystemRoot%\Temp\*") do rd /s /q "%%D" >>"%LOG%" 2>&1

call :LOG "[3/7] Lixeira"
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >>"%LOG%" 2>&1

call :LOG "[4/7] Cache do Windows Update (sera rebaixado se necessario)"
net stop wuauserv >>"%LOG%" 2>&1
net stop bits     >>"%LOG%" 2>&1
rd /s /q "%SystemRoot%\SoftwareDistribution\Download" >>"%LOG%" 2>&1
md "%SystemRoot%\SoftwareDistribution\Download"       >>"%LOG%" 2>&1

call :LOG "[5/7] Cache do Delivery Optimization"
rd /s /q "%SystemRoot%\SoftwareDistribution\DeliveryOptimization" >>"%LOG%" 2>&1
md "%SystemRoot%\SoftwareDistribution\DeliveryOptimization"       >>"%LOG%" 2>&1
net start wuauserv >>"%LOG%" 2>&1
net start bits     >>"%LOG%" 2>&1

call :LOG "[6/7] Windows.old"
if exist "%SystemDrive%\Windows.old" (
    call :LOG "      encontrado, assumindo propriedade e removendo..."
    takeown /F "%SystemDrive%\Windows.old" /R /A /D Y >>"%LOG%" 2>&1 || takeown /F "%SystemDrive%\Windows.old" /R /A /D S >>"%LOG%" 2>&1
    icacls "%SystemDrive%\Windows.old" /grant *S-1-5-32-544:F /T /C >>"%LOG%" 2>&1
    rd /s /q "%SystemDrive%\Windows.old" >>"%LOG%" 2>&1
    if exist "%SystemDrive%\Windows.old" call :WARN "Windows.old nao removido por completo (use a Limpeza de Disco do Windows)"
) else (
    call :LOG "      nao existe, nada a fazer"
)

if "%DO_DISM_RESETBASE%"=="1" (
    call :LOG "[7/7] DISM StartComponentCleanup /ResetBase (varios minutos)"
    Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase >>"%LOG%" 2>&1
) else (
    call :LOG "[7/7] DISM StartComponentCleanup (varios minutos)"
    Dism.exe /Online /Cleanup-Image /StartComponentCleanup >>"%LOG%" 2>&1
)

call :FREESPACE "Espaco livre depois"
call :OK "Limpeza de disco concluida"
set /a MODULES_RUN+=1
exit /b 0


:: ---------------------------------------------------------------------------
:MOD_OPTIMIZE
call :HDR "OTIMIZACAO DO DISCO"
call :LOG "Executando defrag /O em %SystemDrive% (TRIM em SSD, desfrag em HDD)"
defrag %SystemDrive% /O >>"%LOG%" 2>&1
call :OK "Disco otimizado"
set /a MODULES_RUN+=1
exit /b 0


:: ===========================================================================
::  FINAL
:: ===========================================================================
:FINISH
echo.
echo  ==========================================================
echo    CONCLUIDO - %MODULES_RUN% modulo(s) executado(s)
echo  ==========================================================
echo.
echo    Log completo: %LOG%
echo.
echo    Recomendado reiniciar para aplicar todas as alteracoes.
echo.

if "%AUTOMODE%"=="1" goto :EOF
if not "%ASK_REBOOT%"=="1" (
    pause
    goto :EOF
)

set "RB="
set /p "RB=  Reiniciar agora? (S/N): "
if /i "%RB%"=="S" shutdown /r /t 10 /c "Reinicio pelo Windows Script Manager"
goto :EOF


:: ===========================================================================
::  SUB-ROTINAS
:: ===========================================================================
:BANNER
echo.
echo  ==========================================================
echo    WINDOWS SCRIPT MANAGER - Pos Formatacao
echo  ==========================================================
echo.
exit /b 0

:HDR
echo.
echo  ---- %~1 ----------------------------------------
>>"%LOG%" echo.
>>"%LOG%" echo ==== %~1 ====
exit /b 0

:LOG
echo    %~1
>>"%LOG%" echo [%time%] %~1
exit /b 0

:OK
echo    [OK] %~1
>>"%LOG%" echo [%time%] OK: %~1
exit /b 0

:WARN
echo    [!!] %~1
>>"%LOG%" echo [%time%] AVISO: %~1
exit /b 0

:CFGLINE
if "%~2"=="1" (echo     [X] %~1) else (echo     [ ] %~1)
exit /b 0

:ASK
set "ANS="
set /p "ANS=   %~1? (S/N): "
if /i "!ANS!"=="S" (set "%~2=1") else (set "%~2=0")
exit /b 0

:FREESPACE
set "FREE=?"
for /f %%F in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive %SystemDrive:~0,1%).Free/1GB,2)"') do set "FREE=%%F"
call :LOG "%~1: !FREE! GB"
exit /b 0
