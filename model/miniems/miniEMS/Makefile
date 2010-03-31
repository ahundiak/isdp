#---------------------------------------------------------------------------
#
# This makefile builds the "miniEMS" executable. This assumes that the MiniEMS
# libraries are in place
#
# The only function from MiniEMS callable in here are the Pathway APIs. This
# must be strictly enforced as the testing the modularity and completeness of 
# these is one of key purposes of this "miniEMS".
#
# In order to run this make file, the following shell variables are expected
# to be defined:
#   EXNUC
#   BS
#   GRNUC
#   MODEL
#   MDTARG
#----------------------------------------------------------------------------

#
# Build tools needed 
#

CC = acc

OPL = $(EXTARG)/bin/opl

OMCPP = $(EXTARG)/bin/omcpp

#
# libraries and include files related to OM
#

OM_libs = \
	$(EXTARG)/lib/$(CPUTYPE)/libOM.a

OM_incs = \
	-I$(EXNUC)/include

#
# libraries and include files related to BS
#

include $(BS)/lib/bsmakelib
BS_libs = ${BSLIBRARIES}

BS_incs = \
	-I$(BS)/include \
	-I$(BS)/include/prototypes

#
# libraries and include files that are built for the BaseEMS.
#

BASEEMS_libs = \
	$(MINIEMSTARG)/lib/grspec.o \
	$(MINIEMSTARG)/lib/mdspec.o \
	$(MINIEMSTARG)/lib/grimp.o \
	$(MINIEMSTARG)/lib/mdimp.o \
	$(MINIEMSTARG)/lib/grfunk.o \
	$(MINIEMSTARG)/lib/mdfunk.o

BASEEMS_incs = \
	-I$(MINIEMSSRC)/include/grnuc \
	-I$(MINIEMSSRC)/include/model \
	-I$(MINIEMSSRC)/include/api	

#
# stubs library and include files
#

STUBS_libs = \
	$(MINIEMSTARG)/lib/stubs.o

STUBS_incs = \
	-I$(MINIEMSSRC)/stubs

#
# libraries and include files that deal with the external API. 
#

API_libs = \
	$(MINIEMSTARG)/lib/OMuse.o \
	$(MINIEMSTARG)/lib/runtypes.o \
	$(MINIEMSTARG)/lib/errdbg.o \
	$(MINIEMSTARG)/lib/bdryquery.o \
	$(MINIEMSTARG)/lib/sfquery.o \
	$(MINIEMSTARG)/lib/grquery.o \
	$(MINIEMSTARG)/lib/util.o \
	$(MINIEMSTARG)/lib/tolfunc.o \
	$(MINIEMSTARG)/lib/bdryint.o \
	$(MINIEMSTARG)/lib/int2d.o \
	$(MINIEMSTARG)/lib/math.o \
	$(MINIEMSTARG)/lib/dpb.o \
	$(MINIEMSTARG)/lib/bdrycre.o \
	$(MINIEMSTARG)/lib/bdrymod.o \
	$(MINIEMSTARG)/lib/grmod.o \
	$(MINIEMSTARG)/lib/sfcre.o \
	$(MINIEMSTARG)/lib/map.o \
	$(MINIEMSTARG)/lib/sfmod.o \
	$(MINIEMSTARG)/lib/uom.o \
	$(MINIEMSTARG)/lib/uomspec.o \
	$(MINIEMSTARG)/lib/uomimp.o

API_incs = \
	-I$(MINIEMSSRC)/include/api 


#
# Testbed application objects.
#

APP_objs = \
	main.o 

#
# Putting together the above information and the rules needed to build the
# executable -- miniEMS
#

ALLOBJS = \
	$(APP_objs)

ALLLIBS = \
	$(OM_libs) \
	$(BS_libs) \
	$(BASEEMS_libs) \
	$(STUBS_libs) \
	$(API_libs)

IPATH = \
	$(OM_incs) \
	$(BS_incs) \
	$(BASEEMS_incs) \
	$(STUBS_incs) \
	$(API_incs)

miniEMS: $(ALLOBJS) $(ALLLIBS) OMclassinit.o OMapplinit.o 
	@echo "\tCreating miniEMS...\n"
	$(CC) -o miniEMS \
	OMclassinit.o \
	OMapplinit.o \
	$(ALLOBJS) \
	$(ALLLIBS) \
	-lxc -lxcmalloc \
	-lmath -lm -lix -lbsd -lPW -lg -lc_s -lc


OMclassinit.o: $(ALLOBJS) $(ALLLIBS)
	$(OPL) $(ALLOBJS) $(ALLLIBS)
	@echo ""
	$(OMCPP) $(OM_incs) OMclassinit.C OMclassinit.c
	@echo ""
	$(CC) -c OMclassinit.c

OMapplinit.o:
	$(OPL) -a
	@echo ""
	$(OMCPP) $(OM_incs) OMapplinit.C OMapplinit.c
	@echo ""
	$(CC) -c OMapplinit.c

.c.o:
	@echo "\t$< -> $*.o"
	$(CC) $(IPATH) -c $*.c
