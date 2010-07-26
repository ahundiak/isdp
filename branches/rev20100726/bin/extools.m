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

SRC
$(EXNUC)\bin

TARGET
$(TARGET)\bin\execho.exe
$(TARGET)\bin\tee.exe
$(TARGET)\lib\exnt.lib

SOURCE=execho
execho.c

EXEC=execho
$(TARGET)\bin\execho.exe

SOURCE=tee
tee.c

EXEC=tee
$(TARGET)\bin\tee.exe

SOURCE=exnt
getopt.c
env.c

ARCHIVE=exnt
$(TARGET)\lib\exnt.lib
