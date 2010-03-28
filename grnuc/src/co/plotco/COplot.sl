/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COplot.sl

Description
        This command drives all of the I/DRAFT plotting forms - Create
        Plotfile, Create Shaded Plotfile, Submit Plotfile, or Display
        Queue Status.  Each command has a corresponding form which is
        displayed when that form is "active".  Buttons on the forms are
        used to travel between commands.

History
        mrm     03/27/89    creation
                03/22/90    add help function
	madhu	11/27/90    local plot variables initialisation
	sampath 06/30/92    added rotation 
        scw     07/17/92    ansi conversion
        mrm     10/03/92    added Submit Local Plot option
	Satish  06/16/95    added Pen_table option
*/

command_object      GRMCrePlot, PI_CREATE_FORM, GRCrPlRq
synonym             GRMSubPlot, PI_SUBMIT_FORM, GRSbPlFl
synonym             GRMQueSts,  PI_QUEUE_FORM,  GRShPlQSt
synonym             GRMSbLcPl,  PI_SUBMIT_LOCAL_FORM, GRSbLcPl
product_name        "$GRNUC"
class               "COplot"
super_class         "CEO_LOCATE"
form                "CreatePlot", PI_CREATE_FORM, 0, 0, 0
form                "SubmitPlot", PI_SUBMIT_FORM, 0, 0, 0
form                "PlotQStat",  PI_QUEUE_FORM,  0, 0, 0
start_state         wait_for_input

specification

#include "grmessage.h"
#include "FI.h"
#include "pilabel.h"
#include "pidef.h"
#include "pi.h"

instance
{
    PIplotdata pd;          /* contains plot submission data */
    PIcreate cd;            /* contains plotfile creation data */
}

implementation

#include "coimport.h"
#include "FI.h"
#include "pilabel.h"
#include "pidef.h"
#include "pi.h"
#include "exmacros.h"
#include "plotmacros.h"
#include "grmessage.h"
#include "execmsg.h"
#include "plotmsg.h"

extern int FIf_erase ();
extern int FIfld_set_text ();
extern int FIg_display ();
extern void EMSsubbs_put_locate_window();

static OM_S_OBJID plotco_id;

int PIgetplotdata (pd)
PIplotdata **pd;
{
    int sts;

    sts = om$send (msg = message COplot.getpd (pd),
                   senderid = NULL_OBJID,
                   targetid = plotco_id);

    return (sts);
}

int PIgetcreate (cd)
PIcreate **cd;
{
    int sts;

    sts = om$send (msg = message COplot.getcd (cd),
                   senderid = NULL_OBJID,
                   targetid = plotco_id);

    return (sts);
}

int COplot_set_help_topic (command_type)
int command_type;
{
    IGRchar *c;

    /* set the proper Help topic */

    if (command_type == PI_SUBMIT_FORM)
    {
        c = "GRSbPlFl";
    }
    else if (command_type == PI_QUEUE_FORM)
    {
        c = "GRShPlQSt";
    }
    else
    {
        c = "GRCrPlRq";
    }

    om$send (msg = message super_cmd.help_topic (0, c),
             senderid = NULL_OBJID,
             targetid = plotco_id);

    if (ex$is_help_active())
    {
        om$send (msg = message super_cmd.help (),
                 senderid = NULL_OBJID,
                 targetid = plotco_id);
    }
    return(1);
}


state_table
#include "pidef.h"

at init do plot_init()
at wakeup do plot_wakeup()
at sleep do plot_sleep()
at delete do plot_delete()

state wait_for_input
    filter get_event
        on EX_DATA or EX_STRING
            do store_window ()
            state .
        on EX_FORM_FINISHED
            do plot_sleep ()
            state terminate

