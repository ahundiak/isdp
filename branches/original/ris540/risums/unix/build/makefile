###########################################################################
#
#               file:    build/makefile
#
###########################################################################

.SUFFIXES:
.SUFFIXES: .c .o

SHELL=/bin/ksh

#################################################################

include $(RISDEVDIR)/risums/unix/build/defines

#################################################################

fast:
	@mk_test
	@echo
	@$(MAKE) source
	@$(MAKE) lib
	@$(MAKE) bin

world:
	@mk_test
	@$(MAKE) cleanworld
	@$(MAKE) subdirs
	@$(MAKE) prototypes
	@export RIS_BUILD_ALL=1; $(MAKE) source
	@$(MAKE) lib
	@$(MAKE) bin

prototypes:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		echo; \
		echo "\tMaking $$DIR prototypes"; \
		cd $(RISDEVDIR)/risums/unix/$$DIR; $(MAKE) prototypes; \
	done

subdirs:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		if [ ! -d $(RISDEVDIR)/risums/unix/$$DIR/prt ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/prt";\
			mkdir $(RISDEVDIR)/risums/unix/$$DIR/prt;\
		fi ; \
		if [ ! -d $(RISDEVDIR)/risums/unix/$$DIR/$(OBJDIR) ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/$(OBJDIR)";\
			mkdir $(RISDEVDIR)/risums/unix/$$DIR/$(OBJDIR);\
		fi ; \
	done
	@if [ ! -d $(RISDEVDIR)/risums/unix/lib/$(LIBDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory lib/$(LIBDIR)";\
		mkdir $(RISDEVDIR)/risums/unix/lib/$(LIBDIR);\
	fi ;
	@if [ ! -d $(RISDEVDIR)/risums/unix/bin/$(BINDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory bin/$(BINDIR)";\
		mkdir $(RISDEVDIR)/risums/unix/bin/$(BINDIR);\
	fi ;

source:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		echo; \
		echo "\tMaking $$DIR"; \
		cd $(RISDEVDIR)/risums/unix/$$DIR; $(MAKE); \
	done

lib:
	@mk_test
	@echo
	@echo "\tMaking lib"
	@cd $(RISDEVDIR)/risums/unix/lib; $(MAKE)

bin:
	@mk_test
	@echo
	@echo "\tMaking bin"
	@cd $(RISDEVDIR)/risums/unix/bin; $(MAKE)

cleanworld:
	@mk_test
	@$(MAKE) cleanobjdir
	@$(MAKE) cleanmakeout
	@$(MAKE) cleanlib
	@$(MAKE) cleanbin

cleanobjdir:
	@mk_test
	@rm -f	$(RISDEVDIR)/risums/unix/[a-n]*/$(OBJDIR)/*
	@rm -f	$(RISDEVDIR)/risums/unix/[o-z]*/$(OBJDIR)/*
	@rm -f	$(RISDEVDIR)/risums/unix/*/$(OBJDIR)/*

cleanmakeout:
	@mk_test
	@rm -f	$(RISDEVDIR)/risums/unix/*/makeout

cleanprototypes:
	@mk_test
	@rm -f	$(RISDEVDIR)/risums/unix/*/prt/*.prt

cleanlib:
	@mk_test
	@rm -f $(RISDEVDIR)/risums/unix/lib/$(LIBDIR)/*

cleanbin:
	@mk_test
	@rm -f $(RISDEVDIR)/risums/unix/bin/$(BINDIR)/*

backupcpio backcpio:
	@mk_test
	@bckup.ksh -c

backupzip backzip:
	@mk_test
	@bckup.ksh -z

backuplist backlist:
	@mk_test
	@bckup.ksh -l

backuptree backtree:
	@mk_test
	@bckup.ksh -t

tstamp:
	@mk_test
	@touch $(RISDEVDIR)/risums/unix/tstamp
