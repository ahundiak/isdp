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

Notes
   The variable sv_id may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSend_transition (IGRlong *msg; struct GRid *sv_id)
{
IGRlong           om_msg;
struct GRid       temp_id;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   /*
    *  If a save set is current.
    */

   if (me->properties & GRIS_CURRENT)
   {
      /*
       *  Send the end transition message to the current save set.
       */

      temp_id = me->current_sv;

      om_msg = om$send (
               msg = message GRgrset.GSend_transition (msg, 
               &me->current_sv),
               targetid = temp_id.objid, targetos = temp_id.osnum);


      if (sv_id) *sv_id = me->current_sv;

      /*
       *  If this save set was the first saveset then clear
       *  the is current property.
       */

      if (me->current_sv.objid == NULL_OBJID)
      {
         me->properties &= (0xffffffff ^ GRIS_CURRENT);
      }
   }
   return (om_msg);
}
end implementation GRgrset;
