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
$(EXNUC)/om/opl

SOURCE
opl.c

EXEC
$(TARGET)/bin/opl

INCLUDE
$(EXNUC)/om/opl
$(EXNUC)/include
$(LIBXC_INC_PATH)

LINKLIB
#if defined (CLIX)
-lld
$(LIBXC_LIB_PATH)/libxcmalloc.a
#elif defined (IRIX4)
-lmld
#elif defined (SUNOS5) || defined(IRIX5)
-lelf
#endif
$(LIBXC_LIB_PATH)/libxc.a
