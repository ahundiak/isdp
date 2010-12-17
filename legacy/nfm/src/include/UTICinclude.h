#include <stdio.h>

/* 12/17/92 - KT - SUN Port */
/* 3/17/94 - MaC - SGI Port */
/* The #ifndef changed to take care of SCO port -- MVR 16 Dec 93*/

/* HP PORT - IGI - 10 Jun 94 */

#if (!(defined (__sgi) || defined OS_SUNOS || defined OS_SOLARIS || defined OS_SCO_UNIX || defined (OS_HPUX) ) )
#include <inc.h>
#endif

#include "UNIX_or_VMS.h"
#include "UTIclient.h"
#include "UTIdef.h"
#include "UTIextern.h"
#include "UTImacros.h"
#include "UTIstruct.h"
#include "UTIglobals.h"

