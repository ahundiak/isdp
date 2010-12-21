SOURCE
main.c

EXEC
aim

LINKLIB
-lm -lc -lsocket -ldl -lnsl
-L /opt/ingr/lib -R /opt/ingr/lib
-lxml2 -lxslt -lz -lglib -lgtk -lgdk
$VDS/vdaim/imp/VDPaimPostInt.o
$VDS/vdaim/imp/VDPaimPostMan.o
$VDS/vdaim/imp/VDPaimUtil.o

INCLUDE
$VDS/include

