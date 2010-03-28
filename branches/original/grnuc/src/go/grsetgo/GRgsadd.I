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
   GSgsadd

Description
   This method is used to add an object to the current save set.

   *msg         IGRlong       return code 
   *obj_id      GRid          The object id of the object to be
                              added to the save set.
   *rp_relation IGRint        contains the relationship with the
                              right prism (i.e. inside, outside,
                              or overlap)

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

method GSadd (IGRlong *msg; struct GRid *obj_id; IGRint *rp_relation)
{
IGRlong           om_msg;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;
   
   if (me->properties & GRIS_CURRENT)
   {
      om_msg = om$send (
               msg = message GRgrset.GSadd (msg, obj_id, rp_relation),
               targetid = me->current_sv.objid,
               targetos = me->current_sv.osnum);
   }else
   {
      *msg = MSFAIL;
   }
   return (om_msg);
}
end implementation GRgrset;
