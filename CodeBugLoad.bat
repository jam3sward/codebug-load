@echo off

REM Given the name of a codebug.cbg file, this batch file attempts
REM to automatically locate the CodeGug drive letter, then copies
REM the file directly to the CodeBug.
REM James Ward
REM 25/11/15
REM Version 1.0

setlocal ENABLEDELAYEDEXPANSION

REM This is the filename to be transferred to the CodeBug
set payload=%1

REM Check that we were given a filename
if "%payload%"=="" (
  echo Please supply a filename
  goto exit
)

REM Check that the supplied file exists
if not exist %payload% (
  echo Can't find file %payload%
  goto exit
)

REM Get filename extension
for %%f in (%payload%) do set extension=%%~xf

REM Check filename extension
if not %extension%==.cbg (
  echo Filename should have .cbg extension
  goto exit
)

REM Generate temporary file name
set tempfile=%temp%\CBG%random%.TMP

REM Now we have to find the CodeBug, so we can transfer
REM the file onto it

REM Get a list of all the logical disks including name and volumename
REM for example: E: CodeBug
REM The more command is needed to convert the unicode output of wmic
REM to plain text that we can process with for
wmic logicaldisk get name,volumename |more >%tempfile%

REM Find out which one has volume name CodeBug
set codebug=""
for /f "tokens=1,2 skip=1" %%i in (%tempfile%) do (
  if %%j==CodeBug set codebug=%%i
)

REM Delete temporary file
del %tempfile%

REM If we have CodeBug drive letter
if not %codebug%=="" (
  REM Check that the README.HTM file exists on that drive
  if exist %codebug%\README.HTM (
    REM This looks like a real CodeBug, let's transfer the file
    echo CodeBug drive letter is %codebug%
    echo Copying %payload% to %codebug%
    copy %payload% %codebug% >nul
  ) else (
    echo Found what looked like a CodeBug drive letter, but it
    echo didn't seem to contain the usual README.HTM file, so
    echo the file wasn't copied
  )
) else (
  echo Didn't find the CodeBug: is it connected and in
  echo programming mode?
)

:exit