/*
Name
        GRgcscvt

Description
        This file contains the methods GRcvt_to_wld_coords and
        GRcvt_to_lcl_coords for the GRgencs class.  These methods
        convert points from local to world coordinates or vice versa.

History
        dhm     07/15/92    ansi conversion.
        mrm     12/31/92    changed to use GRget_cstype_info
*/

class implementation GRgencs;

#include "grimport.h"
#include "grmessage.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "cspriv.h"
#include "msdef.h"
#include "gocmacros.h"

extern IGRboolean MAinvmx();
extern IGRboolean MAtypemx();
extern IGRboolean MAoptsxform();
extern IGRboolean MAreccyl();
extern IGRboolean MArecsph();
extern IGRboolean MAsphrec();
extern IGRboolean MAcylrec();
extern struct GRcstype_info *GRget_cstype_info();

/*
Name
        GRcvt_to_wld_coords

Description
        This method accepts points in a specified coordinate system type
        and converts them to the rectangular world system.

Synopsis
        IGRlong     *msg            o - completion status
                                        MSSUCC  success; conversion complete
                                        MSFAIL  failed conversion
                                        MSINARG invalid coordinate system type
        IGRchar     *cstype         i - type of coord system, i.e.
                                        rectangular, spherical, cylindrical
        IGRint       npts           i - number of points to convert
        IGRdouble   *input_values   i - coordinates to convert
        IGRdouble   *wld_coords     o - world coordinates

History
        Kumar Talluri   10/05/86    creation
        mrm             12/18/87    use MSINARG for invalid cs type
                        12/28/87    fix problem sph & cyl
                        06/28/88    add npts argument
                        08/03/88    apply scale to pts
*/

method GRcvt_to_wld_coords (IGRlong     *msg;
                            IGRchar     *cstype;
                            IGRint       npts;
                            IGRdouble   *input_values;
                            IGRdouble   *wld_coords)
{
    IGRboolean      found;      /* search flag */
    IGRboolean      bsts;       /* boolean return code */
    IGRshort        mxtype;     /* for optimized point transform */
    IGRint          type;       /* index into p_cstypes array */
    IGRint          i;          /* index */
    IGRlong         sts;        /* return code */
    IGRdouble      *pts;        /* may point to intermediate pts */
    IGRdouble      *pts_to_cvt; /* rectangular values to convert to world */
    IGRdouble       ltw[16];    /* local to world transformation matrix */
    struct GRcstype_info *p_cstypes;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;
    pts = NULL;
    p_cstypes = GRget_cstype_info();

    /*
     *  check for valid coordinate system type
     */

    found = FALSE;

    for (type = 0; type < NUM_CS_TYPES; type++)
    {
        if (!(strncmp (cstype, p_cstypes[type].cstype, strlen(cstype))))
        {
            found = TRUE;
            break;
        }
    }

    if (found)
    {
        if (type == SPHERICAL || type == CYLINDRICAL)
        {
            if (pts = (IGRdouble *) om$malloc (size = npts * 3 *
                                               sizeof (IGRdouble)))
            {
                pts_to_cvt = pts;

                /*
                 *  convert the input points to rectangular coordinates
                 */

                if (type == SPHERICAL)
                {
                    for (i = 0; i < npts * 3; i += 3)
                    {
                        bsts = MAsphrec (msg, &input_values[i], &pts[i]);
                    }
                }
                else
                {
                    for (i = 0; i < npts * 3; i += 3)
                    {
                        bsts = MAcylrec (msg, &input_values[i], &pts[i]);
                    }
                }
            }
            else
            {
                *msg = MANOMEMORY;
                goto finish;
            }
        }
        else /* (type == RECTANGULAR) */
        {
            pts_to_cvt = input_values;
        }

        /*
         *  combine the orientation matrix with the scale vector
         *  to get a local-to-world transformation matrix
         */

        ltw[0] = me->matrix[0] * me->scale[0];
        ltw[1] = me->matrix[1] * me->scale[1];
        ltw[2] = me->matrix[2] * me->scale[2];
        ltw[3] = me->matrix[3];
        ltw[4] = me->matrix[4] * me->scale[0];
        ltw[5] = me->matrix[5] * me->scale[1];
        ltw[6] = me->matrix[6] * me->scale[2];
        ltw[7] = me->matrix[7];
        ltw[8] = me->matrix[8] * me->scale[0];
        ltw[9] = me->matrix[9] * me->scale[1];
        ltw[10] = me->matrix[10] * me->scale[2];
        ltw[11] = me->matrix[11];
        ltw[12] = me->matrix[12];
        ltw[13] = me->matrix[13];
        ltw[14] = me->matrix[14];
        ltw[15] = me->matrix[15];

        /*
         *  convert the rectangular coordinates to world coordinates
         */

        if (bsts = MAtypemx (msg, ltw, &mxtype))
        {
	    IGRlong nnpts = npts;
            bsts = MAoptsxform (msg, &nnpts, &mxtype, ltw, pts_to_cvt,
                                wld_coords);
        }
    }
    else
    {
        *msg = MSINARG; /* invalid type */
    } 

finish:

    if (pts) om$dealloc (ptr = pts);

    return (sts);
}



