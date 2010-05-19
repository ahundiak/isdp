/* $Id: SMextentSrf.I,v 1.2 2001/03/19 20:03:55 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMextentSrf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMextentSrf.I,v $
 *	Revision 1.2  2001/03/19 20:03:55  hans
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/06  21:25:48  pinnacle
# Replaced: smutil/func/SMextentSrf.I for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/20  19:31:36  pinnacle
# Replaced: smutil/func/*.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/04/17  14:55:48  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.4  1996/03/20  18:46:12  pinnacle
# Replaced: smutil/func/SMextentSrf.I for:  by jwfrosch for vds.240
#
# Revision 1.3  1996/03/18  23:28:32  pinnacle
# Replaced: smutil/func/SMextentSrf.I for:  by jwfrosch for vds.240
#
# Revision 1.2  1996/03/18  15:38:24  pinnacle
# Replaced: smutil/func/SMextentSrf.I for:  by jwfrosch for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	03/11/96	HF	Write the extended surface to a file which can be read in by the
 *					command : "debug in"
 *				to enable easier debugging/viewing of the intermediate surfaces.
 *				(ONLY if "ci=toggle" has set : ( VDfunct | VDcomment ) == TRUE)
 *
 *				TR : 179600808 179600185 179525874 179528620
 *				    (179418916 179525583 179525758 179525577
 *				     179421367)
 *
 * -------------------------------------------------------------------*/

/*
 *  File name :		SMextentSrf.I
 *  Description :	Extension of a B-spline surface given a range
 *  Revision date :	92/01/14
 *
 *  History :
 *	alc 	04 Nov 92 Creation date
 *		24 Dec 92 Compute direction points using evaluated derivates
 *		14 Jan 92 Check if an extension is needed (partial range cases,
 *			u/v_phy_closed case, etc.)
 *      pl	23 Mar 93 set the orientation of the extend surface the same
 *		          as the input surface.
 *	HF	01 Nov 94
 *		In order to improve the behaviour of the Split Surface Command
 *		a couple of different BS functions are used for performing the
 *		extension of the surface in the routine SMextentSrfRg().
 *		(According to Dieter Breden this function should produce a more
 *		 stable and accurate result.)
 *		The previous code can be activated (and the new code deactivated)
 *		by setting SMExtSrf_OLD_CODE to TRUE.
 *
 *  This file implements 2 functions to extend a surface given a range :
 *
 *	1) SMextentObjSrfRg() works on surface objects
 *	2) SMextentSrfRg() works directly on surface geometries
 *
 */

class implementation    Root;

#include <stdio.h>

#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "growner.h"
#include "dp.h"
#include "OMmacros.h"
#include "grmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "bserr.h"
#include "msdef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSopt.h"
#include "EMSssprops.h"
#include "VDmem.h"

#include "bsgeom_cvsf.h"

/* Include files from $BS/prototypes */

#include "bsrgbxint.h"
#include "bsbx2.h"
#include "bsdistptpt.h"
#include "bssfeval.h"
#include "bssfxttpt.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "malncbcli.h"

#include "bssftgeomsf.h"
#include "bsxgmsfdst.h"

#define	VD_DEBUG

#include "VDdebug.h"

from GRvg               import GRgetsize, GRgetgeom ;
from EMSgenbs		import GRconstruct ;
from EMSsubbs		import EMget_props ,EMset_props;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				GLOBAL VARIABLES				*/
/* 			Defined in: smutil/func/SMxtglbldf.c			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern int	SMExtSrf_OLD_CODE;	/*
					 * Controls execution of OLD or NEW [=default] code
					 * NEW code = execute BSxgmsfdst() in SMextentSrfRg()
					 * OLD code = execute BSsfxttpt () in SMextentSrfRg()
					 *
					 * Obsolete:
					 * ci=toggle_old : toggles SMExtSrf_OLD_CODE
					 */

extern int	SMExtSrf_Fil_Nm;	/*
					 * To control the extension of the names of the
					 * "extent.srf_<nn>" files which are created
					 * ONLY when ( VDfunct | VDcomment ) == TRUE
					 * (use ci=toggle to toggle TRUE / FALSE)
					 */

