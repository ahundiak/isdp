COPT
#ifdef NT

#ifdef _DEBUG
-W3 -Zp8 -Gd -nologo -Od -Zi -MTd
#else /* _DEBUG */
-W3 -Zp8 -Gd -nologo -O2
#endif /* _DEBUG */

#else /* NT */
-DBASE_EMS
#endif /* NT */

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
TARGET
$(TARGET)/om/opp/tools/kstr
$(TARGET)/om/opp/tools/kgrover
#elif defined(NT)
TARGET
$(TARGET)/om/opp/tools/kstr.exe
$(TARGET)/om/opp/tools/kgrover.exe
#endif

SRC
$(EXNUC)/om/opp/tools

SOURCE=kstrsrc
kstr.c

EXEC=kstrsrc
$(TARGET)/om/opp/tools/kstr

SOURCE=kgroversrc
kgrover.c

EXEC=kgroversrc
$(TARGET)/om/opp/tools/kgrover
