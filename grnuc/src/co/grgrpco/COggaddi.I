/*
Name
   COggadd -- add elements to a graphics group

Description
   This command will add elements to an existing graphic group.

   execute method
      Consists of two external states:
         LOC_GRA_GRP
            Locate a graphic group.
            Allow user to accept/reject the graphic group.
            Put accept point on event queue.
         LOC_OBJS:
            Locate a graphics object.
            Allow user to accept/reject the graphics object.
            Add the graphics object to the graphic group.
            Put accept point on event queue.

   init method
      1.  Initialize instance variables
      2.  Set state to LOC_GRA_GRP

   delete method
      1.  Delete the graphcs sets.
      2.  Delete the command object.

History
   HGW     05/01/86   Creation.
   HGW     06/22/86   Change to new locate and exec
   HGW     08/01/86   Changed name from complex to graphic group
   mrm     10/01/86   OM 4.0 conversion
   mrm/hgw 12/31/86   Convert to use graphics sets
   hgw     03/02/87   Send the post processing message.
   hgw     03/23/87   changed erase element to erase highlight plane
   hgw     03/23/87   changed locate attributes
   hgw     09/21/87   Convert for new graphics object version 1.1
   hgw     08/14/88   Allow location of drawing view and drawing sheet
*/

class implementation COggadd;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsmacros.h"
#include "griomacros.h"
#include "codef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMmacros.h"

from GRowner   import   GRadd_components;

/* 
 *  External command states
 */

#define LOC_GRA_GRP     0
#define LOC_OBJS        1

/*
 *  Internal command states
 */

#define COMPLEX_OPERATION  2       /* Unhighlight graphic group and      */
                                   /* locate the graphics object         */
#define GO_OPERATION       3       /* Add the graphics object to         */
                                   /* the graphic group                  */
#define RESTART            4       /* Restart the command                */

/*
 *  Control looping condidtions
 */

#define FUNC_ERROR  0      /* Continue command after cleanup        */
#define SUCCESS     1      /* Continue looping                      */
#define RETCONTROL  2      /* Exit command and return(OM_S_SUCCESS) */

/****************************************************************/
/*                       E X E C U T E                          */
/****************************************************************/

