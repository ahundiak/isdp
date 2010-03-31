class implementation EMSloop;

/*
The non-Root messages used herein are EMSloop.EMtreemod,
EMSsubbs.GRdisconn and EMSloopset.EMtoglpactive so I chose one
of those classes.
*/

/*
DESCRIPTION

As indicated by input boolean ssi table, perform removals of
surfaces from composites and loops from surfaces.  Record indices
of removed surfaces on composites immediately before removal. 
Deactivate removed surfaces.

HISTORY

14 Dec 1988 jBk Genesis.
*/

# include "EMS.h"       /* for shared libraries */

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

# include "EMSopt.h"    /* EMS_O_OFF EXTRACT */

from EMSsubbs import GRdisconn;
from EMSloopset import EMtoglpactive;

EMSrc EFssiPerformRemovals (rc, osnum, p_ssi)
    EMSrc *rc;
    OMuword osnum;
    struct EMSboolssi_table *p_ssi;
{
    EMSrc omrc = OM_S_SUCCESS;
    int ii;
    OM_S_OBJID *p_affected; /* object having something removed */
    IGRint *p_nrout;        /* number out */
    OM_S_OBJID *p_idout;    /* id out */
    OMuint *p_ixout;        /* index of removed object */
    IGRint numComposites;
    IGRint numSurfs;    

    *rc = EMS_S_Success;

    if (numComposites = p_ssi->num_composites) /* !assignment! */
    {
        OM_S_CHANSELECT toComponents, toLoopset;
        struct GRid ownerGRid;

        ownerGRid.osnum = osnum;

        p_affected = p_ssi->composite_ids;
        p_nrout = p_ssi->num_surfaces_out;
        p_idout = p_ssi->surface_out_ids;
        p_ixout = (OMuint *) p_ssi->composite_indices;

        omrc = EMmake_chanselect(GRcmpowner_to_components, &toComponents);

        EMSdbgMR (omrc, "omrc EFssiPrfrmRm.I from EMmake_chanselect A");

        if (EMSokay (omrc))
        {
            omrc = EMmake_chanselect(EMSsubbs_to_loopset, &toLoopset);
        }

        EMSdbgMR (omrc, "omrc EFssiPrfrmRm.I from EMmake_chanselect B");

        /* iteration over each of the composites */

        for (
            ii = 0;
            ii < numComposites AND EMSokay (omrc) AND EMSokay (*rc);
            ii++, p_affected++, p_nrout++
        )
        {
            int jj;

            ownerGRid.objid = *p_affected;

            /* iteration over each of the surfaces to be removed */

            for (
                jj = 0;
                jj < *p_nrout AND EMSokay (omrc) AND EMSokay (*rc);
                jj++, p_idout++, p_ixout++
            )
            {
                omrc = om$get_index (
                    osnum_c = ownerGRid.osnum,
                    objid_c = ownerGRid.objid,
                    p_chanselect = &toComponents,
                    objid = *p_idout,
                    osnum2 = osnum,
                    indexaddr = p_ixout
                );

                EMSdbgMR (omrc, "omrc EFssiPrfrmRm.I from getIx");

                if (EMSokay (omrc))
                {
                    omrc = om$send (
                        msg = message EMSsubbs.GRdisconn (
                            (IGRlong *) rc,
                            &ownerGRid
                        ),
                        senderid = NULL_OBJID,
                        targetid = *p_idout,
                        targetos = osnum
                    );

                    EMSdbgMR (*rc, "*rc EFssiPrfrmRm.I from GRisconn");
                    EMSdbgMR (omrc, "omrc EFssiPrfrmRm.I from GRisconn");
                }

                if (EMSokay (omrc) AND EMSokay (*rc))
                {
                    extern void EFsetsfstate ();

                    EFsetsfstate (rc, *p_idout, osnum, EMS_O_OFF);

                    EMSdbgMR (*rc, "*rc EFssiPrfrmRm.I from setSfState");
                }

                if (EMSokay (omrc) AND EMSokay (*rc))
                {
                    omrc = om$send (
                        msg = message EMSloopset.EMtoglpactive (
                            (IGRlong *) rc
                        ),
                        senderid = *p_idout,
                        targetos = osnum,
                        p_chanselect = &toLoopset
                    );

                    EMSdbgMR (*rc, "*rc EFssiPrfrmRm.I from toggle");
                    EMSdbgMR (omrc, "omrc EFssiPrfrmRm.I from toggle");
                }

            } /* done iteration over each of the surfaces to be removed */

        } /* done iteration over each of the composites */

    } /* end if (p_ssi->num_composites) */

    numSurfs = p_ssi->num_surfaces;

    if (numSurfs AND EMSokay (omrc) AND EMSokay (*rc))
    {
        p_nrout = p_ssi->num_regions_out;
        p_idout = p_ssi->region_out_ids;

        /* iteration over each of the surfaces */

        for (
            ii = 0;
            ii < numSurfs AND EMSokay (omrc) AND EMSokay (*rc);
            ii++, p_nrout++
        )
        {
            int jj;

            /* iteration over each of the loops to be removed */
            for (
                jj = 0;
                jj < *p_nrout AND EMSokay (omrc) AND EMSokay (*rc);
                jj++, p_idout++
            )
            {
                omrc = om$send (
                    msg = message EMSloop.EMtreemod (
                        (IGRlong *) rc,
                        NULL,
                        EXTRACT,
                        NULL
                    ),
                    senderid = NULL_OBJID,
                    targetid = *p_idout,
                    targetos = osnum
                );

                EMSdbgMR (*rc, "*rc EFssiPrfrmRm.I from treemod");
                EMSdbgMR (omrc, "omrc EFssiPrfrmRm.I from treemod");

            } /* done iteration over each of the loops to be removed */

        } /* done iteration over each of the surfaces */

    } /* end if (p_ssi->num_composites) */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
        *rc = EMS_S_Success;
    }
    else
    {
        omrc = OM_E_ABORT;
        *rc = EMS_E_Fail;
    }

    return omrc;
}

end implementation EMSloop;
