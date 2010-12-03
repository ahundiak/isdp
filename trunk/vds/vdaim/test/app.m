SOURCE
main.c

EXEC
aim

LINKLIB
-lm -lc -lsocket -ldl -lnsl
-L /opt/ingr/lib -R /opt/ingr/lib
-lxml2 -lxslt -lz -lglib -lgtk -lgdk
$VDS/lib/vdiaimimp.o

INCLUDE
$VDS/include

