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
 
			- EMS_FIL_INT_ROLLING_BALL

			  If set, the fillet surface at the interior
			  corner of a cusp will correspond to a surface
			  produced by a rolling ball at that corner. The
			  default is to extend the two surfaces at the
			  corner and produce two fillets.

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

    radius		- Radius of the fillet.

    extend_dist		- Distance to extend fillet. Set it to 0.0 if no
			  extension is desired.

    fill_pt_ind		- Indicator for creating fillet surfaces which end
			  in a point.

    int_cv_GRid		- struct GRid of the intersection curve.
    int_cv_geom		- struct IGRbsp_curve of the intersection curve.

    start_arc_GRid	- struct GRid of the starting arc.
    start_arc_geom	- struct IGRbsp_curve of the starting arc.

    end_arc_GRid	- struct GRid of the ending arc.
    end_arc_geom	- struct IGRbsp_curve of the ending arc.

    			  For the above intersection curve, starting arc
			  and ending arc, they are optional and can be NULL.

			  If anyone of them is specified, then both GRid
			  and geom are required.

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

    fillet_surf_types   - An array of fillet surface types. The function
                          allocates the output memory. Set it to NULL if not
                          requesting.

    fillet_surf_props   - An array of fillet surface properties. The function
                          allocates the output memory. Set it to NULL if not
                          requesting.

 * OPTIONS

    options		- See options described in the inputs section.

 * NOTES

    fill_pt_ind 	- Can be set FALSE.

 * HISTORY

    SY    : 03/29/93 : creation.
    SY    : 08/27/93 : add more invalid argument checks. Add code to
                       deal with geometry intersection, start arc and
		       end arc curves.
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
#include "bschangepar.h"
#include "bsconfilsrf.h"

#define U 0
#define V 1

#define MAX_TRY 10

#define MID_PARVAL 0.5

extern IGRlong EFget_bscv_type_for_an_edg_type();

from EMSedge import EMget_props_type;

#argsused

IGRlong EMcreate_fillet_surf1_to_surf2_const_rad(EMmsg,
						 options,
						 construct_list,
						 surface1_GRid,
						 surface1_geom,
						 surface2_GRid,
						 surface2_geom,
						 radius,
						 extend_dist,
						 fill_pt_ind,
						 int_cv_GRid,
						 int_cv_geom,
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
						 fillet_surf_types,
						 fillet_surf_props)
