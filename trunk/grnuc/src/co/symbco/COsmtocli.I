/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COsmtocl

Description
   This method implements the convert symbol reference to symbol command.

History
   HGW  07/29/86   Creation.
   mrm  10/01/86   OM 4.0 conversion
   HGW  02/16/87   Change to use method that converts a symbol to a cell
   HGW  11/16/87   Changes for version 1.1
   SCW  07/07/92   ANSI conversion
\*/

class implementation COsmtocl;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "codef.h"
#include "OMerrordef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grgsmacros.h"

from GRsmhdr import GRcp_symbol_to_cell;

/* 
 *  Control looping conditions
 */

#define FUNC_ERROR  0     /* Exit command and return(om_msg)      */ 
#define SUCCESS     1     /* Continue looping                     */
#define RETCONTROL  2     /* Exit command and return(OM_S_SUCCESS */



/****************************************************************/
/*                       E X E C U T E                          */
/****************************************************************/

method execute ( IGRint *response; IGRchar *response_data; IGRint pos )
{
IGRlong        om_msg;        /* OM return status       */
IGRlong        ret_msg;       /* Function return code   */
IGRlong        exit_code;     /* Loop control variable  */
IGRlong        size;   
OM_S_CHANSELECT      chansel;
struct GRevent       locate_event;
struct GRmd_env      mod_env;
struct GRid          cl_id;   /* symbol object id                 */

   ex$message(msgnumb = GRC_M_CnvSymCel);

   if (me->init_success)
   {
      exit_code = SUCCESS;
      me->eligible_classes.p_classes = &me->classes;
      chansel.type = OM_e_name;
      chansel.u_sel.name = "COsmtocl.to_gs_channel";
   }else
   {
      ex$message(msgnumb = GR_E_ErrEncCmdTrm);
      *response = TERMINATE;
      exit_code = RETCONTROL;
   }

   while ( exit_code == SUCCESS )
   {
      /*
       *  Call the locate filter to locate an object.
       */

      om_msg = gr$gslocate (msg = &ret_msg,
               event1 = &me->locate_point,
               event2 = &me->locate_point,
               locate_event = &locate_event,
               mask1 = GRm_DATA | GRm_RESTART | GRm_OBJID,
               mask2 = GRm_DATA | GRm_RESTART | GRm_OBJID,
               display_flag = ALL_WINDOWS | ELEM_HILIGHT | 
                              NO_PROJ_ACCEPT_POINT,
               locate_key = GR_P_IdSym,
               acc_key = GR_P_AccSym,
               relocate_key = GR_E_NoEleFnd,
               stack = &me->locate_stack,
               attributes = &me->attr,
               num_inputs = 1,
               locate_state = &me->locate_state,
               input1_mask = GRm_DATA | GRm_RESTART | GRm_OBJID,
               input1_key = GR_P_AccSym,
               eligible_classes = &me->eligible_classes,
               p_chanselect = &chansel);

      me->event_on_q = FALSE;

      if (COERROR (om_msg))
      {
         ex$message(msgnumb = GR_E_ErrEncCmdRst);
         continue;
      }
      else if ( (ret_msg & 1) &&
                ((me->locate_point.response == EX_DATA) ||
                 (me->locate_point.response == EX_OBJID)))
      {
         /*
          *  Element was accepted. 
          *  Erase the highlight plane.
          */
        
         om_msg = dp$erase_hilite (msg = &ret_msg,
                  objid = me->ModuleInfo.md_id.objid,
                  osnum = me->ModuleInfo.md_id.osnum);

         if (COERROR (om_msg & ret_msg))
         {
            ex$message(msgnumb = GR_E_ErrEncCmdRst);
            continue;
         }
            
         /*
          *  Copy the symbol reference to a symbol.
          */

         om_msg = gr$gspass(msg = &ret_msg,
                  pass_msg = message GRsmhdr.GRcp_symbol_to_cell (
                  &ret_msg, &mod_env, &me->ModuleInfo, &cl_id),
                  path = &mod_env,
                  p_chanselect = &chansel);

         if (COERROR(om_msg & ret_msg))
         {
            ex$message(msgnumb = GR_E_ErrEncCmdRst);
            continue;
         }

         /*
          *  Delete the symbol reference.
          */

         om_msg = gr$gsdelete(msg = &ret_msg, p_chanselect = &chansel);

         if (COERROR(om_msg & ret_msg))
         {
            ex$message(msgnumb = GR_E_ErrEncCmdRst);
            continue;
         }

         /*
          *  Use the accept point to locate the next graphics
          *  object.  This is done by pushing the datapoint onto
          *  the event queue.
          */

         size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
         om_msg = ex$putque ( msg = &ret_msg, response = response,
                  byte = &size, buffer = (IGRchar *)&me->locate_point.event );

         if (COERROR (om_msg))
         {
            ex$message(msgnumb = GR_E_ErrEncCmdRst);
            continue;
         }else
         {
            me->event_on_q = TRUE;
         }
      }
      else if (me->locate_point.response == EX_RESTART)
      {
         /* 
          *  Continue to identify elements to drop.
          */
      }
      else if (me->locate_point.response == GR_UNKNOWN_TYPE)
      {
         /*
          *  Unknown event, return control to super_cmd
          */

         exit_code = RETCONTROL;
      }
   }  /* end while        */
   return ( OM_S_SUCCESS );
}   /* end execute method */

/****************************************************************/
/*                      I N I T                                 */
/****************************************************************/

method init ( int type; char *string_ptr )
{
IGRlong     ret_msg;
IGRlong     om_msg;         /* OM return status              */
IGRlong     size;
IGRlong     ret_size;

   om_msg = OM_S_SUCCESS;

   me->event_on_q = FALSE;

   me->attr.properties =   LC_LC_ONLY |
                           LC_WRITE_ONLY |
                           LC_DP_ONLY |
                           IGN_MOD_BIT |
                           IGN_PLANAR_BIT;

   me->attr.owner_action = LC_RIGID_OWNER;

   me->eligible_classes.w_count = 1;
   me->eligible_classes.w_flags = OM_CLST_subclass;
   om_msg = om$get_classid ( classname = "GRsmhdr",
                             p_classid = &me->classes);

   strcpy (me->attr.classes, "GRsmhdr");
   size = sizeof (struct GRmd_env);
   if (gr$get_module_env (msg = &ret_msg, sizbuf = &size, 
      buffer = &me->ModuleInfo, nret = &ret_size))
   {
      me->init_success = TRUE;
   }else
   {
      me->init_success = FALSE;
   }
   return ( OM_S_SUCCESS );
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             delete                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method delete (int flag)
{
IGRlong           om_msg;     /* OM return code */
IGRlong           ret_msg;
OM_S_CHANSELECT   chansel;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "COsmtocl.to_gs_channel";

   /*
    *  Delete the graphics set.  Then delete yourself.
    */

   om_msg = gr$gsempty (msg = &ret_msg, p_chanselect = &chansel);

   om_msg = om$send(mode = OM_e_wrt_message,
                    msg = message COroot.delete ( NULL),
                    senderid = my_id,
                    targetid = my_id);

   return ( OM_S_SUCCESS );
}
end implementation COsmtocl;
