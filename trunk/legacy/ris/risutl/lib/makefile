###########################################################################
#
#				file:	 lib/makefile
#
###########################################################################

.SUFFIXES:
.SUFFIXES: .o

###########################################################################

include $(RISDEVDIR)/risutl/build/defines

###########################################################################

fast:
	@mk_test
	@if [ $(LIBDIR) != "sco" ] ; \
	then \
		$(MAKE) risformslibs;\
	fi
	@$(MAKE) $(LIBDIR)/risuco.a
	@$(MAKE) $(LIBDIR)/risusv.a
	@$(MAKE) $(LIBDIR)/rislduld.a

risformslibs:
	@mk_test
	@echo 
	@case $(LIBDIR) in \
		"c100"|"c400") \
			if [ ! -r "/usr/ip32/unixboot/.X" ] ; \
			then \
				$(MAKE) $(LIBDIR)/risforms.a;\
			fi;\
			if [ "`proddata +%n -x XWINPROG`" ]; \
			then \
				$(MAKE) $(LIBDIR)/xrisforms.a;\
			fi;;\
		"sun"|"Sol2"|"Soli"|"hpux") \
			$(MAKE) $(LIBDIR)/xrisforms.a;;\
	esac

strip:
	@mk_test
	@echo "\n\tStripping target $(TARGET)"
	@if [ -f $(LIBDIR)/risuco.a ]; \
	then \
		strip -r $(LIBDIR)/risuco.a; \
		mcs -d $(LIBDIR)/risuco.a; \
		ar ts $(LIBDIR)/risuco.a >/dev/null; \
	fi
	@if [ -f $(LIBDIR)/risusv.a ]; \
	then \
		strip -r $(LIBDIR)/risusv.a; \
		mcs -d $(LIBDIR)/risusv.a; \
		ar ts $(LIBDIR)/risusv.a >/dev/null; \
	fi
	@if [ -f $(LIBDIR)/rislduld.a ]; \
	then \
		strip -r $(LIBDIR)/rislduld.a; \
		mcs -d $(LIBDIR)/rislduld.a; \
		ar ts $(LIBDIR)/rislduld.a >/dev/null; \
	fi
	@if [ -f $(LIBDIR)/risforms.a ]; \
	then \
		strip -r $(LIBDIR)/risforms.a; \
		mcs -d $(LIBDIR)/risforms.a; \
		ar ts $(LIBDIR)/risforms.a >/dev/null; \
	fi

$(LIBDIR)/risuco.a: $(RIS_UCO_ARCHIVE_OBJS)
	@mk_test
	@echo
	@echo "\tRIS_UCO_ARCHIVE_OBJS   ->   $@"
	@rm -f $@
	@ar rsu $@ $(RIS_UCO_ARCHIVE_OBJS)

$(LIBDIR)/risusv.a: $(RIS_USV_ARCHIVE_OBJS)
	@mk_test
	@echo
	@echo "\tRIS_USV_ARCHIVE_OBJS   ->   $@"
	@rm -f $@
	@ar rsu $@ $(RIS_USV_ARCHIVE_OBJS)

$(LIBDIR)/rislduld.a: $(RIS_LDULD_ARCHIVE_OBJS_1) \
		      $(RIS_LDULD_ARCHIVE_OBJS_2)
	@mk_test
	@echo
	@echo "\tRIS_LDULD_ARCHIVE_OBJS   ->   $@"
	@rm -f $@
	@ar rsu $@ $(RIS_LDULD_ARCHIVE_OBJS_1)
	@ar rsu $@ $(RIS_LDULD_ARCHIVE_OBJS_2)
	@ar rsu $@ $(RIS_LDULD_ARCHIVE_OBJS_3)
	@ar rsu $@ $(RIS_LDULD_ARCHIVE_OBJS_4)

$(LIBDIR)/risforms.a: $(RIS_FORMS_ARCHIVE_OBJS)
	@mk_test
	@echo
	@echo "\tRIS_FORMS_ARCHIVE_OBJS   ->   $@"
	@rm -f $@
	@ar rsu $@ $(RIS_FORMS_ARCHIVE_OBJS)

$(LIBDIR)/xrisforms.a: $(XRIS_FORMS_ARCHIVE_OBJS)
	@mk_test
	@echo
	@echo "\tXRIS_FORMS_ARCHIVE_OBJS   ->   $@"
	@rm -f $@
	@ar rsu $@ $(XRIS_FORMS_ARCHIVE_OBJS)
