@echo off
rem Do not alter this SPC information: $Revision: 1.4.39.1 $
rem This program is used to set the environment variables that the
rem RIS re-packaging procedure needs. It is intended to be edited by the user.
rem
rem

rem =====================================================
rem General variables
rem =====================================================
rem Enter the main directory where the localized files will be in
set _LOCAL_DIR=c:\locin

rem Enter the main directory where the localized files will be backed-up to
set _BU_DIR=c:\locbu

rem Enter the main directory where the last localized files will be copied
set _OLD_DIR=c:\locprev



rem Remove the comment (rem ) for the language you are localizing so the line
rem begins with set
set _LANG=english
rem arabic              set _LANG=arabic
rem albanian            set _LANG=albanian
rem australian english  set _LANG=english.aus
rem bahasa              set _LANG=bahasa
rem belgian dutch       set _LANG=dutch.blg
rem belgian french      set _LANG=french.blg
rem brazilian portugueseset _LANG=portugue.brz
rem bulgarian           set _LANG=bulgaria
rem canadian english    set _LANG=english.can
rem canadian french     set _LANG=french.can
rem catalan             set _LANG=catalan
rem chinese             set _LANG=chinese
rem croata serbian      set _LANG=croata
rem czech               set _LANG=czech
rem danish              set _LANG=danish
rem dutch               set _LANG=dutch
rem finnish             set _LANG=finnish
rem french              set _LANG=french
rem german              set _LANG=german
rem hebrew              set _LANG=hebrew
rem hungarian           set _LANG=hungarian
rem icelandic           set _LANG=icelandic
rem italian             set _LANG=italian
rem japanese            set _LANG=japanese
rem korean              set _LANG=korean
rem mexican spanish     set _LANG=spanish.mex
rem norwegian bokmal    set _LANG=norwegia.bkm
rem norwegian nynorsk   set _LANG=norwegia.nyn
rem polish              set _LANG=polish
rem portuguese          set _LANG=portugue
rem rhaeto romanic      set _LANG=rhaeto.rom
rem romanian            set _LANG=romanian
rem russian             set _LANG=russian
rem serbo croatian      set _LANG=serbo
rem slovak              set _LANG=slovak
rem spanish             set _LANG=spanish
rem swedish             set _LANG=swedish
rem swiss german        set _LANG=german.sws
rem swiss french        set _LANG=french.sws
rem swiss italian       set _LANG=italian.sws
rem thai                set _LANG=thai
rem traditional chinese set _LANG=chinese.smp
rem turkish             set _LANG=turkish
rem uk english          set _LANG=english.uk
rem urdu                set _LANG=urdu


rem =====================================================
rem RIS variables
rem =====================================================
rem Enter the RIS product output directory that will be created
set _RIS_OUTPUT_DIR=c:\locris


rem =====================================================
rem RISDP variables
rem =====================================================
rem Enter the RISDP product output directory that will be created
set _RISDP_OUTPUT_DIR=c:\locrisdp


rem =====================================================
rem RIS ORACLE variables
rem =====================================================
rem Enter the Oracle Product output directory that will be created
set _RISORADS_OUTPUT_DIR=c:\locora


rem =====================================================
rem RIS ORACLE NET variables
rem =====================================================
rem Enter the ORACLE NET Product output directory that will be created
set _RISORANS_OUTPUT_DIR=c:\locoran


rem =====================================================
rem RIS SYBASE variables
rem =====================================================
rem Enter the Sybase Product output directory that will be created
set _RISSYBDS_OUTPUT_DIR=c:\locsyb


rem =====================================================
rem RIS DB2 variables
rem =====================================================
rem Enter the DB2 Product output directory that will be created
set _RISDB2DS_OUTPUT_DIR=c:\locdb2


rem =====================================================
rem RIS INGRES variables
rem =====================================================
rem Enter the INGRES Product output directory that will be created
set _RISINGDS_OUTPUT_DIR=c:\locing


rem =====================================================
rem RIS MS SQL variables
rem =====================================================
rem Enter the MS SQL Product output directory that will be created
set _RISMSFDS_OUTPUT_DIR=c:\locmsf


rem =====================================================
rem RIS INFORMIX variables
rem =====================================================
rem Enter the INFORMIX Product output directory that will be created
set _RISINFDS_OUTPUT_DIR=c:\locinf


rem =====================================================
rem RIS INFORMIX NET variables
rem =====================================================
rem Enter the INFORMIX NET Product output directory that will be created
set _RISINFNS_OUTPUT_DIR=c:\locinfn



call setdef
