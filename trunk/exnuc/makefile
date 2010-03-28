#
#	4/15/91
#	Top level makefile for exnuc
#
MAKEFLAGS=e

EXNUC:\
	env \
	transfer_makefiles_to_target_directory \
	binaries \
	config \
	STUBS \
	exnuc_objects \
	makelib \
	LIB \
	strip_bin \
	executable \
	package_tools

package_tools: $(TARGET)/package/makefile
	@echo "\n\tMaking package tools ..."; \
	cd $(TARGET)/package; \
	pwd; \
	$(MAKE)

env:
	@$(EXNUC)/build/checkEnv.sh \
		EXNUC "$(EXNUC)" \
		TARGET "$(TARGET)" \
		BASE "$(BASE)" \
		MAKEMAKE "$(MAKEMAKE)" \
		MAKE "$(MAKE)" \
		CC "$(CC)" \
		UNAME "$(UNAME)" \
		UNAMESR "$(UNAMESR)" \
		DOPT1 "$(DOPT1)" \
		PRODUCT_NAME "$(PRODUCT_NAME)" \
		PRODUCT_VERSION "$(PRODUCT_VERSION)" \
		BUILD "$(BUILD)"

binaries: \
	MAKEMAKE \
	MKPTYPES \
	OM_BIN \
	ICOB_BIN \
	EXEC_BIN \
	TRANS_BIN

MAKEMAKE:
	@echo "\n\tMaking makemake ..."
	@cd $(TARGET)/bin; \
	pwd; \
	if test "$(UNAME)" = "CLIX"; \
	then \
		$(MAKE) -f mkmk.mk; \
	elif test "$(UNAME)" = "IRIX"; \
	then \
		$(MAKE) -f mkmk.mksgi; \
	elif test "$(UNAMESR)" = "SunOS 4.1.2"; \
	then \
		$(MAKE) -f mkmk.mksun; \
	elif [ "$(UNAMESR)" = "SunOS 5.10" -o "$(UNAMESR)" = "SunOS 5.8" -o "$(UNAMESR)" = "SunOS 5.5" -o "$(UNAMESR)" = "SunOS 5.5.1" ]; \
	then \
		if test "`uname -m`" = "i86pc"; \
		then \
			$(MAKE) -f mkmk.mki5; \
		else \
			$(MAKE) -f mkmk.mks6; \
		fi \
	elif test "$(UNAMESR)" = "SunOS 5.2"; \
	then \
		$(MAKE) -f mkmk.mks5; \
	else \
		echo "$UNAME: invalid uname" >&2; \
		exit 2; \
	fi

MKPTYPES: $(TARGET)/bin/mkptypes.mk
	@echo "\n\tMaking mkptypes ..."
	@cd $(TARGET)/bin; \
	pwd; \
	$(MAKE) -f mkptypes.mk

$(TARGET)/bin/mkptypes.mk: $(EXNUC)/bin/mkptypes.m
	cd $(EXNUC)/bin; \
	$(MAKEMAKE) mkptypes.m $(TARGET)/bin/mkptypes.mk

$(TARGET)/bin/makefile: $(EXNUC)/bin/bin.m
	cd $(EXNUC)/bin; \
	$(MAKEMAKE) bin.m $(TARGET)/bin/makefile

OM_BIN:
	@echo "\n\tMaking OM_BIN..."; \
	cd $(TARGET)/om; \
	pwd; \
	$(MAKE) binaries


ICOB_BIN:
	@echo "\n\tMaking ICOB_BIN ..."; \
	cd $(TARGET)/icob; \
	pwd; \
	. $(EXNUC)/icob/cob.version; \
	$(MAKE) binaries

EXEC_BIN:
	@echo "\n\tMaking EXEC_BIN ..."; \
	cd $(TARGET)/exec; \
	pwd; \
	$(MAKE) binaries

TRANS_BIN:
	@echo "\n\tMaking TRANS_BIN ..."; \
	if test "$(UNAME)" = "CLIX" -o "`uname -m`" = "i86pc"; \
	then \
		echo "\tSorry $(TARGET)/trans not on CLIX & INTEL_SOLARIS"; \
	else \
		cd $(TARGET)/trans; \
		pwd; \
		$(MAKE) binaries; \
	fi