action plot_init ()
{
    int i;
    char grnucpath[128];

    /* initialize generic data */

    me->pd.file[0] = NULL;
    me->pd.queue[0] = NULL;
    me->pd.date[0] = NULL;
    me->pd.jobtocan[0] = NULL;
    me->pd.file_unit[0] = NULL;
    me->pd.plot_unit[0] = NULL;
    me->pd.plotter_unit[0] = NULL;
    me->pd.lastjobqueue[0] = NULL;
    me->pd.lastjobid[0] = NULL;
    me->pd.lastjobname[0] = NULL;
    me->pd.iplot[0] = NULL;
    me->pd.rendattr[0] = NULL;
    me->pd.pentable[0] = NULL;
    me->pd.port[0]=NULL;
    me->pd.raster[0] = NULL;
    me->pd.command = me->mytype;
    me->pd.filetype = (me->mytype == PI_CREATE_IGM_FORM) ? PI_IGM_FILE : PI_IGDS_FILE;
    me->pd.last_value = PI_SCALE;
    me->pd.mode = PI_GRAPHICS;
    me->pd.mail = 0;
    me->pd.exit = FALSE;
    me->pd.rotate_90 = 0;
    me->pd.copies = 1;
    me->pd.lcopies = 1;
    me->pd.file_x = me->pd.file_y = 0.0;
    me->pd.plot_x = me->pd.plot_y = 0.0;
    me->pd.scale = 1.0;
    me->pd.lplot_x = me->pd.lplot_y = 1.0;
    me->pd.lscale = 1.0;
    me->pd.plotter_max[0] = me->pd.plotter_max[1] = 10000.0;
    me->pd.create_form = me->forms[0].form_ptr;
    me->pd.submit_form = me->forms[1].form_ptr;
    me->pd.qstat_form = me->forms[2].form_ptr;

    /* initialize grnuc-specific (Create Plot) data */

    me->cd.ctable[0] = NULL;
    me->cd.seedfile[0] = NULL;
    me->cd.creflags = (me->mytype == PI_CREATE_IGM_FORM) ? PI_CREATE_IGM : PI_CREATE_IGDS;
    me->cd.creflags |= PI_TOGGLE_FENCE;
    me->cd.wftoggle = PI_TOGGLE_FENCE;
    me->cd.cvprism = NULL;
    me->cd.flood_index = -1;

    /* get the path to the defaults file */

    grnucpath[0] = NULL;
#ifdef IDRAW
    get_modtype_data ("Mds", NULL, NULL, NULL, NULL, grnucpath);
#else
    get_modtype_data ("Grnuc", NULL, NULL, NULL, NULL, grnucpath);
#endif
    if (grnucpath[0] != NULL)
    {
        /* read the defaults file */

        COfiledef (TRUE, grnucpath, me->pd.file, me->pd.queue, me->cd.ctable,
                   me->pd.iplot, me->pd.rendattr, me->pd.port, &i, me->pd.pentable);

        if (i) /* toggle to window */
        {
            me->cd.wftoggle = PI_TOGGLE_WINDOW;
            FIg_set_state_on (me->pd.create_form, CREATE_PLOT_WINDOW_FENCE);
        }

        if (me->pd.port[0] == NULL)
        {
            strcpy(me->pd.port,"/dev/tty00"); /* assign a reasonable default */
        }
    }
}

action plot_wakeup ()
{
    /* display the proper form */

    plotco_id = my_id;
    COchcmd (NULL, me->mytype, &me->pd, &me->cd);
}

action plot_sleep ()
{
    if (me->pd.displayed_form)
        FIf_erase (me->pd.displayed_form);
    FIf_erase (me->pd.create_form);
    plotco_id = NULL_OBJID;
}

