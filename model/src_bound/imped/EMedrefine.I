/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method computes the exact intersection by curve surface 
interation at an estimated intersection point. 

Assumption
	The implemetation in this file is assuming that the edge geometry
is exact and therefore its model space counterpart can be used to find an
exact point by iteration. This implemetation is inherited by the natural
edge and the bs edge for whom this assumption holds. Linear edge overides
and does three surface iteration since its geometry is not exact to begin
with.

Arguments

For all input arrays following is the index convention -
0 -  info pertaining to this edge, its surface.
1 -  info pertaining to common edge, its surface.
2 -  info pertaining to the new intersection passing through this edge.

surf_data	input	dataselect pointer for surfaces.
env		input   environment for the surfaces. Required 
			to get surface geometry and the parametric tolerance
			If both these are supplied , then the can be NULL.
tol		input   parametric tolerances for the surfaces. 
			If NULL, then the method tries to get it from the 
			surface.
uv_approx	input   pointer to parametric values for the estimated 
			intersection. If NULL 
			the xyz estimated point is used to compute the
			estimated parameter. The estimation is required for
			intersection surface , i.e uv_approx[2].
xyz_int_approx  input	pointer to 3d estimated intersection point. Required 
			to compute the curve parameter in model space.
uv_exact	output	pointer for output space to return parametric values
			on intersection surface and this surface for the 
			exact intersection point. If not interested pass 
			corresponding pointer as NULL.
xyz_int_exact	output  Just what it says. Not interested ? NULL : non NULL;
my_edpar	input	Ignored for a bs edge because the bs edge
			geometry is never changed.
comm_edpar	input	Info about the estimated parameter on the common
			edge. It is used to introduce the exact uv into
			the common edge. This is not attemted if this argument
			is NULL.
me_refined	output	Always FALSE.
comm_refined	output	TRUE if a point was introduced in common edge. If the
			exact value is within tolerancefrom either of the
			end points of the span where it occured, then it
			is not introduced in the edge.
me_hole		output	Always FALSE.
me_hole		output  TRUE if the edge that was refines belonged to a C
			loop. Valid only if the corresponding refined flag
			is TRUE. This flags conveys the information that
			a hole was refined and thus may warrant retrimming
			of intersection data.
part		input	Used to get the appropriate xyz geom.
			
Return Values
	EMS_S_Success		All went well
	EMS_I_NoSolution	exact intersection could not be computed
				because of some screw up. All errors are
				trapped and return code set to this upon
				exit.
	EMS_I_ParOutOfBounds	The exact intersection point was off the
				common surface by more than dist tol.
	EMS_I_NoCommonEdge	The linear edge had no common edge. Therefore
				no common edge related processing has been
				done. This return code is mutually exclusive
				with EMS_I_ParOutOfBounds.
				
History
	SM	06-Apr-88	Design and creation.
	SM	25-May-88	Send partedinfo to get part of the xyz geom
				if necessary.
	SM	03-Jun-88	Refine the common edge if possible.
	SM	03-Oct-88	When returning the uv parameters for my surface
				and common surface (these are not returned
				by BScvsf_iter() directly), make sure there
				is no jump in parametric space for
				closed surfaces if the parameter lies along
				the seam.
	SM	10-Jan-89	The exact point obtained on my surf and
				comm surf after mdistptsf could have moved
				away from the edge, due to math tolerancing
				or the warpness of the surface among other
				reasons. This movement should be minimal
				at worst. For linear edges this would
				not pose a problem since the edge itself
				would have been modified to contain the
				point. But natural/bs edges being invariant, 
				a gap may result if the intersection is
				modified wrt this moved point. So project
				the point on the edge and return the projected
				point as the exact point. This will
				ensure movement (for refinement) along the
				edge and never away from the edge.
	SM	05-Mar-89	Added return code EMS_I_NoCommonEdge

        NP      05-Feb-92	In the calculation of the approx/exact uv points
                            	using the math function "BSmdistptsf", there was
                                a problem with seam edges. If the me and my
				common edge were seam edges, then the uvpoints
				returned by math might be on the wrong seam. So,
				a "EMptproject" method is called to move the 
      				point to the right seam.
				This modification makes sense only for natural
				edges, since seam edges could not be any other
                                type.

         Sudha  06/04/93        modified to include BSprototype header files