strip_bin:
	@echo "\n\tStripping files in $(TARGET)/bin ..."
	@cd $(TARGET)/bin; \
	set +e; \
	for FILE in `/bin/ls`; \
	do \
		case $$FILE \
		in \
			*.o|Exnuc) continue;; \
			autorecluster|copyOS|dros) \
				if test "$(UNAME)" = "CLIX"; \
				then \
					if test -n "`file $$FILE | fgrep 'not stripped'`"; \
					then \
						echo "\t$(BASE)/bin/istrip -p $(EXNUC)/bin/ci.proto $$FILE"; \
						$(BASE)/bin/istrip -p $(EXNUC)/bin/ci.proto $$FILE; \
					fi; \
				elif test "$(UNAME)" = "IRIX"; \
				then \
					if test -n "`file $$FILE | fgrep 'not stripped'`"; \
					then \
						echo "\tDo Not strip $$FILE"; \
					fi; \
				elif test "$(UNAME)" = "SunOS"; \
				then \
					if test -n "`file $$FILE | fgrep 'not stripped'`"; \
					then \
						echo "\tTemporarily do NOT strip $$FILE"; \
					fi; \
				fi;; \
			*) \
				if test -n "`file $$FILE | fgrep 'not stripped'`"; \
				then \
					echo "\tTemporarily do NOT strip $$FILE"; \
				fi;; \
		esac; \
	done

#					strip $$FILE; \
# To enable strip, insert previous line (without #) AFTER line: Temporarily do NOT strip

# 25 Mar 2010 - ah - Looks like the compiled files are in source control
config: \
	MSGSRC \
	$(TARGET)/config/command.cmp

MSGSRC:
	@echo "\n\tMaking message src ..."; \
	cd $(EXNUC)/config/english/messages/src; \
	pwd; \
	./msgbuild.sh $(EXNUC)/config/english/messages $(EXNUC)/include `\ls *.mb`;

#
#	The horrible mess that follows is used to cleanup the extra blanks
#	inserted in the command table by omcpp.
#

$(TARGET)/config/command.cmp: $(EXNUC)/config/exnuc.cmd
	@echo "\n\tMaking command.cmp ..."; \
	cd $(EXNUC)/config; \
	pwd; \
	$(BASE)/bin/omcpp -l $(DOPT1) -I$(EXNUC)/include exnuc.cmd | \
	nawk -F',' '{ \
			if ($$0 != "") { \
				if ($$1 != "") printf("%s", $$1); \
				if ($$2 != "") printf(",%s", $$2); \
				if ($$3 != "") printf(",%s", $$3); \
				if ($$4 != "") printf(",%s", $$4); \
				if ($$5 != "") printf(",%s", $$5); \
				if ($$6 != "") printf(",%s", $$6); \
				if ($$7 != "") printf(",%s", $$7); \
				if ($$8 != "") printf(",%s", $$8); \
				printf("\n"); \
			} \
		}' | \
	nawk '	{gsub("[ 	]*,[ 	]*", ",")}; \
		{print $$0}' | \
		sed -e 's/ \^ /\^/' -e 's/ 0/0/' -e 's/ \"/\"/' > $(TARGET)/config/command.cmp

transfer_makefiles_to_target_directory:
	@if test "$(EXNUC)" != "$(TARGET)"; \
	then \
		echo; \
		echo "	Transfering makefiles ..."; \
		$(EXNUC)/build/transfer.sh $(EXNUC) $(TARGET) `cat $(EXNUC)/build/exnucmakefiles`; \
	fi

exnuc_objects:
	@cd $(TARGET); \
	$(MAKE) objects

objects: \
	SPEC \
	OM \
	DICTIONARY \
	MESSAGE \
	ICOB \
	EXEC \
	OMTEST \
	RAP \
	IGEFEI \
	EXFORCEREF

SPEC: $(TARGET)/spec/makefile
	@echo "\n\tMaking spec ..."; \
	cd $(TARGET)/spec; \
	pwd; \
	$(MAKE)

