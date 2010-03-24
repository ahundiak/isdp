SUFFIXES
.o .so .c .C .I .l .y

SRC
$(EXNUC)/trans/sp_proc

SOURCE
DIbtree_sp.c
OMrtree_sp.c
OMbtree_sp.C
IGEcolor2_sp.c

#if defined (mips)
COPT
-G0
#elif defined (sparc)
#if defined (SUNOS4)
COPT
-PIC
#else
COPT
-K PIC
#endif
#endif

INCLUDE
$(EXNUC)/include
$(EXNUC)/trans/include

DEFINE
CCDEF

OMCPP
$(BASE)/bin/omcpp

LIB
$(TARGET)/config/dload/port/exsp_proc.o

#if defined sun || defined IRIX5
TARGET
$(TARGET)/config/dload/port/exsp_proc.so

#if defined SUNOS4
POST_SPECIAL
$(TARGET)/config/dload/port/exsp_proc.so: $(objects)
	ld -assert pure-text -o $(TARGET)/config/dload/port/exsp_proc.so $(objects)
	@ls -ls $(TARGET)/config/dload/port/exsp_proc.so; echo

END_SPECIAL
#elif defined SUNOS5
POST_SPECIAL
$(TARGET)/config/dload/port/exsp_proc.so: $(objects)
	ld -z text -G -o $(TARGET)/config/dload/port/exsp_proc.so $(objects)
	@ls -ls $(TARGET)/config/dload/port/exsp_proc.so; echo

END_SPECIAL
#elif defined IRIX5
POST_SPECIAL
$(TARGET)/config/dload/port/exsp_proc.so: $(objects)
	ld -shared -o $(TARGET)/config/dload/port/exsp_proc.so $(objects)
	@ls -ls $(TARGET)/config/dload/port/exsp_proc.so; echo

END_SPECIAL
#endif
#endif

#ifdef IRIX4
TARGET
$(TARGET)/config/dload/port/exsp_proc.o
#endif

