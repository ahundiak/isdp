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

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "exmacros.h"

/*\
Name
   GRget_global_mgr_id

Description
   This routine will retrieve an object from the IGENOD object.

   *msg           IGRlong        completion code
   *name          IGRchar        Name of the global manager
   osnum          GRspacenum     The space number that of global manager
   *global_mgr    GRobjid        The global manager object id

Return Values
   MSSUCC   if successful
   MSFAIL   if failure

History 
   Gray Winn      Creation Date
\*/

IGRint GRget_global_mgr_id (msg, name, osnum, global_mgr)
IGRlong        *msg;
IGRchar        *name;
GRspacenum     osnum;
GRobjid        *global_mgr;
{
IGRlong     om_msg;
GRobjid     NOD_objid;

   *msg = MSSUCC;
   GRget_NOD_object(&om_msg, osnum, &NOD_objid);
   om_msg =  ex$get_objid_from_NOD (NODobjid = NOD_objid,
             objname = name, pobjid = global_mgr, mod_osnum = osnum);
   return ( om_msg );
}
end implementation Root;
