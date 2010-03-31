/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlinedge;

#include "EMS.h"
#include "emsdef.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "emsedgedef.h"

extern OMuword OPP_EMSlinedge_class_id;

method EMconstruct_seg(IGRlong *EMmsg; struct EMSpartedinfo *partinfo;
                       struct EMSpartolbasis *partolbasis;  
                       GRobjid *new_objid)
/*
Description

Notes

History
    WBC 12/28/93        When calling EMleinit, set the option
                        EMSleinit_NoIsoCheck if the edge is marked as iso to
                        avoid tolerance problems (iso tolerance check won't
                        be made in EMleinit). TR#119314468)
    PP  08/11/88        Modified arguments to EMgetpygeom
    SM  31-Oct-87	Modified to send curve type to EMleinit method.
    DLB 5/17/87 	creation.
*/
{
 IGRlong OM_stat = OM_S_SUCCESS;
 struct IGRpolyline poly;


 *EMmsg = EMS_S_Success;

 /*Get my polyine geometry*/
 poly.num_points = 0;
 poly.points = NULL;

 OM_stat = om$send(msg = message EMSedge.EMgetpygeom(EMmsg, 0, MAXINT,
                         FALSE, partinfo, &poly, partolbasis, NULL),
                     targetid = my_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*The new edge should never be reversed*/ 
 partinfo->edprops &= ~EMED_REVERSED;

 /*Make the new linear edge and initialize it*/
 OM_stat = om$construct(classid = OPP_EMSlinedge_class_id,
                        p_objid = new_objid,
                        msg = message EMSlinedge.EMleinit(EMmsg, 
                              partinfo->edprops, partinfo->edtype, &poly, 
                              partolbasis,
                              (partinfo->edprops & EMED_ISO) ?
                                        EMSleinit_NoIsoCheck : NULL,
                              NULL_OBJID));
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 wrapup:
   if (poly.points) om$dealloc(ptr = poly.points);
   EMWRAPUP(*EMmsg, OM_stat, "In EMSlinedge.EMconstruct_seg")
   return (OM_stat);
}
end implementation EMSlinedge;
