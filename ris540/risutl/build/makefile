.SUFFIXES:
.SUFFIXES: .c .o

SHELL=/bin/ksh

UMS_MSG_DIR=$(RISDEVDIR)/risutl/config/english/messages
UMS_TXT_DIR=$(RISDEVDIR)/risutl/config/english/messages/src
MAKE_STS_FILE=$(RISDEVDIR)/risutl/mk$(TARGET).sts

#################################################################

include $(RISDEVDIR)/risutl/build/defines

#################################################################

fast:
	@mk_test
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi
	@$(MAKE) version
	@$(MAKE) errors
	@$(MAKE) source
	@$(MAKE) lib
	@$(MAKE) bin 
	@$(MAKE) helpindex 
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

continue:
	@mk_test
	@if [ "`grep -s "version" $(MAKE_STS_FILE)`" != "version" ]; \
	then \
		$(MAKE) version;\
	else \
		echo "\tskipping version";\
	fi
	@if [ "`grep -s "errors" $(MAKE_STS_FILE)`" != "errors" ]; \
	then \
		$(MAKE) errors;\
	else \
		echo "\tskipping errors";\
	fi
	@if [ "`grep -s "source" $(MAKE_STS_FILE)`" != "source" ]; \
	then \
		$(MAKE) source;\
	else \
		echo "\tskipping source";\
	fi
	@if [ "`grep -s "lib" $(MAKE_STS_FILE)`" != "lib" ]; \
	then \
		$(MAKE) lib;\
	else \
		echo "\tskipping lib";\
	fi
	@if [ "`grep -s "bin" $(MAKE_STS_FILE)`" != "bin" ]; \
	then \
		$(MAKE) bin;\
	else \
		echo "\tskipping bin";\
	fi 

world:
	@mk_test
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi
	$(MAKE) cleanworld
	$(MAKE) subdirs
	$(MAKE) prototypes
	$(MAKE) version
	$(MAKE) errors
	export RIS_BUILD_ALL=1; $(MAKE) source
	$(MAKE) lib
	$(MAKE) bin
	$(MAKE) helpindex 
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

unused_files:
	@mk_test
	@if [ $(BINDIR) != "sco" ] ; \
	then \
		SOURCE_SUBDIRS="$(SOURCE_DIRS)" ;\
	else \
		SOURCE_SUBDIRS="$(SCO_SOURCE_DIRS)" ;\
	fi ;\
	for DIR in $$SOURCE_SUBDIRS ;\
	do \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/risutl/$$DIR"; \
		cd $(RISDEVDIR)/risutl/$$DIR;\
		$(MAKE) unused_files; \
	done

prototypes:
	@mk_test
	@if [ $(BINDIR) != "sco" ] ; \
	then \
		SOURCE_SUBDIRS="$(SOURCE_DIRS)" ;\
	else \
		SOURCE_SUBDIRS="$(SCO_SOURCE_DIRS)" ;\
	fi ;\
	for DIR in $$SOURCE_SUBDIRS ;\
	do\
		echo;\
		echo "\tMaking directory $(RISDEVDIR)/risutl/$$DIR" ;\
		cd $(RISDEVDIR)/risutl/$$DIR ;\
		$(MAKE) prototypes ;\
	done

