clhtodat : NFMcvtmain.o PDMsuntools.o suncvt.o
	acc -o ../binc100/clhtodat NFMcvtmain.o PDMsuntools.o suncvt.o
	chmod +s ../binc100/clhtodat
	ls -ls ../binc100/clhtodat

NFMcvtmain.o : NFMcvtmain.c
	acc -c NFMcvtmain.c

PDMsuntools.o : PDMsuntools.c
	acc -c PDMsuntools.c

suncvt.o : suncvt.c ../include/NFMenv.h
	acc -c -I../include suncvt.c
