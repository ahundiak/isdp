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
$(EXNUC)/bin

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
TARGET
$(TARGET)/bin/mkmk
$(TARGET)/bin/makemake
#elif defined(NT)
TARGET
$(TARGET)\bin\mkmk.exe
$(TARGET)\bin\makemake.exe
#endif

SOURCE
exfilnam.c
fget_atom.c
fget_str.c
fread_input.c
ignore.c
is_file.c
make_rules.c
red_fname.c
reduce_pth.c
str_malloc.c
version.c
toolshash.c

INCLUDE
$(EXNUC)/include

SOURCE=mkmk
mkmk.c

/* XXX - ah 
 * The second define did not have SUNOS in it, 
  * not sure how it worked unless CLIX or IRIX is getting defined somewhere
*/

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
EXEC=mkmk
$(TARGET)/bin/mkmk

LIB
$(TARGET)/bin/mkmklib.o

DEPLIB=mkmk
$(TARGET)/bin/mkmklib.o

LINKLIB=mkmk
#if defined(CLIX)
-lg
#endif
#endif

POST_SPECIAL
$(TARGET)/bin/makemake: $(TARGET)/bin/mkmk
	chmod +x $(TARGET)/bin/makemake
	touch $(TARGET)/bin/makemake
END_SPECIAL
#elif defined(NT)
EXEC=mkmk
$(TARGET)\bin\mkmk.exe

ARCHIVE
$(TARGET)\bin\mkmklib.lib

DEPLIB=mkmk
$(TARGET)\bin\mkmklib.lib
$(TARGET)\lib\exnt.lib

ECHO
$(BASE)\bin\execho

SOURCE=makemake_src
makemake.c

EXEC=makemake_src
$(TARGET)\bin\makemake.exe

LINKLIB=makemake_src
$(TARGET)\lib\exnt.lib

#endif
