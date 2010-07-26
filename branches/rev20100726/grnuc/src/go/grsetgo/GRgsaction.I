/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRgsaction

Description
   This is an function which performs the steps neccessary to
   add an object to a graphics set.  This function is called by
   the graphics set locate action handlers.

   *new_entry     struct GRlc_info     Struct containing an entry to be
                                       added to the graphics set.
   *action        enum GRlocate_action Locate action
   *gs_id         struct GRid          The graphics set object id
   *sv_id         struct GRid          The save set object id
   *type          IGRint               The relation of the object to
                                       the prism.  If this is not a prism
                                       locate pass in NULL.
   use_sv_id      IGRint               If TRUE then use the save set id
                                       when adding objects.  
                                       If FALSE then use  the graphics set 
                                       id when adding objects.

Algorithm
   If the action handler receives an add_all, add_inside, add_outside,
   add_overlap action type, it sends the GSadd message to the targetid
   object.  The object will connects the graphics object to itself or
   foward the message to the appropiate object.

   If the action handler receivs a start_transition action type, it
   sends the GSstart_transition message to the graphics set object.  
   The graphics set method constructs a save set, defines the save 
   set as current, and sends the GSstart_transitoin message.  
   The save set method stores the environment.

   If the action handler receives an end_transition action type,
   it sends the GSend_transiton message to the graphics set object.
   The graphics set method restores the previous save set to the 
   current save set by calling the GSend_transition method on the
   current save set.

   If the action handler receives a post_object action type,
   it send the GSpost_object message to the save set.  The save set
   will add the object to a channel so that an efficient check can 
   be done to see if the object has received the locate message
   in this locate process.  The post channel is cleared when the
   end transition message is sent.

   If the action handler receives a check_object action type,
   it send the GScheck_object message to the save set.  The save set
   will check to see if the object has been added to its post
   channel.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgs.h"
#include "grgsdef.h"
#include "godef.h"
#include "lcmacros.h"
#include "grerr.h"
#include "dpmacros.h"

from  GRgrset  import   GSstart_transition, GSadd, GSend_transition;
from  GRsvset  import   GSpost_located_object, GScheck_located_object;
from  GRvg     import   GRgetsymb;
from  GRgraphics import GRgetprops;

IGRint GRgsaction( new_entry, action, gs_id, sv_id, type, use_sv_id)
struct GRlc_info        *new_entry;
enum GRlocate_action    *action;
struct GRid             *gs_id;
struct GRid             *sv_id;
IGRint                  *type;
IGRint                  use_sv_id;
{
IGRlong        om_msg;
IGRlong        ret_msg;
IGRint         env_prop;
GRobjid        local_targetid;
GRspacenum     local_targetos;
OM_p_MESSAGE   pass_msg;

   env_prop = NULL;

   /*
    *  Perform function based on action type.
    */

   switch (*action)
   {
      case post_object:
      {
         local_targetid = sv_id->objid;
         local_targetos = sv_id->osnum;
         pass_msg =  message GRsvset.GSpost_located_object (&ret_msg, 
                     &new_entry->located_obj);
      }
      break;

      case check_object:
      {
         local_targetid = sv_id->objid;
         local_targetos = sv_id->osnum;
         pass_msg =  message GRsvset.GScheck_located_object (&ret_msg, 
                     &new_entry->located_obj);
      }
      break;

      case start_transition:
      {
         local_targetid = gs_id->objid; 
         local_targetos = gs_id->osnum;
         pass_msg = message GRgrset.GSstart_transition (&ret_msg,
                    &new_entry->module_info, &env_prop, NULL, sv_id);
      }
      break;

      case end_transition:
      {
         local_targetid = gs_id->objid; 
         local_targetos = gs_id->osnum;
         pass_msg = message GRgrset.GSend_transition (&ret_msg, 
                    sv_id);
      }
      break;

      default:
      {
         if (use_sv_id)
         {
            local_targetid = sv_id->objid;
            local_targetos = sv_id->osnum;
         }else
         {
            local_targetid = gs_id->objid;
            local_targetos = gs_id->osnum;
         }

         pass_msg =  message GRgrset.GSadd (&ret_msg, 
                     &new_entry->located_obj, type);
      }
      break;
   }

   om_msg = om$send (msg = pass_msg, senderid = NULL_OBJID, 
            targetid = local_targetid, targetos = local_targetos);

   return (om_msg);
}  

