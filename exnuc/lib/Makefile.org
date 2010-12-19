IPATH =  \
	-I$(EXNUC)/include

omcpp = $(EXNUC)/bin/omcpp

objects = \
	$(EXNUC)/lib/exnucspec.o \
	$(EXNUC)/lib/exstubs.o   \
	$(EXNUC)/lib/exversion.o \
	$(EXNUC)/lib/igefei.o    \
	$(EXNUC)/lib/message.o   \
	$(EXNUC)/lib/om_spec.o   \
	$(EXNUC)/lib/om_src.o    \
	$(EXNUC)/lib/om_igrdir_dir.o   \
	$(EXNUC)/lib/om_igrdir_btree.o \
	$(EXNUC)/lib/om_igrdir_group.o \
	$(EXNUC)/lib/icob_actions.o    \
	$(EXNUC)/lib/icob_ceo.o        \
	$(EXNUC)/lib/icob_state.o      \
	$(EXNUC)/lib/icob_trans.o      \
	$(EXNUC)/lib/icob_util.o       \
	$(EXNUC)/lib/icob_shfn.o       \
	$(EXNUC)/lib/exec_cm.o         \
	$(EXNUC)/lib/exec_wl.o         \
	$(EXNUC)/lib/exec_wfi.o        \
	$(EXNUC)/lib/exec_font.o       \
	$(EXNUC)/lib/exec_udata.o      \
	$(EXNUC)/lib/exec_color.o      \
	$(EXNUC)/lib/exec_window.o     \
	$(EXNUC)/lib/exec_locale.o     \
	$(EXNUC)/lib/exec_cmdserver.o  \
	$(EXNUC)/lib/exec_module.o     \
	$(EXNUC)/lib/exec_execco.o     \
	$(EXNUC)/lib/exec_execsh.o     \
	$(EXNUC)/lib/exec_exec.o

target: $(EXNUC)/lib/exnuc.o

targetx: $(EXNUC)/lib/exnuc.o $(EXNUC)/lib/OMmetas.o $(EXNUC)/lib/OMclassinit.o

$(EXNUC)/lib/exnuc.o : $(objects)
	@ld -r -o $(EXNUC)/lib/exnuc.o $(objects)
	@ls    -l $(EXNUC)/lib/exnuc.o

OMmetas.c : $(EXNUC)/lib/exnuc.o
	opl -m $(EXNUC)/lib/exnuc.o

$(EXNUC)/lib/OMmetas.o : OMmetas.c
	$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c OMmetas.c -o $(EXNUC)/lib/OMmetas.o

OMclassinit.C : $(EXNUC)/lib/exnuc.o
	opl $(EXNUC)/lib/exnuc.o

$(EXNUC)/lib/OMclassinit.o : OMclassinit.C
	$(omcpp) $(IPATH) $(MKDOPT) OMclassinit.C OMclassinit.c
	$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c OMclassinit.c -o $(EXNUC)/lib/OMclassinit.o
