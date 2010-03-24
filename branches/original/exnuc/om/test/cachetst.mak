#
# Portion of makefile and dependencies needed for the two
# cached channel send tests.
#
tsti.o:		tst.o
tst0i.o:	tst0.o
tst10i.o:	tst10.o
tst11i.o:	tst11.o
tst12i.o:	tst12.o
tst13i.o:	tst13.o
tst14i.o:	tst14.o
tst15i.o:	tst15.o
tst16i.o:	tst16.o
tst17i.o:	tst17.o
tst18i.o:	tst18.o
tst19i.o:	tst19.o
tst1i.o:	tst1.o
tst20i.o:	tst20.o
tst21i.o:	tst21.o
tst22i.o:	tst22.o
tst23i.o:	tst23.o
tst24i.o:	tst24.o
tst25i.o:	tst25.o
tst26i.o:	tst26.o
tst27i.o:	tst27.o
tst28i.o:	tst28.o
tst29i.o:	tst29.o
tst2i.o:	tst2.o
tst30i.o:	tst30.o
tst31i.o:	tst31.o
tst32i.o:	tst32.o
tst33i.o:	tst33.o
tst34i.o:	tst34.o
tst35i.o:	tst35.o
tst36i.o:	tst36.o
tst37i.o:	tst37.o
tst38i.o:	tst38.o
tst39i.o:	tst39.o
tst3i.o:	tst3.o
tst40i.o:	tst40.o
tst41i.o:	tst41.o
tst42i.o:	tst42.o
tst43i.o:	tst43.o
tst44i.o:	tst44.o
tst45i.o:	tst45.o
tst46i.o:	tst46.o
tst47i.o:	tst47.o
tst48i.o:	tst48.o
tst49i.o:	tst49.o
tst4i.o:	tst4.o
tst50i.o:	tst50.o
tst51i.o:	tst51.o
tst52i.o:	tst52.o
tst53i.o:	tst53.o
tst54i.o:	tst54.o
tst55i.o:	tst55.o
tst56i.o:	tst56.o
tst57i.o:	tst57.o
tst58i.o:	tst58.o
tst59i.o:	tst59.o
tst5i.o:	tst5.o
tst60i.o:	tst60.o
tst61i.o:	tst61.o
tst62i.o:	tst62.o
tst63i.o:	tst63.o
tst64i.o:	tst64.o
tst65i.o:	tst65.o
tst66i.o:	tst66.o
tst67i.o:	tst67.o
tst68i.o:	tst68.o
tst69i.o:	tst69.o
tst6i.o:	tst6.o
tst70i.o:	tst70.o
tst71i.o:	tst71.o
tst72i.o:	tst72.o
tst73i.o:	tst73.o
tst74i.o:	tst74.o
tst7i.o:	tst7.o
tst8i.o:	tst8.o
tst9i.o:	tst9.o

CACHESOBJS=	tst0.o   tst1.o   tst10.o  tst11.o  tst12.o  tst13.o \
		tst14.o tst15.o tst16.o  tst17.o  tst18.o  tst19.o \
		tst2.o   tst20.o  tst21.o tst22.o tst23.o  tst24.o \
		tst25.o  tst26.o  tst27.o  tst28.o  tst29.o  tst3.o \
		tst30.o  tst31.o  tst32.o  tst33.o  tst34.o  tst35.o \
		tst36.o tst37.o tst38.o  tst39.o  tst4.o  tst40.o \
		tst41.o  tst42.o  tst43.o tst44.o tst45.o  tst46.o \
		tst47.o  tst48.o  tst49.o  tst5.o   tst50.o tst51.o \
		tst52.o  tst53.o  tst54.o  tst55.o  tst56.o  tst57.o \
		tst58.o tst59.o tst6.o tst60.o tst61.o tst62.o tst63.o \
		tst64.o  tst65.o tst66.o tst67.o  tst68.o  tst69.o \
		tst7.o  tst70.o  tst71.o  tst72.o tst73.o tst74.o \
		tst8.o tst9.o tst.o

CACHEIOBJS=	$(CACHESOBJS:.o=i.o)

#******************************************************************************
# OMTcache
#******************************************************************************

cacheOBJS=	OMTcache.o $(CACHESOBJS) $(CACHEIOBJS)

OMTcache.x::	$(cacheOBJS) $(OMTOBJS)   $(OMSENDQ) \
			$(TLIBS) OMTcachez.o
		$(CC) $(CFLAGS) -o OMTcache.x $(cacheOBJS) $(OMTOBJS) \
		OMTcachez.o $(OMSENDQ) $(TLIBS) -ltools -ll -ly -lm

OMTcachez.o:	$(cacheOBJS) libOMsendq.a
		$(OPL) -o OMTcachez.C $(cacheOBJS) libOMsendq.a
		$(OMCPP) $(OMCPPFLAGS) OMTcachez.C OMTcachez.c
		$(CC) $(CFLAGS) -c OMTcachez.c

#******************************************************************************
# OMTcache2
#******************************************************************************

cache2OBJS=	OMTcache2.o tst.o tsti.o tst0.o tst0i.o tst1.o \
		tst1i.o

OMTcache2.x::	$(cache2OBJS) $(OMTOBJS)   $(OMSENDQ) \
			$(TLIBS) OMTcache2z.o
		$(CC) $(CFLAGS) -o OMTcache2.x $(cache2OBJS) $(OMTOBJS) \
		OMTcache2z.o $(OMSENDQ) $(TLIBS) -ltools -ll -ly -lm

OMTcache2z.o:	$(cache2OBJS) libOMsendq.a
		$(OPL) -o OMTcache2z.C $(cache2OBJS) libOMsendq.a
		$(OMCPP) $(OMCPPFLAGS) OMTcache2z.C OMTcache2z.c
		$(CC) $(CFLAGS) -c OMTcache2z.c

#************************************************************************
