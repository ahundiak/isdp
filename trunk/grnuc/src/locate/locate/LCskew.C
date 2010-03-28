/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	This function is to fill in the skew scan structure defined
	by the Rtree.  

Notes	
	This function is only called from the LCquery function.

History
	7/20/87	Started documentation.
*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMindex.h"
#include "igrtypedef.h"

LC_fill_skew (skew, range, range2)
SKEW_KEY_3D_DBL	  *skew;
IGRdouble *range, *range2;
{

/*
 *	Fill in stucture so that it can be done in one place instead of 
 *	several.
 */

    skew->range1.xmin = *range++;
    skew->range1.ymin = *range++;
    skew->range1.zmin = *range++;
    skew->range1.xmax = *range++;
    skew->range1.ymax = *range++;
    skew->range1.zmax = *range;

    skew->range2.xmin = *range2++;
    skew->range2.ymin = *range2++;
    skew->range2.zmin = *range2++;
    skew->range2.xmax = *range2++;
    skew->range2.ymax = *range2++;
    skew->range2.zmax = *range2;
}

