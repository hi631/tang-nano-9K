@echo off

    if exist "bootstrap.obj" del "bootstrap.obj"
    if exist "bootstrap.com" del "bootstrap.com"
    if exist "bootstrap.mi" del "bootstrap.mi"

    c:\app2\masm32\bin\ml /AT /c /Fl bootstrap.asm
    if errorlevel 1 goto errasm

    c:\app2\masm32\bin\link16 /TINY bootstrap,bootstrap.com,,,,
    if errorlevel 1 goto errlink

    ..\tools\bin2mi.exe bootstrap.com bootstrap.mi 32 1024

    dir "bootstrap.*"
    goto TheEnd

  :errlink
    echo _
    echo Link error
    goto TheEnd

  :errasm
    echo _
    echo Assembly Error
    goto TheEnd
    
  :TheEnd

timeout 5
