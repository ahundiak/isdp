/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method computes the exact intersection by three surface 
interation at an estimated intersection point. It also introduces the exact
parameter in its geometry if proper information is passed in to it.

Arguments
For all input arrays following is the index convention -
0 -  info pertaining to this edge, its surface.
1 -  info pertaining to common edge, its surface.
2 -  info pertaining to the new intersection edge, its surface.

surf_data	input	an array of three pointers, each pointing to a
			dataselect structure for a surface. 
			The three surface geometries are what
			is really required. If objects are passed then
			the proper environment should be passed in (see below)
			for the method to go get the geometry from the
			surface. If a particular pointer is NULL, then
			the method makes an attempt to get to that particular
			surface through the its edge.
env		input   environment for each of the three surfaces. Required 
			to get surface geometries and the parametric tolerances
			for every surface. If both these are supplied
			for a surface, then the environment pointer for that
			surface can be NULL.
tol		input   parametric tolerances for each of the three surfaces. 
			If NULL for any surface, then the method tries to
			get it from the surface.
uv_approx	input   pointers to parametric values for the estimated 
			intersection, on each surface. If NULL for a surface
			the xyz estimated point is used to compute the
			estimated uv for that surface.
xyz_int_approx  input	pointer to 3d estimated intersection point. Required 
			only to compute the estimated uv if not supplied
			for a particular surface. Otherwise can be NULL.
uv_exact	output	pointers for output space to return parametric values
			on each surface for the exact intersection
			point. If not interested pass the corresponding pointer
			as NULL.
xyz_int_exact	output  Just what it says. Not interested ? NULL : non NULL;
my_edpar	input	Info about the estimated parameter on the edge. 
			Required for introducing the exact point into
			the geometry of the edge.
comm_edpar	input	As above, but for common edge.
me_refined	output	TRUE if a point was introduced in this edge. If the
			exact value is within tolerancefrom either of the
			end points of the span where it occured, then it
			is not introduced in the edge.
comm_refined	output	As above, but for common edge.
me_hole		output  TRUE if the edge that was refines belonged to a C
			loop. Valid only if the corresponding refined flag
			is TRUE. This flags conveys the information that
			a hole was refined and thus may warrant retrimming
			of intersection data.
comm_hole	output  As above, but for common edge.
part		input	like all other partedge-full edge methods this argument
			defines the active portion of the edge on which
			the method should operate. If NULL whole edge is
			active.
			
Return Values
	EMS_S_Success		All went well
	EMS_I_NoSolution	exact intersection could not be computed
				because of some screw up. All errors are
				trapped and return code set to this upon
				exit.
	EMS_I_NoCommonEdge	The linear edge had no common edge. Therefore
				no common edge related processing has been
				done. The math function used in such a
				case is BScvsfiter() instead of BScvsf_iter().
History
	SM	10-Mar-88	Design and creation.
	SM	25-Apr-88	Check for self intersection and intersection
				with any other element in the loopset before
				introducing the point in the linear edge
				geometry. Also set the range of the loop
				if the point is introduced.
	SM	04-Oct-88	If EMED_SEAM, three surface iteration is
				not possible. so return
				EMS_I_NoSolution.
	SM	05-Mar-89	If no common edge use BScvsfiter()
				rather than exiting with EMS_I_NoSolution.
				Return code in such cases will be
				EMS_I_NoCommonEdge if nothing else has gone
				wrong.
	SM	14-Nov-89	Worked around the problem when intersection
				occurs along iso curve of my_surf. In such
				cases BScvsfiter() can return any point along
				that iso curve.
        Sudha   07/06/93        modified for BSprototype includes

