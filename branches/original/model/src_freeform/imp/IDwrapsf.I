class implementation IDwrap;

#include <stdio.h>
#include <math.h>
/* #include <values.h> */
#include "OMlimits.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "griodef.h"
#include "grio.h"
#include "grmacros.h"
#include "grownerdef.h"

#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "adpdef.h"
#include "dpstruct.h"
#include "bs.h"
#include "bsvalues.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bserr.h"
#include "IDffmsg.h"
#include "bscrossp.h"    /* prototypes */
#include "bsdotp.h"    /* prototypes */
#include "bslenvec.h"    /* prototypes */
#include "bslenvecsq.h"    /* prototypes */
#include "bsmkvec.h"    /* prototypes */
#include "bsnorvec.h"    /* prototypes */
#include "bsxtractpar.h"    /* prototypes */
#include "bscyl_prop.h"	/* prototypes */
#include "bscone_prop.h"    /* prototypes */
#include "bssph_prop.h"	/* prototypes */
#include "bssfeval.h"    /* prototypes */
#include "bschtptstco.h"    /* prototypes */
#include "bsdistptpt.h"    /* prototypes */
#include "msmacros.h"    /* prototypes */
#include <memory.h>    /* prototypes */
#include <string.h>    /* prototypes */

#define NUM_OBJ_A 50
#define NUM_STRK_DBLS 9000
#define NUM_STRK_PTS 3000
#define INC_STRK_PTS 1500

#define TWO_RULE_LNS 1
#define DISTANCE 2

#define UNIT_PTS 25

from GRgraphics import GRaltconstruct, GRconstruct;
from GRvg	import GRgetsize, GRgetgeom, GRdetplane;
from GRtext 	import GRgettxattr;
from GRplanar	import GRgetpolyline;

/*---------------------------------------------------------------------*
 * This method initialize BSgeom_bsp_surf structure                    *
 *---------------------------------------------------------------------*/
