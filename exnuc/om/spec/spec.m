COPT
#ifdef NT

#ifdef _DEBUG
-W3 -Zp8 -Gd -nologo -Od -Zi -MTd
#else /* _DEBUG */
-W3 -Zp8 -Gd -nologo -O2
#endif /* _DEBUG */

#else /* NT */
-DBASE_EMS
#endif /* NT */

SRC
$(EXNUC)/om/spec

SOURCE=omspec
OMISO.S
OMMOSDOS.S
OMOSCO.S
OMTag.S
OMTagCon.S

DEPLIB=omspec
$(TARGET)/spec/DIbst.o
$(TARGET)/spec/DIbstgr.o
$(TARGET)/spec/DIbstob.o
$(TARGET)/spec/DIbtree.o
$(TARGET)/spec/DIlink.o
$(TARGET)/spec/DImaster.o
$(TARGET)/spec/DIrectory.o
$(TARGET)/spec/DIroot.o
$(TARGET)/spec/DIstorage.o
$(TARGET)/spec/GRoup.o
$(TARGET)/spec/GRoups.o
$(TARGET)/spec/IGRdir.o
$(TARGET)/spec/OMCluster.o
$(TARGET)/spec/OMFiledOS.o
$(TARGET)/spec/OMGroup.o
$(TARGET)/spec/OMMOSD.o
$(TARGET)/spec/OMObjSpace.o
$(TARGET)/spec/OMSupGroup.o
$(TARGET)/spec/OMTransOS.o
$(TARGET)/spec/OMbtree.o
$(TARGET)/spec/OMindex.o
$(TARGET)/spec/OMlnkbtree.o
$(TARGET)/spec/OMrtree.o
$(TARGET)/spec/Root.o

SPEC
$(EXNUC)/spec

INCLUDE
$(EXNUC)/include
$(EXNUC)/om/include

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB=omspec
$(TARGET)/om/spec/omspec.o
#elif defined(NT)
ARCHIVE=omspec
$(TARGET)\om\spec\omspec.lib
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