subdirs:
	@mk_test
	@if [ $(BINDIR) != "sco" ] ; \
	then \
		SOURCE_SUBDIRS="$(SOURCE_DIRS)" ;\
	else \
		SOURCE_SUBDIRS="$(SCO_SOURCE_DIRS)" ;\
	fi ;\
	for DIR in $$SOURCE_SUBDIRS ;\
	do \
		if [ ! -d $(RISDEVDIR)/risutl/$$DIR/prt ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/prt";\
			mkdir $(RISDEVDIR)/risutl/$$DIR/prt;\
		fi ; \
		if [ ! -d $(RISDEVDIR)/risutl/$$DIR/$(OBJDIR) ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/$(OBJDIR)";\
			mkdir $(RISDEVDIR)/risutl/$$DIR/$(OBJDIR);\
		fi ; \
	done
	@if [ ! -d $(RISDEVDIR)/risutl/lib/$(LIBDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory lib/$(LIBDIR)";\
		mkdir $(RISDEVDIR)/risutl/lib/$(LIBDIR);\
	fi ;
	@if [ ! -d $(RISDEVDIR)/risutl/bin/$(BINDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory bin/$(BINDIR)";\
		mkdir $(RISDEVDIR)/risutl/bin/$(BINDIR);\
	fi ;

version:
	@mk_test
	@$(RISDEVDIR)/riscom/build/makevers.ksh
	@echo "version" >> $(MAKE_STS_FILE)

errors:
	@mk_test
	@$(MAKE) $(UMS_MSG_DIR)/utl.msg
	@echo "errors" >> $(MAKE_STS_FILE)

$(UMS_MSG_DIR)/utl.msg: $(UMS_TXT_DIR)/risutl.txt
	@mk_test
	@mkutlerr.ksh

source:
	@mk_test
	@if [ $(BINDIR) != "sco" ] ; \
	then \
		SOURCE_SUBDIRS="$(SOURCE_DIRS)" ;\
	else \
		SOURCE_SUBDIRS="$(SCO_SOURCE_DIRS)" ;\
	fi ;\
	echo ;\
	echo "\tMaking source"; \
	for DIR in $$SOURCE_SUBDIRS ;\
	do \
		if [ "`grep -s "^$$DIR$$" $(MAKE_STS_FILE)`" != "$$DIR" ]; \
		then \
			echo; \
			echo "\tMaking directory $(RISDEVDIR)/risutl/$$DIR"; \
			cd $(RISDEVDIR)/risutl/$$DIR; $(MAKE); \
			echo "$$DIR" >> $(MAKE_STS_FILE); \
		else \
			echo "\tskipping $$DIR"; \
		fi ; \
	done; \
	echo "source" >> $(MAKE_STS_FILE)

lib:
	@mk_test
	@echo
	@echo "\tMaking directory $(RISDEVDIR)/risutl/lib"
	@cd $(RISDEVDIR)/risutl/lib; $(MAKE)
	@echo "lib" >> $(MAKE_STS_FILE)

bin:
	@mk_test
	@echo
	@echo "\tMaking directory $(RISDEVDIR)/risutl/bin"
	@cd $(RISDEVDIR)/risutl/bin; $(MAKE)
	@echo "bin" >> $(MAKE_STS_FILE)

helpindex:
	@mk_test
	@echo
	@echo "\tMaking Help index"
	@cd $(RISDEVDIR)/risutl/config/english/help; $(MAKE)
	@echo "helpindex" >> $(MAKE_STS_FILE)

cleanworld:
	@mk_test
	$(MAKE) cleanobjdir
	$(MAKE) cleanmakeout
	$(MAKE) cleanprototypes
	$(MAKE) cleanlib
	$(MAKE) cleanbin

cleanobjdir:
	@mk_test
	@rm -f   $(RISDEVDIR)/risutl/[a-m]*/$(OBJDIR)/[a-m]*
	@rm -f   $(RISDEVDIR)/risutl/[a-m]*/$(OBJDIR)/*
	@rm -f   $(RISDEVDIR)/risutl/un*/$(OBJDIR)/[a-m]*
	@rm -f   $(RISDEVDIR)/risutl/un*/$(OBJDIR)/*
	@rm -f   $(RISDEVDIR)/risutl/uc*/$(OBJDIR)/[a-m]*
	@rm -f   $(RISDEVDIR)/risutl/uc*/$(OBJDIR)/*
	@rm -f   $(RISDEVDIR)/risutl/*/$(OBJDIR)/*

cleanmakeout:
	@mk_test
	@rm -f	$(RISDEVDIR)/risutl/*/makeout

cleanprototypes:
	@mk_test
	@cd $(RISDEVDIR); rm -f risutl/[a-m]*/prt/*
	@cd $(RISDEVDIR); rm -f risutl/[n-z]*/prt/*

cleanlib:
	@mk_test
	@rm -f $(RISDEVDIR)/risutl/lib/$(LIBDIR)/*

cleanbin:
	@mk_test
	@cd $(RISDEVDIR)/risutl/bin; mk $(TARGET) rmlinks
	@rm -f $(RISDEVDIR)/risutl/bin/$(BINDIR)/*

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

