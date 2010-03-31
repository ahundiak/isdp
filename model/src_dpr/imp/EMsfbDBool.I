/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
/*
HISTORY

19 Apr 1989 jBk Modified to make a proper ssi table, if
                applicable.

14 Apr 1988 jBk Changed name of message implemented from
                EMdisjoint to EMdisjointBoolean.

                Added capabilities for many more disjoint boolean
                operations, including several which produce empty
                sets.

04 Dec 1987 jBk Creation.

*/

# ifndef DEBUG
# define DEBUG 0
# endif

/* OM_E_ABORT */
# ifndef OM_D_MACROS
# include "OMmacros.h"
# endif

/* EMS_S_Success, EMS_E_Fail */
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

/* typedef EMSrc */
# ifndef EMStypedef_include
# include "EMStypedef.h"
# endif

/* NULL; EMSerror for EMSmsgReport */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

/* EMSmsgReport */
# ifndef EMScmacros_include
# include "EMScmacros.h"
# endif

/* EMSsfbool_opt_display */
# ifndef emssfintdef_include
# include "emssfintdef.h"
# endif

/* EMS_DO_DISPLAY */
# ifndef EMSopt_include
# include "EMSopt.h"
# endif

method EMdisjointBoolean (
    IGRlong *rc;
    enum EMSbooltype request;
    IGRushort options;
    struct GRvg_construct construct_list[1];
    GRobjid element;
    IGRint num_elements;
    GRobjid set[]
)
{
    int okay = TRUE;
    IGRshort activateOptions = 0;
    EMSrc omrc;
    IGRboolean emptySet;
    IGRboolean disjointSurfaces;
    IGRboolean firstOnly;
    IGRboolean allButFirst;
    IGRboolean lastOnly;
    union EMSssi_table *p_ssi = NULL;

    if (options & EMSsfbool_opt_display)
    {
        activateOptions = EMS_DO_DISPLAY;
    }

    omrc = om$send (
        msg = message EMSsfboolean.EMget_operation_type (
            rc                  /* IGRlong *EMmsg; */,
            &request            /* enum EMSbooltype *request; */,
            NULL                /* enum EMSbooltype *exactOperation; */,
            NULL                /* enum EMSbooltype *generalOperation; */,
            NULL                /* IGRboolean *reverseOrientation; */,
            &emptySet           /* IGRboolean *emptySet; */,
            &disjointSurfaces   /* IGRboolean *disjointSurfaces; */,
            &firstOnly          /* IGRboolean *firstOnly; */,
            &allButFirst        /* IGRboolean *allButFirst; */,
            &lastOnly           /* IGRboolean *lastOnly; */,
            NULL                /* IGRboolean *removedSolids; */,
            NULL                /* IGRlong *msgNumber */
        ),
        targetid = my_id
    );

    okay = EMSokay (omrc) AND EMSokay (*rc) AND disjointSurfaces;

    if (num_elements < 0)
    {
        okay = FALSE;
    }

    if (okay)
    {
        int lowix, highix, dimension;

        if (emptySet)
        {
            lowix = 0;
            highix = num_elements;
        }
        else if (firstOnly)
        {
            lowix = 1;
            highix = num_elements;
        }
        else if (allButFirst)
        {
            lowix = 0;
            highix = 0;
        }
        else if (lastOnly)
        {
            lowix = 0;
            highix = num_elements - 1;
        }
        else
        {
            lowix = 0;
            highix = -1;
        }            

        dimension = highix - lowix + 1;

        if (dimension)
        {        
            union EMSssiSizeData ssisize;

            (void) memset (
                (char *) &ssisize.bool_info,
                0,
                sizeof (ssisize.bool_info)
            );

            ssisize.bool_info.num_composites = 1;
            ssisize.bool_info.num_surfaces_out = dimension;
            ssisize.bool_info.num_surfaces = 0;

            omrc = om$send (
                msg = message EMSsfboolean.EMgetSSIbuffer (
                    rc,
                    &ssisize,
                    &p_ssi
                ),
                targetid = my_id
            );

            okay = EMSokay (omrc) AND EMSokay (*rc) AND p_ssi;

            if (okay)
            {
                struct EMSboolssi_table *p_ssitable;
                GRobjid *p_sf_out_id, *p_set;
                IGRint *p_sf_out_ix;

                p_ssitable = &p_ssi->bool_info;
                p_ssitable->num_composites = 1;
                p_ssitable->composite_ids[0] = my_id;
                p_ssitable->num_surfaces_out[0] = dimension;

                p_sf_out_id = &p_ssitable->surface_out_ids[dimension-1];
                p_sf_out_ix = &p_ssitable->composite_indices[dimension-1];

                p_ssitable->num_surfaces = 0;

                if (NOT lowix) /* lowix IS zero */
                {
                    *p_sf_out_ix-- = lowix++;
                    *p_sf_out_id-- = element;
                }

                p_set = set;

                while (lowix <= highix)
                {
                    *p_sf_out_ix-- = lowix++;
                    *p_sf_out_id-- = *p_set++;
                }
            }
        }
    }

    if (okay)
    {
        /*Added by DLB.*/
        if (options & EMSsfbool_opt_retryingDisjoint)
        {
          request |= DISJ_DUE_TO_RETRY;
        }

        omrc = om$send (
            msg = message EMSsfboolean.EMboolinit (
                rc,
                element,
                num_elements,
                set,
                p_ssi,
                construct_list,
                request
            ),
            targetid = my_id
        );

        okay = EMSokay (omrc) AND EMSokay (*rc);
    }

    if (okay)
    {
        GRobjid *display_ids = NULL;
        IGRint display_count = 0;

        omrc = om$send (
            msg = message EMSdpr.EMactivate (
                rc,
                &activateOptions,
                construct_list->env_info,
                &display_ids,
                &display_count
            ),
            targetid = my_id
        );

        okay = EMSokay (omrc) AND EMSokay (*rc);
    }

    if (okay)
    {
        omrc = OM_S_SUCCESS;
        *rc = EMS_S_Success;
    }
    else
    {
        *rc = EMS_E_Fail;
        omrc = OM_E_ABORT;
    }

    if (p_ssi) om$dealloc (ptr = p_ssi);

    return omrc;
}

end implementation EMSsfboolean;
