COPT
#ifdef NT

#ifdef _DEBUG
-W3 -Zp8 -Gd -nologo -Od -Zi
#else /* _DEBUG */
-W3 -Zp8 -Gd -nologo -O2
#endif /* _DEBUG */

#else /* NT */
-DBASE_EMS
#endif /* NT */

OPP
#ifdef NT
$(OMTARG)/bin/opp
#else
$(EXNUC)/bin/opp
#endif /* NT */

OPPFLAGS
-I$(SRC)
-DBASE_EMS

OMCPP
#ifdef NT
$(OMTARG)/bin/omcpp
#else
$(EXNUC)/bin/omcpp
#endif /* NT */

INCLUDE
$(BS)/include
$(BS)/include/igr_include
$(MINIEMSSRC)/include/api
$(MINIEMSSRC)/include/api/PWapi

SRC
$(MINIEMSSRC)\miniEMS

DEPLIB
#ifdef _DEBUG
$(MINIEMSTARG)/lib/miniemsd.lib
#else
$(MINIEMSTARG)/lib/miniems.lib
#endif /* _DEBUG */

EXEC
$(MINIEMSTARG)/bin/mnems.exe

SOURCE
main.c
