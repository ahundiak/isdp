SHELL=/bin/ksh

.SUFFIXES:
.SUFFIXES: .c .o

OBJECTS=\
	$(OBJDIR)/define.o\
	$(OBJDIR)/depend.o\
	$(OBJDIR)/ignore.o\
	$(OBJDIR)/preproc.o\
	$(OBJDIR)/mm.o\
	$(OBJDIR)/output.o\
	$(OBJDIR)/path.o\
	$(OBJDIR)/read.o\
	$(OBJDIR)/readm.o\
	$(OBJDIR)/special.o\
	$(OBJDIR)/stack.o

IPATH=\
	-Iprt

fast:
	@mk_test
	@$(MAKE) prototypes
	@$(MAKE) $(RISDEVDIR)/ristools/bin/$(BINDIR)/mm	

prototypes:
	@echo
	@echo "\tChecking prototype header files."
	@get_prt *.c

cleanup:
	@rm -f $(OBJECTS) 2>/dev/null
	@rm -f prt/* 2>/dev/null
	@rm -f $(RISDEVDIR)/ristools/bin/$(BINDIR)/mm 2>/dev/null

$(RISDEVDIR)/ristools/bin/$(BINDIR)/mm: $(OBJECTS)
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

$(OBJDIR)/define.o:\
	$(RISDEVDIR)/ristools/mm/define.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/prt/define.prt\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/depend.o:\
	$(RISDEVDIR)/ristools/mm/depend.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/prt/depend.prt\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/ignore.o:\
	$(RISDEVDIR)/ristools/mm/ignore.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/prt/ignore.prt

$(OBJDIR)/mm.o:\
	$(RISDEVDIR)/ristools/mm/mm.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/prt/define.prt\
	$(RISDEVDIR)/ristools/mm/prt/mm.prt\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/prt/path.prt\
	$(RISDEVDIR)/ristools/mm/prt/read.prt\
	$(RISDEVDIR)/ristools/mm/prt/readm.prt\
	$(RISDEVDIR)/ristools/mm/prt/special.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/output.o:\
	$(RISDEVDIR)/ristools/mm/output.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/path.o:\
	$(RISDEVDIR)/ristools/mm/path.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/prt/path.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/preproc.o:\
	$(RISDEVDIR)/ristools/mm/preproc.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/prt/define.prt\
	$(RISDEVDIR)/ristools/mm/prt/preproc.prt\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/read.o:\
	$(RISDEVDIR)/ristools/mm/read.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/stack.h\
	$(RISDEVDIR)/ristools/mm/prt/preproc.prt\
	$(RISDEVDIR)/ristools/mm/prt/depend.prt\
	$(RISDEVDIR)/ristools/mm/prt/path.prt\
	$(RISDEVDIR)/ristools/mm/prt/read.prt\
	$(RISDEVDIR)/ristools/mm/prt/stack.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/readm.o:\
	$(RISDEVDIR)/ristools/mm/readm.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/stack.h\
	$(RISDEVDIR)/ristools/mm/prt/mm.prt\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/prt/path.prt\
	$(RISDEVDIR)/ristools/mm/prt/preproc.prt\
	$(RISDEVDIR)/ristools/mm/prt/readm.prt\
	$(RISDEVDIR)/ristools/mm/prt/special.prt\
	$(RISDEVDIR)/ristools/mm/prt/stack.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/special.o:\
	$(RISDEVDIR)/ristools/mm/special.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/prt/special.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt

$(OBJDIR)/stack.o:\
	$(RISDEVDIR)/ristools/mm/stack.c\
	$(RISDEVDIR)/ristools/mm/mm.h\
	$(RISDEVDIR)/ristools/mm/stack.h\
	$(RISDEVDIR)/ristools/mm/prt/output.prt\
	$(RISDEVDIR)/ristools/mm/prt/stack.prt\
	$(RISDEVDIR)/ristools/mm/sys.prt