extern int	SMExtSrf_Ext_Opt;	/*
					 * To control "ext_option" for BSxgmsfdst()
					 * in SMextentSrfRg() from within SMBndS1BySfs()
					 */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

IGRlong SMextentObjSrfRg ( msg, surf_id, ext_range, cst, reduce_data, ext_surf_id )
  IGRlong                *msg;		/* O */
  struct GRobj_env       *surf_id;	/* I */
  GRrange                 ext_range;	/* I */
  struct GRvg_construct  *cst;		/* I */
  IGRboolean              reduce_data;	/* I (not yet implemented) */
  struct GRid            *ext_surf_id;	/* O */

/*
 * Description :
 *
 *	Given a range, this function will construct an extented surface,
 *	calling the function SMextentSrfRg() (implemented also in this file)
 *
 * Assumptions :
 *
 *	- The input surface must be of class EMSsubbs
 *	- All the computations are done in world coordinates.
 *	- The range of the initial surface must be included in the extension
 *	range (93/01/06 : partial range is now handled, allowing that a part of
 *	the surface is in the extension range)
 *
 * Return codes :
 *
 *	- OM_S_SUCCESS for success
 *	- OM_E_ABORT   for failure
 *	- OM_W_ABORT   if the input surface is not within the extension range
 *
 * Note :
 *	The reduce_data option is not yet implemented
 */

