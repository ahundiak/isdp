/* ###################   APOGEE COMPILED   ################## */
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "emserr.h"

IGRboolean EFisAncestryValid(EMmsg, child_objid, child_osnum, 
                             parent_classid, validate_child)

IGRlong         *EMmsg;
GRobjid         child_objid;      /*Objid of supposed child.             */
OMuword         child_osnum;      /*Osnum of supposed child.             */
OMuword         parent_classid;   /*Classid of supposed parent.          */
IGRboolean      validate_child;   /*If TRUE, is_objid_valid check will be*/ 
                                  /*done on child_objid.                 */ 
/*
Description
    This function returns TRUE if the objid/osnum pair given is a subclass
    or the same class as the ancestor classid given.  Otherwise FALSE will
    be returned.

Return Values
    *EMmsg - EMS_S_Success if all goes well.           
             If validate_child option is TRUE and objid/osnum pair is
             invalid then EMS_I_NotFound is returned.  

History
    DLB  09/02/89 For some reason I defined parent_classid as IGRboolean. It
                  is now OMuword.
    DLB  08/31/88 creation.
*/
{
 IGRlong OM_stat = OM_S_SUCCESS;
 OMuword child_classid;

 *EMmsg = EMS_S_Success;

 if (validate_child)
 {
   OM_stat = om$is_objid_valid(objid = child_objid, 
                               osnum = child_osnum);
   if (!(1&OM_stat)) 
   {
     *EMmsg = EMS_I_NotFound;
     return(FALSE);
   }
 }

 OM_stat = om$get_classid(objid = child_objid, 
                          osnum = child_osnum,
                          p_classid = &child_classid);
 if (!(1&OM_stat)) goto wrapup;

 OM_stat = om$is_ancestry_valid(superclassid = parent_classid,
                                subclassid = child_classid);
 if (!(1&OM_stat)) goto wrapup;

 if (OM_stat == OM_I_INVANCESTRY && child_classid != parent_classid)
   return(FALSE);
 else
   return(TRUE); 

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EFisAncestryValid")
  return(FALSE);
}
