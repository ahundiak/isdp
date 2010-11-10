# Master Application Builder, try to keep it simple
.SUFFIXES: .I .S .C .c .o

opp = $(EXTARG)/bin/opp
opp = opp

omcpp = $(EXTARG)/bin/omcpp
omcpp = omcpp -l

CC = $(COMPILER)

COPT = $(COMPOPT)

# Compiler and preprocessor include options

IPATH =  \
	-I$(XINC) \
        -I$(XGLHOME)/include \
        -I$(XGLHOME)/include/xgl \
 	-I$(EXNUC)/include \
	-I$(GRNUC)/include

# Libraries to be linked by the loader
# This causes a coredump on startup
#	-lxcmalloc \

LINKLIB = \
	-lIGbspmath -lIGexnuc -lIGgrnuc \
	-lxc  -lUMS \
	-lXFS -lXFI \
	-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext \
	-lxml2 -lxslt -lglib -lgtk -lgdk \
	/opt/ingr/helpdp/lib/i86pc/libhc.a    \
	/opt/ingr/helpdp/lib/i86pc/libhlib.a  \
	/opt/ingr/exnucdp/lib/igefei.o        \
	/opt/ingr/grnucsrc/lib/isl/stub.a      \
	/opt/ingr/grnucsrc/lib/isl/libGRstub.a \
	/opt/ingr/grnucsrc/lib/isl/dl.o        \
	/opt/ingr/grnucsrc/lib/isl/ci.o

#LINKLIB = \
#	-lIGbspmath -lIGexnuc -lIGgrnuc \
#	-lxc -lxcmalloc \
#	-lXFS -lXFI \
#	-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext \
#	-lxml2 -lxslt -lglib -lgtk -lgdk \
#	/opt/ingr/ums/lib/i86pc/libUMS.a      \
#	/opt/ingr/libxc/lib/libxc.a           \
#	/opt/ingr/libxc/lib/libxcmalloc.a     \
#	/opt/ingr/helpdp/lib/i86pc/libhc.a    \
#	/opt/ingr/helpdp/lib/i86pc/libhlib.a  \
#	/opt/ingr/exnucdp/lib/igefei.o        \
#	/opt/ingr/grnucsrc/lib/isl/stub.a      \
#	/opt/ingr/grnucsrc/lib/isl/libGRstub.a \
#	/opt/ingr/grnucsrc/lib/isl/dl.o        \
#	/opt/ingr/grnucsrc/lib/isl/ci.o

# OPP and OMCPP options

OPPFLAGS=  \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(XINC) \
	-I$(INGRHOME)/include

.C.o :
	$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(MKDOPT) $< $*.c
	$(CC) -c $(COPT) $(DOPT) -g $(IPATH) $*.c

.c.o:
	@$(CC) -c $(COPT) $(DOPT) -g $(IPATH) $*.c


target:	APP_main.o extrastub.o \
	EXNUCver.o EXNUCapplinit.o \
	GRNUCver.o GRNUCprodinit.o GRNUCclassinit.o \
	MODELver.o MODELprodinit.o MODELclassinit.o \
	EMSPPver.o EMSPPprodinit.o \
	Grnuc Model Emspp

APP_main.o : APP_main.C

# -xpg causing problems?

Grnuc :
	cc -o Grnuc APP_main.o \
	extrastub.o $(LINKLIB) \
	EXNUCver.o EXNUCapplinit.o \
	GRNUCver.o GRNUCprodinit.o GRNUCclassinit.o

Model :
	cc -o Model \
	-lIGmodel   \
	APP_main.o  \
	extrastub.o \
	$(LINKLIB)  \
	EXNUCver.o EXNUCapplinit.o \
	GRNUCver.o GRNUCprodinit.o \
	MODELver.o MODELprodinit.o MODELclassinit.o

Emspp :
	cc -o Emspp \
	-lIGmodel   \
	APP_main.o  \
	extrastub.o \
	$(LINKLIB)  \
	EXNUCver.o EXNUCapplinit.o \
	GRNUCver.o GRNUCprodinit.o \
	MODELver.o MODELprodinit.o MODELclassinit.o \
	EMSPPver.o EMSPPprodinit.o

clean:
	@rm -f *.o APP_main.c Grnuc Model Emspp
	@rm -f EXNUCclassinit.c EMSPPprodinit.c  EXNUCapplinit.c
	@rm -f GRNUCclassinit.c GRNUCprodinit.c
	@rm -f MODELclassinit.c MODELprodinit.c
