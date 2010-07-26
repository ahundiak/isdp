/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*\
Name
   COlcggmem - locate a member of a graphic group

Description
   This is an action handler which is called to make sure that
   the object being located is a member of the desired graphic
   group.  A message is sent to determine if the located object
   is on the "GRconnector.to_owners" channel of the graphic group 
   in question.  If so, then LCptlocact is called to add the object 
   to the locate stack.

   *arglist     struct GRP_gg_member_action_args  Desired graphic group
   *loc_obj     struct GRlc_info                  Located object info
   *locate_args IGRchar                           Arguments to locate
   *action      enum GRlocate_action              Action to be performed

Return values
   OM_S_SUCCESS on successful completion

History
   Mike Mathis    01/02/87     creation
   Gray Winn      03/09/87     include file changes
   Gray Winn      07/25/88     rewrite to work with any owner
\*/

class implementation Root;

#include "coimport.h"
#include "OMprimitives.h"
#include "OMminimum.h"
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
#include "grsymdef.h"
#include "grsym.h"

from GRowner   import   GRis_component_removeable;

IGRint COlcggmem (arglist, loc_obj, locate_args, action)
struct GR_gg_member_action_args  *arglist;  /* desired graphic group */
struct GRlc_info                 *loc_obj;  /* located object information*/
IGRchar                          *locate_args;
enum GRlocate_action             *action;
{
IGRlong        om_msg;
IGRlong        ret_msg;
IGRint         onchan;

   /*
    *  check to see if the desired graphic group is hooked to the
    *  located object
    */

   om_msg = om$send (msg = message GRowner.GRis_component_removeable (
            &ret_msg, &loc_obj->module_info, &loc_obj->located_obj,
            &onchan),
            senderid = NULL_OBJID,
            targetid = arglist->gg_id.objid,
            targetos = arglist->gg_id.osnum);

   if (onchan)
   {
      /*
       *  object is a member of the desired graphic group, so call a
       *  function to add it to the locate stack
       */

      om_msg = LCptlocact (arglist->stack, loc_obj, locate_args, action);
   }
   return (om_msg);
}  
end implementation Root;
