###########################################################################
#
#				file:	 bin/makefile
#
###########################################################################

.SUFFIXES:
.SUFFIXES: .o

###########################################################################

include $(RISDEVDIR)/risutl/build/defines

###########################################################################

fast:
	@mk_test
	@if [ $(BINDIR) = "sco" ] ; \
	then \
		$(MAKE) risdtype; \
		$(MAKE) rislod; \
		$(MAKE) risunlod; \
	else \
		$(MAKE) risguis; \
		$(MAKE) rishelps; \
		$(MAKE) rismgrs; \
		$(MAKE) risalpha; \
		$(MAKE) rliclist; \
		$(MAKE) risbatch; \
		$(MAKE) risclnsr; \
		$(MAKE) risclnup; \
		$(MAKE) risdcode; \
		$(MAKE) risdtype; \
		$(MAKE) rislod; \
		$(MAKE) risplbck; \
		$(MAKE) risrecrd; \
		$(MAKE) risunlod; \
		$(MAKE) risuparm; \
		$(MAKE) timebomb; \
	fi

#
#	RIS interactives
#
risguis:
	@mk_test
	@case $(BINDIR) in \
		"c100"|"c400") \
			if [ ! -r "/usr/ip32/unixboot/.X" ] ; \
			then \
				$(MAKE) $(BINDIR)/risgui; \
			fi;\
			if [ "`proddata +%n -x XWINPROG`" ] ; \
			then \
				$(MAKE) $(BINDIR)/xrisgui; \
			fi;; \
		"sun"|"Sol2"|"Soli"|"hpux") \
			$(MAKE) $(BINDIR)/xrisgui;; \
	esac

