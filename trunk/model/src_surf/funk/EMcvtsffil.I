/*

 * DESCRIPTION
       
    This function returns the fillet(s) between a curve and a surface.

 * Inputs

    options		- EMS_FIL_NATURAL_NORMAL1

			  If set, the fillet is on the side determined
			  by EMcomp_ind.

    			- EMS_FIL_NATURAL_NORMAL2

			  If set, the fillet is on the natural normal side
			  of the surface.

			- EMS_FIL_DEFAULT_RHO

			  Use default rho for constructing fillet surface.
			  This option overrides the following rho value input.

			- EMS_FIL_SURF_ORIENTED

			  If set, the fillet surface will be oriented to be
			  consistent with the surface.

			- EMS_FIL_BOUND_SURF

			  If set, then a natural loopset will be imposed on
			  each of the fillet surfaces.
 
                        - EMS_FIL_CHECK_CURV_PROB

                          If set, check to see whether any of the
                          fillets have a curvature problem, and if
                          so, error out. Else, ignore any curvature
                          problems on the fillets.

                        - EMS_FIL_SINGLE_FILLET

                          If set then the argument 'ref_pt' is used to
                          filter out all but a single fillet (determined
                          by evaluating the minimum distance from
                          'ref_pt' to each of the fillets, and by
                          chosing the fillet that has the smallest
                          minimum distance).

    construct_list	- The instance of GRvg_construct, carrying the
			  packet of information concerning the module,
			  active display parameters, etc.

    curve_GRid		- struct GRid of the curve.
    curve_geom		- struct IGRbsp_curve of the curve.

                          If curve_geom passed in, then curve_GRid is not
                          needed. Otherwise, curve_GRid is required.

    surface_GRid	- struct GRid of the surface.
    surface_geom	- struct IGRbsp_surface of the surface.

                          For each pair above, the GRid is required. Geom
                          is optional and can be set to NULL if not input.

    start_arc_GRid      - struct GRid of the starting arc.
    start_arc_geom      - struct IGRbsp_curve of the starting arc.

    end_arc_GRid        - struct GRid of the ending arc.
    end_arc_geom        - struct IGRbsp_curve of the ending arc.

			  For each pair above, the GRid and geom are mutually
			  exclusive. Input one and set the other to NULL.
			  Start arc and end arc can both be NULL.

    radius		- Radius of the fillet surface.

    ref_pt              - Used to filter out all but one of the fillets
                          (see comments on EMS_FIL_SINGLE_FILLET).

    is_chamfer		- TRUE if it is a chamfer. FALSE otherwise. NOTE that
			  this input overrides the following rho_value input.

    rho_value		- Input rho value for selecting types of conic section
			  curves used in creating fillet surface. NOTE that
			  this input will be ignored if

			  a) EMS_FIL_DEFAULT_RHO is set in the options input
			     (rho is set to BARHO_VALUE for circular arcs);

			  b) is_chamfer is set to true (rho is set to 0.0).
 
 * Outputs

    EMmsg		- Return codes

                          EMS_S_Success         : Success
			  EMS_E_InvalidArg      : Invalid options/argument
			  EMS_E_SurfaceError    : Surface has problem
			  EMS_E_BSerror         : Math error
			  EMS_E_NoDynamicMemory : No heap memory
			  EMS_E_Fail            : Fail

    num_of_fillets	- Number of fillets returned. Set it to NULL if not
			  requesting.

    fillet_surf_objids	- Array of GRobjids of the fillets. The function
			  allocates the output memory. Set it to NULL if not
			  requesting.

    fillet_surf_geoms	- An array of fillet surface geometries. The function
			  allocates the output memory. Set it to NULL if not
			  requesting.

    fillet_surf_props	- An array of fillet surface properties. The function
    			  allocates the output memory. Set it to NULL if not
			  requesting.

 * HISTORY

    SY    : 03/30/93 : creation.
*/

class implementation EMSsubbs;

#include "bserr.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSrnd.h"
#include "REgencompsf.h"
#include "bssfarrevn.h"
#include "bsprptarrsf.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bsfreesf.h"
#include "bsflcvtsfcr.h"

#argsused

