/*
Name
   COggcreate -- create a graphics group

Description
   This method implements the create graphic group command.

   execute:
      Location of an accepted graphics object.
      Construct a graphic group if neccessary and add the
      graphics object to the graphic group.

   init:
      Initialize instance variables

   delete:
      delete graphic set and self

History
   HGW      05/01/86   Creation.
   mrm/hgw  10/01/86   OM 4.0 conversion
   mrm/hgw  12/31/86   Convert to use graphics sets
   hgw      03/23/87   changed erase element to erase highlight plane
   hgw      03/23/87   changed locate attributes
   hgw      12/17/87   Changes for version 1.1
   hgw      12/17/87   Changes for version 1.2
*/

class implementation COggcreate;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "grgsmacros.h"
#include "codef.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "lcmacros.h"

from GRgraphics   import   GRconstruct;
from GRowner      import   GRdelete_owner, GRadd_components;

/* 
 *  Control looping conditions
 */

#define SUCCESS     1     /* Continue looping                     */
#define FUNC_ERROR  0     /* Continue looping after cleanup       */ 
#define RETCONTROL  2     /* Exit command and return(OM_S_SUCCESS */

/*
 *  Defines for deleting the graphic group.
 */

#define  CREATE                     1
#define  NEW_GG                     2
#define  ELEM_ON_GG                 3

/****************************************************************/
/*                       E X E C U T E                          */
/****************************************************************/

method execute ( IGRint *response; IGRchar *response_data; IGRint pos )
{
IGRlong          om_msg;       /* OM return status                    */
IGRlong          ret_msg;      /* Function return code                */
IGRlong          exit_code;    /* Loop control variable               */
IGRlong           size;
IGRint           count;
struct GRevent   locate_event; /* contains the located object         */
struct GRid      gg_id;        /* graphic group object id             */
OM_S_CHANSELECT  to_gragrp;    /* channel from co to graphic group    */
OM_S_CHANSELECT  to_graset;    /* channel from co to graphic set      */


   ex$message(msgnumb = GRC_M_CrtAddGrGrp);

   /* 
    *  Check if the init method was successful.
    */

   if (me->init_success)
   {
      om$make_chanselect (channame = "COggcreate.to_gg",
                          p_chanselect = &to_gragrp);
      om$make_chanselect (channame = "COggcreate.to_gs",
                          p_chanselect = &to_graset);
      exit_code = SUCCESS;
   }else
   {
      ex$message(msgnumb = GR_E_ErrEncCmdTrm);
      *response = TERMINATE;
      exit_code = RETCONTROL;
   }

   while ( exit_code == SUCCESS )
   {
      /*
       *  call locate filter to locate an object & add it to 
       *  the graphics set
       */

      om_msg = gr$gslocate (msg = &ret_msg,
                            event1 = &me->locate_point,
                            event2 = &me->locate_point, 
                            locate_event = &locate_event,
                            mask1 = GRm_DATA | GRm_OBJID | GRm_RESTART |
                                    GRm_RJT_MOVEON,
                            mask2 = GRm_DATA | GRm_OBJID | GRm_RESTART,
                            display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                                           NO_PROJ_ACCEPT_POINT,
                            locate_key = GR_P_IdEleAddGrp,
                            acc_key = GR_P_AccNxtEle,
                            relocate_key = GR_E_NoEleFnd,
                            attributes = &me->attr,
                            stack = &me->locate_stack,
                            locate_state = &me->locate_state,
                            num_inputs = 1,
                            input1_mask = GRm_DATA | GRm_OBJID | 
                                          GRm_RESTART,
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
          *  Element was accepted. 
          *
          *  Erase the highlight plane.
          */
        
         om_msg = dp$erase_hilite (msg = &ret_msg,
                  objid = me->ModuleInfo.md_id.objid,
                  osnum = me->ModuleInfo.md_id.osnum);

         if (om_msg & ret_msg & 1)
         {
            /*
             *  Perform any post processing that is needed on the
             *  graphics sets.  
             */

            om_msg = gr$gspost_processing ( msg = &ret_msg,
                     p_chanselect = &to_graset);

            /*
             *  Is flag set to create a graphic group
             */

            if (me->create_flag == CREATE)
            {
               /*
                *  Create the graphic group
                */
            
               me->constr.msg = &ret_msg;
               gg_id.osnum = me->ModuleInfo.md_id.osnum;
               om_msg = om$construct (osnum = me->ModuleInfo.md_id.osnum,
                        classname = "GRgrgrp", p_objid = &gg_id.objid,
                        msg = message GRgraphics.GRconstruct(&me->constr));
   
               if (om_msg & ret_msg & 1)
               {
                  me->create_flag = NEW_GG;

                  /* 
                   *  Clear the to_gg channel of all objects
                   */

                  om_msg = lc$wild_disconnect(p_chanselect = &to_gragrp);
         
                  if (om_msg & 1)
                  {
                     /*
                      *  Add the graphic group to the command object 
                      *  channel
                      */
                        
                     om_msg = lc$connect ( p_chanselect = &to_gragrp,
                              go_objid = gg_id.objid,
                              go_osnum = gg_id.osnum);

                     if (! (om_msg & 1))
                     {
                        exit_code = FUNC_ERROR;
                     }
                  }else
                  {
                     exit_code = FUNC_ERROR;
                  }
               }else
               {
                  exit_code = FUNC_ERROR;
               }
            }  /* End of if create */
            
            if (exit_code == SUCCESS)
            {
               /*
                *  Inquire the number of objects in the graphics set
                */

               om_msg = gr$gsinqcount ( msg = &ret_msg,
                        count = &count, p_chanselect = &to_graset);

               if (om_msg & ret_msg & 1)
               {
                  om_msg = om$vla_set_dimension(varray = me->object_array,
                           size = count);

                  if (om_msg & 1)
                  {
                     om_msg = gr$gsget_objects (msg = &ret_msg,
                              array = me->object_array,
                              size = count * sizeof (struct GRobj_env),
                              count = &count,
                              p_chanselect = &to_graset);
                              
                     if (om_msg & ret_msg & 1)
                     {
                        om_msg = om$send (
                                 msg = message GRowner.GRadd_components (
                                 &ret_msg, &me->ModuleInfo, &count,
                                 me->object_array, NULL, NULL),
                                 p_chanselect = &to_gragrp);

                        if (om_msg & ret_msg & 1)
                        {
                           me->create_flag = ELEM_ON_GG;

                           /*
                            *  empty the graphics set
                            */

                           om_msg = gr$gsempty (msg = &ret_msg, 
                                    p_chanselect = &to_graset);
   
                           if (om_msg & ret_msg & 1)
                           {
                              /*
                               *  Use the accept point to locate the next 
                               *  graphics object.  This is done by pushing
                               *  the datapoint onto the event queue.
                               */
            
                              size = sizeof(struct GRevent) - 
                                     (sizeof(IGRlong) * 2);
                              om_msg = ex$putque ( msg = &ret_msg, 
                                       response = response, byte = &size, 
                                       buffer = (IGRchar *)&me->locate_point.event );

                              if (! (om_msg & ret_msg & 1))
                              {
                                 exit_code = FUNC_ERROR;
                              }else
                              {
                                 me->event_on_q = TRUE;
                              }
                           }else
                           {
                              exit_code = FUNC_ERROR;
                           }   
                        }else
                        {
                           exit_code = FUNC_ERROR;
                        }   
                     }else
                     {
                        exit_code = FUNC_ERROR;
                     }   
                  }else
                  {
                     exit_code = FUNC_ERROR;
                  }
               }else
               {
                  exit_code = FUNC_ERROR;
               }
            }  /* End of if (success)  */
         }else
         {
            exit_code = FUNC_ERROR;
         }
      }  /* end of if (ret_msg)  */
      else if ((me->locate_point.response == EX_RESTART) ||
               (me->locate_point.response == EX_RJT_MOVEON))
      {
         /* 
          *  Set flag to create graphic group.
          */

         me->create_flag = CREATE;

         /*
          *  empty the graphics set
          */

         om_msg = gr$gsempty (msg = &ret_msg, p_chanselect = &to_graset);

         if (! (om_msg & ret_msg & 1))
         {
            exit_code = FUNC_ERROR;
         }
      }
      else if (me->locate_point.response == GR_UNKNOWN_TYPE)
      {
         /*
          *  Unknown event, return control to super_cmd
          */

         exit_code = RETCONTROL;
      }

      if (exit_code == FUNC_ERROR)
      {
         exit_code = SUCCESS;
         ex$message(msgnumb = GR_E_ErrEncCmdRst);
         me->create_flag = CREATE;
         om_msg = gr$gsempty (msg = &ret_msg, p_chanselect = &to_graset);
         if (me->create_flag == NEW_GG)
         {
            om_msg = om$send(mode = OM_e_wrt_object,
                     msg = message GRowner.GRdelete_owner(&ret_msg,
                     &me->ModuleInfo),
                     targetid = gg_id.objid,
                     targetos = gg_id.osnum);
         }
      }
   }  /* end while        */
   return (OM_S_SUCCESS);
}  /* end execute method */

