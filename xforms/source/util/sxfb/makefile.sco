XFI          = ../xfi
XFUTIL       = ..

CURRENT_TARGET_ARCH = c100

#LICTOOL_DIR=/usr/ip32/lictools
#LICTOOL_LIB=$(LICTOOL_DIR)/api.o
#LICTOOL_INCLUDE_FILE=$(LICTOOL_DIR)/api.h

CC           = acc
COPT         = -knr -ga -O3 -Abss=0

IPATH        = -I$(LICTOOL_DIR)

IPATH        = -I$(X11_INCLUDE_LOC) -I$(X11_INCLUDE_LOC)/X11 \
               -I$(LICTOOL_DIR)

CFLAGS       = $(COPT) $(IPATH) $(MOPT) $(DOPT)

EXE_DIR      = $(XFUTIL)/bin
EXE          = $(EXE_DIR)/sxfb

CLIX_LIB_LOC = /usr/lib
SUN_LIB_LOC  = /usr/lib/X11


BOX=`uname -s`
 #dmb:04/06/93:Changing to OS_KEY for SUNOS5
OS_KEY = `uname -s | tr '[a-z]' '[A-Z]'`
OS_VER = `uname -r`

OBJECTS =	\
	main.o

$(EXE): $(OBJECTS)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(OS_KEY)" = "CLIX" ]; \
	then \
		echo "" ; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)	\
		  $(FORMS_LIB)				\
		  $(LICTOOL_LIB)			\
		  -lmath -lbsd -lc_s; \
		set +x ; \
	elif [ "$(OS_KEY)" = "SCO" ]; \
	then \
		echo "" ; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)	\
		  $(FORMS_LIB)				\
		  $(LICTOOL_LIB)			\
		  -lm -lsocket -lc_s; \
		set +x ; \
	elif [ "$(OS_KEY)" = "IRIX" ]; \
	then \
		echo "" ; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)	\
		  $(FORMS_LIB)				\
		  $(LICTOOL_LIB)			\
		  -lm -lbsd -lc; \
		set +x ; \
	elif [ "$(OS_KEY)" = "SUNOS4" ]; \
	then \
		echo "" ; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)		\
		 $(LICTOOL_LIB)					\
		 -lm -lc;	\
		set +x ; \
	elif [ "$(OS_KEY)" = "SUNOS5" ]; \
	then \
		echo "" ; \
		set -x ; \
		$(CC) $(CFLAGS) -o $(EXE) $(OBJECTS)		\
		 $(LICTOOL_LIB)					\
		 -lm;	\
		set +x ; \
	else \
		echo "Unknown OS_KEY $(OS_KEY)"; \
	fi; \
	if [ "${STRIP}" ]; \
	then \
		echo "Strip $(EXE)"; \
		strip $(EXE); \
		if [ "$(OS_KEY)" = "SUNOS5" ]; \
		then \
		  echo "mcs $(EXE)"; \
		  mcs -c $(EXE); \
		elif [ "$(OS_KEY)" = "CLIX" ]; \
		then \
		  echo "mcs $(EXE)"; \
		  mcs -c $(EXE); \
		fi; \
	fi; \
	echo; \
	ls -ls $(EXE);


main.o:	main.c \
	$(LICTOOL_INCLUDE_FILE) \
	$(ANSI_INCLUDE)/stdio.h