*/
class implementation EMSedge;

#include "EMS.h"
#ifndef DEBUG
#define DEBUG	0
#endif

#if DEBUG
#include <stdio.h>
#endif

#include "OMmacros.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emssfint.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "bsmdistptsf.h"
#include "bsmdistptcv.h"
#include "bsdistptpt.h"
#include "bscvsf_iter.h"
#include "bscvkttol2.h"

%safe
static  void EMno_jump();
%endsafe

extern OMuword OPP_EMSlinedge_class_id;

method EMrefine_points( IGRlong *EMmsg;
			struct EMSdataselect *surf_data[3];
			struct GRmdenv_info  *env[3];
			struct EMSpartolbasis *tol[3];
			IGRdouble	      *uv_approx[3], 
					      *xyz_int_approx, 
					      *uv_exact[3], 
					      *xyz_int_exact;
			struct EMSsfintedpar  *my_edpar, *comm_edpar;
			IGRboolean	      *me_refined, *comm_refined, 
					      *me_hole, *comm_hole;
			struct EMSpartedinfo  *part)
{
  IGRlong			sts, rc;
  struct IGRbsp_surface		*my_surf, *int_surf, *comm_surf;
  struct IGRbsp_curve		my_xyz_geom;
  IGRint			uv_size, tolsize;
  OMuint                        count;
  struct EMSdataselect		loc_my_surf_data, loc_int_surf_data, 
				loc_comm_surf_data, 
				*my_surf_data, *int_surf_data, *comm_surf_data;
  struct GRid			my_srfid, int_srfid, comm_srfid;
  struct EMSpartolbasis		loc_int_tol, *int_tol, *comm_tol, loc_comm_tol,
				loc_my_tol, *my_tol;
  IGRdouble			*int_uv_approx, *int_uv_exact, *my_uv_exact, 
				*comm_uv_exact, *my_uv_approx, *comm_uv_approx;
  IGRdouble			loc_exact_uv[2], loc_approx_uv[2], curve_tol, 
				loc_xyz_exact[3], loc_comm_uv[2], 
				base_point[3], dist, approx_tpar, exact_tpar, 
				loc_my_uv_approx[2], loc_comm_uv_approx[2];
  struct GRmdenv_info		*my_env, *int_env, *comm_env;
  IGRboolean			isuccess, status, reverse,
				loc_me_refined, loc_comm_refined, 
				point_off_comm_surf = FALSE, 
				already_exact = FALSE;
  IGRshort			num_pars, num_intvls;
  IGRdouble			*pars, *intpars, xyzlentol;
  GRobjid			user_id, comm_id = NULL_OBJID;
  IGRushort		user_props, comm_ed_props;
  OM_S_CHANSELECT		to_common_edge;
  OM_S_OBJECT_LINKAGE		comm;
  struct EMSproj_info           proj_pt_info;
  IGRdouble			temp_uv_pt[2];

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  my_xyz_geom.poles = NULL;
  my_xyz_geom.knots = NULL;
  my_xyz_geom.weights = NULL;
  pars = intpars = NULL;
  if(!me_refined) me_refined = &loc_me_refined;
  if(!comm_refined) comm_refined = &loc_comm_refined;
  *me_refined = FALSE;
  *comm_refined = FALSE;
  if(me_hole) *me_hole = FALSE;
  if(comm_hole) *comm_hole = FALSE;

  if(part)
   {
    user_id = part->edid;
    user_props = part->edprops;
    sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
   }
  else
   {
    user_id = my_id;
    user_props = ME.EMSedge->ed_props;
    to_common_edge.type = OM_e_addr;
    to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;
   }

  my_surf_data = (struct EMSdataselect *) surf_data[0];
  comm_surf_data = (struct EMSdataselect *) surf_data[1];
  int_surf_data = (struct EMSdataselect *) surf_data[2];
  
  my_env = (struct GRmdenv_info *) env[0];
  comm_env = (struct GRmdenv_info *) env[1];
  int_env = (struct GRmdenv_info *) env[2];

  my_tol = (struct EMSpartolbasis *) tol[0];
  comm_tol = (struct EMSpartolbasis *) tol[1];
  int_tol = (struct EMSpartolbasis *) tol[2];

