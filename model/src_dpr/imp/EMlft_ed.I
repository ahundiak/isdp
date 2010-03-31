/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsf_lift;

#include "EMS.h"
#include <stdio.h>
%safe
#include <math.h>       /* sqrt */
%endsafe
#include "emsmacros.h"
#include "OMmacros.h"

#define inst_tbl     ME.EMSsf_lift->move_info[entry]

from EMSedge	import	EMget_sf_edges, EMendpts, EMget_props,
                        EMget_props_type;
from EMSsubbs   import  EMpartolbasis;

method EMlift_edge (
    IGRlong                           *EMmsg;
    struct    GRmd_env                *md_env;
    struct    GRvg_construct          *construct_list;
    IGRpoint                          from_pt;
    IGRpoint                          to_pt;
    struct    GRid                    sf_GRid;
    struct    GRid                    ed_GRid;
    IGRushort                         active_constraints;
    struct    EMSlft_cnstrnt_info     *constraint_info )

/*

Notes
	This method does the preprocessing for lift edge
	operation. It builds up the instruction table of
	the instance data. After constructing the instruction
	table and filling the rest of the instance data
	calls the EMlift_execute method.

History  RC	10/30/87	  Creation Date
         RC 03/01/88      Modified arguments and code to
                          include constraints.
*/

{
  struct GRid                 shed_GRids[2];		
  struct EMSlft_ed_info       ed_info[3];
  struct EMSlft_slp_info      sublps_info[2];
  struct EMSlft_lp_info       lps_info;
  struct EMSlft_info          lift_info;
  OM_S_CHANSELECT             cm_ed_chan;
  IGRdouble                   vt_pt[4], uv_pts[8], par_tol, 
                              lp_bpt[2], lp_ept[2];
  OMuint                      blksize, count;
  IGRlong                     mthd_stat;
IGRlong   OM_stat;
  IGRint                      num_sh_edges, num_uv_pts, entry, i, 
                              ed_idx, cur_sublp, num_sublp_eds, 
                              cur_sublp_ed_idx, num_lps = 0;
  GRobjid                     lp_first_ed_id, lp_last_ed_id;
  IGRboolean                  world_flag, sh_eds_seam;
  IGRuchar            ed_cv_type;
  IGRushort           ed_props;
  void                        EMmake_poles_on_surface();

OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;
num_uv_pts = 0;
blksize = 4 * sizeof(IGRdouble);

/*
 * get all of the edges of the surface sharing the edge under 
 * consideration at its end points.
 */

OM_stat = om$send (msg = message EMSedge.EMget_sf_edges(
                     &mthd_stat, 0, shed_GRids, &num_sh_edges),
                   targetid = ed_GRid.objid, targetos = ed_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);


OM_stat = om$send (msg = message EMSedge.EMendpts (
                    &mthd_stat, &vt_pt[0], &vt_pt[2], NULL, NULL, NULL),
	           targetid = ed_GRid.objid, targetos = ed_GRid.osnum);
EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

OM_SET_DIMENSION (ME.EMSsf_lift->move_info, (num_sh_edges+1) );

/* 
 * add an entry for the edge under consideration
 */

entry = 0;
inst_tbl.move_operation = EMS_MOVE_LIN_EDGE;
OM_BLOCK_MOVE (vt_pt, inst_tbl.params.end_pts, blksize);

/*
 * There should be a pole at each end point of the edge.
 * This can be trivially found by checking EMED_COMPATIBLE
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
 
/*
 * There will be at most two edges (excluding degenerate) sharing 
 * the edge under considertions along its end points.
 * One at the begin pt and the other at the end point.
 * Since the method EMget_sf_edg returns the edges
 * in a particular order i.e., first edge is the one
 * sharing the begin point and the second edge sharing
 * the end point. With the help of this information
 * the instructions table can be filled correctly.
 */

for (i =  0; i < num_sh_edges; i++)
{
    /* get the end pt(u,v) of each of the sharing edges.
     */

    OM_stat = om$send (msg = message EMSedge.EMendpts (
                         &mthd_stat, (i == 0) ? &vt_pt[2] : vt_pt, 
                         (i == 0) ? vt_pt : &vt_pt[2], NULL, NULL, NULL),
                       targetid = shed_GRids[i].objid, 
                       targetos = shed_GRids[i].osnum);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

    /* 
     * add this edge to the move instruction set
     */
	
    ++entry;    
    inst_tbl.move_operation = EMS_MOVE_INT_PRP_EDGE;
    OM_BLOCK_MOVE (vt_pt, inst_tbl.params.end_pts, blksize);
	
    /*
     * Trivially check if the edge has a pole at its end points.
     */

     OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                        &ed_props),
                      targetid = shed_GRids[i].objid, 
                      targetos = shed_GRids[i].osnum);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     if (!(ed_props & EMED_COMPATIBLE))
     { 
       OM_BLOCK_MOVE (&vt_pt[2], &uv_pts[num_uv_pts*2], 
                       sizeof(IGRdouble)*2);
       num_uv_pts++;
     }
     
} /* for (i =  0; i < num_sh_edges; i++) */

