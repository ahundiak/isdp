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
$(EXNUC)/om/IGRdir/group

SOURCE
GRoupi.I
GRoupsi.I

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB
$(TARGET)/om/IGRdir/lib/GRouplib.o
#elif defined(NT)
ARCHIVE
$(TARGET)\om\IGRdir\lib\GRouplib.lib
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

