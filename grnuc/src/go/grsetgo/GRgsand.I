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
   GS_and_operation

Description
   This method will perform a logical AND of this graphics set and the
   graphics set passed in gs_id.  This will become the resulting
   graphics set.

   *msg          IGRlong            return code
   *gs_id        struct GRid        The object id of the graphics set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    07/07/87    Creation date.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

method GS_and_operation (IGRlong *msg; struct GRid *gs_id)
{
IGRlong           om_msg;
OM_S_CHANSELECT   sets_sel;

   *msg = MSSUCC;
   sets_sel.type = OM_e_name;
   sets_sel.u_sel.name = "GRgrset.to_sets";

   om_msg = om$send (
            msg = message GRgrset.GS_and_operation (msg, gs_id),
            p_chanselect = &sets_sel);

   return(om_msg);
}
end implementation GRgrset;
