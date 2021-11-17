@REM ----------------------------------------------------------------------------
@REM Copyright 2012 Red Hat, Inc. and/or its affiliates.
@REM
@REM Licensed under the Eclipse Public License version 1.0, available at
@REM http://www.eclipse.org/legal/epl-v10.html
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM MTA Startup script
@REM
@REM Required Environment vars:
@REM ------------------
@REM JAVA_HOME - location of a JRE home dir
@REM
@REM Optional Environment vars
@REM ------------------
@REM MTA_HOME - location of MTA's installed home dir
@REM MTA_OPTS - parameters passed to the Java VM when running MTA
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
if not "%MTA_HOME%" == "" set MTA_HOME=%MTA_HOME:"=%
if not "%JAVA_HOME%" == "" set JAVA_HOME=%JAVA_HOME:"=%

@REM Execute a user defined script before this one
if exist "%USERHOME%\mtarc_pre.bat" call "%USERHOME%\mtarc_pre.bat"

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
   set JAVAVER_MAJOR=%%v
   set JAVAVER_MINOR=%%w
)
set "JAVAVER_MAJOR=%JAVAVER_MAJOR:~1,2%"
set MODULES=
if %JAVAVER_MAJOR% geq 11 (
    echo TECH PREVIEW Running on JDK %JAVAVER%
    SET MODULES="--add-modules=java.se"
    goto chkFHome
)
if %JAVAVER_MINOR% geq 8 goto chkFHome

echo.
echo A Java 1.8 or higher JRE is required to run MTA. "%JAVA_HOME%\bin\java.exe" is version %JAVAVER%
echo.
goto error

:chkFHome

if "%OS%"=="Windows_NT" SET "SCRIPT_HOME=%~dp0.."
if "%OS%"=="WINNT" SET "SCRIPT_HOME=%~dp0.."

if exist "%SCRIPT_HOME%\mta-cli-version.txt" set "MTA_HOME=%SCRIPT_HOME%"

if not "%MTA_HOME%"=="" goto valFHome

if "%OS%"=="Windows_NT" SET "MTA_HOME=%~dp0.."
if "%OS%"=="WINNT" SET "MTA_HOME=%~dp0.."
if not "%MTA_HOME%"=="" goto valFHome

echo.
echo ERROR: MTA_HOME not found in your environment.
echo Please set the MTA_HOME variable in your environment to match the
echo location of the MTA installation
echo.
goto error

:valFHome

:stripFHome
if not "_%MTA_HOME:~-1%"=="_\" goto checkFBat
set "MTA_HOME=%MTA_HOME:~0,-1%"
goto stripFHome

:checkFBat
if exist "%MTA_HOME%\bin\mta-cli.bat" goto init

echo.
echo ERROR: MTA_HOME is set to an invalid directory.
echo MTA_HOME = "%MTA_HOME%"
echo Please set the MTA_HOME variable in your environment to match the
echo location of the MTA installation
echo.
goto error
@REM ==== END VALIDATION ====

@REM Initializing the argument line
:init
setlocal enableextensions enableDelayedExpansion
set MTA_CMD_LINE_ARGS=
set MTA_DEBUG_ARGS=
set OR_CMD_LINE_ARGS=
set RUN_OPENREWRITE=false
set OR_GOAL=dryRun

if "%1"=="" goto initArgs

set "args=%*"
set "args=%args:,=:comma:%"
set "args=%args:;=:semicolon:%"

set C=0

for %%x in (%args%) do (
    set "arg=%%~x"
    set "arg=!arg::comma:=,!"
    set "arg=!arg::semicolon:=;!"
    set "argElement[!C!]=!arg!"
    set /A C=!C! + 1
)

set COUNT=0

