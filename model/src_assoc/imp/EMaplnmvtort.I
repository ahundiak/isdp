/*
 * METHOD:
 *
 *  NDmove_to_root
 *
 * DESCRIPTION:
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  04/28/91
 */
class implementation EMAplane;

#include "ndmacros.h"
#include "nddef.h"
#include "EMSasdef.h"
#include "REplane.h"

method NDmove_to_root ( IGRlong         * msg; 
                        struct GRid     * src_grid; 
                        struct GRmd_env * md_env )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          num_parents = 0, comp_type;
    OM_S_CHANSELECT to_parents_chansel;

    *msg = MSSUCC;

    /*
     * If this plane was constructed as plane encompassing elements
     * allow for variable number of parents.
     */
    if (me->type == EMS_ASplane_encompassing_curves)
    {
        EMmake_chanselect (NDfather_father, &to_parents_chansel);

        om$get_channel_count ( object = me, 
                               p_chanselect = &to_parents_chansel,
                               count = (OMuint *)&num_parents);

        /*
         * If this wasn't the last parent ...
         */
        if (num_parents > 1)

        {
            struct GRid my_grid;

            my_grid.objid = my_id;
            my_grid.osnum = OM_Gw_current_OS;

            comp_type = ND_COMP;
            /*
             * Recompute based on new set of parents.
             */
            nd$wait_batch ( type = GR_GEOM_POSTED,
                            l_object = &my_grid,
                            nb_obj = 1,
                            l_obj_info =  &comp_type);

            return (OM_S_SUCCESS);
        }
    }
    
    /*
     * Go stupid.
     */
/*
 * OM_e_wrt_parent is screwed. 
 * pp 06/20/91
 */
    om_msg = om$send ( msg = message EMAsubbs.NDmove_to_root ( msg,
                                                               src_grid,
                                                               md_env ),
                       mode = OM_e_wrt_message,
                       targetid = my_id );

    return(om_msg);
}

end implementation EMAplane;
