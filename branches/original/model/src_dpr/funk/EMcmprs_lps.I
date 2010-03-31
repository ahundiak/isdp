/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsmacros.h"
#include "EMSerrordef.h"

from EMSedge import EMpt_location;
from EMSedge import EMreverse;

IGRlong EMcompress_loops(EMmsg,
                         group_num,
                         num_elems_grp,
                         elems,
                         elem_rev,
                         loop_bnd_info,
                         partol,
                         multiple_loops,
                         boss_loop)

IGRlong *EMmsg;
IGRint group_num;
IGRint *num_elems_grp;
IGRchar ***elems;
IGRboolean **elem_rev;
struct EMboundary_info **loop_bnd_info;
struct EMSpartolbasis *partol;
IGRboolean multiple_loops;
GRobjid *boss_loop;

{
 IGRlong stat_OM, msg;
 IGRint i;
 struct GRid edge_id;
 struct EMSptloc_info   pt_location;
 OM_S_CHANSELECT to_edges, to_owner;

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
 if (! (1 & stat_OM)) goto wrapup;

 if ((multiple_loops) && (group_num > 0))
  {
   for (i=0; i<num_elems_grp[group_num]; i++)
        loop_bnd_info[i] = (struct EMboundary_info *) elems[group_num][i];
  }
 else
  {
   for (i=0; i<num_elems_grp[group_num]; i++)
    {
     loop_bnd_info[i] = (struct EMboundary_info *) elems[group_num][i];
  
     if (elem_rev[group_num][i])
      {
       stat_OM = om$send (msg = message EMSedge.EMreverse (&msg),
                          senderid = loop_bnd_info[i]->loop_id,
                          p_chanselect = &to_edges);
       EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
      }
    }
  }

 for (i=1; i<num_elems_grp[group_num]; i++)
  {
   stat_OM = om$get_objid_at_index(objid = loop_bnd_info[i]->loop_id,
                                   p_chanselect = &to_edges,
                                   index = 0,
                                   objidaddr = &edge_id.objid,
                                   osnumaddr = &edge_id.osnum);
   if (! (1 & stat_OM)) goto wrapup;
  
   stat_OM = om$send (msg = message Root.disconnect (to_owner,
                            loop_bnd_info[i]->loop_id, edge_id.osnum,
                            to_edges),
                      senderid = NULL_OBJID,
                      targetid = edge_id.objid);
   if (! (1 & stat_OM)) goto wrapup;
   
   stat_OM = om$send (msg = message Root.connect (to_owner,
                            i, loop_bnd_info[0]->loop_id, edge_id.osnum,
                            to_edges, NULL),
                      senderid = NULL_OBJID,
                      targetid = edge_id.objid);
   if (! (1 & stat_OM)) goto wrapup;
  
   stat_OM = om$send (msg = message Root.delete(1),
                      senderid = NULL_OBJID,
                      targetid = loop_bnd_info[i]->loop_id);
   if (! (1 & stat_OM)) goto wrapup;
  }
 
 *boss_loop = loop_bnd_info[0]->loop_id;
 
 if ((num_elems_grp[group_num] == 1) && 
     (loop_bnd_info[0]->bnd_type != EMS_EDGE_BND))
  {
   pt_location.num_located_edges = 0;
   pt_location.location = EMS_L_UNKNWN;
   pt_location.options = NULL;

   stat_OM = om$send (msg = message EMSedge.EMpt_location (&msg,
                            loop_bnd_info[0]->point_in_area,
                            &pt_location,
                            NULL,
                            partol),
                      senderid = *boss_loop,
                      p_chanselect = &to_edges);
   EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
     
   if (pt_location.location == EMS_L_LEFT)
    {
     stat_OM = om$send (msg = message EMSedge.EMreverse (&msg),
                        senderid = *boss_loop,
                        p_chanselect = &to_edges);
     EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
    }
  }

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMcompress_loops");
 return (stat_OM);

}
end implementation EMSsfround;
