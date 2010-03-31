/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"

/*
    SOM_DIMENSION_OF; necessary for getting information when ssi
    table is not consistently represented in the instance data;
    inclusion may be removed when all ssi tables of disjoint
    booleans with wholly removed operands are represented
    consistently with the general boolean ssi table form
*/
# include "OMmacros.h"

method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)
/*
Description
  This method fills the EMSboolssi_size structure so that EMgetSSibuffer
  may be called to malloc the exact size of the buffer.

Return values
  size - pointer to the structure
  EMmsg - EMS_S_Success for success in evaluating the size of a
            consistent SSI table
          EMS_I_Success for success in evaluating the size of an
            inconsistent SSI table for a boolean with wholly
            removed operands.
          EMS_E_InvalidArg if this boolean's type is unknown
          EMS_E_Fail if analyzing the type fails entirely

Notes
  This method assumes that the referenced instance data has valid values.

  This method ought to be returned to always returning
  EMS_S_Success and not sending itself the EMget_operation_type
  message when disjoint booleans are consistently represented. -- jBk

History

13 Apr 1989 jBk Modified to return valid sizes for the currently
                inconsistently represented disjoint boolean
                results.  Consistency checks can be removed when
                disjoint boolean operations always construct a
                consistent SSI table.

  DLB 11/02/87  Modified structure name for version 1.1.0

  AIC xx/xx/87  Creation
*/

{
    int omrc;
    IGRboolean removed;

    omrc = om$send (
        msg = message EMSsfboolean.EMget_operation_type (
            EMmsg       /* IGRlong *EMmsg; */,
            NULL        /* enum EMSbooltype *request; */,
            NULL        /* enum EMSbooltype *exactOperation; */,
            NULL        /* enum EMSbooltype *generalOperation; */,
            NULL        /* IGRboolean *reverseOrientation; */,
            NULL        /* IGRboolean *emptySet; */,
            NULL        /* IGRboolean *disjointSurfaces; */,
            NULL        /* IGRboolean *firstOnly; */,
            NULL        /* IGRboolean *allButFirst; */,
            NULL        /* IGRboolean *lastOnly; */,
            &removed    /* IGRboolean *removedSolids; */,
            NULL        /* IGRlong *msgNumber */
        ),
        targetid = my_id
    );

    if (EMSokay (omrc) AND EMSokay (*EMmsg))
    {
        /* examined type okay */

        struct EMSboolssi_size  *my_size;

        omrc = OM_S_SUCCESS;

        my_size = &size->bool_info;

        if (removed AND NOT me^^EMSsfboolean.num_composites)
        {
            /*
                inconsistent SSI is indicated by having wholly
                removed operands and no composites modified
            */

            *EMmsg = EMS_I_Success;

            my_size->num_composites = 1;
            my_size->num_surfaces_out = om$dimension_of (
                varray = me^^EMSdpr.ids
            );

            my_size->num_surfaces = 0;

            /*
                With num_surfaces' being zero, it ought not be
                necessary to initialize the following two fields,
                but I do just in case someone uses them anyway.
                -- jBk
            */

            my_size->num_regions_in = 0;
            my_size->num_regions_out = 0;
        }
        else /* consistent SSI */
        {
            IGRint                  i, j;

            *EMmsg = EMS_S_Success;

            /*Have num composites modified in instance data.*/
            my_size->num_composites = ME.EMSsfboolean->num_composites;

            /*Get num surfs out per composite from vla.*/
            my_size->num_surfaces_out = 0;
            for(i = 0; i < my_size->num_composites; i ++)
            {
                my_size->num_surfaces_out += ME.EMSsfregmod->in_out[i];
            }

            /*Have num surfaces modified in instance data.*/
            my_size->num_surfaces = ME.EMSsfregmod->num_surfaces;

            /*Get num regions added and removed per surface.*/
            my_size->num_regions_in = 0;
            my_size->num_regions_out = 0;
            for(j = 0; j < my_size->num_surfaces; j ++, i ++)
            {
                my_size->num_regions_in += ME.EMSsfregmod->in_out[i];
            }

            for(j = 0; j < my_size->num_surfaces; j ++, i ++)
            {
                my_size->num_regions_out += ME.EMSsfregmod->in_out[i];
            }

            /* end else consistent SSI */
        }

        /* fi examined type okay */
    }
    else if (NOT (omrc IS OM_E_ABORT AND *EMmsg IS EMS_E_InvalidArg))
    {
        *EMmsg = EMS_E_Fail;
        omrc = OM_E_ABORT;
    }

    return omrc;
}

end implementation EMSsfboolean;