/*\
Name
   GRgs_locate_action

Description
   This is an action handler which performs the steps neccessary to
   add an object to a graphics set.

   *action_args[] struct GRid          An array of 2 objids a graphics
                                       set, and the save set.
   *new_entry     struct GRlc_info     Struct containing an entry to be
                                       added to the graphics set.
   *locate_args   IGRchar              Locate arguments.
   *action        enum GRlocate_action Locate action
Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/
#argsused
IGRint GRgs_locate_action (action_args, new_entry, locate_args, action)
struct GRid             action_args[];
struct GRlc_info        *new_entry;
IGRchar                 *locate_args;
enum GRlocate_action    *action;
{
   return(GRgsaction (new_entry, action, &action_args[0], &action_args[1], 
                      (IGRint *) NULL, TRUE));
}

/*\
Name
   GRgs_rp_action

Description
   This is an action handler which performs the steps neccessary to
   add an object to a graphics set.  This action handler is used on the
   right prism locate.

   *action_args   GRrp_action_args     The right prism locate structure.
   *new_entry     GRlc_info            Struct containing an entry to be
                                       added to the graphics set.
   *locate_args   IGRchar              Locate arguments.
   *action        enum GRlocate_action Locate action

Return Vales
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/
#argsused
IGRint GRgs_rp_action ( action_args, new_entry, locate_args, action)
struct GRrp_action_args *action_args;
struct GRlc_info        *new_entry;
IGRchar                 *locate_args;
enum GRlocate_action    *action;
{
IGRlong        om_msg;
IGRint         type;

   type = NULL;

   /*
    *  Perform function based on action type.
    */

   switch (*action)
   {
      case add_inside:
      {
         if (! (action_args->rp_relation & GO_INSIDE))
         {
            return(OM_S_SUCCESS);
         }
         type = GO_INSIDE;
      }
      break;         

      case add_outside:
      {
         if (!(action_args->rp_relation & GO_OUTSIDE))
         {
            return(OM_S_SUCCESS);
         }
         type = GO_OUTSIDE;
      }
      break;         

      case add_overlap:
      {
         if (!(action_args->rp_relation & GO_OVERLAP))
         {
            return(OM_S_SUCCESS);
         }
         type = GO_OVERLAP;
      }
      break;         
   }

   /* 
    *  If clipping then use the graphics set as the default
    *  object to send to otherwise send the add messages directly to
    *  the save set.
    */

   om_msg = GRgsaction (new_entry, action, &action_args->gs_id, 
            &action_args->sv_id, (type) ? &type : NULL, 
            (action_args->clip_flag) ? FALSE : TRUE);

   return (om_msg);
}  