  my_uv_approx = (IGRdouble *) uv_approx[0];
  comm_uv_approx = (IGRdouble *) uv_approx[1];
  int_uv_approx = (IGRdouble *) uv_approx[2];

  my_uv_exact = (IGRdouble *) uv_exact[0];
  comm_uv_exact = (IGRdouble *) uv_exact[1];
  int_uv_exact = (IGRdouble *) uv_exact[2];
  
  my_surf = comm_surf = int_surf = NULL;
  my_srfid.osnum = comm_srfid.osnum = int_srfid.osnum = OM_Gw_current_OS;
  my_srfid.objid = comm_srfid.objid = int_srfid.objid = NULL_OBJID;
  loc_my_surf_data.datatype = EMSdata_null;
  loc_comm_surf_data.datatype = EMSdata_null;
  loc_int_surf_data.datatype = EMSdata_null;

  EMerr_hndlr(!int_surf_data, *EMmsg, EMS_E_InvalidArg, wrapup);

  /* If the edge is degenerate then exit.
  */
  EMerr_hndlr(user_props & EMED_DEGENERATE, *EMmsg, EMS_I_NoSolution, wrapup);

  BSEXTRACTPAR(&rc, BSTOLLENVEC, xyzlentol);
  uv_size = 2*sizeof(IGRdouble);

  /* Obtain the common edge */
  count = 0;
  sts = om$get_channel_objects(objid = user_id, 
			p_chanselect = &to_common_edge, 
			list = &comm, size = 1, count = &count);
  if(count) comm_id = comm.S_objid;

  if (!IF_NULL_OBJID(comm_id))
  {  /* the properties will be used later to check if this is a SEAM edge
      * primarily. Look for calls to "BSmdistptsf".
      */
     sts = om$send (msg = message EMSedge.EMget_props (EMmsg, &comm_ed_props),
                            targetid = comm_id);
     if(!(1&*EMmsg&sts)) goto wrapup;
                             

  }
  /* Get the surface and the tolerance.
  */
  sts = EMsm_get_surface_tolerance(EMmsg, my_surf_data, &loc_my_surf_data, 
			my_tol, &loc_my_tol, my_env, user_id, &my_srfid);
  if(!(1&*EMmsg&sts)) goto wrapup;

  sts = EMsm_get_surface_tolerance(EMmsg, int_surf_data, &loc_int_surf_data, 
		int_tol, &loc_int_tol, int_env, NULL_OBJID, &int_srfid);
  if(!(1&*EMmsg&sts)) goto wrapup;

  /* If path to the surface is not available and if surface geometry is not
     supplied, there ain't much to be done hanging around here.
  */
  EMerr_hndlr((loc_my_surf_data.datatype != EMSdata_surface) &&
      IF_NULL_OBJID(loc_my_surf_data.data.object[0].objid), *EMmsg, 
				EMS_I_NoSolution, wrapup);
				
  EMerr_hndlr((loc_int_surf_data.datatype != EMSdata_surface) &&
      IF_NULL_OBJID(loc_int_surf_data.data.object[0].objid), *EMmsg, 
				EMS_I_NoSolution, wrapup);
				
  sts = EMsm_get_surface_geom(EMmsg, &loc_my_surf_data, my_env, &my_surf);
  if(!(1&sts&*EMmsg)) goto wrapup;

  sts = EMsm_get_surface_geom(EMmsg, &loc_int_surf_data, int_env, &int_surf);
  if(!(1&sts&*EMmsg)) goto wrapup;

  if(!IF_NULL_OBJID(comm_id))
   {
    sts = EMsm_get_surface_tolerance(EMmsg, comm_surf_data, 
			&loc_comm_surf_data, comm_tol, &loc_comm_tol, 
			comm_env, comm_id, &comm_srfid);
    if(!(1&*EMmsg&sts)) goto wrapup;
    if(user_props & EMED_SEAM)
      comm_surf = (struct IGRbsp_surface *) my_surf;
    else
     {
      EMerr_hndlr((loc_comm_surf_data.datatype != EMSdata_surface) &&
               IF_NULL_OBJID(loc_comm_surf_data.data.object[0].objid), *EMmsg, 
				EMS_I_NoSolution, wrapup);
      sts = EMsm_get_surface_geom(EMmsg, &loc_comm_surf_data, comm_env, 
				&comm_surf);
      if(!(1&sts&*EMmsg)) goto wrapup;
     }
   }

