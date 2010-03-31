/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
# define DEBUG 0

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
# include "codef.h"
# include "bsparameters.h"
# include "bsgeom_cvsf.h"

# define IS     ==
# define AND    &&
# define OR     ||
# define NOT    !

# define  TRUE  1
# define  FALSE 0

#define WBC_USE_NEW_MATH 1

method EMpratpt (IGRlong *msg; IGRshort *mat_type; IGRmatrix
    matrix; IGRpoint wpoint_xyz; IGRdouble point_parametric[]; IGRint
    *num_parameters)
{
    IGRint dummy_i; /* for GRgetabsg */
    struct IGRbsp_surface *surface;
    IGRlong om_msg = OM_S_SUCCESS;
    char *generic_pointer;

    GRgetabsg 
        (msg, mat_type, matrix, &generic_pointer, dummy_i);
    surface = (struct IGRbsp_surface *) generic_pointer;
    surface->num_boundaries = 0;
    if (COERROR (*msg))
    {
        om$report_error(sts = *msg);
        om_msg = OM_E_ABORT;
    }
    else
    {
 extern  IGRboolean  BSprptonsf ();
 extern  IGRboolean     BSfreecv();
 extern  void           BSprptarrsf(),
                        EFinit_geom_surface();
#if !WBC_USE_NEW_MATH
        IGRboolean status;
#endif
        BSrc rc;
        IGRboolean onSurf = FALSE;
        IGRdouble dist_tol;
        struct BSgeom_bsp_surf geom_surface;

#if WBC_USE_NEW_MATH
        geom_surface.sfgen_cv = NULL;

        EFinit_geom_surface(msg, surface, my_id, OM_Gw_current_OS,
                            &geom_surface);
        if (!(1 & *msg))
            goto wrapup;

        dummy_i = 1;
        BSEXTRACTPAR( &rc, BSTOLLENVEC, dist_tol );

        BSprptarrsf(&geom_surface, dist_tol, 0, 0, &dummy_i,
                    wpoint_xyz, point_parametric, NULL, &onSurf,
                    NULL, &rc);

        if (rc == BSSUCC)
#else
        status = BSprptonsf (&rc, surface, wpoint_xyz,
            &point_parametric[0], &point_parametric[1], &onSurf);

        if (status)
#endif
        {
            if (onSurf) *num_parameters = 2;
            else *num_parameters = 0;
        }
        else
        {
            *msg = EMS_E_NoSolution;
        }
#if WBC_USE_NEW_MATH
        if (geom_surface.sfgen_cv)
            BSfreecv(&rc, geom_surface.sfgen_cv);
#endif
    }
wrapup:
    return om_msg;
}

end implementation EMSsubbs;
