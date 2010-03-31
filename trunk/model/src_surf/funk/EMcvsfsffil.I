/*

 * DESCRIPTION
       
    This function returns the fillet(s) from a curve on surface1 to surface2.

 * Inputs

    options		- EMS_FIL_NATURAL_NORMAL1
			  EMS_FIL_NATURAL_NORMAL2

			  These determine the side of each surface
			  on which the fillet will be generated.

			- EMS_FIL_DEFAULT_RHO

			  Use default rho for constructing fillet surface.
			  This option overrides the following rho value input.

			- EMS_FIL_SURF_ORIENTED

			  If set, the fillet surface will be oriented to be
			  consistent with the first surface.

			- EMS_FIL_BOUND_SURF

			  If set, then a natural loopset will be imposed on
			  each of the fillet surfaces.
 
    construct_list	- The instance of GRvg_construct, carrying the
			  packet of information concerning the module,
			  active display parameters, etc.

    curve_GRid		- struct GRid of the curve.
    curve_geom		- struct IGRbsp_curve of the curve.

                          If curve_geom passed in, then curve_GRid is not
			  needed. Otherwise, curve_GRid is required.

    surface1_GRid	- struct GRid of the first surface.
    surface1_geom	- struct IGRbsp_surface of the first surface.

    surface2_GRid	- struct GRid of the second surface.
    surface2_geom	- struct IGRbsp_surface of the second surface.

			  For each pari above, the GRid is required. Geom
			  is optional and can be set to NULL if not input.

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

    SY    : 03/29/93 : creation.
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
#include "bsfreesf.h"
#include "bsdotp.h"
#include "bschangepar.h"
#include "bsflcostsnc.h"

#argsused

IGRlong EMcreate_fillet_cv_on_surf1_to_surf2(EMmsg,
					     options,
					     construct_list,
					     curve_GRid,
					     curve_geom,
					     surface1_GRid,
					     surface1_geom,
					     surface2_GRid,
					     surface2_geom,
					     is_chamfer,
					     rho_value,
					     num_of_fillets,
					     fillet_surf_objids,
					     fillet_surf_geoms,
					     fillet_surf_props)
IGRlong	*EMmsg; 
IGRushort options;
struct GRvg_construct *construct_list;
struct GRid *curve_GRid, *surface1_GRid, *surface2_GRid;
struct IGRbsp_curve *curve_geom;
struct IGRbsp_surface *surface1_geom, *surface2_geom;
IGRboolean is_chamfer;
IGRdouble rho_value;
IGRint *num_of_fillets;
GRobjid	**fillet_surf_objids;
struct IGRbsp_surface ***fillet_surf_geoms;
IGRushort **fillet_surf_props;
{
  struct IGRbsp_curve *ptr_curve_geom;
  struct IGRbsp_surface *ptr_surf1_geom, *ptr_surf2_geom;
  struct IGRbsp_surface *contain_plane1, *contain_plane2;
  IGRboolean natural_normal1, natural_normal2;
  IGRboolean get_plane1, get_plane2;
  struct BSgeom_bsp_curve BSgeom_curve;
  struct BSgeom_bsp_surf BSgeom_surf1, BSgeom_surf2;
  IGRdouble default_rho, tolr, cht_tol;
  struct GRmd_env *md_env = NULL;
  IGRshort *mattyp;
  IGRdouble *mat;
  struct BSgeom_bsp_surf **BSgeom_fillets, *ptr_BSgeom_surf = NULL;
  struct IGRbsp_surface *ptr_bspsf = NULL;
  IGRint num_fillets, num_pts;
  IGRdouble u, v, fillet_point[3], fillet_normal[3];
  IGRdouble surf_uv[2], surf_point[3], surf_normal[3];
  IGRint i, j, index;
  IGRboolean rho_change, reversed, pt_onsurf;
  GRclassid classid;
  GRobjid edge_ids[4];
  IGRlong sts, loc_msg, *cnst_msg;
  BSrc bsrc;

  extern void get_sf_type_for_filleting();
  extern IGRdouble fabs() ;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  cnst_msg = construct_list->msg;

  /*
   * Initialize
   */
  BSEXTRACTPAR(&loc_msg, BSRHO_VALUE, default_rho);
  BSEXTRACTPAR(&loc_msg, BSTOLCLOSETOZERO, tolr);
  BSEXTRACTPAR(&loc_msg, BSTOLCHRDHT, cht_tol);

  rho_change = FALSE;
  pt_onsurf = FALSE;
  num_pts = 1;
  
  ptr_surf1_geom = ptr_surf2_geom = NULL;
  contain_plane1 = contain_plane2 = NULL;
  get_plane1 = get_plane2 = FALSE;

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
   * For the first input surface, construct the surface geometry in a form
   * suitable for math create fillet functions (i.e. construct an instance of
   * struct BSgeom_bsp_surf for the first surface).
   */
  ptr_surf1_geom = surface1_geom;
  if (!ptr_surf1_geom)
  {
    sts = EMgetvggeom(&loc_msg, mattyp, mat,
		      surface1_GRid, &ptr_surf1_geom, NULL);
    EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
  }

  reversed = FALSE;
  get_sf_type_for_filleting(&loc_msg,
			    (IGRushort) 0,
			    surface1_GRid->objid,
			    md_env->md_id.osnum,
			    ptr_surf1_geom,
			    &BSgeom_surf1.type,
			    &contain_plane1,
			    &reversed);
  EMerr_hndlr(!(1 & loc_msg), *EMmsg, EMS_E_SurfaceError, quit);

  if (BSgeom_surf1.type == BSRECT_PLANE && contain_plane1)
  {
    BSgeom_surf1.bspsf = contain_plane1;
    if (reversed == TRUE)
      natural_normal1 = !natural_normal1;
    get_plane1 = TRUE;
  }
  else
    BSgeom_surf1.bspsf = ptr_surf1_geom;

  BSgeom_surf1.bounded = TRUE;
  BSgeom_surf1.urange[0] = BSgeom_surf1.vrange[0] = 0.0;
  BSgeom_surf1.urange[1] = BSgeom_surf1.vrange[1] = 1.0;
  BSgeom_surf1.sfgen_cv = NULL;
  BSgeom_surf1.geom_prop = FALSE;

  /*
   * Do the preceeding for the second input surface
   */
  ptr_surf2_geom = surface2_geom;
  if (!ptr_surf2_geom)
  {
    sts = EMgetvggeom(&loc_msg, mattyp, mat,
		      surface2_GRid, &ptr_surf2_geom, NULL);
    EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
  }
  
  reversed = FALSE;
  get_sf_type_for_filleting(&loc_msg,
			    (IGRushort) 0,
			    surface2_GRid->objid,
			    md_env->md_id.osnum,
			    ptr_surf2_geom,
			    &BSgeom_surf2.type,
			    &contain_plane2,
			    &reversed);
  EMerr_hndlr(!(1 & loc_msg), *EMmsg, EMS_E_SurfaceError, quit);

  if (BSgeom_surf2.type == BSRECT_PLANE && contain_plane2)
  {
    BSgeom_surf2.bspsf = contain_plane2;
    if (reversed == TRUE)
      natural_normal2 = !natural_normal2;
    get_plane2 = TRUE;
  }
  else
    BSgeom_surf2.bspsf = ptr_surf2_geom;

  BSgeom_surf2.bounded = TRUE;
  BSgeom_surf2.urange[0] = BSgeom_surf2.vrange[0] = 0.0;
  BSgeom_surf2.urange[1] = BSgeom_surf2.vrange[1] = 1.0;
  BSgeom_surf2.sfgen_cv = NULL;
  BSgeom_surf2.geom_prop = FALSE;

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
  BSflcostsnc(&BSgeom_surf1,
	      &BSgeom_curve,
	      &BSgeom_surf2,
	      natural_normal1,
	      natural_normal2,
	      &num_fillets,
	      &BSgeom_fillets,
	      &bsrc);
  EMerr_hndlr(bsrc != BSSUCC, *EMmsg, EMS_E_BSerror, quit);
  
  /*
   * Set the fillet's oriented normal. The fillet normal is evaluated at
   * the mid point of either the u=0 or the u=1 iso curve.
   */
  if (options & EMS_FIL_SURF_ORIENTED)
  {
    for (i = 0; i < num_fillets; i++)
    {
      v = 0.5;
      for (j = 0; j < 2; j++)
      {
	u = (IGRdouble) j;
	ptr_BSgeom_surf = j ? &BSgeom_surf2 : &BSgeom_surf1;

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

	  break;
	}
      }

      /*
       * The following should never occur, but check it anyway ...
       */
      EMerr_hndlr(j == 2, *EMmsg, EMS_E_Fail, quit);
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

  /*
   * If the curve geomtry was constructed within this function,
   * then remove it.
   */
  if (!curve_geom)
    om$dealloc(ptr = ptr_curve_geom);

  /*
   * If the first surface bspline geometry was constructed within this
   * function, then remove it.
   */
  if (!surface1_geom)
    om$dealloc(ptr = ptr_surf1_geom);
  if (get_plane1 == TRUE)
    BSfreesf(&loc_msg, contain_plane1);

  /*
   * Do preceding for the second surface.
   */
  if (!surface2_geom)
    om$dealloc(ptr = ptr_surf2_geom);
  if (get_plane2 == TRUE)
    BSfreesf(&loc_msg, contain_plane2);

  EMWRAPUP(*EMmsg, sts, "EMcreate_fillet_cv_on_surf1_to_surf2");
  return sts;
}

end implementation EMSsubbs;
