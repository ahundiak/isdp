/* ###################   APOGEE COMPILED   ################## */
# define DEBUG 0

class implementation GRbspline;

/*

  HISTORY

    Sudha  06/16/93     Modified for BSprototype ansification
*/

#include "EMS.h"
#include "mamulmx.h"
#include "maidmx.h"
# include <stdio.h>

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

# include "igrdef.h"
# include "madef.h"                     /* has MAIDMX */
# include "OMerrordef.h"                /* OM error code defintions */
# include "bstypes.h"
# include "bserr.h"
# include "msmacros.h"
# include "codef.h"

#include "bscveval.h"

# define IS     ==
# define AND    &&
# define OR     ||
# define NOT    !

# define  TRUE  1
# define  FALSE 0

# define ERROR_RET(error_string, error_status) \
if (COERROR (error_status)) \
{ \
    (void)fprintf (stderr, "%s\n", error_string); \
    om$report_error(sts = error_status); \
    return (error_status); \
}

# define STATUS_RET(error_string, error_status, error_msg) \
if (NOT (error_status)) \
{ \
    (void)fprintf (stderr, "%s\n", error_string); \
    om$report_error(sts = error_msg); \
    return (error_msg); \
}

method EMptatpr (IGRlong *msg; IGRshort *mat_type; IGRmatrix
    matrix; IGRdouble point_parametric[]; IGRint num_parameters;
    IGRpoint wpoint_xyz)
{
    IGRshort id_mat_type = MAIDMX;    
    IGRmatrix id_matrix;
    IGRshort dimension = 4;
    IGRshort four = 4, one = 1;
    IGRint dummy_i; /* for GRgetabsg */
    IGRdouble lcs_point[4];
    struct IGRbsp_curve *curve_pointer;
    IGRboolean status;
    char *generic_pointer;
    BSrc rc;

    if (num_parameters != 1) return MSINARG;

    status = MAidmx (msg, id_matrix);
    STATUS_RET ("GRbspline.EMptatpr, MAidmx failed", status, *msg);

    GRgetabsg
        (msg, &id_mat_type, id_matrix, &generic_pointer, dummy_i);
    ERROR_RET ("GRbspline.EMptatpr, GRgetabsg failed", *msg);
    curve_pointer = (struct IGRbsp_curve *) generic_pointer;

    BScveval (curve_pointer, point_parametric[0], 0, (IGRpoint *)&lcs_point[0], &rc);
    if (BSERROR (rc))
        STATUS_RET ("GRbspline.EMptatpr, BScveval failed", FALSE, MSFAIL);

    lcs_point[3] = 1;
    if (*mat_type IS MAIDMX)
    {
        wpoint_xyz[0] = lcs_point[0];
        wpoint_xyz[1] = lcs_point[1];
        wpoint_xyz[2] = lcs_point[2];
    }
    else
    {
        IGRdouble wcs_point[4],

        status = MAmulmx
            (msg, &four, &four, &one, matrix, lcs_point, wcs_point);
        STATUS_RET ("GRbspline.EMptatpr, MAmulmx failed", status, *msg);
        wpoint_xyz[0] = wcs_point[0];
        wpoint_xyz[1] = wcs_point[1];
        wpoint_xyz[2] = wcs_point[2];
    }
    
    return OM_S_SUCCESS;
}

end implementation GRbspline;
