.SUFFIXES:
.SUFFIXES: .c .o

SHELL=/bin/ksh

UMS_MSG_DIR=$(RISDEVDIR)/riscom/config/english/messages
UMS_TXT_DIR=$(RISDEVDIR)/riscom/config/english/messages/src

MAKE_STS_FILE=$(RISDEVDIR)/riscom/mk$(TARGET).sts

#################################################################

include $(RISDEVDIR)/riscom/build/defines

#################################################################

fast:
	@mk_test
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi
	@if [ "$(MAKE_PARSE)" = "YES" ] ; then \
		cd $(RISDEVDIR)/riscom/parsetpg; $(MAKE) tpg_flag; \
	fi
	@$(MAKE) errors
	@$(MAKE) source
	@$(MAKE) lib
	@$(MAKE) bin
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

continue:
	@mk_test
	@if [ "`grep -s "errors" $(MAKE_STS_FILE)`" != "errors" ]; then \
		echo "\t$(MAKE) errors"; $(MAKE) errors;\
	else \
		echo "\tskipping errors";\
	fi
	@if [ "`grep -s "source" $(MAKE_STS_FILE)`" != "source" ]; then \
		echo "\t$(MAKE) source"; $(MAKE) source;\
	else \
		echo "\tskipping source";\
	fi
	@if [ "`grep -s "lib" $(MAKE_STS_FILE)`" != "lib" ]; then \
		echo "\t$(MAKE) lib"; $(MAKE) lib;\
	else \
		echo "\tskipping lib";\
	fi
	@if [ "`grep -s "bin" $(MAKE_STS_FILE)`" != "bin" ]; then \
		echo "\t$(MAKE) bin"; $(MAKE) bin;\
	else \
		echo "\tskipping bin";\
	fi
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

world:
	@mk_test
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi
	$(MAKE) cleanworld
	$(MAKE) subdirs
	$(MAKE) prototypes
	@if [ "$(MAKE_PARSE)" = "YES" ] ; then \
		cd $(RISDEVDIR)/riscom/parsetpg; $(MAKE) tpg_flag; \
	fi
	$(MAKE) errors
	export RIS_BUILD_ALL=1; $(MAKE) source
	$(MAKE) lib
	$(MAKE) bin
	@if [ -f $(MAKE_STS_FILE) ]; then rm -f $(MAKE_STS_FILE) 2>/dev/null; fi

prototypes:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/riscom/$$DIR"; \
		cd $(RISDEVDIR)/riscom/$$DIR; $(MAKE) prototypes; \
	done
	@if [ "$(MAKE_PARSE)" = "YES" ] ; then \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/riscom/parse"; \
		cd $(RISDEVDIR)/riscom/parse; $(MAKE) prototypes; \
	fi

