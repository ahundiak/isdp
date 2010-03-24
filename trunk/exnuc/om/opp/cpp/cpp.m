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
$(EXNUC)/om/opp/cpp

SOURCE=omcppsrc
loner.c

EXEC=omcppsrc
$(TARGET)/bin/omcpp

DEPLIB=omcppsrc
$(TARGET)/om/opp/cpp/cpp.a
$(TARGET)/om/opp/symtab/symtab.a

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LINKLIB=omcppsrc
$(LIBXC_LIB_PATH)/libxcmalloc.a
$(LIBXC_LIB_PATH)/libxc.a
#elif defined(NT)
LINKLIB=omcppsrc
$(TARGET)\lib\exnt.lib
#endif

SOURCE=cpp
char_st.c
cleanup.c
cppdat.c
cppout.c
disco.c
find_file.c
fio.c
luther.c
mallocdbg.c
omdef.c
parents.c
prepro.c
stream.c
tok.c

ARCHIVE=cpp
$(TARGET)/om/opp/cpp/cpp.a

INCLUDE
$(EXNUC)/om/opp/symtab
$(EXNUC)/om/opp/opp
$(EXNUC)/include
$(EXNUC)/bin
