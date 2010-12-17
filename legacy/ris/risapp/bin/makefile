###########################################################################
#
#				file:	 bin/makefile
#
###########################################################################

.SUFFIXES:
.SUFFIXES: .o

###########################################################################

include $(RISDEVDIR)/risapp/build/defines

###########################################################################

fast:
	@mk_test
	@$(MAKE) riscpp 
	@$(MAKE) strip

strip:
	@mk_test
	@echo "\n\tStripping target $(TARGET)"
	@if [ -f $(BINDIR)/riscpp ]; \
	then \
		strip $(BINDIR)/riscpp; \
		if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; \
		then \
			mcs -d $(BINDIR)/riscpp; \
		fi; \
	 fi

riscpp: $(BINDIR)/riscpp dummy
	@mk_test
	@echo 
	@echo "\t$(BINDIR)/riscpp   ->   $@"
	@if [ $(BINDIR) = "c100" -o $(BINDIR) = "c400" ]; then \
		if [ $(TARGET) = "c400" -a `inqcpuid` != "C400" ] ; then \
			( mk c100 riscpp ) ; \
		fi ; \
	fi ;

$(BINDIR)/riscpp: $(BINDIR)/riscpp.a $(RISCPP_ARCHIVES)
	@mk_test
	@echo 
	@echo '\t$$RISCPP_OBJS   ->   '$@
	@echo "\tLinking with $(LINK)"
#	@because $?
	@case $(BINDIR) in \
	"c100"|"c400"|"sco") \
		$(LINK) -o $@ $(BINDIR)/riscpp.a $(RISCPP_ARCHIVES) $(RISCPP_LIBS);;\
	"sun"|"Sol2"|"Soli"|"hpux") \
		$(LINK) -o $@ $(RISCPP_OBJS) $(RISCPP_ARCHIVES) $(RISCPP_LIBS);;\
	esac
	@rm -f $(BINDIR)/riscpp.a

$(BINDIR)/riscpp.a: $(RISCPP_OBJS1) $(RISCPP_OBJS2)
	@mk_test
	@case $(BINDIR) in \
	"c100"|"c400"|"sco") \
		echo; \
		echo '\tMaking temporary library' $@; \
		echo '\t$$RISCPP_OBJS   ->   '$@; \
		ar rsu $@ $(RISCPP_OBJS1); \
		ar rsu $@ $(RISCPP_OBJS2);; \
	esac

dummy:
