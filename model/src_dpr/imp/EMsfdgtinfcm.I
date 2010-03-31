/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSdprquery.h"


method EMgetInfoAboutComponents(IGRlong *EMmsg; IGRint *comp_info_count;
                                struct EMScomponent_info **comp_info)
/*
Description
    The current requirement for this message is to return connect
    information for primitives only.  Complex composites (i.e DPR's) will
    only return the component ids in the EMScomponent_info structure.  If
    it is desired to return connect information for complex composites, then
    remove this override.

    See $EMS/src_surf/imp/EMsfgtinfcmp.I for a complete description.

Notes
    See $EMS/src_surf/imp/EMsfgtinfcmp.I for a complete description.

Return Values
    EMmsg - EMS_S_Success if all is well.

History
    DLB 09/26/88 Creation.
*/
{
 IGRlong                  OM_stat=OM_S_SUCCESS;
 IGRint                   i, comp_count=0;
 struct GRid              *comp_list=NULL;
 struct EMScomponent_info *current_comp_info;
 void                     EFgetcomponents();


 *EMmsg = EMS_S_Success;

 /*Get all surfaces of this composite and fill the EMScomponent_info 
  * structure.
  */
 EFgetcomponents(EMmsg, my_id, my_id, OM_Gw_current_OS, &comp_count,
                 &comp_list);
 if (!(1 & *EMmsg)) goto wrapup; 

 /*If no surfaces then something fishy is going on.*/
 if (! comp_count) {*EMmsg = EMS_E_InvalidSend; goto wrapup;}

 *comp_info = (struct EMScomponent_info *) om$malloc
              (size = comp_count * sizeof(struct EMScomponent_info));
 if (! *comp_info) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

 *comp_info_count = comp_count;

 for(i=0; i<comp_count; i++) 
 {
   /*Fill the EMScomponent_info structure.*/
   current_comp_info = &(*comp_info)[i];   /*Cut down on indirection.*/

   current_comp_info->surf_id = comp_list[i].objid;
   current_comp_info->num_adjoin_info = 0;
   current_comp_info->adjoin_info = NULL;
 } /*end for i*/

 wrapup:
   if (comp_list) om$dealloc(ptr = comp_list);
   EMWRAPUP(*EMmsg, OM_stat, "In EMSsfdpr.EMgetInfoAboutComponents")
   return (OM_stat);
}
end implementation EMSsfdpr;