ME.EMSsf_lift->num_instructions = num_sh_edges + 1;

for (i = 0; i < 3; i++)
	me->lift_vector[i] = to_pt[i] - from_pt[i];

me->operation_type = EMS_LIFT_EDGE;

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
 * The information needed to modify the surface has been
 * gathered. Now collect the information to construct
 * the lifted surfaces.
 *
 * In case there are two edges sharing the edge to be lifted
 * and both of them are seam edges, both edges will be moved.
 * Since both edges are moved, there will be no gap created 
 * in the model. Thus, no new surfaces should be created for the
 * sharing edges. On the other hand, if only one of the two
 * sharing edges is a seam edge, a surface should be constructed
 * for the seam edge.
 */

if (num_sh_edges == 2)
{
 sh_eds_seam = TRUE;
 for (i = 0; i < 2; i++)
 {
   OM_stat = om$send (msg = message EMSedge.EMget_props (
                      &mthd_stat, &ed_props),
			         targetid = shed_GRids[i].objid);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
 
   if (!(ed_props & EMED_SEAM))
   {
     sh_eds_seam = FALSE;   break;
   } 

 } /* for (i = 0; i < 2; i++) */

 if (sh_eds_seam) num_sh_edges = 0;

} /* if (num_sh_edges == 2) */

/*

for (i = num_sh_edges-1; i >= 0; i--)
{
  OM_stat = om$send (msg = message EMSedge.EMget_props (
                      &mthd_stat, &ed_props),
			         targetid = shed_GRids[i].objid);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  if (ed_props & EMED_SEAM)
  {
	for (j = i+1; j < num_sh_edges; j++)
	  shed_GRids[j-1] = shed_GRids[j];
	num_sh_edges--;

  }
  
}

*/

/*
 * Since it is a surface/composite surface, it may be possible that
 * some of the edges donot have a common edge. Such edges
 * will not be used in the lift operation. Thus
 * these edges should be filtered out.
 */

for (i = 0; i < num_sh_edges; i++)
{
  ed_idx = (i == 0) ? 0 : 2;
  ed_info[ed_idx].ed_GRid = shed_GRids[i];
  ed_info[ed_idx].ed_sf_type = EMS_C_RULED_SF;
  ed_info[ed_idx].ed_cv_type = NULL;
  ed_info[ed_idx].ed_constraint_type = NULL;
  if (active_constraints & EMS_LC_AUTO_COINCIDENCE)
      ed_info[ed_idx].ed_constraint_type |= EMS_LC_AUTO_COINCIDENCE;

} /* for (i = 0; i < num_sh_edges; i++) */

/*
 * collect the information for the edge to be lifted
 */