IGRlong	*EMmsg; 
IGRushort options;
struct GRvg_construct *construct_list;
struct GRid *surface1_GRid, *surface2_GRid;
struct IGRbsp_surface *surface1_geom, *surface2_geom;
IGRdouble radius, extend_dist, rho_value;
IGRboolean fill_pt_ind, is_chamfer;
struct GRid *int_cv_GRid, *start_arc_GRid, *end_arc_GRid;
struct IGRbsp_curve *int_cv_geom, *start_arc_geom, *end_arc_geom;
IGRpoint ref_pt;
IGRint *num_of_fillets;
GRobjid	**fillet_surf_objids;
struct IGRbsp_surface ***fillet_surf_geoms;
IGRint **fillet_surf_types;
IGRushort **fillet_surf_props;
{
  struct IGRbsp_surface *ptr_surf1_geom, *ptr_surf2_geom;
  struct IGRbsp_surface *contain_plane1, *contain_plane2;
  IGRboolean natural_normal1, natural_normal2;
  IGRboolean get_plane1, get_plane2;
  IGRboolean found;
  struct BSgeom_bsp_surf BSgeom_surf1, BSgeom_surf2;
  struct IGRbsp_curve *ptr_int_cv_geom;
  struct IGRbsp_curve *ptr_start_arc_geom, *ptr_end_arc_geom;
  struct BSgeom_bsp_curve *BSgeom_int_cv, *BSgeom_start_arc, *BSgeom_end_arc;
  IGRdouble default_rho, tolr, cht_tol;
  struct GRmd_env *md_env = NULL;
  IGRshort *mattyp;
  IGRdouble *mat;
  IGRuchar edge_type;
  struct BSgeom_bsp_surf **BSgeom_fillets;
  struct IGRbsp_surface *ptr_bspsf = NULL;
  IGRint csp_opt, num_grps, *num_fillets, *fsf_type;
  IGRint num_pts, total_num_fillets;
  IGRboolean *crv_probs;
  IGRdouble min_dist, dist;
  IGRdouble u, v, fillet_point[3], fillet_normal[3];
  IGRdouble surf_uv[2], surf_point[3], surf_normal[3];
  IGRint i, j, k, index;
  IGRboolean rho_change, reversed, pt_onsurf;
  GRclassid classid;
  GRobjid edge_ids[4];
  IGRlong sts, loc_msg, *cnst_msg;
  BSrc bsrc;

  extern void get_sf_type_for_filleting();
  extern IGRdouble EMsubdivval();
  extern IGRdouble fabs();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  cnst_msg = construct_list->msg;
  num_fillets = NULL;
  crv_probs = NULL;
  fsf_type = NULL;

  /*
   * Initialize
   */
  BSEXTRACTPAR(&loc_msg, BSRHO_VALUE, default_rho);
  BSEXTRACTPAR(&loc_msg, BSTOLCLOSETOZERO, tolr);
  BSEXTRACTPAR(&loc_msg, BSTOLCHRDHT, cht_tol);

  rho_change = FALSE;
  pt_onsurf = FALSE;
  num_pts = 1;
  total_num_fillets = 0;
  
  ptr_surf1_geom = ptr_surf2_geom = NULL;
  contain_plane1 = contain_plane2 = NULL;
  get_plane1 = get_plane2 = FALSE;

  ptr_int_cv_geom = NULL;
  ptr_start_arc_geom = ptr_end_arc_geom = NULL;
  BSgeom_int_cv = BSgeom_start_arc = BSgeom_end_arc = NULL;

  natural_normal1 = options & EMS_FIL_NATURAL_NORMAL1 ? 1 : 0;
  natural_normal2 = options & EMS_FIL_NATURAL_NORMAL2 ? 1 : 0;
  csp_opt = options & EMS_FIL_INT_ROLLING_BALL ? 1 : 2;

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
   * Both GRid of the surfaces are required to get their types for
   * constructing geometry surfaces.
   */
  if (!surface1_GRid || !surface2_GRid)
  {
    *EMmsg = EMS_E_InvalidArg;
    goto quit;
  }

  /*
   * If any of the int_cv, start_arc or end_arc specified, then
   * both GRid and geometry are required.
   */
  if (int_cv_GRid && !int_cv_geom || !int_cv_GRid && int_cv_geom ||
      start_arc_GRid && !start_arc_geom || !start_arc_GRid && start_arc_geom ||
      end_arc_GRid && !end_arc_geom || !end_arc_GRid && end_arc_geom)
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
  if (ptr_int_cv_geom)
  {
    BSgeom_int_cv = (struct BSgeom_bsp_curve *) alloca(sizeof(struct BSgeom_bsp_curve));

    sts = om$send(msg = message EMSedge.EMget_props_type(&loc_msg,
							 NULL,
							 &edge_type),
		  senderid = NULL_OBJID,
		  targetid = int_cv_GRid->objid,
		  targetos = int_cv_GRid->osnum);
    EMerr_hndlr(!(sts & loc_msg & 1), *EMmsg, loc_msg, quit);

    EFget_bscv_type_for_an_edge_type(&BSgeom_int_cv->type, edge_type);
    if ((BSgeom_int_cv->type == BS3DLINESTR ||
	 BSgeom_int_cv->type == BS2DLINESTR) &&
	ptr_int_cv_geom->num_poles == 2)
      BSgeom_int_cv->type = BSLINE;
    
    BSgeom_int_cv->geom_prop = FALSE;
    BSgeom_int_cv->bscv_flag = TRUE;
    BSgeom_int_cv->array1 = NULL;
    BSgeom_int_cv->bspcv = ptr_int_cv_geom;
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
  if (ptr_start_arc_geom)
  {
    BSgeom_start_arc = (struct BSgeom_bsp_curve *) alloca(sizeof(struct BSgeom_bsp_curve));

    sts = om$send(msg = message EMSedge.EMget_props_type(&loc_msg,
							 NULL,
							 &edge_type),
		  senderid = NULL_OBJID,
		  targetid = start_arc_GRid->objid,
		  targetos = start_arc_GRid->osnum);
    EMerr_hndlr(!(sts & loc_msg & 1), *EMmsg, loc_msg, quit);

    EFget_bscv_type_for_an_edge_type(&BSgeom_start_arc->type, edge_type);
    if ((BSgeom_start_arc->type == BS3DLINESTR ||
	 BSgeom_start_arc->type == BS2DLINESTR) &&
	ptr_start_arc_geom->num_poles == 2)
      BSgeom_start_arc->type = BSLINE;
    
    BSgeom_start_arc->geom_prop = FALSE;
    BSgeom_start_arc->bscv_flag = TRUE;
    BSgeom_start_arc->array1 = NULL;
    BSgeom_start_arc->bspcv = ptr_start_arc_geom;
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
  if (ptr_end_arc_geom)
  {
    BSgeom_end_arc = (struct BSgeom_bsp_curve *) alloca(sizeof(struct BSgeom_bsp_curve));

    sts = om$send(msg = message EMSedge.EMget_props_type(&loc_msg,
							 NULL,
							 &edge_type),
		  senderid = NULL_OBJID,
		  targetid = end_arc_GRid->objid,
		  targetos = end_arc_GRid->osnum);
    EMerr_hndlr(!(sts & loc_msg & 1), *EMmsg, loc_msg, quit);

    EFget_bscv_type_for_an_edge_type(&BSgeom_end_arc->type, edge_type);
    if ((BSgeom_end_arc->type == BS3DLINESTR ||
	 BSgeom_end_arc->type == BS2DLINESTR) &&
	ptr_end_arc_geom->num_poles == 2)
      BSgeom_end_arc->type = BSLINE;
    
    BSgeom_end_arc->geom_prop = FALSE;
    BSgeom_end_arc->bscv_flag = TRUE;
    BSgeom_end_arc->array1 = NULL;
    BSgeom_end_arc->bspcv = ptr_end_arc_geom;
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
  if (fabs(extend_dist) <= tolr)
    extend_dist = 0.0;

  /*
   * Call math function to create the fillet surface.
   */
  BSconfilsrf(&BSgeom_surf1, &BSgeom_surf2,
	      radius,
	      natural_normal1, natural_normal2,
	      extend_dist,
	      csp_opt,
	      fill_pt_ind,
	      BSgeom_int_cv,
	      BSgeom_start_arc,
	      BSgeom_end_arc,
	      &num_grps,
	      &num_fillets,
	      &BSgeom_fillets,
	      &crv_probs,
	      &fsf_type,
	      &bsrc);
  EMerr_hndlr(bsrc != BSSUCC, *EMmsg, EMS_E_BSerror, quit);
  
  /*
   * Calculate number of fillet surface created.
   */
  for (i = 0; i < num_grps; i++)
    total_num_fillets += num_fillets[i];

  /*
   * If the option is to return only a single fillet surface, then choose
   * the one which is closest to the 'ref_pt'. Delete the rest.
   */
  if (options & EMS_FIL_SINGLE_FILLET && total_num_fillets > 1)
  {
    if (!ref_pt)
    {
      *EMmsg = EMS_E_InvalidArg;
      goto quit;
    }

    min_dist = MAXDOUBLE;
    index = 0;

    for (i = 0; i < total_num_fillets; i++)
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
    
    for (i = 0; i < total_num_fillets; i++)
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
      if (fsf_type)
	fsf_type[0] = fsf_type[index];
    }
    
    total_num_fillets = 1;
  }

  /*
   * Check the fillets' curvature problem.
   */
  if (options & EMS_FIL_CHECK_CURV_PROB && crv_probs)
  {
    for (i = 0; i < total_num_fillets; i++)
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
    for (i = 0; i < total_num_fillets; i++)
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
                     BSgeom_fillets[i]->bspsf,
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

            BSgeom_fillets[i]->bspsf->pos_orient =
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
    *num_of_fillets = total_num_fillets;

  /*
   * Do the array of fillet objids and natural boundaries.
   */
  if (fillet_surf_objids)
  {
    if (!(*fillet_surf_objids))
    {
      *fillet_surf_objids = (GRobjid *) om$malloc(size = total_num_fillets * sizeof(GRobjid));
      EMerr_hndlr(!(*fillet_surf_objids), *EMmsg, EMS_E_NoDynamicMemory, quit);
    }
    
    for (i = 0; i < total_num_fillets; i++)
    {
      construct_list->geometry = (IGRchar *) BSgeom_fillets[i]->bspsf;
      getsfclassid(BSgeom_fillets[i]->type, &classid);

      sts = om$construct(classid = classid,
			 osnum = md_env->md_id.osnum,
			 p_objid = &(*fillet_surf_objids)[i],
			 msg = message GRgraphics.GRconstruct(construct_list));
      EMerr_hndlr(!(sts & *cnst_msg & 1 ), *EMmsg, *cnst_msg, quit);
      
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
      *fillet_surf_props = (IGRushort *) om$malloc(size = total_num_fillets * sizeof(IGRint));
      EMerr_hndlr(!(*fillet_surf_props), *EMmsg, EMS_E_NoDynamicMemory, quit);
    }
    
    for (i = 0; i < total_num_fillets; i++)
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
      *fillet_surf_geoms = (struct IGRbsp_surface **) om$malloc(size = total_num_fillets * sizeof(struct IGRbsp_surface *));
      EMerr_hndlr(!(*fillet_surf_geoms), *EMmsg, EMS_E_NoDynamicMemory, quit);
    }

    for (i = 0; i < total_num_fillets; i++)
    {
      (*fillet_surf_geoms)[i] = BSgeom_fillets[i]->bspsf;
      BSgeom_fillets[i]->bspsf = NULL;
    }
  }

  /*
   * Do the fillets surface type.
   */
  if (fillet_surf_types)
  {
    if (!(*fillet_surf_types))
    {
      *fillet_surf_types = (IGRint *) om$malloc(size = total_num_fillets * sizeof(IGRint));
      EMerr_hndlr(!(*fillet_surf_types), *EMmsg, EMS_E_NoDynamicMemory, quit);
    }

    for (i = 0; i < total_num_fillets; i++)
      (*fillet_surf_types)[i] = fsf_type[i];
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
  if (num_fillets)
    om$dealloc(ptr = num_fillets);
  
  if (BSgeom_fillets)
  {
    for (i = 0; i < total_num_fillets; i++)
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

  if (fsf_type)
    om$dealloc(ptr = fsf_type);

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
  
  EMWRAPUP(*EMmsg, sts, "EMcreate_fillet_surf1_to_surf2_const_rad");
  return sts;
}

end implementation EMSsubbs;
