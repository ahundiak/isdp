/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*

NAME
        EFmkperp2vec - Make two vectors perpendicular to each other.

SYNOPSIS
        EFmkperp2vec (pt1, pt2, pt3, vec1, vec2)
        IGRpoint    pt1, pt2, pt3;
        IGRvector   vec1, vec2;

DESCRIPTION
        This routine will make two vectors perpendicular to each
        other. Pt1 and pt2 are the two points that define the
        first vector and pt1 and pt3 are the two points that
        define the second vector. Vec1 and vec2 are calculated
        from these points and vec2 is modified to be perpendicular
        to vec1. Also pt3 which corresponds to vec2 is modified
        by adding vec2 to pt1 (making the new perpendicular point).
        
NOTES
        The algorithm for this routine was largely taken from
        the BSplane3pt math routine.

RETURN VALUES
        If successful, the function returns EMS_S_Success. Or,
        EMS_I_Modifed is returned if the routine was successful 
        and the point was modified (to make it perpendicular if 
        it wasn't already). Any other error will cause EMS_E_Fail
        to be returned.

HISTORY
        21-Jan-1987  J. Brooke King:  added #undefs for TRUE,
                    FALSE and ABS in order to avoid warnings.
        DLB 11/25/86    Creation date.

	Sudha	06/02/93	modified to include for BSprototype headers

*/

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
#include "bsparameters.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsdistptpts.h"

#ifdef ABS
#undef ABS
#endif
#define ABS(X) ((X) >= 0 ? (X) : -(X))
#ifdef TRUE
#undef TRUE
#endif
#define TRUE 1
#ifdef FALSE
#undef FALSE
#endif
#define FALSE 0

IGRlong EFmkperp2vec (pt1, pt2, pt3, vec1, vec2)

IGRpoint  pt1;        /*input - point 1 of plane*/
IGRpoint  pt2;        /*input - point 2 of plane*/
IGRpoint  pt3;        /*input - point 3 of plane | output - modified pt*/
IGRvector vec1;       /*output - vector from pt1 to pt2*/
IGRvector vec2;       /*output - vector from pt1 to pt3*/

/*Function returns:  EMS_S_Success
                     EMS_E_Fail
                     EMS_I_Modified
*/
{
IGRvector  zerovec;
IGRint     i, status;
IGRlong    msg;
IGRdouble  t, tolerance;
IGRpoint   temp1;
IGRboolean changed = FALSE;

status = BSEXTRACTPAR(&msg, BSTOLLENVEC, tolerance);
if (!status) return EMS_E_Fail;
for (i=0; i<3; i++)
{
 temp1[i] = pt3[i];
 vec1[i] = pt2[i] - pt1[i];
 vec2[i] = pt3[i] - pt1[i];
 zerovec[i] = 0;
}
t = BSdistptpts(&msg, vec1, zerovec);
if (BSERROR(msg)) return EMS_E_Fail;
t = (vec2[0] * vec1[0] + vec2[1] * vec1[1] + vec2[2] * vec1[2]) / t;
for (i=0; i<3; i++)
{
 vec2[i] = pt1[i] + t * vec1[i];
 vec2[i] = pt3[i] - vec2[i];
 pt3[i] = pt1[i] + vec2[i]; 
 if ( ABS(temp1[i]-pt3[i]) > tolerance )
  changed = TRUE;
}
if (changed)
 return EMS_I_Modified;
else
 return EMS_S_Success;
}
