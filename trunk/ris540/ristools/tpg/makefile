SHELL=/bin/ksh

.SUFFIXES:
.SUFFIXES: .c .o

OBJECTS=\
	$(OBJDIR)/data.o\
	$(OBJDIR)/generate.o\
	$(OBJDIR)/main.o\
	$(OBJDIR)/msg.o\
	$(OBJDIR)/read.o\
	$(OBJDIR)/tests.o\
	$(OBJDIR)/ums.o\
	$(OBJDIR)/write.o

IPATH=\
	-Iprt\
	-I$(RISDEVDIR)/riscom/include

fast:
	@mk_test
	@$(MAKE) prototypes
	@$(MAKE) $(RISDEVDIR)/ristools/bin/$(BINDIR)/tpg	

prototypes:
	@echo
	@echo "\tChecking prototype header files."
	@get_prt *.c

cleanup:
	@rm -f $(OBJECTS) 2>/dev/null
	@rm -f prt/* 2>/dev/null
	@rm -f $(RISDEVDIR)/ristools/bin/$(BINDIR)/tpg 2>/dev/null

$(RISDEVDIR)/ristools/bin/$(BINDIR)/tpg: $(OBJECTS)
	@mk_test
	@echo
	@echo '\t$$OBJECTS   ->   '$@
	@$(LINK) -o $@ $(OBJECTS) $(SYS_LIB)

$(OBJECTS):
	@mk_test
	@echo
	@echo "\t$(@F:.o=.c) -> $@"
	@echo "\tCompiling with $(CC) -c $(COPT)"
	@because $?
	@$(CC) -c $(COPT) $(DOPT) $(IPATH) $(@F:.o=.c)
	@mv $(@F) $@
	@chk_prt -r $(IFDEF_FLAG) -nnonfuncs $(DOPT) $(IPATH) $(@F:.o=.c)
	@echo "\tPrototypes enforced"

$(OBJDIR)/data.o:\
	$(RISDEVDIR)/ristools/tpg/data.c\
	$(RISDEVDIR)/ristools/tpg/tpg.h\
	$(RISDEVDIR)/ristools/tpg/prt/data.prt\
	$(RISDEVDIR)/ristools/tpg/prt/read.prt\
	$(RISDEVDIR)/ristools/tpg/sys.prt

$(OBJDIR)/generate.o:\
	$(RISDEVDIR)/ristools/tpg/generate.c\
	$(RISDEVDIR)/ristools/tpg/tpg.h\
	$(RISDEVDIR)/ristools/tpg/prt/generate.prt\
	$(RISDEVDIR)/ristools/tpg/prt/msg.prt\
	$(RISDEVDIR)/ristools/tpg/prt/tests.prt\
	$(RISDEVDIR)/ristools/tpg/prt/write.prt\
	$(RISDEVDIR)/ristools/tpg/sys.prt

$(OBJDIR)/main.o:\
	$(RISDEVDIR)/ristools/tpg/main.c\
	$(RISDEVDIR)/ristools/tpg/tpg.h\
	$(RISDEVDIR)/ristools/tpg/prt/generate.prt\
	$(RISDEVDIR)/ristools/tpg/prt/tests.prt\
	$(RISDEVDIR)/ristools/tpg/prt/data.prt\
	$(RISDEVDIR)/ristools/tpg/prt/msg.prt\
	$(RISDEVDIR)/ristools/tpg/prt/read.prt\
	$(RISDEVDIR)/ristools/tpg/sys.prt

$(OBJDIR)/msg.o:\
	$(RISDEVDIR)/ristools/tpg/msg.c\
	$(RISDEVDIR)/ristools/tpg/tpg.h\
	$(RISDEVDIR)/ristools/tpg/prt/msg.prt\
	$(RISDEVDIR)/ristools/tpg/prt/read.prt\
	$(RISDEVDIR)/ristools/tpg/prt/data.prt\
	$(RISDEVDIR)/ristools/tpg/sys.prt

$(OBJDIR)/read.o:\
	$(RISDEVDIR)/ristools/tpg/read.c\
	$(RISDEVDIR)/ristools/tpg/tpg.h\
	$(RISDEVDIR)/ristools/tpg/prt/read.prt\
	$(RISDEVDIR)/ristools/tpg/sys.prt

$(OBJDIR)/tests.o:\
	$(RISDEVDIR)/ristools/tpg/tests.c\
	$(RISDEVDIR)/ristools/tpg/tpg.h\
	$(RISDEVDIR)/ristools/tpg/prt/tests.prt\
	$(RISDEVDIR)/ristools/tpg/prt/write.prt\
	$(RISDEVDIR)/ristools/tpg/sys.prt

$(OBJDIR)/ums.o:\
	$(RISDEVDIR)/ristools/tpg/ums.c\
	$(RISDEVDIR)/ristools/tpg/tpg.h\
	$(RISDEVDIR)/ristools/tpg/prt/generate.prt\
	$(RISDEVDIR)/ristools/tpg/prt/msg.prt\
	$(RISDEVDIR)/ristools/tpg/prt/tests.prt\
	$(RISDEVDIR)/ristools/tpg/prt/write.prt\
	$(RISDEVDIR)/ristools/tpg/prt/ums.prt\
	$(RISDEVDIR)/ristools/tpg/sys.prt

$(OBJDIR)/write.o:\
	$(RISDEVDIR)/ristools/tpg/write.c\
	$(RISDEVDIR)/ristools/tpg/tpg.h\
	$(RISDEVDIR)/ristools/tpg/prt/write.prt\
	$(RISDEVDIR)/ristools/tpg/prt/generate.prt\
	$(RISDEVDIR)/ristools/tpg/sys.prt
