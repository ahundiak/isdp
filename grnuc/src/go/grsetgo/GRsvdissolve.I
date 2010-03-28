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
   GSdissolve 

Description
   This method is used to disconnect all members from the graphics
   set and then delete the graphics set.

    *msg         IGRlong        return code

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

method GSdissolve (IGRlong *msg )
{
IGRlong           om_msg;

   *msg = MSSUCC;
   om_msg = om$send(msg = message Root.delete (NULL), targetid = my_id);
   return ( om_msg );
}

end implementation GRsvset;
