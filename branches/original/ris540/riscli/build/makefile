.SUFFIXES:
.SUFFIXES: .c .o

SHELL=/bin/ksh
UNAME=`uname -n`
SYSTEM_NAME=`uname -s`
CPU_NAME=`inqcpuid`

MAKE_STS_FILE=$(RISDEVDIR)/riscli/mk$(TARGET).sts

#################################################################

include $(RISDEVDIR)/riscli/build/defines

#################################################################

# this will make the executables in "bin"

fast:
	@mk_test
	@if [ -s $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi
	@$(MAKE) version
	@$(MAKE) source
	@$(MAKE) bin
	@if [ -s $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

continue:
	@mk_test
	@if [ "`grep -s "version" $(MAKE_STS_FILE)`" != "version" ]; then \
		echo "\t$(MAKE) version"; $(MAKE) version;\
	else \
		echo "\tskipping version";\
	fi
	@if [ "`grep -s "source" $(MAKE_STS_FILE)`" != "source" ]; then \
		echo "\t$(MAKE) source"; $(MAKE) source;\
	else \
		echo "\tskipping source";\
	fi
	@if [ "`grep -s "bin" $(MAKE_STS_FILE)`" != "bin" ]; then \
		echo "\t$(MAKE) bin"; $(MAKE) bin;\
	else \
		echo "\tskipping bin";\
	fi

world:
	@mk_test
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi
	@$(MAKE) subdirs
	@$(MAKE) cleanworld
	@$(MAKE) version
	@$(MAKE) prototypes
	@export RIS_BUILD_ALL=1; $(MAKE) source
	@$(MAKE) bin
	@$(MAKE) keyword
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

keyword:
	@if [ $(SYSTEM_NAME) = "CLIX" ] && [ $(CPU_NAME) = "C300" ] ; then \
		if [ -f $(RISDEVDIR)/riscli/bin/c100/mkkeydoc ] ; then \
			$(RISDEVDIR)/riscli/bin/c100/mkkeydoc \
				-t $(RISDEVDIR)/riscli/doc/keyword.doc; fi; \
	elif [ $(SYSTEM_NAME) = "CLIX" ] && [ $(CPU_NAME) = "C400" ] ; then \
		if [ -f $(RISDEVDIR)/riscli/bin/c400/mkkeydoc ] ; then \
			$(RISDEVDIR)/riscli/bin/c400/mkkeydoc \
				-t $(RISDEVDIR)/riscli/doc/keyword.doc; fi; \
	else \
		if [ -f $(RISDEVDIR)/riscli/bin/$(BINDIR)/mkkeydoc ] ; then \
			$(RISDEVDIR)/riscli/bin/$(BINDIR)/mkkeydoc \
				-t $(RISDEVDIR)/riscli/doc/keyword.doc; fi; \
	fi

subdirs:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		if [ ! -d $(RISDEVDIR)/riscli/$$DIR/prt ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/prt";\
			mkdir $(RISDEVDIR)/riscli/$$DIR/prt;\
		fi ; \
		if [ ! -d $(RISDEVDIR)/riscli/$$DIR/$(OBJDIR) ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/$(OBJDIR)";\
			mkdir $(RISDEVDIR)/riscli/$$DIR/$(OBJDIR);\
		fi ; \
	done
	@if [ ! -d $(RISDEVDIR)/riscli/bin/$(BINDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory bin/$(BINDIR)";\
		mkdir $(RISDEVDIR)/riscli/bin/$(BINDIR);\
	fi ;

unused_files:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/riscli/$$DIR"; \
		cd $(RISDEVDIR)/riscli/$$DIR; $(MAKE) unused_files; \
	done

prototypes:
	@mk_test
	@(for DIR in $(SOURCE_DIRS); do \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/riscli/$$DIR"; \
		cd $(RISDEVDIR)/riscli/$$DIR; $(MAKE) prototypes; \
	done) ;

version:
	@mk_test
	@$(RISDEVDIR)/riscom/build/makevers.ksh
	@echo "version" >> $(MAKE_STS_FILE)

source:
	@mk_test
	@echo "\tMaking source"
	@for DIR in $(SOURCE_DIRS); \
	do \
		if [ "`grep -s "$$DIR" $(MAKE_STS_FILE)`" != "$$DIR" ]; then \
			echo; \
			echo "\tMaking directory $(RISDEVDIR)/riscli/$$DIR"; \
			cd $(RISDEVDIR)/riscli/$$DIR; $(MAKE); \
			echo "$$DIR" >> $(MAKE_STS_FILE); \
		else \
			echo "\tskipping $$DIR"; \
		fi ; \
	done
	@echo "source" >> $(MAKE_STS_FILE)

bin:
	@mk_test
	@cd $(RISDEVDIR)/riscli/bin;	$(MAKE)
	@echo "bin" >> $(MAKE_STS_FILE)

cleanworld:
	@mk_test
	$(MAKE) cleanobjdir
	$(MAKE) cleanmakeout
	$(MAKE) cleanprototypes
	$(MAKE) cleanbin

cleanobjdir:
	@mk_test
	@cd $(RISDEVDIR)/riscli; \
	if [ `pwd` = $(RISDEVDIR)/riscli ] ; \
	then \
	rm -f   ./[a-c]*/$(OBJDIR)/* ; \
	rm -f   ./[d-m]*/$(OBJDIR)/* ; \
	rm -f   ./[n-z]*/$(OBJDIR)/* ; \
	fi ; 

cleanmakeout:
	@mk_test
	@rm -f	$(RISDEVDIR)/riscli/*/makeout

cleanprototypes:
	@mk_test
	@cd $(RISDEVDIR)/riscli; \
	if [ `pwd` = $(RISDEVDIR)/riscli ] ; \
	then \
	rm -f	./[a-m]*/prt/* ; \
	rm -f	./[n-z]*/prt/* ; \
	fi ;

cleanbin:
	@mk_test
	@rm -f $(RISDEVDIR)/riscli/bin/$(BINDIR)/*

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