for %%x in (%args%) do (
    set OR_REMOVE_ARG=false
    set "arg=%%~x"
    set "arg=!arg::comma:=,!"
    set "arg=!arg::semicolon:=;!"
    if "!arg!"=="--debug" set MTA_DEBUG_ARGS=-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000
    if "!arg!"=="--input" (
        set "OR_REMOVE_ARG=true"
	set /A y=!COUNT! + 1
        call set OR_TRANSFORM_PATH=%%argElement[!y!]%%
    )
    if "!arg!"=="!OR_TRANSFORM_PATH!" (
        set "OR_REMOVE_ARG=true"
    )
    if "!arg!"=="--openrewrite" (
        set "OR_REMOVE_ARG=true"
        set RUN_OPENREWRITE=true
    )
    if "!arg!"=="--goal" (
        set "OR_REMOVE_ARG=true"
	set /A z=!COUNT! + 1	
        call set OR_GOAL=%%argElement[!z!]%%
    )
    if "!arg!"=="!OR_GOAL!" (
        set "OR_REMOVE_ARG=true"
    )

    if !OR_REMOVE_ARG!==false set "OR_CMD_LINE_ARGS=!OR_CMD_LINE_ARGS! "!arg!""
    set "MTA_CMD_LINE_ARGS=!MTA_CMD_LINE_ARGS! "!arg!""
    set /A COUNT=!COUNT! + 1
)

:initArgs
setlocal enableextensions enabledelayedexpansion
if %1a==a goto endInit

shift
goto initArgs
@REM Reaching here means variables are defined and arguments have been captured
:endInit

SET MTA_JAVA_EXE="%JAVA_HOME%\bin\java.exe"

@REM -- 4NT shell
if "%@eval[2+2]" == "4" goto 4NTCWJars

if %RUN_OPENREWRITE%==false goto runMTA_CLI

:runOpenrewrite
PUSHD "%OR_TRANSFORM_PATH%"
mvn "org.openrewrite.maven:rewrite-maven-plugin:4.13.0:%OR_GOAL%" "-Drewrite.configLocation=%MTA_HOME%\rules\openrewrite\rewrite.yml" %OR_CMD_LINE_ARGS%
POPD

if ERRORLEVEL 1 goto error
goto end

@REM Start MTA
:runMTA_CLI

echo Using MTA at %MTA_HOME%
echo Using Java at %JAVA_HOME%

if exist "%MTA_HOME%\addons" set ADDONS_DIR=--immutableAddonDir "%MTA_HOME%\addons"
set MTA_MAIN_CLASS=org.jboss.windup.bootstrap.Bootstrap

@REM MAX_MEMORY - Maximum Java Heap (example: 2048m)
@REM MAX_METASPACE_SIZE - Maximum Metaspace size (example: 256m)
@REM RESERVED_CODE_CACHE_SIZE - Hotspot code cache size (example: 128m)
if "%MAX_METASPACE_SIZE%" == "" (
  set MTA_MAX_METASPACE_SIZE=256m
) else (
  set MTA_MAX_METASPACE_SIZE=%MAX_METASPACE_SIZE%
)

if "%RESERVED_CODE_CACHE_SIZE%" == "" (
  set MTA_RESERVED_CODE_CACHE_SIZE=128m
) else (
  set MTA_RESERVED_CODE_CACHE_SIZE=%RESERVED_CODE_CACHE_SIZE%
)

if "%MTA_OPTS%" == "" (
  if "%MAX_MEMORY%" == "" (
    set MTA_OPTS_INTERNAL=-XX:MaxMetaspaceSize=%MTA_MAX_METASPACE_SIZE% -XX:ReservedCodeCacheSize=128m
  ) else (
    set MTA_OPTS_INTERNAL=-Xmx%MAX_MEMORY% -XX:MaxMetaspaceSize=%MTA_MAX_METASPACE_SIZE% -XX:ReservedCodeCacheSize=128m
  )
) else (
  set MTA_OPTS_INTERNAL=%MTA_OPTS%
)

%MTA_JAVA_EXE% %MODULES% %MTA_DEBUG_ARGS% %MTA_OPTS_INTERNAL% "-Dforge.standalone=true" "-Dforge.home=%MTA_HOME%" "-Dwindup.home=%MTA_HOME%" ^
   -cp ".;%MTA_HOME%\lib\*" %MTA_MAIN_CLASS% %MTA_CMD_LINE_ARGS% %ADDONS_DIR%
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
set MTA_JAVA_EXE=
set MTA_CMD_LINE_ARGS=
set MTA_OPTS_INTERNAL=
set MTA_MAX_METASPACE_SIZE=
set MTA_RESERVED_CODE_CACHE_SIZE=
goto postExec

:endNT
@endlocal & set ERROR_CODE=%ERROR_CODE%

:postExec
if exist "%USERHOME%\mtarc_post.bat" call "%USERHOME%\mtarc_post.bat"

if "%MTA_TERMINATE_CMD%" == "on" exit %ERROR_CODE%

cmd /C exit /B %ERROR_CODE%