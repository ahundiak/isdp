#ifndef FImin_included
#define FImin_included	1

// #include "FIimport.h"   /* Import must be included first for shlib */

#include <X11/Xlib.h>  /* X11-4/17/90 */
#include <X11/Xatom.h>
#include <X11/Xutil.h>

#include "FI.h"
#include "FIrange.h"
#include "FIform.h"
#include "FIgadget.h"
#include "FIcolors.h"

#include "FImgt.h"
#include "FIext.h"
#include "FImacros.h"


#include "unistd.h"  /* dmb:09/29/92:for PATH_MAX in ANSI */

#if defined(sun) || defined(sparc) || defined(i386)
#define PATH_MAX 256
#elif defined(mips)
/* from <limits.h>, protected in __EXTENSIONS__ || _POSIX_SOURCE section */
#define PATH_MAX 1024
#endif

#include "limits.h"  /* dmb:09/29/92:for INT_MAX in ANSI */

/**********************************************************************/
/*** The next two used to be in FIkey.h ( private ), and then I     ***/
/*** moved them into FIappl.h ( public ), until I realized that     ***/
/*** "RETURN" is a lex/yacc reserved macro.  So now they're here .  ***/
/***					-- JAJ:01/21/92		    ***/
/**********************************************************************/
#define RETURN     10
#define SPACE      32


#endif

