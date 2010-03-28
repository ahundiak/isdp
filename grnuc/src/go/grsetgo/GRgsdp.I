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
   GRdisplay

Description
   This method sets up display for the graphics set.

   *msg         IGRlong        completion code:
   *mx_type     IGRshort       type of matrix 
   matrix       IGRmatrix      environment transformation matrix
   *mode        enum GRdpmode  the display mode 
   *dp_id       struct GRid    the display id

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    08/06/87    Creation date.
\*/

class implementation GRgrset;

#include "grimport.h"
#include  "msdef.h"

method GRdisplay(IGRlong *msg;  IGRshort *type; IGRmatrix matrix;
                 enum GRdpmode *mode; struct GRid *dp_id)
{
IGRlong  om_msg;

   *msg = MSSUCC;
   om_msg = om$send (
            msg = message GRgrset.GSdisplay (msg, mode, dp_id),
            targetid = my_id);
   return(om_msg);
}
end implementation GRgrset;