#
#	risgui
#
risgui: $(BINDIR)/risgui
$(BINDIR)/risgui: $(RISGUI_OBJS) $(RISGUI_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISGUI_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISGUI_OBJS) $(RISGUI_ARCHIVES) $(RISGUI_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	xrisgui
#
xrisgui: $(BINDIR)/xrisgui
$(BINDIR)/xrisgui: $(XRISGUI_OBJS) $(XRISGUI_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tXRISGUI_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(XRISGUI_OBJS) $(XRISGUI_ARCHIVES) $(XRISGUI_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	RIS managers
#
rismgrs:
	@mk_test
	@case $(BINDIR) in \
		"c100"|"c400") \
			if [ ! -r "/usr/ip32/unixboot/.X" ] ; \
			then \
				$(MAKE) $(BINDIR)/rismgr;\
			fi;\
			if [ "`proddata +%n -x XWINPROG`" ]; \
			then \
				$(MAKE) $(BINDIR)/xrismgr;\
			fi;;\
		"sun"|"Sol2"|"Soli"|"hpux") \
			$(MAKE) $(BINDIR)/xrismgr;;\
	esac

#
#	rismgr
#
rismgr: $(BINDIR)/rismgr
$(BINDIR)/rismgr: $(RISMGR_OBJS) $(RISMGR_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISMGR_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISMGR_OBJS) $(RISMGR_ARCHIVES) $(RISMGR_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	xrismgr
#
xrismgr: $(BINDIR)/xrismgr
$(BINDIR)/xrismgr: $(XRISMGR_OBJS) $(XRISMGR_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tXRISMGR_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(XRISMGR_OBJS) $(XRISMGR_ARCHIVES) $(XRISMGR_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	RIS helps
#
rishelps:
	@mk_test
	@case $(BINDIR) in \
		"c100"|"c400") \
			if [ ! -r "/usr/ip32/unixboot/.X" ] ; \
			then \
				$(MAKE) $(BINDIR)/rishelp;\
			fi;\
			if [ "`proddata +%n -x XWINPROG`" ]; \
			then \
				$(MAKE) $(BINDIR)/xrishelp;\
			fi;;\
		"sun"|"Sol2"|"Soli"|"hpux") \
			$(MAKE) $(BINDIR)/xrishelp;;\
	esac

#
#	rishelp
#
rishelp: $(BINDIR)/rishelp
$(BINDIR)/rishelp: $(RISHELP_OBJS) $(RISHELP_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISHELP_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISHELP_OBJS) $(RISHELP_ARCHIVES) $(RISHELP_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	xrishelp
#
xrishelp: $(BINDIR)/xrishelp
$(BINDIR)/xrishelp: $(XRISHELP_OBJS) $(XRISHELP_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tXRISHELP_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(XRISHELP_OBJS) $(XRISHELP_ARCHIVES) $(XRISHELP_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#
#	risalpha
#
risalpha: $(BINDIR)/risalpha
$(BINDIR)/risalpha: $(RISALPHA_OBJS) $(RISALPHA_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISALPHA_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISALPHA_OBJS) $(RISALPHA_ARCHIVES) $(RISALPHA_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#
#	risbatch
#
risbatch: $(BINDIR)/risbatch
$(BINDIR)/risbatch: $(RISBATCH_OBJS) $(RISBATCH_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISBATCH_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISBATCH_OBJS) $(RISBATCH_ARCHIVES) $(RISBATCH_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	risclnsr
#
risclnsr: $(BINDIR)/risclnsr
$(BINDIR)/risclnsr: $(RISCLNSR_OBJS) $(RISCLNSR_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISCLNSR_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISCLNSR_OBJS) $(RISCLNSR_ARCHIVES) $(RISCLNSR_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	risclnup
#
risclnup: $(BINDIR)/risclnup
$(BINDIR)/risclnup: $(RISCLNUP_OBJS) $(RISCLNUP_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISCLNUP_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISCLNUP_OBJS) $(RISCLNUP_ARCHIVES) $(RISCLNUP_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	risdcode
#
risdcode: $(BINDIR)/risdcode
$(BINDIR)/risdcode: $(RISDCODE_OBJS) $(RISDCODE_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISDCODE_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISDCODE_OBJS) $(RISDCODE_ARCHIVES) $(RISDCODE_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	risdtype
#
risdtype: $(BINDIR)/risdtype
$(BINDIR)/risdtype: $(RISDTYPE_OBJS) $(RISDTYPE_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISDTYPE_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISDTYPE_OBJS) $(RISDTYPE_ARCHIVES) $(RISDTYPE_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	rislod
#
rislod: $(BINDIR)/rislod
$(BINDIR)/rislod: $(RISLOD_OBJS) $(RISLOD_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISLOD_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISLOD_OBJS) $(RISLOD_ARCHIVES) $(RISLOD_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	risplbck
#
risplbck: $(BINDIR)/risplbck
$(BINDIR)/risplbck: $(RISPLBCK_OBJS) $(RISPLBCK_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISPLBCK_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISPLBCK_OBJS) $(RISPLBCK_ARCHIVES) $(RISPLBCK_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	risrecrd
#
risrecrd: $(BINDIR)/risrecrd
$(BINDIR)/risrecrd: $(RISRECRD_OBJS) $(RISRECRD_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISRECRD_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISRECRD_OBJS) $(RISRECRD_ARCHIVES) $(RISRECRD_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	risunlod
#
risunlod: $(BINDIR)/risunlod
$(BINDIR)/risunlod: $(RISUNLOD_OBJS) $(RISUNLOD_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISUNLOD_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISUNLOD_OBJS) $(RISUNLOD_ARCHIVES) $(RISUNLOD_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	risuparm
#
risuparm: $(BINDIR)/risuparm
$(BINDIR)/risuparm: $(RISUPARM_OBJS) $(RISUPARM_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tRISUPARM_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISUPARM_OBJS) $(RISUPARM_ARCHIVES) $(RISUPARM_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#
#	rliclist
#
rliclist: $(BINDIR)/rliclist
$(BINDIR)/rliclist: $(RLICLIST_OBJS) 
	@mk_test
	@echo 
	@echo "\tRLICLIST_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RLICLIST_OBJS) $(RLICLIST_ARCHIVES) $(RLICLIST_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

#
#	timebomb
#
timebomb: $(BINDIR)/timebomb
$(BINDIR)/timebomb: $(TIMEBOMB_OBJS) $(TIMEBOMB_ARCHIVES)
	@mk_test
	@echo 
	@echo "\tTIMEBOMB_OBJS   ->   $@"
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(TIMEBOMB_OBJS) $(TIMEBOMB_ARCHIVES) $(TIMEBOMB_LIBS)
	@echo "\tStripping $@"; strip $@
	@if [ $(BINDIR) != "sun" -a $(BINDIR) != "hpux" ]; then \
		mcs -d $@; \
	fi

links:
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

