/*
Name
        COggremove

Description
        This command will remove elements from a graphic group.

        init:
            initialize instance variables and create graphic sets
            for the graphic group and its components

        delete:
            delete the graphic sets and self
        
        execute:
            identify a graphic group and elements to remove from it

History
        mrm     12/31/86    creation
        hgw     01/28/86    fixed graphic set problems
        mrm     01/30/86    call GRremove_components rather than calling
                            GRcpxdisconn directly
        hgw     03/02/87    Send the post processing message.
        hgw     03/09/87    include file changes
        hgw     03/23/87    changed erase element to erase highlight plane
        hgw     03/23/87    changed locate attributes
        hgw     12/17/87    Changes for version 1.1
        hgw     07/22/88    Generalized command to work subclasses of GRowner
	jhw	01/21/89    Added check for deleted graphic group
*/

class implementation COggremove;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "growner.h"
#include "grgs.h"
#include "OMerrordef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "grgsmacros.h"
#include "dpmacros.h"
#include "exmacros.h"

from GRowner import GRremove_components, GRis_component_removeable;

/*
 *  Control looping condidtions
 */

#define FUNC_ERROR  0      /* Continue command after cleanup */
#define SUCCESS     1      /* Continue looping */
#define RETCONTROL  2      /* Exit command and return(OM_S_SUCCESS) */

