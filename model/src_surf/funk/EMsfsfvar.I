/*

 * DESCRIPTION
       
    This function returns the constant radius fillet(s) between the two
    surfaces specified.

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
 
    surface1_GRid	- struct GRid of the first surface.
    surface1_geom	- struct IGRbsp_surface of the first surface.

    surface2_GRid	- struct GRid of the second surface.
    surface2_geom	- struct IGRbsp_surface of the second surface.

			  For each pair above, the GRid is required. Geom
			  is optional and can be set to NULL if not input.

    start_radius	- Starting radius of the fillet.
    end_radius		- Ending radius of the fillet.

    mmradius		- This is used only when starting radius is equal
			  to ending radius and law curve is input.
			  mmradius is used to calculate radius distribution
			  under law curve.

    start_pt		- Point where starting radius is realized.
    end_pt		- Point where ending radius is realized.

    reverse		- For closed fillet, indicating whether to reverse
			  the direction of the fillet surface.
			  If the fillet is open, this is unused.

    extend_dist_start   - Distance to extend fillet at the start.
                          Set it to 0.0 if no extension is desired.

    extend_dist_end     - Distance to extend fillet at the end.
                          Set it to 0.0 if no extension is desired.

    int_cv_GRid		- struct GRid of the intersection curve.
    int_cv_geom		- struct IGRbsp_curve of the intersection curve.

    law_cv_GRid		- struct GRid of the law curve.
    law_cv_geom		- struct IGRbsp_curve of the law curve.

    start_arc_GRid	- struct GRid of the starting arc.
    start_arc_geom	- struct IGRbsp_curve of the starting arc.

    end_arc_GRid	- struct GRid of the ending arc.
    end_arc_geom	- struct IGRbsp_curve of the ending arc.

    			  For the above intersection curve, law curve, 
			  starting arc and ending arc, they can be NULL.
			  If specified, then X_X_GRid and X_X_geom are
			  mutually exclusive.

    fpar0, fpar1	- Relative arc length values (between 0.0 and 1.0)
    			  of int_cv that will be mapped onto the x-axis
			  under the law_cv.

    ctrline_cv		- The center line curve of the fillet. This is
			  either the intersection of the two surfaces or
			  the intersection of the two offset surfaces.
			  This curve should be obtained by calling
			  BSvarfilsfe with opt = 1.
			  If it does not know, set it to NULL. 

    ctrline_type	- Used in conjunction with ctrline_cv.
			  This value should be returned from calling
			  BSvarfilsfe with opt = 1. If ctrline_cv does
			  not pass in, then set it to be 0.

    ref_pt		- Used to filter out all but one of the fillets
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

    EMmsg               - Return codes

                          EMS_S_Success         : Success
                          EMS_E_InvalidArg      : Invalid options/argument
                          EMS_E_SurfaceError    : Surface has problem
                          EMS_E_BSerror         : Math error
                          EMS_E_NoDynamicMemory : No heap memory
                          EMS_E_Fail            : Fail

    num_of_fillets      - Number of fillets returned. Set it to NULL if not
                          requesting.

    fillet_surf_objids  - Array of GRobjids of the fillets. The function
                          allocates the output memory. Set it to NULL if not
                          requesting.

    fillet_surf_geoms   - An array of fillet surface geometries. The function
                          allocates the output memory. Set it to NULL if not
                          requesting.

    fillet_surf_props   - An array of fillet surface properties. The function
                          allocates the output memory. Set it to NULL if not
                          requesting.

 * OPTIONS

    options		- See options described in the inputs section.

 * NOTES

    fpar0, fpar1	- Only be used when law curve is not NULL.

    In typical use when ctrline_cv is unknown, initialize them as follows

    struct IGRbsp_curve *ctrline_cv = NULL;
    IGRshort ctrline_type = 0;

    ... calling ...
    EMcreate_fillet_surf1_to_surf2_var_rad(.., &ctrline_cv, &ctrline_type, ..);


 * HISTORY

    SY    : 07/09/93 : creation.
*/

class implementation EMSsubbs;

#include "bserr.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSrnd.h"
#include "REgencompsf.h"
#include "bssfarrevn.h"
#include "bsprptarrsf.h"
#include "bsmdistcvsf.h"
#include "bsconstprcv.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsfreesf.h"
#include "bsvarfilsrf.h"