$(TARGET)/spec/makefile: $(EXNUC)/spec/spec.m
	cd $(EXNUC)/spec; \
	$(MAKEMAKE) spec.m $(TARGET)/spec/makefile

OM:
	@echo "\n\tMaking OM ...";
	@cd $(TARGET)/om; \
	pwd; \
	$(MAKE) objects

OMTEST:
	@echo "\n\tMaking OM TEST ...";
	@cd $(TARGET)/om; \
	pwd; \
	$(MAKE) TEST

DICTIONARY: $(TARGET)/dict/makefile $(TARGET)/dict/speclist $(TARGET)/dict/specdep
	@echo "\n\tMaking dict ..."; \
	if test "$(UNAME)" = "CLIX" -o "`uname -m`" = "i86pc"; \
	then \
		echo "\tSorry $(TARGET)/dict not on CLIX & INTEL_SOLARIS"; \
	else \
		cd $(TARGET)/dict; \
		pwd; \
		$(MAKE); \
	fi

$(TARGET)/dict/makefile: $(EXNUC)/dict/dict.m
	cd $(EXNUC)/dict; \
	$(MAKEMAKE) dict.m $(TARGET)/dict/makefile

$(TARGET)/dict/speclist: $(EXNUC)/spec/spec.m $(EXNUC)/om/spec/spec.m
	@echo "\n\tMaking $(TARGET)/dict/speclist ..."; \
	FIRST=1; \
	echo "class_d=\c" > $(TARGET)/dict/speclist; \
	for FILE in `find $(EXNUC)/spec $(EXNUC)/om/spec -name '*.S' -print`; \
	do \
		if test "$$FILE" = "$(EXNUC)/spec/CEO.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/super_cmd.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_bckup.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_close.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_defbut.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_dig.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/IGEabsdig.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/IGEdigwin.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_exit.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_fbackup.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_file.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_funcky.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_listfm.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_menuchk.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_pricmd.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_retri.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_save.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_saveas.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_test.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_ver.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_rclkeyin.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_swapmenu.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/exec.S"; then continue; fi; \
		if test -n "$$FIRST"; then echo "\\"; FIRST=; else echo " \\"; fi; \
		echo "\t"'$$(TARGET)/dict/'"`basename $$FILE .S`.d\c"; \
	done >> $(TARGET)/dict/speclist; \
	echo >> $(TARGET)/dict/speclist

$(TARGET)/dict/specdep: $(EXNUC)/spec/spec.m $(EXNUC)/om/spec/spec.m
	@echo "\n\tMaking $(TARGET)/dict/specdep ..."; \
	echo > $(TARGET)/dict/specdep; \
	for FILE in `find $(EXNUC)/spec -name '*.S' -print`; \
	do \
		if test "$$FILE" = "$(EXNUC)/spec/CEO.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/super_cmd.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_bckup.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_close.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_defbut.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_dig.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/IGEabsdig.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/IGEdigwin.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_exit.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_fbackup.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_file.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_funcky.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_listfm.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_menuchk.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_pricmd.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_retri.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_save.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_saveas.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_test.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_ver.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_rclkeyin.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/EX_swapmenu.S"; then continue; fi; \
		if test "$$FILE" = "$(EXNUC)/spec/exec.S"; then continue; fi; \
		echo '$$(TARGET)/dict/'"`basename $$FILE .S`.d: "'$$(EXNUC)/spec/'"`basename $$FILE"; \
	done >> $(TARGET)/dict/specdep; \
	for FILE in `find $(EXNUC)/om/spec -name '*.S' -print`; \
	do \
		echo '$$(TARGET)/dict/'"`basename $$FILE .S`.d: "'$$(EXNUC)/om/spec/'"`basename $$FILE"; \
	done >> $(TARGET)/dict/specdep

MESSAGE:
	@echo "\n\tMaking message ..."; \
	cd $(TARGET)/message; \
	pwd; \
	$(MAKE)

ICOB:
	@echo "\n\tMaking icob ..."; \
	cd $(TARGET)/icob; \
	pwd; \
	. $(EXNUC)/icob/cob.version; \
	$(MAKE) objects

EXEC:
	@echo "\n\tMaking exec ..."; \
	cd $(TARGET)/exec; \
	pwd; \
	$(MAKE) objects

