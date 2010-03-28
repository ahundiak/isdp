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
   GScheck_located_object 

Description
   This method is used to check is an object has been added to the
   located objects channel.

   *msg           IGRlong           return code 
   *obj_id        struct GRid       Located object.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    03/13/87    Creation date.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "lcmacros.h"

method GScheck_located_object (IGRlong *msg; struct GRid *obj_id)
{
IGRlong           om_msg;
OM_S_CHANSELECT   posted_chansel;

   *msg = MSSUCC;
   posted_chansel.type = OM_e_name;
   posted_chansel.u_sel.name = "GRgrset.to_sets";

   /*
    *  Check if the object is on my channel.
    */

   om_msg = lc$is_objid_on_channel (p_chanselect = &posted_chansel,
            go_objid = obj_id->objid, 
            go_osnum = obj_id->osnum);

   return (om_msg);
}

end implementation GRsvset;
