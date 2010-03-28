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
   GSempty 

Description
   This method is used to remove all graphics objects from the 
   graphics set.

    *msg           IGRlong         return code
    *owner_id      GRid            Owner object.
    owner_chansel  OM_p_CHANSELECT Channel of the owner object.

Notes
   The owner_chansel and owner_id can be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSempty (IGRlong *msg; struct GRid *owner_id;
                OM_p_CHANSELECT owner_chansel)
{
IGRlong           om_msg;

   *msg = MSSUCC;
   om_msg = om$send(msg = message Root.delete (NULL), targetid = my_id);
   return ( om_msg );
}
end implementation GRsvset;
