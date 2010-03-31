/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"

/*
HISTORY

09 Jan 1989 jBk Replaced em$xsMessage invocations with ex$message
                invocations.
                Accordingly, replaced EMScimacros.h inclusion
                with inclusion of msmacros.h.
?? ??? ???? jBk Genesis.
*/

/* IGRlong */
# include "igrtypedef.h"

#include "msdef.h"  /* MS_IMMEDIATE for ex$message */

/* ex$message */
# include "msmacros.h"

void EFmessage (msgNum)
IGRlong msgNum;
{
    ex$message (msgnumb = msgNum);
}