IGRlong EMcreate_fillet_curve_to_surface(EMmsg,
					 options,
					 construct_list,
					 curve_GRid,
					 curve_geom,
					 surface_GRid,
					 surface_geom,
					 radius,
					 start_arc_GRid,
					 start_arc_geom,
					 end_arc_GRid,
					 end_arc_geom,
					 ref_pt,
					 is_chamfer,
					 rho_value,
					 num_of_fillets,
					 fillet_surf_objids,
					 fillet_surf_geoms,
					 fillet_surf_props)
IGRlong	*EMmsg; 
IGRushort options;
struct GRvg_construct *construct_list;
struct GRid *curve_GRid, *surface_GRid, *start_arc_GRid, *end_arc_GRid;
struct IGRbsp_curve *curve_geom, *start_arc_geom, *end_arc_geom;
struct IGRbsp_surface *surface_geom;
IGRdouble radius, rho_value;
IGRpoint ref_pt;
IGRboolean is_chamfer;
IGRint *num_of_fillets;
GRobjid	**fillet_surf_objids;
struct IGRbsp_surface ***fillet_surf_geoms;
IGRushort **fillet_surf_props;
{
  struct IGRbsp_surface *ptr_surf_geom, *contain_plane;
  struct IGRbsp_curve *ptr_curve_geom, *ptr_start_arc_geom, *ptr_end_arc_geom;
  IGRboolean natural_normal1, natural_normal2, get_plane;
  struct BSgeom_bsp_curve BSgeom_curve;
  struct BSgeom_bsp_surf BSgeom_surf;
  IGRdouble default_rho, tolr, cht_tol;
  struct GRmd_env *md_env = NULL;
  IGRshort *mattyp;
  IGRdouble *mat;
  struct BSgeom_bsp_surf **BSgeom_fillets, *ptr_BSgeom_surf = NULL;
  struct IGRbsp_surface *ptr_bspsf = NULL;
  IGRint num_fillets, num_pts;
  IGRboolean *crv_probs;
  IGRdouble min_dist, dist;
  IGRdouble u, v, fillet_point[3], fillet_normal[3];
  IGRdouble surf_uv[2], surf_point[3], surf_normal[3];
  IGRint i, index;
  IGRboolean rho_change, reversed, pt_onsurf;
  GRclassid classid;
  GRobjid edge_ids[4];
  IGRlong sts, loc_msg, *cnst_msg;
  BSrc bsrc;

  extern void get_sf_type_for_filleting();
  extern IGRdouble fabs();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  cnst_msg = construct_list->msg;
  crv_probs = NULL;

  /*
   * Initialize
   */
  BSEXTRACTPAR(&loc_msg, BSRHO_VALUE, default_rho);
  BSEXTRACTPAR(&loc_msg, BSTOLCLOSETOZERO, tolr);
  BSEXTRACTPAR(&loc_msg, BSTOLCHRDHT, cht_tol);

  rho_change = FALSE;
  pt_onsurf = FALSE;
  num_pts = 1;
  
  ptr_surf_geom = NULL;
  contain_plane = NULL;
  get_plane = FALSE;

  ptr_curve_geom = NULL;
  ptr_start_arc_geom = ptr_end_arc_geom = NULL;

  natural_normal1 = options & EMS_FIL_NATURAL_NORMAL1 ? 1 : 0;
  natural_normal2 = options & EMS_FIL_NATURAL_NORMAL2 ? 1 : 0;

  md_env = construct_list->env_info;
  mattyp = &md_env->md_env.matrix_type;
  mat = &md_env->md_env.matrix[0];

  BSgeom_fillets = NULL;

  /*
   * If a natural boundary is to be imposed on the fillets, then
   * 'fillet_surf_objids' cannot be NULL (if so, there is nothing
   * to attach the loopset).
   */
  if ((options & EMS_FIL_BOUND_SURF) && !fillet_surf_objids)
  {
    *EMmsg = EMS_E_InvalidArg;
    goto quit;
  }

  /*
   * For the input curve, construct the curve geometry in an instance of
   * struct BSgeom_bsp_curve.
   */
  ptr_curve_geom = curve_geom;
  if (!ptr_curve_geom)
  {
    sts = EMgetvggeom(&loc_msg, mattyp, mat,
		      curve_GRid, &ptr_curve_geom, NULL);
    EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
  }

  BSgeom_curve.geom_prop = FALSE;
  BSgeom_curve.bscv_flag = TRUE;
  BSgeom_curve.array1 = NULL;
  BSgeom_curve.type = BSGEN_BSP_CV;
  BSgeom_curve.bspcv = ptr_curve_geom;

  /*
   * For the input surface, construct the surface geometry in a form
   * suitable for math create fillet functions (i.e. construct an instance of
   * struct BSgeom_bsp_surf for the first surface).
   */
  ptr_surf_geom = surface_geom;
  if (!ptr_surf_geom)
  {
    sts = EMgetvggeom(&loc_msg, mattyp, mat,
		      surface_GRid, &ptr_surf_geom, NULL);
    EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
  }

  reversed = FALSE;
  get_sf_type_for_filleting(&loc_msg,
			    (IGRushort) 0,
			    surface_GRid->objid,
			    md_env->md_id.osnum,
			    ptr_surf_geom,
			    &BSgeom_surf.type,
			    &contain_plane,
			    &reversed);
  EMerr_hndlr(!(1 & loc_msg), *EMmsg, EMS_E_SurfaceError, quit);

  if (BSgeom_surf.type == BSRECT_PLANE && contain_plane)
  {
    BSgeom_surf.bspsf = contain_plane;
    if (reversed == TRUE)
      natural_normal2 = !natural_normal2;
    get_plane = TRUE;
  }
  else
    BSgeom_surf.bspsf = ptr_surf_geom;

  BSgeom_surf.bounded = TRUE;
  BSgeom_surf.urange[0] = BSgeom_surf.vrange[0] = 0.0;
  BSgeom_surf.urange[1] = BSgeom_surf.vrange[1] = 1.0;
  BSgeom_surf.sfgen_cv = NULL;
  BSgeom_surf.geom_prop = FALSE;

  /*
   * Get the B-spline geometry of the input starting arc.
   */
  ptr_start_arc_geom = start_arc_geom;
  if (!ptr_start_arc_geom)
  {
    if (start_arc_GRid)
    {
      sts = EMgetvggeom(&loc_msg, mattyp, mat,
                        start_arc_GRid, &ptr_start_arc_geom, NULL);
      EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
    }
  }

  /*
   * Do the proceeding for the ending arc.
   */
  ptr_end_arc_geom = end_arc_geom;
  if (!ptr_end_arc_geom)
  {
    if (end_arc_GRid)
    {
      sts = EMgetvggeom(&loc_msg, mattyp, mat,
                        end_arc_GRid, &ptr_end_arc_geom, NULL);
      EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
    }
  }

  /*
   * Save the existing RHO value (to be reset in quit), and enforce the
   * input 'rho_value'.
   */
  if (fabs(rho_value - default_rho) > tolr && !(options & EMS_FIL_DEFAULT_RHO))
  {
    if (is_chamfer)
      rho_value = 0.0;
    BSchangepar(&loc_msg, BSRHO_VALUE, rho_value);
    rho_change = TRUE;
  }

  /*
   * Call math function to create the fillet surface.
   */
  BSflcvtsfcr(&BSgeom_curve,
	      natural_normal1,
	      &BSgeom_surf,
	      natural_normal2,
	      radius,
	      ptr_start_arc_geom,
	      ptr_end_arc_geom,
	      &num_fillets,
	      &BSgeom_fillets,
	      &crv_probs,
	      &bsrc);
  EMerr_hndlr(bsrc != BSSUCC, *EMmsg, EMS_E_BSerror, quit);
  
  /*
   * If the option is to return only a single fillet surface, then choose
   * the one which is closest to the 'ref_pt'. Delete the rest.
   */
  if (options & EMS_FIL_SINGLE_FILLET && num_fillets > 1)
  {
    if (!ref_pt)
    {
      *EMmsg = EMS_E_InvalidArg;
      goto quit;
    }

    min_dist = MAXDOUBLE;
    index = 0;

    for (i = 0; i < num_fillets; i++)
    {
      BSprptarrsf(BSgeom_fillets[i], cht_tol, 2, 2, &num_pts, ref_pt,
                  surf_uv, surf_point, &pt_onsurf, NULL, &bsrc);
      EMerr_hndlr(bsrc != BSSUCC, *EMmsg, EMS_E_BSerror, quit);

      if ((dist = BSdistptpt(&bsrc, ref_pt, surf_point)) < min_dist)
      {
        min_dist = dist;
        index = i;
      }
    }

    for (i = 0; i < num_fillets; i++)
    {
      /*
       * Delete all fillets except the one that is closest to 'ref_pt'
       */
      if (i == index)
        continue;

      if (BSgeom_fillets[i])
      {
        if (BSgeom_fillets[i]->bspsf)
          BSfreesf(&bsrc, BSgeom_fillets[i]->bspsf);
        om$dealloc(ptr = BSgeom_fillets[i]);
        BSgeom_fillets[i] = NULL;
      }
    }

    if (index)
    {
      BSgeom_fillets[0] = BSgeom_fillets[index];
      BSgeom_fillets[index] = NULL;
      if (crv_probs)
        crv_probs[0] = crv_probs[index];
    }

    num_fillets = 1;
  }

  /*
   * Check the fillets' curvature problem.
   */
  if (options & EMS_FIL_CHECK_CURV_PROB && crv_probs)
  {
    for (i = 0; i < num_fillets; i++)
      if (crv_probs[i] == TRUE)
      {
        *EMmsg = EMS_E_SurfaceError;
        goto quit;
      }
  }

  /*
   * Set the fillet's oriented normal. The fillet normal is evaluated at
   * the mid point of either the u=0 or the u=1 iso curve.
   */
  if (options & EMS_FIL_SURF_ORIENTED)
  {
    for (i = 0; i < num_fillets; i++)
    {
      u = 1.0;
      v = 0.5;
      ptr_BSgeom_surf = &BSgeom_surf;

      BSsfarrevn(&bsrc,
		 BSgeom_fillets[i]->bspsf,
		 1, &u,
		 1, &v,
		 fillet_point,
		 fillet_normal);
      
      BSprptarrsf(ptr_BSgeom_surf,
		  cht_tol,
		  2, 0,
		  &num_pts, fillet_point,
		  surf_uv, surf_point,
		  &pt_onsurf, NULL,
		  &bsrc);
      EMerr_hndlr(bsrc != BSSUCC, *EMmsg, EMS_E_BSerror, quit);

      if (pt_onsurf)
      {
	/*
	 * Evaluate the surface normal at point (u, v).
	 */
	BSsfarrevn(&bsrc,
		   ptr_BSgeom_surf->bspsf,
		   1, &surf_uv[0],
		   1, &surf_uv[1],
		   surf_point,
		   surf_normal);

	/*
	 * Orient normal of the fillet according to surface normal
	 */
	BSgeom_fillets[i]->bspsf->pos_orient =
	  BSdotp(&loc_msg, fillet_normal, surf_normal) > 0 ?
	  ptr_BSgeom_surf->bspsf->pos_orient :
	  !ptr_BSgeom_surf->bspsf->pos_orient;
	
      }
      else
      {
	*EMmsg = EMS_E_Fail;
	goto quit;
      }
    }
  }

  /*
   * Create objects for each of the fillets. Determine fillet v0 and v1
   * degeneracy. Impose a natural boundary. Assign output.
   */
  if (num_of_fillets)
    *num_of_fillets = num_fillets;
  
  /*
   * Do the array of fillet objids and natural boundaries.
   */
  if (fillet_surf_objids)
  {
    if (!(*fillet_surf_objids))
    {
      *fillet_surf_objids = (GRobjid *) om$malloc(size = num_fillets * sizeof(GRobjid));
      EMerr_hndlr(!(*fillet_surf_objids), *EMmsg, EMS_E_NoDynamicMemory, quit);
    }
    
    for (i = 0; i < num_fillets; i++)
    {
      construct_list->geometry = (IGRchar *) BSgeom_fillets[i]->bspsf;
      getsfclassid(BSgeom_fillets[i]->type, &classid);

      sts = om$construct(classid = classid,
			 osnum = md_env->md_id.osnum,
			 p_objid = &(*fillet_surf_objids)[i],
			 msg = message GRgraphics.GRconstruct(construct_list));
      EMerr_hndlr(!(sts & *cnst_msg & 1), *EMmsg, *cnst_msg, quit);

      /*
       * if required, impose a natural boundary on the fillet
       * surface (needed the fillet surface object before doing
       * this).
       */
      if (options & EMS_FIL_BOUND_SURF)
      {
	sts = om$send(msg = message EMSsurface.EMmk_nat_bdry(&loc_msg,
							     &md_env->md_env,
							     edge_ids),
		      targetid = (*fillet_surf_objids)[i],
		      senderid = NULL_OBJID,
		      targetos = md_env->md_id.osnum);
	EMerr_hndlr(!(sts & loc_msg & 1), *EMmsg, loc_msg, quit);
      }
    }
  }

  /*
   * Do the fillets properties.
   */
  if (fillet_surf_props)
  {
    if (!(*fillet_surf_props))
    {
      *fillet_surf_props = (IGRushort *) om$malloc(size = num_fillets * sizeof(IGRint));
      EMerr_hndlr(!(*fillet_surf_props), *EMmsg, EMS_E_NoDynamicMemory, quit);
    }
    
    for (i = 0; i < num_fillets; i++)
    {
      (*fillet_surf_props)[i] = 0;
      ptr_bspsf = BSgeom_fillets[i]->bspsf;
      
      /*
       * Determine degeneracy of the ith fillet on v = 0.
       */
      if (EFpts_degenerate(ptr_bspsf->u_num_poles,
			   ptr_bspsf->poles,
			   ptr_bspsf->weights,
			   3,
			   cht_tol))
	(*fillet_surf_props)[i] = EMSfillet_v0_is_degenerate;

      /*
       * Determine the accuracy of the fillet.
       */
      if (BSgeom_fillets[i]->type == BSGEN_BSP_SF)
	(*fillet_surf_props)[i] |= EMSfillet_inaccurate_atstart |
	                           EMSfillet_inaccurate_atstop;

      /*
       * Determine degeneracy of the ith fillet on v = 1.
       */
      index = (ptr_bspsf->v_num_poles - 1) * ptr_bspsf->u_num_poles;
      if (EFpts_degenerate(ptr_bspsf->u_num_poles,
			   ptr_bspsf->poles + index * 3,
			   ptr_bspsf->weights ? ptr_bspsf->weights + index : NULL,
			   3,
			   cht_tol))
	(*fillet_surf_props)[i] |= EMSfillet_v1_is_degenerate;
    }
  }

  /*
   * Do the fillets geometry.
   */
  if (fillet_surf_geoms)
  {
    if (!(*fillet_surf_geoms))
    {
      *fillet_surf_geoms = (struct IGRbsp_surface **) om$malloc(size = num_fillets * sizeof(struct IGRbsp_surface *));
      EMerr_hndlr(!(*fillet_surf_geoms), *EMmsg, EMS_E_NoDynamicMemory, quit);
    }

    for (i = 0; i < num_fillets; i++)
    {
      (*fillet_surf_geoms)[i] = BSgeom_fillets[i]->bspsf;
      BSgeom_fillets[i]->bspsf = NULL;
    }
  }

 quit:
  
  /*
   * If the rho value was changed, then reset it.
   */
  if (rho_change == TRUE)
    BSchangepar(&loc_msg, BSRHO_VALUE, default_rho);

  /*
   * Remove all the fillets that were not utilized.
   */
  if (BSgeom_fillets)
  {
    for (i = 0; i < num_fillets; i++)
      if (BSgeom_fillets[i])
      {
	if (BSgeom_fillets[i]->bspsf)
	  BSfreesf(&loc_msg, BSgeom_fillets[i]->bspsf);
	om$dealloc(ptr = BSgeom_fillets[i]);
      }
    om$dealloc(ptr = BSgeom_fillets);
  }

 if (crv_probs)
    om$dealloc(ptr = crv_probs);

  /*
   * If the curve geomtry was constructed within this function,
   * then remove it.
   */
  if (!curve_geom)
    om$dealloc(ptr = ptr_curve_geom);

  /*
   * If the surface bspline geometry was constructed within this
   * function, then remove it.
   */
  if (!surface_geom)
    om$dealloc(ptr = ptr_surf_geom);
  if (get_plane == TRUE)
    BSfreesf(&loc_msg, contain_plane);

 /*
   * If the starting arc bspline geometry was constructed
   * within this function, then remove it.
   */
  if (!start_arc_geom && ptr_start_arc_geom)
    om$dealloc(ptr = ptr_start_arc_geom);

  /*
   * Do proceeding for ending arc.
   */
  if (!end_arc_geom && ptr_end_arc_geom)
    om$dealloc(ptr = ptr_end_arc_geom);

  EMWRAPUP(*EMmsg, sts, "EMcreate_fillet_curve_to_surface");
  return sts;
}

end implementation EMSsubbs;
