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
   This method retrieves information about the object and stores
   it in the input structure.

   *msg        IGRlong           completion code
   *info       struct GRobj_info structure for information about 
                                 the object

Return Values
   MSSUCC -    if successful

History
   Gray Winn   09/17/87    Design date.
\*/

class implementation GRgrgrp;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "msmacros.h"
#include "grmessage.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
   *msg = MSSUCC;
   ex$message(msgnumb = GR_I_grgrp, buff = info->type);
   return(OM_S_SUCCESS);
}
end implementation GRgrgrp;
