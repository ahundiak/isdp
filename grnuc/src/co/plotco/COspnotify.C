/*
Name
        COspnotify

Description
        This file contains the notification routines called by FI when
        input is received on the Submit Plot form.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm     03/12/89    creation
	madhu	11/27/90    added local plotting interface
        mrm     11/23/91    fixed to redisplay default if user enters
                            an invalid queue name
	sampath 06/30/92    added rotation 
        scw     07/17/92    ansi conversion
        elp     01/13/93    semi port to NT
        mrm     06/08/93    fixed so that "rotate 90" can be turned off, added
                            UMS calls to eliminate strings & conditional
                            compilation.
	Satish  06/16/95    Added Pen_table option
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "plotmsg.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmsg.h"

#if defined( NT )
#if 1  /* because opp can not handle it */
#include <windows.h>
#endif
#endif

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 1  /* because opp can not handle it */
#if defined( X11 )
#include <XFIproto_pub.h>
#elif defined( ENV5 )
#include <FIproto_pub.h>
#elif defined( NT )
#include <shampub.h>
#endif
#else
#include <FI.h>
#endif
#else
#include <FI.h>
#endif

#include "pidef.h"
#include "pi.h"
#include "pilabel.h"

int COspnotify(form_label, gadget_label, value, form)
int form_label;
int gadget_label;
double value;
Form form;
{
    char buf[128], buf1[32];
    int i, row, sel, sts;
    PIplotdata *pd;
    PIcreate *cd;
    double swap_var;

    FILE *fptr;

    /* get a pointer to the current plot data */

    PIgetplotdata(&pd);
    PIgetcreate(&cd);

    /* clear the message field */

    FIfld_get_text(form, FI_MSG_FIELD, 0, 0, 128, (unsigned char *) buf,
                   &sel, &row);
    if (strlen(buf))
    {
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, "", 0);
    }

    /* process the input */

    switch (gadget_label)
    {
      case FI_ACCEPT:
      case FI_CANCEL:
        FIf_erase(form);
        pd->displayed_form = NULL;
        pd->exit = TRUE;
        break;

      case FI_HELP:
        break;

      case SUBMIT_PLOT_TYPE:
        pd->pltype=(int)value;

        if (pd->pltype)		/* local plotting --OBSOLETE-- */
        {
            FIf_cvrt_to_perm_win(form);
            FIg_disable(form, FI_CVT_TO_PERM_WIN);
            FIg_erase(form, SUBMIT_PLOT_REND_TEXT);
            FIg_erase(form, SUBMIT_PLOT_REND_ATTR);
            FIg_erase(form, SUBMIT_PLOT_PEN_TABLE_TEXT);
            FIg_erase(form, SUBMIT_PLOT_PEN_TABLE);
            FIg_erase(form, SUBMIT_PLOT_IPLOT_TEXT);
            FIg_erase(form, SUBMIT_PLOT_IPLOT_OPTIONS);
            FIg_erase(form, SUBMIT_PLOT_PLOTTER_TEXT);
            FIg_erase(form, SUBMIT_PLOT_SELECT_PLOTTER);
            FIg_erase(form, SUBMIT_PLOT_MAIL_BEGIN);
            FIg_erase(form, SUBMIT_PLOT_MAIL_END);
            FIg_erase(form, SUBMIT_PLOT_DATE_TEXT);
            FIg_erase(form, SUBMIT_PLOT_DATE);
            FIg_erase(form, SUBMIT_PLOT_JOB_STATUS);
            FIg_erase(form, SUBMIT_PLOT_QUEUE_STATUS);	
            FIg_erase(form, SUBMIT_PLOT_ROTATE_90_GROUP);
            FIg_display(form, SUBMIT_PLOT_PORT);
            FIg_display(form, SUBMIT_PLOT_PORT_TEXT);
            FIfld_set_text(form, SUBMIT_PLOT_PORT, 0, 0, pd->port, 0);
            sprintf(buf1, "%f", pd->lscale);
            FIfld_set_text(pd->submit_form, SUBMIT_PLOT_SCALE, 0, 0, buf1, 0);

            /* Compute the plot size and display...  */
            COspsizescale(pd, form_label, SUBMIT_PLOT_SCALE, 1.0, form);
            sprintf(buf1, "%d", pd->lcopies);
            FIfld_set_text(pd->submit_form, SUBMIT_PLOT_COPIES, 0, 0, buf1, 0);
        }
        else
        {
            FIg_erase(form, SUBMIT_PLOT_PORT);
            FIg_erase(form, SUBMIT_PLOT_PORT_TEXT);
            FIg_display(form, SUBMIT_PLOT_REND_TEXT);
            FIg_display(form, SUBMIT_PLOT_REND_ATTR);
            FIg_display(form, SUBMIT_PLOT_PEN_TABLE_TEXT);
            FIg_display(form, SUBMIT_PLOT_PEN_TABLE);
            FIg_display(form, SUBMIT_PLOT_IPLOT_TEXT);
            FIg_display(form, SUBMIT_PLOT_IPLOT_OPTIONS);
            FIg_display(form, SUBMIT_PLOT_PLOTTER_TEXT);
            FIg_display(form, SUBMIT_PLOT_SELECT_PLOTTER);
            FIg_display(form, SUBMIT_PLOT_MAIL_BEGIN);
            FIg_display(form, SUBMIT_PLOT_MAIL_END);
            FIg_display(form, SUBMIT_PLOT_DATE_TEXT);
            FIg_display(form, SUBMIT_PLOT_DATE);
            FIg_display(form, SUBMIT_PLOT_JOB_STATUS);
            FIg_display(form, SUBMIT_PLOT_QUEUE_STATUS);	
            FIg_display(form, SUBMIT_PLOT_ROTATE_90_GROUP);
            sprintf(buf1, "%f", pd->plot_x);
            FIfld_set_text(pd->submit_form, SUBMIT_PLOT_X_SIZE, 0, 0, buf1, 0);
            sprintf(buf1, "%f", pd->plot_y);
            FIfld_set_text(pd->submit_form, SUBMIT_PLOT_Y_SIZE, 0, 0, buf1, 0);
            sprintf(buf1, "%.5f", pd->scale);
            FIfld_set_text(pd->submit_form, SUBMIT_PLOT_SCALE, 0, 0, buf1, 0);
            sprintf(buf1, "%d", pd->copies);
            FIfld_set_text(pd->submit_form, SUBMIT_PLOT_COPIES, 0, 0, buf1, 0);
        }

        break;

      case FI_CVT_TO_PERM_WIN:
        FIg_disable(form, gadget_label);
        break;

      case FI_EXECUTE:
        UMSGetByNum(buf, PI_I_Working, 0);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);

        if (pd->pltype)		/* local plotting */		
            COsplocal(pd, buf);
        else
            COspexecute(pd, buf);
	
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);

        break;

      case SUBMIT_PLOT_FILE_NAME:
        FIfld_get_text(form, gadget_label, 0, 0, 128,
                       (unsigned char *) buf, &sel, &row);
        COsppfname(pd, form_label, gadget_label, value, form, buf);
        break;

      case SUBMIT_PLOT_REND_ATTR:
        FIfld_get_text(form, gadget_label, 0, 0, 128,
                       (unsigned char *) buf, &sel, &row);
        sts = COcknamln(buf);
        if (sts == PI_I_NAMETRUNC)
        {
            /* redisplay the truncated name */
            FIfld_set_text(form, gadget_label, 0, 0, buf, 0);
            UMSGetByNum(buf1, PI_I_TruncName, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf1, 0);
        }
        strncpy(pd->rendattr, buf, 128);
        break;

      case SUBMIT_PLOT_PEN_TABLE:

        FIfld_get_text(form, gadget_label, 0, 0, 128,
                       (unsigned char *) buf, &sel, &row);
        sts = COcknamln(buf);
        if (sts == PI_I_NAMETRUNC)
        {
            /* redisplay the truncated name */
            FIfld_set_text(form, gadget_label, 0, 0, buf, 0);
            UMSGetByNum(buf1, PI_I_TruncName, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf1, 0);
        }
	
	if (strlen(buf) == 0)
	{
		pd->pentable[0] = NULL;
		break;
	}
	else
	{
		if ((fptr=fopen(buf,"r")) == NULL)
 		{
			UMSGetByNum(buf1, GR_E_FileNotFound, 0);
			FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf1, 0);	
		}
		else
		{
			fclose(fptr);	

        		strncpy(pd->pentable, buf, 128);
		}
	}
        break;

      case SUBMIT_PLOT_IPLOT_OPTIONS:
        FIfld_get_text(form, gadget_label, 0, 0, 256,
                       (unsigned char *)pd->iplot, &sel, &row);
        if (pd->rotate_90)
        {
            if (strstr(pd->iplot, "-rot"))
            {
                UMSGetByNum(buf1, PI_I_RotInIplot, 0);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf1, 0);
            }
        }
        break;

      case SUBMIT_PLOT_SELECT_PLOTTER:
        FIfld_get_text(form, gadget_label, 0, 0, 128,
                       (unsigned char *) buf, &sel, &row);
        sscanf(buf, "%s", pd->queue);
        sts = COpqinfo(pd->queue, pd->plotter_max, &pd->plotter_max[1],
                       pd->plotter_unit);
        if (!(sts & 1))
        {
            UMSGetByNum(buf, PI_E_InvalidQueue, "%s", pd->queue);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);

            /* grab the first plotter in the list */
            FIfld_get_list_text(form, SUBMIT_PLOT_SELECT_PLOTTER,
                                0, 0, 128, (unsigned char *) buf, &sel);
            sscanf(buf, "%s", pd->queue);
            sts = COpqinfo(pd->queue, pd->plotter_max, &pd->plotter_max[1],
                           pd->plotter_unit);
        }
        COspformatqinfo(pd->queue, pd->plotter_max[0],
                        pd->plotter_max[1], pd->plotter_unit, buf);
        FIfld_set_text(form, SUBMIT_PLOT_SELECT_PLOTTER, 0, 0, buf, 0);

        /* display the plot size and scale */
        if (!COsizeplot(pd))
        {
            UMSGetByNum(buf, PI_I_PlotScaled, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        }
        COspshosize(pd);
        break;

      case SUBMIT_PLOT_PORT:
        FIfld_get_text(form, gadget_label, 0, 0, 16,
                       (unsigned char *) pd->port, &sel, &row);
        if (pd->port[0] == NULL)
        {
            strcpy(pd->port,"/dev/tty00");
            FIfld_set_text(form, gadget_label, 0, 0, pd->port, 0);
        }
        break;

      case SUBMIT_PLOT_X_SIZE:
      case SUBMIT_PLOT_Y_SIZE:
      case SUBMIT_PLOT_SCALE:
        if (pd->pltype)
        {
            UMSGetByNum(buf, PI_W_CheckLocalLimits, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        }
        COspsizescale(pd, form_label, gadget_label, value, form);
        break;

      case SUBMIT_PLOT_DATE:
        FIfld_get_text(form, gadget_label, 0, 0, 32,
                       (unsigned char *) pd->date, &sel, &row);
        break;

      case SUBMIT_PLOT_COPIES:
        FIfld_get_text(form, gadget_label, 0, 0, 128,
                       (unsigned char *) buf, &sel, &row);
        if (pd->pltype)
            pd->lcopies = atoi(buf);
        else
            pd->copies = atoi(buf);
        break;

      case SUBMIT_PLOT_MAIL_BEGIN:
      case SUBMIT_PLOT_MAIL_END:
        if (gadget_label == SUBMIT_PLOT_MAIL_BEGIN) 
            i = PI_MAIL_BEGIN;
        else
            i = PI_MAIL_END;
        if (pd->mail & i)
            pd->mail &= ~i;
        else
            pd->mail |= i;
        break;

      case SUBMIT_PLOT_ROTATE_90:
        pd->rotate_90 = (int)value;
        if (pd->rotate_90)
        {
            if (strstr(pd->iplot, "-rot"))
            {
                UMSGetByNum(buf1, PI_I_RotInIplot, 0);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf1, 0);
            }
        }

        /* rescale and display the plot size and scale */

        swap_var = pd->file_x;
        pd->file_x = pd->file_y;
        pd->file_y = swap_var;
        swap_var = pd->lplot_x;
        pd->lplot_x = pd->lplot_y;
        pd->lplot_y = swap_var;
        swap_var = pd->plot_x;
        pd->plot_x = pd->plot_y;
        pd->plot_y = swap_var;

        /* adjust the appropriate value */

        if ((pd->last_value == PI_X_SIZE))
            pd->last_value = PI_Y_SIZE;
        else if ((pd->last_value == PI_Y_SIZE))
            pd->last_value = PI_X_SIZE;

        if (!COsizeplot(pd))
        {
            UMSGetByNum(buf, PI_I_PlotScaled, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        }
        COspshosize(pd);

        break;

      case SUBMIT_PLOT_JOB_STATUS:
        UMSGetByNum(buf, PI_I_Working, 0);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        COspjobsts(pd->lastjobqueue, pd->lastjobid, pd->lastjobname, buf);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        FIg_reset(form, gadget_label);
        break;

      case SUBMIT_PLOT_QUEUE_STATUS:
        FIg_reset(form, gadget_label);
        COchcmd(PI_SUBMIT_FORM, PI_QUEUE_FORM, pd, cd);
        break;

      case SUBMIT_PLOT_CREATE_PLOT:
        FIg_reset(form, gadget_label);
        COchcmd(PI_SUBMIT_FORM, PI_CREATE_FORM, pd, cd);
        break;

      default:
        break;
    }
    return(FI_SUCCESS);
}
