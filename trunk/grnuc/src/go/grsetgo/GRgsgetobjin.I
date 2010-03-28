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
   GRgetobjinfo

Description
   This method reports information about the object.

   *msg        IGRlong              return code
   *info       struct GRobj_info    information structure for locate

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn 08/06/87   Creation Date
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "msmacros.h"
#include "grmessage.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
   *msg = MSSUCC;
   ex$message(msgnumb = GR_I_selset, buff = info->type);
   return(OM_S_SUCCESS);
}
end implementation GRgrset;
