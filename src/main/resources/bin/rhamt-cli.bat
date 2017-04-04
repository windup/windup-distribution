@REM ----------------------------------------------------------------------------
@REM Copyright 2012 Red Hat, Inc. and/or its affiliates.
@REM
@REM Licensed under the Eclipse Public License version 1.0, available at
@REM http://www.eclipse.org/legal/epl-v10.html
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM RHAMT Startup script
@REM
@REM Required Environment vars:
@REM ------------------
@REM JAVA_HOME - location of a JRE home dir
@REM
@REM Optional Environment vars
@REM ------------------
@REM RHAMT_HOME - location of RHAMT's installed home dir
@REM RHAMT_OPTS - parameters passed to the Java VM when running RHAMT
@REM MAX_MEMORY - Maximum Java Heap (example: 2048m)
@REM MAX_METASPACE_SIZE - Maximum Metaspace size (example: 256m)
@REM RESERVED_CODE_CACHE_SIZE - Hotspot code cache size (example: 128m)
@REM ----------------------------------------------------------------------------

@echo off

set ADDON_DIR=

@REM set %USERHOME% to equivalent of $HOME
if not "%USERHOME%" == "" goto OkUserhome
set "USERHOME=%USERPROFILE%"

if not "%USERHOME%" == "" goto OkUserhome
set "USERHOME=%HOMEDRIVE%%HOMEPATH%"

:OkUserhome

@REM Remove extraneous quotes from variables
if not "%RHAMT_HOME%" == "" set RHAMT_HOME=%RHAMT_HOME:"=%
if not "%JAVA_HOME%" == "" set JAVA_HOME=%JAVA_HOME:"=%

@REM Execute a user defined script before this one
if exist "%USERHOME%\winduprc_pre.bat" call "%USERHOME%\winduprc_pre.bat"

set ERROR_CODE=0

@REM set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" @setlocal
if "%OS%"=="WINNT" @setlocal

@REM ==== START VALIDATION ====
if not "%JAVA_HOME%" == "" goto OkJHome

@REM Try to infer the JAVA_HOME location from the registry
FOR /F "skip=2 tokens=2*" %%A IN ('REG QUERY "HKLM\Software\JavaSoft\Java Runtime Environment" /v CurrentVersion') DO set CurVer=%%B

FOR /F "skip=2 tokens=2*" %%A IN ('REG QUERY "HKLM\Software\JavaSoft\Java Runtime Environment\%CurVer%" /v JavaHome') DO set JAVA_HOME=%%B

if not "%JAVA_HOME%" == "" goto OkJHome

echo.
echo ERROR: JAVA_HOME not found in your environment.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation
echo.
goto error

:OkJHome
if exist "%JAVA_HOME%\bin\java.exe" goto chkJVersion

echo.
echo ERROR: JAVA_HOME is set to an invalid directory.
echo JAVA_HOME = "%JAVA_HOME%"
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation
echo.
goto error

:chkJVersion
set PATH="%JAVA_HOME%\bin";%PATH%

for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
   set JAVAVER=%%g
)
for /f "delims=. tokens=1-3" %%v in ("%JAVAVER%") do (
   set JAVAVER_MINOR=%%w
)

if %JAVAVER_MINOR% geq 8 goto chkFHome

echo.
echo A Java 1.8 or higher JRE is required to run RHAMT. "%JAVA_HOME%\bin\java.exe" is version %JAVAVER%
echo.
goto error

:chkFHome

if "%OS%"=="Windows_NT" SET "SCRIPT_HOME=%~dp0.."
if "%OS%"=="WINNT" SET "SCRIPT_HOME=%~dp0.."

if exist "%SCRIPT_HOME%\rhamt-cli-version.txt" set "RHAMT_HOME=%SCRIPT_HOME%"

if not "%RHAMT_HOME%"=="" goto valFHome

if "%OS%"=="Windows_NT" SET "RHAMT_HOME=%~dp0.."
if "%OS%"=="WINNT" SET "RHAMT_HOME=%~dp0.."
if not "%RHAMT_HOME%"=="" goto valFHome

echo.
echo ERROR: RHAMT_HOME not found in your environment.
echo Please set the RHAMT_HOME variable in your environment to match the
echo location of the RHAMT installation
echo.
goto error

:valFHome

:stripFHome
if not "_%RHAMT_HOME:~-1%"=="_\" goto checkFBat
set "RHAMT_HOME=%RHAMT_HOME:~0,-1%"
goto stripFHome

:checkFBat
if exist "%RHAMT_HOME%\bin\rhamt-cli.bat" goto init

