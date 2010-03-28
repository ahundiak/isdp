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
   GSend_transition 

Description
   This method is used to define the end of an environment and the 
   transition to the previous environment.

   *msg         IGRlong        return code 
   *sv_id       struct GRid    The object id of the current saveset.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "lcmacros.h"

method GSend_transition (IGRlong *msg; struct GRid *sv_id)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;
OM_S_CHANSELECT   posted_chansel;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";
   posted_chansel.type = OM_e_name;
   posted_chansel.u_sel.name = "GRgrset.to_sets";

   *msg = MSSUCC;
   if (sv_id)
   {
      *sv_id = me->current_sv;
   }

   om_msg = lc$wild_disconnect (p_chanselect =&posted_chansel);

   if (me->path.md_id.objid != NULL_OBJID)
   {
      /*
       *  Free up the space from the preallocation of this channel.
       */

      om$channel_unpreset (p_chanselect = &chansel, collapse_flag = 1);
   }

   return ( OM_S_SUCCESS );
}

end implementation GRsvset;
