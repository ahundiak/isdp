/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"

method EMconstruct_seg(IGRlong *EMmsg; struct EMSpartedinfo *partinfo;
                       struct EMSpartolbasis *partolbasis;  
                       GRobjid *new_objid)
/*
Description
Notes
History
    DLB 5/17/87 creation.
*/

{
 *EMmsg = EMS_F_Fail;
 return(OM_E_ABORT);
}
end implementation EMSedge;
