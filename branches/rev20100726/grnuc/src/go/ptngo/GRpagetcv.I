/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpagetcv

Description
        This function gets the abstract geometry of the master patterning
        element (at position zero of the input channel) and allocates a copy
        of the curve for the calling routine.  This copy is used to form a
        curve prism to clip the pattern components.  The copy is necessary
        because the geometry cache will be wiped out during clipping.

Synopsis
        IGRint GRpagetcv (msg, caller, to_comp, module, cv)

        IGRlong             *msg;       return code
        GRobjid             *caller;    calling object's id
        OM_S_CHANSELECT     *to_comp;   channel to the master element
        struct GRmd_env     *module;    of the caller
        struct IGRbsp_curve **cv;       output curve

Notes
        The caller is responsible for deallocating the memory for the
        returned curve.

Return Codes
        IGRint ()       OM_S_SUCCESS if successful
                        OM_E_ERROR if unsucessful
        IGRlong msg     MSSUCC if successful
                        MANOMEMORY if failure allocating for new curve

History
        mrm     11/25/87    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "gocmacros.h"

IGRint GRpagetcv (msg, caller, to_comp, module, cv)

IGRlong             *msg;       /* return code */
GRobjid             *caller;    /* calling object's id */
OM_S_CHANSELECT     *to_comp;   /* channel to the master element */
struct GRmd_env     *module;    /* of the caller */
struct IGRbsp_curve **cv;       /* output curve */

{
    IGRint              i;          /* integer variable */
    IGRlong             sts;        /* return code */
    IGRlong             cvsize;     /* size of the curve */
    struct IGRbsp_curve *cache;     /* points to geometry cache */
    struct IGRbsp_curve *cv_ptr;    /* output curve */

    sts = OM_S_SUCCESS;

    /*
     *  get the abstract geometry for the master element
     *  into the geometry cache
     */

    sts = om$send (msg = message GRvg.GRgenabsg( msg, 
                                                &module->md_env.matrix_type,
                                                 module->md_env.matrix, 
                                                 (IGRchar **)&cache ),
                   senderid = *caller,
                   p_chanselect = to_comp,
                   from = 0,
                   to = 0);

    if ((sts & *msg & 1))
    {
        /*
         *  compute size of curve
         */

        GRbc_size (cache->order, (cache->num_poles + cache->order),
                   cache->rational, cache->num_boundaries, cvsize);

        /*
         *  allocate for new curve
         */

        if ((*cv = (struct IGRbsp_curve *) om$malloc (size = cvsize)) == NULL)
        {
            sts = OM_E_ERROR;
            *msg = MANOMEMORY;
        }
        else
        {
            /*
             *  copy curve geometry from the geometry cache
             */

            cv_ptr = *cv;
            *cv_ptr = *cache;

            GRbc_partition (cv_ptr, cache->order,
                            (cache->num_poles + cache->order), 
                            cache->rational, cache->num_boundaries);

            for (i = 0; i < (cv_ptr->num_poles * 3); i++)
            {
                cv_ptr->poles[i] = cache->poles[i];
            }

            if (cv_ptr->rational)
            {
                for (i = 0; i < cv_ptr->num_poles; i++)
                {
                    cv_ptr->weights[i] = cache->weights[i];
                }
            }

            if (cv_ptr->num_boundaries)
            {
                for (i = 0; i < cv_ptr->num_boundaries; i++)
                {
                    cv_ptr->bdrys[i] = cache->bdrys[i];
                }
            }

            for (i = 0; i < cv_ptr->num_knots; i++)
            { 
                cv_ptr->knots[i] = cache->knots[i];
            }
        }
    }
            
    return (sts);
}

end implementation GRpa;
