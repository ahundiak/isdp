###########################################################################
#
#				file:	 lib/makefile
#
###########################################################################

.SUFFIXES:
.SUFFIXES: .o

###########################################################################

include $(RISDEVDIR)/risapp/build/defines

###########################################################################

fast: ris.a
	@mk_test

strip:
	@mk_test
	@echo "\n\tStripping target $(TARGET)"
	@if [ -f $(LIBDIR)/ris.a ]; \
	then \
		strip -r $(LIBDIR)/ris.a; \
		mcs -d $(LIBDIR)/ris.a; \
		ar ts $(LIBDIR)/ris.a >/dev/null;\
	 fi ;

ris.a: $(LIBDIR)/ris.a dummy
	@mk_test
	@echo
	@echo "\t$(LIBDIR)/ris.a   ->   $@"
	@if [ $(LIBDIR) = "sun" ]; \
	then \
		ranlib $@; \
	fi
	@if [ $(LIBDIR) = "hpux" ]; \
	then \
		# HP-UX linker will use the last occurance in the archive. \
		# this makes sure that nettcp.o appears after nettcpdm.o   \
		ar ma nettcpdm.o $(LIBDIR)/$@ nettcp.o; \
	fi;

$(LIBDIR)/ris.a: ris_a1 ris_a2 ris_a3 ris_a4 ris_a5
	@mk_test
	@echo
	@echo '\t$?   ->   '$@
	
ris_a1: $(RIS_ARCHIVE_OBJS1) 
	@mk_test
	@echo
	@echo '\t$$RIS_ARCHIVE_OBJS1   ->   '$@
	@because $?
	@rm -f $(LIBDIR)/ris.a
	@ar rsu $(LIBDIR)/ris.a $(RIS_ARCHIVE_OBJS1)

ris_a2: $(RIS_ARCHIVE_OBJS2)
	@mk_test
	@echo
	@echo '\t$$RIS_ARCHIVE_OBJS2   ->   '$@
	@because $?
	@ar rsu $(LIBDIR)/ris.a $(RIS_ARCHIVE_OBJS2)

ris_a3: $(RIS_ARCHIVE_OBJS3)
	@mk_test
	@echo
	@echo '\t$$RIS_ARCHIVE_OBJS3   ->   '$@
	@because $?
	@ar rsu $(LIBDIR)/ris.a $(RIS_ARCHIVE_OBJS3)

ris_a4: $(RIS_ARCHIVE_OBJS4)
	@mk_test
	@echo
	@echo '\t$$RIS_ARCHIVE_OBJS4   ->   '$@
	@because $?
	@ar rsu $(LIBDIR)/ris.a $(RIS_ARCHIVE_OBJS4)

ris_a5: $(RIS_ARCHIVE_OBJS5)
	@mk_test
	@echo
	@echo '\t$$RIS_ARCHIVE_OBJS5   ->   '$@
	@because $?
	@ar rsu $(LIBDIR)/ris.a $(RIS_ARCHIVE_OBJS5)

dummy:
