/* ###################   APOGEE COMPILED   ################## */
/* 
 * DESCRIPTION
 *
 * The purpose of this routine is find the union of two ranges - the smallest
 * range that can contain both input ranges.  The resulting range is returned
 * in the second range.
 *
 * NOTES
 *
 * The second range will be overwritten by the union range.
 * 
 * HISTORY
 *
 * 01/14/92 : WBC : creation date
 */

# include "OMminimum.h"
# include "msdef.h" /* MS message codes */
# include "igrtypedef.h"
# include "igetypedef.h"
# include "gr.h"
# include "igr.h"
# include "igrdp.h"
# include "godef.h"
# include "go.h"

IGRint EFunion_ranges(range1, range2)

GRrange      range1;
GRrange      range2;
{
    IGRint index;

    for (index = 0; index < 3; index++)
    {
        if (range1[index] < range2[index])
            range2[index] = range1[index];
        if (range1[index + 3] > range2[index + 3])
            range2[index + 3] = range1[index + 3];
    }

    return(TRUE);
}
