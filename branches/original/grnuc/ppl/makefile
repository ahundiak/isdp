.SUFFIXES: .S .I .C .c .o

ver=0

CC = acc -knr -o3
CCFILTER = 2>&1 | sed -f $(GRNUC)/acc.sed

SRC = .

DOPT = 

LINKLIB = 

OPPFLAGS =  \
	-I/usr2/ip32/modelsrc/include \
	-I/usr2/ip32/grnucsrc/include \
	-I/usr/ip32/exnucdp/include \
	-I/usr/ip32/bspmathdp/include \
	-I/usr2/ip32/modelsrc/spec \
	-I/usr2/ip32/grnucsrc/spec \
	-I/usr/ip32/exnucdp/om/spec \
	-I/usr/ip32/exnucdp/exec/spec

IPATH =  \
	-I/usr2/ip32/modelsrc/include \
	-I/usr2/ip32/grnucsrc/include \
	-I/usr/ip32/exnucdp/include \
	-I/usr/ip32/bspmathdp/include

opp = /usr/ip32/exnucdp/bin/opp

omcpp = /usr/ip32/exnucdp/bin/omcpp


# Object files 

c_objects = \
	GO2bcclisect.o \
	GOarcptrdcv.o \
	GOarctnbcp.o \
	GObcsclisect.o \
	GOcdtto2bc.o \
	GOcttobc.o \
	GOfillet.o \
	GRhvls2pt.o \
	GRaals2pt.o \
	GR2bcisectut.o \
	GRgetbuffer.o \
	GRload3dconi.o \
	GRgentransu.o \
	GRls2pt.o \
	GRls2ptrt.o \
	GRorthoseg.o \
	GRpostrtrans.o \
	GRposttransu.o \
	GRprerout.o \
	GRpytransuti.o \
	GRsetarc.o \
	GRsortevents.o \
	GRtransrange.o \
	GRvtsegrtang.o \
	GRar2ptrad.o \
	GRar2ptradrt.o \
	GRar3pt.o \
	GRar3ptrt.o \
	GRarc2ptr.o \
	GRarcaxpt.o \
	GRarcnptang.o \
	GRarcnptangr.o \
	GRarcnradpts.o \
	GRargenabsg.o \
	GRbclnextend.o \
	GRbrlncon.o \
	GRcbclnexten.o \
	GRcheckrel.o \
	GRclorthpg.o \
	GRcr2ptrad.o \
	GRcr2ptradrt.o \
	GRcr3pt.o \
	GRcr3ptrt.o \
	GRcrc2ptr.o \
	GRcrcnrad.o \
	GRcrcnradrt.o \
	GRcrdiam.o \
	GRcrdiamrt.o \
	GReaaxaxpt.o \
	GReaaxaxptrt.o \
	GReaaxptax.o \
	GReaaxptaxrt.o \
	GRelaxaxpt.o \
	GRelaxaxptrt.o \
	GRelcnaxpt.o \
	GRelcnaxptrt.o \
	GRxformarc.o \
	GRcheckortho.o \
	GRcheckplana.o \
	GRloadcs.o \
	GR2ptlsext.o \
	GOlpfrbs.o \
	GOlptobs.o

C_objects = \
	GR2objisect.o \
	GR2objminlin.o \
	GRabsgutil.o \
	GRpybcueq.o \
	HSgetprops.o \
	GRlnoffset.o \
	GRacthand.o \
	GRcheckcrit.o \
	GRlbgeomchk.o \
	GRinit_path.o \
	GR2objangbis.o

spc_objects =

imp_objects = \
	grmacrosi.o \
	grwireframei.o \
	GRnotifylist.o \
	GR2objaisect.o \
	GRaltchgclas.o \
	GRtchgclass.o \
	GRccschoice.o \
	GRchgclass.o \
	GRconsfunc.o \
	GRfillet.o \
	GRloccheck.o \
	GRget2objgeo.o \
	GRowneradd.o \
	GRownerrem.o \
	GRupdaterng.o \
	GRpladdpts.o \
	GRcnupdrang.o \
	GRdetpoint.o \
	GRaddptsutil.o \
	GRorthaddpts.o \
	GUprocessplo.o \
	GRprocessfit.o

