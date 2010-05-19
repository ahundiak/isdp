/* $Id: VDS_locproc.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/func / VDS_locproc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDS_locproc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
Name
        VDSlocate_processing

Description
	See routine LClocate_processing.

Notes
	Thos routine has be taken from the LClocate, to override the
	filter for I/VDS, used in the class VDS_LOCATE.

	The function LCnmlocate is replaced by the function VDSnmlocate.

History
	adz	12/10/92	Creatio Date
*/

class implementation Root;

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "msdef.h"
#include "OMindex.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "lcpriv.h"
#include "exmacros.h"
#include "OMerrordef.h"
#include "lcmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "execmsg.h"
#include "lcmsg.h"

extern IGRint LCptlocact();
extern IGRint LCaccact();
extern IGRint LCevaction();
extern IGRint LCblptlocate();
extern IGRint LCcselect();

from GRgraphics import GRlocate;

IGRint VDSlocate_processing(
                rc, event1, event2, event3, eventmask1,
                eventmask2, eventsize, display_flag, response,
                response_data, locate_prompt, acc_prompt,
                relocate_prompt, attributes, stack, dyn, type,
                act_handler, act_args, rtree_classes, eligible_classes,
                select, select_args, max_entries, regex, locate_key,
                acc_key, relocate_key, hilight_mode, unhilight_mode,
                nbytes1, nbytes2, range_finder, range_args, value_type1,
                value_type2, scale_flag)