action form_notification
{
    long i;
    char grnucpath[128];

    IGRchar path[128], path1[128], *tmp;
    FILE *file_read, *file_write;
    IGRchar curr_line[80], *ch_ptr;
    IGRboolean remark;


    ex$message (msgnumb = EX_S_Clear);

    switch (form_label)
    {
        case PI_CREATE_FORM:
        case PI_CREATE_IGM_FORM:
            me->ret = COcpnotify (form_label, gadget_label, value, form_ptr);
            break;

        case PI_SUBMIT_FORM:
            me->ret = COspnotify (form_label, gadget_label, value, form_ptr);
            break;

        case PI_QUEUE_FORM:
            me->ret = COqsnotify (form_label, gadget_label, value, form_ptr);
            break;

        default:
            me->ret = FALSE;
    }
    if (me->pd.exit)
    {
        /* write the defaults file */

        grnucpath[0] = NULL;
#ifdef IDRAW
        get_modtype_data ("Mds", NULL, NULL, NULL, NULL, grnucpath);
#else
        get_modtype_data ("Grnuc", NULL, NULL, NULL, NULL, grnucpath);
#endif
        if (grnucpath[0] != NULL)
        {
            i = (me->cd.wftoggle == PI_TOGGLE_WINDOW);
            COfiledef (FALSE, grnucpath, me->pd.file, me->pd.queue,
                       me->cd.ctable, me->pd.iplot, me->pd.rendattr, me->pd.port, &i, me->pd.pentable);

	/*  Write the pen table file to 
	    $INGRHOME/ip/iplotsrv/config/system/iplotsrv.cfg
	*/
 
            GRget_ingrhome(path);
            strcat(path ,"/ip/iplotsrv/config/system/");
 
            strcpy(path1,path);
            strcat(path1,"iplotsrv.cfg");
            file_read = fopen(path1,"r");
            if (file_read == NULL)
            {
                goto clean_up;
            }
 
            strcpy(path1,path);
            strcat(path1,"iplotsrv_temp");
            file_write = fopen(path1,"w");
 
            if (file_write == NULL)
 
            {
		        fclose(file_read);
                goto clean_up;
            }
 
            while (fgets(curr_line, 80, file_read) != NULL)
            {
                remark = FALSE;
                tmp = strstr(curr_line,"IPLOTSRV_DEFAULT_PEN_TABLE");

	    /* Parse the line only if it contains the keyword */

                if (tmp != NULL)
                {
                        ch_ptr = curr_line;
                        while(ch_ptr != tmp)
                        {

	    		/* check whether the line containing the keyword
			   is a remark statement.
			*/

                                if (*ch_ptr == '#')
                                {
 
                                        remark = TRUE;
                                        break;
 
                                }
                                ch_ptr++;
                        }
			
			/* If line is a remark statement, write it as it is */
	 
                        if (remark == TRUE)
                        {
                                fprintf(file_write,"%s",curr_line);
                                continue;
                        }
 
                        strcpy(curr_line,"IPLOTSRV_DEFAULT_PEN_TABLE = ");
                       	if (me->pd.pentable[0] != NULL) 
				strcat(curr_line, me->pd.pentable);
			else
				strcat(curr_line, "none");
				
                        fprintf(file_write,"%s",curr_line);
                }
                else
                {
                        fprintf(file_write,"%s",curr_line);
                }
            }
            fclose(file_read);
            fclose(file_write);

	/* close files and reopen them to write from temp to cfg file */ 

            strcpy(path1,path);
 
            strcat(path1,"iplotsrv_temp");
            file_read = fopen(path1,"r");
            if (file_read == NULL)
            {
                goto clean_up;
            }
 
            strcpy(path1,path);
            strcat(path1,"iplotsrv.cfg");
            file_write = fopen(path1,"w");
	    if (file_write == NULL)
            {
                fclose(file_read);
                goto clean_up;
            }

            while (fgets(curr_line, 80, file_read) != NULL)
                fprintf(file_write,"%s",curr_line);
 
            fclose(file_read);
            fclose(file_write);
 
        }

clean_up:
        /* terminate the command */

        *(me->response) = EX_FORM_FINISHED;
        i = sizeof (struct EX_button);

        ex$putque (msg = &me->ret,
                   response = me->response,
                   byte = &i,
                   buffer = me->response_data);
    }
    else if (me->pd.command != me->mytype)
    {
        /* changed forms; set mytype */

        me->mytype = me->pd.command;
    }

}

action plot_delete
{
    if (me->cd.cvprism)
        om$dealloc (ptr = me->cd.cvprism);
}

action store_window ()
{
    int sts;
    char buf[64];

    me->cd.creflags &= ~PI_HAVE_FENCE;

    sts = plot$get_window_range (msg = &me->ret,
                                 event = &me->event1,
                                 window = &me->cd.window,
                                 world = me->cd.range,
                                 view = &me->cd.range[6]);
    if (sts)
    {
        me->cd.creflags |= PI_HAVE_WINDOW;
        buf[0] = NULL;
        EMSsubbs_put_locate_window(me->cd.window.objid,me->cd.window.osnum);
    }
    else
    {
        me->cd.creflags &= ~PI_HAVE_WINDOW;
        if (me->ret == PI_F_NOWINDOW)
        {
            ex$message (msgnumb = PI_E_WinNotFnd, buff = buf);
        }
        else
        {
            ex$message (msgnumb = PI_E_CantPltSelWin, buff = buf);
        }
    }
    if(!buf[0])
	    COcpnotify (PI_CREATE_FORM, CREATE_PLOT_FILE_NAME, 1.0, me->pd.create_form);
    else
	    FIfld_set_text (me->pd.create_form, FI_MSG_FIELD, 0, 0, buf, 0);

}

action getpd (PIplotdata **pd)
{
    *pd = &me->pd;
    return (OM_S_SUCCESS);
}

action getcd (PIcreate **cd)
{
    *cd = &me->cd;
    return (OM_S_SUCCESS);
}

