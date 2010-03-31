# script to generate the mddict.m file

cd $MDTARG/dict
rm *.c
rm NM*.S
\ls *.[ST] > /tmp/dict.$$
cat << EO > mddict.m
SUFFIXES
.T .S

INCLUDE
.
\$(INGRHOME)/include
\$(XINC)
#ifdef XGL
\$(XGLHOME)/include
\$(XGLHOME)/include/xgl
#endif
\$(MODEL)/include
\$(MODEL)/proto_include
\$(GRNUC)/include
\$(EXNUC)/include
\$(BS)/include
\$(BS)/include/prototypes
\$(GRNUC)/ingrsys

SPEC
\$(EXNUC)/spec
\$(GRNUC)/spec
\$(MODEL)/spec


SRC
.

SOURCE
EO

cat /tmp/dict.$$ >> mddict.m
rm /tmp/dict.$$

cat << EO >> mddict.m
CC
cc \$(IPATH)

SPECIAL
APP = \$(MDTARG)
DDP = \$(EXTARG)/bin/ddp \$(MKDOPT)
CCD = \$(EXTARG)/bin/ccd
CTD = \$(EXTARG)/bin/ctd
END_SPECIAL

TARGET
main_target

POST_SPECIAL
main_target: \$(objects)
	#Creating \$(APP)/config/class_defns
	@cat \$(objects) > \$(APP)/config/class_defns
END_SPECIAL


POST_SPECIAL
.T.o:
	#$<
	#    \$*.T -> \$*.S
	@\$(CTD) \$*
	#    \$*.S -> \$*.
	@\$(DDP) \$(OPPFLAGS) \$*.S
	#    \$*. -> \$*.c
	@\$(CCD) \$* > \$*.c
	#    \$*.c -> \$*.d
	@\$(CC) \$*.c -o \$*
	@\$*
	@mv \$*.d \$*.o
	@rm \$*.c \$*
	@echo; echo

.S.o:
	#$<
	#    \$*.S -> \$*.
	@\$(DDP) \$(OPPFLAGS) \$*.S
	#    \$*. -> \$*.c
	@\$(CCD) \$* > \$*.c
	#    \$*.c -> \$*.d
	@\$(CC) \$*.c -o \$*
	@\$*
	@mv \$*.d \$*.o
	@rm \$*.c \$*
	@echo; echo
END_SPECIAL

NORULES
EO