extern IGRint COlcggmem();   /* locate action handler */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       E X E C U T E                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
    IGRint              count;          /* number of objects on graphic set */
    IGRint              i;              /* loop index */
    IGRint              buf_size;       /* size of buf for objs to be removed*/
    IGRlong             size;
    IGRint              flag;
    IGRint              one = 1;
    IGRchar             *buffer;        /* points to buffer */
    IGRlong             sts;            /* return status */
    IGRlong             ret_msg;        /* Function return code */
    IGRlong             msg;            /* Function return code */
    IGRlong             exit_code;      /* Loop control variable */
    struct GRobj_env    gg_obj_env;     /* graphic group id */
    struct GRobj_env    *obj_env;
    struct GRevent      locate_event;   /* contains the located object */
    enum   states       {LOC_GRA_GRP,   /* locate a graphic group */
                         LOC_OBJS,      /* locate components to remove */
                         RESTART };     /* Restart the command */
    OM_S_CHANSELECT     to_gragrp;      /* channel from co to graphic group */
    OM_S_CHANSELECT     to_graset;      /* channel from co to graphic set */

    ex$message(msgnumb = GRC_M_RmEleGrGrp);
    if (me->init_status)
    {
        exit_code = SUCCESS;
        me->eligible_classes.p_classes = me->classes;
        me->loc_gg_mem.stack = &me->locate_stack;
        om$make_chanselect (channame = "COggremove.to_gg_gs",
                            p_chanselect = &to_gragrp);
        om$make_chanselect (channame = "COggremove.to_gs_gs",
                            p_chanselect = &to_graset);
    }
    else
    {
        ex$message(msgnumb = GR_E_ErrEncCmdTrm);
        *response = TERMINATE;
        exit_code = RETCONTROL;
    }

    while (exit_code == SUCCESS)
    {
        switch (me->state)
        {
            case LOC_GRA_GRP:

                /*
                 *  Call the locate filter to locate an object.
                 *  Note: A group event generator is not valid for the
                 *  accept event because the group event generator will
                 *  use the criteria of the first event.
                 */

                sts = gr$gslocate (msg = &ret_msg,
                                   event1 = &me->locate_point,
                                   event2 = &me->locate_point, 
                                   locate_event = &locate_event,
                                   mask1 = GRm_DATA | GRm_RESTART,
                                   mask2 = GRm_DATA | GRm_RESTART,
                                   display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                                                  NO_PROJ_ACCEPT_POINT,
                                   locate_key = GR_P_IdGrGrp,
                                   acc_key = GR_P_AccEle,
                                   relocate_key = GR_E_NoEleFnd,
                                   attributes = &me->gg_attr,
                                   stack = &me->locate_stack,
                                   eligible_classes = &me->eligible_classes,
                                   p_chanselect = &to_gragrp);

                if (!(sts & 1))
                {
                    exit_code = FUNC_ERROR;
                }
                else if ((ret_msg & 1) && 
                         (me->locate_point.response == EX_DATA))
                {
                    /*
                     *  Erase the highlight plane.
                     */
        
                    sts = dp$erase_hilite (msg = &ret_msg,
                                           objid = me->ModuleInfo.md_id.objid,
                                           osnum = me->ModuleInfo.md_id.osnum);

                    if (!(sts & ret_msg & 1))
                    {
                        exit_code = FUNC_ERROR;
                        break;
                    }
 
                    /*
                     *  Use the input to accept the graphic group as
                     *  the input to locate the first element to add
                     *  to the graphic group. This is done by pushing
                     *  the datapoint onto the event queue.
                     */

                    size = sizeof (struct GRevent) - (sizeof (IGRlong) * 2);
                    sts = ex$putque (msg = &ret_msg, 
                                     response = response,
                                     byte = &size, 
                                     buffer = (char *)&me->locate_point.event);

                    if (!(sts & 1))
                    {
                        exit_code = FUNC_ERROR;
                    }
                    else
                    {
                        me->event_on_q = TRUE;
                        me->state = LOC_OBJS;
                    }
                }
                else if (me->locate_point.response == EX_RESTART)
                {
                    /*
                     *  Restart the command.
                     */

                    me->state = RESTART;
                }
                else if (me->locate_point.response == GR_UNKNOWN_TYPE)
                {
                    /*
                     *  Unknown event, return control to super_cmd
                     */

                    exit_code = RETCONTROL;
                }
                break;

            case LOC_OBJS: 

                /*
                 *  Get the object id and channel number of the
                 *  graphic group.  These will be used by the action 
                 *  handler to locate only components of this graphic group
                 */

                sts = gr$gsget_objects (msg = &ret_msg,
                                        array = &gg_obj_env, 
                                        size = sizeof(struct GRobj_env),
                                        count = &count, 
                                        p_chanselect = &to_gragrp);
                              
                /*
                 * If the graphic group has been deleted set the
                 * state to LOC_GRA_GRP. The graphic group will be deleted
                 * if it's last component is removed.
                 */
                if ( (ret_msg == MSFAIL) && (!count) && (sts & 1) )
                {
                    me->event_on_q = FALSE;
                    me->state = LOC_GRA_GRP;
                    break;
                }
                else if (!(sts & 1)) /* An error occured */
                {
                    exit_code = FUNC_ERROR;
                    break;
                }

                me->loc_gg_mem.gg_id.objid = gg_obj_env.obj_id.objid;
                me->loc_gg_mem.gg_id.osnum = gg_obj_env.obj_id.osnum;

                /*
                 *  Call the locate filter to locate an object.
                 */

                sts = gr$gslocate (msg = &ret_msg,
                                   event1 = &me->locate_point,
                                   event2 = &me->locate_point, 
                                   locate_event = &locate_event,
                                   mask1 = GRm_DATA | GRm_OBJID |
                                           GRm_BACK_UP | GRm_RESTART,
                                   mask2 = GRm_DATA | GRm_OBJID | GRm_RESTART,
                                   display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                                                  NO_PROJ_ACCEPT_POINT,
                                   locate_key = GR_P_IdEleRm,
                                   acc_key = GR_P_AccNxtEle,
                                   relocate_key = GR_E_NoEleFnd,
                                   attributes = &me->ele_attr,
                                   stack = &me->locate_stack,
                                   locate_state = &me->locate_state,
                                   num_inputs = 1,
                                   input1_mask = GRm_DATA | GRm_OBJID |
                                                 GRm_RESTART,
                                   input1_key = GR_P_AccIdNxtEle,
                                   action_handler = COlcggmem,
                                   action_args = &me->loc_gg_mem,
                                   p_chanselect = &to_graset);

                me->event_on_q = FALSE;

                if (!(sts & 1))
                {
                    exit_code = FUNC_ERROR;
                }
                else if ((ret_msg & 1) &&
                         ((me->locate_point.response == EX_DATA) ||
                          (me->locate_point.response == EX_OBJID)))
                {
                    /*
                     *  Erase the highlight plane.
                     */
        
                    sts = dp$erase_hilite (msg = &ret_msg,
                                           objid = me->ModuleInfo.md_id.objid,
                                           osnum = me->ModuleInfo.md_id.osnum);

                    if (!(sts & ret_msg & 1))
                    {
                        exit_code = FUNC_ERROR;
                        break;
                    }

                    /*
                     *  Perform any post processing that is needed on the
                     *  graphics sets.  
                     */

                    sts = gr$gspost_processing (msg = &ret_msg,
                                                p_chanselect = &to_graset);

                    if (!(sts & ret_msg & 1))
                    {
                        exit_code = FUNC_ERROR;
                        break;
                    }

                    /*
                     *  Send a message to the graphics set to get the 
                     *  number of objects it owns.
                     */

                    sts = gr$gsinqcount (msg = &ret_msg,
                                         count = &count,
                                         p_chanselect = &to_graset);

                    if (!(sts & ret_msg & 1))
                    {
                        exit_code = FUNC_ERROR;
                        break;
                    }

                    buf_size = sizeof(struct GRobj_env) * count;
                    buffer = om$malloc (size = buf_size);
                    if (!buffer)
                    {
                        exit_code = FUNC_ERROR;
                        break;
                    }

                    /*
                     *  Send a message to the graphics set to get the 
                     *  object(s) owned by the graphics set.
                     */

                    sts = gr$gsget_objects (msg = &ret_msg,
                                            array = buffer,
                                            size = buf_size,
                                            count = &count,
                                            p_chanselect = &to_graset);
                              
                    if (!(sts & ret_msg & 1))
                    {
                        om$dealloc (ptr = buffer);
                        exit_code = FUNC_ERROR;
                        break;
                    }

                    obj_env = (struct GRobj_env *)buffer;
                    for (i=0; i < count; ++i)
                    {
                        /*
                         *  send the graphic group a message to remove the 
                         *  specified object(s).  This method takes care of
                         *  removing the last object from the graphics group
                         */

                        sts = gr$gspass (msg = &msg,
                            pass_msg = message GRowner.GRis_component_removeable
                                      (&ret_msg, &obj_env[i].mod_env, 
                                       &obj_env[i].obj_id, &flag),
                            p_chanselect = &to_gragrp);

                        if (flag)
                        {
                            sts = gr$gspass (msg = &msg,
                                pass_msg = message GRowner.GRremove_components
                                          (&ret_msg, &me->ModuleInfo, &one,
                                           &obj_env[i]),
                                p_chanselect = &to_gragrp);
                        }
                    }
                    om$dealloc (ptr = buffer);

                    if (!(sts & ret_msg & msg & 1))
                    {
                        exit_code = FUNC_ERROR;
                        break;
                    }

                    /* 
                     *  Empty the graphic set that contains the graphic 
                     *  objects
                     */

                    sts = gr$gsempty (msg = &ret_msg, 
                                      p_chanselect = &to_graset);

                    if (!(sts & ret_msg & 1))
                    {
                        exit_code = FUNC_ERROR;
                        break;
                    }

                    /*
                     *  Use the input to accept the graphic object as the 
                     *  input to locate the next element to remove from the 
                     *  graphic group.  This is done by pushing the event
                     *  on the event queue.
                     */

                    size = sizeof (struct GRevent) - (sizeof (IGRlong) * 2);
                    sts = ex$putque (msg = &ret_msg, 
                                     response = response,
                                     byte = &size, 
                                     buffer = (char *)&me->locate_point.event);

                    if (!(sts & 1))
                    {
                        exit_code = FUNC_ERROR;
                    }
                    else
                    {
                        me->event_on_q = TRUE;
                        me->state = LOC_OBJS;
                    }
                }
                else if (me->locate_point.response == EX_RESTART ||
                         me->locate_point.response == EX_BACK_UP)
                {
                    /*
                     *  Restart command.
                     */

                    me->state = RESTART;
                }
                else if (me->locate_point.response == GR_UNKNOWN_TYPE)
                {
                    /*
                     *  Unknown event, return control to super_cmd
                     */

                    exit_code = RETCONTROL;
                }
                break;

            case RESTART: 

                /* 
                 *  Empty the graphic set that contains the graphic group.
                 */

                sts = gr$gsempty (msg = &ret_msg,
                                  p_chanselect = &to_gragrp);

                if (!(sts & ret_msg & 1))
                {
                    exit_code = FUNC_ERROR;
                    break;
                }

                /*
                 *  Empty the graphic set that contains the graphic objects
                 */

                sts = gr$gsempty (msg = &ret_msg,
                                  p_chanselect = &to_graset);

                if (!(sts & ret_msg & 1))
                {
                    exit_code = FUNC_ERROR;
                    break;
                }

                me->state = LOC_GRA_GRP;
                break;
        }  /* end switch */

        if (exit_code == FUNC_ERROR)
        {
            if (me->event_on_q)
            {
                /*
                 *  Remove the event from the queue;
                 */

                co$getevent (msg = &ret_msg, 
                             event_mask = GRm_DATA | GRm_RESTART,
                             response = response,
                             response_data = response_data, 
                             event = &me->locate_point);

                me->event_on_q = FALSE;
            }

            ex$message (msgnumb = GR_E_ErrEncCmdRst);
            me->state = RESTART;
            exit_code = SUCCESS;
        }
    } /* end while */
    return (OM_S_SUCCESS);
} /* end execute method */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      I N I T                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *string_ptr)
{
    IGRlong         sts;        /* OM return status             */
    IGRlong         ret_msg;    /* Function return code         */
    IGRint          size;       /* size of DPB structure        */
    IGRint          ret_size;   /* return size of DPB structure */

    sts = OM_S_SUCCESS;
    me->state = 0;
    me->locate_state = 0;
    me->event_on_q = FALSE;

    me->ele_attr.properties =    LC_LC_ONLY |
                                 LC_WRITE_ONLY |
                                 LC_DP_ONLY |
                                 IGN_MOD_BIT |
                                 IGN_PLANAR_BIT;

    me->ele_attr.owner_action =  LC_RIGID_OWNER |
                                 LC_FLEX_OWNER |
                                 LC_FLEX_COMP;

    me->gg_attr.properties =     LC_LC_ONLY |
                                 LC_WRITE_ONLY |
                                 LC_DP_ONLY |
                                 IGN_MOD_BIT |
                                 IGN_PLANAR_BIT;

    me->gg_attr.owner_action = LC_FLEX_OWNER;
    strcpy (me->ele_attr.classes, "GRgraphics");
    strcpy (me->gg_attr.classes, "GRgraphics");

    me->eligible_classes.w_count = 3;
    me->eligible_classes.w_flags = OM_CLST_subclass;
    sts = om$get_classid (classname = "GRgrgrp",
                          p_classid = &me->classes[0]);
    sts = om$get_classid (classname = "GRdrawview",
                          p_classid = &me->classes[1]);
    sts = om$get_classid (classname = "GRdrawsheet",
                          p_classid = &me->classes[2]);

    size = sizeof (struct GRmd_env);
    if (gr$get_module_env (msg = &ret_msg,
                           sizbuf = &size, 
                           buffer = &me->ModuleInfo,
                           nret = &ret_size))
    {
        me->init_status = TRUE;
    }
    else
    {
        me->init_status = FALSE;
    }  
    return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       D E L E T E                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method delete (int flag)
{
    IGRlong         status, msg;     /* return codes */
    OM_S_CHANSELECT to_graset;

    /*
     *  Empty & delete the graphic sets
     */

    status = om$make_chanselect (channame = "COggremove.to_gg_gs",
                                 p_chanselect = &to_graset);

    status = gr$gsempty (msg = &msg, p_chanselect = &to_graset);

    status = gr$gsdissolve (msg = &msg, p_chanselect = &to_graset);

    status = om$make_chanselect (channame = "COggremove.to_gs_gs",
                                 p_chanselect = &to_graset);

    status = gr$gsempty (msg = &msg, p_chanselect = &to_graset);

    status = gr$gsdissolve (msg = &msg, p_chanselect = &to_graset);

    /*
     *  delete self
     */

    status = om$send (mode = OM_e_wrt_message,
                      msg = message Root.delete (NULL),
                      senderid = my_id,
                      targetid = my_id);

    return (OM_S_SUCCESS);
}

end implementation COggremove;
