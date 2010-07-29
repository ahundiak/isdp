# Master Application Builder, try to keep it simple
.SUFFIXES: .I .S .C .c .o

opp = $(EXTARG)/bin/opp

omcpp = $(EXTARG)/bin/omcpp

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
LINKLIB = \
	-lIGbspmath -lIGexnuc -lIGgrnuc \
	-lXFS -lXFI \
	-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext \
	/opt/ingr/ums/lib/i86pc/libUMS.a      \
	/opt/ingr/libxc/lib/libxc.a           \
	/opt/ingr/libxc/lib/libxcmalloc.a     \
	/opt/ingr/helpdp/lib/i86pc/libhc.a    \
	/opt/ingr/helpdp/lib/i86pc/libhlib.a  \
	/opt/ingr/exnucdp/lib/igefei.o        \
	/opt/ingr/grnucdp/lib/isl/stub.a      \
	/opt/ingr/grnucdp/lib/isl/libGRstub.a \
	/opt/ingr/grnucdp/lib/isl/dl.o        \
	/opt/ingr/grnucdp/lib/isl/ci.o

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
