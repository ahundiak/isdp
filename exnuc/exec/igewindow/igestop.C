#include "exsysdep.h"
#include <sys/signal.h>
#include <igrtypedef.h>


extern long EX_stopproc_id;

static int stop_is_active = FALSE;
static int igestop = FALSE;

/* This routine activates the stop sign */

void IGEactivate_stop_sign()
{
    if (!stop_is_active && EX_stopproc_id)
    {
        stop_is_active = TRUE;
        kill(EX_stopproc_id, SIGUSR1);
    }
}

/* This routine deactivates the stop sign */

void IGEdeactivate_stop_sign()
{
    if (stop_is_active && EX_stopproc_id)
    {
        stop_is_active = FALSE;
        kill(EX_stopproc_id, SIGUSR2);
    }
}

/* This routine resets the stop variable */

void IGEresetstop()
{
   igestop = FALSE;
   IGEdeactivate_stop_sign();
}

/*
    This routine returns the current state of the stop variable.  It also
    activates the stop sign, on the assumption that if anyone is checking
    for a stop action, then it is valid for the user to see the active
    stop sign.
*/

int IGEstop()
{
    IGEactivate_stop_sign();
    return(igestop);
}

/* This routine sets the igestop variable when SIGUSR1 is detected */

int IGEsetstop()
{
   signal(SIGUSR1,(void (*)())IGEsetstop);
   return(igestop = TRUE);
}
