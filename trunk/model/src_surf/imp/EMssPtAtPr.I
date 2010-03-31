/* ###################   APOGEE COMPILED   ################## */
# define DEBUG 0

class implementation EMSsubbs;

#include "EMS.h"
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

# include "madef.h"                     /* has MAIDMX */
# include "OMerrordef.h"                /* OM error code defintions */
# include "bstypes.h"
# include "bserr.h"
# include "msmacros.h"
# include "codef.h"

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

/*
  History   RC   07/23/87  Modified  such more than one
                           point can be evaluated.
            WBC  03/31/93  Changed the declaration of the local variables
                           'four' and 'one' from IGRint to IGRshort since
                           pointers to IGRshorts are expected by MAmulmx.
 */

method EMptatpr (IGRlong *msg; IGRshort *mat_type; IGRmatrix
    matrix; IGRdouble point_parametric[]; IGRint num_parameters;
    IGRpoint wpoint_xyz)
{
    IGRshort id_mat_type = MAIDMX;    
    IGRmatrix id_matrix;
    IGRshort four = 4, one = 1;
 extern  IGRboolean  MAmulmx ();
  extern     IGRboolean MAidmx ();
  extern     void BSsfeval ();
    IGRint dummy_i; /* for GRgetabsg */
    IGRdouble lcs_point[4], u, v, umin, vmin, umax, vmax;
    struct IGRbsp_surface *surface_pointer;
    IGRboolean status;
    char *generic_pointer;
    BSrc rc;
        IGRint num_pts;
    IGRint i;

    num_pts = num_parameters/2;

    if (num_pts * 2 != num_parameters ) return MSINARG;

    status = MAidmx (msg, id_matrix);
    STATUS_RET ("EMSsubbs.EMptatpr, MAidmx failed", status, *msg);

    GRgetabsg
        (msg, &id_mat_type, id_matrix, &generic_pointer, dummy_i);
    ERROR_RET ("EMSsubbs.EMptatpr, GRgetabsg failed", *msg);
    surface_pointer = (struct IGRbsp_surface *) generic_pointer;

    for (i = 0; i < num_pts ; i++)
        {
            u = point_parametric[2*i];
            v = point_parametric[2*i+1];
            umin = surface_pointer->u_knots[surface_pointer->u_order-1];
            umax = surface_pointer->u_knots[surface_pointer->u_num_poles];
            vmin = surface_pointer->v_knots[surface_pointer->v_order-1];
            vmax = surface_pointer->v_knots[surface_pointer->v_num_poles];
            if (u < umin)
              u = umin;
            else if (u > umax)
              u = umax;
            if (v < vmin)
              v = vmin;
            else if (v > vmax)
              v = vmax;
            BSsfeval (surface_pointer, u, v, 0, lcs_point, &rc);
        if (BSERROR (rc))
         STATUS_RET ("EMSsubbs.EMptatpr, BSsfeval failed", FALSE, MSFAIL);

        lcs_point[3] = 1;
        if (*mat_type IS MAIDMX)
        {
                wpoint_xyz[3*i] = lcs_point[0];
                wpoint_xyz[3*i+1] = lcs_point[1];
                wpoint_xyz[3*i+2] = lcs_point[2];
        }
        else
        {
           IGRdouble wcs_point[4],

                status = MAmulmx
                   (msg, &four, &four, &one, matrix, lcs_point, wcs_point);
                STATUS_RET ("EMSsubbs.EMptatpr, MAmulmx failed", status, *msg);
                wpoint_xyz[3*i] = wcs_point[0];
                wpoint_xyz[3*i+1] = wcs_point[1];
                wpoint_xyz[3*i+2] = wcs_point[2];
        }
    }

    return OM_S_SUCCESS;
}

end implementation EMSsubbs;
