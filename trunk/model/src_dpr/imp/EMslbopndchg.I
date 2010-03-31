/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslboolean;

#include "EMS.h"
#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

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

History
    DLB 09/02/89 Creation.
*/
{
  IGRlong          OM_stat=OM_S_SUCCESS;
  OMuint           opnd_inx;
  enum EMSbooltype exact_type;
  OM_S_CHANSELECT  to_comps;



  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(EMmsg,
                          NULL, &exact_type, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL), 
                   targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (exact_type == EMSbool_saveside)
  {
    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$get_index(object_c = me,
                           p_chanselect = &to_comps,
                           objid = new_opnd,
                           indexaddr = &opnd_inx);
    if (!(1 & OM_stat)) goto wrapup;
 
    if (opnd_inx == 1)
    {
      /*Save side plane was changed so I will change to a generic difference*/
      ME.EMSsfboolean->operation = EMSbool_difference;
    }
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSslbool.EMopndChanged")
    return(OM_stat);
}
end implementation EMSslboolean;