method init_surf_geom( IGRlong *rc; struct GRlc_info *lc_surf;
		       struct BSgeom_bsp_surf *quad_surf;
		       IGRshort *u_or_v )
{
  struct GRmd_env surf_mod;
  IGRshort surf_os;
  GRobjid surf_id;
  IGRchar *geom;
  struct IGRbsp_surface *surf_geom;
  OMuword surf_classid;
  IGRlong status, msg, siz_buf;

  /* get surface module env, id & os */
  surf_mod = lc_surf->module_info;
  surf_id = lc_surf->located_obj.objid;
  surf_os = lc_surf->located_obj.osnum;

  /* get surface geometry */
  status = om$send( msg = message GRvg.GRgetsize( &msg,
						  &surf_mod.md_env.matrix_type,
						  surf_mod.md_env.matrix,
						  &siz_buf ),
		    targetid = surf_id,
		    targetos = surf_os );
  geom = ( char * ) om$malloc( size = siz_buf );
  if ( geom == NULL )
  {
    status = OM_E_NODYNMEM;
    om$report_error( sts = status );
    *rc = BSNULL;
    goto quit;
  }
  status = om$send( msg = message GRvg.GRgetgeom( &msg,
						  &surf_mod.md_env.matrix_type,
						  surf_mod.md_env.matrix,
						  geom ),
		    targetid = surf_id,
		    targetos = surf_os );
  surf_geom = ( struct IGRbsp_surface * ) geom;

  /* initialize fields in the BSgeom_bsp_surf struct */
  quad_surf->geom_prop = FALSE;
  quad_surf->bounded = TRUE;
  quad_surf->urange[0] = surf_geom->u_knots[surf_geom->u_order - 1];
  quad_surf->urange[1] = surf_geom->u_knots[surf_geom->u_num_poles];
  quad_surf->vrange[0] = surf_geom->v_knots[surf_geom->v_order - 1];
  quad_surf->vrange[1] = surf_geom->v_knots[surf_geom->v_num_poles];
  quad_surf->bspsf = surf_geom;
  quad_surf->sfgen_cv = NULL;

  /* get the surface class id */
  om$get_classid( osnum = surf_os,
		  objid = surf_id,
		  p_classid = &surf_classid );

  /* according surface class, call corresponding math routine to
     perform actual initialization */
  if ( om$is_ancestry_valid( subclassid = surf_classid,
			     superclassname = "EMSpcylindr" ) == OM_S_SUCCESS )
  {
    quad_surf->type = BSPART_CYL;
    BScyl_prop( quad_surf, rc );
  }
  else if ( om$is_ancestry_valid( subclassid = surf_classid,
				  superclassname = "EMScylindr" ) == OM_S_SUCCESS )
  {
    quad_surf->type = BSFULL_CYL;
    BScyl_prop( quad_surf, rc );
  }
  else if ( om$is_ancestry_valid( subclassid = surf_classid,
				  superclassname = "EMSpcone" ) == OM_S_SUCCESS )
  {
    quad_surf->type = BSPART_CONE;
    BScone_prop( quad_surf, rc );
  }
  else if ( om$is_ancestry_valid( subclassid = surf_classid,
				  superclassname = "EMScone" ) == OM_S_SUCCESS )
  {
    quad_surf->type = BSFULL_CONE;
    BScone_prop( quad_surf, rc );
  }
  else if ( om$is_ancestry_valid( subclassid = surf_classid,
				  superclassname = "EMSsphere" ) == OM_S_SUCCESS )
  {
    quad_surf->type = BSSPHERE;
    BSsph_prop( quad_surf, rc );
  }
  else
  {
    *rc = BSNULL;
    goto quit;
  }

  if ( quad_surf->type == BSFULL_CYL || quad_surf->type == BSPART_CYL ||
       quad_surf->type == BSFULL_CONE || quad_surf->type == BSPART_CONE )
  {
    /* determine the rule line parameter */
    if ( surf_geom->v_num_poles == 2 )
      *u_or_v = 1;
    else if ( surf_geom->u_num_poles == 2 )
      *u_or_v = 2;
  }

 quit:
  return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------*
 * This method initialize the polyline structure for input element     *
 *---------------------------------------------------------------------*/
method get_polyline( IGRlong *rc; struct GRlc_info *element;
		     uword gd_os; OM_S_OBJID gd_id; struct IGRdisplay *disp;
		     IGRint *num_poly_ln; struct IGRpolyline **poly_lns )
{
  struct GRmd_env ele_mod;
  IGRshort ele_os;
  GRobjid ele_id;
  OMuword ele_class_id;
  IGRint max_num_poly_ln = NUM_OBJ_A;
  struct IGRpolyline poly_ln;
  IGRlong ret_bytes, status, msg;

  /* get element module, id & os */
  ele_mod = element->module_info;
  ele_id = element->located_obj.objid;
  ele_os = element->located_obj.osnum;

  /* initialize num_poly_ln to zero */
  *num_poly_ln = 0;

  /* initialize a chunk of memory to hold polylines */
  *poly_lns = ( struct IGRpolyline * ) om$malloc( size = NUM_OBJ_A * sizeof( struct IGRpolyline ));
  if ( *poly_lns == NULL )
  {
    status = OM_E_NODYNMEM;
    om$report_error( sts = status );
    *rc = FALSE;
    goto quit;
  }

  /* get class id of the input planar element */
  om$get_classid( osnum = ele_os,
		  objid = ele_id,
		  p_classid = &ele_class_id );
  if ( om$is_ancestry_valid( subclassid = ele_class_id,
			     superclassname = "GRtext" ) == OM_S_SUCCESS )
  /* input element is text */
  {
    struct var_list var_list[5];
    IGRint win_no, gpipe_id, gragad_flags;
    struct DPfnt_os_tbl *fnt_os_ptr;
    struct IGRlbsys lbs;
    struct IGResintx ele_info;
    struct IGRestx text_attr;
    IGRshort text_lng, nostrokes, malc_buf;
    IGRuchar *text_string;
    IGRdouble strk_buf[NUM_STRK_DBLS], *ptr_strk_buf, *start_pt;
    IGRint num_points, malloc_size, num_pts, tot_num_pts, count;
    struct IGRpolyline poly_ln;
    IGRlong which_error;
    IGRboolean ststf;

    var_list[0].var = WIN_NO;
    var_list[0].var_ptr = ( IGRchar * ) &win_no;
    var_list[0].num_bytes = sizeof( IGRint );
    var_list[0].bytes_returned = &ret_bytes;
    
    var_list[1].var = GPIPE_ID;
    var_list[1].var_ptr = ( IGRchar * ) &gpipe_id;
    var_list[1].num_bytes = sizeof( IGRint );
    var_list[1].bytes_returned = &ret_bytes;
    
    var_list[2].var = FONT_OS_PTR;
    var_list[2].var_ptr = ( IGRchar * ) &fnt_os_ptr;
    var_list[2].num_bytes = 4;
    var_list[2].bytes_returned = &ret_bytes;

    var_list[3].var = GRAGAD_FLAGS;
    var_list[3].var_ptr = ( IGRchar * ) &gragad_flags;
    var_list[3].num_bytes = sizeof( IGRint );
    var_list[3].bytes_returned = &ret_bytes;

    var_list[4].var = END_PARAM;

    status = dp$inq_set_gragad( msg = &msg,
			        osnum = gd_os,
			        gragad_objid = gd_id,
			        which_error = &which_error,
			        var_list = var_list );
    if ( !( status & 1 & msg ))
    {
      status = OM_E_ABORT;
      *rc = FALSE;
      goto quit;
    }

    /* get text geometry and attributes */
    status = om$send( msg = message GRtext.GRgetgeom( &msg, 
						      &ele_mod.md_env.matrix_type,
						      ele_mod.md_env.matrix,
						      ( IGRchar * ) &lbs ),
		      targetid = ele_id,
		      targetos = ele_os );
    status = om$send( msg = message GRtext.GRgettxattr( &msg, 
						        &text_attr,
						        &text_lng,
						        &text_string ),
		      targetid = ele_id,
		      targetos = ele_os );

    ele_info.font_id = ele_os;
    ele_info.flags = 0;
    ele_info.prev_font = text_attr.font;
    ele_info.estx = &text_attr;
    ele_info.text_string = ( IGRchar * ) text_string;

    ptr_strk_buf = strk_buf;
    nostrokes = TRUE;
    num_points = NUM_STRK_PTS;
    malc_buf = FALSE;

    while ( nostrokes )
    {
      ststf = DPtxstrk( &msg, &lbs, &ele_info, disp,
		        win_no, gpipe_id, fnt_os_ptr, gragad_flags,
		        0, 1.0, 0, ptr_strk_buf, &num_points);
      if ( ststf == FALSE )
      {
	num_points = num_points + INC_STRK_PTS;
	if ( malc_buf )
	  om$dealloc( ptr = ptr_strk_buf );
	malc_buf = TRUE;
	malloc_size = sizeof( IGRdouble ) * num_points * 3.0;
	ptr_strk_buf = ( IGRdouble * ) om$malloc( size = malloc_size );
	if ( ptr_strk_buf == NULL )
	{
	  status = OM_E_NODYNMEM;
	  om$report_error( sts = status );
	  if ( malc_buf )
	    om$dealloc( ptr = ptr_strk_buf );
	  *rc = FALSE;
	  goto quit;
	}
      }
      else
	nostrokes = FALSE;
    } /* close for while */
    om$dealloc( ptr = text_string );

    tot_num_pts = 0;

    while( tot_num_pts < num_points )
    {
      start_pt = ptr_strk_buf;
      count = 0;
      while ( !( fabs( fabs( *ptr_strk_buf/MAXDOUBLE ) - 1 ) < 1e-6 ))
      {
	ptr_strk_buf = ptr_strk_buf + 3;
	count = count + 3;
      }
      num_pts = count / 3;
      tot_num_pts = tot_num_pts + num_pts + 1;

      poly_ln.num_points = num_pts;
      poly_ln.points = ( IGRdouble * ) om$malloc( size = count * sizeof( IGRdouble ));
      if ( poly_ln.points == NULL )
      {
	status = OM_E_NODYNMEM;
	om$report_error( sts = status );
	*rc = FALSE;
	goto quit;
      }
      memcpy( (char *)poly_ln.points, (char *)start_pt, 
        count * sizeof( IGRdouble ));

      if ( *num_poly_ln >= max_num_poly_ln )
      {
	while ( max_num_poly_ln <= *num_poly_ln )
	  max_num_poly_ln += NUM_OBJ_A;
	*poly_lns = ( struct IGRpolyline * ) om$realloc( ptr = ( IGRchar * ) *poly_lns,
							 size = max_num_poly_ln * sizeof( struct IGRpolyline ));
	if ( me->poly_lns == NULL )
	{
	  status = OM_E_NODYNMEM;
	  om$report_error( sts = status );
	  *rc = FALSE;
	  goto quit;
	}
      }
      (*poly_lns)[(*num_poly_ln)++] = poly_ln;
      ptr_strk_buf = ptr_strk_buf + 3;
    }
    
    if ( malc_buf )
      om$dealloc( ptr = ptr_strk_buf );

  }
  else if ( om$is_ancestry_valid( subclassid = ele_class_id,
				  superclassname = "GRplanar" ) == OM_S_SUCCESS )
  /* input element is polyline or polygon */
  {
    /* set num_points = 0 to determine the storage needed to store
       points of the polyline (see GRplanar.GRgetpolyline) */
    poly_ln.num_points = 0;
    status = om$send( msg = message GRplanar.GRgetpolyline( &msg,
							    &ele_mod.md_env.matrix_type,
							    ele_mod.md_env.matrix,
							    ( IGRint * ) &poly_ln.num_points,
							    &poly_ln ),
		      targetid = ele_id,
		      targetos = ele_os );

    poly_ln.points = ( IGRdouble * ) om$malloc( size = poly_ln.num_points * 3 * sizeof( IGRdouble ));
    if ( poly_ln.points == NULL )
    {
      status = OM_E_NODYNMEM;
      om$report_error( sts = status );
      *rc = FALSE;
      goto quit;
    }

    /* set num_points = 1 to actually fill in the points */
    poly_ln.num_points = 1;
    status = om$send( msg = message GRplanar.GRgetpolyline( &msg,
							    &ele_mod.md_env.matrix_type,
							    ele_mod.md_env.matrix,
							    ( IGRint * ) &poly_ln.num_points,
							    &poly_ln ),
		      targetid = ele_id,
		      targetos = ele_os );
    *num_poly_ln = 1;
    (*poly_lns)[0] = poly_ln;
  }
  else if ( om$is_ancestry_valid( subclassid = ele_class_id,
				  superclassname = "GRlinear" ) == OM_S_SUCCESS )
  /* input element is 3d linestring or 3d linesegment */
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NONPLANAR );
    *rc = FALSE;
    goto quit;
  }
  else if ( om$is_ancestry_valid( subclassid = ele_class_id,
				  superclassname = "GRbspline" ) == OM_S_SUCCESS )
  {
    IGRchar *geom;
    struct IGRbsp_curve *cv_geom;
    IGRdouble *pars, ratio = 0.0;
    IGRpoint *pts;
    IGRint i;
    IGRlong siz_buf;

    /* get b-spline curve geometry */
    status = om$send( msg = message GRvg.GRgetsize( &msg,
						    &ele_mod.md_env.matrix_type,
						    ele_mod.md_env.matrix,
						    &siz_buf ),
		      targetid = ele_id,
		      targetos = ele_os );
    geom = ( char * ) om$malloc( size = siz_buf );
    if ( geom == NULL )
    {
      status = OM_E_NODYNMEM;
      om$report_error( sts = status );
      *rc = FALSE;
      goto quit;
    }
    status = om$send( msg = message GRvg.GRgetgeom( &msg,
						    &ele_mod.md_env.matrix_type,
						    ele_mod.md_env.matrix,
						    geom ),
		      targetid = ele_id,
		      targetos = ele_os );
    cv_geom = ( struct IGRbsp_curve * ) geom;

    /* check whether this a planar curve */
    if ( cv_geom->planar == FALSE )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NONPLANAR );
      *rc = FALSE;
      goto quit;
    }

    /* if planar, then find stroke points */
    BSchtptstco( cv_geom, 0, TRUE, FALSE, NULL, FALSE, ratio,
		 (IGRint *) &(poly_ln.num_points), &pts, &pars, &msg );

    poly_ln.points = ( IGRdouble * ) om$malloc( size = ( poly_ln.num_points ) * 3 * sizeof( IGRdouble ));
    if ( poly_ln.points == NULL )
    {
      status = OM_E_NODYNMEM;
      om$report_error( sts = status );
      *rc = FALSE;
      goto quit;
    }

    /* copy points */
    for ( i = 0; i < poly_ln.num_points; i++ )
      memcpy( (char *)(poly_ln.points + i*3), (char *)pts[i], 
        3 * sizeof( IGRdouble ));

    *num_poly_ln = 1;
    (*poly_lns)[0] = poly_ln;

    om$dealloc( ptr = pts );
    om$dealloc( ptr = geom );
  }
  else if ( om$is_ancestry_valid( subclassid = ele_class_id,
				  superclassname = "GRowner" ) == OM_S_SUCCESS )
  {
    OM_S_CLASSLIST ele_yes_list, ele_no_list;
    OMuword ele_class_ids[4];
    IGRlong num_objs;
    struct GRlc_info *loc_objects;
    struct IGRplane plane;
    IGRpoint p0, p1;
    IGRvector v0, v1, vec;
    IGRdouble lenvec_tol, othovec_tol;
    struct IGRpolyline *lns;
    IGRint num_lns, i;
    extern IGRlong EMselective_fence();

    /* initialize element yes classes in a group */
    ele_yes_list.w_count = 3;
    ele_yes_list.p_classes = ele_class_ids;
    om$get_classid( classname = "GRplanar",
		    p_classid = &ele_class_ids[0] );
    om$get_classid( classname = "GRtext",
		    p_classid = &ele_class_ids[1] );
    om$get_classid( classname = "GRbspline",
		    p_classid = &ele_class_ids[2] );

    /* do not specify no classes */
    ele_no_list.w_count = 0;

    EMselective_fence( &ele_yes_list, &ele_no_list, element,
		       FALSE, TRUE, my_id, &num_objs, &loc_objects, &msg );
    if ( !( 1 & msg ))
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_GetGrGrpElem );
      *rc = FALSE;
      goto quit;
    }

    BSxtractpar( &msg, BSTOLLENVEC, &lenvec_tol );
    BSxtractpar( &msg, BSTOLORTHOVEC, &othovec_tol );

    /* now test co-planarity for all elements in the located group */

    /* get the plane that the first element lies on */
    plane.point = p0;
    plane.normal = v0;
    status = om$send( msg = message GRvg.GRdetplane( &msg,
						     &loc_objects[0].module_info.md_env.matrix_type,
						     loc_objects[0].module_info.md_env.matrix,
						     &plane ),
		      targetid = loc_objects[0].located_obj.objid,
		      targetos = loc_objects[0].located_obj.osnum );

    for ( i = 1; i < num_objs; i++ )
    {
      plane.point = p1;
      plane.normal = v1;
      status = om$send( msg = message GRvg.GRdetplane( &msg,
						       &loc_objects[i].module_info.md_env.matrix_type,
						       loc_objects[i].module_info.md_env.matrix,
						       &plane ),
		        targetid = loc_objects[i].located_obj.objid,
		        targetos = loc_objects[i].located_obj.osnum );

      BScrossp( &msg, v0, v1, vec );
      if ( BSlenvec( &msg, vec ) >= lenvec_tol )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_GrpElemNonPlnr );
	*rc = FALSE;
	goto quit;
      }
      BSmkvec( &msg, vec, p0, p1 );
      if ( fabs( BSdotp( &msg, vec, v0 )) >= othovec_tol )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_GrpElemNonPlnr );
	*rc = FALSE;
	goto quit;
      }
    }

    /* get polyline from each element */
    for ( i = 0; i < num_objs; i++ )
    {
      status = om$send( msg = message IDwrap.get_polyline( &msg,
							   &loc_objects[i],
							   gd_os,
							   gd_id,
							   disp,
							   &num_lns,
							   &lns ),
		        targetid = my_id );

      if ( ( *num_poly_ln + num_lns ) >= max_num_poly_ln )
      {
	while ( max_num_poly_ln <= ( *num_poly_ln + num_lns ))
	  max_num_poly_ln += NUM_OBJ_A;
	*poly_lns = ( struct IGRpolyline * ) om$realloc( ptr = ( IGRchar * ) *poly_lns,
							 size = max_num_poly_ln * sizeof( struct IGRpolyline ));
	if ( me->poly_lns == NULL )
	{
	  status = OM_E_NODYNMEM;
	  om$report_error( sts = status );
	  *rc = FALSE;
	  goto quit;
	}
      }
      memcpy( (char *)(*poly_lns + (*num_poly_ln)), (char *)lns, 
        num_lns * sizeof( struct IGRpolyline ));
      (*num_poly_ln) += num_lns;

      /* free lns */
      om$dealloc( ptr = lns );
    }
  }
  else
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NONPLANAR );
    *rc = FALSE;
    goto quit;
  }

  /* now check the case where the object is a line segment.
     That cannot be wrapped since the plane is not uniquely
     determined by one single line */
  if ( *num_poly_ln == 1 && (*poly_lns)[0].num_points == 2 )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_WRPLNSEG );
    *rc = FALSE;
    goto quit;
  }

  *rc = TRUE;

 quit:
  return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------*
 * Compute wrap angle on the conical surface                           *
 *---------------------------------------------------------------------*/
