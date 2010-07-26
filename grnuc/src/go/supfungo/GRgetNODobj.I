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
   GRget_NOD_object

Description
   This function is used to construct/reterive a NOD object.
   The NOD object is given a unique name so that it can be identified
   across design sessions.

   *msg        IGRlong        return code
   osnum       uword          The object space number of the NOD
   *objid      GRobjid        The object id of the NOD.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    10/16/86    Creation date.
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "exmacros.h"

#define  IGE_NOD_NAME    "IGENOD"

IGRint GRget_NOD_object (msg, osnum, objid)
IGRlong  *msg;
uword    osnum;
GRobjid  *objid;
{
IGRlong  om_msg;

   *msg = MSSUCC;

   /*
    *  Call an EX macro to retreive the NOD.
    *  If a NOD object could not be found then
    *  create a NOD object.
    */

   om_msg = ex$get_NOD (NODname = IGE_NOD_NAME,
            pobjid = objid, create = TRUE,
            modid = NULL, mod_osnum = osnum);

   return(om_msg);
}   

end implementation Root;
