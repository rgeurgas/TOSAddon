@ECHO OFF

IF [%1]==[] GOTO Usage
IF [%2]==[] GOTO Usage
GOTO Copy

:Usage
ECHO Using this script: "build.cmd <addon> <version>"
EXIT /B 1

:Copy
ECHO. & ECHO Copying addon files to a temporary folder...
ROBOCOPY /s /e %1\src build\.tmp > NUL

:Create
ECHO. & ECHO Creating IPF...
python build\.tools\ipf.py --enable-encryption --overwrite -vcf build\%1-v%2.ipf build\.tmp

:Clean
ECHO. & ECHO Deleting temporary folder...
RMDIR /s /q build\.tmp