/*
Name
        GRcvt_to_lcl_coords

Description
        This method converts a world coordinate system point to local
        coordinates, in the specified coordinate system type.  All conversion
        is actually performed in rectangular coordinates.

Synopsis
        IGRlong     *msg            o - completion status
                                        MSSUCC   success, conversion complete
                                        MSFAIL   failed conversion
                                        MSINARG  invalid coordinate system type
        IGRchar     *cstype         i - type of coord system, i.e.
                                        rectangular, spherical, cylindrical
        IGRint       npts           i - number of points to convert
        IGRdouble   *input_values   i - coordinates to convert
        IGRdouble   *lcl_coords     o - local coordinates

History
        Kumar Talluri   10/05/86    creation
        mrm             12/18/87    use MSINARG for invalid cs type
                        06/28/88    add npts argument
                        08/03/88    apply scale to pts
*/

method GRcvt_to_lcl_coords (IGRlong     *msg;
                            IGRchar     *cstype;
                            IGRint       npts;
                            IGRdouble   *input_values;
                            IGRdouble   *lcl_coords)
{
    IGRboolean      found = FALSE;  /* flag */
    IGRshort        mxtype;         /* for optimized point transform */
    IGRshort        i;              /* index */
    IGRlong         sts;            /* return code */
    IGRlong         type;           /* index into p_cstypes array */
    IGRdouble      *pts;            /* may point to an intermediate array */
    IGRdouble      *cvt_pts;        /* converted points */
    IGRmatrix       wtl;            /* transformation matrix */
    struct GRcstype_info *p_cstypes;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;
    pts = NULL;
    p_cstypes = GRget_cstype_info();

    /*
     *  check for valid cstype
     */

    for (type = 0; type < NUM_CS_TYPES; type++)
    {
        if (!(strncmp (cstype, p_cstypes[type].cstype, strlen (cstype))))
        {
            found = TRUE;
            break;
        }
    }

    if (found)
    {
        /*
         *  if converting to rectangular put converted points directly into
         *  output array, otherwise allocate an intermediate array
         */

        if (type == SPHERICAL || type == CYLINDRICAL)
        {
            if (!(pts = (IGRdouble *) om$malloc (size = npts * 3 *
                                                 sizeof (IGRdouble))))
            {
                *msg = MANOMEMORY;
                goto finish;
            }
            cvt_pts = pts;
        }
        else /* (type == RECTANGULAR) */
        {
            cvt_pts = lcl_coords;
        }

        /*
         *  get a world-to-local matrix and the corresponding matrix type
         */

        i = 4;

        if (MAinvmx (msg, &i, me->matrix, wtl))
        {
            wtl[0] /= me->scale[0];
            wtl[1] /= me->scale[0];
            wtl[2] /= me->scale[0];
            wtl[3] /= me->scale[0];
            wtl[4] /= me->scale[1];
            wtl[5] /= me->scale[1];
            wtl[6] /= me->scale[1];
            wtl[7] /= me->scale[1];
            wtl[8] /= me->scale[2];
            wtl[9] /= me->scale[2];
            wtl[10] /= me->scale[2];
            wtl[11] /= me->scale[2];

            if (MAtypemx (msg, wtl, &mxtype))
            {
                /*
                 *  convert points to the local rectangular system
                 */
		IGRlong nnpts = npts;
                if (MAoptsxform (msg, &nnpts, &mxtype, wtl,
                                 input_values, cvt_pts))
                {
                    /*
                     *  if necessary, convert to spherical or cylindrical
                     */

                    if (type == SPHERICAL)
                    {
                        for (i = 0; i < npts * 3; i += 3)
                        {
                            MArecsph (msg, &cvt_pts[i], &lcl_coords[i]);
                        }
                    }
                    else if (type == CYLINDRICAL)
                    {
                        for (i = 0; i < npts * 3; i += 3)
                        {
                            MAreccyl (msg, &cvt_pts[i], &lcl_coords[i]);
                        }
                    }
                }
            }
        }
    }
    else
    {
        *msg = MSINARG; /* invalid type */
    }

finish:

    if (pts) om$dealloc (ptr = pts);

    return (sts);
}

end implementation GRgencs;
