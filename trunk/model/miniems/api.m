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
$(MINIEMSSRC)/stubs
$(MINIEMSSRC)/include/model
$(MINIEMSSRC)/include/grnuc
$(BS)/include
$(BS)/include/prototypes
$(MINIEMSSRC)/include/api
$(MINIEMSSRC)/include/api/PWapi
$(XINC)
$(INGRHOME)/include
$(EXNUC)/include
#ifdef NT
$(MINIEMSSRC)/include
#endif /* NT */
SPEC
$(MINIEMSSRC)/stubs
$(MINIEMSSRC)/spec/model
$(MINIEMSSRC)/spec/grnuc
$(MINIEMSSRC)/spec/uom
$(MINIEMSSRC)/exnuc
$(EXNUC)/spec
