CC = cc -ga

OPPFLAGS =  \
	-I$(EXNUC)/include \
	-I$(EXNUC)/om/include \
	-I$(EXNUC)/spec \
	-I$(SRC)

SRC = $(EXNUC)/om/test

IPATH =  \
	-I$(EXNUC)/include \
	-I$(EXNUC)/om/include

.SUFFIXES: .C .I .S .c .o .x
CCDEF = $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2)

OMCPPDEF = $(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2)

opp = $(BASE)/bin/opp

omcpp = $(BASE)/bin/omcpp

MOPT = -Dclipper=1 -D__clipper__=1


# Object files 

C_objects = \
	OMTdrv.o \
	OMTdumprel.o \
	OMTab.o \
	OMTconnect.o \
	OMTwild.o \
	OMTrange.o \
	OMTmovech.o \
	OMTcopych.o \
	OMTsibling.o \
	OMTorder.o \
	OMTvararray.o \
	OMTisosend.o \
	OMTdynamic.o \
	OMTdynamic2.o \
	OMTdynamic3.o \
	OMTeyeso.o \
	OMTprodem.o \
	OMTroos.o \
	OMTrecog.o \
	OMTsupgrp.o \
	OMTos.o \
	OMTboolean.o \
	OMTclust.o \
	OMTgrptst.o \
	OMTvla.o \
	OMTsend.o \
	OMTsend51.o \
	OMTswap.o \
	OMTcdtime1.o \
	OMTcdtime2.o \
	OMTintrcpt.o \
	OMTbstring.o \
	OMTbint.o \
	OMTr2di.o \
	OMTsk2di.o \
	OMTr3dd.o \
	OMTsk3dd.o

spec_objects = \
	ResA.o \
	ResB.o \
	A.o \
	B.o \
	C.o \
	D.o

imp_objects = \
	ResAi.o \
	ResBi.o \
	Ai.o \
	Bi.o \
	Ci.o \
	Di.o

objects = \
	$(C_objects) \
	$(spec_objects) \
	$(imp_objects) 


# main target

target: \
	OMTdrv.x


# src group targets

objects: $(objects)

OMTdrv.o : \
	$(SRC)/OMTdrv.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMintprims.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/DIprims.h \
	$(EXNUC)/include/dload.h

OMTdumprel.o : \
	$(SRC)/OMTdumprel.C \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMintprims.h

OMTab.o : \
	$(SRC)/OMTab.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

OMTconnect.o : \
	$(SRC)/OMTconnect.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h

OMTwild.o : \
	$(SRC)/OMTwild.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

OMTrange.o : \
	$(SRC)/OMTrange.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

OMTmovech.o : \
	$(SRC)/OMTmovech.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

OMTcopych.o : \
	$(SRC)/OMTcopych.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMintprims.h

OMTsibling.o : \
	$(SRC)/OMTsibling.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

OMTorder.o : \
	$(SRC)/OMTorder.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

OMTvararray.o : \
	$(SRC)/OMTvararray.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

OMTisosend.o : \
	$(SRC)/OMTisosend.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMintprims.h

OMTdynamic.o : \
	$(SRC)/OMTdynamic.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h \
	$(EXNUC)/include/OMintprims.h \
	$(EXNUC)/include/DIprims.h \
	$(EXNUC)/include/DItypedef.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/DIglob.h

OMTdynamic2.o : \
	$(SRC)/OMTdynamic2.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h \
	$(EXNUC)/include/OMintprims.h \
	$(EXNUC)/include/DItypedef.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/DIglob.h \
	$(EXNUC)/include/DIprims.h

OMTdynamic3.o : \
	$(SRC)/OMTdynamic3.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h \
	$(EXNUC)/include/OMintprims.h

OMTeyeso.o : \
	$(SRC)/OMTeyeso.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

OMTprodem.o : \
	$(SRC)/OMTprodem.C \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h \
	$(EXNUC)/include/OMintprims.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMDB.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMbtreedef.h