/*\
Name
   GRgs_symb_action

Description
   This is an action handler which performs the steps neccessary to
   add an object to a graphics set.  This action handler will also
   do a symbology criteria check.

   *action_args   struct GRsymb_action_args  The structure defining the
                                             symbology
   *new_entry     struct GRlc_info           Entry to be added to the
                                             graphics set.
   *locate_args   IGRchar                    Locate arguments.
   *action        enum GRlocate_action       Locate action

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

#define gen_bit_test(addr,bit_no) (*(((char *) (addr))+((bit_no)/8)) &  \
                                    ( 1 << ((bit_no)%8)))
#define WEIGHT_DEFINED  1
#define COLOR_DEFINED   2
#define STYLE_DEFINED   4
#argsused
IGRint GRgs_symb_action( action_args, new_entry, locate_args, action)
struct GRsymb_action_args  *action_args;
struct GRlc_info           *new_entry;
IGRchar                    *locate_args;
enum GRlocate_action       *action;
{
IGRlong              om_msg;
IGRlong              ret_msg;
struct GRsymbology   symb;

   om_msg = OM_S_SUCCESS;
   if (action_args->flag &(COLOR_DEFINED | STYLE_DEFINED | WEIGHT_DEFINED))
   {
      /*
       *  Inquire the symbology of the object.  If the object symbology
       *  is correct then the object is added.  Otherwise the object
       *  is rejected.
       */

      om_msg = om$send ( msg = message GRvg.GRgetsymb (&ret_msg, &symb),
               senderid = NULL_OBJID,
               targetid = new_entry->located_obj.objid,
               targetos = new_entry->located_obj.osnum);

      if (om_msg & ret_msg & 1)
      {
         if (action_args->flag & COLOR_DEFINED)
         {
            if (!(gen_bit_test(action_args->color, 
                               symb.display_attr.color)))
            {
               return(OM_S_SUCCESS);
            }
         }

         if (action_args->flag & WEIGHT_DEFINED)
         {
            if (!(gen_bit_test(action_args->weight,
                               symb.display_attr.weight)))
            {
               return(OM_S_SUCCESS);
            }
         }

         if (action_args->flag & STYLE_DEFINED)
         {
            if (!(gen_bit_test(action_args->style, 
                               symb.display_attr.style)))
            {
               return(OM_S_SUCCESS);
            }
         }
   
         om_msg = GRgsaction ( new_entry, action, &action_args->gs_id, 
                  &action_args->sv_id, (IGRint *) NULL, TRUE);
      }else
      {
         return(OM_S_SUCCESS);
      }
   }
   return (om_msg);
}  



#argsused
IGRint GRgs_delete_action( action_args, new_entry, locate_args, action)
struct GRdelete_action     *action_args;
struct GRlc_info           *new_entry;
IGRchar                    *locate_args;
enum GRlocate_action       *action;
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRshort             properties;
/*IGRshort             mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;*/
OMuword              go_classid;
struct GRsymbology   symb;
/*IGRint               class_status;*/

    om_msg = OM_S_SUCCESS;
/*
 *  If the element fails to meet the properties then it should be
 *  added to the located elements.   This is so that the proper 
 *  elements may be deleted by the file fence command.
 */

/*
 *  The criteria that will be checked is window layers, global layers,
 *  locateable, displayable, and classchecks. 
 */
    om_msg = om$send (msg = message GRvg.GRgetsymb (&ret_msg, &symb),
                      senderid = NULL_OBJID,
                      targetid = new_entry->located_obj.objid,
                      targetos = new_entry->located_obj.osnum);

    if (om_msg & 1) {
/*
 *  If the element has a layer and is does not pass the layers passed in
 *  call the action handler to have it deleted.
 */
        if (ret_msg != GR_I_NO_LAYER) {
            if (!DPlevel_check (symb.level, action_args->layers)) {
                goto action_handler;
            }
        }
    }
    om_msg = om$send (msg = message GRgraphics.GRgetprops 
                            (&ret_msg, &properties),
                      senderid = NULL_OBJID,
                      targetid = new_entry->located_obj.objid,
                      targetos = new_entry->located_obj.osnum);
    if (om_msg & 1 && ret_msg == MSSUCC) {
/*
 *  If the element is not displayable or locateable call the action
 *  handler to have the element deleted.
 */
        if (!(properties & GRIS_LOCATABLE)
              ||
            !(properties & GRIS_DISPLAYABLE)) {
            goto action_handler;
        }
    }

    om_msg = om$get_classid (objid = new_entry->located_obj.objid,
                             osnum = new_entry->located_obj.osnum,
                             p_classid = &go_classid);
/*
 *  If the element passes the class check then reject it.  Only the
 *  elements that fail should be accepted.  This is so that the proper
 *  elements get deleted.  The only classes that will be checked are
 *  the global types that are allready incorporated into the macro.
 *
 *  During this locate operation the global class check criteria is
 *  turned off.  It must be explicitly turned on so that the element
 *  may be checked for deletion.
 */

    LCclass_check_on();
    om_msg = lc$classchek (rc = &ret_msg, classid_to_check = go_classid,
                  eligible_classes = NULL);
    LCclass_check_off();

    if (om_msg) {
        return (om_msg);
    }
action_handler:    
    om_msg = GRgsaction ( new_entry, action, &action_args->gs_id, 
                  &action_args->sv_id, (IGRint *) NULL, TRUE);
    return (om_msg);
}  


end implementation Root;
