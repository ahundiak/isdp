/* $Id: VDusrAttrs.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* I/VDS
 *
 * File:        $VDS/vdutil/VDusrAttrs.I
 *
 * Description:
 *    This file contains the following functions :
 *                  - VDgetUsrAttrs
 *                  - VDmodUsrAttrs
 *
 * Revision History:
 *	$Log: VDusrAttrs.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      08/15/94        R. Manem        Creation
 */

class implementation Root;


#include "igetypedef.h"     /* these two needed for gr.h, order of includes */
#include "igrtypedef.h"     /* important, also needed for IGRint ...        */
#include "gr.h"             /* struct GRid, GRmd_env                        */

#include "OMprimitives.h"   /* om$send                                      */
#include "OMmacros.h"       /* indirectly for OM_S_SUCCESS, OM_E_NODYNMEM   */

#include "AS_status.h"      /* as$status                                    */


from VDSroot     import VDSgetUsrAttributes;
from VDSroot     import VDSmodUsrAttributes;



/*+fe
  Function VDgetUsrAttrs

  Macro Name
      vd$getUsrAttributes

  Abstract
      Gets the user attributes of an object

  Arguments
      IGRlong            *sts             (O)    return code
      struct GRid        object           (I)    id of the object
      struct GRmd_env    *md_env          (I)    module environment of object
      IGRint             *nbAttrs         (O)    number or user attributes
      struct ACrg_coll   **att            (O)    List of user attributes

  Returns
      OM_S_SUCCESS    : if success
      OM_E_NODYNMEM   : not enough dynamic memory available
      OM_W_ABORT      : if some other error
-fe*/



IGRlong VDgetUsrAttrs( IGRlong           *sts,
                       struct GRid       object,
                       struct GRmd_env   *md_env,
                       IGRint            *nbAttrs,
                       struct ACrg_coll  **att )
{

   IGRlong status;

   status = om$send( msg = message VDSroot.VDSgetUsrAttributes( sts, nbAttrs,
                                                                att, md_env ),
                     senderid = NULL_OBJID,
                     targetid = object.objid,
                     targetos = object.osnum );
   return status;
} /* VDgetUsrAttrs */

                              
/*+fe
  Function VDmodUsrAttrs

  Macro Name
      vd$modUsrAttributes

  Abstract
       Modifies the user attributes of an object based on the following logic :

            If the type of the attribute is VD_ATTRIB_DELETE, it is deleted.
            otherwise,
                If the attribute exists, it is modified to reflect
                the new type and value.
                If the attribute does not exist, it is created with the
                new type and value.

  Arguments
      IGRlong            *sts             (O)    return code
      struct GRid        object           (I)    id of the object
      struct GRmd_env    *md_env          (I)    module environment of object
      IGRint             nbAttrs          (I)    number of user attributes
                                                 to be modified
      struct ACrg_coll   *att             (I)    List of attributes to be
                                                 modified

  Notes/Remarks
      The type of an attribute (att[i].desc.type) can have the following
      values :

              VD_ATTRIB_DELETE
              AC_ATTRIB_TEXT
              AC_ATTRIB_DOUBLE

  Returns
      OM_S_SUCCESS    : if success
      OM_E_NODYNMEM   : not enough dynamic memory available
      OM_W_ABORT      : if some other error
-fe*/


IGRlong VDmodUsrAttrs( IGRlong           *sts,
                       struct GRid       object,
                       struct GRmd_env   *md_env,
                       IGRint            nbAttrs,
                       struct ACrg_coll  *att )
{

   IGRlong status;

   status = om$send( msg = message VDSroot.VDSmodUsrAttributes( sts, nbAttrs,
                                                                att, md_env ),
                     senderid = NULL_OBJID,
                     targetid = object.objid,
                     targetos = object.osnum );
   return status;
} /* VDmodUsrAttrs */

end implementation Root;
