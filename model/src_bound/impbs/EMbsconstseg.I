/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "emsdef.h"

extern OMuword OPP_EMSbsedge_class_id;

method EMconstruct_seg(IGRlong *EMmsg; struct EMSpartedinfo *partinfo;
                       struct EMSpartolbasis *partolbasis;  
                       GRobjid *new_objid)
/*
Description

Notes

History
    PP  12/03/87 Made changes to handle setting of edge types correctly
    DLB 5/17/87 creation.
*/

{
 IGRlong OM_stat = OM_S_SUCCESS;
 struct IGRbsp_curve curve;


 *EMmsg = EMS_S_Success;

 /*Get my bc geometry*/
 curve.poles = NULL;
 curve.knots = NULL;
 curve.weights = NULL;
 curve.bdrys = NULL;
 
 OM_stat = om$send(msg = message EMSedge.EMgetbcgeom(EMmsg, 0, MAXINT,
                         FALSE, partinfo, &curve, partolbasis, NULL),
                   targetid = my_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*The new edge should never be reversed*/ 

 partinfo->edprops &= ~EMED_REVERSED;

 /*Make the new bs edge and initialize it*/
 OM_stat = om$construct(classid = OPP_EMSbsedge_class_id,
                        p_objid = new_objid,
                        msg = message EMSbsedge.EMbsinit(EMmsg, 
                              partinfo->edprops, partinfo->edtype, &curve,
                              partolbasis));
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 wrapup:
   if (curve.poles) om$dealloc(ptr = curve.poles);
   if (curve.knots) om$dealloc(ptr = curve.knots);
   if (curve.weights) om$dealloc(ptr = curve.weights);
   if (curve.bdrys) om$dealloc(ptr = curve.bdrys);

   EMWRAPUP(*EMmsg, OM_stat, "In EMSbsedge.EMconstruct_seg")
   return (OM_stat);
}
end implementation EMSbsedge;
