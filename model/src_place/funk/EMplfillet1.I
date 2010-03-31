/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a fillet between 2 sufaces/among 3
 *  surfaces/curve and surface. These can be placed as associative or
 *  non-associative entities.
 *
 * INPUTS:
 *
 *  assoc_opts		- EMSasconst_notassociative
 *			  Non-associative fillet surface. Default is to place
 *			  associative fillet surface.
 *
 *  fillet_type		- The type of fillet surface wanted. Currently, there
 *			  are seven types (1 - 7):
 *
 *			  fillet_type == 1:
 *
 *			  Place a constant radius fillet surface between two
 *			  surfaces adjacent to the edge (input as element1)
 *
 *			  UNUSED ARGUMENTS (set to NULL):
 *			  element2, element3, end_radius, mm_radius,
 *                        start_point, end_point, law_curve, reverse,
 *                        ctrline_cv, ctrline_type.
 *
 *			  fillet_type == 2:
 *
 *			  Place a constant radius fillet surface between two
 *			  input surfaces (input as element1 and element2).
 *
 *			  UNUSED ARGUMENTS (set to NULL):
 *			  element3, end_radius, mm_radius, start_point,
 *                        end_point, law_curve, reverse, ctrline_cv,
 *                        ctrline_type.
 *
 *			  fillet_type == 3:
 *
 *			  Place a variable radius fillet surface between two
 *			  surfaces adjacent to the edge (input as element1)
 *
 *			  UNUSED ARGUMENTS (set to NULL):
 *			  element2, element3, start_point, end_point.
 *
 *                        OPTIONAL ARGUMENTS
 *                        mm_radius is need only when start_radius is equal
 *                        to end_radius and law_curve is input.
 *                        If law_curve is NULL, then start_radius cannot be
 *                        equal to end_radius.
 *                        Normally, ctrline_cv and ctrline_type should be set
 *                        to NULL. In case, ctrline_cv and ctrline_type are
 *                        input, they should be obtained from calling
 *                        BSvarfilsrf with opt = 1.
 *
 *			  fillet_type == 4:
 *
 *			  Place a variable radius fillet surface between two
 *			  input surfaces (input as element1 and element2).
 *
 *			  UNUSED ARGUMENTS for default option (set to NULL):
 *			  element3.
 *
 *                        OPTIONAL ARGUMENTS
 *                        See the edge case.
 *
 *			  fillet_type == 5:
 *
 *			  Place a fillet surface between a curve (input as
 *			  element1), surface1 (input as element2) containing
 *			  the curve and another surface2 (input as element3).
 *			  The fillet surface will be tangent to surface1 along
 *			  the curve.
 *
 *			  ARGUMENT UNUSED (set to NULL):
 *			  start_radius, end_radius, mm_radius, start_point,
 *                        end_point, end_radius, ext_distance, law_curve,
 *                        reverse, ctrline_cv, ctrline_type.
 *			  
 *			  fillet_type == 6:
 *
 *			  Place a constant radius fillet surface between a
 *			  curve (input as element1) and a surface (input as
 *			  element2) with a radius (input as start_radius).
 *
 *			  ARGUMENTS UNUSED (set to NULL):
 *			  element3, end_radius, mm_radius, start_point,
 *                        end_point, end_radius, ext_distance, law_curve,
 *                        reverse, ctrline_cv, ctrline_type.
 *
 *			  fillet_type == 7:
 *
 *			  Place a fillet surface among three surfaces (input
 *			  as element1-3). The fillet starts from surface1 and
 *			  ends at surface3.
 *
 *			  ARGUMENTS UNUSED (set to NULL):
 *			  start_radius, end_radius, mm_radius, start_point,
 *                        end_point, law_curve, reverse, ctrline_cv,
 *                        ctrline_type.
 *
 *  fillet_opts		- EMS_FIL_NATURAL_NORMAL1
 *			- EMS_FIL_NATURAL_NORMAL2
 *			- EMS_FIL_NATURAL_NORMAL3
 *			  Filleting on the natural normal side of the surface.
 *                        When the input element is an edge, then natural
 *                        normals of the two surfaces are determined inside
 *                        the program. If fillet_type is 6, then natural
 *                        normal is the curve side indicator indicating to
 *                        which side of the curve to place a fillet surface.
 *
 *                      - EMS_FIL_DEFAULT_RHO
 *                        Use default rho for constructing fillet surface.
 *                        This option  overrides the rho value input.
 *
 *			- EMS_FIL_SURF_ORIENTED
 *                        If set, the fillet surface will be oriented to be
 *                        consistent with the first surface.
 *
 *                      - EMS_FIL_BOUND_SURF
 *                        If set, then a natural loopset will be imposed on
 *                        each of the fillet surfaces.
 *
 *			- EMS_FIL_INT_ROLLING_BALL
 *			  Do rolling ball at interior cusp. The default is to
 *			  extend two fillet surfaces. This option is only used
 *			  for fillet_type = 1 or 2.
 *
 *                      - EMS_FIL_FLIP_EDGE_ENDS
 *                        This option is only used in varying radius filleting
 *                        when edge was located and law curve was input. If
 *                        set, then intersection curve, which is the edge,
 *                        will be reverse oriented and start point and end
 *                        point are swapped.
 *
 *                      - EMS_FIL_CHECK_CURV_PROB
 *                        If set, check to see whether any of the fillets have
 *                        a curvature problem, and if so, error out. This
 *                        option is only used for fillet_type = 1, 2, 3, 4, 6.
 *
 *  mdenv		- Module environment.
 *  level		- Layer.
 *  disp		- Color, weight and style.
 *  dispattr		- Display attributes.
 *  objname		- Object name
 *			  The above are used to call EMgetvgcnstr to get
 *                        vg construct list.
 *
 *  element1
 *  element2
 *  element3		- Input objects. See notes in fillet_type for detail.
 *
 *  start_radius
 *  end_radius
 *  mm_radius	        - Input radius. See notes in fillet_type for detail.
 *
 *  start_point
 *  end_point		- Input endpoints. Only for fillet_type = 4.
 *
 *  ext_distance	- Extend distance. Don't apply to fillet_type = 5, 6.
 *
 *  rho_value		- Rho value for constructing fillet surface.
 *
 *  is_chamfer		- TRUE: chamfer; FALSE: otherwise.
 *
 *  reverse		- Used only when the fillet surface is closed.
 *			  The open/close can be detected by calling
 *                        BSvarfilsrf when opt = 1. This applies to
 *                        fillet_type = 3, 4 only
 *
 *  ctrline_cv
 *  ctrline_type	- These should be NULL normally. The valid input
 *                        should be the output from calling BSvarfilsrf with
 *                        opt = 1. This applies to fillet_type = 3, 4 only.
 *
 * OUTPUT
 *
 *  filobj		- Object id of the constructed fillet surface.
 *
 *  msg                 - Return codes
 *                        EMS_S_Success         : Success
 *                        EMS_E_InvalidArg      : Invalid options/argument
 *                        EMS_E_SurfaceError    : Surface has problem
 *                        EMS_E_BSerror         : Math error
 *                        EMS_E_NoDynamicMemory : No heap memory
 *                        EMS_E_Fail            : Fail
 *
 * HISTORY:
 *
 *  SY   : If edge located for filleting, pass edge xyz geometry as
 *         intersection curve for constant and varying radius fillet
 *         routines : 08/25/93
 *  SY   : more description for arguments : 08/13/93
 *  SY   : add EDGE_RAD and EDGE_R1_R2 types : 07/23/93
 *  SY   : add header : 03/13/93
 *  SY   : rework the function in line with new math functions : 03/12/93
 *  Janaka : set 'loc_fillets = NULL' : 10/05/92
 *  DLB  : support txt-w-leader  9/15/91
 *  jhw  :  Creation  :  03/20/91
 */
