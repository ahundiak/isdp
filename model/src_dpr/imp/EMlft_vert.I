/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsf_lift;

#include "EMS.h"
#include <stdio.h>
#include "emsmacros.h"
#include "OMmacros.h"

#define inst_tbl       ME.EMSsf_lift->move_info[entry]

from EMSedge  import EMget_sf_edges, EMendpts, EMget_props;

method EMlift_vertex (
    IGRlong                           *EMmsg;
    struct   GRmd_env                 *md_env;
    struct   GRvg_construct           *construct_list;
    IGRpoint                          from_pt;
    IGRpoint                          to_pt;
    struct   GRid                     sf_GRid;
    struct   GRid                     ed_GRid;
    IGRshort                          which_end_pt;
    IGRushort                 active_constraints;
    struct   EMSlft_cnstrnt_info      *constraint_info )

/*
Notes

    This method does the preprocessing for lift vertex
    operation. It builds up the instruction table of
	the instance data. After constructing the instruction
	table, filling the rest of the instance data and other relevent
    information, EMlift_execute message is invoked to process the
    operation.

History   RC   10/30/87    Creation Date
          RC   03/01/88    Modified arguments and code to
                             include constraints.
*/

{
  struct     EMSlft_lp_info         lps_info;
  struct     EMSlft_slp_info        sublps_info;
  struct     EMSlft_ed_info         ed_info[2];
  struct     EMSlft_info            lift_info;
  IGRdouble                         vt_pt[4], uv_pts[6];
  OM_S_CHANSELECT                   cm_ed_chan;
  struct     GRid                   shed_GRid, cur_ed;
  OMuint                            blksize, count;
  IGRlong                           mthd_stat;
  IGRlong                           OM_stat;
  IGRint                            num_sh_edges, num_uv_pts = 0, 
                                    ed_idx, num_sublps = 0, num_lps = 0,
                                    entry, i;
  IGRushort                         ed_props;
  void                              EMmake_poles_on_surface(),
                                    EFmemory_allocation();


OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;
blksize = sizeof(IGRdouble) * 4;

/*
 * get the edges of the surface sharing the edge under 
 * consideration at the given given end point.
 */

OM_stat = om$send (msg = message EMSedge.EMget_sf_edges( &mthd_stat,
                    which_end_pt, &shed_GRid, &num_sh_edges),
                   targetid = ed_GRid.objid, targetos = ed_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

/*
 * get the end points (u,v) of the edge under consideration.
 * Put these points in the instruction_table such
 * that first point is the one that is to be moved
 * and the second point is the one that is to be kept rigid.
 */

OM_stat = om$send (msg = message EMSedge.EMendpts ( &mthd_stat,
                   (which_end_pt == EMS_EDGE_BEG_PT) ? vt_pt : &vt_pt[2],
                   (which_end_pt == EMS_EDGE_BEG_PT) ? &vt_pt[2] : vt_pt,
                    NULL, NULL, NULL),
                   targetid = ed_GRid.objid, targetos = ed_GRid.osnum);
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

/*
 * There should be a pole at each end point of the edge.
 * This can be found by checking EMED_COMPATIBLE
 * property of the edge. If the edge is compatible 
 * it has poles at its end points. 
 */

OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                    &ed_props),
                   targetid = ed_GRid.objid, targetos = ed_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

if (!(ed_props & EMED_COMPATIBLE))
{ 
  OM_BLOCK_MOVE (vt_pt, uv_pts, blksize);
  num_uv_pts = 2;
}
 
OM_stat = om$vla_set_dimension( varray = me->move_info,
			size = num_sh_edges+2);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);   

/*
 * add an instruction for the vertex movement
 */

entry = 0;
inst_tbl.move_operation = EMS_MOVE_LIN_VERTEX;
OM_BLOCK_MOVE(vt_pt, inst_tbl.params.vt_pt, sizeof(IGRdouble)*2);
entry++;

/*
 * add an entry for the edge under consideration
 */

