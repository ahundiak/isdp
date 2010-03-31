/* ###################   APOGEE COMPILED   ################## */
/*
  HISTORY

    Sudha  06/16/93     Modified for BSprototype ansification
*/

# define DEBUG 0

class implementation GRbspline;

#include "EMS.h"
# if DEBUG
# include <stdio.h>
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

# include "OMerrordef.h"    /* OM error code defintions */
# include "bserr.h"
# include "emserr.h"
# include "EMSerrordef.h"
# include "codef.h"

# include "msdef.h"

#include "bsprptoncv.h"

# define IS     ==
# define AND    &&
# define OR     ||
# define NOT    !

# define  TRUE  1
# define  FALSE 0

method EMpratpt (IGRlong *msg; IGRshort *mat_type; IGRmatrix
    matrix; IGRpoint wpoint_xyz; IGRdouble point_parametric[]; IGRint
    *num_parameters)
{
    IGRint dummy_i; /* for GRgetabsg */
    char *generic_pointer;
    struct IGRbsp_curve *curve;
    IGRlong om_msg = OM_S_SUCCESS;

    GRgetabsg 
        (msg, mat_type, matrix, &generic_pointer, dummy_i);
    curve = (struct IGRbsp_curve *) generic_pointer;
    if (COERROR (*msg))
    {
        om$report_error(sts = *msg);
        om_msg = OM_E_ABORT;
    }
    else
    {
        IGRboolean status;
        BSrc rc;
        IGRboolean onCurve = FALSE;

        status = BSprptoncv (&rc, curve, wpoint_xyz,
            point_parametric, &onCurve);

        if (status)
        {
            if (onCurve) *num_parameters = 1;
            else *num_parameters = 0;
        }
        else
        {
            *msg = EMS_E_NoSolution;
        }
    }

    return(om_msg);
}

end implementation GRbspline;
