/*

 * DESCRIPTION
       
    This function returns the fillet(s) among the three surfaces specified.

 * Inputs

    options		- EMS_FIL_NATURAL_NORMAL1
			  EMS_FIL_NATURAL_NORMAL2
			  EMS_FIL_NATURAL_NORMAL3

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

    surface1_GRid	- struct GRid of the first surface.
    surface1_geom	- struct IGRbsp_surface of the first surface.

    surface2_GRid	- struct GRid of the second surface.
    surface2_geom	- struct IGRbsp_surface of the second surface.

    surface3_GRid	- struct GRid of the third surface.
    surface3_geom	- struct IGRbsp_surface of the third surface.

			  For each pair above, the GRid is required. Geom
			  is optional and can be set to NULL if not input.

    extend_dist		- Distance to extend fillet. Set it to 0.0 if no
                          extension is desired.

    int_cv12		- Intersection curve between surface1 and surface2.
			  Set NULL if it is not known. Math will calculate
			  it internally.

    int_cv23		- Intersection curve between surface2 and surface3.
                          Set NULL if it is not known. Math will calculate
			  it internally.

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

    fillet_surf_objid	- A GRobjid of the fillets. User allocates the memory.
			  Set it to NULL if not requesting.

    fillet_surf_geom	- The fillet surface geometries. Set it to NULL if not
			  requesting.

    fillet_surf_prop	- The fillet surface properties. The function allocates
			  the output memory. Set it to NULL if not requesting.

 * HISTORY

    SY    : 03/24/93 : creation.
    Sudha   07/06/93   Modified for BSprototypes ansification
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
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bschangepar.h"
#include "bstrpsffil.h"

#argsused

IGRlong EMcreate_fillet_triple_surfaces(EMmsg,
					options,
					construct_list,
					surface1_GRid,
					surface1_geom,
					surface2_GRid,
					surface2_geom,
					surface3_GRid,
					surface3_geom,
					extend_dist,
					int_cv12,
					int_cv23,
					is_chamfer,
					rho_value,
					fillet_surf_objid,
					fillet_surf_geom,
					fillet_surf_prop)
IGRlong	*EMmsg; 
IGRushort options;
struct GRvg_construct *construct_list;
struct GRid *surface1_GRid, *surface2_GRid, *surface3_GRid;
struct IGRbsp_surface *surface1_geom, *surface2_geom, *surface3_geom;
IGRboolean is_chamfer;
IGRdouble extend_dist, rho_value;
struct IGRbsp_curve *int_cv12, *int_cv23;
GRobjid	*fillet_surf_objid;
struct IGRbsp_surface **fillet_surf_geom;
IGRushort *fillet_surf_prop;
{
  struct IGRbsp_surface *ptr_surf1_geom, *ptr_surf2_geom, *ptr_surf3_geom;
  struct IGRbsp_surface *contain_plane1, *contain_plane2, *contain_plane3;
  IGRboolean natural_normal1, natural_normal2, natural_normal3;
  IGRboolean get_plane1, get_plane2, get_plane3;
  struct BSgeom_bsp_surf BSgeom_surf1, BSgeom_surf2, BSgeom_surf3;
  IGRdouble default_rho, tolr, cht_tol;
  struct GRmd_env *md_env = NULL;
  IGRshort *mattyp, opt = 1;
  IGRdouble *mat;
  struct BSgeom_bsp_surf *BSgeom_fillets, *ptr_BSgeom_surf = NULL;
  struct IGRbsp_surface *ptr_bspsf = NULL;
  IGRint num_pts;
  IGRdouble u, v, fillet_point[3], fillet_normal[3];
  IGRdouble surf_uv[2], surf_point[3], surf_normal[3];
  IGRint j, index;
  struct IGRbsp_curve *isocv = NULL;
  IGRdouble dist, *par_cv, *par_sf;
  IGRpoint *pts_cv, *pts_sf;
  IGRboolean rho_change, reversed, pt_onsurf, testplnr = FALSE;
  GRclassid classid;
  GRobjid edge_ids[4];
  IGRlong sts, loc_msg, *cnst_msg;
  BSrc bsrc;

  extern void get_sf_type_for_filleting();
  extern IGRdouble fabs();

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
  
  ptr_surf1_geom = ptr_surf2_geom = ptr_surf3_geom = NULL;
  contain_plane1 = contain_plane2 = contain_plane3 = NULL;
  get_plane1 = get_plane2 = get_plane3 = FALSE;

  natural_normal1 = options & EMS_FIL_NATURAL_NORMAL1 ? 1 : 0;
  natural_normal2 = options & EMS_FIL_NATURAL_NORMAL2 ? 1 : 0;
  natural_normal3 = options & EMS_FIL_NATURAL_NORMAL3 ? 1 : 0;

  md_env = construct_list->env_info;
  mattyp = &md_env->md_env.matrix_type;
  mat = &md_env->md_env.matrix[0];

  BSgeom_fillets = NULL;

  /*
   * If a natural boundary is to be imposed on the fillets, then
   * 'fillet_surf_objid' cannot be NULL (if so, there is nothing
   * to attach the loopset).
   */
  if ((options & EMS_FIL_BOUND_SURF) && !fillet_surf_objid)
  {
    *EMmsg = EMS_E_InvalidArg;
    goto quit;
  }

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
   * Do the preceeding for the third input surface
   */
  ptr_surf3_geom = surface3_geom;
  if (!ptr_surf3_geom)
  {
    sts = EMgetvggeom(&loc_msg, mattyp, mat,
		      surface3_GRid, &ptr_surf3_geom, NULL);
    EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
  }
  
  reversed = FALSE;
  get_sf_type_for_filleting(&loc_msg,
			    (IGRushort) 0,
			    surface3_GRid->objid,
			    md_env->md_id.osnum,
			    ptr_surf3_geom,
			    &BSgeom_surf3.type,
			    &contain_plane3,
			    &reversed);
  EMerr_hndlr(!(1 & loc_msg), *EMmsg, EMS_E_SurfaceError, quit);

  if (BSgeom_surf3.type == BSRECT_PLANE && contain_plane3)
  {
    BSgeom_surf3.bspsf = contain_plane3;
    if (reversed == TRUE)
      natural_normal3 = !natural_normal3;
    get_plane3 = TRUE;
  }
  else
    BSgeom_surf3.bspsf = ptr_surf3_geom;

  BSgeom_surf3.bounded = TRUE;
  BSgeom_surf3.urange[0] = BSgeom_surf3.vrange[0] = 0.0;
  BSgeom_surf3.urange[1] = BSgeom_surf3.vrange[1] = 1.0;
  BSgeom_surf3.sfgen_cv = NULL;
  BSgeom_surf3.geom_prop = FALSE;

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
  BStrpsffil(&BSgeom_surf1, natural_normal1,
	     &BSgeom_surf2, natural_normal2,
	     &BSgeom_surf3, natural_normal3,
	     extend_dist,
	     int_cv12, int_cv23,
	     &BSgeom_fillets,
	     &bsrc);
  EMerr_hndlr(bsrc != BSSUCC, *EMmsg, EMS_E_BSerror, quit);
  
  /*
   * Set the fillet's oriented normal. The fillet normal is evaluated at
   * the mid point of either the u=0 or the u=1 iso curve.
   */
  if (options & EMS_FIL_SURF_ORIENTED)
  {
    v = 0.5;
    for (j = 0; j < 2; j++)
    {
      u = (IGRdouble) j;
      ptr_BSgeom_surf = j ? &BSgeom_surf3 : &BSgeom_surf1;

      BSsfarrevn(&bsrc,
		 BSgeom_fillets->bspsf,
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
	BSgeom_fillets->bspsf->pos_orient =
	  BSdotp(&loc_msg, fillet_normal, surf_normal) > 0 ?
	  ptr_BSgeom_surf->bspsf->pos_orient :
	  !ptr_BSgeom_surf->bspsf->pos_orient;

	break;
      }
    }

    /*
     * If the above process failed, then extract the u=1 curve and
     * find the minimum distance from that curve to surface.
     */
    if (j == 2)
    {
      ptr_bspsf = BSgeom_fillets->bspsf;

      /*
       * Allocate memory for extracting the iso curve.
       */
      BSalloccv(ptr_bspsf->v_order, ptr_bspsf->v_num_poles,
		ptr_bspsf->rational, 0, &isocv, &bsrc);
      BSconstprcv(&bsrc, ptr_bspsf, &opt, &u, &testplnr, isocv);

      /*
       * Now, calculate the minimum distance between isocv and surface.
       */
      BSmdistcvsf(isocv, ptr_BSgeom_surf->bspsf,
		  &num_pts, &par_cv, &par_sf, &pts_cv, &pts_sf,
		  &dist, &bsrc);
      EMerr_hndlr(bsrc != BSSUCC, *EMmsg, EMS_E_BSerror, quit);

      /*
       * Although this should not happen, check it anyway ...
       */
      EMerr_hndlr((fabs(dist) > cht_tol || num_pts < 1),
		  *EMmsg, EMS_E_Fail, quit);

      /*
       * Evaluate surface and fillet normals at the common point.
       */
      BSsfarrevn(&bsrc,
		 ptr_bspsf,
		 1, &u,
		 1, &par_cv[0],
		 fillet_point,
		 fillet_normal);

      BSsfarrevn(&bsrc,
		 ptr_BSgeom_surf->bspsf,
		 1, &par_sf[0],
		 1, &par_sf[1],
		 surf_point,
		 surf_normal);

      /*
       * Orient normal of the fillet according to surface normal
       */
      BSgeom_fillets->bspsf->pos_orient =
	BSdotp(&bsrc, fillet_normal, surf_normal) > 0 ?
        ptr_BSgeom_surf->bspsf->pos_orient :
        !ptr_BSgeom_surf->bspsf->pos_orient;

      /*
       * Free memory allocated.
       */
      BSfreecv(&bsrc, isocv);
      om$dealloc(ptr = par_cv);
      om$dealloc(ptr = par_sf);
      om$dealloc(ptr = pts_cv);
      om$dealloc(ptr = pts_sf);
    }
  }

  /*
   * Create objects for each of the fillets. Determine fillet v0 and v1
   * degeneracy. Impose a natural boundary. Assign output.
   */
  if (fillet_surf_objid)
  {
    construct_list->geometry = (IGRchar *) BSgeom_fillets->bspsf;
    getsfclassid(BSgeom_fillets->type, &classid);

    sts = om$construct(classid = classid,
		       osnum = md_env->md_id.osnum,
		       p_objid = fillet_surf_objid,
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
		    targetid = *fillet_surf_objid,
		    senderid = NULL_OBJID,
		    targetos = md_env->md_id.osnum);
      EMerr_hndlr(!(sts & loc_msg & 1), *EMmsg, loc_msg, quit);
    }
  }

  /*
   * Do the fillets properties.
   */
  if (fillet_surf_prop)
  {
    *fillet_surf_prop = 0;
    ptr_bspsf = BSgeom_fillets->bspsf;
      
    /*
     * Determine degeneracy of the ith fillet on v = 0.
     */
    if (EFpts_degenerate(ptr_bspsf->u_num_poles,
			 ptr_bspsf->poles,
			 ptr_bspsf->weights,
			 3,
			 cht_tol))
      *fillet_surf_prop = EMSfillet_v0_is_degenerate;

    /*
     * Determine the accuracy of the fillet.
     */
    if (BSgeom_fillets->type == BSGEN_BSP_SF)
      *fillet_surf_prop |= EMSfillet_inaccurate_atstart |
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
      *fillet_surf_prop |= EMSfillet_v1_is_degenerate;
  }

  /*
   * Do the fillets geometry.
   */
  if (fillet_surf_geom)
  {
    *fillet_surf_geom = BSgeom_fillets->bspsf;
    BSgeom_fillets->bspsf = NULL;
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
    if (BSgeom_fillets->bspsf)
      BSfreesf(&loc_msg, BSgeom_fillets->bspsf);
    om$dealloc(ptr = BSgeom_fillets);
  }

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

  /*
   * Do preceding for the third surface.
   */
  if (!surface3_geom)
    om$dealloc(ptr = ptr_surf3_geom);
  if (get_plane3 == TRUE)
    BSfreesf(&loc_msg, contain_plane3);

  EMWRAPUP(*EMmsg, sts, "EMcreate_fillet_triple_surfaces");
  return sts;
}

end implementation EMSsubbs;