objects = $(c_objects) $(C_objects) $(spc_objects) $(imp_objects)

/usr2/ip32/grnucsrc/lib/gosup.o: ${objects}
	@echo 
	@if [ "$(FAST)" ]; \
	 then \
	     if [ -s opp.list ]; \
	     then \
	         echo "\topping files"; \
	         if $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) `cat opp.list`; \
	         then \
	             cat opp.list | sed s/\\.[IS]/.c/ >>cc.list; \
	         else \
	             echo "\terror opping source"; \
	             exit 1; \
	         fi; \
	     else \
	         echo "\tnothing to opp"; \
	     fi; \
	     if [ -s cc.list ]; \
	     then \
	         echo "\tcompiling files"; \
	         $(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) `cat cc.list` \
                          $(CCFILTER); \
	         if [ "$(COPT)" != "-g" ]; \
	         then \
	             echo "\tremoving .c files"; \
	             rm `cat cc.list`; \
	         else \
	             echo "\tleaving .c files"; \
	         fi; \
	     else \
	         echo "\tnothing to compile"; \
	     fi; \
	 fi
	ld -r -o /usr2/ip32/grnucsrc/lib/gosup.o $(objects)
	@echo
	@rm -f opp.list cc.list
	@ls -ls /usr2/ip32/grnucsrc/lib/gosup.o
	@echo


# Source group targets

objects: $(objects)

GO2bcclisect.o : \
	$(SRC)/GO2bcclisect.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h

GOarcptrdcv.o : \
	$(SRC)/GOarcptrdcv.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GOarctnbcp.o : \
	$(SRC)/GOarctnbcp.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GObcsclisect.o : \
	$(SRC)/GObcsclisect.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h

GOcdtto2bc.o : \
	$(SRC)/GOcdtto2bc.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GOcttobc.o : \
	$(SRC)/GOcttobc.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GOfillet.o : \
	$(SRC)/GOfillet.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GRhvls2pt.o : \
	$(SRC)/GRhvls2pt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr2/ip32/grnucsrc/include/dperr.h \
	/usr2/ip32/grnucsrc/include/dpdef.h

GRaals2pt.o : \
	$(SRC)/GRaals2pt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr2/ip32/grnucsrc/include/dperr.h \
	/usr2/ip32/grnucsrc/include/dpdef.h

GR2bcisectut.o : \
	$(SRC)/GR2bcisectut.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GRgetbuffer.o : \
	$(SRC)/GRgetbuffer.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/gocmacros.h

GRload3dconi.o : \
	$(SRC)/GRload3dconi.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr2/ip32/grnucsrc/include/mapriv.h

GRgentransu.o : \
	$(SRC)/GRgentransu.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h

GRls2pt.o : \
	$(SRC)/GRls2pt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRls2ptrt.o : \
	$(SRC)/GRls2ptrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/bspmathdp/include/bserr.h

GRorthoseg.o : \
	$(SRC)/GRorthoseg.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRpostrtrans.o : \
	$(SRC)/GRpostrtrans.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GRposttransu.o : \
	$(SRC)/GRposttransu.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRprerout.o : \
	$(SRC)/GRprerout.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRpytransuti.o : \
	$(SRC)/GRpytransuti.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h

GRsetarc.o : \
	$(SRC)/GRsetarc.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRsortevents.o : \
	$(SRC)/GRsortevents.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/msdef.h

GRtransrange.o : \
	$(SRC)/GRtransrange.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMindex.h

GRvtsegrtang.o : \
	$(SRC)/GRvtsegrtang.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/mapriv.h \
	/usr/ip32/exnucdp/include/OMerrordef.h

GRar2ptrad.o : \
	$(SRC)/GRar2ptrad.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h

GRar2ptradrt.o : \
	$(SRC)/GRar2ptradrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GRar3pt.o : \
	$(SRC)/GRar3pt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRar3ptrt.o : \
	$(SRC)/GRar3ptrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GRarc2ptr.o : \
	$(SRC)/GRarc2ptr.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRarcaxpt.o : \
	$(SRC)/GRarcaxpt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRarcnptang.o : \
	$(SRC)/GRarcnptang.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRarcnptangr.o : \
	$(SRC)/GRarcnptangr.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h