class implementation EMSgencompsf;

#include "bserr.h"
#include "bsparameters.h"
#include "ex.h"
#include "msmacros.h"
#include "DIdef.h"
#include "EMSfillet.h"
#include "bsdistptpt.h"
#include "bsrev_cv.h"

#define EDGE_RAD 1
#define SF_SF_RAD 2
#define EDGE_R1_R2 3
#define SF_SF_R1_R2 4
#define SF_SF_CV 5
#define SF_CV_RAD 6
#define SF_SF_SF 7

from EMSedge import EMgetsurface_info, EMchkconvex;
from EMSedge import EMget_bcxyz_geom, EMxyz_endpt;

IGRlong EMplace_fillet1(msg,
			assoc_opts,
			fillet_type,
			fillet_opts,
			mdenv, 
			level, 
			disp, 
			dispattr, 
			objname,
			element1,
			element2,
			element3,
			start_radius,
			end_radius,
			mm_radius,
			start_point,
			end_point,
			ext_distance,
			law_curve,
			rho_value,
			is_chamfer,
			reverse,
			ctrline_cv,
			ctrline_type,
			filobj)
IGRlong                *msg;
IGRushort              assoc_opts, fillet_opts;
IGRint                 fillet_type;
struct GRmd_env        *mdenv;
IGRshort               level, ctrline_type;
struct IGRdisplay      *disp;
IGRchar                *dispattr, *objname;
struct EMSobject_info  *element1, *element2, *element3;
struct EMSpoint_info   *start_point, *end_point;
struct EMSvalue_info   *start_radius, *end_radius, *mm_radius;
struct EMSvalue_info   *ext_distance, *rho_value;
struct EMSobject_info  *law_curve;
IGRboolean             is_chamfer, reverse;
struct IGRbsp_curve    *ctrline_cv;
GRobjid                *filobj;
{
  struct GRmd_env loc_mdenv;
  IGRchar loc_name[DI_PATH_MAX];
  struct IGRdisplay loc_disp;
  struct GRvg_construct vgcnstr;
  GRspacenum constros;
  IGRshort mattyp;
  IGRdouble *mat;
  struct IGRbsp_curve *int_cv_geom = NULL;
  IGRint i;
  IGRlong loc_msg, stat_func, sts;
  extern void EMinitvgcnstr();
  extern IGRboolean EMgetvgcnstr();
  extern IGRlong EMgetparptobj(), EMgetparvalobj();
  extern IGRlong EMcreate_fillet_surf1_to_surf2_const_rad();
  extern IGRlong EMcreate_fillet_surf1_to_surf2_var_rad();
  extern IGRlong EMcreate_fillet_cv_on_surf1_to_surf2();
  extern IGRlong EMcreate_fillet_curve_to_surface();
  extern IGRlong EMcreate_fillet_triple_surfaces();

  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  
  /*
   * Check fillet type
   */
  if (fillet_type < EDGE_RAD || fillet_type > SF_SF_SF)
  {
    *msg = EMS_E_InvalidArg;
    goto quit;
  }

  /*
   * Initialize
   */
  EMinitvgcnstr(&loc_msg, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
  stat_func = EMgetvgcnstr(assoc_opts, EMSgrid, mdenv, level, disp, dispattr, objname, &vgcnstr);
  EMerr_hndlr(!stat_func, *msg, EMS_E_Fail, quit);

  constros = vgcnstr.env_info->md_id.osnum;
  mattyp = vgcnstr.env_info->md_env.matrix_type;
  mat = vgcnstr.env_info->md_env.matrix;

  /*
   * Branch depending on associativity
   */
  if (assoc_opts & EMSasconst_notassociative)
  {
    IGRdouble loc_rho_value, loc_ext_distance, tolr1;
    IGRdouble loc_start_rad, loc_end_rad, loc_mm_rad;
    IGRpoint loc_start_point, loc_end_point, tmp_point;
    IGRboolean convex, neutral, normal, closed;
    struct GRid sf1_GRid, sf2_GRid, *int_cv_GRid;
    OM_S_CHANSELECT edge_chan;
    OM_S_OBJECT_LINKAGE edge_link;
    OMuint edge_count;
    IGRint num_fillets;
    struct IGRbsp_surface *surf_geom;
    GRobjid *loc_fillets;
    
    BSEXTRACTPAR(&loc_msg, BSTOLLENVEC, tolr1);

    loc_rho_value = 0.0;
    loc_ext_distance = 0.0;
    int_cv_GRid = NULL;
    closed = FALSE;
    loc_fillets = NULL;

    if (!is_chamfer)
    {
      sts = EMgetparval_numeric(&loc_msg, rho_value, &loc_rho_value);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
    }

    /*
     * When doing constant or varying radius filleting on an edge, we
     * need to get the two faces adjacent to the edge first.
     */
    if (fillet_type == EDGE_RAD || fillet_type == EDGE_R1_R2)
    {
      sts = om$send(msg = message EMSedge.EMgetsurface_info(&loc_msg,
							    &sf1_GRid.objid,
							    NULL),
		    senderid = NULL_OBJID,
		    targetid = element1->grid.objid,
		    targetos = element1->grid.osnum);
      EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
      sf1_GRid.osnum = element1->grid.osnum;
	
      sts = om$make_chanselect(channame = "EMSedge.to_common_edge",
			       p_chanselect = &edge_chan);
      EMerr_hndlr(EMSerror(sts), sts, OM_E_ABORT, quit);

      sts = om$get_channel_objects(objid = element1->grid.objid,
				   osnum = element1->grid.osnum,
				   p_chanselect = &edge_chan,
				   size = 1,
				   list = &edge_link,
				   count = &edge_count);
      EMerr_hndlr(EMSerror(sts), sts, OM_E_ABORT, quit);
      
      sts = om$send(msg = message EMSedge.EMgetsurface_info(&loc_msg,
							    &sf2_GRid.objid,
							    NULL),
		    senderid = NULL_OBJID,
		    targetid = edge_link.S_objid,
		    targetos = element1->grid.osnum);
      EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
      sf2_GRid.osnum = element1->grid.osnum;

      /*
       * Having got two surfaces, we need to determine the normals
       * of the surface where fillet surface will be placed. This
       * is achieved by determining the convexity of the edge and
       * computing a dot product of the normals.
       */
      sts = om$send(msg = message EMSedge.EMchkconvex(&loc_msg,
						      EMSchkconvex_nextgeomsf,
						      &element1->env.md_env.matrix_type,
						      element1->env.md_env.matrix,
						      EMS_ZEROANGLE_DEG_MAX,
						      &convex,
						      &neutral,
						      NULL),
		    senderid = NULL_OBJID,
		    targetid = element1->grid.objid,
		    targetos = element1->grid.osnum);
      EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

      /* we do not process neutral edge */
      if (neutral == TRUE)
      {
	*msg = EMS_Fil_NeutralEdge;
	sts = OM_E_ABORT;
	goto quit;
      }

      /*
       * determine the side of the first surface (normal1)
       * where fillet will be placed
       */
      surf_geom = NULL;
      sts = EMgetvggeom(&loc_msg,
			&element1->env.md_env.matrix_type,
			element1->env.md_env.matrix,
			&sf1_GRid,
			&surf_geom,
			NULL);
      EMerr_hndlr(!(loc_msg & sts & 1), *msg, loc_msg, quit);

      normal = convex ? surf_geom->pos_orient : !surf_geom->pos_orient;
      if (normal)
	fillet_opts |= EMS_FIL_NATURAL_NORMAL1;
      else
	fillet_opts &= ~EMS_FIL_NATURAL_NORMAL1;
      om$dealloc(ptr = surf_geom);

      /*
       * determine the side of the second surface (normal2)
       * where fillet will be placed
       */
      surf_geom = NULL;
      sts = EMgetvggeom(&loc_msg,
			&element1->env.md_env.matrix_type,
			element1->env.md_env.matrix,
			&sf2_GRid,
			&surf_geom,
			NULL);
      EMerr_hndlr(!(loc_msg & sts & 1), *msg, loc_msg, quit);

      normal = convex ? surf_geom->pos_orient : !surf_geom->pos_orient;
      if (normal)
	fillet_opts |= EMS_FIL_NATURAL_NORMAL2;
      else
	fillet_opts &= ~EMS_FIL_NATURAL_NORMAL2;
      om$dealloc(ptr = surf_geom);

      /*
       * Extrace the xyz geometry of the edge to be passed in as the
       * intersection curve.
       */
      int_cv_geom = (struct IGRbsp_curve *) alloca(sizeof(struct IGRbsp_curve));
      int_cv_geom->poles = NULL;
      int_cv_geom->knots = NULL;
      int_cv_geom->weights = NULL;
      sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&loc_msg,
							   &element1->env.md_env,
							   &sf1_GRid,
							   NULL,
							   0,
							   MAXINT,
							   FALSE,
							   NULL,
							   int_cv_geom),
		    senderid = NULL_OBJID,
		    targetid = element1->grid.objid,
		    targetos = element1->grid.osnum);
      EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

      int_cv_GRid = &element1->grid;
		    
      /*
       * If this is varying radii filleting, then we need to further
       * extract the end points of the edge to be used as the starting
       * and ending points.
       */
      if (fillet_type == EDGE_R1_R2)
      {
	sts = om$send(msg = message EMSedge.EMxyz_endpt(&loc_msg,
							NULL,
							&element1->env.md_env,
							NULL,
							NULL,
							loc_start_point,
							loc_end_point,
							NULL),
		      senderid = NULL_OBJID,
		      targetid = element1->grid.objid,
		      targetos = element1->grid.osnum);
	EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

	if (BSdistptpt(&loc_msg, loc_start_point, loc_end_point) < tolr1)
	  closed = TRUE;
	else
	{
	  reverse = FALSE;
	  if (law_curve && (fillet_opts & EMS_FIL_FLIP_EDGE_ENDS))
	  {
	    memcpy(tmp_point, loc_start_point, sizeof(IGRpoint));
	    memcpy(loc_start_point, loc_end_point, sizeof(IGRpoint));
	    memcpy(loc_end_point, tmp_point, sizeof(IGRpoint));
	    BSrev_cv(&loc_msg, int_cv_geom);
	  }
	}
      }
    }

    switch (fillet_type)
    {
    case SF_SF_RAD:
      sf1_GRid = element1->grid;
      sf2_GRid = element2->grid;
      /*
       * no BREAK here
       */
    case EDGE_RAD:
      /* radius is stored in start_radius for constant radius filleting */
      sts = EMgetparval_numeric(&loc_msg, start_radius, &loc_start_rad);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      if (ext_distance)
      {
	sts = EMgetparval_numeric(&loc_msg, ext_distance, &loc_ext_distance);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	/* loc_ext_distance is now a ratio instead of absolute distance */
	loc_ext_distance *= loc_start_rad;
      }

      stat_func = EMcreate_fillet_surf1_to_surf2_const_rad(&loc_msg,
							   fillet_opts,
							   &vgcnstr,
							   &sf1_GRid,
							   NULL,
							   &sf2_GRid,
							   NULL,
							   loc_start_rad,
							   loc_ext_distance,
							   FALSE,
							   int_cv_GRid,
							   int_cv_geom,
							   NULL,
							   NULL,
							   NULL,
							   NULL,
							   NULL,
							   is_chamfer,
							   loc_rho_value,
							   &num_fillets,
							   &loc_fillets,
							   NULL,
							   NULL,
							   NULL);
      break;
      
    case SF_SF_R1_R2:
      sf1_GRid = element1->grid;
      sf2_GRid = element2->grid;

      sts = EMgetparpt_numeric(&loc_msg, start_point, loc_start_point);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      sts = EMgetparpt_numeric(&loc_msg, end_point, loc_end_point);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      /*
       * no BREAK here
       */
    case EDGE_R1_R2:
      sts = EMgetparval_numeric(&loc_msg, start_radius, &loc_start_rad);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      /*
       * end_radius is NULL only if edge is closed.
       */
      if (end_radius)
      {
	sts = EMgetparval_numeric(&loc_msg, end_radius, &loc_end_rad);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
      }
      else
	loc_end_rad = loc_start_rad;

      if (mm_radius)
      {
	sts = EMgetparval_numeric(&loc_msg, mm_radius, &loc_mm_rad);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
      }

      if (ext_distance)
      {
	sts = EMgetparval_numeric(&loc_msg, ext_distance, &loc_ext_distance);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	/* loc_ext_distance is now a ratio instead of absolute distance */
	if ((loc_start_rad < loc_end_rad && loc_start_rad != 0.0) ||
	    loc_end_rad == 0.0)
	  loc_ext_distance *= loc_start_rad;
	else
	  loc_ext_distance *= loc_end_rad;
      }

      stat_func = EMcreate_fillet_surf1_to_surf2_var_rad(&loc_msg,
							 fillet_opts,
							 &vgcnstr,
							 &sf1_GRid,
							 NULL,
							 &sf2_GRid,
							 NULL,
							 loc_start_rad,
							 loc_end_rad,
							 loc_mm_rad,
							 loc_start_point,
							 loc_end_point,
							 reverse,
							 loc_ext_distance,
							 loc_ext_distance,
							 int_cv_GRid,
							 int_cv_geom,
							 (law_curve ?
							  &law_curve->grid :
							  NULL),
							 NULL,
							 NULL,
							 NULL,
							 NULL,
							 NULL,
							 0.0,
							 1.0,
							 &ctrline_cv,
							 &ctrline_type,
							 NULL,
							 is_chamfer,
							 loc_rho_value,
							 &num_fillets,
							 &loc_fillets,
							 NULL,
							 NULL);
      break;

    case SF_CV_RAD:
      sts = EMgetparval_numeric(&loc_msg, start_radius, &loc_start_rad);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      stat_func = EMcreate_fillet_curve_to_surface(&loc_msg,
						   fillet_opts,
						   &vgcnstr,
						   &element1->grid,
						   NULL,
						   &element2->grid,
						   NULL,
						   loc_start_rad,
						   NULL,
						   NULL,
						   NULL,
						   NULL,
						   NULL,
						   is_chamfer,
						   loc_rho_value,
						   &num_fillets,
						   &loc_fillets,
						   NULL,
						   NULL);
      break;

    case SF_SF_CV:
      stat_func = EMcreate_fillet_cv_on_surf1_to_surf2(&loc_msg,
						       fillet_opts,
						       &vgcnstr,
						       &element1->grid,
						       NULL,
						       &element2->grid,
						       NULL,
						       &element3->grid,
						       NULL,
						       is_chamfer,
						       loc_rho_value,
						       &num_fillets,
						       &loc_fillets,
						       NULL,
						       NULL);
      break;
      
    case SF_SF_SF:
      if (ext_distance)
      {
	sts = EMgetparval_numeric(&loc_msg, ext_distance, &loc_ext_distance);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
      }

      loc_fillets = (GRobjid *) om$malloc(size = sizeof(GRobjid));
      num_fillets = 1;
      
      stat_func = EMcreate_fillet_triple_surfaces(&loc_msg,
						  fillet_opts,
						  &vgcnstr,
						  &element1->grid,
						  NULL,
						  &element2->grid,
						  NULL,
						  &element3->grid,
						  NULL,
						  loc_ext_distance,
						  NULL,
						  NULL,
						  is_chamfer,
						  loc_rho_value,
						  loc_fillets,
						  NULL,
						  NULL);
      break;
    }
    if (loc_msg == EMS_E_InvalidArg || loc_msg == EMS_E_SurfaceError ||
	loc_msg == EMS_E_BSerror || loc_msg == EMS_E_NoDynamicMemory ||
	loc_msg == EMS_E_Fail)
    {
      *msg = EMS_E_Fail;
      goto quit;
    }

    if (num_fillets > 1)
    {
      sts = EFbuild_graphic_group(num_fillets, 
				  loc_fillets, 
				  NULL, 
				  &vgcnstr,
				  filobj,
				  &loc_msg);
      if (EMSerror(sts & loc_msg))
      {
	for (i = 0; i < num_fillets; i++)
	  om$send(msg = message GRgraphics.GRdelete(&loc_msg,
						    vgcnstr.env_info),
		  targetid = loc_fillets[i],
		  targetos = constros,
		  senderid = NULL_OBJID);
      }
    }
    else
      *filobj = *loc_fillets;

    if (loc_fillets)
      free(loc_fillets);
  }
  else
  {
    struct EMSobject_info parobjs[12];
    IGRint fil_surf_type, num_objs;
    struct EMSfillet_surface_new fil_info;

    num_objs = 0;
    fil_surf_type = 0;	/* shut up compiler warning */

    fil_info.props = fillet_opts;
    fil_info.view_index = NO_VIEW;
    fil_info.reverse = reverse;
    BSEXTRACTPAR(&loc_msg, BSTOLCHRDHT, fil_info.cht_tol);

    /*
     * if ext_distance does not pass in, then create one since
     * we want to make it a parent
     */
    if (fillet_type == EDGE_RAD || fillet_type == SF_SF_RAD ||
	fillet_type == EDGE_R1_R2 || fillet_type == SF_SF_R1_R2 ||
        fillet_type == SF_SF_SF)
    {
      if (!ext_distance)
      {
	ext_distance = (struct EMSvalue_info *) alloca(sizeof(struct EMSvalue_info));
	ext_distance->type = EMSdatainfo_numeric;
	ext_distance->val = 0.0;
      }
    }

    switch (fillet_type)
    {
    case EDGE_RAD:
    case SF_SF_RAD:
      memcpy(&parobjs[num_objs++], element1, sizeof(struct EMSobject_info));

      if (fillet_type == SF_SF_RAD)
      {
	fil_surf_type = EMS_ASfillet_by_surface_surface_radius;
	memcpy(&parobjs[num_objs++], element2, sizeof(struct EMSobject_info));
      }
      else
	fil_surf_type = EMS_ASfillet_by_edge_radius; 
      
      /* radius is stored in start_radius for constant radius filleting */
      sts = EMgetparval_object(&loc_msg, constros, NULL, start_radius, &parobjs[num_objs++]);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
      
      sts = EMgetparval_object(&loc_msg, constros, NULL, ext_distance, &parobjs[num_objs++]);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      sts = EMgetparval_object(&loc_msg, constros, NULL, rho_value, &parobjs[num_objs++]);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
      break;
      
    case EDGE_R1_R2:
    case SF_SF_R1_R2:
      memcpy(&parobjs[num_objs++], element1, sizeof(struct EMSobject_info));

      if (fillet_type == SF_SF_R1_R2)
      {
	fil_surf_type = EMS_ASfillet_by_surface_surface_radii;
	memcpy(&parobjs[num_objs++], element2, sizeof(struct EMSobject_info));

	sts = EMgetparval_object(&loc_msg, constros, NULL, ext_distance, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	sts = EMgetparval_object(&loc_msg, constros, NULL, rho_value, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	sts = EMgetparval_object(&loc_msg, constros, NULL, start_radius, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	sts = EMgetparval_object(&loc_msg, constros, NULL, end_radius, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	sts = EMgetparpt_object(&loc_msg, mattyp, mat, constros, start_point, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	sts = EMgetparpt_object(&loc_msg, mattyp, mat, constros, end_point, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
      
	if (law_curve)
	  memcpy(&parobjs[num_objs++], law_curve, sizeof(struct EMSobject_info));

	if (mm_radius)
	{
	  sts = EMgetparval_object(&loc_msg, constros, NULL, mm_radius, &parobjs[num_objs++]);
	  EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
	}
      }
      else
      {
	fil_surf_type = EMS_ASfillet_by_edge_radii;

	sts = EMgetparval_object(&loc_msg, constros, NULL, ext_distance, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	sts = EMgetparval_object(&loc_msg, constros, NULL, rho_value, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	sts = EMgetparval_object(&loc_msg, constros, NULL, start_radius, &parobjs[num_objs++]);
	EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

	if (end_radius)
	{
	  sts = EMgetparval_object(&loc_msg, constros, NULL, end_radius, &parobjs[num_objs++]);
	  EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
	}

	if (mm_radius)
	{
	  sts = EMgetparval_object(&loc_msg, constros, NULL, mm_radius, &parobjs[num_objs++]);
	  EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
	}

	if (law_curve)
	  memcpy(&parobjs[num_objs++], law_curve, sizeof(struct EMSobject_info));
      }
      break;

    case SF_CV_RAD:
      fil_surf_type = EMS_ASfillet_by_curve_surface_radius; 
      memcpy(&parobjs[0], element1, sizeof(struct EMSobject_info));
      memcpy(&parobjs[1], element2, sizeof(struct EMSobject_info));

      sts = EMgetparval_object(&loc_msg, constros, NULL, start_radius, &parobjs[2]);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      sts = EMgetparval_object(&loc_msg, constros, NULL, rho_value, &parobjs[3]);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      num_objs = 4;
      break;

    case SF_SF_CV:
      fil_surf_type = EMS_ASfillet_by_curve_surface_surface;
      memcpy(&parobjs[0], element1, sizeof(struct EMSobject_info));
      memcpy(&parobjs[1], element2, sizeof(struct EMSobject_info));
      memcpy(&parobjs[2], element3, sizeof(struct EMSobject_info));

      sts = EMgetparval_object(&loc_msg, constros, NULL, rho_value, &parobjs[3]);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      num_objs = 4;
      break;

    case SF_SF_SF:
      fil_surf_type = EMS_ASfillet_by_triple_surfaces;
      memcpy(&parobjs[0], element1, sizeof(struct EMSobject_info));
      memcpy(&parobjs[1], element2, sizeof(struct EMSobject_info));
      memcpy(&parobjs[2], element3, sizeof(struct EMSobject_info));

      sts = EMgetparval_object(&loc_msg, constros, NULL, ext_distance, &parobjs[3]);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      sts = EMgetparval_object(&loc_msg, constros, NULL, rho_value, &parobjs[4]);
      EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);

      num_objs = 5;
      break;
    }

    sts = om$construct(classid = OPP_EMSgencompsf_class_id,
		       msg = message EMSassoc.EMinit_associative 
		       (&loc_msg,
			assoc_opts & ~EMSasconst_recompute,
			num_objs, 
			parobjs, 
			fil_surf_type,
			sizeof(struct EMSfillet_surface_new),
			(IGRchar *) &fil_info,
			&vgcnstr),
		       osnum = constros, 
		       p_objid = filobj);
    EMerr_hndlr(EMSerror(loc_msg & sts), *msg, EMS_E_Fail, quit);
  }

 quit:
  if (int_cv_geom)
  {
    if (int_cv_geom->poles)
      free(int_cv_geom->poles);
    if (int_cv_geom->knots)
      free(int_cv_geom->knots);
    if (int_cv_geom->weights)
      free(int_cv_geom->weights);
  }
  
  EMWRAPUP(*msg, sts, "EMplace_fillet1");
  return sts;
}

end implementation EMSgencompsf;
