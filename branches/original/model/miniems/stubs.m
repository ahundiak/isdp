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

SRC
$(MINIEMSSRC)/stubs

OPP
#ifdef NT
$(OMTARG)/bin/opp
#else
$(EXTARG)/bin/opp
#endif /* NT */

OPPFLAGS
-I$(SRC)
-DBASE_EMS

OMCPP
#ifdef NT
$(OMTARG)/bin/omcpp
#else
$(EXTARG)/bin/omcpp
#endif /* NT */


INCLUDE
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(MINIEMSSRC)/include/model
$(MINIEMSSRC)/include/grnuc
$(MINIEMSSRC)/include/api

SPEC

$(MINIEMSSRC)/spec/model
$(MINIEMSSRC)/spec/grnuc
$(MINIEMSSRC)/stubs
$(EXNUC)/spec

/*SRC 
$(MINIEMSSRC)/stubs
*/
#ifdef NT
ARCHIVE
$(MINIEMSTARG)/lib/stubs.lib
#else
LIB
$(MINIEMSTARG)/lib/stubs.o
#endif
SOURCE