{
  BSrc                    bsrc;
  struct IGRbsp_surface  *surf_geom_ptr = NULL, *ext_surf_geom_ptr = NULL;
  IGRlong                 size;
  OMuword                 surf_cl;
  IGRlong                 status, SMmsg;
  extern GRclassid        OPP_EMSsubbs_class_id;
  IGRuchar                props, c_props;
  IGRlong                 SMextentSrfRg ();	/* Forward declaration */

  __enterFunction ( name = "SMextentObjSrfRg" );

  *msg = MSFAIL;

  /*
   * Test if we have a B-spline surface
   */

  status = om$get_classid ( osnum = surf_id->obj_id.osnum,
			    objid = surf_id->obj_id.objid,
			    p_classid = &surf_cl );
  as$status ( action = GOTO_VALUE, value = wrapup );

  if ( om$is_ancestry_valid ( superclassid = OPP_EMSsubbs_class_id,
			      subclassid = surf_cl ) != OM_S_SUCCESS )
  {
    __prints ( "Input surface is not a B-spline" );
    status = OM_E_ABORT;
    as$status ( action = GOTO_VALUE, value = wrapup );
  }

  /*
   * Get surface geometry, and extent it
   */

  status = om$send ( msg = message EMSsubbs.EMget_props ( &SMmsg,
							  &props ),
		     senderid = NULL_OBJID,
		     targetid = surf_id->obj_id.objid,
		     targetos = surf_id->obj_id.osnum );
  as$status ( action = GOTO_VALUE, value = wrapup );
  if ( !( SMmsg & 1 ) )
  {
    status = OM_E_ABORT;
    as$status ( action = GOTO_VALUE, value = wrapup );
  }

  status = om$send ( msg = message GRvg.GRgetsize ( &SMmsg,
						    &surf_id->mod_env.md_env.matrix_type,
						    surf_id->mod_env.md_env.matrix,
						    &size ),
		     senderid = NULL_OBJID,
		     targetid = surf_id->obj_id.objid,
		     targetos = surf_id->obj_id.osnum );
  as$status ( action = GOTO_VALUE, value = wrapup );
  if ( !( SMmsg & 1 ) )
  {
    status = OM_E_ABORT;
    as$status ( action = GOTO_VALUE, value = wrapup );
  }

  surf_geom_ptr = (struct IGRbsp_surface *) _MALLOC ( size, char );
  if ( surf_geom_ptr == NULL )
  {
    status = OM_E_ABORT;
    as$status ( action = GOTO_VALUE, value = wrapup );
  }

  status = om$send ( msg = message GRvg.GRgetgeom ( &SMmsg,
						    &surf_id->mod_env.md_env.matrix_type,
						    surf_id->mod_env.md_env.matrix,
						    ( IGRchar * ) surf_geom_ptr ),
		     senderid = NULL_OBJID,
		     targetid = surf_id->obj_id.objid,
		     targetos = surf_id->obj_id.osnum );
  as$status ( action = GOTO_VALUE, value = wrapup );
  if ( !( SMmsg & 1 ) )
  {
    status = OM_E_ABORT;
    as$status ( action = GOTO_VALUE, value = wrapup );
  }

  /*
   * Call extent function
   */

  reduce_data = TRUE;			/* not yet implemented */

  status = SMextentSrfRg ( &SMmsg, surf_geom_ptr, ext_range,
			   reduce_data, &ext_surf_geom_ptr );
  as$status ( sts = status & SMmsg, action = GOTO_VALUE, value = wrapup );

  /*
   * Construct the extended surface
   */

  ext_surf_id->osnum = cst->env_info->md_id.osnum;

  cst->geometry = ( IGRchar * ) ext_surf_geom_ptr;

  status = om$construct ( classname = "EMSgenbs",
			  osnum = ext_surf_id->osnum,
			  p_objid = &ext_surf_id->objid,
			  msg = message EMSgenbs.GRconstruct ( cst ) );
  as$status ( action = GOTO_VALUE, value = wrapup );

  status = om$send ( msg = message EMSsubbs.EMget_props ( &SMmsg,
							  &c_props ),
		     senderid = NULL_OBJID,
		     targetid = ext_surf_id->objid,
		     targetos = ext_surf_id->osnum );
  as$status ( action = GOTO_VALUE, value = wrapup );
  if ( !( SMmsg & 1 ) )
  {
    status = OM_E_ABORT;
    as$status ( action = GOTO_VALUE, value = wrapup );
  }
  if ( ( ( props & EMSIS_NRML_REVERSED ) && ( !( c_props & EMSIS_NRML_REVERSED ) ) )
       || ( !( props & EMSIS_NRML_REVERSED ) && ( c_props & EMSIS_NRML_REVERSED ) ) )
  {

    status = om$send ( msg = message EMSsubbs.EMset_props ( &SMmsg,
							    ( unsigned char ) EMSIS_NRML_REVERSED,
							    ( char ) EMS_O_TOGGLE ),
		       senderid = NULL_OBJID,
		       targetid = ext_surf_id->objid,
		       targetos = ext_surf_id->osnum );
    as$status ( action = GOTO_VALUE, value = wrapup );
    if ( !( SMmsg & 1 ) )
    {
      status = OM_E_ABORT;
      as$status ( action = GOTO_VALUE, value = wrapup );
    }
  }

  /*
   * Menage in both cases
   */

  *msg = MSSUCC;			/* success so far */

wrapup:

  __exitFunction ( name = "SMextentObjSrfRg", argfmt = "%s",  args = "Success Exit" );

  if ( surf_geom_ptr != NULL )
    _FREE ( surf_geom_ptr );
  if ( ext_surf_geom_ptr != NULL )
    BSfreesf ( &bsrc, ext_surf_geom_ptr );
  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

IGRlong SMextentSrfRg ( msg, surface, ext_range, reduce_data, ext_surf )
  IGRlong                *msg;		/* O */
  struct IGRbsp_surface  *surface;	/* I */
  GRrange                 ext_range;	/* I */
  IGRboolean              reduce_data;	/* I (not yet implemented) */
  struct IGRbsp_surface **ext_surf;	/* O */

/*
 * Description :
 *
 *	Given a range, this function will extent side by side a surface
 *	geometry to an extended one.
 *
 * Assumptions :
 *
 *	- All the computations are done in world coordinates.
 *	- The range of the initial surface is included in the extension range.
 *
 * Return codes :
 *
 *	- OM_S_SUCCESS for success
 *	- OM_E_ABORT   for failure
 *	- OM_W_ABORT   if the input surface is not within the extension range
 *
 * Notes :
 *
 *	- Memory for **ext_surf is allocated by BSsfxttpt(), and should
 *	  be freeed by a BSfreesf().
 *	- The reduce_data option is not yet implemented
 *
 */

{
  IGRlong                 status;
  IGRint                  num_ext_done;
  IGRint                  nd;			/* BSsfeval  : number of derivatives */
  IGRint                  ext_option;		/* BSsfxttpt : option to extent */
  IGRint                  i_cor, i_side;
  IGRlong                 num_poles;
  GRrange                 surf_range, inter_range;
  GRrange                 cum_range;
  IGRboolean              inter_flag;

  IGRdouble               surf_center[3];	/* center of the initial surface range box */

  IGRdouble               side_point[12];	/* buffer for 4 points  */
  IGRdouble               side_vector[12];	/* buffer for 4 vectors */

/*IGRdouble	eval[12] ; 	 space for (nd+1) * (nd+1) points */

  IGRpoint                eval[4];		/* Jean: 4/april/93 Correction for 2.2 */
  IGRdouble               side_ext1[12], side_ext2[12];

  struct IGRline          tmp_line;
  struct IGRline_seg      clip_line;
  IGRdouble               clip_points[6];
  IGRdouble               aux_point[3];
  IGRboolean              seg_found;

  IGRdouble               scal;
  IGRdouble               uclip1[3], uclip2[3], ucenter[3];	/* vectors */
  IGRdouble               dclip1, dclip2;	/* squared distance */
  IGRboolean              ext_needed[4];	/* updated in 2 passes */
  IGRlong                 sizebuf, nret;
  IGRdouble               bas_tol;

  struct IGRbsp_surface  *aux1_surf, *aux2_surf;
  BSrc                    bsrc;

  struct BSgeom_bsp_surf  gmsf, xgmsf;

  __enterFunction ( name = "SMextentSrfRg" );

  /*
   * Get basis tolerance (used later to check if a side extension is needed)
   */

  sizebuf = sizeof ( IGRdouble );
  gr$get_basis_tolerance ( msg = &status,
			   sizbuf = &sizebuf,
			   buffer = &bas_tol,
			   nret = &nret );
  if ( !( status & 1 ) )
  {
    status = OM_W_ABORT;
    as$status ();			/* go on */
    bas_tol = 1e-6;
  }

  /*
   * Get range of initial surface
   */

  num_poles = surface->u_num_poles * surface->v_num_poles;
  BSbx2 ( &bsrc,
	  &num_poles, ( IGRpoint * ) surface->poles,	/* Jean 4/12/93 Cast for 2.2 */
	  ( surface->rational ? surface->weights : NULL ),
	  &surf_range[0], &surf_range[3] );
  if ( bsrc != BSSUCC )
  {
    status = OM_E_ABORT;
    as$status ( action = GOTO_VALUE, value = wrapup );
  }

  /*
   * Check if the range of the surface intersects the extension range
   */

  BSrgbxint ( &surf_range[0], &surf_range[3], &ext_range[0], &ext_range[3],
	      &inter_flag, &inter_range[0], &inter_range[3], &bsrc );
  if ( bsrc != BSSUCC )
  {
    status = OM_E_ABORT;
    as$status ( action = GOTO_VALUE, value = wrapup );
  }

  if ( inter_flag == FALSE )
  {
    __prints ( "Surface outside extension range" );

    /*
     * Just return the same geometry in another format to be consistent with BSsfxttpt()
     */

    /* surface->num_boundaries = 0;	// see BSallocsf() note ... */
    BSallocsf ( surface->u_order, surface->v_order, surface->u_num_poles,
		surface->v_num_poles, surface->rational, surface->num_boundaries,
		ext_surf, &bsrc );
    if ( bsrc != BSSUCC )
    {
      status = OM_W_ABORT;
      as$status ( action = GOTO_VALUE, value = wrapup );
    }

    BSsf_copy ( &bsrc, surface, *ext_surf );
    if ( bsrc != BSSUCC )
    {
      BSfreesf ( &bsrc, *ext_surf );
      status = OM_E_ABORT;
      as$status ( action = GOTO_VALUE, value = wrapup );
    }
    goto quit;
  }

  /*
   * Get "cumulative" range (includes both surface and extension ranges)
   */

  for ( i_cor = 0; i_cor < 3; i_cor++ )
  {
    cum_range[i_cor] = ( ext_range[i_cor] > surf_range[i_cor] ?
			 surf_range[i_cor] : ext_range[i_cor] );
  }					/* min */

  for ( i_cor = 3; i_cor < 6; i_cor++ )
  {
    cum_range[i_cor] = ( ext_range[i_cor] < surf_range[i_cor] ?
			 surf_range[i_cor] : ext_range[i_cor] );
  }					/* max */

  /*
   * Extent surface within the given range
   */

  /*
   * 1) Evaluate side points (0.50, 0), (0, 0.50), (0.50, 1) and (1, 0.50)
   *	and their appropriate partials
   */

  /*
   * Note : if a partial derivative is null, a vector is computed from the
   *	center of the surface to the current evaluated side point
   */

  /*
   * 1.1) Update ext_needed[] (first pass)
   */

  if ( surface->v_phy_closed )
  {
    __prints ( "Surface is v-physically closed" );
    ext_needed[0] = FALSE;
    ext_needed[2] = FALSE;
  }
  else
  {
    ext_needed[0] = TRUE;
    ext_needed[2] = TRUE;
  }

  if ( surface->u_phy_closed )
  {
    __prints ( "Surface is u-physically closed" );
    ext_needed[1] = FALSE;
    ext_needed[3] = FALSE;
  }
  else
  {
    ext_needed[1] = TRUE;
    ext_needed[3] = TRUE;
  }

  /*
   * 1.2) Evaluate surface point at (0.5, 0.5)
   */

  BSsfeval ( surface, 0.50, 0.50, 0, eval, &bsrc );
  if ( bsrc != BSSUCC )
  {
    status = OM_E_ABORT;
    as$status ();
    for ( i_cor = 0; i_cor < 3; i_cor++ )
    {
      surf_center[i_cor] = ( surf_range[i_cor] + surf_range[3 + i_cor] ) * 0.5;
    }
  }
  else				/* Add by jean 4/12/93 (because parameter BSsfeval was surf_center before)*/
    for ( i_cor = 0; i_cor < 3; i_cor++ )
    {
      surf_center[i_cor] = eval[0][i_cor];
    }

  /*
   * 1.3) Evaluate side points and partials
   */

  nd = 1;				/* number of derivatives */

  BSsfeval ( surface, 0.50, 0.00, nd, eval, &bsrc );
  if ( bsrc != BSSUCC )
  {
    status = OM_E_ABORT;
    as$status ();
  }
  for ( i_cor = 0; i_cor < 3; i_cor++ )
  {
    side_point[i_cor] = eval[0][i_cor];
    side_vector[i_cor] = eval[2][i_cor];	/* v partial */
  }
  BSnorvec ( &bsrc, &side_vector[0] );
  if ( bsrc != BSSUCC )
  {
    for ( i_cor = 0; i_cor < 3; i_cor++ )
    {
      side_vector[i_cor] = side_point[i_cor] - surf_center[i_cor];
    }
    BSnorvec ( &bsrc, &side_vector[0] );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }
  }					/* null partial */

  BSsfeval ( surface, 0.00, 0.50, nd, eval, &bsrc );
  if ( bsrc != BSSUCC )
  {
    status = OM_E_ABORT;
    as$status ();
  }
  for ( i_cor = 0; i_cor < 3; i_cor++ )
  {
    side_point[3 + i_cor] = eval[0][i_cor];
    side_vector[3 + i_cor] = eval[1][i_cor];	/* u partial */
  }
  BSnorvec ( &bsrc, &side_vector[3] );
  if ( bsrc != BSSUCC )
  {
    for ( i_cor = 0; i_cor < 3; i_cor++ )
    {
      side_vector[3 + i_cor] = side_point[3 + i_cor] - surf_center[i_cor];
    }
    BSnorvec ( &bsrc, &side_vector[3] );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }
  }					/* null partial */

  BSsfeval ( surface, 0.50, 1.00, nd, eval, &bsrc );
  if ( bsrc != BSSUCC )
  {
    status = OM_E_ABORT;
    as$status ();
  }
  for ( i_cor = 0; i_cor < 3; i_cor++ )
  {
    side_point[6 + i_cor] = eval[0][i_cor];
    side_vector[6 + i_cor] = eval[2][i_cor];	/* v partial */
  }
  BSnorvec ( &bsrc, &side_vector[6] );
  if ( bsrc != BSSUCC )
  {
    for ( i_cor = 0; i_cor < 3; i_cor++ )
    {
      side_vector[6 + i_cor] = side_point[6 + i_cor] - surf_center[i_cor];
    }
    BSnorvec ( &bsrc, &side_vector[6] );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }
  }					/* null partial */

  BSsfeval ( surface, 1.00, 0.50, nd, eval, &bsrc );
  if ( bsrc != BSSUCC )
  {
    status = OM_E_ABORT;
    as$status ();
  }
  for ( i_cor = 0; i_cor < 3; i_cor++ )
  {
    side_point[9 + i_cor] = eval[0][i_cor];
    side_vector[9 + i_cor] = eval[1][i_cor];	/* u partial */
  }
  BSnorvec ( &bsrc, &side_vector[9] );
  if ( bsrc != BSSUCC )
  {
    for ( i_cor = 0; i_cor < 3; i_cor++ )
    {
      side_vector[9 + i_cor] = side_point[9 + i_cor] - surf_center[i_cor];
    }
    BSnorvec ( &bsrc, &side_vector[9] );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }
  }					/* null partial */

  /*
   * 2) Compute intersections with the range box to find the extension point
   */

  for ( i_side = 0; i_side < 4; i_side++ )
  {

    if ( !ext_needed[i_side] )
      continue;

    for ( i_cor = 0; i_cor < 3; i_cor++ )
    {
      aux_point[i_cor] = side_point[3 * i_side + i_cor] + side_vector[3 * i_side + i_cor];
    }

    tmp_line.point1 = &side_point[3 * i_side];
    tmp_line.point2 = &aux_point[0];
    clip_line.beg_point = &clip_points[0];
    clip_line.end_point = &clip_points[3];

    seg_found = MAlncbclip ( &status,
			     &tmp_line, &cum_range[0], &cum_range[3], &clip_line );

    if ( ( status != MSSUCC ) || ( !seg_found ) )
    {
      status = OM_E_ABORT;
      as$status ( action = GOTO_VALUE, value = wrapup );
    }

    /*
     * Check if a side extension is needed
     */

    BSmkvec ( &bsrc, uclip1, &side_point[i_side * 3], &clip_points[0] );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }
    BSmkvec ( &bsrc, uclip2, &side_point[i_side * 3], &clip_points[3] );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }
    BSmkvec ( &bsrc, ucenter, &side_point[i_side * 3], &surf_center[0] );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }

    dclip1 = uclip1[0] * uclip1[0] + uclip1[1] * uclip1[1] + uclip1[2] * uclip1[2];
    dclip2 = uclip2[0] * uclip2[0] + uclip2[1] * uclip2[1] + uclip2[2] * uclip2[2];

    /*
     * Update ext_needed[] (second pass)
     */

    if ( dclip1 < bas_tol * bas_tol || dclip2 < bas_tol * bas_tol )
    {
      ext_needed[i_side] = FALSE;
    }
    else
    {
      ext_needed[i_side] = TRUE;
    }

    /*
     * Compute priority extension point
     */

    scal = BSdotp ( &bsrc, ucenter, uclip1 );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }

    if ( scal < 0 )
    {
      for ( i_cor = 0; i_cor < 3; i_cor++ )
      {
	side_ext1[3 * i_side + i_cor] = clip_points[i_cor];
	side_ext2[3 * i_side + i_cor] = clip_points[3 + i_cor];
      }
    }
    else
    {
      for ( i_cor = 0; i_cor < 3; i_cor++ )
      {
	side_ext1[3 * i_side + i_cor] = clip_points[3 + i_cor];
	side_ext2[3 * i_side + i_cor] = clip_points[i_cor];
      }
    }
  }					/* i_side */

  /*
   * 3) Find extension point for each side point, and extent surface
   */

  aux1_surf = surface;			/* initial geometry */
  ext_option = 0;			/* linear extension */
  num_ext_done = 0;

  for ( i_side = 0; i_side < 4; i_side++ )
  {
    if ( !ext_needed[i_side] )
    {
      __printf ( "No extension needed for side number %d", i_side );

      continue;				/* skip */
    }

    __printf ( "Extension needed for side number %d", i_side );

    /*
     * HF : 11/1/94
     *
     * In order to improve the behaviour of the Split Surface Command
     * a couple of different BS functions are used for performing the
     * extension of the surface.
     * (According to Dieter Breden this function should produce a more
     *  stable and accurate result.)
     * The previous code can be activated (and the new code deactivated)
     * by setting SMExtSrf_OLD_CODE to TRUE.
     */

   if ( SMExtSrf_OLD_CODE )	// Obsolete: Toggled by ci=toggle_old
   {
    BSsfxttpt ( ext_option,
		aux1_surf,
		&side_point[i_side * 3],	/* direction point */
		&side_ext1[i_side * 3],		/* extension point */
		&aux2_surf,
		&bsrc );

    if ( bsrc == BSINVEXTDIR )
    {
      /*
       * yet another attempt
       */

      __prints ( "Inverse extension" );

      BSsfxttpt ( ext_option,
		  aux1_surf,
		  &side_point[i_side * 3],	/* direction point */
		  &side_ext2[i_side * 3],	/* extension point */
		  &aux2_surf,
		  &bsrc );
    }

    if ( bsrc != BSSUCC )
    {
      __prints ( "One side extension has failed" );

      if ( bsrc != BSINVEXTDIR )
      {
	status = OM_E_ABORT;
	as$status ();
      }
      /*
       * go on for next extension
       */
    }
    else
    {
      __prints ( "Side extension successfull" );

      num_ext_done++;
      if ( aux1_surf != surface )
      {
	BSfreesf ( &bsrc, aux1_surf );
      }

      aux1_surf = aux2_surf;		/* store intermediate result */
    }
  }
  else		/* DEFAULT : SMExtSrf_OLD_CODE is NOT '#define'd */
  {
    IGRboolean		tst_all = 1;
    IGRint		type    = 0;
    IGRboolean		vleft   = ext_needed[0] & (i_side == 0 ),
			uleft   = ext_needed[1] & (i_side == 1 ),
			vright  = ext_needed[2] & (i_side == 2 ),
			uright  = ext_needed[3] & (i_side == 3 );
    IGRdouble		dist    = 0,
			dist_out= 0;

    gmsf .bounded  = TRUE;
    gmsf .bspsf    = aux1_surf;
    gmsf .sfgen_cv = NULL;
    xgmsf.bspsf    = NULL;
    xgmsf.sfgen_cv = NULL;

    /*
     * The function BSsftgeomsf() needs to be called in order to fill out the
     * struct BSgeom_bsp_surf with the proper values required by the function
     * BSxgmsfdst() to perform the extension of the surface.
     */

    BSsftgeomsf ( &gmsf, tst_all, type, &bsrc );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ( action = GOTO_VALUE, value = wrapup );
    }
    else
    {
      if ( gmsf.sfgen_cv != NULL )
      {
	BSfreecv ( &bsrc, gmsf.sfgen_cv );
	gmsf.sfgen_cv = NULL;
      }
    }

    dist = BSdistptpt ( &bsrc, &side_point[i_side * 3], &side_ext1[i_side * 3] );
    if ( bsrc != BSSUCC )
    {
      status = OM_E_ABORT;
      as$status ();
    }

    /*
     * Since the function BSxgmsfdst() is called with a (possibly) different distance for
     * extending each of the four edges of the surface, only ONE of the parameters:
     *		uleft, uright, vleft, vright
     * should have a TRUE value for the corresponding edge to extend.
     *
     * Testing against a number of TR's learns that usually polynomial extension has a
     * better chance on successfull returning from "message EMSsurface.EMintsurf_saveside()"
     * than linear extension.
     */

    //ext_option = 0;			/* linear     extension */
    //ext_option = 1;			/* polynomial extension */

    ext_option = SMExtSrf_Ext_Opt;	/* defined in SMBndS1BySfs()	*/

    //JLL/HF: 03/18/2001 - If order == 2 always set  ext_option = 1
    if( (uleft ==1) && ( gmsf.bspsf->u_order == 2) ) ext_option = 1;
    if( (uright==1) && ( gmsf.bspsf->u_order == 2) ) ext_option = 1;
    if( (vleft ==1) && ( gmsf.bspsf->v_order == 2) ) ext_option = 1;
    if( (vright==1) && ( gmsf.bspsf->v_order == 2) ) ext_option = 1;

    __printf ( "i_side = %d, uleft = %d, uright = %d, vleft = %d, vright = %d, ext_option = %d, uord = %d, vord = %d, dist = %lg",
	       `i_side, uleft, uright, vleft, vright, ext_option, gmsf.bspsf->u_order, gmsf.bspsf->v_order, dist` );

    BSxgmsfdst (&gmsf, dist, ext_option, uleft, uright, vleft, vright, &xgmsf, &dist_out, &bsrc);

    if ( bsrc != BSSUCC )
    {
      __printf ( "Extension on side [%d] has failed", i_side);

      continue;
    }
    else
    {
      __prints ( "Side extension successfull" );

      if ( xgmsf.sfgen_cv != NULL )
      {
	BSfreecv ( &bsrc, xgmsf.sfgen_cv );
	xgmsf.sfgen_cv = NULL;
      }
      if ( xgmsf.bspsf != NULL )
      {
	if ( xgmsf.bspsf != aux1_surf && aux1_surf != surface && aux1_surf != NULL )
	{
	  BSfreesf ( &bsrc, aux1_surf );	/* Free previous intermediate result */
	}
	aux1_surf = xgmsf.bspsf;		/* Store new intermediate result */
	num_ext_done++;
      }
    }
   }
  }					/* for */

  /*
   * Output extended geometry
   */

  if ( num_ext_done == 0 )
  {
    /*
     * Just return the same geometry in another format to be consistent with BSsfxttpt()
     */

    /* surface->num_boundaries = 0;	// see BSallocsf() note ... */
    BSallocsf ( surface->u_order, surface->v_order, surface->u_num_poles,
		surface->v_num_poles, surface->rational, surface->num_boundaries,
		ext_surf, &bsrc );
    if ( bsrc != BSSUCC )
    {
      status = OM_W_ABORT;
      as$status ( action = GOTO_VALUE, value = wrapup );
    }

    BSsf_copy ( &bsrc, surface, *ext_surf );
    if ( bsrc != BSSUCC )
    {
      BSfreesf ( &bsrc, *ext_surf );
      status = OM_E_ABORT;
      as$status ( action = GOTO_VALUE, value = wrapup );
    }
  }
  else
  {
    *ext_surf = aux1_surf;
  }

  if ( VDfunct | VDcomment )	// Toggled at run-time by: "ci=toggle"
  {
    /*
     * HF : 03/11/96
     *
     * Write the extended surface to a file which can be read in by the
     * 		command : "debug in"
     * to enable easier debugging/viewing of the intermediate surfaces.
     */
    char extent_srf[15];
    FILE *fp = NULL;
    IGRboolean option = FALSE;
    extern IGRboolean BSprintbsps();

    sprintf  ( extent_srf, "extent.srf_%d", SMExtSrf_Fil_Nm );
    extent_srf[14] = '\0';
    __printf ( "Writing extended surface to file : <%s>", extent_srf );

    fp = fopen ( extent_srf, "w" );
    if ( fp != NULL )
    {
      BSprintbsps ( fp, NULL, aux1_surf, option );
      fclose ( fp );
    }
  }

  if ( reduce_data )
  {
//    __prints ( "Not yet implemented" );
  }

quit:				/* everything OK */

  __exitFunction ( name = "SMextentSrfRg", argfmt = "%s",  args = "Success Exit" );

  *msg = MSSUCC;
  return OM_S_SUCCESS;

wrapup:				/* error case */

  __exitFunction ( name = "SMextentSrfRg", argfmt = "%s",  args = "Error Exit" );

  *ext_surf = NULL;
  *msg = MSFAIL;
  return status;
}

end implementation      Root;
