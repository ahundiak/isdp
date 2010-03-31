/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*

NAME
        EFmkperpvcpl - Make a vector perpendicular to 2 other vectors.

SYNOPSIS
        EFmkperpvcpl (planepts, pt, vec)
        IGRpoint    planepts[], pt;
        IGRvector   vec;

DESCRIPTION
        This routine will make a vector perpendicular to 2 vectors
        that are thenselves already perpendicular. The two input 
        vectors are defined by 3 input points. The first point is 
        assumed to be the intersection point of these vectors. It 
        will also be the begin point for the calculated vector. The 
        two other points define the direction and magnatude or the 
        input vectors. The single input point is a point somewhere 
        off of the plane defined by the two input vectors. This 
        routine will move that point to be directly over point 1 
        defined in planepts and mutually perpendicular to both 
        input vectors.
        
NOTES
        The algorithm for this routine was largely taken from
        the BSbox math routine.

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
        Sudha   06/02/93        modified to include for BSprototype headers
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
#include "bsproj1.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bscrossp.h"

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

IGRlong EFmkperpvcpl (planepts, pt, vec)

IGRpoint  planepts[]; /*input - 3 pts to determine plane*/
IGRpoint  pt;         /*input - point off plane | output - modified pt*/
IGRvector vec;        /*output - normal vector to plane from pt1 to pt4*/

/*Function returns:  EMS_S_Success
                     EMS_E_Fail
                     EMS_I_Modified
*/
{
IGRboolean status;
IGRboolean changed = FALSE;
IGRlong    msg, i;
IGRdouble  len, tolerance;
IGRvector  vec1, vec2, normal;
IGRpoint   proj_pt, temp;

for (i=0; i<3; i++)
 temp[i] = pt[i];

status = BSEXTRACTPAR(&msg, BSTOLLENVEC, tolerance);
if (!status) return EMS_E_Fail;

status = BSmkvec(&msg, vec1, &planepts[0][0], &planepts[1][0]);
if (!status) return EMS_E_Fail;

status = BSmkvec(&msg, vec2, &planepts[0][0], &planepts[2][0]);
if (!status) return EMS_E_Fail;

status = BScrossp(&msg, vec1, vec2, normal);
if (!status) return EMS_E_Fail;

status = BSnorvec(&msg, normal);
if (!status) return EMS_E_Fail;

status = BSproj1(&msg, pt, normal, &planepts[0][0], proj_pt);
if (!status) return EMS_E_Fail;

status = BSmkvec(&msg, vec, proj_pt, pt);
if (!status) return EMS_E_Fail;

len = BSlenvec(&msg, vec);
if (BSERROR(msg)) return EMS_E_Fail;

if (len < tolerance) return EMS_E_Fail;
for (i=0; i<3; i++)
{
 pt[i] = planepts[0][i] + vec[i];
 if ( ABS(temp[i]-pt[i]) > tolerance )
  changed = TRUE;
}
if (changed)
 return EMS_I_Modified;
else
 return EMS_S_Success;
} 
