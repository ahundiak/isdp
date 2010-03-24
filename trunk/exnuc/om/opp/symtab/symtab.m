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
$(EXNUC)/om/opp/symtab

SOURCE
symtab.c
hiersymtab.c
usagetab.c
basictab.c
ordertab.c

ARCHIVE
$(TARGET)/om/opp/symtab/symtab.a

INCLUDE
$(EXNUC)/om/opp/opp

SOURCE=symtest
test.c

EXEC=symtest
$(TARGET)/om/opp/symtab/symtest

LINKLIB=symtest
-lxcmalloc
-lxc

DEPLIB=symtest
$(TARGET)/om/opp/symtab/symtab.a

POST_SPECIAL
symtab.cl : symtab.h
	touch symtab.cl

basictab.cl : basictab.h symtab.cl
	touch basictab.cl

basictab.h : symtab.h
	touch basictab.h

hiersymtab.h : symtab.h
	touch hiersymtab.h

hiersymtab.cl : hiersymtab.h symtab.cl
	touch hiersymtab.cl

usagetab.h : hiersymtab.h
	touch usagetab.h

usagetab.cl : usagetab.h hiersymtab.cl
	touch usagetab.cl

ordertab.h : hiersymtab.h
	touch ordertab.h

ordertab.cl : ordertab.h hiersymtab.cl
	touch ordertab.cl
END_SPECIAL