method comp_wrap_angle( IGRlong *rc; IGRshort type; IGRdouble arc_len;
		        IGRvector tang_vec; IGRdouble *wrap_angle )
{
  IGRlong msg;

  switch ( type )
  {
  case TWO_RULE_LNS:
    {
      IGRboolean which;
      IGRpoint start_pt, end_pt, cnt_pt;
      IGRvector start_vec, end_vec, vec;
      IGRdouble v, sin_val, cos_val;

      if ( fabs( me->start_uv - me->end_uv ) <= 1e-4 )
	*wrap_angle = 2.0 * M_PI;
      else
      {
	/* compute two unit vectors which will span the angle */
	switch ( me->quad_surf.type )
	{
	case BSFULL_CYL:
	case BSPART_CYL:
	  /* get starting and ending points */
	  memcpy((char *) start_pt, (char *)me->start_ln, 
            3 * sizeof( IGRdouble ));
	  memcpy( (char *)end_pt, (char *)me->end_ln, 3 * sizeof( IGRdouble ));

	  BSmkvec( &msg, vec, me->quad_surf.pt1, start_pt );
	  v = BSdotp( &msg, vec, me->quad_surf.vec1 );

	  cnt_pt[0] = me->quad_surf.pt1[0] + v * me->quad_surf.vec1[0];
	  cnt_pt[1] = me->quad_surf.pt1[1] + v * me->quad_surf.vec1[1];
	  cnt_pt[2] = me->quad_surf.pt1[2] + v * me->quad_surf.vec1[2];

	  /* compute starting and ending vectors */
	  BSmkvec( &msg, start_vec, cnt_pt, start_pt );
	  BSnorvec( &msg, start_vec );
	  BSmkvec( &msg, end_vec, cnt_pt, end_pt );
	  BSnorvec( &msg, end_vec );
	  break;

	case BSFULL_CONE:
	case BSPART_CONE:
	  which = ( me->quad_surf.flag1 == 0 || me->quad_surf.flag1 == 1 );

	  /* find end points of the starting and ending rule lines */
	  if ( which )
	  {
	    memcpy( (char *)start_pt, (char *)me->start_ln, 3 * sizeof( IGRdouble ));
	    memcpy( (char *)end_pt,(char *) me->end_ln, 
                3 * sizeof( IGRdouble ));

	    BSmkvec( &msg, vec, me->quad_surf.pt1, start_pt );
	    v = BSdotp( &msg, vec, me->quad_surf.vec1 );

	    cnt_pt[0] = me->quad_surf.pt1[0] + v * me->quad_surf.vec1[0];
	    cnt_pt[1] = me->quad_surf.pt1[1] + v * me->quad_surf.vec1[1];
	    cnt_pt[2] = me->quad_surf.pt1[2] + v * me->quad_surf.vec1[2];

	    /* compute the starting and ending vectors */
	    BSmkvec( &msg, start_vec, cnt_pt, start_pt );
	    BSnorvec( &msg, start_vec );
	    BSmkvec( &msg, end_vec, cnt_pt, end_pt );
	    BSnorvec( &msg, end_vec );
	  }
	  else
	  {
	    memcpy((char *) start_pt, (char *)(me->start_ln + 3), 
                3 * sizeof( IGRdouble ));
	    memcpy( (char *)end_pt, (char *)(me->end_ln + 3), 
                3 * sizeof( IGRdouble ));

	    BSmkvec( &msg, vec, me->quad_surf.pt2, start_pt );
	    v = BSdotp( &msg, vec, me->quad_surf.vec1 );

	    cnt_pt[0] = me->quad_surf.pt2[0] + v * me->quad_surf.vec1[0];
	    cnt_pt[1] = me->quad_surf.pt2[1] + v * me->quad_surf.vec1[1];
	    cnt_pt[2] = me->quad_surf.pt2[2] + v * me->quad_surf.vec1[2];

	    /* compute the starting and ending vectors */
	    BSmkvec( &msg, start_vec, cnt_pt, start_pt );
	    BSnorvec( &msg, start_vec );
	    BSmkvec( &msg, end_vec, cnt_pt, end_pt );
	    BSnorvec( &msg, end_vec );
	  }
	  break;

	case BSSPHERE:
	  /* find mid points on the starting and ending rule lines */
	  BSsfeval( me->quad_surf.bspsf, 0.5, me->start_uv, 0, &start_pt, &msg );
	  BSsfeval( me->quad_surf.bspsf, 0.5, me->end_uv, 0, &end_pt, &msg );

	  /* compute starting and ending vectors */
	  BSmkvec( &msg, start_vec, me->quad_surf.pt1, start_pt );
	  BSnorvec( &msg, start_vec );
	  BSmkvec( &msg, end_vec, me->quad_surf.pt1, end_pt );
	  BSnorvec( &msg, end_vec );
	  break;
	}

	BScrossp( &msg, tang_vec, start_vec, vec );
	if ( BSdotp( &msg, vec, me->quad_surf.vec1 ) > 0 )
	  /* wrapping is clockwise w.r.t. me->quad_surf.vec1 as z_axis */
	  BScrossp( &msg, end_vec, start_vec, vec );
	else
	  /* wrapping is counterclockwise */
	  BScrossp( &msg, start_vec, end_vec, vec );

	sin_val = BSdotp( &msg, vec, me->quad_surf.vec1 );
	cos_val = BSdotp( &msg, start_vec, end_vec );

	*wrap_angle = atan2( sin_val, cos_val );
	if ( *wrap_angle < 0 )
	  *wrap_angle += 2 * M_PI;
      }
      break;
    }
  case DISTANCE:
    {
      IGRvector vec;
      IGRdouble val, angle, radius = 0.0;

      /* compute the radius at the point where distance is measured.
	 This point is the input starting point */
      switch ( me->quad_surf.type )
      {
      case BSFULL_CYL:
      case BSPART_CYL:
	radius = me->quad_surf.len1;
	break;

      case BSFULL_CONE:
      case BSPART_CONE:
	/* compute the vector from the point to tip */
	BSmkvec( &msg, vec, me->start_pt, me->quad_surf.pt5 );

	/* compute the radius of the circle at the point */
	radius = BSlenvec( &msg, vec ) * sin( me->quad_surf.len4 );
	break;

      case BSSPHERE:
	if ( me->start_uv < 0.5 )	/* check the upper half */
	  /* compute the angle from intersection to the top pole */
	  BSmkvec( &msg, vec, me->start_pt, me->quad_surf.pt2 );
	else
	  /* compute the angle from intersection to the bottom pole */
	  BSmkvec( &msg, vec, me->start_pt, me->quad_surf.pt4 );

	/* calculate radius of the circle at the point */
	val = BSlenvecsq( &msg, vec );
	angle = acos(1-val/( 2.0 * me->quad_surf.len1 * me->quad_surf.len1 ));
	radius = me->quad_surf.len1 * sin( angle );
	break;
      }

      /* calculate the wrapping angle */
      if ( arc_len > 0 )
	*wrap_angle = arc_len / radius;
      else if ( arc_len < 0 )
      {
	*wrap_angle = -arc_len / radius;
	while ( *wrap_angle >= 2.0 * M_PI )
	  *wrap_angle -= 2.0 * M_PI;
	*wrap_angle = 2.0 * M_PI - *wrap_angle;
      }
      else
	*wrap_angle = 2.0 * M_PI;
      break;
    }
  }
  *rc = TRUE;
  return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------*
 * Map a point of planar element to the conical surface                *
 *---------------------------------------------------------------------*/
method map_to_sf( IGRlong *rc; struct ele_rect *rect;
		  IGRdouble wrap_angle, width, z_dis;
		  IGRvector x_axis, y_axis; IGRint rot_sign;
		  IGRpoint pt, new_cnt, new_pt; IGRdouble *rot_angle )
{
  IGRdouble pt_hgt, sign, z_pt, h_scal, radius, sin_val, cos_val;
  IGRvector vec, cur_x_axis, cur_y_axis;
  IGRlong msg;

  z_pt = 0.0;	/* shut off stupid warning from the compiler */

  /* compute the correct z_height */
  BSmkvec( &msg, vec, rect->min_v_pt, pt );
  pt_hgt = BSdotp( &msg, vec, rect->v_vec );
  sign = ( BSdotp( &msg, rect->v_vec, me->quad_surf.vec1 ) > 0 ? 1 : -1 );
  switch ( me->quad_surf.type )
  {
  case BSFULL_CYL:
  case BSPART_CYL:
    z_pt = z_dis + sign * pt_hgt;
    break;
  case BSFULL_CONE:
  case BSPART_CONE:
    z_pt = z_dis + sign * pt_hgt * cos( me->quad_surf.len4 );
    break;
  case BSSPHERE:
    z_pt = z_dis + sign * ( pt_hgt / rect->rect_hgt ) * width;

    /* handle possible degenerate cases */
    if ( z_pt > me->quad_surf.len1 || z_pt < -me->quad_surf.len1 )
    {
      if ( z_pt > 0 )
	z_pt = me->quad_surf.len1;
      else
	z_pt = -me->quad_surf.len1;
    }
    break;
  }

  /* find the center of the circle at z_height */
  new_cnt[0] = me->quad_surf.pt1[0] + z_pt * me->quad_surf.vec1[0];
  new_cnt[1] = me->quad_surf.pt1[1] + z_pt * me->quad_surf.vec1[1];
  new_cnt[2] = me->quad_surf.pt1[2] + z_pt * me->quad_surf.vec1[2];

  /* note that cylinder have a uniform radius along z_axis. hence
     we need not compute its rotation axis for each point */
  if ( me->quad_surf.type != BSFULL_CYL &&
       me->quad_surf.type != BSPART_CYL )
  {
    /* compute the radius of the circle at the point */
    if ( me->quad_surf.type == BSFULL_CONE ||
         me->quad_surf.type == BSPART_CONE )
    {
      BSmkvec( &msg, vec, new_cnt, me->quad_surf.pt5 );
      radius = BSlenvec( &msg, vec ) * tan( me->quad_surf.len4 );
    }
    else
      radius = sqrt( fabs( me->quad_surf.len1 * me->quad_surf.len1 - 
			   z_pt * z_pt ));

    /* compute axies of rotation */
    cur_x_axis[0] = radius * x_axis[0];
    cur_x_axis[1] = radius * x_axis[1];
    cur_x_axis[2] = radius * x_axis[2];
    cur_y_axis[0] = radius * y_axis[0];
    cur_y_axis[1] = radius * y_axis[1];
    cur_y_axis[2] = radius * y_axis[2];
  }

  /* compute horizontal scaling */
  BSmkvec( &msg, vec, rect->min_pt, pt );
  h_scal = BSdotp( &msg, vec, rect->h_vec );

  /* calculate the rotation angle */
  *rot_angle = ( h_scal / rect->rect_len ) * wrap_angle;
  if ( rot_sign == -1 )
    *rot_angle = -( *rot_angle );
  sin_val = sin( *rot_angle );
  cos_val = cos( *rot_angle );

  /* rotate to get point on the surface */
  if ( me->quad_surf.type == BSFULL_CYL ||
       me->quad_surf.type == BSPART_CYL )
  {
    new_pt[0] = new_cnt[0] + x_axis[0] * cos_val + y_axis[0] * sin_val;
    new_pt[1] = new_cnt[1] + x_axis[1] * cos_val + y_axis[1] * sin_val;
    new_pt[2] = new_cnt[2] + x_axis[2] * cos_val + y_axis[2] * sin_val;
  }
  else
  {
    new_pt[0] = new_cnt[0] + cur_x_axis[0] * cos_val + cur_y_axis[0] * sin_val;
    new_pt[1] = new_cnt[1] + cur_x_axis[1] * cos_val + cur_y_axis[1] * sin_val;
    new_pt[2] = new_cnt[2] + cur_x_axis[2] * cos_val + cur_y_axis[2] * sin_val;
  }

  *rc = TRUE;
  return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------*
 * Wrap element onto conical surface                                   *
 *---------------------------------------------------------------------*/
method wrap_sf( IGRlong *rc; struct ele_rect *rect;
	        IGRdouble wrap_angle, width, z_dis;
	        IGRvector tang_vec;
	        struct IGRdisplay *disp; IGRshort level )
{
  IGRshort act_os;
  struct GRvg_construct cnst_list;
  IGRdouble lenvec_tol;
  OM_S_OBJID ggid;
  struct GRid gg_grid;

  IGRpoint start_pt, cnt_pt;
  IGRvector x_axis, y_axis;
  IGRvector ln_dir, vec;
  IGRint rot_sign, i, j, max_points;
  struct IGRpolyline poly_ln, wrp_ln;
  IGRpoint mid_pt, pt1, pt2, new_cnt1, new_pt1, new_cnt2, new_pt2;
  IGRboolean parallel;
  IGRdouble v, rot_angle1, rot_angle2, *cur_ptr;
  struct GRid wrp_cv;

  IGRlong msg, status;

  *rc = TRUE;
  BSxtractpar( &msg, BSTOLLENVEC, &lenvec_tol );

  act_os = ME.ECelement->md_env.md_id.osnum;

  /* initialize standard construction list */
  cnst_list.msg = &msg;
  cnst_list.newflag = 0;
  cnst_list.level = level;
  cnst_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  cnst_list.display = disp;
  cnst_list.name = NULL;
  cnst_list.class_attr = NULL;
  cnst_list.env_info = &ME.ECelement->md_env;

  /* initialize a graphic group object */
  status = om$construct( osnum = act_os,
			 classname = "GRgrgrp",
			 p_objid = &ggid,
			 msg = message GRgraphics.GRconstruct( &cnst_list ));
  gg_grid.objid = ggid;
  gg_grid.osnum = act_os;

  /* establish a local coordiante system for rotation */
  switch ( me->quad_surf.type )
  {
  case BSFULL_CYL:
  case BSPART_CYL:
    memcpy( (char *)start_pt, (char *)me->start_ln, 3 * sizeof( IGRdouble ));
    BSmkvec( &msg, vec, me->quad_surf.pt1, start_pt );
    v = BSdotp( &msg, vec, me->quad_surf.vec1 );

    cnt_pt[0] = me->quad_surf.pt1[0] + v * me->quad_surf.vec1[0];
    cnt_pt[1] = me->quad_surf.pt1[1] + v * me->quad_surf.vec1[1];
    cnt_pt[2] = me->quad_surf.pt1[2] + v * me->quad_surf.vec1[2];

    BSmkvec( &msg, x_axis, cnt_pt, start_pt );
    BScrossp( &msg, me->quad_surf.vec1, x_axis, y_axis );
    break;
  case BSFULL_CONE:
  case BSPART_CONE:
    if ( me->quad_surf.flag1 == 0 || me->quad_surf.flag1 == 1 )
    {
      memcpy((char *) start_pt, (char *)me->start_ln, 3 * sizeof( IGRdouble ));
      BSmkvec( &msg, vec, me->quad_surf.pt1, start_pt );
      v = BSdotp( &msg, vec, me->quad_surf.vec1 );

      cnt_pt[0] = me->quad_surf.pt1[0] + v * me->quad_surf.vec1[0];
      cnt_pt[1] = me->quad_surf.pt1[1] + v * me->quad_surf.vec1[1];
      cnt_pt[2] = me->quad_surf.pt1[2] + v * me->quad_surf.vec1[2];

      BSmkvec( &msg, x_axis, cnt_pt, start_pt );
    }
    else
    {
      memcpy((char *) start_pt, (char *)(me->start_ln + 3), 
        3 * sizeof( IGRdouble ));
      BSmkvec( &msg, vec, me->quad_surf.pt2, start_pt );
      v = BSdotp( &msg, vec, me->quad_surf.vec1 );

      cnt_pt[0] = me->quad_surf.pt2[0] + v * me->quad_surf.vec1[0];
      cnt_pt[1] = me->quad_surf.pt2[1] + v * me->quad_surf.vec1[1];
      cnt_pt[2] = me->quad_surf.pt2[2] + v * me->quad_surf.vec1[2];

      BSmkvec( &msg, x_axis, cnt_pt, start_pt );
    }
    BSnorvec( &msg, x_axis );
    BScrossp( &msg, me->quad_surf.vec1, x_axis, y_axis );
    break;
  case BSSPHERE:
    BSsfeval( me->quad_surf.bspsf, 0.5, me->start_uv, 0, &mid_pt, &msg );
    BSmkvec( &msg, x_axis, me->quad_surf.pt1, mid_pt );
    BSnorvec( &msg, x_axis );
    BScrossp( &msg, me->quad_surf.vec1, x_axis, y_axis );
    break;
  }

  /* determine the sign of angular rotation */
  rot_sign = ( BSdotp( &msg, y_axis, tang_vec ) > 0 ? 1 : -1 );

  /* initialize a chunk of memory to hold polylines */
  max_points = NUM_STRK_PTS;
  wrp_ln.points = ( IGRdouble * ) om$malloc( size = NUM_STRK_DBLS * sizeof( IGRdouble ));
  if ( wrp_ln.points == NULL )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    *rc = FALSE;
    goto quit;
  }

  /* now, map end points of each polyline to the cone */
  for ( j = 0; j < me->num_poly_ln; j++ )
  {
    poly_ln = me->poly_lns[j];

    pt1[0] = poly_ln.points[0];
    pt1[1] = poly_ln.points[1];
    pt1[2] = poly_ln.points[2];

    /* map the first point to surface */
    status = om$send( msg = message IDwrap.map_to_sf( &msg,
						      rect,
						      wrap_angle,
						      width,
						      z_dis,
						      x_axis,
						      y_axis,
						      rot_sign,
						      pt1,
						      new_cnt1,
						      new_pt1,
						      &rot_angle1 ),
		      targetid = my_id );

    /* initialization: put the first point */
    memcpy((char *) wrp_ln.points, (char *)new_pt1, 3 * sizeof( IGRdouble ));
    wrp_ln.num_points = 1;
    cur_ptr = wrp_ln.points + 3;

    for ( i = 1; i < poly_ln.num_points; i++ )
    {
      pt2[0] = poly_ln.points[3*i];
      pt2[1] = poly_ln.points[3*i+1];
      pt2[2] = poly_ln.points[3*i+2];

      /* map the second point to surface */
      status = om$send( msg = message IDwrap.map_to_sf( &msg,
						        rect,
						        wrap_angle,
						        width,
						        z_dis,
						        x_axis,
						        y_axis,
						        rot_sign,
						        pt2,
						        new_cnt2,
						        new_pt2,
						        &rot_angle2 ),
		        targetid = my_id );

      /* determine the line consisting of pt1, pt2 is parallel
	 to the vertical sorting vector */
      BSmkvec( &msg, ln_dir, pt1, pt2 );
      BSnorvec( &msg, ln_dir );
      BScrossp( &msg, ln_dir, rect->v_vec, vec );

      if ( BSlenvec( &msg, vec ) <= lenvec_tol )
	parallel = TRUE;
      else
	parallel = FALSE;

      if ( me->quad_surf.type == BSSPHERE )
	parallel = FALSE;	/* temporary set it to false */

      
      /* if parallel then only the line connecting new_pt1 and new_pt2
	 must lie on the cone. Construct a line directly */
      if ( parallel == TRUE )
      {
	/* if surface is cylinder or cone, then construct a line
	   connecting new_pt1 and new_pt2 */
	if ( me->quad_surf.type == BSFULL_CYL ||
	     me->quad_surf.type == BSPART_CYL ||
	     me->quad_surf.type == BSFULL_CONE ||
	     me->quad_surf.type == BSPART_CONE )
	{
	  if (( wrp_ln.num_points + 1 ) > max_points )
	  {
	    max_points += INC_STRK_PTS;
	    wrp_ln.points = ( IGRdouble * ) om$realloc( ptr = ( IGRchar * ) wrp_ln.points,
						        size = max_points * 3 * sizeof( IGRdouble ));
	    if ( wrp_ln.points == NULL )
	    {
	      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	      *rc = FALSE;
	      goto quit;
	    }
	    cur_ptr = wrp_ln.points + wrp_ln.num_points * 3;
	  }
	  memcpy( (char *)cur_ptr, (char *)new_pt2, 3 * sizeof( IGRdouble ));
	  cur_ptr += 3;
	  ++(wrp_ln.num_points);
	}
	else
	{
	  /* for sphere, this will be a circle with radius as sphere
	     radius and passing through new_pt1 and new_pt2. we use
	     specialized algorithm for efficiency */
	}
      }
      else
      {
	/* determine the number of points used to stroke
	   out the wrapping polyline strings */
	IGRdouble diff_angle, len1, len2, map_angle;
	IGRdouble inc_angle, cur_angle, sin_val, cos_val;
	IGRvector inc_vec;
	IGRint ii;
	IGRlong num1, num2, num_strk_pts;
	IGRpoint cur_pt, map_pt, map_cnt;

	diff_angle = fabs( rot_angle2 - rot_angle1 );
	len1 = 0.0;	/* get rid of stupid warning from compiler */
	switch ( me->quad_surf.type )
	{
	case BSFULL_CYL:
	case BSPART_CYL:
	  len1 = me->quad_surf.len1 * diff_angle;
	  break;
	case BSFULL_CONE:
	case BSPART_CONE:
	  len1 = ( me->quad_surf.len1+me->quad_surf.len2 ) / 2.0 * diff_angle;
	  break;
	case BSSPHERE:
	  len1 = me->quad_surf.len1 * diff_angle;
	  break;
	}
	num1 = ( IGRlong ) ( len1 + 0.5 );
	len2 = BSdistptpt( &msg, new_pt1, new_pt2 );
	num2 = ( IGRlong ) ( len2 + 0.5 );

	if ( num1 < num2 )
	  num_strk_pts = num2 * me->unit_pts; /* UNIT_PTS; */
	else
	  num_strk_pts = num1 * me->unit_pts; /* UNIT_PTS; */

	if ( num_strk_pts > 2 )
	{
	  if (( wrp_ln.num_points + num_strk_pts - 1 ) > max_points )
	  {
	    while ( max_points < ( wrp_ln.num_points + num_strk_pts - 1 ))
	      max_points += INC_STRK_PTS;

	    wrp_ln.points = ( IGRdouble * ) om$realloc( ptr = ( IGRchar * ) wrp_ln.points,
						        size = max_points * 3 * sizeof( IGRdouble ));
	    if ( wrp_ln.points == NULL )
	    {
	      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	      *rc = FALSE;
	      goto quit;
	    }
	    cur_ptr = wrp_ln.points + wrp_ln.num_points * 3;
	  }

	  /* we use special algorithm for cylinder */
	  if ( me->quad_surf.type == BSFULL_CYL ||
	       me->quad_surf.type == BSPART_CYL )
	  {
	    inc_vec[0] = ( new_cnt2[0] - new_cnt1[0] ) / num_strk_pts;
	    inc_vec[1] = ( new_cnt2[1] - new_cnt1[1] ) / num_strk_pts;
	    inc_vec[2] = ( new_cnt2[2] - new_cnt1[2] ) / num_strk_pts;
	    inc_angle = ( rot_angle2 - rot_angle1 ) / num_strk_pts;

	    map_cnt[0] = new_cnt1[0];
	    map_cnt[1] = new_cnt1[1];
	    map_cnt[2] = new_cnt1[2];
	    cur_angle = rot_angle1;

	    /* there is a even faster way to generate points if
	       the intersection is a circular arc */
	    for ( ii = 1; ii < ( num_strk_pts - 1 ); ii++ )
	    {
	      map_cnt[0] += inc_vec[0];
	      map_cnt[1] += inc_vec[1];
	      map_cnt[2] += inc_vec[2];
	      cur_angle += inc_angle;
	      sin_val = sin( cur_angle );
	      cos_val = cos( cur_angle );
	      
	      map_pt[0] = map_cnt[0] + x_axis[0]*cos_val + y_axis[0]*sin_val;
	      map_pt[1] = map_cnt[1] + x_axis[1]*cos_val + y_axis[1]*sin_val;
	      map_pt[2] = map_cnt[2] + x_axis[2]*cos_val + y_axis[2]*sin_val;
	    
	      memcpy( (char *)cur_ptr, (char *)map_pt, 
                3 * sizeof( IGRdouble ));
	      cur_ptr += 3;
	    }
	    memcpy( (char *)cur_ptr, (char *)new_pt2, 3 * sizeof( IGRdouble ));
	    cur_ptr += 3;

	    wrp_ln.num_points += ( num_strk_pts - 1 );
	  }
	  else
	  {
	    inc_vec[0] = ( pt2[0] - pt1[0] ) / num_strk_pts;
	    inc_vec[1] = ( pt2[1] - pt1[1] ) / num_strk_pts;
	    inc_vec[2] = ( pt2[2] - pt1[2] ) / num_strk_pts;
	    cur_pt[0] = pt1[0];
	    cur_pt[1] = pt1[1];
	    cur_pt[2] = pt1[2];

	    /* there is a even faster way to generate points if
	       the intersection is a circular arc */
	    for ( ii = 1; ii < ( num_strk_pts - 1 ); ii++ )
	    {
	      cur_pt[0] += inc_vec[0];
	      cur_pt[1] += inc_vec[1];
	      cur_pt[2] += inc_vec[2];

	      status = om$send( msg = message IDwrap.map_to_sf( &msg,
							        rect,
							        wrap_angle,
							        width,
							        z_dis,
							        x_axis,
							        y_axis,
							        rot_sign,
							        cur_pt,
							        map_cnt,
							        map_pt,
							        &map_angle ),
			        targetid = my_id );

	      memcpy( (char *)cur_ptr, (char *)map_pt, 
                3 * sizeof( IGRdouble ));
	      cur_ptr += 3;
	    }
	    memcpy( (char *)cur_ptr, (char *)new_pt2, 3 * sizeof( IGRdouble ));
	    cur_ptr += 3;

	    wrp_ln.num_points += ( num_strk_pts - 1 );
	  }
	}
	else
	{
	  if (( wrp_ln.num_points + 1 ) > max_points )
	  {
	    max_points += INC_STRK_PTS;
	    wrp_ln.points = ( IGRdouble * ) om$realloc( ptr = ( IGRchar * ) wrp_ln.points,
						        size = max_points * 3 * sizeof( IGRdouble ));
	    if ( wrp_ln.points == NULL )
	    {
	      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	      *rc = FALSE;
	      goto quit;
	    }
	    cur_ptr = wrp_ln.points + wrp_ln.num_points * 3;
	  }
	  memcpy( (char *)cur_ptr, (char *)new_pt2, 3 * sizeof( IGRdouble ));
	  cur_ptr += 3;
	  ++(wrp_ln.num_points);
	}
      }
      pt1[0] = pt2[0];
      pt1[1] = pt2[1];
      pt1[2] = pt2[2];
      new_pt1[0] = new_pt2[0];
      new_pt1[1] = new_pt2[1];
      new_pt1[2] = new_pt2[2];
      rot_angle1 = rot_angle2;

      if ( me->quad_surf.type == BSFULL_CYL ||
	   me->quad_surf.type == BSPART_CYL )
      {
	new_cnt1[0] = new_cnt2[0];
	new_cnt1[1] = new_cnt2[1];
	new_cnt1[2] = new_cnt2[2];
      }
    }

    /* construct the result polyline string */
    cnst_list.geometry = ( IGRchar * ) &wrp_ln;

    status = om$construct( classname = "GR3dlinestr",
			   osnum = act_os,
			   p_objid = &wrp_cv.objid,
			   msg = message GRgraphics.GRaltconstruct( &cnst_list ));
    wrp_cv.osnum = act_os;

    /* put the object into the graphic group */
    GRconnect_object( &msg, act_os, wrp_cv.objid, &gg_grid,
		      GR_FLEXIBLE, GR_OVERRIDE, OM_K_MAXINT, OM_K_MAXINT );

    gr$display_object( object_id = &wrp_cv,
		       mode = GRbd );
  }

  *rc = TRUE;
  UI_status( " " );

  /* free all the memory allocated */
  om$dealloc( ptr = wrp_ln.points );

 quit:
  for ( i = 0; i < me->num_poly_ln; i++ )
  {
    om$dealloc( ptr = me->poly_lns[i].points );
    me->poly_lns[i].points = NULL;
  }
  om$dealloc( ptr = me->poly_lns );
  me->poly_lns = NULL;
  me->num_poly_ln = 0;
  om$dealloc( ptr = me->quad_surf.bspsf );
  me->quad_surf.bspsf = NULL;

  return OM_S_SUCCESS;

} /* close action wrapping onto conical surface */

end implementation IDwrap;
