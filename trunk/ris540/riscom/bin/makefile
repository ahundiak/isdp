###########################################################################
#
#				file:	 bin/makefile
#
###########################################################################

SHELL=/bin/ksh

include $(RISDEVDIR)/riscom/build/defines

.SUFFIXES:
.SUFFIXES: .o

fast:
	@mk_test
	@$(MAKE) $(BINDIR)/ristcpsr
	@$(MAKE) strip

strip:
	@mk_test
	@echo "\n\tStripping target $(TARGET)"
	@if [ -f $(BINDIR)/ristcpsr ]; \
	then \
		strip $(BINDIR)/ristcpsr; \
		if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; \
		then \
			mcs -d $(BINDIR)/ristcpsr; \
		fi; \
	fi

$(BINDIR)/ristcpsr: $(RISTCPSR_OBJS) $(RISTCPSR_ARCHIVES)
	@mk_test
	@echo
	@echo '\t$$RISTCPSR_OBJS   ->   '$@
	@echo "\tLinking with $(LINK)"
	@because $?
	@$(LINK) -o $@ $(RISTCPSR_OBJS) $(RISTCPSR_ARCHIVES) $(RISTCPSR_LIBS)