method execute ( IGRint *response; IGRchar *response_data; IGRint pos )
{
IGRlong         om_msg;       /* OM return status              */
IGRlong         ret_msg;      /* Function return code          */
IGRlong         exit_code;    /* Loop control variable         */
IGRlong         size;
IGRint          count;
struct GRevent  locate_event; /* contains the located object   */
OM_S_CHANSELECT to_gragrp;    /* channel from co to graphic group */
OM_S_CHANSELECT to_graset;    /* channel from co to graphic set   */

   ex$message(msgnumb = GRC_M_AddEleGrGrp);

   if (me->init_success)
   {
      exit_code = SUCCESS;
      me->eligible_classes.p_classes = me->classes;
      om$make_chanselect (channame = "COggadd.to_gg_gs",
                          p_chanselect = &to_gragrp);
      om$make_chanselect (channame = "COggadd.to_gs_gs",
                          p_chanselect = &to_graset);
   }else
   {
      ex$message(msgnumb = GR_E_ErrEncCmdTrm);
      *response = TERMINATE;
      exit_code = RETCONTROL;
   }

   while ( exit_code == SUCCESS )
   {
      switch ( me->state )
      {
         /*************************************************************/
         case LOC_GRA_GRP:
         {
            /*
             *  Call the locate filter to locate an object.
             */

            om_msg = gr$gslocate (msg = &ret_msg,
                       event1 = &me->locate_point,
                       event2 = &me->locate_point, 
                       locate_event = &locate_event,
                       mask1 = GRm_DATA | GRm_RESTART,
                       mask2 = GRm_DATA | GRm_OBJID | GRm_RESTART,
                       display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                                      NO_PROJ_ACCEPT_POINT,
                       locate_key = GR_P_IdGrGrp,
                       acc_key = GR_P_AccEle,
                       relocate_key = GR_E_NoEleFnd,
                       attributes = &me->gg_attr,
                       stack = &me->locate_stack,
                       eligible_classes = &me->eligible_classes,
                       p_chanselect = &to_gragrp);

            if (COERROR (om_msg))
            {
               exit_code = FUNC_ERROR;
            }else if ( (ret_msg & 1) &&
                       ( (me->locate_point.response == EX_DATA) ||
                         (me->locate_point.response == EX_OBJID)))
            {
               /* 
                *  Unhighlight the graphic group and add the 
                *  the accept point to the event queue.
                */

               me->state = COMPLEX_OPERATION;
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
         }
         break;

         /***************************************************************/
         case LOC_OBJS: 
         {
            /*
             *  Call the locate filter to locate an object.
             */

            om_msg = gr$gslocate (msg = &ret_msg,
                       event1 = &me->locate_point,
                       event2 = &me->locate_point, 
                       locate_event = &locate_event,
                       mask1 = GRm_DATA | GRm_OBJID | GRm_RESTART,
                       mask2 = GRm_DATA | GRm_OBJID | GRm_RESTART,
                       display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                                      NO_PROJ_ACCEPT_POINT,
                       locate_key = GR_P_IdEleAddGrp,
                       acc_key = GR_P_AccNxtEle,
                       relocate_key = GR_E_NoEleFnd,
                       attributes = &me->ele_attr,
                       stack = &me->locate_stack,
                       locate_state = &me->locate_state,
                       num_inputs = 1,
                       input1_mask = GRm_DATA | GRm_OBJID | GRm_RESTART,
                       input1_key = GR_P_AccIdNxtEle,
                       p_chanselect = &to_graset);

            me->event_on_q = FALSE;

            if (COERROR (om_msg))
            {
               exit_code = FUNC_ERROR;
            }else if ( (ret_msg & 1) &&
                       ( (me->locate_point.response == EX_DATA) ||
                         (me->locate_point.response == EX_OBJID)))
            {
               /* 
                *  Unhighlight the graphics object and add it to 
                *  graphic group.  The accept point is used to identify
                *  the next graphics object.
                */

               me->state = GO_OPERATION;
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
         }
         break;

         /**************************************************************/
         case COMPLEX_OPERATION:
         {
            /*
             *  Erase the highlight plane
             */

            om_msg = dp$erase_hilite (msg = &ret_msg,
                     objid = me->ModuleInfo.md_id.objid,
                     osnum = me->ModuleInfo.md_id.osnum);

            if (COERROR (om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }
 
            /*
             *  Use the input to accept the graphic group as the input to
             *  locate the first element to add to the graphic group. 
             *  This is done by pushing the event onto the event queue.
             */
            
            size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
            om_msg = ex$putque ( msg = &ret_msg, response = response, 
                     byte = &size, buffer = (char *)&me->locate_point.event);

            if (!(om_msg & ret_msg & 1))
            {
               exit_code = FUNC_ERROR;
            }else
            {
               me->event_on_q = TRUE;
               me->state = LOC_OBJS;
            }
         }
         break;

         /**************************************************************/
         case GO_OPERATION:
         {
            /*
             *  Erase the highlight plane
             */

            om_msg = dp$erase_hilite (msg = &ret_msg,
                     objid = me->ModuleInfo.md_id.objid,
                     osnum = me->ModuleInfo.md_id.osnum);

            if (COERROR (om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            } 

            /*
             *  Perform any post processing that is needed on the
             *  graphics sets.  
             */

            om_msg = gr$gspost_processing ( msg = &ret_msg,
                     p_chanselect = &to_graset);

            if (COERROR (om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            } 

            /*
             *  Inquire the number of objects in the graphics set
             */

            om_msg = gr$gsinqcount ( msg = &ret_msg,
                     count = &count, p_chanselect = &to_graset);

            if (COERROR(om_msg & ret_msg ))
            {
               exit_code = FUNC_ERROR;
               break;
            }

            om_msg = om$vla_set_dimension(varray = me->object_array,
                     size = count);

            if (COERROR(om_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }
             
            om_msg = gr$gsget_objects (msg = &ret_msg,
                     array = me->object_array,
                     size = count * sizeof (struct GRobj_env),
                     count = &count, p_chanselect = &to_graset);
                              
            if (COERROR(om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }
             
            om_msg = om$send (
                     msg = message GRowner.GRadd_components (&ret_msg,
                     &me->ModuleInfo, &count, me->object_array, NULL, 
                     NULL),
                     p_chanselect = &to_gragrp);

            if (COERROR(om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }

            /* 
             *  Empty the graphic set that contains the graphic objects
             */

            om_msg = gr$gsempty(msg = &ret_msg, p_chanselect = &to_graset);

            if (COERROR(om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }

            /*
             *  Use the input to accept the graphics object as the 
             *  input to locate the first element to add to the 
             *  graphic group.  This is done by pushing the datapoint 
             *  onto the event queue.
             */
            
            size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
            om_msg = ex$putque ( msg = &ret_msg, response = response, 
                     byte = &size, buffer = (char *)&me->locate_point.event);

            if (COERROR (om_msg))
            {
               exit_code = FUNC_ERROR;
            }else
            {
               me->event_on_q = TRUE;
               me->state = LOC_OBJS;
            }
         }  /* End of internal state GO_OPERATION */
         break;

         /**************************************************************/
         case RESTART:
         {
            /* 
             *  Empty the graphic set that contains the graphic group.
             */

            om_msg = gr$gsempty(msg = &ret_msg, p_chanselect = &to_gragrp);

            if (COERROR (om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }

            /* 
             *  Empty the graphic set that contains the graphic objects
             */

            om_msg = gr$gsempty(msg = &ret_msg, p_chanselect = &to_graset);

            if (COERROR(om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }

            /* 
             *  Restart the command at the locate graphic group state.
             */

            me->state = LOC_GRA_GRP;            
         }
      }  /* end switch        */

      if (exit_code == FUNC_ERROR)
      {
         if (me->event_on_q)
         {
            /*
             *  Remove the event from the queue;
             */

            co$getevent(msg = &ret_msg, 
               event_mask = GRm_DATA | GRm_RESTART,
               response = response, response_data = response_data, 
               event = &me->locate_point);

            me->event_on_q = FALSE;
         }

         ex$message(msgnumb = GR_E_ErrEncCmdRst);
         me->state = LOC_GRA_GRP;
         exit_code = SUCCESS;
      }
   }  /* end while        */
   return ( OM_S_SUCCESS );   /* Return OM_S_SUCCESS  */
}   /* end execute method */

/****************************************************************/
/*                      I N I T                                 */
/****************************************************************/

method init ( int type; char *string_ptr )
{
IGRlong         om_msg;     /* OM return status             */
IGRlong         ret_msg;    /* Function return code         */
IGRint          size;       /* size of DPB structure        */
IGRint          ret_size;   /* return size of DPB structure */

   om_msg = OM_S_SUCCESS;
   me->mod_flag = 1; 
   me->locate_state = 0;
   me->event_on_q = FALSE;
   me->state = LOC_GRA_GRP;

   me->ele_attr.properties =     LC_LC_ONLY |
                                 LC_WRITE_ONLY |
                                 LC_DP_ONLY |
                                 IGN_MOD_BIT |
                                 IGN_PLANAR_BIT;

   me->ele_attr.owner_action =   LC_RIGID_OWNER |
                                 LC_FLEX_OWNER |
                                 LC_FLEX_COMP;

   me->gg_attr.properties =      LC_LC_ONLY |
                                 LC_WRITE_ONLY |
                                 LC_DP_ONLY |
                                 IGN_MOD_BIT |
                                 IGN_PLANAR_BIT;

   me->gg_attr.owner_action =    LC_FLEX_OWNER;

   strcpy (me->ele_attr.classes, "GRgraphics");
   strcpy (me->gg_attr.classes, "GRgraphics");

   /* 
    *  Set up parameters for the Grouping locate.
    */

   me->eligible_classes.w_count = 3;
   me->eligible_classes.w_flags = OM_CLST_subclass;
   om_msg = om$get_classid ( classname = "GRgrgrp",
                             p_classid = &me->classes[0]);
   om_msg = om$get_classid ( classname = "GRdrawview",
                             p_classid = &me->classes[1]);
   om_msg = om$get_classid ( classname = "GRdrawsheet",
                             p_classid = &me->classes[2]);

   /*
    *  Initialize the init_success to failure.
    */
   
   me->init_success = FALSE;

   size = sizeof (struct GRmd_env);
   if (gr$get_module_env (msg = &ret_msg,
                          sizbuf = &size, 
                          buffer = &me->ModuleInfo,
                          nret = &ret_size))
   {
      me->init_success = TRUE;
   }
   return ( OM_S_SUCCESS );
}

/****************************************************************/
/*                       D E L E T E                            */
/****************************************************************/

method delete (int flag)
{
IGRlong         status, msg;     /* return codes */
OM_S_CHANSELECT to_graset;

   /*
    *  Empty & delete the graphic sets
    */

   status =  om$make_chanselect (channame = "COggadd.to_gg_gs",
                                 p_chanselect = &to_graset);

   status = gr$gsempty (msg = &msg, p_chanselect = &to_graset);
   status = gr$gsdissolve (msg = &msg, p_chanselect = &to_graset);

   status =  om$make_chanselect (channame = "COggadd.to_gs_gs",
                                 p_chanselect = &to_graset);

   status = gr$gsempty (msg = &msg, p_chanselect = &to_graset);
   status = gr$gsdissolve (msg = &msg, p_chanselect = &to_graset);

   /*
    *  delete self
    */

   status = om$send (mode = OM_e_wrt_message,
                     msg = message COroot.delete ( NULL),
                     senderid = my_id,
                     targetid = my_id);

   return ( OM_S_SUCCESS );
}

end implementation COggadd;
