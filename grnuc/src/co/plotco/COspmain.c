/*
Name
        COspmain

Description
        This file may be compiled to provide a test drive for the
        Submit Plot form.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm      ?/ ?/8?    creation
        elp     01/13/92    semi port to NT
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/param.h>
#ifdef X11
#include <Intrinsic.h>
#endif
#ifdef ENV5
#include <tools.h>
#endif
#include <FI.h>
#include <UMS.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "pilabel.h"
#include "pidef.h"
#include "pi.h"

#define Null ((char*)NULL)

extern int COspnotify(), COqsnotify();

PIplotdata global_pd;          /* contains plot submission data */
PIcreate global_cd;            /* contains plotfile creation data */

int PIgetplotdata(PIplotdata **pd)
{
    *pd = &global_pd;
    return(TRUE);
}

int PIgetcreate(PIcreate **cd)
{
    *cd = &global_cd;
    return(TRUE);
}

main(int argc, char *argv[])
{
    int i;
    char path[MAXPATHLEN], *product, buf[MAXPATHLEN];
#ifdef X11
    Display  *display;
    Widget top_level;
    XtAppContext app_context;
#endif

    /* initialize global data */
    global_pd.file[0] = NULL;
    global_pd.queue[0] = NULL;
    global_pd.date[0] = NULL;
    global_pd.jobtocan[0] = NULL;
    global_pd.file_unit[0] = NULL;
    global_pd.plot_unit[0] = NULL;
    global_pd.plotter_unit[0] = NULL;
    global_pd.lastjobqueue[0] = NULL;
    global_pd.lastjobid[0] = NULL;
    global_pd.lastjobname[0] = NULL;
    global_pd.iplot[0] = NULL;
    global_pd.rendattr[0] = NULL;
    global_pd.pentable[0] = NULL;
    global_pd.port[0]=NULL;
    global_pd.raster[0] = NULL;
    global_pd.command = PI_SUBMIT_FORM;
    global_pd.filetype = PI_IGDS_FILE;
    global_pd.last_value = PI_SCALE;
    global_pd.mode = PI_GRAPHICS;
    global_pd.mail = 0;
    global_pd.exit = FALSE;
    global_pd.copies = 1;
    global_pd.lcopies = 1;
    global_pd.file_x = global_pd.file_y = 0.0;
    global_pd.plot_x = global_pd.plot_y = 0.0;
    global_pd.scale = 1.0;
    global_pd.lplot_x = global_pd.lplot_y = 1.0;
    global_pd.lscale = 1.0;
    global_pd.plotter_max[0] = global_pd.plotter_max[1] = 10000.0;


    /* initialize the toolkit */
#if defined( NT )
    FI_enter( hInst );
#endif

#ifdef ENV5
    Enter_tools();
    FI_enter();
    Enable_events(FI_EVENT_MASK);
#endif

#ifdef X11
    /* initialize the toolkit */
    top_level = XtVaAppInitialize(&app_context, "plot", NULL, NULL,
#ifdef SUNOS
                                  (Cardinal *)&argc,
#else
                                  (int *)&argc,
#endif
                                  (String *)argv, (String *)NULL, NULL);
 
    /* initialize the forms system */
    display = XtDisplay(top_level);
    FSEnter(display, 0);
    FI_enter(display, DefaultColormap(display, DefaultScreen(display)), 32);
#endif

    /* get the path to GRNUC */
    path[0] = NULL;
    product = "Grnuc";
    GRget_product_data(product, Null, Null, Null, Null, path);
    if (path[0] == NULL)
    {
        printf("Cannot find %s in $INGRHOME/product_data\n", product);
        exit(1);
    }

    /* set the path for I/FORMS to find the form definition files */
#if defined( NT )
    sprintf(buf, ".;%sconfig\\english\\forms", path);
#else
    sprintf(buf, ".:%sconfig/english/forms", path);
#endif
    FI_set_form_path(buf);

#if defined( NT )
    sprintf(buf, ".;%sconfig\\english\\icons", path);
#else
    sprintf(buf, ".:%sconfig/english/icons", path);
#endif
    FI_set_symbol_path(buf);

    /* initialize the message system */
    sprintf(buf, "%s/config/english/messages/pltmessage.msg", path);
    UMSInitMsg(buf, UMS_INDEX);

    /* create the forms */
    FIf_new(PI_SUBMIT_FORM, "SubmitPlot", COspnotify, &global_pd.submit_form);
    FIf_new(PI_QUEUE_FORM, "PlotQStat", COqsnotify, &global_pd.qstat_form);

    /* disable the Create Plot buttons */
    FIg_disable(global_pd.submit_form, SUBMIT_PLOT_CREATE_PLOT);
    FIg_disable(global_pd.submit_form, QSTATUS_CREATE_PLOT);

    /* read the defaults file */
    COfiledef(TRUE, path, global_pd.file, global_pd.queue,
              global_cd.ctable, global_pd.iplot, global_pd.rendattr,
              global_pd.port, &i, global_pd.pentable);

    if (global_pd.port[0] == NULL)
    {
        strcpy(global_pd.port,"/dev/tty00"); /* assign a reasonable default */
    }

    /* bring up the submit form */
    COchcmd (NULL, PI_SUBMIT_FORM, &global_pd, &global_cd);

    /* wait for input */
    FI_process_forms();

    exit(0);
}
