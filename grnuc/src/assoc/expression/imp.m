
SRC
$(GRNUC)/src/assoc/expression

CC
$(COMPILER) -knr

SOURCE

expression.S
exp_util.I
exp_lib.I
exp_graph.I

exp_ovrdi.I
exp_univ.I
exp_cvrt.I

CO_exp.S
CO_expi.I

COchexp.S
COchexpi.I

text_exp.S
text_expi.I

expl.l
expy.y


exp_match.I
exp_simul.I
exp_bcksol.C
exp_invop.C
exp_loop.I

exp_di.I

InitValues.I
PckExp.I
exp_string.C

#ifndef NT
LIB
$(GRLIB)/lib/expression.o
#else
ARCHIVE
$(GRLIB)/lib/expression.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRLIB)/src/assoc/expression
$(GRNUC)/src/assoc/include_priv
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

POST_SPECIAL
$(lex_objects) :
	@echo
	@echo "\t$(SRC)/expl.l -> lex.yy.c <lex>"
	@lex $(SRC)/expl.l
	@echo "	lex.yy.c -> expl.C <sed>"
	@sed "s/yy/expy/g" lex.yy.c | sed "s/YY/E/g" > lex.yy.C
	@mv lex.yy.C expl.tmp
	@awk '{ if(n==0) { n=1; print "#ifndef clipper"; \
	                        print "#define clipper 1"; \
	                        print "#endif"; print; } \
	        else {print} \
	      }' n=0 expl.tmp >lex.yy.C
	@awk '/NLSTATE/	{ if(n==0) { n=1;} else { print "  ";}} \
	                { print; }' n=0 lex.yy.C > expl.tmp
	@mv expl.tmp lex.yy.C 
	@chmod 777 lex.yy.C
	@echo "	expl.C -> expl.c"
	@$(omcpp) $(IPATH) $(MKDOPT) lex.yy.C > expl.C
	@sed "s/yy/expy/g" expl.C | sed "s/YY/E/g" > expl.c
	@echo "	expl.c -> expl.o"
	@$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c expl.c;
	@if [ "$(DEBUG)" != "yes" ]; \
	then /bin/rm expl.c; \
	     /bin/rm expl.C; \
	fi
	@/bin/rm lex.yy.c
	@/bin/rm lex.yy.C
	@echo

$(yacc_objects) :
	@echo
	@echo "	$(SRC)/expy.y -> y.tab.c <yacc>"
	@sed 's/exp\$$/EXP_SHARK_EATER/g' $(SRC)/expy.y | sed 's/om\$$/OM_SHARK_EATER/g' | sed 's/co\$$/CO_SHARK_EATER/g' > shark.y
	@yacc -vd shark.y
	@echo "	y.tab.c -> expy.C <sed>"
	@sed "s/yy/expy/g" y.tab.c | sed "s/YY/EY/g"  >expy.tmp
	@sed "s/EXP_SHARK_EATER/exp$$/g" expy.tmp | sed "s/OM_SHARK_EATER/om$$/g" | sed "s/CO_SHARK_EATER/co$$/g" > expy.C
	@if test -s expy.h; \
	then mv expy.h expy.H; \
	else >expy.H; \
	fi
	@sed "s/yy/expy/g" y.tab.h | sed "s/YY/EY/g"  >expy.h
	@if diff expy.[hH] >/dev/null; \
	then mv expy.H expy.h; \
	else rm expy.H; \
	fi
	@echo "	expy.C -> expy.c"
	$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) expy.C > expy.c
	@echo "	expy.c -> expy.o"
	@$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c expy.c
	@if [ "$(DEBUG)" != "yes" ]; \
	then /bin/rm expy.c; \
	     /bin/rm expy.C; \
	fi
	@/bin/rm y.tab.c
	@/bin/rm y.output
	@/bin/rm y.tab.h
	@/bin/rm shark.y
END_SPECIAL
