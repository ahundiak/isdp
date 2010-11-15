
include $(RISDEVDIR)/risutl/build/defines

SYSTEM_NAME=`uname -s`

ENV5_LIBS=$(RISMGR_ARCHIVES) $(RISMGR_LIBS)
ENV5_IPATH=\
	-I$(RISDEVDIR)/risutl/include\
	-I$(RISDEVDIR)/riscom/include

X_LIBS=$(XRISMGR_ARCHIVES) $(XRISMGR_LIBS)
X_IPATH=\
	-I/usr/openwin/include\
	-I$(RISDEVDIR)/risutl/include\
	-I$(RISDEVDIR)/riscom/include

all:
	@case $(SYSTEM_NAME) in \
		"CLIX") \
			if [ "`proddata +%n -x ENVIRONV`" ] ; \
			then \
				$(MAKE) frmsamps LIBS="$(ENV5_LIBS)" IPATH="$(ENV5_IPATH)" ; \
			fi; \
			if [ "`proddata +%n -x XWINPROG`" ] ; \
			then \
				$(MAKE) xfrmsamps LIBS="$(X_LIBS)" IPATH="$(X_IPATH)" ; \
			fi;; \
		"SunOS") \
			$(MAKE) xfrmsamps LIBS="$(X_LIBS)" IPATH="$(X_IPATH)";; \
	esac

frmsamps: frmsamp1 frmsamp2
frmsamp1.c: $(RISDEVDIR)/risutl/include/risforms.h
frmsamp2.c: $(RISDEVDIR)/risutl/include/risforms.h

xfrmsamps: xfrmsamp1 xfrmsamp2
xfrmsamp1.c: $(RISDEVDIR)/risutl/include/risforms.h
xfrmsamp2.c: $(RISDEVDIR)/risutl/include/risforms.h

cleanup:
	@-rm *.o 2>/dev/null
	@-rm frmsamp1 frmsamp2 2>/dev/null
	@-rm xfrmsamp1 xfrmsamp2 2>/dev/null

.c:
	@mk_test
	@echo
	@echo  "\tMaking $@"
	$(CC) -c $(IPATH) $@.c
	$(LINK) -o $@ $@.o $(LIBS)
	@rm $@.o
