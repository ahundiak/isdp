XFB          = ..

CC           = acc
COPT         = -knr  -O2
IPATH        = -I./include
CFLAGS       = $(COPT) $(IPATH)

# This is where evtobdf goes.
EXE_DIR      = $(XFB)/bin
EXE          = $(EXE_DIR)/evtobdf

CLIX_LIB_LOC = /usr/lib
SUN_LIB_LOC  = /usr/lib/X11

ARCHIVE      = libX11.a
SHARABLE     = libX11_s.a

# For SunOS
#SUN_XLIB     = "$(SUN_LIB_LOC)/$(ARCHIVE)"
SUN_XLIB     = -lX11
# For CLIX
#CLIX_XLIB    = "$(CLIX_LIB_LOC)/$(ARCHIVE)"
CLIX_XLIB    = "$(CLIX_LIB_LOC)/$(SHARABLE)"


BOX=`uname -s`

objs=\
	evtobdf.o \
	util.o

$(EXE): $(objs)
	@if [ ! -d $(EXE_DIR) ]; \
	then \
		echo "Create $(EXE_DIR)."; \
		mkdir -p $(EXE_DIR); \
	fi;
	@if [ "$(BOX)" = "SunOS" ]; \
	then \
		echo "Build with $(SUN_XLIB) for $(BOX)"; \
		$(CC) $(CFLAGS) -o $(EXE) $(objs) -lm -lc; \
	else \
		if [ "$(BOX)" = "CLIX" ]; \
		then \
			echo "Build with $(CLIX_XLIB) for $(BOX)"; \
			$(CC) $(CFLAGS) -o $(EXE) $(objs) -lxcmalloc \
			  -lmath -lbsd -lc_s; \
		else \
			echo "Unknown BOX $(BOX)"; \
		fi; \
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
