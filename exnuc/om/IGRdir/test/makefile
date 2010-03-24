.SUFFIXES: .I .S .C .o

.PRECIOUS: Run

# Definitions  

om = ../..
om_bin = ${om}/bin
om_inc = ${om}/../include
om_spec = ${om}/spec
om_lib = ${om}/lib

opp = ${om_bin}/opp

omcpp = $(om_bin)/omcpp

CFLAGS = -g -I../spec -I$(debug) -I$(exec) -I$(om_inc)


CC = cc -ga 
COPT =

# Preprocessor inc options

IPATH =  \
	-I${exec} \
	-I${debug} \
	-I${om}/../include 

# Compiler options

# Libraries to be linked by the loader

LINKLIB = 

# OPP and OMCPP options 

OPPFLAGS=  \
	-I../spec \
	-I${om}/spec \
	-I${exec} \
	-I${debug} \
	-I${om}/../include


# Object files 

objects = \
	dummy.o \
	dummi.o \
	myclass.o \
	tst_dir.o \
	tst_diri.o \
	mkdir.o \
	rmdir.o \
	add.o \
	send.o \
	link.o \
	uname.o \
	trans.o \
	search.o \
	search1.o \
	search2.o \
	search3.o \
	untrans.o \
	ls.o \
	find.o \
	index.o \
	pass.o \
	mkpath.o \
	load.o \
	cg.o \
	change_group.o \
	cp.o \
	create.o \
	stat.o \
	valid.o \
	mount.o \
	test.o \
	DIstring.o \
	suntran.o \
	suntrans.o \
	cd.o \
	main.o


Run : $(objects) opl image




main.o : \
	main.I \
	${om}/../include/OMimport.h \
	${om}/../include/OMlimits.h \
	${om}/../include/OMminimum.h \
	${om}/../include/OMprimindex.h \
	${om}/../include/OMprimitives.h \
	${om}/../include/OMdeport.h \
	${om}/spec/Root.S

dummy.o : \
	dummy.S \
	${om}/../include/OMimport.h \
	${om}/../include/OMlimits.h \
	${om}/../include/OMminimum.h \
	${om}/../include/OMprimindex.h \
	${om}/../include/OMprimitives.h \
	${om}/../include/OMdeport.h \
	${om}/spec/Root.S

dummi.o : \
	dummy.S \
	dummi.I \
	${om}/../include/OMimport.h \
	${om}/../include/OMlimits.h \
	${om}/../include/OMminimum.h \
	${om}/../include/OMprimindex.h \
	${om}/../include/OMprimitives.h \
	${om}/../include/OMdeport.h \
	${om}/spec/Root.S

DIvariable.o : \
	DIvariable.S \
	${om}/../include/OMimport.h \
	${om}/../include/OMlimits.h \
	${om}/../include/OMminimum.h \
	${om}/../include/OMprimindex.h \
	${om}/../include/OMprimitives.h \
	${om}/../include/OMdeport.h \
	${om}/spec/Root.S

DIvariablei.o : \
	DIvariable.S \
	DIvariablei.I \
	${om}/../include/OMimport.h \
	${om}/../include/OMlimits.h \
	${om}/../include/OMminimum.h \
	${om}/../include/OMprimindex.h \
	${om}/../include/OMprimitives.h \
	${om}/../include/OMdeport.h \
	${om}/spec/Root.S
mkdir.o : \
	mkdir.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


rmdir.o : \
	rmdir.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


add.o : \
	add.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

send.o : \
	send.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


link.o : \
	link.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

uname.o : \
	uname.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


trans.o : \
	trans.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

search.o : \
	search.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

search1.o : \
	search1.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

search2.o : \
	search2.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

search3.o : \
	search3.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

untrans.o : \
	untrans.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


ls.o : \
	ls.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

find.o : \
	find.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


index.o : \
	index.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


mkpath.o : \
	mkpath.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


tst_dir.o : \
	tst_dir.S \
	${om_spec}/Root.S

tst_diri.o : \
	tst_diri.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


pass.o : \
	pass.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