inst_tbl.move_operation = EMS_MOVE_INT_PRP_EDGE;
OM_BLOCK_MOVE (vt_pt, inst_tbl.params.end_pts, blksize);
entry++;

/*
 * add an entry to the edge sharing the end point
 * of the above edge
 */

OM_stat = om$send (msg = message EMSedge.EMendpts ( &mthd_stat, 
                 (which_end_pt == EMS_EDGE_BEG_PT) ? &vt_pt[2] : vt_pt,
                 (which_end_pt == EMS_EDGE_BEG_PT) ? vt_pt : &vt_pt[2],
                 NULL, NULL, NULL),
               targetid = shed_GRid.objid, targetos = shed_GRid.osnum);
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

inst_tbl.move_operation = EMS_MOVE_INT_PRP_EDGE;
OM_BLOCK_MOVE (vt_pt, inst_tbl.params.end_pts, blksize);

/*
 * Trivially check if the edge has a pole at its end points.
 */

OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                    &ed_props),
                   targetid = shed_GRid.objid, 
                   targetos = shed_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

if (!(ed_props & EMED_COMPATIBLE))
{ 
  OM_BLOCK_MOVE (&vt_pt[2], &uv_pts[num_uv_pts*2], sizeof(IGRdouble)*2);
  num_uv_pts++;
}

me->num_instructions = num_sh_edges + 2;
me->operation_type = EMS_LIFT_VERTEX;

for (i = 0; i < 3; i++)
	me->lift_vector[i] = to_pt[i] - from_pt[i];

/*
 * Make sure that the end points of the edge under consideration
 * and the edges sharing it have surface poles.
 */

if (num_uv_pts)
{
  EMmake_poles_on_surface (&mthd_stat, &sf_GRid, NULL, md_env, uv_pts,
                          num_uv_pts);
  EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
}
 
/*
 * Since it is a surface/composite surface, it may be possible that
 * some of the edges donot have a common edge. Such edges
 * will not be used in the lift operation. Thus
 * these edges should be filtered out.
 */

 OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 ed_idx = 0;

 for (i = 0; i < 2; i++)
 {
   cur_ed = i ? ed_GRid : shed_GRid;

   OM_stat = om$get_channel_count (osnum = cur_ed.osnum,
                      objid = cur_ed.objid, 
                      p_chanselect = &cm_ed_chan, count = &count);
   EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

   if (count)
   {
     ed_info[ed_idx].ed_GRid = cur_ed;
     ed_info[ed_idx].ed_sf_type = EMS_C_RULED_SF;
     ed_info[ed_idx].ed_constraint_type = NULL;
     if (active_constraints & EMS_LC_AUTO_COINCIDENCE)
       ed_info[ed_idx].ed_constraint_type |= EMS_LC_AUTO_COINCIDENCE;
     ed_idx++;

   } /* if (count) */
           
 } /* for (i = 0; i < 2; i++) */

 if (ed_idx)
 {
   num_sublps = 1;
   sublps_info.num_edges = ed_idx;
   sublps_info.ed_info = ed_info;
 }
 
 if (num_sublps)
 {
   num_lps = 1;
   lps_info.num_sublps = num_sublps;
   lps_info.sublps_info = &sublps_info;
   lps_info.match_end_pts_eds = FALSE;
 }

 lift_info.sf_GRid = sf_GRid;
 lift_info.lift_operation = EMS_LIFT_VERTEX;
 lift_info.active_constraints = active_constraints;
 lift_info.num_lps = num_lps;
 lift_info.num_ed_infos = 2;
 lift_info.lps_info = &lps_info;

 /* Now all of the information to modify the surface as
  * well as to construct new surfaces has been collected.
  * Time to perform the operation.
  */

 OM_stat = om$send (msg = message EMSsf_lift.EMlift_execute (
                    &mthd_stat, md_env, construct_list, &lift_info,
                    EMS_DO_DISPLAY, NULL, NULL),
                  targetid = my_id);
 EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

wrapup:

 EMWRAPUP (*EMmsg, OM_stat,"In EMSsf_lift : EMlift_vert");
 return (OM_stat);

}

end implementation EMSsf_lift;