*/
class implementation EMSlinedge;

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
#include "emsinterdef.h"
#include "bstrpsfiter.h"
#include "bssfeval.h"
#include "bsmdistptsf.h"
#include "bsdistptpt.h"
#include "bscvsfiter.h"

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
  struct IGRbsp_surface		*my_surf = NULL, *comm_surf = NULL, 
				*int_surf = NULL;
  OM_S_CHANSELECT		to_common_edge;
  IGRint			count, uv_size, tolsize, j;
  struct EMSdataselect		loc_my_surf_data, loc_comm_surf_data, 
				loc_int_surf_data, 
				*my_surf_data, *comm_surf_data, 
				*int_surf_data;
  struct GRid			my_srfid, comm_srfid, int_srfid;
  GRobjid			comm_id, user_id;
  struct EMSpartolbasis		loc_my_tol, loc_comm_tol, loc_int_tol, 
				*my_tol, *comm_tol, *int_tol;
  OM_S_OBJECT_LINKAGE		comm;
  struct GRmdenv_info		*my_env, *comm_env, *int_env;
  IGRdouble			*my_uv_approx, *comm_uv_approx, *int_uv_approx,
				*my_uv_exact, *comm_uv_exact, *int_uv_exact, 
				loc_my_uv[2], loc_comm_uv[2], loc_int_uv[2], 
				base_point[3], dist;
  IGRboolean			isuccess, status;
  IGRboolean			loc_me_refined, loc_comm_refined;
  IGRdouble			sav_my_old_uv[2], sav_comm_old_uv[2], 
				loc_xyz_exact[3], lentol;
  IGRushort		user_props = NULL;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  if(!me_refined) me_refined = &loc_me_refined;
  if(!comm_refined) comm_refined = &loc_comm_refined;
  *comm_refined = FALSE;
  *me_refined = FALSE;

  if(part)
   {
    user_id = part->edid;
    sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
    user_props = part->edprops;
   }
  else
   {
    user_id = my_id;
    to_common_edge.type = OM_e_addr;
    to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;
    user_props = ME.EMSedge->ed_props;
   }

  uv_size = 2*sizeof(IGRdouble);

  /* Initialize the pointers(some of them could be NULL)
  */
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
  
  if(user_props & EMED_SEAM)
   {
     *EMmsg = EMS_I_NoSolution;
     goto wrapup;
   }

  loc_int_surf_data = *int_surf_data;

  sts = om$get_channel_objects(objid = user_id, 
			p_chanselect = &to_common_edge, 
			list = &comm, size = 1, count = (OMuint *)&count);
			
  if(!count)
    comm_id = NULL_OBJID;
  else comm_id = comm.S_objid;

  /* Get the surfaces and the tolerances.
  */
  sts = EMsm_get_surface_tolerance(EMmsg, my_surf_data, &loc_my_surf_data, 
			my_tol, &loc_my_tol, my_env, user_id, &my_srfid);
  if(!(1&*EMmsg&sts)) goto wrapup;

  if(!IF_NULL_OBJID(comm_id))
   {
    sts = EMsm_get_surface_tolerance(EMmsg, comm_surf_data, 
		&loc_comm_surf_data, comm_tol, &loc_comm_tol, comm_env, 
		comm_id, &comm_srfid);
    if(!(1&*EMmsg&sts)) goto wrapup;
   }

  sts = EMsm_get_surface_tolerance(EMmsg, int_surf_data, &loc_int_surf_data, 
		int_tol, &loc_int_tol, int_env, NULL_OBJID, &int_srfid);
  if(!(1&*EMmsg&sts)) goto wrapup;

  /* If path to the surface is not available and if surface geometry is not
     supplied, there ain't much to be done hanging around here.
  */
  EMerr_hndlr((loc_my_surf_data.datatype != EMSdata_surface) &&
      IF_NULL_OBJID(loc_my_surf_data.data.object[0].objid), *EMmsg, 
				EMS_I_NoSolution, wrapup);
				
  EMerr_hndlr(!IF_NULL_OBJID(comm_id) && 
	      (loc_comm_surf_data.datatype != EMSdata_surface) &&
      	      IF_NULL_OBJID(loc_comm_surf_data.data.object[0].objid), *EMmsg, 
				EMS_I_NoSolution, wrapup);
				
  EMerr_hndlr((loc_int_surf_data.datatype != EMSdata_surface) &&
      IF_NULL_OBJID(loc_int_surf_data.data.object[0].objid), *EMmsg, 
				EMS_I_NoSolution, wrapup);
							    
  /* Obtain the three surface geometries involved.
  */
  sts = EMsm_get_surface_geom(EMmsg, &loc_my_surf_data, my_env, &my_surf);
  if(!(1&sts&*EMmsg)) goto wrapup;

  if(!IF_NULL_OBJID(comm_id))
   {
    sts = EMsm_get_surface_geom(EMmsg, &loc_comm_surf_data, comm_env,
				&comm_surf);
    if(!(1&sts&*EMmsg)) goto wrapup;
   }

  sts = EMsm_get_surface_geom(EMmsg, &loc_int_surf_data, int_env, &int_surf);
  if(!(1&sts&*EMmsg)) goto wrapup;


  /* Move the approximate intersection parameters into local buffer because
     math uses input space itself for output. We can keep the approxiamte
     values intact and return the exact values.
     If the approximate uv values on the three surfaces are not supplied
     compute them from the approximate xyz intersection point. BSmdistptsf
     routine is used instead of BSprptonsf to avoid tolerance problem
     causing the point to be declared to be off a surface. We know for sure
     that the xyz point supplied is on all the three surfaces.
  */
  if(my_uv_approx) OM_BLOCK_MOVE(my_uv_approx, loc_my_uv, uv_size);
  else
   {
     status = BSmdistptsf( &rc, my_surf, xyz_int_approx, &loc_my_uv[0], 
			  &loc_my_uv[1], base_point, &dist);
     if(!status) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
   }

  if(!IF_NULL_OBJID(comm_id))
   {
    if(comm_uv_approx) OM_BLOCK_MOVE(comm_uv_approx, loc_comm_uv, uv_size);
    else
     {
      status = BSmdistptsf( &rc, comm_surf, xyz_int_approx, &loc_comm_uv[0], 
			  &loc_comm_uv[1], base_point, &dist);
      if(!status) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
     }
   }

  if(int_uv_approx) OM_BLOCK_MOVE(int_uv_approx, loc_int_uv, uv_size);
  else
   {
     status = BSmdistptsf( &rc, int_surf, xyz_int_approx, &loc_int_uv[0], 
			  &loc_int_uv[1], base_point, &dist);
     if(!status) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
   }

  /* Now we have the three surface geometries, the parametric tolerances
     for the respective surfaces and the approximate intersection parameters
     on each of the surfaces. So get the exact intersection.
     If there is no common surface available we will use the iteration method
     which holds one parameter constant out of the 4 (2 each for 2 surfaces)
     and iterates the remaining three.
  */
  if(my_edpar) OM_BLOCK_MOVE(loc_my_uv, sav_my_old_uv, uv_size);
  if(comm_edpar && !IF_NULL_OBJID(comm_id)) 
	OM_BLOCK_MOVE(loc_comm_uv, sav_comm_old_uv, uv_size);
	
  if(!IF_NULL_OBJID(comm_id))
   {
    BStrpsfiter(my_surf, comm_surf, int_surf, 
	      loc_my_tol.tol, loc_comm_tol.tol, loc_int_tol.tol, 
	      &loc_my_uv[0], &loc_my_uv[1], 
	      &loc_comm_uv[0], &loc_comm_uv[1], 
	      &loc_int_uv[0], &loc_int_uv[1], loc_xyz_exact, &isuccess, &rc);
    EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
    EMerr_hndlr(!isuccess, *EMmsg, EMS_I_NoSolution, wrapup);
   }
  else
   {
    IGRdouble	junkpt[3], my_uv[2], int_uv[2], dist1, dist2;
    IGRint	iso = 0;
    IGRdouble   junk_xyz[3], junk_my_uv[2], junk_int_uv[2];
	         
    if(!xyz_int_approx)
     {
      BSsfeval(my_surf, loc_my_uv[0], loc_my_uv[1], 1, (IGRpoint *)junkpt, &rc );
      EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
      xyz_int_approx = (IGRdouble *) junkpt;
     }
    /* Save uv values */
    OM_BLOCK_MOVE(loc_my_uv, my_uv, uv_size);
    OM_BLOCK_MOVE(loc_int_uv, int_uv, uv_size);
    isuccess = FALSE;
    BSEXTRACTPAR(&rc, BSTOLLENVEC, lentol);

    /* Try on both surfaces untill success.
       When a point is found on one surface, try again on the same surface
       by keeping the other parameter constant. Out of the two pick the
       closest point. If the first iteration itself returned the same point
       as the one input, then stop immediately.
       The above was put in to counter problems arising when the intersection
       was along the iso curve of my surf. This caused the iteration function
       to return arbitrary point along that iso curve (since the entire iso
       curve is a solution for such cases.) Going along the other parameter
       will ensure a correct point.
    */
    for(j=0; (j<2) && !isuccess && (iso < 4); j++)
     {
      OM_BLOCK_MOVE(xyz_int_approx, loc_xyz_exact, 3*sizeof(IGRdouble));
      OM_BLOCK_MOVE(my_uv, loc_my_uv, uv_size);
      OM_BLOCK_MOVE(int_uv, loc_int_uv, uv_size);
      rc = BSSUCC;
      isuccess = FALSE;
      BScvsfiter(my_surf, int_surf, iso++, my_surf->u_phy_closed,
	      my_surf->v_phy_closed , int_surf->u_phy_closed, 
	      int_surf->v_phy_closed, 
	      loc_my_tol.tol, loc_int_tol.tol, loc_xyz_exact, 
	      &loc_my_uv[0], &loc_my_uv[1], 
	      &loc_int_uv[0], &loc_int_uv[1], &isuccess, &rc);
      if((rc!=BSSUCC) || !isuccess) {iso++; continue;}

      if(BSdistptpt(&rc, loc_xyz_exact, xyz_int_approx) < lentol) continue;

      /* Try with the other parameter remaining constant and select the
	 closest point.
      */
      OM_BLOCK_MOVE(xyz_int_approx, junk_xyz, 3*sizeof(IGRdouble));
      OM_BLOCK_MOVE(my_uv, junk_my_uv, uv_size);
      OM_BLOCK_MOVE(int_uv, junk_int_uv, uv_size);
      rc = BSSUCC;
      isuccess = FALSE;
      BScvsfiter(my_surf, int_surf, iso++, my_surf->u_phy_closed,
	      my_surf->v_phy_closed , int_surf->u_phy_closed, 
	      int_surf->v_phy_closed, 
	      loc_my_tol.tol, loc_int_tol.tol, junk_xyz, 
	      &junk_my_uv[0], &junk_my_uv[1], 
	      &junk_int_uv[0], &junk_int_uv[1], &isuccess, &rc);
      if( (rc!=BSSUCC) || !isuccess) continue;

      dist1 = BSdistptpt(&rc, xyz_int_approx, loc_xyz_exact);
      dist2 = BSdistptpt(&rc, xyz_int_approx, junk_xyz);
      if(dist2 < dist1)
       {
        OM_BLOCK_MOVE(junk_xyz, loc_xyz_exact, 3*sizeof(IGRdouble));
        OM_BLOCK_MOVE(junk_my_uv, loc_my_uv, uv_size);
        OM_BLOCK_MOVE(junk_int_uv, loc_int_uv, uv_size);
       }
     }

    EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
    EMerr_hndlr(!isuccess, *EMmsg, EMS_I_NoSolution, wrapup);
   }

  if(my_uv_exact) OM_BLOCK_MOVE(loc_my_uv, my_uv_exact, uv_size);
  if(comm_uv_exact && !IF_NULL_OBJID(comm_id)) 
	OM_BLOCK_MOVE(loc_comm_uv, comm_uv_exact, uv_size);
  if(int_uv_exact) OM_BLOCK_MOVE(loc_int_uv, int_uv_exact, uv_size);
  if(xyz_int_exact) OM_BLOCK_MOVE(loc_xyz_exact, xyz_int_exact, 
				  3*sizeof(IGRdouble));
				
  tolsize = sizeof(struct EMSpartolbasis);
  if(my_tol) OM_BLOCK_MOVE(&loc_my_tol, my_tol, tolsize);
  if(comm_tol && !IF_NULL_OBJID(comm_id)) 
    OM_BLOCK_MOVE(&loc_comm_tol, comm_tol, tolsize);
  if(int_tol) OM_BLOCK_MOVE(&loc_int_tol, int_tol, tolsize);

  /* Refine myself. The exact intersection point is introduced as long
     as it is not within tolerance from either of the existing ends of the
     span where it is intended to be introduced.
  */
  if(my_edpar)
   {
    struct EMSdataselect	junk;

    junk.datatype = EMSdata_surface;
    junk.data.surface = (struct IGRbsp_surface *) my_surf;

    sts = EMsm_insert_point_in_edge(EMmsg, my_edpar, &loc_my_tol, user_id, 
		loc_my_uv, me_hole, me_refined, &my_env->matrix_type, 
		my_env->matrix, &junk);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);
    if(*EMmsg == EMS_I_NoSolution) goto wrapup;