#define U 0
#define V 1

#define MAX_TRY 10

#define MID_PARVAL 0.5

extern OMuword OPP_EMSgenbs_class_id;

#argsused

IGRlong EMcreate_fillet_surf1_to_surf2_var_rad(EMmsg,
					       options,
					       construct_list,
					       surface1_GRid,
					       surface1_geom,
					       surface2_GRid,
					       surface2_geom,
					       start_radius,
					       end_radius,
					       mmradius,
					       start_pt,
					       end_pt,
					       reverse,
					       extend_dist_start,
					       extend_dist_end,
					       int_cv_GRid,
					       int_cv_geom,
					       law_cv_GRid,
					       law_cv_geom,
					       start_arc_GRid,
					       start_arc_geom,
					       end_arc_GRid,
					       end_arc_geom,
					       fpar0,
					       fpar1,
					       ctrline_cv,
					       ctrline_type,
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
struct GRid *surface1_GRid, *surface2_GRid;
struct IGRbsp_surface *surface1_geom, *surface2_geom;
IGRdouble start_radius, end_radius, mmradius;
IGRpoint start_pt, end_pt, ref_pt;
struct GRid *int_cv_GRid, *law_cv_GRid, *start_arc_GRid, *end_arc_GRid;
struct IGRbsp_curve *int_cv_geom, *law_cv_geom;
struct IGRbsp_curve *start_arc_geom, *end_arc_geom, **ctrline_cv;
IGRdouble extend_dist_start, extend_dist_end, fpar0, fpar1, rho_value;
IGRboolean reverse, is_chamfer;
IGRshort *ctrline_type;
IGRint *num_of_fillets;
GRobjid	**fillet_surf_objids;
struct IGRbsp_surface ***fillet_surf_geoms;
IGRushort **fillet_surf_props;
{
  struct IGRbsp_surface *ptr_surf1_geom, *ptr_surf2_geom;
  struct IGRbsp_surface *contain_plane1, *contain_plane2;
  IGRboolean natural_normal1, natural_normal2;
  IGRboolean get_plane1, get_plane2;
  IGRboolean found;
  struct BSgeom_bsp_surf BSgeom_surf1, BSgeom_surf2;
  struct IGRbsp_curve *ptr_int_cv_geom, *ptr_law_cv_geom;
  struct IGRbsp_curve *ptr_start_arc_geom, *ptr_end_arc_geom;
  IGRdouble default_rho, tolr, cht_tol;
  struct GRmd_env *md_env = NULL;
  IGRshort *mattyp;
  IGRdouble *mat;
  /*
   * Notice that BSvarfilsfe is the only new filleting function which
   * returns fillet surface in IGRbsp_surface structure instead of
   * BSgeom_bsp_surf structure.
   */
  struct IGRbsp_surface **BSbsp_fillets, *ptr_bspsf = NULL;
  struct BSgeom_bsp_surf BSgeom_fillet;

  IGRint num_fillets, num_pts;
  IGRboolean *crv_probs;
  IGRdouble min_dist, dist;
  IGRdouble u, v, fillet_point[3], fillet_normal[3];
  IGRdouble surf_uv[2], surf_point[3], surf_normal[3];
  IGRint i, j, k, index;
  IGRboolean rho_change, reversed, pt_onsurf;
  GRobjid edge_ids[4];
  IGRlong sts, loc_msg, *cnst_msg;
  BSrc bsrc;

  extern void get_sf_type_for_filleting();
  extern IGRdouble EMsubdivval();
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
  num_fillets = 0;
  
  ptr_surf1_geom = ptr_surf2_geom = NULL;
  contain_plane1 = contain_plane2 = NULL;
  get_plane1 = get_plane2 = FALSE;

  ptr_int_cv_geom = ptr_law_cv_geom = NULL;
  ptr_start_arc_geom = ptr_end_arc_geom = NULL;

  natural_normal1 = options & EMS_FIL_NATURAL_NORMAL1 ? 1 : 0;
  natural_normal2 = options & EMS_FIL_NATURAL_NORMAL2 ? 1 : 0;

  md_env = construct_list->env_info;
  mattyp = &md_env->md_env.matrix_type;
  mat = &md_env->md_env.matrix[0];
  
  BSbsp_fillets = NULL;

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
   * Do the preceeding for the second input surface.
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
   * Get the B-spline geometry of the input intersection curve.
   */
  ptr_int_cv_geom = int_cv_geom;
  if (!ptr_int_cv_geom)
  {
    if (int_cv_GRid)
    {
      sts = EMgetvggeom(&loc_msg, mattyp, mat,
			int_cv_GRid, &ptr_int_cv_geom, NULL);
      EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
    }
  }

  /*
   * Get the B-spline geometry of the law curve.
   */
  ptr_law_cv_geom = law_cv_geom;
  if (!ptr_law_cv_geom)
  {
    if (law_cv_GRid)
    {
      sts = EMgetvggeom(&loc_msg, mattyp, mat,
			law_cv_GRid, &ptr_law_cv_geom, NULL);
      EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
    }
  }

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
   * Set extend distance to 0.0 if it is meant to be.
   */
  if (fabs(extend_dist_start) <= tolr)
    extend_dist_start = 0.0;
  if (fabs(extend_dist_end) <= tolr)
    extend_dist_end = 0.0;

  /*
   * Call math function to create the fillet surface.
   */
  BSvarfilsfe(&BSgeom_surf1, &BSgeom_surf2,
              start_radius, end_radius, mmradius,
	      natural_normal1, natural_normal2,
	      start_pt, end_pt,
	      reverse,
	      extend_dist_start,
	      extend_dist_end,
	      ptr_start_arc_geom,
	      ptr_end_arc_geom,
	      ptr_int_cv_geom,
	      ptr_law_cv_geom,
	      fpar0, fpar1,
	      *ctrline_cv ? 2 : 0,
	      ctrline_type,
              ctrline_cv,
	      &num_fillets,
	      &BSbsp_fillets,
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
      /*
       * initialize BSgeom_bsp_surf structure
       */
      BSgeom_fillet.type = BSGEN_BSP_SF;
      BSgeom_fillet.bounded = TRUE;
      BSgeom_fillet.urange[0] = BSgeom_fillet.vrange[0] = 0.0;
      BSgeom_fillet.urange[1] = BSgeom_fillet.vrange[1] = 1.0;
      BSgeom_fillet.sfgen_cv = NULL;
      BSgeom_fillet.geom_prop = FALSE;
      BSgeom_fillet.bspsf = BSbsp_fillets[i];

      BSprptarrsf(&BSgeom_fillet, cht_tol, 2, 2, &num_pts, ref_pt,
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

      if (BSbsp_fillets[i])
      {
	BSfreesf(&bsrc, BSbsp_fillets[i]);
	BSbsp_fillets[i] = NULL;
      }
    }

    if (index)
    {
      BSbsp_fillets[0] = BSbsp_fillets[index];
      BSbsp_fillets[index] = NULL;
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
   * Set the fillets' oriented normal. The fillet normal is evaluated at
   * the mid point of either the u=0 or the u=1 iso curve.
   */
  if (options & EMS_FIL_SURF_ORIENTED)
  {
    for (i = 0; i < num_fillets; i++)
    {
      found = FALSE;
      for (j = 0; j < 2; j++)
      {
        u = (IGRdouble) j;
        ptr_bspsf = j ? ptr_surf2_geom : ptr_surf1_geom;
	
        for (k = 0; k < MAX_TRY; k++)
        {
          /*
           * Obtain a v-value between 0.0 and 1.0, unique for a
           * given 'k'.
           */

	  v = EMsubdivval (MID_PARVAL, k);

          /*
           * Check to see if this position dictated by the u,v on the
           * fillet is within tolerance of the support surface. If so,
           * obtain the natural normals of the two surfaces at this
           * location.
           */

          BSsfarrevn(&bsrc,
                     BSbsp_fillets[i],
                     1, &u,
                     1, &v,
                     fillet_point,
                     fillet_normal);
          if (bsrc != BSSUCC)
            continue;

          BSmdistptsf(&bsrc,
                      ptr_bspsf,
                      fillet_point,
                      &surf_uv[U], &surf_uv[V],
                      surf_point,
                      &dist);
          if (bsrc != BSSUCC)
            continue;
        
          if (dist < cht_tol)
          {
            BSsfarrevn(&bsrc,
                       ptr_bspsf,
                       1, &surf_uv[U],
                       1, &surf_uv[V],
                       surf_point,
                       surf_normal);
            if (bsrc != BSSUCC)
              continue;

	    /*
             * Set the orientation of the fillet consistent with the
             * support surface.
             */

            BSbsp_fillets[i]->pos_orient =
              BSdotp(&bsrc, fillet_normal, surf_normal) > 0 ?
	       ptr_bspsf->pos_orient : !ptr_bspsf->pos_orient;
            found = TRUE;
            break;
          }
        }
      if (found)
        break;
      }
      EMerr_hndlr (!found, *EMmsg, EMS_E_Fail, quit);
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
      construct_list->geometry = (IGRchar *) BSbsp_fillets[i];

      sts = om$construct(classid = OPP_EMSgenbs_class_id,
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
      ptr_bspsf = BSbsp_fillets[i];
      
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
      (*fillet_surf_geoms)[i] = BSbsp_fillets[i];
      BSbsp_fillets[i] = NULL;
    }
  }

 quit:

  /*
   * If the rho value was changed, then reset it.
   */
  if (rho_change == TRUE)
    BSchangepar(&loc_msg, BSRHO_VALUE, default_rho);

  if (BSbsp_fillets)
  {
    for (i = 0; i < num_fillets; i++)
      if (BSbsp_fillets[i])
	BSfreesf(&loc_msg, BSbsp_fillets[i]);
    om$dealloc(ptr = BSbsp_fillets);
  }

  if (crv_probs)
    om$dealloc(ptr = crv_probs);

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
   * If the intersection curve bspline geometry was constructed 
   * within this function, then remove it.
   */
  if (!int_cv_geom && ptr_int_cv_geom)
    om$dealloc(ptr = ptr_int_cv_geom);
  
  /*
   * If the law curve bspline geometry was constructed 
   * within this function, then remove it.
   */
  if (!law_cv_geom && ptr_law_cv_geom)
    om$dealloc(ptr = ptr_law_cv_geom);
  
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
  
  EMWRAPUP(*EMmsg, sts, "EMcreate_fillet_surf1_to_surf2_var_rad");
  return sts;
}

/*

 * DESCRIPTION
       
    This function returns the center line curve of the varying radius
    fillet. It is used primarily in the place fillet surface command
    object to detect whether the created fillet surface will be a closed
    one or not.

 * HISTORY

    SY    : 07/29/93 : creation.
*/

IGRint EMget_fillet_ctrline(EMmsg,
			    md_env,
			    surface1_GRid,
			    surface1_geom,
			    surface2_GRid,
			    surface2_geom,
			    natural_normal1,
			    natural_normal2,
			    start_radius,
			    end_radius,
			    mmradius,
			    start_pt,
			    end_pt,
			    int_cv_GRid,
			    int_cv_geom,
			    law_cv_GRid,
			    law_cv_geom,
			    start_arc_GRid,
			    start_arc_geom,
			    end_arc_GRid,
			    end_arc_geom,
			    reverse,
			    extend_dist_start,
			    extend_dist_end,
			    rho_value,
			    ctrline_cv,
			    ctrline_type)
IGRlong *EMmsg;
struct GRmd_env *md_env;
struct GRid *surface1_GRid, *surface2_GRid;
struct IGRbsp_surface *surface1_geom, *surface2_geom;
IGRboolean natural_normal1, natural_normal2;
IGRdouble start_radius, end_radius, mmradius;
IGRpoint start_pt, end_pt;
struct GRid *int_cv_GRid, *law_cv_GRid;
struct IGRbsp_curve *int_cv_geom, *law_cv_geom;
struct GRid *start_arc_GRid, *end_arc_GRid;
struct IGRbsp_curve *start_arc_geom, *end_arc_geom;
IGRdouble extend_dist_start, extend_dist_end, rho_value;
struct IGRbsp_curve **ctrline_cv;
IGRshort *ctrline_type;
{
  struct IGRbsp_surface *ptr_surf1_geom, *ptr_surf2_geom;
  struct IGRbsp_surface *contain_plane1, *contain_plane2;
  IGRboolean get_plane1, get_plane2, rho_change, reversed;
  struct BSgeom_bsp_surf BSgeom_surf1, BSgeom_surf2;
  struct IGRbsp_curve *ptr_int_cv_geom, *ptr_law_cv_geom;
  struct IGRbsp_curve *ptr_start_arc_geom, *ptr_end_arc_geom;
  IGRdouble default_rho, tolr;
  IGRshort *mattyp;
  IGRdouble *mat;
  IGRlong loc_msg, sts;
  BSrc bsrc;

  extern void get_sf_type_for_filleting();
  extern IGRdouble fabs();
  
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  /*
   * Initialize
   */
  BSEXTRACTPAR(&loc_msg, BSRHO_VALUE, default_rho);
  BSEXTRACTPAR(&loc_msg, BSTOLCLOSETOZERO, tolr);

  ptr_surf1_geom = surface1_geom;
  ptr_surf2_geom = surface2_geom;
  ptr_int_cv_geom = int_cv_geom;
  ptr_law_cv_geom = law_cv_geom;
  ptr_start_arc_geom = start_arc_geom;
  ptr_end_arc_geom = end_arc_geom;

  contain_plane1 = contain_plane2 = NULL;
  get_plane1 = get_plane2 = FALSE;

  rho_change = FALSE;
  
  mattyp = &md_env->md_env.matrix_type;
  mat = &md_env->md_env.matrix[0];

  /*
   * For the first input surface, construct the surface geometry in a form
   * suitable for math create fillet functions (i.e. construct an instance of
   * struct BSgeom_bsp_surf for the first surface).
   */
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
   * Do the preceeding for the second input surface.
   */
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
   * Get the B-spline geometry of the input intersection curve.
   */
  if (!ptr_int_cv_geom)
  {
    if (int_cv_GRid)
    {
      sts = EMgetvggeom(&loc_msg, mattyp, mat,
                        int_cv_GRid, &ptr_int_cv_geom, NULL);
      EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
    }
  }

  /*
   * Get the B-spline geometry of the law curve.
   */
  if (!ptr_law_cv_geom)
  {
    if (law_cv_GRid)
    {
      sts = EMgetvggeom(&loc_msg, mattyp, mat,
                        law_cv_GRid, &ptr_law_cv_geom, NULL);
      EMerr_hndlr(!(loc_msg & sts & 1), *EMmsg, loc_msg, quit);
    }
  }

  /*
   * Get the B-spline geometry of the input starting arc.
   */
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
  if (fabs(rho_value - default_rho) > tolr)
  {
    BSchangepar(&loc_msg, BSRHO_VALUE, rho_value);
    rho_change = TRUE;
  }

  /*
   * Set extend distance to 0.0 if it is meant to be.
   */
  if (fabs(extend_dist_start) <= tolr)
    extend_dist_start = 0.0;
  if (fabs(extend_dist_end) <= tolr)
    extend_dist_end = 0.0;

  BSvarfilsfe(&BSgeom_surf1, &BSgeom_surf2,
              start_radius, end_radius, mmradius,
              natural_normal1, natural_normal2,
              start_pt, end_pt,
              reverse,
              extend_dist_start,
              extend_dist_end,
              ptr_start_arc_geom,
              ptr_end_arc_geom,
              ptr_int_cv_geom,
              ptr_law_cv_geom,
              0.0, 1.0,
              1,
	      ctrline_type,
              ctrline_cv,
              NULL,
	      NULL,
	      NULL,
              &bsrc);
  EMerr_hndlr(bsrc != BSSUCC, *EMmsg, EMS_E_BSerror, quit);

 quit:

  /*
   * If the rho value was changed, then reset it.
   */
  if (rho_change == TRUE)
    BSchangepar(&loc_msg, BSRHO_VALUE, default_rho);

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
   * If the intersection curve bspline geometry was constructed
   * within this function, then remove it.
   */
  if (!int_cv_geom && ptr_int_cv_geom)
    om$dealloc(ptr = ptr_int_cv_geom);

  /*
   * If the law curve bspline geometry was constructed
   * within this function, then remove it.
   */
  if (!law_cv_geom && ptr_law_cv_geom)
    om$dealloc(ptr = ptr_law_cv_geom);

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

  EMWRAPUP(*EMmsg, sts, "EMget_fillet_ctrline");
  return sts;
}

end implementation EMSsubbs;
