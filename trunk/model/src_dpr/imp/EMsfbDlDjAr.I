/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

/*
HISTORY

03 Nov 1989 SS  Added notification
05 Jan 1989 jBk Changed debug writes.
29 Nov 1988 jBk Genesis.

ALGORITHM

If desired, erase the areas represented by the P-loops in the
input list of areas to be removed.  ERASURE MUST BE PERFORMED BY
THE SENDER.

Using the input list of P-loops, create a list of the surfaces
referenced by them, along with a list of the P-loops referencing
each surface.  Leave the original list of P-loops to be
deallocated by the sender, if at all.

Iterate over the surface list, aquiring the C-loops of each
associated P-loop and merging the C-loops into the surface's
list of loops to be removed.

Iterate over the surface list, inquiring of the surface as to the
number of its active loops.  If this number is the same as the
number of nodes in its associated list of loops:  add the owner
of the surface to the list of modified composites, which is a
list of elements (modified composites) with lists (of removed
surfaces); add the surface to the owner's list of removed
surfaces; remove the surface and its list of loops from the list
of surfaces.

For each composite in the list of modified composites, add its
information to the save state information.

If it exists, deallocate the list of modified composites.

For each surface remaining in the list of surfaces:  add the
loops in its associated list to the save state information.

Deallocate the list of surfaces.

Iterate over the surfaces in the save state information, removing
them from their corresponding composites.

For each P-loop in the save state information, remove its area
(and consequently, its C-loops) from its corresponding loopset.

Send an EMSsfboolean.EMboolinit to myself.
*/

# include "EMS.h"   /* for shared libraries */

# ifndef DEBUG
#   define DEBUG 0
# endif

# if DEBUG
#   include <stdio.h>
#   include "EMScmacros.h"

extern int EFfprints ();

#   define EMSdbgMR(rc, string) EMSmsgReport ((rc), (string), TRUE)
#   define EMSdbgEPS(string)    EFfprints (NULL, string)
# else
#   define EMSdbgMR(rc, string)
#   define EMSdbgEPS(string)
# endif

# include "EMSopt.h"    /* EMS_OPT_ALL */

