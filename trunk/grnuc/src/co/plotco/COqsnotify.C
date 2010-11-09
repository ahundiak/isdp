/*
Name
        COqsnotify

Description
        This file contains the notification routines called by FI when
        input is received on the Queue Status form.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm     03/12/89    creation
        elp     01/13/89    semi port to NT
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "plotmsg.h"

#if defined( NT )
#if 1  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 1  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif

#include "pidef.h"
#include "pi.h"
#include "pilabel.h"

int COqsnotify (
  int    form_label,
  int    gadget_label,
  double value,
  Form   form)
{
    char buf[128], jobnum[128];
    int row, sel, sts;
    PIplotdata *pd;
    PIcreate *cd;

    /* get a pointer to the current plot data */

    PIgetplotdata (&pd);
    PIgetcreate (&cd);

    /* clear the message field */

    FIfld_get_text (form, FI_MSG_FIELD, 0, 0, 128, (unsigned char *) buf,
                    &sel, &row);
    if (strlen (buf))
    {
        FIfld_set_text (form, FI_MSG_FIELD, 0, 0, "", 0);
        FIg_display (form, FI_MSG_FIELD);
    }

    switch (gadget_label)
    {
        case FI_ACCEPT:
        case FI_CANCEL:
            FIf_erase (form);
            pd->displayed_form = NULL;
            pd->exit = TRUE;
            break;

        case FI_HELP:
            break;

        case FI_CVT_TO_PERM_WIN:
            FIg_disable (form, gadget_label);
            break;

        case FI_EXECUTE:
        case QSTATUS_UPDATE:
        case QSTATUS_QUEUE:
            UMSGetByNum(buf, PI_I_Working, 0);
            FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
            COqsupdate (pd, form_label, gadget_label, value, form);
            if (gadget_label != QSTATUS_QUEUE)
            {
                FIg_reset (form, gadget_label);
            }
            break;

        case QSTATUS_JOB_LIST:
            FIfld_get_text (form, gadget_label, (int)value, 0, 128,
                            (unsigned char *) buf, &sel, &row);
            sts = sscanf (buf, "%s %*s %s", jobnum, pd->jobtocan);
            if (!strchr (jobnum, ':'))
            {
                pd->jobtocan[0] = NULL;
                FIfld_set_select (form, gadget_label, (int)value, 0, FALSE);
            }
            break;

        case QSTATUS_CANCEL_PLOT:
            UMSGetByNum(buf, PI_I_Working, 0);
            FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
            COqscancel (form_label, gadget_label, value, form);
            FIg_reset (form, gadget_label);
            break;

        case QSTATUS_SUBMIT_PLOT:
            FIg_reset (form, gadget_label);
            COchcmd (PI_QUEUE_FORM, PI_SUBMIT_FORM, pd, cd);
            break;

        case QSTATUS_CREATE_PLOT:
            FIg_reset (form, gadget_label);
            COchcmd (PI_QUEUE_FORM, PI_CREATE_FORM, pd, cd);
            break;

        default:
            break;
    }
    return (FI_SUCCESS);
}