#if DEBUG
    if(*EMmsg == EMS_S_Success)
        fprintf(stderr, "Edge %d REFINED\n", user_id);
#endif
   }

  /* Refine common edge if possible */
  if(comm_edpar && !IF_NULL_OBJID(comm_id))
   {
    struct EMSdataselect	junk;

    junk.datatype = EMSdata_surface;
    junk.data.surface = (struct IGRbsp_surface *) comm_surf;

    sts = EMsm_insert_point_in_edge(EMmsg, comm_edpar, &loc_comm_tol, comm_id, 
		loc_comm_uv, comm_hole, comm_refined, &comm_env->matrix_type, 
		comm_env->matrix, &junk);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_I_NoSolution, wrapup);
    if(*EMmsg == EMS_I_NoSolution) goto wrapup;
#if DEBUG
      if(*EMmsg == EMS_S_Success)
       fprintf(stderr, "Common edge %d of edge %d REFINED\n",comm_id, user_id);
#endif
   }


wrapup:
if( (loc_my_surf_data.datatype == EMSdata_object) && my_surf) free(my_surf);
if( (loc_comm_surf_data.datatype == EMSdata_object) && comm_surf) 
							free(comm_surf);

if( (loc_int_surf_data.datatype == EMSdata_object) && int_surf) free(int_surf);

if(!(1&*EMmsg&sts))
 {
  *EMmsg = EMS_I_NoSolution;
  sts = OM_S_SUCCESS;
 }
if((*EMmsg != EMS_I_NoSolution) && IF_NULL_OBJID(comm_id))
 *EMmsg = EMS_I_NoCommonEdge;
else if(*EMmsg != EMS_I_NoSolution) *EMmsg = EMS_S_Success;

return(sts);
}


end implementation EMSlinedge;