method EMdelDisjAreas (
    IGRlong *rc;
    struct GRvg_construct *list;
    struct EMStreeHeap *p_areas;
    OM_S_OBJID surface
)
{
    IGRboolean notify;
    EMSrc omrc;
    struct EMStreeHeap *p_surfs = NULL;
    union EMSssi_table ussi;
    struct EMStreeHeap *p_comps = NULL;

#   if DEBUG
        /* for use in debug print of surf list */
        struct EMStreeNode *p_snode;
        struct EMSelementWithList *p_ewl;
            OM_S_OBJID lploop;
            struct EMStreeNode *p_pnode;
#   endif

    EMSdbgEPS ("EMSsfboolean.EMdelDisjAreas\n");

    /* intialiazation */

    /* ussi.bool_info.num_composites does not matter */
    ussi.bool_info.composite_ids = NULL;
    ussi.bool_info.num_surfaces_out = NULL;
    ussi.bool_info.surface_out_ids = NULL;
    ussi.bool_info.composite_indices = NULL;
    /* ussi.bool_info.num_surfaces does not matter */
    ussi.bool_info.surface_ids = NULL;
    ussi.bool_info.num_regions_in = NULL;  /* will stay NULL */
    ussi.bool_info.region_in_ids = NULL;   /* will stay NULL */
    ussi.bool_info.num_regions_out = NULL;
    ussi.bool_info.region_out_ids = NULL;

    notify = EMcheck_inhibit_postproc();

#   if DEBUG
    {
        struct EMStreeNode *p_anode;
        OM_S_OBJID aploop;
        extern EMSrc EFtreeLeftmostNode ();

        *rc = EFtreeLeftmostNode (
            p_areas,
            &p_anode,
            &aploop
        );

        while (*rc IS EMS_I_Found)
        {
            extern EMSrc EFnodeNextToRight ();

            fprintf (stderr, "    ploop %d\n", aploop);

            *rc = EFnodeNextToRight (
                p_anode,
                &p_anode,
                &aploop
            );
        }
    }

    EMSdbgMR (*rc, "*rc from print loops");
    EMSdbgMR (omrc, "omrc from print loops");

#   endif /* DEBUG */

    omrc = EFsurfacesWithBoundaryLists (
        rc,
        OM_Gw_current_OS,
        p_areas,
        &p_surfs
    );

    EMSdbgMR (*rc, "*rc from EFsurfacesWithBoundaryLists");
    EMSdbgMR (omrc, "omrc from EFsurfacesWithBoundaryLists");

#   if DEBUG
    {
        extern EMSrc EFtreeLeftmostNode ();

        *rc = EFtreeLeftmostNode (
            p_surfs,
            &p_snode,
            &p_ewl
        );

        while (*rc IS EMS_I_Found)
        {
            extern EMSrc EFtreeLeftmostNode ();

            fprintf (stderr, "surf %d\n", p_ewl->content);

            *rc = EFtreeLeftmostNode (
                p_ewl->list,
                &p_pnode,
                &lploop
            );            

            while (*rc IS EMS_I_Found)
            {
                extern EMSrc EFnodeNextToRight ();

                fprintf (stderr, "    ploop %d\n", lploop);

                *rc = EFnodeNextToRight (
                    p_pnode,
                    &p_pnode,
                    &lploop
                );
            }

            if (EMSokay (*rc))
            {
                extern EMSrc EFnodeNextToRight ();

                *rc = EFnodeNextToRight (
                    p_snode,
                    &p_snode,
                    &p_ewl
                );
            }
        }
    }

    EMSdbgMR (*rc, "*rc from print surfs with lists of loops 0");
    EMSdbgMR (omrc, "omrc from print surfs with lists of loops 0");

#   endif /* DEBUG */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        extern EMSrc EFtreeLeftmostNode ();
        struct EMStreeNode *p_plnode;
        struct EMSelementWithList *p_plewl;

        *rc = EFtreeLeftmostNode (
            p_surfs,
            &p_plnode,
            &p_plewl
        );

        while (*rc IS EMS_I_Found AND EMSokay (omrc))
        {
            /* intentional block */
            {
                extern EMSrc EFploopListAddCloops ();

                omrc = EFploopListAddCloops (
                    rc,
                    OM_Gw_current_OS,
                    p_plewl->list
                );
            }

            if (*rc IS EMS_S_Success AND omrc IS OM_S_SUCCESS)
            {
                *rc = EFnodeNextToRight (
                    p_plnode,
                    &p_plnode,
                    &p_plewl
                );
            }
        }
    }

    EMSdbgMR (*rc, "*rc from EFploopListAddCloops");
    EMSdbgMR (omrc, "omrc from EFploopListAddCloops");

#   if DEBUG
    {
        extern EMSrc EFtreeLeftmostNode ();

        *rc = EFtreeLeftmostNode (
            p_surfs,
            &p_snode,
            &p_ewl
        );

        while (*rc IS EMS_I_Found)
        {
            extern EMSrc EFtreeLeftmostNode ();

            fprintf (stderr, "surf %d\n", p_ewl->content);

            *rc = EFtreeLeftmostNode (
                p_ewl->list,
                &p_pnode,
                &lploop
            );            

            while (*rc IS EMS_I_Found)
            {
                extern EMSrc EFnodeNextToRight ();

                fprintf (stderr, "    [cp]loop %d\n", lploop);

                *rc = EFnodeNextToRight (
                    p_pnode,
                    &p_pnode,
                    &lploop
                );
            }

            if (EMSokay (*rc))
            {
                extern EMSrc EFnodeNextToRight ();

                *rc = EFnodeNextToRight (
                    p_snode,
                    &p_snode,
                    &p_ewl
                );
            }
        }
    }

    EMSdbgMR (*rc, "*rc from print surfs with lists of loops 1");
    EMSdbgMR (omrc, "omrc from print surfs with lists of loops 1");