OMTroos.o : \
	$(SRC)/OMTroos.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMintprims.h

OMTrecog.o : \
	$(SRC)/OMTrecog.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h \
	$(EXNUC)/include/OMintprims.h

OMTsupgrp.o : \
	$(SRC)/OMTsupgrp.C \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h

OMTos.o : \
	$(SRC)/OMTos.C \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/OMintprims.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMMOSD.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMparameters.h

OMTboolean.o : \
	$(SRC)/OMTboolean.C \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h

OMTclust.o : \
	$(SRC)/OMTclust.C \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMerrordef.h

OMTgrptst.o : \
	$(SRC)/OMTgrptst.C \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h

OMTvla.o : \
	$(SRC)/OMTvla.C \
	/usr/include/stdio.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h

OMTsend.o : \
	$(SRC)/OMTsend.C \
	/usr/include/sys/types.h \
	/usr/include/sys/times.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h

OMTsend51.o : \
	$(SRC)/OMTsend51.C \
	/usr/include/sys/types.h \
	/usr/include/sys/times.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h

OMTswap.o : \
	$(SRC)/OMTswap.C \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMMOSD.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMparameters.h \
	/usr/include/memory.h \
	/usr/include/string.h

OMTcdtime1.o : \
	$(SRC)/OMTcdtime1.C \
	/usr/include/sys/types.h \
	/usr/include/sys/times.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h

OMTcdtime2.o : \
	$(SRC)/OMTcdtime2.C \
	/usr/include/sys/types.h \
	/usr/include/sys/times.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMmetaclass.h \
	$(EXNUC)/om/include/OMeveryone.h

OMTintrcpt.o : \
	$(SRC)/OMTintrcpt.C \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/om/include/OMintercept.h

OMTbstring.o : \
	$(SRC)/OMTbstring.C \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMDB.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMbtreedef.h

OMTbint.o : \
	$(SRC)/OMTbint.C \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMDB.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMbtreedef.h

OMTr2di.o : \
	$(SRC)/OMTr2di.C \
	/usr/include/math.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/OMDB.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMrtreedef.h

OMTsk2di.o : \
	$(SRC)/OMTsk2di.C \
	/usr/include/math.h \
	$(EXNUC)/include/OMDB.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMrtreedef.h

OMTr3dd.o : \
	$(SRC)/OMTr3dd.C \
	/usr/include/math.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/OMDB.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMrtreedef.h

OMTsk3dd.o : \
	$(SRC)/OMTsk3dd.C \
	/usr/include/math.h \
	$(EXNUC)/include/OMDB.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMrtreedef.h

ResA.o : \
	$(SRC)/ResA.S \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S

ResB.o : \
	$(SRC)/ResB.S \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S

A.o : \
	$(SRC)/A.S \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S

B.o : \
	$(SRC)/B.S \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S

C.o : \
	$(SRC)/C.S \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S

D.o : \
	$(SRC)/D.S \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S \
	$(SRC)/C.S

ResAi.o : \
	$(SRC)/ResAi.I \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S \
	$(SRC)/ResA.S \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMerrordef.h

ResBi.o : \
	$(SRC)/ResBi.I \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S \
	$(SRC)/ResB.S \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

Ai.o : \
	$(SRC)/Ai.I \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S \
	$(SRC)/A.S \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMerrordef.h

Bi.o : \
	$(SRC)/Bi.I \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S \
	$(SRC)/B.S \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMspecify.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMobjectcomm.h

Ci.o : \
	$(SRC)/Ci.I \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S \
	$(SRC)/C.S \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMerrordef.h

Di.o : \
	$(SRC)/Di.I \
	$(EXNUC)/include/OMimport.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMdeport.h \
	$(EXNUC)/spec/Root.S \
	$(SRC)/C.S \
	$(SRC)/D.S

