@echo off
rem Do not alter this SPC information: $Revision: 1.1.42.1 $
rem This program is used to check if a files/directory exists. It requires
rem no editing by the user.
rem
rem
@if not exist %1 set _ERROR=1