  if(int_uv_approx) OM_BLOCK_MOVE(int_uv_approx, loc_approx_uv, uv_size);
  else
   {
     status = BSmdistptsf( &rc, int_surf, xyz_int_approx, &loc_approx_uv[0], 
			  &loc_approx_uv[1], base_point, &dist);
     if(rc != BSSUCC) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
   }

  /* Approx uv on my surface and the common edge's surface are required if
     the surface is closed. If the point is along the seam, then the
     exact xyz point can give us the uv parameter on the other seam. So a
     check needs to be done before returning the exact uv parameter on
     my surface and the common surface. These parameters are not
     returned by BScvsf_iter() directly.
  */
  if(my_uv_approx) OM_BLOCK_MOVE(my_uv_approx, loc_my_uv_approx, uv_size);
  else if(my_surf)
   {
    status = BSmdistptsf( &rc, my_surf, xyz_int_approx, &loc_my_uv_approx[0],
			  &loc_my_uv_approx[1], base_point, &dist);
    if(!status) {*EMmsg = EMS_I_NoSolution; goto wrapup;}

    /* IF by chance I am a SEAM edge, then the above function MIGHT return a
     * point on the wrong seam, corresponding to the same model space point
     * "xyz_int_approx". To get the correct point therefore, project the point
     * "loc_my_uv_approx[0,1]" onto myself. The output from here still has to 
     * be located in the "loc_my_uv_approx" array which will be used down below.
     */

    if (user_props & EMED_SEAM)
    {  temp_uv_pt[0] = loc_my_uv_approx[0];
       temp_uv_pt[1] = loc_my_uv_approx[1];
       sts = om$send(msg = message EMSedge.EMptproject(EMmsg, temp_uv_pt, 1,
                                &proj_pt_info, NULL, &loc_my_tol),
                                targetid = user_id);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);
      
       loc_my_uv_approx[0] = proj_pt_info.proj_pt[0];
       loc_my_uv_approx[1] = proj_pt_info.proj_pt[1];
    }
   }

  if(comm_uv_approx) OM_BLOCK_MOVE(comm_uv_approx, loc_comm_uv_approx, 
					uv_size);
  else if(comm_surf)
   {
    status = BSmdistptsf( &rc, comm_surf, xyz_int_approx, 
		&loc_comm_uv_approx[0], &loc_comm_uv_approx[1], base_point, 
		&dist);
    if(!status) {*EMmsg = EMS_I_NoSolution; goto wrapup;}

     /* IF by chance I am a SEAM edge, then so is the common edge and then the 
      * above function MIGHT return a point on the wrong seam, corresponding
      * to the same model space point "xyz_int_approx". To get the correct 
      * point therefore, project the point "loc_comm_uv_approx[0,1]" onto the
      * common edge. The output from here still has to be located in the 
      * "loc_comm_uv_approx" array which will be used down below. Since we are
      * talking about the my surface, we use my tolerance. 
     */

    if ((comm_ed_props & EMED_SEAM) && !IF_NULL_OBJID(comm_id))
    {  temp_uv_pt[0] = loc_comm_uv_approx[0];
       temp_uv_pt[1] = loc_comm_uv_approx[1];
       sts = om$send(msg = message EMSedge.EMptproject(EMmsg, temp_uv_pt, 1,
                                &proj_pt_info, NULL, &loc_my_tol),
                                targetid = comm_id);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);

       loc_comm_uv_approx[0] = proj_pt_info.proj_pt[0];
       loc_comm_uv_approx[1] = proj_pt_info.proj_pt[1];
    }
   }
 /* Get my model space geometry
  */
  reverse = user_props & EMED_REVERSED;
  sts = om$send(msg = message EMSedge.EMget_bcxyz_geom
			(EMmsg, my_env, NULL, my_surf, 0, MAXINT, reverse, 
			 part, &my_xyz_geom), targetid = my_id);
  if(!(1&*EMmsg&sts)) goto wrapup;
  if(!my_xyz_geom.rational) my_xyz_geom.weights = NULL;

  /* Get the approx tpar on the model space geometry.
  */
  BSmdistptcv(&my_xyz_geom, xyz_int_approx, &num_intvls, &num_pars, 
	      &pars, &dist, &intpars, &rc);
  if(rc != BSSUCC) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
  if(!num_pars) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
  approx_tpar = pars[0];

  BScvkttol2(my_xyz_geom.order, my_xyz_geom.knots, my_xyz_geom.num_poles, 
	     my_xyz_geom.poles, my_xyz_geom.weights, &curve_tol, &rc);
  if(rc != BSSUCC) {*EMmsg = EMS_I_NoSolution; goto wrapup;}

  BScvsf_iter(&my_xyz_geom, int_surf, approx_tpar, loc_approx_uv[0], 
	      loc_approx_uv[1], curve_tol, loc_int_tol.tol, &exact_tpar, 
	      loc_exact_uv, &loc_exact_uv[1], loc_xyz_exact, &isuccess, &rc);
  EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
  EMerr_hndlr(!isuccess, *EMmsg, EMS_I_NoSolution, wrapup);
  if( (dist = BSdistptpt(&rc, loc_xyz_exact, xyz_int_approx)) < xyzlentol)
   already_exact = TRUE;

  /* Return the exact parametric values for all the surfaces involved.
   * Also try to refine the common edge if possible.
   */

  if(my_uv_exact)
   {
    struct EMSproj_info		proj_info;

    if(already_exact && (my_uv_approx || my_surf))
     OM_BLOCK_MOVE(loc_my_uv_approx, my_uv_exact, uv_size);
    else if(my_surf)
     {
      status = BSmdistptsf( &rc, my_surf, loc_xyz_exact, &my_uv_exact[0], 
			  &my_uv_exact[1], base_point, &dist);
      if(rc != BSSUCC) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
	
      /* Do the seam check to make sure we have not jumped in parametric
         space.
      */
      EMno_jump(my_surf, loc_my_uv_approx, my_uv_exact);

      /* The uv point obtained may have moved away from the edge.
	 Project it onto the edge to make sure it lies on the edge. This
	 will ensure the movement of the refined point to always be along
	 the bs/natural edge and never away from it. This problem does not
	 arise for a linear edge because the linear edge itself is
	 modified to contain the refined point.
      */
      sts = om$send(msg = message EMSedge.EMptproject(EMmsg, my_uv_exact, 1, 
				&proj_info, NULL, &loc_my_tol), 
				targetid = user_id);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);
      OM_BLOCK_MOVE(proj_info.proj_pt, my_uv_exact, uv_size);
      if(my_edpar)
       {
   	OM_BLOCK_MOVE(&proj_info.param, &my_edpar->edgepar, 
					sizeof(struct EMSedgebound));
   	if(proj_info.location != EMScvint_unknown)
		my_edpar->intloc = proj_info.location;
   	my_edpar->edgeid = user_id;
       }
     }
    else {*EMmsg = EMS_I_NoSolution; goto wrapup;}
   }

  if(!IF_NULL_OBJID(comm_id))
   {
    if(already_exact && (comm_uv_approx || comm_surf))
     OM_BLOCK_MOVE(loc_comm_uv_approx, loc_comm_uv, uv_size);
    else
     {
      status = BSmdistptsf( &rc, comm_surf, loc_xyz_exact, &loc_comm_uv[0], 
			  &loc_comm_uv[1], base_point, &dist);
      if(rc != BSSUCC) {*EMmsg = EMS_I_NoSolution; goto wrapup;}

    /* We do the same projection onto the edge (that we did before  while 
     * calculating the approx. uv pointt) just in case math has returned the
     * point on the wrong seam. For myself, the check is unconditionally done 
     * above, for the reasons stated above. But for the common edge, we only 
     * do it if it is a seam edge, for now. We use the tolerance for my surface,
     * since it is a seam edge.
     */
    if (comm_ed_props & EMED_SEAM)
    {  temp_uv_pt[0] = loc_comm_uv[0];
       temp_uv_pt[1] = loc_comm_uv[1];
       sts = om$send(msg = message EMSedge.EMptproject(EMmsg, temp_uv_pt, 1,
                                &proj_pt_info, NULL, &loc_my_tol),
                                targetid = comm_id);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);

       loc_comm_uv[0] = proj_pt_info.proj_pt[0];
       loc_comm_uv[1] = proj_pt_info.proj_pt[1];
    }
      if( (dist = BSdistptpt(&rc, loc_xyz_exact, base_point)) > xyzlentol)
       point_off_comm_surf = TRUE;

      /* Do the seam check to make sure we have not jumped in parametric
         space.
      */
      EMno_jump(comm_surf, loc_comm_uv_approx, loc_comm_uv);
     }
   }
	
  if(comm_edpar && !IF_NULL_OBJID(comm_id))
   {
    struct EMSdataselect	junk;

    junk.datatype = EMSdata_surface;
    junk.data.surface = (struct IGRbsp_surface *) comm_surf;

    sts = EMsm_insert_point_in_edge(EMmsg, comm_edpar, &loc_comm_tol, comm_id, 
		loc_comm_uv, comm_hole, comm_refined, &comm_env->matrix_type, 
		comm_env->matrix, &junk);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);