IGRlong *rc;                        /* return code */ 
struct GRevent *event1;             /* return from GRgetevent */
struct GRevent *event2;             /* return from GRgetevent */
struct GRevent *event3;             /* return from GRgetevent */
IGRlong eventmask1;                 /* mask to GRgetevent */
IGRlong eventmask2;                 /* mask to GRgetevent */
IGRint *eventsize;                  /* size of struct GRevent */
IGRlong display_flag;               /* see lcdef.h */
IGRint *response;                   /* response from GRgetevent */
IGRchar *response_data;             /* response data from GRgetevent */
IGRchar *locate_prompt;             /* locate prompt */
IGRchar *acc_prompt;                /* accept/reject prompt */
IGRchar *relocate_prompt;           /* when an object is not located */
struct GRlc_locate *attributes;     /* contains class & level info */
struct GRlc_stack *stack;           /* pointer to "stack" */
struct GRlc_dynamics *dyn;          /* dynamics info */
IGRint type;                        /* point, boreline, or dpb default */
IGRint (*act_handler)();            /* alternate locate eligibility function */
IGRchar *act_args;                  /* arglist for act_handler */
OM_p_CLASSLIST rtree_classes;       /* not fully implemented */
OM_p_CLASSLIST eligible_classes;    /* classes eligible for locate */
IGRint (*select)();                 /* alternate accept/reject function */
IGRchar *select_args;               /* arglist for select */
IGRint max_entries;                 /* locate stack size */
IGRint regex;                       /* named locate regular expression flag */
IGRlong locate_key, acc_key;        /* prompt keys */
IGRlong relocate_key;               /* status key used if noe objs found */
IGRint hilight_mode;                /* display mode used in select function */
IGRint unhilight_mode;              /* accepted object is left in this mode */
IGRint *nbytes1, *nbytes2;          /* co$getevent args */
IGRint (*range_finder)();           /* alternate locate-by range function */
IGRchar *range_args;                /* arglist for range_finder */
IGRchar *value_type1, *value_type2; /* co$getevent args */
IGRint scale_flag;                  /* co$getevent arg */
{
    IGRchar info[75];
    IGRboolean is_bore;
    IGRshort cursor_on;
    IGRint size;
    IGRint obj_located = 0;
    IGRchar obj_hilighted;
    IGRint need_display, element;
    IGRint onewindow, ext_o_element;
    IGRint (*function)();
    IGRint ret_code = 0, ii;
    IGRint level[DP_NUM_OF_LEVELS];
    IGRint myresponse;
    IGRlong mask1 = eventmask1;
    IGRlong mask2 = eventmask2;
    IGRlong no_bytes;
    IGRlong msg;
    IGRdouble tolerance;
    enum GRdpmode dpmode;
    struct EX_cmd cmd_str;
    struct GRmd_env mod;
    struct GRlc_info *obj;
    struct GRlc_classes classinfo;
    struct LC_action_args action_info;
    struct LC_select_args select_info;
    struct GRlc_cvl cvl;

    cursor_on =0;
    obj = NULL;

    GRLocInfo(GRLocateFilterOutput, LC_I_LocFilter,
              OM_Gw_current_OS, NULL_OBJID);

    classinfo.rtree_classes = rtree_classes;
    classinfo.eligible_classes = eligible_classes;
    onewindow = (display_flag & ONE_WINDOW) ? TRUE : FALSE;
    element = (display_flag & ELEM_HILIGHT) ? TRUE : FALSE;
    ext_o_element = 0; /* both object and extensions */

    if (!event3)
    {
        event3 = event2;
    }
    if (!mask1)
    {
        mask1 = GRm_DATA | GRm_TEXT_VALUE | GRm_RESET;
    }
    if (!mask2)
    {
        mask2 = GRm_DATA;
    }
    if (!eventsize)
    {
        size = sizeof (struct GRevent) -  (2 * (sizeof (int)));
    }
    else
    {
        size = *eventsize;
    }
    if (type == LC_DPB_LOCATE)
    {
        no_bytes = sizeof (IGRboolean);
        gr$get_bore_locate (msg = &msg,
                            sizbuf = &no_bytes,
                            buffer = &is_bore,
                            nret = &no_bytes);
    }
    if (type == LC_PT_LOCATE)
    {
        is_bore = 0;
    }
    else if (type == LC_BL_LOCATE)
    {
        is_bore = 1;
    }

    if (!act_handler)
    {
        if (display_flag & LC_ACC_ONE_ELEMENT)
        {
            IGRboolean auto_acc_flag;

            gr$get_auto_accept_flag(buffer = &auto_acc_flag);
            act_handler = (auto_acc_flag) ? LCaccact : LCptlocact;
        }
        else
        {
            act_handler = LCptlocact;
        }
    }
    action_info.rc = rc;
    action_info.stack = stack;
    action_info.max_entries = max_entries;
    action_info.select = select;
    action_info.select_args = select_args;
    action_info.loc_select_args = &select_info;
    stack->number_located = stack->num_entries;

    if (!select)
    {
        select = LCcselect;
        action_info.select = LCcselect;
        action_info.select_args = (IGRchar *) &select_info;
    }
    select_info.response_data = response_data;
    select_info.obj_hilighted = (IGRchar *)&obj_hilighted;
    select_info.acc_prompt = acc_prompt;
    select_info.relocate_prompt = relocate_prompt;
    select_info.is_bore = &is_bore;
    select_info.eventsize = &size;
    select_info.response = response;
    select_info.eventmask = mask2;
    select_info.display_flag = display_flag;
    select_info.stack = stack;
    select_info.dyn = dyn;
    select_info.accept_event = event2;
    select_info.acc_event1 = event3;
    select_info.relocate_key = relocate_key;
    select_info.acc_key = acc_key;
    select_info.nbytes = nbytes2;
    select_info.value_type = value_type2;
    select_info.scale_flag = scale_flag;
    if (unhilight_mode == -1)
    {
        select_info.mode = GRhd;
    }
    else
    {
        select_info.mode = (enum GRdpmode)unhilight_mode;
    }
    if (hilight_mode == -1)
    {
        select_info.hilight_mode = GRhd;
    }
    else
    {
        select_info.hilight_mode = (enum GRdpmode)hilight_mode;
    }

    if (stack->num_entries)
    {
        if (dyn)
        {
            dyn->GRlc_event = *event1;    
        }

        if ((*select) (rc, &select_info, select_args))
        {
            if (*rc == LC_UNKNOWN_TYPE)
            {
                *rc = LC_NO_OBJ_LOCATED;
                ret_code = obj_located = 1;
            }
            else if (*rc == LC_BACKUP)
            {
                /* fall through to the "while (!obj_located)" loop */

                ret_code = 0;
                ex$message (msgnumb = relocate_key, 
                            in_buff = relocate_prompt,
                            field = ERROR_FIELD);
            }
            else if (*rc != LC_RELOCATE)
            {
                /* LC_NO_OBJ_LOCATED, LC_OBJ_LOCATED, or LC_OBJS_IN_STACK */

                ret_code = obj_located = 1;
            }
            else
            {
                if (display_flag & DO_NOT_RELOCATE)
                {
                    ret_code = obj_located = 1;
                    *rc = LC_NO_OBJ_LOCATED;
                }
                else if (!(display_flag & DO_NOT_RELOCATE))
                {
                    ret_code = 0;
                    ex$message (msgnumb = relocate_key, 
                            in_buff = relocate_prompt, field = ERROR_FIELD);
                }
            }
        }
        else
        {
            goto ERROR_WRAP;
        }
    }

    while (!obj_located)
    {
        *rc = LC_NO_OBJ_LOCATED;
        no_bytes = sizeof (IGRdouble);
 
        gr$get_dit_tolerance (msg = &msg, sizbuf = &no_bytes,
                              buffer = &tolerance, nret= &no_bytes);

        /* turn on the locate cursor if the queue is empty */

        if (!ex$peek_event_queue (resp = &myresponse))
        {
            LCdef_cursor();
            cursor_on = 1;
        }

        LCmark_locate (LC_Locate_Point);

        if (co$getevent (msg = &msg,
                         event_mask = mask1,
                         msgnum = locate_key,
                         prompt = locate_prompt,
                         response = response,
                         response_data = response_data,
                         event = event1,
                         nbytes = nbytes1,
                         value_type = value_type1,
                         scale_flag = scale_flag) == MSFAIL) 
        {
            *rc = msg;
            goto ERROR_WRAP;
        }

        if (cursor_on)
        {
            LCrestore_cursor();    
            cursor_on = 0;
        }

        no_bytes = sizeof (struct GRmd_env);
        gr$get_module_env (msg = &msg, sizbuf = &no_bytes,
                           buffer = &mod, nret= &no_bytes);

        stack->module = mod.md_id;
        stack->window.objid = event1->event.button.objid;
        stack->window.osnum = mod.md_id.osnum;

        /*
         *  check the user's input
         */
    
        if (event1->response == EX_DATA)
        {
            /*
             *  is the data button from an event generator that located
             *  an object?
             */

            ret_code = 1;
            if (!LCevent (rc, event1, attributes, act_handler, &action_info, 
                          &mod, eligible_classes, stack, &size, display_flag))
            {
                ex$message (msgnumb = EX_S_Clear);
                ex$message (msgnumb = EX_P_Clear);

                action_info.type = (is_bore) ? GR_bl_loc : GR_pt_loc;

                function = (range_finder) ? range_finder: LCblptlocate;

                /* locate by range */

                *rc = LC_RELOCATE;
                ret_code = (*function) (&msg, event1, attributes, stack, &mod,
                                        &tolerance, act_handler, act_args,
                                        &classinfo, &action_info, range_args);
            }
            lc$check_id (rc = &msg, mode = LC_DELETE);
            lc$post_id (rc = &msg, mode = LC_DELETE);
        }
        else if (event1->response == EX_STRING)
        {
            if (event1->subtype == GRst_DEFAULT)
            {
                if ((mask1 & GRm_VALUE) || (display_flag & DO_NOT_RELOCATE))
                {
                    /* user may be looking for a NULL string; return as */
                    /* no object located */

                    *event3 = *event2 = *event1;
                    ret_code = 1;
                    *rc = LC_NO_OBJ_LOCATED;
                    GRLocInfo(GRLocateFilterOutput, LC_I_NoObjLoc,
                              OM_Gw_current_OS, NULL_OBJID);
                    break;
                }
                else
                {
                    /* ignore carriage return; reprompt to locate */

                    ex$message (msgnumb = relocate_key,
                                in_buff = relocate_prompt, 
                                field = ERROR_FIELD);
                    continue;
                }
            }

            /* invoke a named locate */

            select_info.display_flag |= ALL_WINDOWS | ELEM_HILIGHT |
                                        NO_PROJ_ACCEPT_POINT;
            display_flag |= ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;

            action_info.type = GR_nam_loc;

            ret_code = VDSnmlocate(rc, event1->event.keyin, &mod, attributes, 
                                   act_handler, &action_info, stack,
                                   regex, act_args, eligible_classes);

            if (*rc == LC_OBJ_LOCATED)
            {
                /* locate by name successful, graphic set created; display */
                /* flag must be modified to prevent projecting a point onto */
                /* a set; if object is accepted the gr$gslocate filter will */
                /* attach it to the proper channel */

                display_flag |= NO_PROJ_ACCEPT_POINT;
            }

            if ((*rc == LC_OBJ_LOCATED || *rc == LC_OBJS_IN_STACK) &&
                (display_flag & LC_INPUT_LOC_POINT))
            {
                /* User has asked that each object be associated with a */
                /* locate point, so prompt for one.  Go ahead and highlight */
                /* the element, although for LC_OBJS_IN_STACK this will */
                /* result in a double highlight from the select handler */

                strcpy (info, "Input data point");
                ex$message (in_buff = info, field = PROMPT_FIELD);

                if (vsd_and_queue_empty)
                {
                    LCdef_cursor();
                    cursor_on = 1;
                }

                obj = &stack->entry[0];

                if ((hilight_mode == -1))
                {
                    dpmode = (display_flag & LC_HALF_HIGHLIGHT) ? GRhhd : GRhd;
                }
                else
                {
                    dpmode = (enum GRdpmode)hilight_mode;
                }

                lc$display (msg = &msg,
                            matrix_type = &obj->module_info.md_env.matrix_type,
                            matrix = obj->module_info.md_env.matrix,
                            highlight_mode = &dpmode,
                            window_id = &stack->window,
                            objid = obj->located_obj.objid,
                            osnum = obj->located_obj.osnum,
                            mod_id = &obj->module_info.md_id,
                            element = element,
                            window = onewindow,
                            parms = &obj->geom_parms,
                            ext_o_element = &ext_o_element);

                co$getevent (msg = &msg,
                             event_mask = GRm_DATA | GRm_RESET,
                             prompt = info,
                             response = response,
                             response_data = response_data,
                             nbytes = nbytes1,
                             value_type = value_type1,
                             scale_flag = scale_flag,
                             event = event1);

                if (cursor_on)
                {
                    LCrestore_cursor();    
                    cursor_on = 0;
                }

                if (event1->response == RESET)
                {
                    *rc = LC_RELOCATE;
                    ret_code = 1;
                }
                else if (event1->response == GR_UNKNOWN_TYPE)
                {
                    *event3 = *event1;
                    ret_code = obj_located = 1;
                    *rc = LC_NO_OBJ_LOCATED;
                    GRLocInfo(GRLocateFilterOutput, LC_I_NoObjLocUnIn,
                              OM_Gw_current_OS, NULL_OBJID);
                    break;  /* should leave while loop */
                }
            }
            else if (*rc == LC_NO_OBJ_LOCATED)
            {

                /* Check whether the string is a command.  If so, change */
                /* the response type in both response and event.response */
                /* to appropriate values and return with no object */
                /* located.  Clear the vsd, since commands should pull */
                /* their input from the software queue rather than the */
                /* vsd, and part of the string being returned may already */
                /* be in the vsd. */

                clear_vsd;

                if (ex$get_cmd_info (string = event1->event.keyin,
                                     mode = EX_STRING,
                                     cmdstr = &cmd_str))
                {
                    /* Since there is no mask in getevent for a command, */
                    /* must return as an unknown type. */

                    *response = CMD_STRING;
                    event1->response = GR_UNKNOWN_TYPE;
                    *event3 = *event1;
                    ret_code = obj_located = 1;
                    *rc = LC_NO_OBJ_LOCATED;
                    GRLocInfo(GRLocateFilterOutput, LC_I_NoObjLocCmd,
                              OM_Gw_current_OS, NULL_OBJID);
                    break;  /* should leave while loop */
                }
                else
                {
                    *rc = LC_RELOCATE;
                }
            }
        } 
        else if (event1->response == EX_OBJID)
        {
            /* object on queue - usually from group generators */

            *event3 = *event1;
            ret_code = obj_located = 1;
            *rc = LC_OBJ_LOCATED;
            lc$check_id (rc = &msg, mode = LC_DELETE);
            lc$post_id (rc = &msg, mode = LC_DELETE);

            /* project the point onto the object */

            LCobj_project (event3, display_flag, is_bore, TRUE, &mod);

            /*
             *  leave the locate filter with the object (group) in
             *  the display mode requested (assume that the object (group)
             *  is currently drawn in background only)
             */

            need_display = TRUE;

            if ((hilight_mode == -1) && (unhilight_mode == -1))
            {
                dpmode = (display_flag & LC_HALF_HIGHLIGHT) ? GRhhd : GRhd;
            }
            else if ((unhilight_mode == -1) && (hilight_mode != GRbd))
            {
                dpmode = (enum GRdpmode)hilight_mode;
            }
            else if ((unhilight_mode != GRbd) &&
                     (unhilight_mode != GRhe) &&
                     (unhilight_mode != GRbdhe))
            {                
                dpmode = (enum GRdpmode)unhilight_mode;
            }
            else
            {
                need_display = FALSE;
            }

            if (need_display)
            {
                obj = event3->located_object;

                lc$display (msg = &msg,
                            matrix_type = &obj->module_info.md_env.matrix_type,
                            matrix = obj->module_info.md_env.matrix,
                            highlight_mode = &dpmode,
                            window_id = &stack->window,
                            objid = obj->located_obj.objid,
                            osnum = obj->located_obj.osnum,
                            mod_id = &obj->module_info.md_id,
                            element = element,
                            window = onewindow,
                            parms = &obj->geom_parms,
                            ext_o_element = &ext_o_element);
            }

            GRLocInfo(GRLocateFilterOutput, LC_I_ObjRet,
                      event3->located_object[0].located_obj.osnum, 
                      event3->located_object[0].located_obj.objid);

            break; /* exit while loop and return */
        }
        else if (event1->response == GR_UNKNOWN_TYPE && *response == EX_OBJID)
        {
            size = sizeof (struct GRevent) - (2 * sizeof (IGRint));
            memcpy (&event3->event, response_data, size);
            memcpy (&event2->event, response_data, size);
            memcpy (&event1->event, response_data, size);
            event1->nbytes = event2->nbytes = event3->nbytes = size;
        
            cvl.attributes.obj_attr = *attributes;
            cvl.action_handler = LCevaction;
            cvl.module = mod;

            cvl.classes = eligible_classes;
            cvl.act_parms = NULL;
            cvl.attributes.type = GR_nam_loc;
            for (ii = 0; ii < DP_NUM_OF_LEVELS; ii++)
            {
                level[ii] = 0xffffffff;
            }
            cvl.levels = level;
            cvl.locate_args = &action_info;

            om$send (msg = message GRgraphics.GRlocate (&cvl, NULL), 
                     senderid = NULL_OBJID, 
                     targetid = event1->located_object[0].located_obj.objid,
                     targetos = event1->located_object[0].located_obj.osnum);

            if (stack->num_entries)
            {
                LCobj_project (event1, display_flag, is_bore, FALSE, &mod);

                /*
                 *  Now that the object is eligible to be located and
                 *  is not a group object, see if the object passes
                 *  the class list of the command.
                 */

                ret_code = obj_located = 1;
                *rc = LC_OBJ_LOCATED;
                stack->num_entries = 0;
                LCget_info (event1->located_object[0].located_obj.objid, 
                            event1->located_object[0].located_obj.osnum, 
                            info);
        
                ex$message (msgnumb = LC_NO_MSG,
                            in_buff = info,
                            field = ERROR_FIELD);

                event1->response = event2->response = event3->response 
                                                           = *response = DATA;
                lc$check_id (rc = &msg, mode = LC_DELETE);
                lc$post_id (rc = &msg, mode = LC_DELETE);
            }
            else
            {
                ret_code = 1;
                *rc = LC_RELOCATE;
            }
        } 
        else
        {
            /*
             *  unknown or unhandled input received, so return element
             *  not located
             */

            *event3 = *event1;
            ret_code = obj_located = 1;
            *rc = LC_NO_OBJ_LOCATED;

            if (event1->response != GR_UNKNOWN_TYPE)
            {
                /*
                 *  user has asked for something not handled here (backup, 
                 *  moveon, ...), so delete the locate criteria and let
                 *  the caller handle the input; the delete is necessary to
                 *  prevent the criteria stack from hanging on to obselete
                 *  data in cases like "Identify element or moveon"
                 */

                LCdel_criteria();
            }

            GRLocInfo(GRLocateFilterOutput, LC_I_NoObjLoc,
                      OM_Gw_current_OS, NULL_OBJID);

            break;
        }

        /*
         *  If  any elements were placed in the stack 
         *            and 
         *      accept and reject requested
         *  then
         *      go into the accept/reject cycle
         */

        if (ret_code)
        {
           /*
            *   if none of the if statements are taken the return code is
            *   LC_RELOCATE -- so the while loop takes effect and another
            *   locate is performed.
            */

            if (*rc == LC_UNKNOWN_TYPE)
            {
                *rc = LC_NO_OBJ_LOCATED;
                ret_code = 1;
                GRLocInfo(GRLocateFilterOutput, LC_I_NoObjLocUnIn,
                          OM_Gw_current_OS, NULL_OBJID);
                break;
            }
            else if (*rc == LC_OBJ_LOCATED)
            {
                ret_code = 1;
                GRLocInfo(GRLocateFilterOutput, LC_I_ObjRet,
                          event3->located_object[0].located_obj.osnum,
                          event3->located_object[0].located_obj.objid);
                break;
            }
            else if (*rc == LC_NO_OBJ_LOCATED)
            {
                ret_code = 1;
                GRLocInfo(GRLocateFilterOutput, LC_I_NoObjLoc,
                          OM_Gw_current_OS, NULL_OBJID);
                break;
            }
            else if (*rc == LC_OBJS_IN_STACK)
            {
                /* check whether to auto-accept a single object or call the */
                /* select handler to allow the user to accept the object */

                if ((display_flag & LC_ACC_ONE_ELEMENT) &&
                    (stack->number_located == 1))
                {
                    ii = stack->num_entries - 1;
                    event1->located_object[0] = stack->entry[ii];
                    event1->num_id = 1;
                    LCobj_project (event1, display_flag, is_bore, TRUE, &mod);
                    *event3 = *event2 = *event1;
                    stack->number_located = stack->num_entries = 0;
                    ret_code = obj_located = 1;
                    *rc = LC_ONE_ELEM_ACCEPT;
                    GRLocInfo(GRLocateFilterOutput, LC_I_OneEleAcc,
                              event3->located_object[0].located_obj.osnum,
                              event3->located_object[0].located_obj.objid);
                    break;
                }          
                else if ((display_flag & LC_ACC_TWO_ELEMENT) &&
                         (stack->number_located == 2))
                {
                    ii = stack->num_entries - 1;
                    event1->located_object[0] = stack->entry[ii];
                    event1->located_object[1] = stack->entry[ii - 1];
                    event1->num_id = 2;
                    LCobj_project (event1, display_flag, is_bore, TRUE, &mod);
                    *event3 = *event2 = *event1;
                    stack->number_located = stack->num_entries = 0;
                    ret_code = obj_located = 1;
                    *rc = LC_TWO_ELEM_ACCEPT;
                    GRLocInfo(GRLocateFilterOutput, LC_I_OneEleAcc,
                              event3->located_object[0].located_obj.osnum,
                              event3->located_object[0].located_obj.objid);
                    GRLocInfo(GRLocateFilterOutput, LC_I_TwoEleAcc,
                              event3->located_object[1].located_obj.osnum,
                              event3->located_object[1].located_obj.objid);
                    break;
		}
                else if ((*select) (rc, &select_info, select_args))
                {
                    if (*rc == LC_UNKNOWN_TYPE)
                    {
                        *rc = LC_NO_OBJ_LOCATED;
                        ret_code = 1;
                        GRLocInfo(GRLocateFilterOutput, LC_I_NoObjLocUnIn,
                                  OM_Gw_current_OS, NULL_OBJID);
                        break;
                    }
                    if (*rc != LC_RELOCATE)
                    {
                        ret_code = 1;
                        GRLocInfo(GRLocateFilterOutput, LC_I_ObjRet,
                                  event3->located_object[0].located_obj.osnum,
                                  event3->located_object[0].located_obj.objid);
                        break;
                    }
                }
            }
        }   /* if (stack->num_entries */
        else
        {
            goto ERROR_WRAP;
        }

        if (display_flag & DO_NOT_RELOCATE)
        {
            obj_located = 1;
            *rc = LC_NO_OBJ_LOCATED;
            LCdel_criteria();
        }
        else if (!(display_flag & DO_NOT_RELOCATE))
        {
            ex$message (msgnumb = relocate_key,
                        in_buff = relocate_prompt, 
                        field = ERROR_FIELD);
            stack->number_located = stack->num_entries = 0;
        }
    }  /* end while loop until object is found */

    if (ret_code && (*rc == LC_OBJ_LOCATED || *rc == LC_ONE_ELEM_ACCEPT))
    {
        LCdel_criteria();
    }

    stack->number_located = 0;
    return (ret_code);

ERROR_WRAP:

    *rc = LC_NO_OBJ_LOCATED;
    stack->number_located = stack->num_entries = 0;
    LCdel_criteria();
    GRLocInfo(GRLocateFilterOutput, LC_E_LocateError,
              OM_Gw_current_OS, NULL_OBJID);
    return (0);
}

end implementation Root;
