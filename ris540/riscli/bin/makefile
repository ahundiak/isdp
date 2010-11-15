###########################################################################
#
#				file:	 riscli/bin/makefile
#
###########################################################################

.SUFFIXES:
.SUFFIXES: .o

###########################################################################

include $(RISDEVDIR)/riscli/build/defines

###########################################################################

fast:
	@mk_test
	@$(MAKE) riscli
	@$(MAKE) risupgrd 
	@$(MAKE) mkkeydoc
	@$(MAKE) strip

strip:
	@mk_test
	@echo
	@echo "\tStripping target " $(TARGET)
	@if [ -f $(BINDIR)/riscli ]; \
	then \
		strip $(BINDIR)/riscli; \
		if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; \
		then \
			mcs -d $(BINDIR)/riscli; \
		fi; \
	fi
	@if [ -f $(BINDIR)/risupgrd ]; \
	then \
		strip $(BINDIR)/risupgrd; \
		if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; \
		then \
			mcs -d $(BINDIR)/risupgrd; \
		fi; \
	fi

links:
	@mk_test
	@for EXE in $(EXECUTABLES); \
	do \
		if [ -f $(BINDIR)/$$EXE ];\
		then \
			echo "\t$(BINDIR)/$$EXE   ->   $$EXE"; \
			ln $(BINDIR)/$$EXE $$EXE; \
		fi;\
	done

rmlinks:
	@for EXE in $(EXECUTABLES); \
	do \
		if [ -f $$EXE ];\
		then \
			echo "\tremoving $$EXE"; \
			rm -f $$EXE; \
		fi;\
	done

############################################################
#
#	riscli
#
############################################################
riscli: $(BINDIR)/riscli dummy
	@mk_test
	@echo 
	@echo "\t$(BINDIR)/riscli   ->   $@"

$(BINDIR)/riscli: $(BINDIR)/riscli.a $(RISCLI_ARCHIVE)
	@mk_test
	@echo 
	@echo '\t$$RISCLI_OBJS   ->   '$@
	@echo "\tLinking with $(LINK)"
#	@because -c $?
	@case $(BINDIR) in \
	"c100"|"c400"|"sco") \
		$(LINK) -o $@ $(BINDIR)/riscli.a $(RISCLI_ARCHIVE) $(RISCLI_LIBS);; \
	"sun"|"Sol2"|"Soli"|"hpux") \
		$(LINK) -o $@ $(RISCLI_OBJS) $(RISCLI_ARCHIVE) $(RISCLI_LIBS);; \
	esac
	@rm -f $(BINDIR)/riscli.a

$(BINDIR)/riscli.a:
	@mk_test
	@case $(BINDIR) in \
	"c100"|"c400"|"sco") \
		rm -f $(BINDIR)/riscli.a; \
		echo; \
		echo '\tMaking temporary riscli library'; \
		ar r $(BINDIR)/riscli.a $(RISCLI_OBJS_1); \
		ar r $(BINDIR)/riscli.a $(RISCLI_OBJS_2); \
		ar r $(BINDIR)/riscli.a $(RISCLI_OBJS_3); \
		ar r $(BINDIR)/riscli.a $(RISCLI_OBJS_4); \
		ar r $(BINDIR)/riscli.a $(RISCLI_OBJS_5); \
		ar r $(BINDIR)/riscli.a $(RISCLI_OBJS_6); \
		ar r $(BINDIR)/riscli.a $(RISCLI_OBJS_7); \
		echo ;;\
	esac

############################################################
#
#	risupgrade
#
############################################################
risupgrd: $(BINDIR)/risupgrd dummy
	@mk_test
	@echo 
	@echo "\t$(BINDIR)/risupgrd   ->   $@"

$(BINDIR)/risupgrd: $(RISUPGRADE_OBJS)
	@mk_test
	@echo 
	@echo '\t$$RISUPGRADE_OBJS   ->   '$@
	@echo "\tLinking with $(LINK)"
	@because $?
	@$(LINK) -o risuptmp $(RISUPGRADE_OBJS) $(RISDEVDIR)/risapp/lib/$(LIBDIR)/ris.a $(RISUPGRADE_LIBS)
	@mv -f risuptmp $@

############################################################
#
#	mkkeydoc
#
############################################################
mkkeydoc: $(BINDIR)/mkkeydoc dummy
	@mk_test
	@echo 
	@echo "\t$(BINDIR)/mkkeydoc   ->   $@"

$(BINDIR)/mkkeydoc: $(MKKEYDOC_OBJS)
	@mk_test
	@echo 
	@echo '\t$$MKKEYDOC_OBJS   ->   '$@
	@echo "\tLinking with $(LINK)"
	@because $?
	@$(LINK) -o mkkeytmp $(MKKEYDOC_OBJS) $(MKKEYDOC_LIBS)
	@mv -f mkkeytmp $@

dummy:
