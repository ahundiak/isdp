#ifdef XWINDOWS
#ifdef OS_HPUX
#include <X11R5/X11/Xatom.h>
#include <X11R5/X11/Xlib.h>
#include <X11R5/X11/Xutil.h>
#include <X11R5/X11/X.h>
#else
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/X.h>
#endif
#endif
#include <stdio.h>
#include <string.h>
#include <tools.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/times.h>
#include <FI.h>
#include <FEI.h>
#include <FIdyn.h>
#include <FIappl.h>
#include <MS.h>
#include <UMS.h>
/*#include <iHelp.h>*/   /* Include file commented all ports - SSRS - 4 Feb 94*/
#include <helpif.h>
#include <helpifproto.h>
#include "ERR.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "BASproto.h"
#include "NFMerrordef.h"
#include "NFIerrordef.h"
#include "NFIcommands.h"
#include "NFMtitles.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "NFMcombine.h"
#include "NFFforms.h"
#include "NFFdisplay.h"
#include "NFFdef.h"
#include "NFFstruct.h"
#include "NFFproto.h"