subdirs:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		if [ ! -d $(RISDEVDIR)/riscom/$$DIR/prt ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/prt";\
			mkdir $(RISDEVDIR)/riscom/$$DIR/prt;\
		fi ; \
		if [ ! -d $(RISDEVDIR)/riscom/$$DIR/$(OBJDIR) ] ; then \
			echo;\
			echo "\tCreating subdirectory $$DIR/$(OBJDIR)";\
			mkdir $(RISDEVDIR)/riscom/$$DIR/$(OBJDIR);\
		fi ; \
	done
	@if [ "$(MAKE_PARSE)" = "YES" ] ; then \
		if [ ! -d $(RISDEVDIR)/riscom/parse/prt ] ; then \
			echo;\
			echo "\tCreating subdirectory parse/prt";\
			mkdir $(RISDEVDIR)/riscom/parse/prt;\
		fi ; \
		if [ ! -d $(RISDEVDIR)/riscom/parse/$(OBJDIR) ] ; then \
			echo;\
			echo "\tCreating subdirectory parse/$(OBJDIR)";\
			mkdir $(RISDEVDIR)/riscom/parse/$(OBJDIR);\
		fi ; \
		if [ ! -d $(RISDEVDIR)/riscom/parsetpg/$(OBJDIR) ] ; then \
			echo;\
			echo "\tCreating subdirectory parsetpg/$(OBJDIR)";\
			mkdir $(RISDEVDIR)/riscom/parsetpg/$(OBJDIR);\
		fi ; \
	fi
	@if [ ! -d $(RISDEVDIR)/riscom/lib/$(LIBDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory lib/$(LIBDIR)";\
		mkdir $(RISDEVDIR)/riscom/lib/$(LIBDIR);\
	fi ;
	@if [ ! -d $(RISDEVDIR)/riscom/bin/$(BINDIR) ] ; then \
		echo;\
		echo "\tCreating subdirectory bin/$(BINDIR)";\
		mkdir $(RISDEVDIR)/riscom/bin/$(BINDIR);\
	fi ;

errors:
	@mk_test
	@$(MAKE) $(UMS_MSG_DIR)/ris.msg
	@$(MAKE) $(UMS_MSG_DIR)/net.msg
	@echo "errors" >> $(MAKE_STS_FILE)

$(UMS_MSG_DIR)/ris.msg: \
	$(UMS_TXT_DIR)/riserr.txt \
	$(UMS_TXT_DIR)/risinf.txt \
	$(UMS_TXT_DIR)/rispmt.txt \
	$(UMS_TXT_DIR)/risdyn.txt \
	$(UMS_TXT_DIR)/ristpg.txt
	@mk_test
	@mkriserr.ksh

$(UMS_MSG_DIR)/net.msg: \
	$(UMS_TXT_DIR)/risnet.txt
	@mk_test
	@mkneterr.ksh

unused_files:
	@mk_test
	@for DIR in $(SOURCE_DIRS); \
	do \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/riscom/$$DIR"; \
		cd $(RISDEVDIR)/riscom/$$DIR; $(MAKE) unused_files; \
	done 
	@if [ "$(MAKE_PARSE)" = "YES" ] ; then \
		echo; \
		echo "\tMaking directory $(RISDEVDIR)/riscom/parse"; \
		cd $(RISDEVDIR)/riscom/parse; $(MAKE) unused_files; \
	fi

source:
	@mk_test
	@echo "\tMaking source"
	@for DIR in $(SOURCE_DIRS); \
	do \
		if [ "`grep -s "$$DIR" $(MAKE_STS_FILE)`" != "$$DIR" ]; \
		then \
			echo; \
			echo "\tMaking directory $(RISDEVDIR)/riscom/$$DIR"; \
			cd $(RISDEVDIR)/riscom/$$DIR; $(MAKE); \
			echo "$$DIR" >> $(MAKE_STS_FILE); \
		else \
			echo "\tskipping $$DIR"; \
		fi; \
	done
	@if [ "$(MAKE_PARSE)" = "YES" ] ; then \
		if [ "`grep -s "parse" $(MAKE_STS_FILE)`" != "parse" ]; \
		then \
			echo; \
			echo "\tMaking directory $(RISDEVDIR)/riscom/parse"; \
			cd $(RISDEVDIR)/riscom/parse; $(MAKE); \
			echo "parse" >> $(MAKE_STS_FILE); \
		else \
			echo "\tskipping parse"; \
		fi; \
		if [ "`grep -s "parsetpg" $(MAKE_STS_FILE)`" != "parsetpg" ]; \
		then \
			echo; \
			echo "\tMaking directory $(RISDEVDIR)/riscom/parsetpg"; \
			cd $(RISDEVDIR)/riscom/parsetpg; $(MAKE) make objects; \
			echo "parsetpg" >> $(MAKE_STS_FILE); \
		else \
			echo "\tskipping parsetpg"; \
		fi; \
	fi
	@echo "source" >> $(MAKE_STS_FILE)

lib:
	@mk_test
	@echo
	@echo "\tMaking directory $(RISDEVDIR)/riscom/lib"
	@cd $(RISDEVDIR)/riscom/lib;	$(MAKE)
	@echo "lib" >> $(MAKE_STS_FILE) 

bin:
	@mk_test
	@echo
	@echo "\tMaking directory $(RISDEVDIR)/riscom/bin"
	@cd $(RISDEVDIR)/riscom/bin;	$(MAKE)
	@echo "bin" >> $(MAKE_STS_FILE) 

install:
	@mk_test
	@echo; \
	case $(TARGET) in \
		"c100"|"c400")	PLATFORM=CLIX ;; \
		"sco")			PLATFORM=sco ;; \
		"sun")			PLATFORM=SunOS4 ;; \
		"Sol2"|"Soli")	PLATFORM=Solaris ;; \
		"hpux")			PLATFORM=HP-UX ;; \
	esac; \
	RIS_PLATFORM=$$PLATFORM devinstl.ksh

cleanworld:
	@mk_test
	$(MAKE) cleanobjdir
	$(MAKE) cleanmakeout
	$(MAKE) cleanprototypes
	$(MAKE) cleanlib
	$(MAKE) cleanbin
	$(MAKE) cleanmsg

cleanobjdir:
	@mk_test
	@cd $(RISDEVDIR)/riscom; \
	if [ `pwd` = $(RISDEVDIR)/riscom ] ; \
	then \
	rm -f	./[a-n]*/$(OBJDIR)/* ; \
	rm -f	./[o-z]*/$(OBJDIR)/* ; \
	fi ;

cleanmakeout:
	@mk_test
	@rm -f	$(RISDEVDIR)/riscom/*/makeout

cleanmsg:
	@mk_test
	@rm -f	$(RISDEVDIR)/riscom/config/english/messages/net.msg
	@rm -f	$(RISDEVDIR)/riscom/config/english/messages/ris.msg

cleanprototypes:
	@mk_test
	@cd $(RISDEVDIR)/riscom; \
	if [ `pwd` = $(RISDEVDIR)/riscom ] ; \
	then \
	rm -f	./[a-i]*/prt/* ; \
	rm -f	./[j-r]*/prt/* ; \
	rm -f	./[s-z]*/prt/* ; \
	fi ;

cleanlib:
	@mk_test
	@rm -f $(RISDEVDIR)/riscom/lib/$(LIBDIR)/*

cleanbin:
	@mk_test
	@cd $(RISDEVDIR)/riscom/bin; rm -f $(EXECUTABLES)
	@rm -f $(RISDEVDIR)/riscom/bin/$(BINDIR)/*

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
