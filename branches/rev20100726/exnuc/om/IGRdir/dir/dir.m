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
$(EXNUC)/om/IGRdir/dir

SOURCE
DIboot.I
DIconfig.I
DIdbg.C
DIdump.I
DIfast_trans.I
DIindex.I
DIlib.I
DIlinki.I
DImaci.I
DImasteri.I
DImkpath.I
DImove.I
DIrectori.I
DIregexp.C
DIrooti.I
DIsearch.I
DIsyn.I
DIuntrans.I
IGRdiri.I

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB
$(TARGET)/om/IGRdir/lib/DIrectorylib.o
#elif defined(NT)
ARCHIVE
$(TARGET)\om\IGRdir\lib\DIrectorylib.lib
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

