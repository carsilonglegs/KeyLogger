install the compile module
Install-Module -Name ps2exe -Scope CurrentUser

Key parts for compilations for execution .exe:
   1. set a bypass command so powershell system block isnt raised: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
    2. Import-Module ps2exe : ps2exe -inputFile "PATH\TO\LOGGER.PS1" -outputFile "PATH\TO\LOGGER.EXE" -noConsole
