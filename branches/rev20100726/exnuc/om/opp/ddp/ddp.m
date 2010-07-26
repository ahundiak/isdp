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
$(EXNUC)/om/opp/ddp

SOURCE=ddp
ddp.c

EXEC=ddp
$(TARGET)/bin/ddp

DEPLIB=ddp
$(TARGET)/om/opp/ddp/ddp.a
$(TARGET)/om/opp/opp/opp.a
$(TARGET)/om/opp/cpp/cpp.a
$(TARGET)/om/opp/symtab/symtab.a

LINKLIB=ddp
$(LIBXC_LIB_PATH)/libxcmalloc.a
$(LIBXC_LIB_PATH)/libxc.a

SOURCE=ddplib
ddp_dump.c
ddp_error.c
ddp_hash.c
ddp_supp.c
ddp_tcodes.c

ARCHIVE=ddplib
$(TARGET)/om/opp/ddp/ddp.a

INCLUDE
$(TARGET)/om/opp/opp
$(EXNUC)/om/opp/opp
$(EXNUC)/om/opp/symtab
$(EXNUC)/om/opp/cpp
