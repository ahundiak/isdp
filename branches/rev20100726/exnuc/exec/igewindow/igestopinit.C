#include "igrtypedef.h"
#include <stdio.h>
#include <sys/signal.h>
#include "exmacros.h"
#include "exlocale.h"
#include "exdef.h"


#ifdef X11
#include <FI.h>
#include <X11/Xlib.h> 
#include <X11/Xutil.h> 
#include <X11/Xresource.h> 

extern Form	EX_msg_form;
extern char     EX_display_name[];
extern long     EX_stopproc_id;
extern char     EX_runname[];
extern XrmDatabase EXrDB;

extern Display *EXdisplay;
extern int      EXscreen;
extern Colormap EXcolormap[];
extern XrmDatabase EXrDB;
extern int execvp();
extern int IGE_translate_color();
#endif

extern long     EX_stopproc_id;

extern  IGRint	IGEsetstop();
extern  void	IGEresetstop();

IGEstopinit()
{
#ifdef X11
    IGRchar	*myargv[20];
    char        cmap[32];
#endif
#ifdef ENV5
    IGRchar	*myargv[4];
#endif
    IGRchar     stoproc[120];
    IGRchar     stopsym[120];
    IGRchar	language[30];
    IGRint	igepid;
    IGRchar	ige_pid[10];
    IGRint	status;
    IGRint	done;   
    IGRint	i;
    FILE	*fp;

    fp = 0;
    if (ex$is_batch())
    {
        goto wrapup;
    }

    /* Set up IGEsetstop to be called when SIGUSR1 is sent to the IGE
       process */

    signal(SIGUSR1,(void (*)())IGEsetstop);

    /*  Set up IGEresetstop to be called on every input.  This is used to 
        clear the stop flag. */

    ex$add_function( fun = (int (*)())IGEresetstop,
		    mode = EX_START_FUNC);


    /*  loop until the stop process is found     */

    status = TRUE;
    done = FALSE;

    for (i = 0; ((status == TRUE) && (done == FALSE)); i++)
    {
        if (status = ex$get_path(index = i, 
                                 path = stoproc, 
                                 type = EX_PRODUCT_PATH,
                                 len = sizeof(stoproc)))
        {

            strcat(stoproc,"bin/");
            strcat(stoproc,"grstoproc");

            if (fp = fopen(stoproc,"r"))
            {
                done = TRUE;
            }
        }
    }


    /*	If the stop process is found, fork the processs and pass IGE's process
	id so the stop process knows where to send the SIGUSR1 signal */
    if (ex$is_driver_exist())
    {
        if (done)
        {
            fclose(fp);
            status = TRUE;
            done = FALSE;
            for (i = 0; ((status == TRUE) && (done == FALSE)); i++)
            {
                if (status = ex$get_path(index = i,
                                         path = stopsym, 
                                         len = sizeof(stopsym)))
                {

                    strcat(stopsym,"config/");
                    ex$language( language = language);
                    strcat(stopsym,language);
                    strcat(stopsym,"/icons/GRfrm.sym");

                    if (fp = fopen(stopsym,"r"))
                    {
                        done = TRUE;
                    }
                }
            }
	       
            if (done)
            {
                fclose(fp);
            }
            else
            {
                stopsym[0] = '\0';
            }
            i = 0;
            myargv[i++] = stoproc;
#ifdef X11
            myargv[i++] = "-c";
            sprintf(cmap, "%d", EXcolormap[0]);
            myargv[i++] = cmap;
#endif
            igepid = getpid();
            sprintf(ige_pid,"%d",igepid);
            myargv[i++] = ige_pid;
            myargv[i++] = stopsym;
            myargv[i++] = 0;
#ifdef DEBUG
        {
            int j;

            printf("calling ex$fork\n");
            for (j = 0; j < i; j++)
                printf("myargv[%d] = :%s:\n", j, myargv[j]);
        }
            status =
#endif
                ex$fork(num_entry = --i,
                        argu = myargv,
                        childpid = (int *) &EX_stopproc_id);
#ifdef DEBUG
            printf("ex$fork: %#x, %d\n", status, EX_stopproc_id);
#endif
        }
        else
        {
            printf("Could not find stop process\n");
        }
    }
#ifdef DEBUG
    else
        printf("Couldn't find the $$#$@ driver \n");
#endif

wrapup:
    return(1);
}
