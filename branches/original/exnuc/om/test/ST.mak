CFLAGS = -g -ga -I./libx
OMLIB = libOMg.o
OTHERLIB = -lix
OMTswapTime.x:	OMTswapTime.o STmaster.o STmasteri.o \
		STgene.o STgenei.o \
		STa.o STai.o \
		STb.o STbi.o \
		STc.o STci.o \
		STd.o STdi.o \
		OMTswapTimez.o \
		$(OMLIB)
	$(CC) $(CFLAGS) -o OMTswapTime.x \
		OMTswapTime.o STmaster.o STmasteri.o \
		STgene.o STgenei.o \
		STa.o STai.o \
		STb.o STbi.o \
		STc.o STci.o \
		STd.o STdi.o \
		OMTswapTimez.o \
		$(OMLIB) -lxc -lm -lmalloc -lg $(OTHERLIB)


STgrabSlots:	STgrabSlots.o $(OMLIB)
		cc $(CFLAGS) -o STgrabSlots STgrabSlots.o \
		$(OMLIB) -lxc -lm -lmalloc -lg $(OTHERLIB)

STgrabSlots.o:	STgrabSlots.C
	omcpp -l STgrabSlots.C STgrabSlots.c
	cc $(CFLAGS) -c STgrabSlots.c

OMTswapTime.o: OMTswapTime.C
	omcpp -l OMTswapTime.C OMTswapTime.c
	cc $(CFLAGS) -c OMTswapTime.c

OMTswapTimez.o: STa.S STb.S STc.S STd.S
	opl -o OMTswapTimez.c STmaster.o STgene.o STa.o STb.o STc.o STd.o
	$(CC) $(CFLAGS) -c OMTswapTimez.c

STmaster.o: STmaster.S
	opp -l STmaster.S
	$(CC) $(CFLAGS) -c STmaster.c

STmasteri.o: STmasteri.I
	opp -l STmasteri.I
	$(CC) $(CFLAGS) -c STmasteri.c

STgene.o: STgene.S        
	opp -l STgene.S 
	$(CC) $(CFLAGS) -c STgene.c

STgenei.o: STgenei.I       
	opp -l STgenei.I
	$(CC) $(CFLAGS) -c STgenei.c

STa.o: STa.S
	opp -l STa.S
	$(CC) $(CFLAGS) -c STa.c

STai.o: STai.I          
	opp -l STai.I
	$(CC) $(CFLAGS) -c STai.c 

STb.o: STb.S           
	opp -l STb.S
	$(CC) $(CFLAGS) -c STb.c 

STbi.o: STbi.I          
	opp -l STbi.I
	$(CC) $(CFLAGS) -c STbi.c 

STc.o: STc.S           
	opp -l STc.S
	$(CC) $(CFLAGS) -c STc.c 

STci.o: STci.I          
	opp -l STci.I
	$(CC) $(CFLAGS) -c STci.c 

STd.o: STd.S           
	opp -l STd.S
	$(CC) $(CFLAGS) -c STd.c 

STdi.o: STdi.I          
	opp -l STdi.I
	$(CC) $(CFLAGS) -c STdi.c
