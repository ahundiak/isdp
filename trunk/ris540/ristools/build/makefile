SHELL=/bin/ksh

DIRS=\
	c \
	mm 

SUBDIRS= \
	mm/prt \
	mm/$(OBJDIR) \
	tpg/prt \
	tpg/$(OBJDIR) \
	bin \
	bin/$(BINDIR)

fast:
	@mk_test
	@$(MAKE) version
	@echo
	@for DIR in $(DIRS); \
	do \
		if [ -d $(RISDEVDIR)/ristools/$$DIR ] ; then \
			echo;\
			echo "\tMaking $$DIR";\
			cd $(RISDEVDIR)/ristools/$$DIR;\
			$(MAKE);\
		fi ; \
	done
	@if [ "$(MAKE_TPG)" = "YES" ] ; then \
		if [ -d $(RISDEVDIR)/ristools/tpg ] ; then \
			echo;\
			echo "\tMaking tpg"; \
			cd $(RISDEVDIR)/ristools/tpg; \
			$(MAKE); \
		fi ; \
	fi

subdirs:
	@mk_test
	@echo
	@for SUBDIR in $(SUBDIRS); \
	do \
		if [ ! -d $(RISDEVDIR)/ristools/$$SUBDIR ] ; then \
			echo;\
			echo "\tCreating subdirectory $$SUBDIR";\
			mkdir $(RISDEVDIR)/ristools/$$SUBDIR;\
		fi ; \
	done

version:
	@mk_test
	@$(RISDEVDIR)/riscom/build/makevers.ksh

prototypes:
	@mk_test

world:
	@mk_test
	@$(MAKE) cleanworld	
	@$(MAKE) subdirs	
	@$(MAKE) fast

cleanworld:
	@for DIR in $(DIRS); \
	do \
		if [ -d $(RISDEVDIR)/ristools/$$DIR ] ; then \
			echo;\
			echo "\tCleaning directory $$DIR";\
			cd $(RISDEVDIR)/ristools/$$DIR;\
			$(MAKE) cleanup;\
		fi ; \
	done
	@if [ "$(MAKE_TPG)" = "YES" ] ; then \
		if [ -d $(RISDEVDIR)/ristools/tpg ] ; then \
			echo;\
			echo "\tCleaning directory tpg";\
			cd $(RISDEVDIR)/ristools/tpg;\
			$(MAKE) cleanup;\
		fi ; \
	fi

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