#if DEBUG
      if(*EMmsg == EMS_S_Success)
       fprintf(stderr, "Common edge %d of edge %d REFINED\n",comm_id, user_id);
#endif
   }

  if(comm_uv_exact && !IF_NULL_OBJID(comm_id)) 
    OM_BLOCK_MOVE(loc_comm_uv, comm_uv_exact, uv_size);
  if(int_uv_exact) OM_BLOCK_MOVE(loc_exact_uv, int_uv_exact, uv_size);
  if(xyz_int_exact) OM_BLOCK_MOVE(loc_xyz_exact, xyz_int_exact, 
				  3*sizeof(IGRdouble));
				
  tolsize = sizeof(struct EMSpartolbasis);
  if(comm_tol && !IF_NULL_OBJID(comm_id)) 
    OM_BLOCK_MOVE(&loc_comm_tol, comm_tol, tolsize);
  if(int_tol) OM_BLOCK_MOVE(&loc_int_tol, int_tol, tolsize);
  if(my_tol) OM_BLOCK_MOVE(&loc_my_tol, my_tol, tolsize);

wrapup:
 if( (loc_my_surf_data.datatype == EMSdata_object) && my_surf)
   free(my_surf);
 if( (loc_comm_surf_data.datatype == EMSdata_object) && comm_surf &&
			(comm_surf != my_surf))
   free(comm_surf);
 if( (loc_int_surf_data.datatype == EMSdata_object) && int_surf)
   free(int_surf);
 if(my_xyz_geom.poles) free(my_xyz_geom.poles);
 if(my_xyz_geom.knots) free(my_xyz_geom.knots);
 if(my_xyz_geom.weights) free(my_xyz_geom.weights);
 if(pars) free(pars);
 if(intpars) free(intpars);

 if(!(1&*EMmsg&sts))
  {
   *EMmsg = EMS_I_NoSolution;
   sts = OM_S_SUCCESS;
  }

 if((*EMmsg != EMS_I_NoSolution) && IF_NULL_OBJID(comm_id)) 
   *EMmsg = EMS_I_NoCommonEdge;
 else if((*EMmsg != EMS_I_NoSolution) && point_off_comm_surf) 
   *EMmsg = EMS_I_ParOutOfBounds;
 else if(*EMmsg != EMS_I_NoSolution) *EMmsg = EMS_S_Success;

 return(sts);
}

#define PAR_DELTA	0.5
%safe
#include <math.h>
%endsafe

static void EMno_jump(surf, uv_approx, uv_exact)
struct IGRbsp_surface	*surf;
IGRdouble		*uv_approx, *uv_exact;
{
	
 /* Is there a jump? */
 if(surf->u_phy_closed && (fabs(uv_approx[0] - uv_exact[0]) > PAR_DELTA))
  {
	
   /* if there is a jump, bring the parameter to the correct seam.
   */
   if(fabs(uv_exact[0] - 0.0) < fabs(uv_exact[0] - 1.0))
    uv_exact[0] = 1.0;
   else uv_exact[0] = 0.0;
  }

 if(surf->v_phy_closed && (fabs(uv_approx[1] - uv_exact[1]) > PAR_DELTA))
  {
	
   /* if there is a jump, bring the parameter to the correct seam.
   */
   if(fabs(uv_exact[1] - 0.0) < fabs(uv_exact[1] - 1.0))
    uv_exact[1] = 1.0;
   else uv_exact[1] = 0.0;
  }

}

end implementation EMSedge;
