.SUFFIXES:
.SUFFIXES: .c .o

SHELL=/bin/ksh


MAKE_STS_FILE=$(RISDEVDIR)/risapp/mk$(TARGET).sts

#################################################################

include $(RISDEVDIR)/risapp/build/defines

#################################################################

# this will make the executables in "bin"

fast:
	@mk_test
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi
	@$(MAKE) version
	@$(MAKE) source
	@$(MAKE) lib
	@$(MAKE) bin
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

continue:
	@mk_test
	@if [ "`grep -s "version" $(MAKE_STS_FILE)`" != "version" ]; \
	then \
		echo "\t$(MAKE) version"; $(MAKE) version;\
	else \
		echo "\tskipping version";\
	fi
	@if [ "`grep -s "source" $(MAKE_STS_FILE)`" != "source" ]; \
	then \
		echo "\t$(MAKE) source"; $(MAKE) source;\
	else \
		echo "\tskipping source";\
	fi
	@if [ "`grep -s "lib" $(MAKE_STS_FILE)`" != "lib" ]; \
	then \
		echo "\t$(MAKE) lib"; $(MAKE) lib;\
	else \
		echo "\tskipping lib";\
	fi
	@if [ "`grep -s "bin" $(MAKE_STS_FILE)`" != "bin" ]; \
	then \
		echo "\t$(MAKE) bin"; $(MAKE) bin;\
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
	export RIS_BUILD_ALL=1; $(MAKE) source
	$(MAKE) lib
	$(MAKE) bin
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

unused_files:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/risapp/$$DIR"; \
		cd $(RISDEVDIR)/risapp/$$DIR; $(MAKE) unused_files; \
	done

prototypes:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/risapp/$$DIR"; \
		cd $(RISDEVDIR)/risapp/$$DIR; $(MAKE) prototypes; \
	done

subdirs:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		if [ ! -d $(RISDEVDIR)/risapp/$$DIR/prt ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/prt";\
			mkdir $(RISDEVDIR)/risapp/$$DIR/prt;\
		fi ; \
		if [ ! -d $(RISDEVDIR)/risapp/$$DIR/$(OBJDIR) ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/$(OBJDIR)";\
			mkdir $(RISDEVDIR)/risapp/$$DIR/$(OBJDIR);\
		fi ; \
	done
	@if [ ! -d $(RISDEVDIR)/risapp/lib/$(LIBDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory lib/$(LIBDIR)";\
		mkdir $(RISDEVDIR)/risapp/lib/$(LIBDIR);\
	fi ;
	@if [ ! -d $(RISDEVDIR)/risapp/bin/$(BINDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory bin/$(BINDIR)";\
		mkdir $(RISDEVDIR)/risapp/bin/$(BINDIR);\
	fi ;

version:
	@mk_test
	@$(RISDEVDIR)/riscom/build/makevers.ksh
	@echo "version" >> $(MAKE_STS_FILE)

source:
	@mk_test
	@echo "\tMaking source"
	@for DIR in $(SOURCE_DIRS); \
	do \
		if [ "`grep -s "$$DIR" $(MAKE_STS_FILE)`" != "$$DIR" ]; \
		then \
			echo; \
			echo "\tMaking directory $(RISDEVDIR)/risapp/$$DIR"; \
			cd $(RISDEVDIR)/risapp/$$DIR; $(MAKE); \
			echo "$$DIR" >> $(MAKE_STS_FILE); \
		else \
			echo "\tskipping $$DIR"; \
		fi ; \
	done;
	@echo "source" >> $(MAKE_STS_FILE)

lib:
	@mk_test
	@echo
	@echo "\tMaking directory $(RISDEVDIR)/risapp/lib"
	@cd $(RISDEVDIR)/risapp/lib;	$(MAKE)
	@echo "lib" >> $(MAKE_STS_FILE)

bin:
	@mk_test
	@echo
	@echo "\tMaking directory $(RISDEVDIR)/risapp/bin"
	@cd $(RISDEVDIR)/risapp/bin;	$(MAKE)
	@echo "bin" >> $(MAKE_STS_FILE)
	
cleanworld:
	@mk_test
	$(MAKE) cleanobjdir
	$(MAKE) cleanmakeout
	$(MAKE) cleanprototypes
	$(MAKE) cleanlib
	$(MAKE) cleanbin

cleanobjdir:
	@mk_test
	@cd $(RISDEVDIR)/risapp ; \
	if [ `pwd` = $(RISDEVDIR)/risapp ] ; then \
	rm -f   ./*/$(OBJDIR)/* ; \
	fi ;

cleanmakeout:
	@mk_test
	@rm -f	$(RISDEVDIR)/risapp/*/makeout

cleanprototypes:
	@mk_test
	@cd $(RISDEVDIR)/risapp ; \
	if [ `pwd` = $(RISDEVDIR)/risapp ] ; then \
	rm -f	./[a-c]*/prt/* ; \
	rm -f	./[d-z]*/prt/* ; \
	fi ;

cleanlib:
	@mk_test
	@rm -f $(RISDEVDIR)/risapp/lib/*.[ao]
	@rm -f $(RISDEVDIR)/risapp/lib/$(LIBDIR)/*.[ao]

cleanbin:
	@mk_test
	@cd $(RISDEVDIR)/risapp/bin; rm -f $(EXECUTABLES)
	@rm -f $(RISDEVDIR)/risapp/bin/$(BINDIR)/$(EXECUTABLES)

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
