#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>

/* 12/17/92 - KT - SUN Port */
/* MSSP - 29 Dec 93. replaced __unix__ with OS_CLIX */
#ifdef OS_CLIX
#include <stdarg.h>
#endif

/*  1 line modified to take care of SCO/SOL port MVR 7 Jan 93 */
/* Added to support SGI Port. 030394 MaC */

/* HP PORT - IGI - 10 Jun 94 */

#if (defined (__sgi) || defined(OS_SUNOS) || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) || defined (OS_HPUX) )
#include <varargs.h>
#endif

#include <errno.h>
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "ERR.h"