$(spec_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@F:.o=.S): $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$(SRC)/$(@:.o=.S) -> $(@:.o=.c)"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(@:.o=.S)"; fi; \
	 $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(@:.o=.S); \
	 if [ "$(FAST)" ]; \
	 then \
	    if test -z "$(VERBOSE_RULES)"; \
	    then \
	        echo "\t$(@:.o=.c) -> cc.list\c"; \
	    else \
	        echo "\techo \"$(@:.o=.c)\" >>cc.list"; \
	    fi; \
	    echo "$(@:.o=.c)" >>cc.list; \
	 else \
	    if test -z "$(VERBOSE_RULES)"; \
	    then \
	        echo "\t$(@:.o=.c) -> $(@)"; \
	    else \
	        echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c)"; \
	    fi; \
	    $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c); \
	    if [ "$(COPT)" != "-g" ]; \
	    then \
	        if test -z "$(VERBOSE_RULES)"; \
	        then \
	            echo "\tremoving $(@:.o=.c)"; \
	        else \
	            echo "\trm $(@F:.o=.c)"; \
	        fi; \
	        rm $(@F:.o=.c); \
	    else \
	        if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $(@:.o=.c)"; fi; \
	    fi; \
	 fi
	@echo 

$(imp_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@F:.o=.I): $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$(SRC)/$(@:.o=.I) -> $(@:.o=.c)"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(@:.o=.I)"; fi; \
	 $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(@:.o=.I); \
	 if [ "$(FAST)" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	        echo "\t$(@:.o=.c) -> cc.list\c"; \
	     else \
	        echo "\techo \"$(@:.o=.c)\" >>cc.list"; \
	     fi; \
	     echo "$(@:.o=.c)" >>cc.list; \
	 else \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$(@:.o=.c) -> $(@)"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c)"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c); \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	         if test -z "$(VERBOSE_RULES)"; \
	         then \
	             echo "\tremoving $(@:.o=.c)"; \
	         else \
	             echo "\trm $(@F:.o=.c)"; \
	         fi; \
	         rm $(@F:.o=.c); \
	     else \
	         if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $(@:.o=.c)"; fi; \
	     fi; \
	 fi
	@echo 

$(C_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@F:.o=.C): $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$(SRC)/$(@:.o=.C) -> $(@:.o=.c)"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(SRC)/$(@:.o=.C) $(@F:.o=.c)"; fi; \
	 $(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) \
		$(SRC)/$(@:.o=.C) $(@F:.o=.c); \
	 if [ "$(FAST)" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	        echo "\t$(@:.o=.c) -> cc.list\c"; \
	     else \
	        echo "\techo \"$(@:.o=.c)\" >>cc.list"; \
	     fi; \
	     echo "$(@:.o=.c)" >>cc.list; \
	 else \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$(@:.o=.c) -> $(@)"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c)"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c); \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	         if test -z "$(VERBOSE_RULES)"; \
	         then \
	             echo "\tremoving $(@:.o=.c)"; \
	         else \
	             echo "\trm $(@F:.o=.c)"; \
	         fi; \
	         rm $(@F:.o=.c); \
	     else \
	         if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $(@:.o=.c)"; fi; \
	     fi; \
	 fi
	@echo 