#   endif /* DEBUG */

    omrc = EFcompositeSurfacesWithSurfaceLists (
        rc,
        OM_Gw_current_OS,
        p_surfs,
        &p_comps
    );

    EMSdbgMR (*rc, "*rc from EFcompositeSurfacesWithSurfaceLists");
    EMSdbgMR (omrc, "omrc from EFcompositeSurfacesWithSurfaceLists");

#   if DEBUG
    {
        extern EMSrc EFtreeLeftmostNode ();

        *rc = EFtreeLeftmostNode (
            p_comps,
            &p_snode,
            &p_ewl
        );

        while (*rc IS EMS_I_Found)
        {
            extern EMSrc EFtreeLeftmostNode ();

            fprintf (stderr, "comp %d\n", p_ewl->content);

            *rc = EFtreeLeftmostNode (
                p_ewl->list,
                &p_pnode,
                &lploop
            );            

            while (*rc IS EMS_I_Found)
            {
                extern EMSrc EFnodeNextToRight ();

                fprintf (stderr, "    surf %d\n", lploop);

                *rc = EFnodeNextToRight (
                    p_pnode,
                    &p_pnode,
                    &lploop
                );
            }

            if (EMSokay (*rc))
            {
                extern EMSrc EFnodeNextToRight ();

                *rc = EFnodeNextToRight (
                    p_snode,
                    &p_snode,
                    &p_ewl
                );
            }
        }
    }

    EMSdbgMR (*rc, "*rc from print comps with lists of surfs");
    EMSdbgMR (omrc, "omrc from print comps with lists of surfs");

    /* intentional block */
    {
        extern EMSrc EFtreeLeftmostNode ();

        *rc = EFtreeLeftmostNode (
            p_surfs,
            &p_snode,
            &p_ewl
        );

        while (*rc IS EMS_I_Found)
        {
            extern EMSrc EFtreeLeftmostNode ();

            fprintf (stderr, "surf %d\n", p_ewl->content);

            if (p_ewl->list)
            {
                *rc = EFtreeLeftmostNode (
                    p_ewl->list,
                    &p_pnode,
                    &lploop
                );            

                while (*rc IS EMS_I_Found)
                {
                    extern EMSrc EFnodeNextToRight ();

                    fprintf (stderr, "    [cp]loop %d\n", lploop);

                    *rc = EFnodeNextToRight (
                        p_pnode,
                        &p_pnode,
                        &lploop
                    );
                }
            } /* end if (p_ewl->list) */

            if (EMSokay (*rc))
            {
                extern EMSrc EFnodeNextToRight ();

                *rc = EFnodeNextToRight (
                    p_snode,
                    &p_snode,
                    &p_ewl
                );
            }

        } /* end while (*rc IS EMS_I_Found) */
    } /* end intentional block */

    EMSdbgMR (*rc, "*rc from print surfs with lists of loops 2");
    EMSdbgMR (omrc, "omrc from print surfs with lists of loops 2");

#   endif /* DEBUG */

    if (EMSokay (*rc) AND EMSokay (omrc))
    {
        extern EMSrc EFtreesToBoolSSI ();

        *rc = EFtreesToBoolSSI (p_comps, p_surfs, &ussi.bool_info);
    }

    EMSdbgMR (*rc, "*rc from EFtreesToBoolSSI");

