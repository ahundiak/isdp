#
# script to produce the grdict.m file for the grdict directory
#

cd $GRTARG/dict
rm CO*.S 
rm *.c
\ls *.[ST] > /tmp/dict.$$
cat << EO > grdict.m
SUFFIXES
.T .S

INCLUDE
.
\$(GRNUC)/ingrsys
\$(INGRHOME)/include
\$(XINC)
#ifdef XGL
\$(XGLHOME)/include
\$(XGLHOME)/include/xgl
#endif
\$(GRNUC)/include
\$(EXNUC)/include
\$(BS)/include

SPEC
\$(EXNUC)/spec
\$(GRNUC)/spec


SRC
.

SOURCE
EO

#
# add source files to grdict.m 
#
cat /tmp/dict.$$ >> grdict.m
rm /tmp/dict.$$

cat << EO >> grdict.m
CC 
cc \$(IPATH)

SPECIAL
APP = \$(GRTARG)
DDP = \$(EXTARG)/bin/ddp -DX11 \$(MKDOPT)
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
	#    $*.S -> \$*.
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