.I.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$< -> $*.c"; \
	 else \
	     echo "\t$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<"; \
	 fi
	@$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<
	@if [ "$(FAST)" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$*.c -> cc.list\c"; \
	     else \
	         echo "\techo \"$*.c\" >>cc.list"; \
	     fi; \
	     echo "$*.c" >>cc.list; \
	 else \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$*.c -> $*.o"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c; \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	        if test -z "$(VERBOSE_RULES)"; \
	        then \
	            echo "\tremoving $*.c"; \
	        else \
	            echo "\trm $*.c"; \
	        fi; \
	        rm $*.c; \
	     else \
	        if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $*.c"; fi; \
	     fi; \
	 fi
	@echo 

.C.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$< -> $*.c"; \
	 else \
	     echo "\t$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $< $*.c"; \
	 fi
	@$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $< $*.c
	@if [ "$(FAST)" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$*.c -> cc.list\c"; \
	     else \
	         echo "\techo \"$*.c\" >>cc.list"; \
	     fi; \
	     echo "$*.c" >>cc.list; \
	 else \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$*.c -> $*.o"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c; \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	        if test -z "$(VERBOSE_RULES)"; \
	        then \
	            echo "\tremoving $*.c"; \
	        else \
	            echo "\trm $*.c"; \
	        fi; \
	        rm $*.c; \
	     else \
	        if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $*.c"; fi; \
	     fi; \
	 fi
	@echo 

.S.c:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ "$(FAST)" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$< -> opp.list\c"; \
	     else \
	         echo "\techo \"$<\" >>opp.list"; \
	     fi;\
	     echo "$<" >>opp.list; \
	 else \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$< -> $*.c"; \
	     else \
	         echo "\t$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<"; \
	     fi; \
	     $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<; \
	 fi
	@echo 

.c.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$< -> $*.o"; \
	 else \
	     echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	 fi
	@$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c
	@echo 

#
 #    TEST makefile
 #
 #    main targets:: 
 #
 #         AllTests:  Tthis target is generally used to run all std tests.
 #                    It will recursively call itself to perform the makes.
 #                    One side effect is that after a test has successfully
 #                     run - there will be a zero block .x file to keep track
 #                     of which tests have been run.
 #
 #      OMT<test>.x: This target is used to make a specific test.
 #
 #
 #      TESTER:      This target is used in the recursive call to specify that
 #                    the test should be built, run, and checked against .std
 #                    file for differences
 #
 #
 #      TESTER_NEW:  This target is used just as TESTER but it is for tests
 #                    which do not have a .std file (no output is a good
 #                    result)
 #
 #      TEST:        This target is used to make - but NOT run a std test.
 #                    One may enter this target via the action macro on the
 #                    command line. e.g.  make -r OMTab.x action=TEST
 #
 #
 #      Because some tests do not use the standard .S and .I files (A.S,B.S...)
 #       they had to be entered as a specific target in order to override the
 #	 macros (specs and impls).  Also they needed a unique classinit file
 #	other than the standard (OMTstdz.C).
 #
 #      Any of the macros may be overridden by inputing them on the make
 #	command line.  Be sure to group via double quotes if more than one
 #	file is to be macroized. e.q. specs="my.S my2.S my3.S"
 #

action   = TESTER
opl      = $(BASE)/bin/opl
ztest    = OMTstdz

deplibs = $(LIBXC)/libxc.a

linklibs = -lg -lmalloc $(deplibs) -lix -lm -lbsd


omlib    = $(TARGET)/lib/libOM.a

specs = \
	ResA.o \
	ResB.o \
	A.o \
	B.o \
	C.o \
	D.o

impls = $(specs:.o=i.o)

supobjs = \
	OMTdumprel.o \
	OMapplinit.o

tests = \
	OMTab.C \
	OMTconnect.C \
	OMTwild.C \
	OMTrange.C \
	OMTmovech.C \
	OMTcopych.C \
	OMTsibling.C \
	OMTorder.C \
	OMTvararray.C \
	OMTisosend.C \
	OMTdynamic.C \
	OMTdynamic2.C \
	OMTdynamic3.C \
	OMTeyeso.C \
	OMTprodem.C \
	OMTroos.C \
	OMTrecog.C \
	OMTsupgrp.C

newtests = \
	OMTos.C \
	OMTboolean.C \
	OMTclust.C \
	OMTgrptst.C \
	OMTvla.C \
	OMTsend.C \
	OMTsend51.C \
	OMTswap.C \
	OMTcdtime1.C \
	OMTcdtime2.C \
	OMTintrcpt.C

treetests = \
	OMTbstring.C \
	OMTbint.C \
	OMTr2di.C \
	OMTsk2di.C \
	OMTr3dd.C \
	OMTsk3dd.C

AllTests: $(tests:.C=.x) $(newtests:.C=.x) $(treetests:.C=.x)

$(ztest).C: $(specs)
	$(opl) -o $(ztest).C  $(specs)

TEST:: $(ftest).o $(ztest).o $(specs) $(impls) $(supobjs) $(omlib) $(deplibs)
	@echo "************************************************************"
	@echo "*********************************** makeing $(ftest).x"
	@echo "************************************************************"
	$(CCDEF) -o $(ftest).x $(ftest).o $(specs) $(impls) \
         $(supobjs) $(omlib) $(ztest).o $(linklibs)

TESTER:: $(ftest).o $(ztest).o $(specs) $(impls) $(supobjs)
	@echo "************************************************************"
	@echo "*********************************** makeing $(ftest).x"
	@echo "************************************************************"
	$(CCDEF) -o $(ftest).x $(ftest).o $(specs) $(impls) \
         $(supobjs) $(omlib) $(ztest).o $(linklibs)

TESTER_NEW:: $(ftest).o $(ztest).o $(specs) $(impls) $(supobjs)
	@echo "************************************************************"
	@echo "*********************************** makeing $(ftest).x"
	@echo "************************************************************"
	$(CCDEF) -o $(ftest).x $(ftest).o $(specs) $(impls) \
         $(supobjs) $(omlib) $(ztest).o $(linklibs)

OMTsend.x: $(specs) $(impls) timea.o timeai.o
	$(MAKE) -r TESTER_NEW ftest=$* \
	ztest=OMTsendz \
	omlib=$(omlib) \
	specs="$(specs) timea.o" \
	impls="$(impls) timeai.o"

dyn_specs=clsa.o clsb.o clsc.o clse.o
dyn_impls=$(dyn_specs:.o=i.o)
OMTdynamic.x: $(dyn_specs) $(dyn_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTdynamicz \
	omlib=$(omlib) \
	specs="$(dyn_specs)" \
	impls="$(dyn_impls)"

OMTdynamic2.x: $(dyn_specs) $(dyn_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTdynamicz \
	omlib=$(omlib) \
	specs="$(dyn_specs)" \
	impls="$(dyn_impls)"

OMTdynamic3.x: $(dyn_specs) $(dyn_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTdynamicz \
	omlib=$(omlib) \
	specs="$(dyn_specs)" \
	impls="$(dyn_impls)"

pro_specs=clsa.o clsb.o clsc.o clse.o parenta.o parentb.o clsd.o clsf.o \
          clsg.o clsq.o clsr.o dump_btree.o OMTpb.o
pro_impls=$(pro_specs:.o=i.o)
OMTprodem.x: $(pro_specs) $(pro_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTprodemz \
	omlib=$(omlib) \
	specs="$(pro_specs)" \
	impls="$(pro_impls)"

rec_specs=clsj.o sub_clsj.o clsd.o sub_clsb.o clsa.o clsb.o clsc.o clse.o \
          clsf.o clsg.o clsh.o sub_clsh.o
rec_impls=$(rec_specs:.o=i.o)
OMTrecog.x: $(rec_specs) $(rec_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTrecogz \
	omlib=$(omlib) \
	specs="$(rec_specs)" \
	impls="$(rec_impls)"

OMTboolean.x: testa.o testai.o testb.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTbooleanz \
	omlib=$(omlib) \
	specs="testa.o testb.o" \
	impls="testai.o"

OMTos.x: $(specs) $(impls)
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTstdz \
	omlib=$(omlib) \
	specs="$(specs)" \
	impls="$(impls)"

51_specs=$(specs) class1.o class2.o class3.o class4.o class5.o
51_impls=$(impls) class1i.o
OMTsend51.x: $(51_specs) $(51_impls)
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTsend51z \
	omlib=$(omlib) \
	specs="$(51_specs)" \
	impls="$(51_impls)"

OMTcdtime1.x: testa.o testai.o testb.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTbooleanz \
	omlib=$(omlib) \
	specs="testa.o testb.o" \
	impls="testai.o"

OMTcdtime2.x: testa.o testai.o testb.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTbooleanz \
	omlib=$(omlib) \
	specs="testa.o testb.o" \
	impls="testai.o"

OMTclust.x: g.o gi.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTclustz \
	omlib=$(omlib) \
	specs="g.o" \
	impls="gi.o"

OMTgrptst.x: g.o gi.o OMTgrptsti.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTclustz \
	omlib=$(omlib) \
	specs="g.o" \
	impls="gi.o OMTgrptsti.o"

OMTintrcpt.x: g.o gi.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTclustz \
	omlib=$(omlib) \
	specs="g.o" \
	impls="gi.o"

OMTswap.x: c1.o c1i.o OMTswaptsti.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTswapz \
	omlib=$(omlib) \
	specs="c1.o" \
	impls="c1i.o OMTswaptsti.o"

OMTvla.x: vla.o vlai.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTvlaz \
	omlib=$(omlib) \
	specs="vla.o" \
	impls="vlai.o"

OMTbstring.x: OMTpr.o OMTpri.o OMTpb.o OMTpbi.o A.o Ai.o B.o Bi.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTbstringz \
	omlib=$(omlib) \
	specs="OMTpr.o OMTpb.o A.o B.o" \
	impls="OMTpri.o OMTpbi.o Ai.o Bi.o"

OMTbint.x: OMTpr.o OMTpri.o OMTpb.o OMTpbi.o A.o Ai.o B.o Bi.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTbstringz \
	omlib=$(omlib) \
	specs="OMTpr.o OMTpb.o A.o B.o" \
	impls="OMTpri.o OMTpbi.o Ai.o Bi.o"

OMTr2di.x: $(specs) $(impls) OMTpr.o OMTpri.o OMTdumpR2di.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTr2diz \
	omlib=$(omlib) \
	supobjs="$(supobjs) OMTdumpR2di.o" \
	specs="$(specs) OMTpr.o" \
	impls="$(impls) OMTpri.o"

OMTsk2di.x: OMTpr.o OMTpri.o OMTdumpR2di.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTsk2diz \
	omlib=$(omlib) \
	supobjs="$(supobjs) OMTdumpR2di.o" \
	specs="OMTpr.o" \
	impls="OMTpri.o"

OMTr3dd.x: $(specs) $(impls) OMTpr.o OMTpri.o OMTdumpR3dd.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTr2diz \
	omlib=$(omlib) \
	supobjs="$(supobjs) OMTdumpR3dd.o" \
	specs="$(specs) OMTpr.o" \
	impls="$(impls) OMTpri.o"

OMTsk3dd.x: $(specs) $(impls) OMTpr.o OMTpri.o OMTdumpR3dd.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTr2diz \
	omlib=$(omlib) \
	supobjs="$(supobjs) OMTdumpR3dd.o" \
	specs="$(specs) OMTpr.o" \
	impls="$(impls) OMTpri.o"

OMapplinit.o :
	$(opl) -a
	$(OMCPPDEF) OMapplinit.C OMapplinit.c
	$(CCDEF) -c OMapplinit.c

OMTdrv.x : OMTdrv.o $(specs) $(impls) $(supobjs) $(omlib) $(deplibs)
	$(MAKE) TEST ftest=OMTdrv ztest=OMTdrvz \
        omlib="$(omlib)" \
        specs="$(specs)" \
        impls="$(impls)"

.C.x:
	$(MAKE) -r $(action) ftest=$* ztest=$(ztest) \
        omlib="$(omlib)" \
        specs="$(specs)" \
        impls="$(impls)"