GRarcnradpts.o : \
	$(SRC)/GRarcnradpts.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/dperr.h \
	/usr2/ip32/grnucsrc/include/dpdef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h

GRargenabsg.o : \
	$(SRC)/GRargenabsg.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr2/ip32/grnucsrc/include/gocmacros.h \
	/usr/ip32/exnucdp/include/msdef.h

GRbclnextend.o : \
	$(SRC)/GRbclnextend.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/godef.h

GRbrlncon.o : \
	$(SRC)/GRbrlncon.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRcbclnexten.o : \
	$(SRC)/GRcbclnexten.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRcheckrel.o : \
	$(SRC)/GRcheckrel.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/grgsdef.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/msdef.h

GRclorthpg.o : \
	$(SRC)/GRclorthpg.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/mapriv.h \
	/usr/ip32/exnucdp/include/msdef.h

GRcr2ptrad.o : \
	$(SRC)/GRcr2ptrad.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h

GRcr2ptradrt.o : \
	$(SRC)/GRcr2ptradrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr/ip32/exnucdp/include/msdef.h

GRcr3pt.o : \
	$(SRC)/GRcr3pt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h

GRcr3ptrt.o : \
	$(SRC)/GRcr3ptrt.c \
	/usr/ip32/bspmathdp/include/bserr.h \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRcrc2ptr.o : \
	$(SRC)/GRcrc2ptr.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRcrcnrad.o : \
	$(SRC)/GRcrcnrad.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRcrcnradrt.o : \
	$(SRC)/GRcrcnradrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GRcrdiam.o : \
	$(SRC)/GRcrdiam.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRcrdiamrt.o : \
	$(SRC)/GRcrdiamrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GReaaxaxpt.o : \
	$(SRC)/GReaaxaxpt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GReaaxaxptrt.o : \
	$(SRC)/GReaaxaxptrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GReaaxptax.o : \
	$(SRC)/GReaaxptax.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GReaaxptaxrt.o : \
	$(SRC)/GReaaxptaxrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GRelaxaxpt.o : \
	$(SRC)/GRelaxaxpt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRelaxaxptrt.o : \
	$(SRC)/GRelaxaxptrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GRelcnaxpt.o : \
	$(SRC)/GRelcnaxpt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h

GRelcnaxptrt.o : \
	$(SRC)/GRelcnaxptrt.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GRxformarc.o : \
	$(SRC)/GRxformarc.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/grerr.h

GRcheckortho.o : \
	$(SRC)/GRcheckortho.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/mapriv.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h

GRcheckplana.o : \
	$(SRC)/GRcheckplana.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/mapriv.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h

GRloadcs.o : \
	$(SRC)/GRloadcs.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h

GR2ptlsext.o : \
	$(SRC)/GR2ptlsext.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h

GOlpfrbs.o : \
	$(SRC)/GOlpfrbs.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GOlptobs.o : \
	$(SRC)/GOlptobs.c \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GR2objisect.o : \
	$(SRC)/GR2objisect.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h \
	/usr2/ip32/grnucsrc/include/maerr.h

GR2objminlin.o : \
	$(SRC)/GR2objminlin.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GRabsgutil.o : \
	$(SRC)/GRabsgutil.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/gocmacros.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h

GRpybcueq.o : \
	$(SRC)/GRpybcueq.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gocmacros.h \
	/usr/ip32/bspmathdp/include/bserr.h

HSgetprops.o : \
	$(SRC)/HSgetprops.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr2/ip32/grnucsrc/include/grdpbdef.h \
	/usr2/ip32/grnucsrc/include/grdpbmacros.h

GRlnoffset.o : \
	$(SRC)/GRlnoffset.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr/ip32/exnucdp/include/OMerrordef.h

GRacthand.o : \
	$(SRC)/GRacthand.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lc.h

GRcheckcrit.o : \
	$(SRC)/GRcheckcrit.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/lcmacros.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h

GRlbgeomchk.o : \
	$(SRC)/GRlbgeomchk.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/lcmacros.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h

GRinit_path.o : \
	$(SRC)/GRinit_path.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/lc.h

GR2objangbis.o : \
	$(SRC)/GR2objangbis.C \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

