/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
 DESCRIPTION

 This function will return a matrix that will align (make colinear and
 end-to-end) one line segment with another.

 RETURN VALUES

 sts		EMS_S_Success - no problems
                EMS_E_BSerror - BS math routine failed
		EMS_E_Fail - MA math routine failed

 HISTORY

 09/23/91 : WBC : Creation date.
 07/08/93 : Sudha Modified for BSprototypes ansification

 */

#include "EMS.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "emsedgedef.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "emserr.h"
#include "madef.h"
#include "maidmx.h"
#include "magrotmx.h"
#include "maang2vc.h"
#include "bscrossp.h"


IGRlong EFget_alignment_matrix(line_segment, line_to_align,
                               align_matrix, parallel)

IGRdouble  line_segment[6];
IGRdouble  line_to_align[6];   /* line segment to be aligned with line_seg */
IGRdouble  align_matrix[16];   /* 4X4 matrix that will align line_to_align with
                                  line_seg (make colinear and end-to-end */
IGRboolean *parallel;          /* TRUE is returned if the input segments are
                                  are paralle, otherwise FALSE is returned */
{
    IGRlong	sts, rc;
    IGRint      index;
    IGRdouble   angle[3], vector[3], vector_to_align[3], rot_axis[3];

    sts = EMS_S_Success;

    /* create line vectors from the line segments */

    for (index = 0; index < 3; index++)
    {
        vector[index] = line_segment[index + 3] - line_segment[index];
        vector_to_align[index] = line_to_align[index + 3] - line_to_align[index];
    }

    /* find the rotation matrix that will make line_to_align parallel to
     * line_segment
     */

    MAang2vc(&rc, vector_to_align, vector, angle);
    EMerr_hndlr (!(1 & rc), sts, EMS_E_Fail, wrapup);

    if (angle[0] != 0.0)
    {
        sts = BScrossp (&rc, vector_to_align, vector, rot_axis);
        EMerr_hndlr(!sts || rc != BSSUCC, sts, EMS_E_BSerror, wrapup);

        if (angle[0] > PI )
            angle[0] = 2 * PI - angle[0];

        MAgrotmx(&rc, rot_axis, line_to_align, &angle[0], align_matrix);
        EMerr_hndlr (!(1 & rc), sts, EMS_E_Fail, wrapup);
        *parallel = FALSE;
    }
    else  /* create an identity matrix */
    {
        MAidmx (&rc, align_matrix);
        EMerr_hndlr (!(1 & rc), sts, EMS_E_Fail, wrapup);
        *parallel = TRUE;
    }

    /* change the translation of the matrix to get the line segments aligned
     * (end-to-end)
     */

    for (index = 0; index < 3; index++)
        align_matrix[(index * 4) + 3] += line_segment[index + 3] -
                                                       line_to_align[index];

wrapup:

    return (sts);
}