OM_stat = om$send (msg = message EMSedge.EMget_props_type (
			        &mthd_stat, NULL, &ed_cv_type),
		           targetid = ed_GRid.objid, 
                   targetos = ed_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError, wrapup);


ed_idx = num_sh_edges ? 1 : 0;
ed_info[ed_idx].ed_GRid = ed_GRid;
ed_info[ed_idx].ed_sf_type = EMS_C_PROJECTED_SF;
ed_info[ed_idx].ed_cv_type = ed_cv_type;
ed_info[ed_idx].ed_constraint_type = NULL;
if (active_constraints & EMS_LC_AUTO_COINCIDENCE)
      ed_info[ed_idx].ed_constraint_type |= EMS_LC_AUTO_COINCIDENCE;

/*
 * Now all of the possible edges to be used in constructing
 * the lifted surfaces have been collected in the loop direction.
 * Next job is to take out the edges which do not
 * have any common edges. If there are any such edges, the
 * loop needs to be divided into subloops.
 */

OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

cur_sublp = 0;
ed_idx = 0;
num_sublp_eds = 0;

do
{
   OM_stat = om$get_channel_count (osnum = ed_info[ed_idx].ed_GRid.osnum,
                      objid = ed_info[ed_idx].ed_GRid.objid, 
                      p_chanselect = &cm_ed_chan, count = &count);
   EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

   if (count)
   {
     if (!num_sublp_eds && !cur_sublp)
       lp_first_ed_id = ed_info[ed_idx].ed_GRid.objid;
     if (!num_sublp_eds) cur_sublp_ed_idx = ed_idx;
     num_sublp_eds++;
   }

   else if (num_sublp_eds )
   {
       sublps_info[cur_sublp].num_edges = num_sublp_eds;
       sublps_info[cur_sublp++].ed_info = &ed_info[cur_sublp_ed_idx];
       lp_last_ed_id = ed_info[ed_idx-1].ed_GRid.objid;
       num_sublp_eds = 0;
   }
       
   ed_idx++;     

} while (ed_idx < (num_sh_edges+1) );

if (num_sublp_eds )
{
   sublps_info[cur_sublp].num_edges = num_sublp_eds;
   sublps_info[cur_sublp++].ed_info = &ed_info[cur_sublp_ed_idx];
   lp_last_ed_id = ed_info[ed_idx-1].ed_GRid.objid;
}


if (cur_sublp)
{
  num_lps = 1;
  lps_info.num_sublps = cur_sublp;
  lps_info.sublps_info = sublps_info;
  
  /*
   * check if the edges at the end points of the loop
   * need to have edge matching performed.
   */

  OM_stat = om$send (msg = message EMSedge.EMendpts (
                      &mthd_stat, lp_bpt, NULL, NULL, NULL, 
                      NULL),
	                 targetid = lp_first_ed_id);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  OM_stat = om$send (msg = message EMSedge.EMendpts (
                      &mthd_stat, NULL, lp_ept, NULL, NULL, 
                      NULL),
	                 targetid = lp_last_ed_id);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
 
  world_flag = TRUE;
  OM_stat = om$send (msg = message EMSsubbs.EMpartolbasis (&mthd_stat,
                      &md_env->md_env.matrix_type, md_env->md_env.matrix,
                      &world_flag, FALSE, &par_tol),
                     targetid = sf_GRid.objid);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  lps_info.match_end_pts_eds = 
     ( sqrt( EM2ddistptpts(lp_bpt, lp_ept) ) <= par_tol) ? TRUE : FALSE;
    
}

lift_info.sf_GRid = sf_GRid;
lift_info.lift_operation = EMS_LIFT_EDGE;
lift_info.active_constraints = active_constraints;
lift_info.num_lps = num_lps;
lift_info.num_ed_infos = num_sh_edges + 1;
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

EMWRAPUP (*EMmsg, OM_stat,"In EMSsf_lift : EMlift_edge");

return (OM_stat);
}

end implementation EMSsf_lift;