grmacrosi.o : \
	$(SRC)/grmacrosi.I \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/grdpbdef.h \
	/usr2/ip32/grnucsrc/include/grdpbmacros.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr/ip32/exnucdp/include/exmacros.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/grmacros.h \
	/usr2/ip32/grnucsrc/include/csmacros.h \
	/usr/ip32/exnucdp/include/DIdef.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr2/ip32/grnucsrc/spec/GRcmpowner.S \
	/usr2/ip32/grnucsrc/include/growner.h \
	/usr2/ip32/grnucsrc/spec/GRowner.S \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/spec/GRlbsys.S \
	/usr2/ip32/grnucsrc/spec/GRcoords.S \
	/usr2/ip32/grnucsrc/spec/GRgencs.S

grwireframei.o : \
	$(SRC)/grwireframei.I \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/grdpbdef.h \
	/usr2/ip32/grnucsrc/include/grdpbmacros.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr/ip32/exnucdp/include/exmacros.h \
	/usr2/ip32/grnucsrc/include/dpmacros.h \
	/usr2/ip32/grnucsrc/include/dperr.h \
	/usr2/ip32/grnucsrc/include/dpdef.h \
	/usr2/ip32/grnucsrc/include/comiscmac.h \
	/usr2/ip32/grnucsrc/include/grwireframe.h \
	/usr2/ip32/grnucsrc/include/grmacros.h \
	/usr2/ip32/grnucsrc/spec/GRlinear.S \
	/usr2/ip32/grnucsrc/spec/GRbspline.S \
	/usr2/ip32/grnucsrc/spec/GRconic.S \
	/usr2/ip32/grnucsrc/spec/GRcurve.S \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S

GRnotifylist.o : \
	$(SRC)/GRnotifylist.I \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/spec/GRlistener.S

GR2objaisect.o : \
	$(SRC)/GR2objaisect.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h \
	/usr2/ip32/grnucsrc/include/maerr.h

GRaltchgclas.o : \
	$(SRC)/GRaltchgclas.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/godef.h

GRtchgclass.o : \
	$(SRC)/GRtchgclass.I \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/spec/GRlinear.S \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/spec/GRcurve.S \
	/usr2/ip32/grnucsrc/spec/GRbspline.S \
	/usr2/ip32/grnucsrc/spec/GRconic.S

GRccschoice.o : \
	$(SRC)/GRccschoice.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/dperr.h \
	/usr2/ip32/grnucsrc/include/dpdef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grrouterpriv.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h

GRchgclass.o : \
	$(SRC)/GRchgclass.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/godef.h

GRconsfunc.o : \
	$(SRC)/GRconsfunc.I \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h \
	/usr2/ip32/grnucsrc/include/grownmacros.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/spec/IGEdisplay.S \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr/ip32/exnucdp/include/exmacros.h \
	/usr/ip32/exnucdp/exec/spec/module.S \
	/usr2/ip32/grnucsrc/spec/GRmodule.S \
	/usr2/ip32/grnucsrc/spec/GRconic.S \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/spec/GRcurve.S \
	/usr2/ip32/grnucsrc/spec/GRbspline.S \
	/usr2/ip32/grnucsrc/spec/GRlinear.S

GRfillet.o : \
	$(SRC)/GRfillet.I \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr/ip32/bspmathdp/include/bserr.h \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/spec/GRcurve.S

GRloccheck.o : \
	$(SRC)/GRloccheck.I \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/dpmacros.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr2/ip32/grnucsrc/include/lcmacros.h \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S

GRget2objgeo.o : \
	$(SRC)/GRget2objgeo.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/msdef.h

GRowneradd.o : \
	$(SRC)/GRowneradd.I \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/spec/IGEdisplay.S \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr/ip32/exnucdp/include/exmacros.h \
	/usr/ip32/exnucdp/exec/spec/module.S \
	/usr2/ip32/grnucsrc/spec/GRmodule.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/spec/GRcmpowner.S

GRownerrem.o : \
	$(SRC)/GRownerrem.I \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/spec/IGEdisplay.S \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr/ip32/exnucdp/include/exmacros.h \
	/usr/ip32/exnucdp/exec/spec/module.S \
	/usr2/ip32/grnucsrc/spec/GRmodule.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/spec/GRcmpowner.S

