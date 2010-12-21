SOURCE
main.c
ftp.c
        
EXEC
aimx

LINKLIB
-lm -lc -lsocket -ldl -lnsl
-L /usr/local/lib -R /usr/local/lib
-lglib-2.0 -lgobject-2.0 -lgio-2.0

INCLUDE
/usr/local/include/glib-2.0
/usr/local/lib/glib-2.0/include
ls

