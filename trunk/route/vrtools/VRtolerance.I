/* $Id: VRtolerance.I,v 1.1 2001/10/25 19:30:34 anand Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrtools/VRtolerance.I
 *
 * Description:
 * 	An attempt to have an acceptable and consistent means for using the
 * 	"right" tolerance value (when comparing two double quantities).
 *
 * Motivation:
 * 	JTS TRs 5651, 5652, 5649 and perhaps many others.
 *
 * Dependencies:
 * 	vrinclude/VRMath.h	-> Constants used in VRGetTol are defined here.
 * 	BSMath related stuff	-> BSEXTRACTPAR has been used to extract the
 * 				   basis tolerance value.
 *
 * Revision History:
 *	$Log: VRtolerance.I,v $
 *	Revision 1.1  2001/10/25 19:30:34  anand
 *	JTS TRs 5649, 5651 and 5652.
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *			Anand		creation date
 *
 ***************************************************************************/

class implementation Root;

#include <stdio.h>
#include "bs.h"
#include "bsparameters.h"
#include "vrdbgmacros.h"

#define DONT_EXTERN_TOL_FUNC
#include "VRMath.h"

%safe
static double VRROUTETOL=1.0e99;
%endsafe

void VRSetRouteTol(double VRValToSet)
{
    BSrc	bsretcode;
    double	BSMathBaseTol;

    SetProc( VRSetRouteTol ); Begin
    __DBGpr_dbl(" Argument passed to VRSetBaseTol", VRValToSet );

    BSEXTRACTPAR( &bsretcode, BSTOLLENVEC, BSMathBaseTol );
    __DBGpr_dbl(" Value of BSTOLLENVEC", BSMathBaseTol );

    /* Check to see if function was called with a value meant to replace the
     * basis tolerance.  If user called VRSetBaseTol with -1 as arg, he simply
     * meant VRROUTETOL to be set to the basis tolerance */
    if( VRValToSet == -1.0 )	// Note: EXACT EQUALITY INSISTED.
    {
	if( VRROUTETOL != 1.0e99 && VRROUTETOL != BSMathBaseTol )
	    printf("Route Tolerance reset to %le\n",BSMathBaseTol);

	VRROUTETOL = BSMathBaseTol;
	End
	return;
    }

    if( BSMathBaseTol != VRValToSet )
	printf("ROUTE TOLERANCE OVERRIDEN to %le\n",VRValToSet);

    VRROUTETOL = VRValToSet;
    End
    return;
}

static double VRGetRouteTol(void)
{
    BSrc	bsretcode;
    double	BSMathBaseTol;
    SetProc( VRGetRouteTol ); Begin

    BSEXTRACTPAR( &bsretcode, BSTOLLENVEC, BSMathBaseTol );
    __DBGpr_dbl(" Value of BSTOLLENVEC", BSMathBaseTol );

    if( VRROUTETOL == 1.0e99 )
	VRSetRouteTol( -1.0 );

    if( BSMathBaseTol != VRROUTETOL )
    {
	printf("Using Overridden Route Tolerance of %le!\n", VRROUTETOL);
	End
	return VRROUTETOL;
    }

    End
    return BSMathBaseTol;
}

double VRGetTol(int VRWhatKindOfTol)
{
    double RouteTol;

    RouteTol = VRGetRouteTol();

    switch( VRWhatKindOfTol )
    {
	case VR_DEFAULT_TOL:
	    return RouteTol;

	case VR_LENGTH_TOL:
	case VR_DIST_TOL:
	    return RouteTol;

	case VR_SQRLEN_TOL:
	    return (2.0*RouteTol);

	case VR_ANGULAR_TOL:
	    return RouteTol; /*
				 ????????????????????????????????????????????
				 ? Do we need to consider Deg-to-Rad and/or ?
				 ? Rad-to-Deg conversion? Remember, the	    ?
				 ? conversion factor is 57.295779515, i.e., ?
				 ? the tolerance will increase or decrease  ?
				 ? by two orders of magnitude!		    ?
				 ????????????????????????????????????????????
			       */

	case VR_BENDRAD_TOL:
	    return RouteTol;

	case VR_SKETCH_TOL:
	    return RouteTol;

	case VR_DOTPROD_TOL:
	case VR_ORTHO_TOL:
	case VR_DELTA_TOL:
	    return (RouteTol*1.732050808);
    }
}

end implementation Root;