GRupdaterng.o : \
	$(SRC)/GRupdaterng.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/gopriv.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/spec/IGEdisplay.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/exnucdp/include/exdef.h \
	/usr/ip32/exnucdp/include/exmacros.h \
	/usr/ip32/exnucdp/exec/spec/module.S \
	/usr2/ip32/grnucsrc/spec/GRmodule.S

GRpladdpts.o : \
	$(SRC)/GRpladdpts.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/spec/GRcurve.S \
	/usr2/ip32/grnucsrc/spec/GRbspline.S \
	/usr2/ip32/grnucsrc/spec/GRlinear.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h

GRcnupdrang.o : \
	$(SRC)/GRcnupdrang.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMcluster.h \
	/usr/ip32/exnucdp/include/OMmacros.h

GRdetpoint.o : \
	$(SRC)/GRdetpoint.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr/ip32/exnucdp/include/msdef.h

GRaddptsutil.o : \
	$(SRC)/GRaddptsutil.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/spec/GRcurve.S \
	/usr2/ip32/grnucsrc/spec/GRbspline.S \
	/usr2/ip32/grnucsrc/spec/GRlinear.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/exnucdp/include/msdef.h

GRorthaddpts.o : \
	$(SRC)/GRorthaddpts.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/spec/GRcurve.S \
	/usr2/ip32/grnucsrc/spec/GRbspline.S \
	/usr2/ip32/grnucsrc/spec/GRlinear.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr/ip32/bspmathdp/include/bserr.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h

GUprocessplo.o : \
	$(SRC)/GUprocessplo.I \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/grerr.h \
	/usr2/ip32/grnucsrc/include/dperr.h \
	/usr2/ip32/grnucsrc/include/dpdef.h \
	/usr2/ip32/grnucsrc/include/dpmacros.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/include/ref.h \
	/usr2/ip32/grnucsrc/spec/GRreffile.S

GRprocessfit.o : \
	$(SRC)/GRprocessfit.I \
	/usr2/ip32/grnucsrc/spec/GRnotify.S \
	/usr/ip32/exnucdp/include/OMimport.h \
	/usr/ip32/exnucdp/include/OMprimitives.h \
	/usr/ip32/exnucdp/include/OMdeport.h \
	/usr/ip32/exnucdp/om/spec/Root.S \
	/usr2/ip32/grnucsrc/include/igr.h \
	/usr2/ip32/grnucsrc/include/igrdp.h \
	/usr2/ip32/grnucsrc/include/dp.h \
	/usr2/ip32/grnucsrc/include/go.h \
	/usr/ip32/exnucdp/include/OMindex.h \
	/usr/ip32/exnucdp/include/OMerrordef.h \
	/usr2/ip32/grnucsrc/include/griodef.h \
	/usr2/ip32/grnucsrc/include/grio.h \
	/usr2/ip32/grnucsrc/include/lcdef.h \
	/usr2/ip32/grnucsrc/include/lc.h \
	/usr2/ip32/grnucsrc/include/dpstruct.h \
	/usr2/ip32/grnucsrc/spec/GRgraphics.S \
	/usr2/ip32/grnucsrc/spec/GRconnector.S \
	/usr2/ip32/modelsrc/include/EMmsg_obj.h \
	/usr2/ip32/modelsrc/include/emsdattyp.h \
	/usr2/ip32/modelsrc/include/emsinter.h \
	/usr2/ip32/grnucsrc/spec/GRvg.S \
	/usr2/ip32/grnucsrc/spec/GRcurve.S \
	/usr2/ip32/grnucsrc/spec/GRbspline.S \
	/usr2/ip32/grnucsrc/spec/GRlinear.S \
	/usr2/ip32/grnucsrc/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr/ip32/exnucdp/include/OMlimits.h \
	/usr/ip32/exnucdp/include/OMtypes.h \
	/usr/ip32/exnucdp/include/OMminimum.h \
	/usr/ip32/exnucdp/include/igetypedef.h \
	/usr/ip32/exnucdp/include/igrtypedef.h \
	/usr2/ip32/grnucsrc/include/gr.h \
	/usr/ip32/exnucdp/include/fidef.h \
	/usr/ip32/exnucdp/include/fi.h \
	/usr/ip32/exnucdp/include/ex.h \
	/usr/ip32/bspmathdp/include/bsparameters.h \
	/usr2/ip32/grnucsrc/include/grimport.h \
	/usr2/ip32/grnucsrc/include/igrdef.h \
	/usr/ip32/exnucdp/include/msdef.h \
	/usr2/ip32/grnucsrc/include/godef.h \
	/usr2/ip32/grnucsrc/include/maerr.h \
	/usr2/ip32/grnucsrc/include/madef.h \
	/usr2/ip32/grnucsrc/include/dpmacros.h \
	/usr2/ip32/grnucsrc/include/dperr.h \
	/usr2/ip32/grnucsrc/include/dpdef.h

