/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COcpnotify

Description
        This file contains the notification routines called by FI when
        input is received on the Create Plot form.

History
        03/12/89:mrm:creation
        07/17/92:scw:ansi conversion
        01/13/93:elp:semi port to NT
	03/02/93:Carlos:UMS compliance and header
Keywords
 plot      
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef STANDALONE
#include "coimport.h"
#endif
#include <sys/types.h>
#include <sys/stat.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "plotmsg.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsmacros.h"

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
#include "plotmacros.h"
#include "exdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"

extern IGRint GRplot_fence_del();

#argsused
int COcpnotify (form_label, gadget_label, value, form)
int form_label;
int gadget_label;
double value;
Form form;
{
    char buf[128], *c, *c1;
    int i, j, sts, msg, sel;
    PIcreate *cd;
    PIplotdata *pd;
#ifndef NT
    struct stat filestat;
#else
    struct _stat filestat;
#endif
    struct GRid fence, window,act_fence;
    struct GRmd_env mod;
    struct GRevent window_event;
    IGRlong msg1,sts1;

    /* get a pointer to the current plot data */

    PIgetplotdata (&pd);
    PIgetcreate (&cd);

    /* clear the message field */

    FIfld_get_text (form, FI_MSG_FIELD, 0, 0, 128,
                    (unsigned char *) buf, &sel, &i);
    if (strlen (buf))
    {
        FIfld_set_text (form, FI_MSG_FIELD, 0, 0, "", 0);
    }

    /* get the current module info */

    i = sizeof (struct GRmd_env);
    gr$get_module_env (msg = &sts, sizbuf = &i, buffer = &mod, nret = &i);

    /* process the input */

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

        case FI_EXECUTE:

/* BEGIN 90N2045
*/
	    if ((cd->wftoggle == PI_TOGGLE_FENCE) &&
		!(cd->creflags & PI_HAVE_FENCE))
	    {
                    cd->creflags &= ~PI_HAVE_WINDOW;
	        
	            if (cd->cvprism) 
        	    {
                	om$dealloc (ptr = cd->cvprism);
	                cd->cvprism = NULL;
        	    }

 /* The function GRplot_fence_del() has been called as a part of the 
    TR# 119418207 wherein we need to prompt the message "no active
    fence defined" when the fence element is in the undelete buffer.
    This function is implemented in the file GRudsave.I
    
    If the fence element is in the undelete buffer, the function 
    returns a TRUE flag and hence the control will be transferred
    to give a message "no active fence defined"
 */ 
    
             sts1 = gr$gsget_fence (msg = &msg1, fence_id = &act_fence);
             if (!(sts1 & msg1 & 1)) goto wrapup1;

             if(GRplot_fence_del()) goto wrapup1; 

                    COget_fence_range (&sts, &mod, &fence, &cd->window,
                                   cd->range, &cd->range[6], &cd->cvprism);
                    if (sts & 1)
                    {
                      cd->creflags |= PI_HAVE_FENCE;
                    }
                    else
                    {
        wrapup1:            /* no fence defined; notify user */
                       ex$message (msgnumb = PI_F_NoActFncDfn, buff = buf);
                       FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
		       break;
                    }
            }

/* END 90N2045
*/
            if ((cd->wftoggle == PI_TOGGLE_WINDOW) &&
                !(cd->creflags & PI_HAVE_WINDOW))
            {
	        /* window not identified */
                cd->creflags &= ~PI_HAVE_FENCE;
                ex$message (msgnumb = PI_P_IdWinPlt, buff = buf);
                FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
            }
            
            else if (strlen (pd->file) == 0)
            {
                /* filename not specified */
                ex$message (msgnumb = PI_P_EntPFName, buff = buf);
                FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
            }
            else
            {
                /* create the plot file */
                ex$message (msgnumb = PI_I_CreatingPF, buff = buf);
                FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
                plot$create_plotfile(msg = &sts,
                                     filetype = pd->filetype,
                                     module = &mod,
                                     dbtype = "3d",
                                     range = cd->range,
                                     window = &cd->window,
                                     cvprism = cd->cvprism,
                                     plotfile = pd->file,
                                     seedfile = cd->seedfile,
                                     color_table = cd->ctable,
                                     flood_index = cd->flood_index,
                                     status = buf);
                FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
            }
            break;

        case CREATE_PLOT_WINDOW_FENCE:
    
#ifndef NT
             if ((stat (pd->file, &filestat)) == 0)
#else
             if ((_stat (pd->file, &filestat)) == 0)
#endif
             {
                    ex$message (msgnumb = PI_I_ExstFOvrwrt, field = ERROR_FIELD);
                    ex$message (msgnumb = PI_I_ExstFOvrwrt, buff = buf);
                    FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
             }
            /* deallocate previously used memory */
            if (cd->cvprism) 
            {
                om$dealloc (ptr = cd->cvprism);
                cd->cvprism = NULL;
            }

            if (cd->wftoggle == PI_TOGGLE_WINDOW) /* now reads fence */
            {
                cd->creflags &= ~PI_HAVE_WINDOW;
                cd->wftoggle = PI_TOGGLE_FENCE;
         
             sts1 = gr$gsget_fence (msg = &msg1, fence_id = &act_fence);
             if (!(sts1 & msg1 & 1)) goto wrapup2;

             if(GRplot_fence_del()) goto wrapup2; 
 
                /* get the active fence id and the window & range */
                /* associated with it */
                COget_fence_range (&sts, &mod, &fence, &cd->window,
                                   cd->range, &cd->range[6], &cd->cvprism);
                if (sts & 1)
                {
                    cd->creflags |= PI_HAVE_FENCE;
                }
                else
                {
      wrapup2:         /* no fence defined; notify user */
                    cd->creflags &= ~PI_HAVE_FENCE;
                    ex$message (msgnumb = PI_F_NoActFncDfn, buff = buf);
                    FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
		}
	    }
            else if (cd->wftoggle == PI_TOGGLE_FENCE) /* now window */
            {
                cd->creflags &= ~PI_HAVE_FENCE;
                cd->wftoggle = PI_TOGGLE_WINDOW;

                /* check for single active window */

                sts = dp$get_gragad_id (msg = &msg,
                                        mod_GRid = &mod,
                                        name = "*", 
                                        array_size = 1,
                                        total_num = &i,
                                        numberofids = &j,
                                        found_GRids = &window,
                                        type_gragad = IGE_GG | ACTIVE_GG);

                if ((sts & msg & 1) && (i == 1))
                {
                    /* single window active, simulate a user selection */

                    window_event.response = EX_DATA;
                    window_event.event.button.objid = window.objid;
                    window_event.event.button.osnum = window.osnum;

                    sts = plot$get_window_range (msg = &msg,
                                                 event = &window_event,
                                                 window = &cd->window,
                                                 world = cd->range,
                                                 view = &cd->range[6]);
                    if (sts)
                    {
                        cd->creflags |= PI_HAVE_WINDOW;
                    }
                    else
                    {
                        cd->creflags &= ~PI_HAVE_WINDOW;
                        i = (msg == PI_F_NOWINDOW) ?
                                          PI_E_WinNotFnd : PI_E_CantPltSelWin;
                        ex$message (msgnumb = i, buff = buf);
                        FIfld_set_text (pd->create_form, FI_MSG_FIELD,
                                        0, 0, buf, 0);
                    }
                }

                if (!(cd->creflags & PI_HAVE_WINDOW))
                {
                    /* prompt user to identify window */

                    ex$message (msgnumb = PI_P_IdWinPlt, buff = buf);
                    FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
                }
            }
            break;

        case CREATE_PLOT_FILE_NAME:
            FIfld_get_text (form, gadget_label, 0, 0, 128,
                            (unsigned char *) pd->file, &sel, &i);
            sts = COcknamln (pd->file);
            if (sts == PI_W_NULLNAME)
            {
                pd->file[0] = NULL;
            }
            else
            {
                if (sts == PI_I_NAMETRUNC)
                {
                    FIfld_set_text (form, gadget_label, 0, 0, pd->file, 0);
                }
    
                /* prevent overwriting the current object space */

                msg = 0;
                ex$filename(name = buf, len = 128);
                c = (c = strrchr(buf,'/')) ? c + 1 : buf;
                c1 = (c1 = strrchr(pd->file,'/')) ? c1 + 1 : pd->file;
                if (!strcmp(c,c1))
                {
                    msg = PI_E_CantOvwtCurFl;
                    pd->file[0] = NULL;
                    FIfld_set_text(form,gadget_label,0,0,"",0);
                }
#ifndef NT
                else if ((stat (pd->file, &filestat)) == 0)
#else
                else if ((_stat (pd->file, &filestat)) == 0)
#endif
                {
                    /* warn about overwriting existing files */
                    msg = PI_I_ExstFOvrwrt;
                }
                if (msg)
                {
                    ex$message (msgnumb = msg, field = ERROR_FIELD);
                    ex$message (msgnumb = msg, buff = buf);
                    FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
                }
            }
            break;

        case CREATE_PLOT_COLOR_TABLE:
            FIfld_get_text (form, gadget_label, 0, 0, 128,
                            (unsigned char *) buf, &sel, &i);
#ifdef INTERSCRIPT
            if (pd->filetype == PI_IGDS_FILE)
            {
#endif
                strcpy (cd->ctable, buf);
                sts = COcknamln (cd->ctable);
                if (sts == PI_I_NAMETRUNC)
                {
                    FIfld_set_text (form, gadget_label, 0, 0, cd->ctable, 0);
                }
#ifdef INTERSCRIPT
            }
            else
            {
                cd->flood_index = atoi (buf);
                if (cd->flood_index < 0 || cd->flood_index > 255)
                {
                    buf[0] = NULL;
                    FIfld_set_text (form, gadget_label, 0, 0, buf, 0);
                }
            }
#endif
            break;

#ifdef INTERSCRIPT

        case CREATE_PLOT_FILE_TYPE:
            if (value)
            {
                pd->filetype = PI_IGM_FILE;
                if (cd->flood_index >= 0)
                {
                    sprintf (buf, "%d", cd->flood_index);
                }
                else
                {
                    buf[0] = NULL;
                }
                FIfld_set_text (form, CREATE_PLOT_COLOR_TABLE, 0, 0, buf, 0);
		ex$message ( msgnumb = PI_I_FloodIndex, buff = buf );
                /* sprintf (buf, "Flood Index"); get a message key! */
            }
            else
            {
                pd->filetype = PI_IGDS_FILE;
                FIfld_set_text (form, CREATE_PLOT_COLOR_TABLE, 0, 0, cd->ctable, 0);
		ex$message ( msgnumb = PI_I_ColorTable, buff = buf );
                /* sprintf (buf, "Color Table"); get a message key! */
            }
            FIg_erase (pd->create_form, CREATE_PLOT_CT_TEXT);
            FIg_set_text (pd->create_form, CREATE_PLOT_CT_TEXT, buf);
            FIg_display (pd->create_form, CREATE_PLOT_CT_TEXT);
            break;

#endif

        case CREATE_PLOT_QUEUE_STATUS:
            FIg_reset (form, gadget_label);
            COchcmd (PI_CREATE_FORM, PI_QUEUE_FORM, pd, cd);
            break;

        case CREATE_PLOT_SUBMIT_PLOT:
            FIg_reset (form, gadget_label);
            COchcmd (PI_CREATE_FORM, PI_SUBMIT_FORM, pd, cd);
            break;

        default:
            break;
    }
    return (FI_SUCCESS);
}