#   if DEBUG
    {
        OM_S_OBJID *pso, *pro;
        int ii;

        pso = ussi.bool_info.surface_out_ids;
        pro = ussi.bool_info.region_out_ids;

        for (ii = 0; ii < ussi.bool_info.num_composites; ii++)
        {
            int jj;

            fprintf (stderr, "ussi.bool_info comp %d\n",
                ussi.bool_info.composite_ids[ii]);
            
            for (jj = 0; jj < ussi.bool_info.num_surfaces_out[ii]; jj++)
            {
                fprintf (stderr, "    surf %d\n", *pso++);
            }
        }

        for (ii = 0; ii < ussi.bool_info.num_surfaces; ii++)
        {
            int jj;

            fprintf (stderr, "ussi.bool_info surf %d\n",
                ussi.bool_info.surface_ids[ii]);
            
            for (jj = 0; jj < ussi.bool_info.num_regions_out[ii]; jj++)
            {
                fprintf (stderr, "    loop %d\n", *pro++);
            }
        }
    }
#   endif

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        extern EMSrc EFtreeOfEwlEnd ();

        if (p_comps)
        {
            *rc = EFtreeOfEwlEnd (p_comps);
        }

        if (EMSokay (*rc))
        {
            *rc = EFtreeOfEwlEnd (p_surfs);
        }
    }

    EMSdbgMR (*rc, "*rc from EFtreeOfEwlEnd");

    if (EMSokay (*rc) AND EMSokay (omrc))
    {
        extern EMSrc EFssiPerformRemovals ();

        omrc = EFssiPerformRemovals (
            rc,
            OM_Gw_current_OS,
            &ussi.bool_info
        );
    }

    EMSdbgMR (*rc, "*rc from EFussi.bool_infoPerformRemovals");
    EMSdbgMR (omrc, "omrc from EFussi.bool_infoPerformRemovals");

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = om$send (
            msg = message EMSsfboolean.EMboolinit (
                rc,
                surface,
                0,
                NULL,
                &ussi,
                list,
                EMSbool_delDisjArea
            ),
            targetid = my_id
        );

        if (notify && !EMSerror (omrc & *rc))
          {
          OMuint i, num_comps;
          IGRlong local_rc;
          OM_S_CHANSELECT chan_to_comps;

          EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);  

          num_comps = 0;
          om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
           count = &num_comps);

          for (i=0; i<num_comps; i++)
            om$send (msg = message EMSsurface.EMpostgeomod (&local_rc,
            EMS_POST_SAVEDSTATE | (i == 0 ? NULL : EMS_POST_NOCOMPONENTS), 
            list->env_info, OPPmargs, NULL), from = i, to = i,
            p_chanselect = &chan_to_comps);
          }
    }

    EMSdbgMR (*rc, "*rc from EMboolinit");
    EMSdbgMR (omrc, "omrc from EMboolinit");

    /* deallocation of SSI table */

    /* ussi.bool_info.num_composites does not matter */

    if (ussi.bool_info.composite_ids)
        om$dealloc (ptr = ussi.bool_info.composite_ids);

    if (ussi.bool_info.num_surfaces_out)
        om$dealloc (ptr = ussi.bool_info.num_surfaces_out);

    if (ussi.bool_info.surface_out_ids)
        om$dealloc (ptr = ussi.bool_info.surface_out_ids);

    if (ussi.bool_info.composite_indices)
        om$dealloc (ptr = ussi.bool_info.composite_indices);

    /* ussi.bool_info.num_surfaces does not matter */

    if (ussi.bool_info.surface_ids)
        om$dealloc (ptr = ussi.bool_info.surface_ids);

    /* ussi.bool_info.num_regions_in ought still be NULL */

    /* ussi.bool_info.region_in_ids ought still be NULL */

    if (ussi.bool_info.num_regions_out)
        om$dealloc (ptr = ussi.bool_info.num_regions_out);

    if (ussi.bool_info.region_out_ids)
        om$dealloc (ptr = ussi.bool_info.region_out_ids);

    if (EMSokay (*rc) AND EMSokay (omrc))
    {
        *rc = EMS_S_Success;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        *rc = EMS_E_Fail;
        omrc = OM_E_ABORT;
    }

    if (notify)
      EMrestore_postproc();

    return omrc;
}

end implementation EMSsfboolean;
