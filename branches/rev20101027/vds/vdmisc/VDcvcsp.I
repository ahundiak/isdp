/* $Id: VDcvcsp.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDcvcsp.I
 *
 * Description:
 *		Finds cusp (knuckle) points of a curve
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDcvcsp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/01/28  21:36:30  pinnacle
# Created: vdmisc/VDcvcsp.I by impd for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/27/98	HF		creation date
 *
 ***************************************************************************/
/*
	I/VDS

	VDget_cv_cusp_pts
	-----------------
Abstract

	This function finds cusp (knuckle) points of a curve

Arguments

OUT	long			*msg		completion code
IN	const struct GRobj_env	*crv		curve to be tested
OUT	int			*num_csp	number of cusps
OUT	double			*cusps		cusp points, must be freed by caller
OUT	BSrc			*rc		return code from BS function

RETURN_VALUE		TRUE if no errors occurred, else FALSE
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
#include "bscvarreval.h"
#include "bsfndcvcsp.h"
#include "bsxtractpar.h"

extern GRclassid	OPP_GRcurve_class_id;
extern GRclassid	OPP_EMSsubbs_class_id;

extern double		fabs();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDget_cv_cusp_pts ( msg, crv, num_csp, cusps, rc )

  long			 *msg ;
  struct GRobj_env	 *crv ;
  int			 *num_csp;
  double		**cusps ;
  BSrc			 *rc ;

{
  int			 i0, sts = OM_S_SUCCESS;

  IGRdouble		*par = NULL;
  IGRdouble		 bastol= 0.0, chtol= 0.0;
  struct IGRbsp_curve   *curve = NULL;
  struct IGRbsp_surface *surf  = NULL;

  __enterFunction ( name = "VDget_cv_cusp_pts", argfmt = "crv = [%d,%d]",
		    args = `crv->obj_id.osnum, crv->obj_id.objid` );

  *msg     = MSSUCC;
  *rc      = BSSUCC;
  *num_csp = 0;

  BSxtractpar( rc, BSTOLBASIS, &bastol );
  BSxtractpar( rc, BSTOLCHRDHT, &chtol );

  /*
   * Check if curve is really a curve
   */
  if ( ! vd_$is_ancestry_valid ( object  = &crv->obj_id, 
				 classid = OPP_GRcurve_class_id ) )
  {
    printf ( "Selected object is not a curve\n" );
    *msg = MSFAIL ;
    sts  = 0;
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
    sts  = 0;
    goto wrapup;
  }

  /*
   * Malloc the required memory
   */

  par  = _MALLOC ( curve->num_poles - curve->order +1, IGRdouble );

  if ( ! par )
  {
    *msg = MANOMEMORY ;
    sts  = 0;
    goto wrapup ; 
  }
    
  /*
   * Retrieve the number of cusps & cusp para values of a curve
   */

  BSfndcvcsp ( curve, num_csp, par, rc);

  __printf ( "BSfndcvcsp(): rc = %d, curve->num_poles = %d, num_csp = %d", `*rc, curve->num_poles, *num_csp` );

  if ( BSSUCC != *rc )
  {
    *msg = MSFAIL ;
    sts  = 0;
    goto wrapup ; 
  }
  else
  {
    if ( *num_csp == 0 )		// NO cusps found, so no need to continue
    {
      goto quit;
    }
  }

  for ( i0=0; i0 < *num_csp; i0++ )
  {
    __printf ( "par[%d] = %lg", `i0, par[i0]` );
  }
  
  /*
   * Malloc the required memory
   */

  (*cusps) = _MALLOC ( *num_csp * 3, IGRdouble );

  if ( ! cusps )
  {
    *msg = MANOMEMORY ;
    sts  = 0;
    goto wrapup ; 
  }
    
  /*
   * Retrieve the XYZ cusp points corresponding to the para values
   */
  BScvarreval ( rc, curve, par, *num_csp, 0, *cusps );

  if ( BSSUCC != *rc )
  {
    *msg = MSFAIL ;
    sts  = 0;
    goto wrapup ; 
  }

  /*
   * Check the minimum distances against the tolerance
   */

  for ( i0=0; i0 < *num_csp * 3; i0+=3 )
  {
    __printf ( "cusps[%d] = %lg, %lg, %lg", `i0, (*cusps)[i0], (*cusps)[i0+1], (*cusps)[i0+2]` );
  }

quit:

  sts = OM_S_SUCCESS;

wrapup : 

  _FREE( curve ) ;
  _FREE( par  ) ;

  __exitFunction ( name = "VDget_cv_cusp_pts" );

  return (sts) ;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDppl_free ( char * ptr )
{
  _FREE ( ptr );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDSroot ;
