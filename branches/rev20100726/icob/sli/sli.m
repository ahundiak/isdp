SRC
$(EXNUC)/icob/sli

SOURCE=Slic
act_out.C
args_declare.C
begin.C
cmd_table.C
copy_lines.C
cpp_tfile.C
declare.C
def_actions.C
def_states.C
do_act.C
do_args.C
do_class.C
do_var.C
dump_sym.C
end.C
find_defn.C
find_msg.C
find_type.C
find_word.C
get_actions.C
get_escape.C
get_token.C
init_sli.C
insert_sym.C
iws_out.C
lookup.C
macro.C
make_fname.C
mandatory.C
modifier.C
next_state.C
open_file.C
options.C
put.C
put_strs.C
response.C
scan_dots.C
slic.C
slishellvar.C
sliyy.C
stacks.C
state_out.C
str_list_out.C
strip_quotes.C
sub_resp.C
table_out.C
tlist_out.C
trans_out.C
verify_sym.C
sliy.y
slil.l
sliml.l

EXEC=Slic
$(TARGET)/bin/Slic

LINKLIB=Slic
-ll

DEPLIB=Slic
$(TARGET)/icob/sli/print_vers.o

INCLUDE
$(TARGET)/icob/sli
$(EXNUC)/icob/include
$(EXNUC)/include
$(UMS_INC_PATH)

SPEC
$(EXNUC)/spec

DEFINE
CCDEF

POST_SPECIAL
YFLAGS = -d

$(TARGET)/icob/sli/print_vers.o:
	@echo 'char * give_version (){ return  "$(COB_VER_D)"; }' \
	    > print_vers.c; \
	echo 'print_version (){ printf ("Slic  '$(COB_VER)'  '`date`'\\n");}'\
	    >> print_vers.c;
	$(CCDEF) -c print_vers.c
	@if test "$(COPT)" != "-g"; \
	then \
		echo "\trm print_vers.c"; \
		rm print_vers.c; \
	else \
		echo "\tleaving print_vers.c"; \
	fi
	
sliy.o:
	@echo "\t$(SRC)/sliy.y -> sliy.o"
	@yacc $(YFLAGS) $(SRC)/sliy.y; \
	mv y.tab.c sliy.c
	$(CCDEF) -c sliy.c
	@if test "$(COPT)" != "-g"; \
	then \
		echo "\trm sliy.c"; \
		rm sliy.c; \
	else \
		echo "\tleaving sliy.c"; \
	fi
	touch $(TARGET)/icob/sli/makefile

slil.o:
	@echo "\t$(SRC)/slil.l -> slil.o"
	@lex $(SRC)/slil.l; \
	mv lex.yy.c slil.c
	$(CCDEF) -c slil.c
	@if test "$(COPT)" != "-g"; \
	then \
		echo "\trm slil.c"; \
		rm slil.c; \
	else \
		echo "\tleaving slil.c"; \
	fi

sliml.o:
	@echo "\t$(SRC)/sliml.l -> sliml.o"
	@lex $(SRC)/sliml.l; \
	sed -e "s/YYTYPE char/YYTYPE unsigned char/g" -e "s/yy/sliyy/g" -e "s/YY/sliYY/g" lex.yy.c >sliml.c; \
	rm lex.yy.c
	$(CCDEF) -c sliml.c
	@if test "$(COPT)" != "-g"; \
	then \
		echo "\trm sliml.c"; \
		rm sliml.c; \
	else \
		echo "\tleaving sliml.c"; \
	fi
END_SPECIAL

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

