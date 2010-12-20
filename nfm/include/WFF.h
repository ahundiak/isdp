#ifdef XWINDOWS
#ifdef OS_HPUX
#include <X11R5/X11/Xatom.h>
#include <X11R5/X11/Xlib.h>
#include <X11R5/X11/Xutil.h>
#include <X11R5/X11/X.h>        /* Added by SSRS - 29/10/93 */
#else
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/X.h>        /* Added by SSRS - 29/10/93 */
#endif
#endif
#include "WFFincl.h"
#include "WFFdef.h"
#include "WFGstructs.h"
#include "WFFstructs.h"
#include "WFFglobal.h"
#include "WFFforms.h"
#include "WFFcommands.h"
#include "NFIerrordef.h"

/* Typedefs used in prototyping */

/* Prototyped Functions */

#include "WFGproto.h"
#include "WFFproto.h"
