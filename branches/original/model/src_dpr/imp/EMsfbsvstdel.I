/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
/* IF_NULL_OBJID, om$dimension_of */
# include "OMmacros.h"

method EMsavestatedelete (IGRlong *EMmsg; struct GRmd_env *my_env;
                          union EMSssi_table *ssi)
/*
DESCRIPTION

This method will delete the saved assoc info that is not
currently in the topology.  ONLY information that would never get
a delete message by another path should be deleted.

RETURNED VALUES

EMS_S_Success if all is well.

HISTORY

    DLB 3/8/91  If ssi is incoming then don't reset the instance vars.
18 Apr 1989 jBk Modified to make a special case only for those
                booleans which result in an empty set.  This
                simplification is made possible and, indeed,
                required by the advent of an EMgetSSI which gets
                a consistent SSI from even the removed-operand
                booleans which have the inconsistent SSI table
                representation in their instance data.

13 Sep 1988 AIC Replaced explicit assignment of message to
                om$make_message.

18-Apr-1988 jBk To save object code and time, consolidated
                message assignment.

                Changed many absolute codings to macros.
                Added code to get rid of empty-set text object,
                if it exists, when this object is inactive.

03-Nov-1987 DLB Modified for version 1.1.0

08-Apr-1987 DLB creation.

*/
{
    union EMSssi_table      *mod_table = NULL;
    IGRlong                 OM_stat;
    IGRboolean              active;
    IGRboolean              emptySet;

    OM_stat = om$send (
        msg = message EMSsfboolean.EMget_operation_type (
            EMmsg,
            NULL,
            NULL,
            NULL,
            NULL,
            &emptySet,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
        ),
        targetid = my_id
    );

    if (NOT (EMSokay (OM_stat) AND EMSokay (*EMmsg))) goto wrapup;

    active = ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH;

    if (emptySet AND NOT active)
    {
        OM_stat = om$send (
            msg = message EMSsfboolean.EMremoveNullSymbol (
                EMmsg,
                my_env
            ),
            targetid = my_id
        );

        if (EMSokay (OM_stat) AND EMSokay (*EMmsg))
        {
            OM_stat = OM_S_SUCCESS;
            *EMmsg = EMS_S_Success;
        }
        else
        {
            OM_stat = OM_E_ABORT;
            *EMmsg = EMS_E_Fail;
        }
    }

    /* intentional block */
    {
        IGRint                  i, j;
        GRobjid                 *id;
        struct EMSboolssi_table *my_info;
        OM_S_MESSAGE                    packedmessage;
        struct GRgraphics_GRdelete_Msg  GRdeleteArglist;
        struct Root_delete_Msg          deleteArglist;

        *EMmsg = EMS_S_Success;
        OM_stat = OM_S_SUCCESS;

        if (!ssi)
        {
          /* Get the table of objects to delete from me */
          OM_stat = om$send(msg = message EMSdpr.EMgetSSI (EMmsg, &mod_table),
                            targetid = my_id);
          if (NOT (EMSokay (OM_stat) AND EMSokay (*EMmsg))) goto wrapup;
        }
        else
          mod_table = ssi;

        my_info = &mod_table->bool_info;

/*
        packedmessage = message GRvg.GRdelete (EMmsg, my_env);
*/

        GRdeleteArglist.msg = EMmsg;
        GRdeleteArglist.md_env = my_env;
        om$make_message(classname = "GRgraphics",
                        methodname = "GRdelete",
                        size = sizeof(GRdeleteArglist),
                        p_arglist = &GRdeleteArglist,
                        p_msg = &packedmessage);

        if (active)
        {
            /*delete all out surfaces*/
            id = my_info->surface_out_ids;

            for (i = 0; i < my_info->num_composites; i++)
            {
                for (j = 0; j < my_info->num_surfaces_out[i]; j++)
                {
                    OM_stat = om$send (
                        msg = &packedmessage,
                        targetid = *id
                    );

                    if (EMSerror (OM_stat)) goto wrapup;
                    id++;
                }
            }
        }

/*
        packedmessage = message Root.delete (NULL);
*/

        deleteArglist.f_defer_flag = NULL;
        om$make_message(classname = "Root",
                        methodname = "delete",
                        size = sizeof(deleteArglist),
                        p_arglist = &deleteArglist,
                        p_msg = &packedmessage);

        if (active)
        {
            /* delete all out loops */
            id = my_info->region_out_ids;
            for (i = 0; i < my_info->num_surfaces; i++)
            {
                for (j = 0; j < my_info->num_regions_out[i]; j++)
                {
                    OM_stat = om$send (
                        msg = &packedmessage,
                        targetid = *id
                    );
                    if (EMSerror (OM_stat)) goto wrapup;
                    id++;
                }
            }
        }
        else  /* not active */
        {
            /* delete all in loops */
            id = my_info->region_in_ids;
            for (i = 0; i < my_info->num_surfaces; i++)
            {
                for (j = 0; j < my_info->num_regions_in[i]; j++)
                {
                    if (NOT IF_NULL_OBJID (*id))
                    {
                        OM_stat = om$send (
                            msg = &packedmessage,
                            targetid = *id
                        );
                        if (EMSerror (OM_stat)) goto wrapup;
                    }
                    id++;
                }
            }
        } /* end else not active */

        if (!ssi) /*DLB 3/8/91*/
        {
          /* Reset the instance data */
          ME.EMSsfregmod->num_surfaces = 0;
          ME.EMSsfboolean->num_composites = 0;
        }

    } /* end intentional block */

wrapup:
    if (mod_table && !ssi) om$dealloc (ptr = mod_table);
    EMWRAPUP (*EMmsg, OM_stat, "sfb.svstdel");
    return(OM_stat);
}
end implementation EMSsfboolean;