RAP: $(TARGET)/rap/makefile
	@echo "\n\tMaking rap ..."; \
	cd $(TARGET)/rap; \
	pwd; \
	$(MAKE)

$(TARGET)/rap/makefile: $(EXNUC)/rap/rap.m
	cd $(EXNUC)/rap; \
	$(MAKEMAKE) rap.m $(TARGET)/rap/makefile

IGEFEI: $(TARGET)/igefei/makefile
	@echo "\n\tMaking igefei ..."; \
	cd $(TARGET)/igefei; \
	pwd; \
	$(MAKE)

$(TARGET)/igefei/makefile: $(EXNUC)/igefei/igefei.m
	cd $(EXNUC)/igefei; \
	$(MAKEMAKE) igefei.m $(TARGET)/igefei/makefile

EXFORCEREF:
	@echo "\n\tMaking $(TARGET)/lib/exforceref.o ..."
	@if test "$(UNAME)" != "CLIX"; \
	then \
		echo "\tSorry $(TARGET)/lib/exforceref.o only on CLIX"; \
	else \
		touch exforceref.c; \
		$(MAKE) exforceref.o; \
		rm exforceref.c; \
		$(MAKE) $(TARGET)/lib/exforceref.o; \
	fi

$(TARGET)/lib/exforceref.o:
	ld -r -o $(TARGET)/lib/exforceref.o exforceref.o -u _fgetgrent -u _fgetpwent -u _getgrent -u _jrand48 -u _lrand48 -u _mrand48 -u _nrand48 -u _seed48 -u _srand48 -u _ttyslot; \
	rm exforceref.o

makelib:
	@echo "\n\tMaking $(TARGET)/exnucmakelib ..."
	@cd $(TARGET); \
	pwd; \
	if test "$(UNAME)" = "CLIX"; \
	then \
		if test "$(EXNUC)" != "$(TARGET)"; \
		then \
			if test "$(PRODUCT_NAME)" = "EXNUCX"; \
			then \
				sed 's/libexnuc./libXexnuc./g' $(EXNUC)/exnucmakelib >$(TARGET)/exnucmakelib; \
			else \
				cp $(EXNUC)/exnucmakelib $(TARGET); \
			fi; \
		fi; \
	else \
		cp $(EXNUC)/exnucSmakelib $(TARGET)/exnucmakelib; \
	fi

LIB: $(TARGET)/lib/makefile $(TARGET)/lib/objects.mk
	@echo "\n\tCreating library ...";
	@cd $(TARGET)/lib; \
	pwd; \
	$(MAKE) -f objects.mk; \
	$(MAKE)

$(TARGET)/lib/makefile: $(EXNUC)/lib/lib.m
	cd $(EXNUC)/lib; \
	$(MAKEMAKE) lib.m $(TARGET)/lib/makefile

$(TARGET)/lib/objects.mk: $(EXNUC)/lib/objects.m
	cd $(EXNUC)/lib; \
	$(MAKEMAKE) objects.m $(TARGET)/lib/objects.mk

executable: $(TARGET)/bin/makefile
	@echo "\n\tCreating exnuc executable image ...";
	@cd $(TARGET)/bin; \
	pwd; \
	PRODUCT_NAME=EXNUC $(MAKE) $(TARGET)/bin/Exnuc

STUBS: $(TARGET)/lib/linkstub.mk $(TARGET)/lib/fpstub.mk
	@echo "\n\tMaking fp stubs ..."; \
	if test "`uname -s`" = "SunOS"; \
	then \
	  cd $(TARGET)/lib; \
	  $(MAKE) -f linkstub.mk; \
	else \
	  echo "\tFP stubs are built only Solaris platforms"; \
	fi

$(TARGET)/lib/linkstub.mk: $(EXNUC)/lib/linkstub.m
	cd $(EXNUC)/lib; \
	$(MAKEMAKE) linkstub.m $(TARGET)/lib/linkstub.mk

$(TARGET)/lib/fpstub.mk: $(EXNUC)/lib/fpstub.m
	cd $(EXNUC)/lib; \
	$(MAKEMAKE) fpstub.m $(TARGET)/lib/fpstub.mk
