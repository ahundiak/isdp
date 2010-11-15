SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscom/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END

SRC
$(RISDEVDIR)/riscom/parsetpg

INCLUDE
#if defined(sun)
/usr/5include
#endif
#if defined(unix)
/usr/include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
#endif
#if defined(DOS)
$(HIGHCDIR)\inc
#endif

$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/riscom/parse/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
action.c
column.c
db.c
embed.c
expr.c
host.c
literal.c
misc.c
parse.c
pred.c
privs.c
query.c
ris_stmt.c
schema.c
set_func.c
stmt.c
table.c
type.c
update.c
value.c

POST_SPECIAL
#if defined(unix)
$(C_OBJECTS):
	@mk_test
	@echo
	@echo "\t$(@:.o=.c)   ->   $(OBJDIR)/$@"
	@echo "\tCompiling with $(CC) $(COPT)"
	@because $?
	@$(CC) -c $(COPT) $(DOPT) $(IPATH) $(SRC)/$(@:.o=.c)
	@chk_prt -r $(IFDEF_FLAG) -n$(NONFUNCTIONS) $(DOPT) $(IPATH) $(SRC)/$(@:.o=.c)
	@echo "\tPrototypes enforced"
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscom\build\rulesc.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\riscom\build\rulesc.dos
#endif
END
