#include <stdio.h>
#include <string.h>
#include <ctype.h>
/* HP PORT - IGI - 16 Jun 94 */
#ifndef OS_HPUX
#include <tiuser.h>
#endif
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include "DEBUG.h"
#include "NETnetstruct.h"

#ifdef INCLUDE_EXTERN
#include "NETnetextern.h"
#endif

/* 12/18/92 - KT - SUN Port */
/* MSSP - 29 Dec 93. modiifed to include on SCO and Solaris as well */
/* Modified to support SGI Port. 030394 MaC */

/* HP PORT - IGI - 10 Jun 94 */

#if (defined (__sgi) || defined (OS_SUNOS) || defined (OS_SOLARIS) || defined (OS_SCO_UNIX) || defined (OS_HPUX) )
#include <varargs.h>
#endif

#include "NETstruct.h"
#include "NETerrordef.h"
#include "ERR.h"
#include "NETtlidef.h"
#include "net.h"

#include "NETproto.h"
#include "ERRproto.h"




