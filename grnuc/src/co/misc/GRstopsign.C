/*
Name
        GRstopsign

Description
        This file contains functions related to the stop sign.

History
        mrm     05/12/93    created from EXNUC source files igestop.C and
                            igestopinit.C
*/

#include <stdio.h>
#include <sys/signal.h>
#ifdef X11_2.2
#include <FI.h>
#include <X11/Xlib.h> 
#include <X11/Xutil.h> 
#include <X11/Xresource.h> 
#endif
#include "exsysdep.h"
#include "igrtypedef.h"
#include "exmacros.h"
#include "exlocale.h"
#include "exdef.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "wl.h"
#include "cm.h"

static int stopsign_is_active = FALSE;
static int stop_requested = FALSE;
static int stop_process = 0;

/*
Name
        IGEactivate_stop_sign

Description
        This routine activates the stop sign by sending it SIGUSR1.  The stop
        process will respond by turning the stop sign red.
*/

void IGEactivate_stop_sign()
{
    if (!stopsign_is_active && stop_process)
    {
        stopsign_is_active = TRUE;
        kill(stop_process, SIGUSR1);
    }
}

/*
Name
        IGEdeactivate_stop_sign

Description
        This routine deactivates the stop sign by sending it SIGUSR2.  The
        stop process will respond by turning the stop sign gray.
*/

void IGEdeactivate_stop_sign()
{
    if (stopsign_is_active && stop_process)
    {
        stopsign_is_active = FALSE;
        kill(stop_process, SIGUSR2);
    }
}

/*
Name
        IGEresetstop

Description
        This routine resets the stop variable and the stop sign to the default
        state.  This indicates that there is nothing "stoppable" going on.
*/

void IGEresetstop()
{
   stop_requested = FALSE;
   IGEdeactivate_stop_sign();
}

/*
Name
        IGEstop

Description
        This routine returns the current state of the stop variable.  It also
        activates the stop sign, on the assumption that if anyone is checking
        for a stop action, then it is valid for the user to see the active
        stop sign.
*/

int IGEstop()
{
    IGEactivate_stop_sign();
    return(stop_requested);
}

/*
Name
        IGEsetstop

Description
        This routine is a signal handler which sets the stop_requested
        variable when SIGUSR1 is detected.  The stop process will send this
        signal when the user clicks on the stop sign.
*/

int IGEsetstop()
{
   return(stop_requested = TRUE);
}

/*
Name
        IGEstopinit

Description
        This function creates the stop process.
*/

IGEstopinit()
{
    char *myargv[16], stoproc[128], stopsym[128], language[32], ige_pid[16];
    int	igepid, sts, found, i;
    FILE *fp = NULL;
#ifdef X11
    int screen_type;
    char colormap[32];
    WLuint16 lscreen_no;
    WLuint32 context_no;
    struct WLnative_info native_info;
#endif

    // Set up the SIGUSR1 signal handler.  Note that using sigset() means that
    // the signal handler does not need to be reset in the signal handler
    // function.  Note also that this is done up front regardless of whether
    // the stop process is successfully spawned, in case some one is dumb
    // enough to go blasting SIGUSR1 at the process without a stop sign
    // attached, like in batch mode or when running under a debugger without
    // the driver.
    sigset(SIGUSR1,(void (*)())IGEsetstop);

    // Set up IGEresetstop to be called on every input.  This is used to clear
    // the stop flag.  Ditto the above note about always doing this.
    ex$add_function(fun = (int (*)())IGEresetstop, mode = EX_START_FUNC);

    // punt in batch mode or when the driver is absent
    if (ex$is_batch() || !ex$is_driver_exist())
        goto wrapup;

    // find the stop process executable
    sts = TRUE;
    found = FALSE;
    for (i = 0; ((sts == TRUE) && (found == FALSE)); i++)
    {
        if (sts = ex$get_path(index = i, 
                              path = stoproc, 
                              type = EX_PRODUCT_PATH,
                              len = sizeof(stoproc)))
        {
            strcat(stoproc,"bin/stopsign");
            if (fp = fopen(stoproc, "r"))
            {
                fclose(fp);
                found = TRUE;
            }
        }
    }
    if (!found)
    {
        printf("stopsign executable not found\n");
        goto wrapup;
    }

    // find the symbol file - this is much easier to do here than in the
    // stopsign process, since exnuc knows about all the product paths here
    sts = TRUE;
    found = FALSE;
    ex$language(language = language);
    for (i = 0; ((sts == TRUE) && (found == FALSE)); i++)
    {
        if (sts = ex$get_path(index = i,
                              path = stopsym, 
                              len = sizeof(stopsym)))
        {
            sprintf(&stopsym[strlen(stopsym)], "config/%s/icons/GRfrm.sym",
                    language);
            if (fp = fopen(stopsym, "r"))
            {
                fclose(fp);
                found = TRUE;
            }
        }
    }
    if (!found)
        stopsym[0] = NULL;

#ifdef X11
    // get the active color map id to pass to the stopsign
    WLget_active_screen(&lscreen_no, &screen_type);
    CMget_exnuc_forms_context(lscreen_no, &context_no);
    WLget_native_info_from_context(lscreen_no, context_no, &native_info);
#endif

    // build the command line
    i = 0;
    myargv[i++] = stoproc;
#ifdef X11
    myargv[i++] = "-c";
    sprintf(colormap, "%d", native_info.colormap);
    myargv[i++] = colormap;
#endif
    igepid = getpid();
    sprintf(ige_pid,"%d",igepid);
    myargv[i++] = ige_pid;
    myargv[i++] = stopsym;
    myargv[i++] = 0;

    // fork the stop process
    sts = ex$fork(num_entry = --i, argu = myargv, childpid = &stop_process);

wrapup:

    return(TRUE);
}

/*
Name
        GRcreate_stopsign

Description
        This function provides a GRNUC entry point to start up a stopsign
        process.
*/

void GRcreate_stopsign()
{
    IGEstopinit();
}

/*
Name
        GRmove_stopsign_to_active_screen

Description
        This function moves the stopsign to the active screen, in a
        multiscreen Intergraph Environ V environment.  The real work actually
        goes on in the stop process, since this process is not aware of what
        screen the stop sign occupies.  For lack of a better communication
        mechanism, this function sends a SIGPWR signal to the stop process,
        which is interpreted there as "make sure I'm on the active
        [virtual|physical] screen."

History
        mrm     05/18/93    creation
*/

#ifdef ENV5
void GRmove_stopsign_to_active_screen()
{
    kill(stop_process, SIGPWR);
}
#endif