echo.
echo ERROR: RHAMT_HOME is set to an invalid directory.
echo RHAMT_HOME = "%RHAMT_HOME%"
echo Please set the RHAMT_HOME variable in your environment to match the
echo location of the RHAMT installation
echo.
goto error
@REM ==== END VALIDATION ====

@REM Initializing the argument line
:init
setlocal enableextensions enabledelayedexpansion
set RHAMT_CMD_LINE_ARGS=
set RHAMT_DEBUG_ARGS=

if "%1"=="" goto initArgs

set "args=%*"
set "args=%args:,=:comma:%"
set "args=%args:;=:semicolon:%"

for %%x in (%args%) do (
    set "arg=%%~x"
    set "arg=!arg::comma:=,!"
    set "arg=!arg::semicolon:=;!"
    if "!arg!"=="--debug" set RHAMT_DEBUG_ARGS=-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000
    set "RHAMT_CMD_LINE_ARGS=!RHAMT_CMD_LINE_ARGS! "!arg!""
)

:initArgs
setlocal enableextensions enabledelayedexpansion
if %1a==a goto endInit

shift
goto initArgs
@REM Reaching here means variables are defined and arguments have been captured
:endInit

SET RHAMT_JAVA_EXE="%JAVA_HOME%\bin\java.exe"

@REM -- 4NT shell
if "%@eval[2+2]" == "4" goto 4NTCWJars

goto runRHAMT_CLI

@REM Start RHAMT
:runRHAMT_CLI

echo Using RHAMT at %RHAMT_HOME%
echo Using Java at %JAVA_HOME%

if exist "%RHAMT_HOME%\addons" set ADDONS_DIR=--immutableAddonDir "%RHAMT_HOME%\addons"
set RHAMT_MAIN_CLASS=org.jboss.windup.bootstrap.Bootstrap

@REM MAX_MEMORY - Maximum Java Heap (example: 2048m)
@REM MAX_METASPACE_SIZE - Maximum Metaspace size (example: 256m)
@REM RESERVED_CODE_CACHE_SIZE - Hotspot code cache size (example: 128m)
if "%MAX_METASPACE_SIZE%" == "" (
  set RHAMT_MAX_METASPACE_SIZE=256m
) else (
  set RHAMT_MAX_METASPACE_SIZE=%MAX_METASPACE_SIZE%
)

if "%RESERVED_CODE_CACHE_SIZE%" == "" (
  set RHAMT_RESERVED_CODE_CACHE_SIZE=128m
) else (
  set RHAMT_RESERVED_CODE_CACHE_SIZE=%RESERVED_CODE_CACHE_SIZE%
)

if "%RHAMT_OPTS%" == "" (
  if "%MAX_MEMORY%" == "" (
    set RHAMT_OPTS_INTERNAL=-XX:MaxMetaspaceSize=%RHAMT_MAX_METASPACE_SIZE% -XX:ReservedCodeCacheSize=128m
  ) else (
    set RHAMT_OPTS_INTERNAL=-Xmx%MAX_MEMORY% -XX:MaxMetaspaceSize=%RHAMT_MAX_METASPACE_SIZE% -XX:ReservedCodeCacheSize=128m
  )
) else (
  set RHAMT_OPTS_INTERNAL=%RHAMT_OPTS%
)

%RHAMT_JAVA_EXE% %RHAMT_DEBUG_ARGS% %RHAMT_OPTS_INTERNAL% "-Dforge.standalone=true" "-Dforge.home=%RHAMT_HOME%" "-Dwindup.home=%RHAMT_HOME%" ^
   -cp ".;%RHAMT_HOME%\lib\*" %RHAMT_MAIN_CLASS% %RHAMT_CMD_LINE_ARGS% %ADDONS_DIR%
if ERRORLEVEL 1 goto error
goto end

:error
if "%OS%"=="Windows_NT" @endlocal
if "%OS%"=="WINNT" @endlocal
set ERROR_CODE=1

:end
@REM set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" goto endNT
if "%OS%"=="WINNT" goto endNT

@REM For old DOS remove the set variables from ENV - we assume they were not set
@REM before we started - at least we don't leave any baggage around
set RHAMT_JAVA_EXE=
set RHAMT_CMD_LINE_ARGS=
set RHAMT_OPTS_INTERNAL=
set RHAMT_MAX_METASPACE_SIZE=
set RHAMT_RESERVED_CODE_CACHE_SIZE=
goto postExec

:endNT
@endlocal & set ERROR_CODE=%ERROR_CODE%

:postExec
if exist "%USERHOME%\winduprc_post.bat" call "%USERHOME%\winduprc_post.bat"

if "%RHAMT_TERMINATE_CMD%" == "on" exit %ERROR_CODE%

cmd /C exit /B %ERROR_CODE%
