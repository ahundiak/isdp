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
$(EXNUC)/om/opp/opp

SOURCE=oppsrc
opp.c

EXEC=oppsrc
$(TARGET)/bin/opp

DEPLIB=oppsrc
$(TARGET)/om/opp/opp/opp.a
$(TARGET)/om/opp/cpp/cpp.a
$(TARGET)/om/opp/symtab/symtab.a

#if defined(SYSV) || defined(BSD)
LINKLIB=oppsrc
$(LIBXC_LIB_PATH)/libxcmalloc.a
$(LIBXC_LIB_PATH)/libxc.a
#elif defined(NT)
LINKLIB=oppsrc
$(TARGET)\lib\exnt.lib
#endif

SOURCE=opplib
carriers.c
class.c
dcltrs.c
dumpmessage.c
functions.c
identifier.c
initgen.c
keval.c
kgti.c
kpster.c
kutil.c
lex3.c
lexinput.c
messbuf2.c
odinsup.c
oppdata.c
oppface.c
oppmalloc.c
#if defined(SVR3) || defined(BSD)
oppy.y
#elif defined(NT)
ntoppy.c
#elif defined(SUNOS5) || defined (IRIX5)
s5oppy.c
#endif
quefree.c
relations.c
share.c
sizeof.c
typeinfo.c

ARCHIVE=opplib
$(TARGET)/om/opp/opp/opp.a

INCLUDE
$(TARGET)/om/opp/opp
$(EXNUC)/om/opp/symtab
$(EXNUC)/om/opp/cpp
$(EXNUC)/include

DEFINE
CCDEF

#if defined(UNIX)
SPECIAL
MAKEFLAGS=r
END_SPECIAL

POST_SPECIAL
#if defined(BSD)
SED = $(EXNUC)/om/opp/tools/yacc.sedsun
#else
SED = $(EXNUC)/om/opp/tools/yacc.sed
#endif
kstr=$(BASE)/om/opp/tools/kstr
kgrover=$(BASE)/om/opp/tools/kgrover

oppy.o:
	yacc -dl $(SRC)/oppy.y
	sed -f $(SED) y.tab.c > oppy.c
	rm y.tab.c
	$(kstr) < $(SRC)/oppy.y > kptype.h
	$(kgrover) y.tab.h kptype.h > kpster.h
#if defined (SUNOS) && defined (SYSV)
	mv oppy.c tmp.c
	sed -f $(EXNUC)/om/opp/tools/yacc.seds5 tmp.c > oppy.c
	rm tmp.c
#endif
	$(CCDEF) -I$(SRC) -c oppy.c
	@if test "$(COPT)" != "-g"; \
	then \
		echo "\trm oppy.c"; \
		rm oppy.c; \
	else \
		echo "\tleaving oppy.c"; \
	fi
	touch $(TARGET)/om/opp/opp/makefile

END_SPECIAL
#endif