$(c_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@F:.o=.c): $?"; fi
	@echo "\t$(SRC)/$(@:.o=.c) -> $(@)"
	@if [ -n "$(@D)" ]; then cd $(@D); fi; \
	 $(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) $(SRC)/$(@:.o=.c) \
                  $(CCFILTER)
	@echo 

$(C_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@:.o=.C): $?"; fi
	@echo "\t$(SRC)/$(@:.o=.C) -> $(@:.o=.c)"
	@if [ -n "$(@D)" ]; then cd $(@D); fi; \
	 $(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) \
		$(SRC)/$(@:.o=.C) $(@F:.o=.c)"
	@if [ -n "$(@D)" ]; then cd $(@D); fi; \
	 if [ "$(FAST)" ]; \
	 then \
	     echo "\t$(@:.o=.c) -> cc.list\c"; \
	     echo "$(@:.o=.c)" >>cc.list; \
	 else \
	     echo "\t$(@:.o=.c) -> $(@)"; \
	     $(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) $(@F:.o=.c) \
                      $(CCFILTER); \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	         echo "\tremoving $(@:.o=.c)"; \
	         rm $(@F:.o=.c); \
	     else \
	         echo "\tleaving $(@:.o=.c)"; \
	     fi; \
	 fi
	@echo 

$(imp_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@:.o=.I): $?"; fi
	@if [ -n "$(@D)" ]; then cd $(@D); fi; \
	 if [ "$(FAST)" ]; \
	 then \
	     echo "\t$(SRC)/$(@:.o=.I) -> opp.list\c"; \
	     echo "$(SRC)/$(@:.o=.I)" >>opp.list; \
	 else \
	     echo "\t$(SRC)/$(@:.o=.I) -> $(@:.o=.c)"; \
	     $(opp) $(OPPOPT) $(OPPFLAGS) -I`dirname $(SRC)/$(@)` $(DOPT) $(DOPT1) $(DOPT2) $(@F:.o=.I); \
	     echo "\t$(@:.o=.c) -> $(@)"; \
	     $(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) $(@F:.o=.c) \
                      $(CCFILTER); \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	         echo "\tremoving $(@:.o=.c)"; \
	         rm $(@F:.o=.c); \
	     else \
	         echo "\tleaving $(@:.o=.c)"; \
	     fi; \
	 fi
	@echo 

.C.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@echo "\t$< -> $*.c"
	@$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $< $*.c
	@if [ "$(FAST)" ]; \
	 then \
	     echo "\t$*.c -> cc.list\c"; \
	     echo "$*.c" >>cc.list; \
	 else \
	     echo "\t$*.c -> $*.o"; \
	     $(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) $*.c \
                      $(CCFILTER); \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	         echo "\tremoving $*.c"; \
	         rm $*.c; \
	     else \
	         echo "\tleaving $*.c"; \
	     fi; \
	 fi
	@echo 

.S.o .I.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ "$(FAST)" ]; \
	 then \
	     echo "\t$< -> opp.list\c"; \
	     echo "$<" >>opp.list; \
	 else \
	     echo "\t$< -> $*.c"; \
	     $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<; \
	     echo "\t$*.c -> $*.o"; \
	     $(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) $*.c \
                      $(CCFILTER); \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	         echo "\tremoving $*.c"; \
	         rm $*.c; \
	     else \
	         echo "\tleaving $*.c"; \
	     fi; \
	 fi
	@echo 

.c.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@echo "\t$< -> $*.o"
	@$(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) $*.c \
                  $(CCFILTER)
	@echo 