load.o : \
	load.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

DIstring.o : \
	DIstring.C

test.o : \
	test.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


cg.o : \
	cg.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


change_group.o : \
	change_group.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


cp.o : \
	cp.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


create.o : \
	create.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


stat.o : \
	stat.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


valid.o : \
	valid.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

mount.o : \
	mount.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

suntrans.o : \
	suntrans.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S

suntran.o : \
	suntran.I \
	${om_inc}/OMimport.h \
	${om_inc}/OMlimits.h \
	${om_inc}/OMminimum.h \
	${om_inc}/OMprimindex.h \
	${om_inc}/OMprimitives.h \
	${om_inc}/OMdeport.h \
	${om_spec}/Root.S


opl: 	main.I
	@echo "\n\n\n\t...opl\n"
	$(om_bin)/opl \
	$(objects)
	@$(omcpp) -I$(om_inc) OMclassinit.C > OMclassinit.c
	@cc ${CFLAGS} -p -c -ga -I$(om_inc) OMclassinit.c

#	@echo "\t\tundef ..."
#	@undef_dir >/dev/null 2>&1

image: \
	main.I
	@echo "\t\tlink ..."
	ld -o Run \
	/lib/crt1.o \
	../../../lib/OMinit.o \
	OMclassinit.o \
	OMapplinit.o \
	$(objects) \
        ./execv.o \
	../lib/DIbtree.L \
	../lib/DIrectory.L \
	../lib/GRoup.L \
	../../../archlib/libexnucar.a \
	-lxc \
	./bigstub.o \
	-lix -lbsd -lm -lmalloc -lc /lib/crtn.o
	@echo ""
	@echo ""
	@ls -ls Run
	@echo ""

.C.o :
	@echo " $< -> $*.c"			# OPP
	@echo "\n remaking $*.o because of : $? \n"
	@${omcpp} ${OPPOPT} $(OPPFLAGS) $< $*.c
	@echo "	$*.c -> $*.o"
	@cp $*.c /tmp/tmp_c_file
	@cat /tmp/tmp_c_file | fgrep -v "#line" > $*.c
	@$(CC) -c $(COPT) $(DOPT) $(IPATH) $*.c
	@if test "$(COPT)" != "-g"; then rm $*.c; echo "	removing $*.c"; \
	else echo "	leaving $*.c ";fi
	@if test "$(DOPT)" = "-DDEBUG"; then echo "	debug verion of $*.c\
 compiled";fi

.S.o .R.o:
	@echo "	$< -> $*.c"
	@${opp} ${OPPOPT} $(OPPFLAGS) $<
	@echo "	$*.c -> $*.o"
	@$(CC) -c $(COPT) $(IPATH) $*.c
	@if test "$(COPT)" != "-g"; then rm $*.c; echo "Removing $*.c";\
	else echo "	debug version $*.c left";fi

.I.o:
	@echo " $< -> $*.c"			# OPP
	@echo "\n remaking $*.o because of : $? \n"
	@${opp} ${OPPOPT} $(OPPFLAGS) $<
	@echo " $*.c -> $*.o"
	@cp $*.c /tmp/tmp_c_file
	@cat /tmp/tmp_c_file | fgrep -v "#line" > $*.c
	@$(CC) -c $(COPT) $(IPATH) $*.c
	@if test "$(COPT)" != "-g"; then rm $*.c ; echo "Removing $*.c";\
	else echo "debug version $*.c left"; fi

.S.c .R.c :
	@echo "	$< -> $*.c"
	@${opp} ${OPPOPT} ${OPPFLAGS} $<
	@echo "	$*.c -> $*.o"
	@$(CC) -c $(COPT) $(IPATH) $*.c
	@if test "$(COPT)" != "-g"; then rm $*.c $*.c; echo "Removing $*.c";\
	else echo "	debug version $*.c left";fi

.I.c:
	@echo " $< -> $*.c"			# OPP
	@echo "\n remaking $*.o because of : $? \n"
	@${opp} ${OPPOPT} $(OPPFLAGS) $<
