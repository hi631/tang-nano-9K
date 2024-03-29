@echo off

    if exist "BIOS_Next186.obj" del "BIOS_Next186.obj"
    if exist "BIOS_Next186.com" del "BIOS_Next186.com"

    c:\app2\masm32\bin\ml /AT /c /Fl BIOS_Next186.asm
    if errorlevel 1 goto errasm

    c:\app2\masm32\bin\link16 /TINY BIOS_Next186,BIOS_Next186.com,,,,
    if errorlevel 1 goto errlink

    ..\tools\bin2mi.exe BIOS_Next186.com BIOS_Next186.mi 32 2048

    dir "BIOS_Next186.*"
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
