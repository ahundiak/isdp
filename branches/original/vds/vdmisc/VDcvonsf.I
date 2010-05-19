/* $Id: VDcvonsf.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDcvonsf.I
 *
 * Description:
 *		Test if curve is on surface with regards to tolerance
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDcvonsf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/01/29  18:14:16  pinnacle
# Replaced: vdmisc/VDcvonsf.I for:  by impd for vds
#
# Revision 1.2  1998/01/26  23:59:44  pinnacle
# Replaced: vdmisc/VDcvonsf.I for:  by jwfrosch for vds
#
# Revision 1.1  1998/01/22  20:00:18  pinnacle
# Created: vdmisc/VDcvonsf.I by impd for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/21/98	HF		creation date
 *
 ***************************************************************************/
/*
	I/VDS

	VDcurve_on_surface
	------------------
Abstract

	This function tests if a curve is on a surface with regards to tol.

Arguments

OUT	long			*msg	completion code
IN	const struct GRobj_env	*crv	curve to be tested
IN	const struct GRobj_env	*srf	surface to 
IN	double			 tol	tolerance used for testing: must be >= 0.0
					- if tol=0.0          , it will be set to chord_height_tol
					- if 0.0<tol<basis_tol, it will be set to basis_tol
OUT	BSrc			*rc	return code from BS function

RETURN_VALUE		TRUE if curve on surface, else FALSE
*/

class implementation VDSroot ;

#include <stdio.h>
#include <stdlib.h>
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "growner.h"
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_geommacros.h"

#define	VD_DEBUG

#include "VDdebug.h"

/*
 * Includes of function prototypes.
 */
#include "bscvnodptrg.h"
#include "bscvnodpts.h"
#include "bsxtractpar.h"

extern GRclassid	OPP_GRcurve_class_id;
extern GRclassid	OPP_EMSsubbs_class_id;

extern double		fabs();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDcurve_on_surface( msg, crv, srf, tol, rc )

  long			*msg ;
  struct GRobj_env	*crv ;
  struct GRobj_env	*srf ;
  double		 tol ;
  BSrc			*rc ;

{
  int			 i0, sts, result = FALSE;
  IGRint		 num_insert = 0, num_pts = 0;

  IGRdouble		*node_vals = NULL, *node_pts = NULL;
  IGRdouble		*mdist = NULL, *uvmin = NULL, *ptmin = NULL;
  IGRdouble		 user_dsup = 0.0, bastol= 0.0, chtol= 0.0, max_tol = tol;
  struct IGRbsp_curve   *curve = NULL;
  struct IGRbsp_surface *surf  = NULL;

  __enterFunction ( name = "VDcurve_on_surface", argfmt = "tol = %lg, crv = [%d,%d], srf = [%d,%d]",
		    args = `tol, crv->obj_id.osnum, crv->obj_id.objid, srf->obj_id.osnum, srf->obj_id.objid` );

  *msg    = MSSUCC;
  *rc     = BSSUCC;

  BSxtractpar( rc, BSTOLBASIS, &bastol );
  BSxtractpar( rc, BSTOLCHRDHT, &chtol );

  if ( tol <  0.0 ) tol = fabs (tol);
  if ( tol == 0.0 )
  {
    tol = chtol ;
  }
  else if ( tol < bastol )
  {
    tol = bastol ;
  }
  /*
   * If max_tol is too large ==>> problems on CLIX with function BSmdptbssf(), so adjust if necessary
   */
  if ( max_tol / bastol > 1000. ) max_tol = bastol * 1000.;

  __printf ( "tol = %lg, max_tol = %lg, Basis_Tol = %lg, Chord_Height_Tol = %lg", `tol, max_tol, bastol, chtol` );

  /*
   * Check if curve is really a curve
   */
  if ( ! vd_$is_ancestry_valid ( object  = &crv->obj_id, 
				 classid = OPP_GRcurve_class_id ) )
  {
    printf ( "Selected object is not a curve\n" );
    *msg = MSFAIL ;
    goto wrapup;
  }
 
  /*
   * Check if surface is really a surface
   */
  if ( ! vd_$is_ancestry_valid ( object  = &srf->obj_id, 
				 classid = OPP_EMSsubbs_class_id ) )
  {
    printf ( "Selected object is not a surface\n" );
    *msg = MSFAIL ;
    goto wrapup;
  }
  
  /*
   * Get the geometry data for the curve
   */
  sts = vd_$get_geometry ( msg      =  msg,
			   grobjId  = &crv->obj_id,
			   grobjEnv = &crv->mod_env,
			   geometry = &curve );

  if ( ! ( sts & *msg & 1 ) )
  {
    printf("Problem with getting curve geometry\n");
    *msg = MSFAIL ;
    goto wrapup;
  }
  
  /*
   * Get the geometry data for the surface
   */
  sts = vd_$get_geometry ( msg      =  msg,
			   grobjId  = &srf->obj_id,
			   grobjEnv = &srf->mod_env,
			   geometry = &surf );

  if ( ! ( sts & *msg & 1 ) )
  {
    printf("Problem with getting surface geometry\n");
    *msg = MSFAIL ;
    goto wrapup;
  }

  /*
   * Malloc the required memory
   */

  node_vals = _MALLOC ( curve->num_poles    , IGRdouble );
  node_pts  = _MALLOC ( curve->num_poles * 3, IGRdouble );

  if ( ! node_vals || ! node_pts )
  {
    *msg = MANOMEMORY ;
    goto wrapup ; 
  }
    
  /*
   * Retrieve the node points corresponding to the poles 
   */

  BScvnodpts ( curve, num_insert, &num_pts, node_vals, node_pts, rc);

  __printf ( "BScvnodpts() : *rc = %d, curve->num_poles = %d, num_pts = %d", `*rc, curve->num_poles, num_pts` );

  if ( BSSUCC != *rc )
  {
    *msg = MSFAIL ;
    goto wrapup ; 
  }
  
  if ( num_pts != curve->num_poles )
  {
    printf ( "VDcurve_on_surface() -> BScvnodpts(): num_pts[%d] != curve->num_poles[%d]\n", num_pts, curve->num_poles );

    // Some action required in this case ?!?!?!?
  }
  
  /*
   * Malloc the required memory
   */

  mdist  = _MALLOC ( num_pts    , IGRdouble );
  uvmin  = _MALLOC ( num_pts * 2, IGRdouble );
  ptmin  = _MALLOC ( num_pts * 3, IGRdouble );

  if ( ! mdist || ! uvmin || ! ptmin )
  {
    *msg = MANOMEMORY ;
    goto wrapup ; 
  }
    
  /*
   * Retrieve the minimum distances from the node points of the curve to the surface
   */

  BSmdptbssf ( surf, num_pts, node_pts, max_tol, user_dsup, mdist, uvmin, ptmin, rc);

  if ( BSSUCC != *rc )
  {
    *msg = MSFAIL ;
    goto wrapup ; 
  }

  /*
   * Check the minimum distances against the tolerance
   */

  for ( i0=0; i0 < num_pts; i0++ )
  {
    __printf ( "mdist[%d] = %lg", `i0, mdist[i0]` );

    if ( mdist[i0] > tol ) goto wrapup;
  }

  result = TRUE;

wrapup : 

  _FREE( curve ) ;
  _FREE( surf  ) ;

  _FREE( node_vals ) ;
  _FREE( node_pts  ) ;

  _FREE( mdist  ) ;
  _FREE( uvmin  ) ;
  _FREE( ptmin  ) ;


  __exitFunction ( name = "VDcurve_on_surface" );

  return (result) ;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDSroot ;
