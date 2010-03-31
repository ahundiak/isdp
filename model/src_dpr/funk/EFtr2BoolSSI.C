/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION

Derive save-state-information table from trees, except for
composite indices of surfaces-out, since they are not extracted
in this function as the loops-out are not.

HISTORY

12 Dec 1988 jBk Genesis.
*/

# include "EMS.h"
# include "OMminimum.h"
# include "OMprimitives.h"
# include "EMSmsgdef.h"
# include "EMSlogic.h"
# include "EMSadt.h"
# include "EMStypedef.h"
# include "igrtypedef.h"
# include "igetypedef.h"
# include "EMSssi.h"

EMSrc EFtreesToBoolSSI (p_comps, p_surfs, p_ssi)
    struct EMStreeHeap *p_comps;
    struct EMStreeHeap *p_surfs;
    struct EMSboolssi_table *p_ssi;
{
    EMSrc rc = EMS_S_Success;

    int surfCount = 0;
    int loopCount = 0;

    rc = EMS_S_Success;

    p_ssi->num_composites = 0;
    p_ssi->num_surfaces = 0;

    p_ssi->region_in_ids = NULL;

    /* do memory for surface to composite relationship */

    if (p_comps)
    {
        extern EMSrc EFcountNodesInListOfElementsWithLists ();

        rc = EFcountNodesInListOfElementsWithLists (
            p_comps,
            &p_ssi->num_composites,
            &surfCount
        );
    }

    if (surfCount AND rc IS EMS_S_Success)
    {
        p_ssi->composite_ids = (GRobjid *) om$malloc (size =
            p_ssi->num_composites * sizeof (*p_ssi->composite_ids)
        );

        if (NOT p_ssi->composite_ids) rc = EMS_E_NoDynamicMemory;
        else
        {
            p_ssi->num_surfaces_out = (IGRint *) om$malloc (size =
                p_ssi->num_composites * sizeof (*p_ssi->num_surfaces_out)
            );

            if (NOT p_ssi->num_surfaces_out) rc = EMS_E_NoDynamicMemory;
        }

        if (rc IS EMS_S_Success)
        {
            p_ssi->surface_out_ids = (GRobjid *) om$malloc (size =
                surfCount * sizeof (*p_ssi->surface_out_ids)
            );

            if (NOT p_ssi->surface_out_ids) rc = EMS_E_NoDynamicMemory;
        }

        if (rc IS EMS_S_Success)
        {
            p_ssi->composite_indices = (IGRint *) om$malloc (size =
                surfCount * sizeof (*p_ssi->composite_indices)
            );

           if (NOT p_ssi->composite_indices) rc = EMS_E_NoDynamicMemory;
        }

        if (rc IS EMS_S_Success)
        {
            extern EMSrc EFtreeOfEwlToArrays ();

            rc = EFtreeOfEwlToArrays (
                p_comps,
                p_ssi->composite_ids,
                p_ssi->num_surfaces_out,
                p_ssi->surface_out_ids
            );
        }
    }
    else /* not (surfCount AND rc IS EMS_S_Success) */
    {
        p_ssi->composite_ids = NULL;
        p_ssi->num_surfaces_out = NULL;
        p_ssi->surface_out_ids = NULL;
        p_ssi->composite_indices = NULL;
    }
    /* done memory for surface to composite relationship */

    /* do memory for loop to surface relationship */

    if (EMSokay (rc))
    {
        extern EMSrc EFcountNodesInListOfElementsWithLists ();

        rc = EFcountNodesInListOfElementsWithLists (
            p_surfs,
            &p_ssi->num_surfaces,
            &loopCount
        );
    }

    if (loopCount AND rc IS EMS_S_Success)
    {
        p_ssi->surface_ids = (GRobjid *) om$malloc (size =
            p_ssi->num_surfaces * sizeof (*p_ssi->surface_ids)
        );

        if (NOT p_ssi->surface_ids) rc = EMS_E_NoDynamicMemory;
        else
        {
            p_ssi->num_regions_out = (IGRint *) om$malloc (size =
                p_ssi->num_surfaces * sizeof (*p_ssi->num_regions_out)
            );

            if (NOT p_ssi->num_regions_out) rc = EMS_E_NoDynamicMemory;
        }

        if (rc IS EMS_S_Success)
        {
            p_ssi->region_out_ids = (GRobjid *) om$malloc (size =
                loopCount * sizeof (*p_ssi->region_out_ids)
            );

            if (NOT p_ssi->region_out_ids) rc = EMS_E_NoDynamicMemory;
        }

        if (rc IS EMS_S_Success)
        {
            p_ssi->num_regions_in = (IGRint *) om$malloc (size =
                p_ssi->num_surfaces * sizeof (*p_ssi->num_regions_in)
            );

            if (NOT p_ssi->num_regions_in) rc = EMS_E_NoDynamicMemory;
        }

        if (rc IS EMS_S_Success)
        {
            extern EMSrc EFtreeOfEwlToArrays ();
            IGRint *p_nri;
            int ii;

            for (
                ii = 0, p_nri = p_ssi->num_regions_in;
                ii < p_ssi->num_surfaces;
                ii++
            )
            {
                *p_nri++ = 0;
            }

            rc = EFtreeOfEwlToArrays (
                p_surfs,
                p_ssi->surface_ids,
                p_ssi->num_regions_out,
                p_ssi->region_out_ids
            );
        }
    }
    else /* not (loopCount AND rc IS EMS_S_Success) */
    {
        p_ssi->surface_ids = NULL;
        p_ssi->num_regions_out = NULL;
        p_ssi->region_out_ids = NULL;
        p_ssi->num_regions_in = NULL;
    }

    /* done memory for loop to surface relationship */

    return rc;
}
