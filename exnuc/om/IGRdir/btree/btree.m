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
$(EXNUC)/om/IGRdir/btree

SOURCE
DIbstgri.I
DIbsti.I
DIbstobi.I
DIbtreei.I
DIuntree.C

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB
$(TARGET)/om/IGRdir/lib/DIbtreelib.o
#elif defined(NT)
ARCHIVE
$(TARGET)\om\IGRdir\lib\DIbtreelib.lib
#endif

SPEC
$(EXNUC)/spec

INCLUDE
$(EXNUC)/include
$(EXNUC)/om/IGRdir/include

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