/****************************************************************/
/*                      I N I T                                 */
/****************************************************************/

method init ( int type; char *string_ptr )
{
IGRlong         status;         /* OM return status               */
IGRlong         ret_msg;        /* Function return code           */
IGRint          size;           /* Size of DPB structure          */
IGRint          ret_size;       /* Size of DPB structure returned */

   me->locate_state = 0;
   me->create_flag = CREATE;
   me->event_on_q = FALSE;
   me->constr.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;

   me->attr.properties =      LC_LC_ONLY |
                              LC_WRITE_ONLY |
                              LC_DP_ONLY |
                              IGN_MOD_BIT |
                              IGN_PLANAR_BIT;

   me->attr.owner_action =    LC_RIGID_OWNER |
                              LC_FLEX_OWNER |
                              LC_FLEX_COMP;

   strcpy (me->attr.classes, "GRgraphics");

   /*
    *  Get the module environment.
    */

   size = sizeof (struct GRmd_env);
   status = gr$get_module_env (msg = &ret_msg,
                                   sizbuf = &size, 
                                   buffer = &me->ModuleInfo,
                                   nret = &ret_size);
   if (status & ret_msg & 1)
   {
      me->init_success = TRUE;
   }else
   {
      me->init_success = FALSE;
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
OM_S_CHANSELECT to_gragrp;

   /*
    *  Empty & delete the graphic set
    */

   status =  om$make_chanselect (channame = "COggcreate.to_gs",
                                 p_chanselect = &to_graset);
   status =  om$make_chanselect (channame = "COggcreate.to_gg",
                                 p_chanselect = &to_gragrp);

   status = lc$wild_disconnect (p_chanselect = &to_gragrp);

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

end implementation COggcreate;
