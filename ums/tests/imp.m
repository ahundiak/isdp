SOURCE
main.c

EXEC
test_ums

LINKLIB
-lm -lc -lsocket -ldl -lnsl -R /usr/local/lib -L /usr/local/lib -lglib-2.0
$UMS/lib/ums.o

INCLUDE
/usr/local/include
$UMS/include



