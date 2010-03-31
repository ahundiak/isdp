/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"

method EMoperandChanged(IGRlong *EMmsg; 
                        GRobjid old_opnd, new_opnd;
                        IGRushort options)
/*
Description
    This message informs an operation that one of its operands has changed 
    or been completely replaced.  A good example of this occurrence is a
    replacement of the plane (opnd 1) on the intersect plane - save side
    operation.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        old_opnd, 
        new_opnd - fairly obvious, if the operand changed but was not
                   completely replaced then the ids will be the same.
        options - None so far.
    About this override:
        This method provides the statndard response to the message i.e do
        nothing.  EMSslboolean class will certainly override the message
        to check for the ip -ss case.

History
    DLB 09/02/89 Creation.
*/
{
  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}
end implementation EMSdpr;
