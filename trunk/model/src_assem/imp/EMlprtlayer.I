class implementation EMlocalpart;

#include <grimport.h>
#include <DIprims.h>
#include <OMmacros.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <grownerdef.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"
#include "assemmacros.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_layers                                                      |
 |                                                                           |
 | This method returns the layers that are assigned to this part. The        |
 | returned buffer is a 128 byte bit mask representing all 1024 layers.      |
 |                                                                           |
 | This method returns the layers that are assigned to this part as well as  |
 | the layers that will be turned on when this part is active and the layers |
 | that are turned on when this part is deactivated. The returned buffers    |
 | are 128 byte bit masks representing all 1024 layers.                      |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |          IGRlong         * layers        Layer buffer, 32 IGRlongs.       |
 |          IGRlong         * active_on     Layer buffer, 32 IGRlongs.       |
 |          IGRlong         * nonactive_on  Layer buffer, 32 IGRlongs.       |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_layers (IGRlong * msg;
                     IGRlong * layers;
                     IGRlong * active_on;
                     IGRlong * nonactive_on)
{
    *msg = ASM_S_SUCCESS;
    
    if (layers)
    {
        memcpy (layers, me->layers, 32 * sizeof(IGRlong));
    }
    
    if (active_on)
    {
        memcpy (active_on, me->active_on, 32 * sizeof(IGRlong));
    }
    
    if (nonactive_on)
    {
        memcpy (nonactive_on, me->nonactive_on, 32 * sizeof(IGRlong));
    }

    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_layers                                                      |
 |                                                                           |
 | This method sets the layers that a part has assigned to it.               |
 |                                                                           |
 | This method sets the layers that are assigned to this part as well as     |
 | setting the layers that will be turned on when this part is active and the|
 | layers that are turned on when this part is deactivated. The returned     |
 | buffers are 128 byte bit masks representing all 1024 layers.              |
 |                                                                           |
 | Input:   IGRlong         * msg           Return code.                     |
 |          IGRlong         * layers        Layers.                          |
 |          IGRlong         * active_on     Layer buffer, 32 IGRlongs.       |
 |          IGRlong         * nonactive_on  Layer buffer, 32 IGRlongs.       |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_layers (IGRlong * msg;
                     IGRlong * layers;
                     IGRlong * active_on;
                     IGRlong * nonactive_on)
{
    IGRlong         om_msg = OM_S_SUCCESS, ok;
    struct GRid     file_part_id;
    struct GRmd_env mod_env;
    IGRint          size = 32 * sizeof(IGRlong);
    IGRlong         loc_active_on[32];
    IGRlong         loc_nonactive_on[32];
    IGRshort        active_layer;
    
    *msg = ASM_S_SUCCESS;
 
    /*
     * You can't set the layers for a file part since a file
     * part's layers are dictated by the layers that aren't used
     * by it's local parts.
     */
    if (EM_IS_FILE_PART(me->props) && (layers))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * If setting the available layers ...
     */
    if (layers)
    {
        om_msg = gr$get_module_env (buffer = &mod_env);
    
        if (!(om_msg & 1))
        {
            *msg = ASM_E_ABORT;
        }
        
        mod_env.md_id.osnum = OM_Gw_current_OS;
        
        om_msg = asm$get_file_part (msg = msg, 
                                    mod_env = &mod_env,
                                    part_id = &file_part_id);
    
        if (!(om_msg & 1))
        {
            *msg = ASM_E_ABORT;
        }

        /*
         * If I've been initialized have the file part first reuse
         * my layer set. This will give back my existing layers
         * to the file part temporarily.
         */
        if (me->active_layer != -1)
        {
            om_msg = om$send (msg = message EMlocalpart.EMreuse_layers
                                              (msg,
                                               me->layers,
                                               me->active_on,
                                               me->nonactive_on),
                              targetid = file_part_id.objid,
                              targetos = file_part_id.osnum);
        
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
        }

        /*
         * Now check the layer subset out from the file part.
         */
        om_msg = om$send (msg = message EMlocalpart.EMuse_layers 
                                               (msg,
                                                layers,
                                                loc_active_on,
                                                loc_nonactive_on),
                          targetid = file_part_id.objid,
                          targetos = file_part_id.osnum);
        
        if (!(om_msg & *msg & 1))
        {
            /*
             * Set the layers back to what they were.
             */
            om$send (msg = message EMlocalpart.EMuse_layers
                                               (&ok,
                                                me->layers,
                                                me->active_on,
                                                me->nonactive_on),
                     targetid = file_part_id.objid,
                     targetos = file_part_id.osnum);

            goto quit;
        }
        
        memcpy (me->layers, layers, size);
        memcpy (me->active_on, loc_active_on, size);
        memcpy (me->nonactive_on, loc_nonactive_on, size);
    }
    
    if (active_on)
    {
        if (EMis_layer_subset (me->layers, active_on))
        {
            memcpy (me->active_on, active_on, size);
        }
        else
        {
            *msg = ASM_E_INVARGS;
            goto quit;
        }
    }
    
    if (nonactive_on)
    {
        if (EMis_layer_subset (me->layers, nonactive_on))
        {
            memcpy (me->nonactive_on, nonactive_on, size);
        }
        else
        {
            *msg = ASM_E_INVARGS;
            goto quit;
        }
    }

    /*
     * Get the active part.
     */
    gr$get_active_level (buffer = &active_layer);
    
    /*
     * Now determine is one of the new layers is the active 
     * layer in which case we want to make this the active
     * part.
     */
    if (EMlayer_in_layers (active_layer, me->layers))
    {
        struct GRid my_grid;
        
        my_grid.objid = my_id;
        my_grid.osnum = OM_Gw_current_OS;

        me->active_layer = active_layer;
        
        asm$set_active_part (msg = msg,
                             part_id = &my_grid);
    }
    /* 
     * Make sure my active layer still falls in the layers. 
     */
    else if (EMlayer_in_layers (me->active_layer, me->layers))
    {
        me->active_layer = EMget_first_layer(me->layers);
    }
    
    if (me->active_layer == -1)
    {
        me->active_layer = EMget_first_layer(me->layers);
    }
    
 quit:

    if (om_msg & *msg & 1)
    {
        EMbom_update (BOM_MOD_LAYERS, my_id, OM_Gw_current_OS, NULL);
    }
    
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_active_layer                                                |
 |                                                                           |
 | This method returns the active layer for this part.                       |
 |                                                                           |
 | Output:  IGRlong         * msg          Return code.                      |
 |          IGRint          * active_layer Active layer.                     |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_active_layer (IGRlong * msg;
                           IGRint  * active_layer)
{
    *msg = ASM_S_SUCCESS;
    *active_layer = me->active_layer;
    return OM_S_SUCCESS;
}    

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_active_layer                                                |
 |                                                                           |
 | This method sets the active layer for this part.                          |
 |                                                                           |
 | Output:  IGRlong         * msg        Return code.                        |
 |          IGRint            layer      Active layer.                       |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_active_layer (IGRlong * msg;
                           IGRshort  active_layer)
{
    *msg = ASM_S_SUCCESS;

    if (!EMlayer_in_layers(me->layers, active_layer))
    {
        *msg = ASM_E_INVARGS;
    }
    else
    {
        me->active_layer = active_layer;
    }
    
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Message: EMuse_layers                                             |
 |                                                                           |
 | This method is sent by a local part to the file part when it is created or|
 | when it's layer assignment is changed using the EMset_layers message. The |
 | file part will make sure that the specified layers are a valid subset of  |
 | the file part and will take them out of it's list of available layers and |
 | displayed layers.                                                         |
 |                                                                           |
 | Input:   IGRlong * layers         Layer array, 32 IGRlong.                |
 |                                                                           |
 | Output:  IGRlong * msg            Return code.                            |
 |          IGRlong * active_on      Active on layers for set.               |
 |          IGRlong * nonactive_on   Nonactive on layers for set.            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Constructed sucessfully.                     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMuse_layers (IGRlong * msg;
                     IGRlong * layers;
                     IGRlong * active_on;
                     IGRlong * nonactive_on)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  i;
    
    *msg = ASM_S_SUCCESS;
 
    if (EM_IS_LOCAL_PART(me->props))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    if (!EMis_layer_subset(me->layers, layers))
    {
        *msg = ASM_E_INVARGS;
        goto quit;
    }

    /*
     * Set the layers and active/nonactive on layers and remove
     * them from this object's lists.
     */
    for (i=0; i<32; ++i)
    {
        active_on[i]    = me->active_on[i] & layers[i];
        nonactive_on[i] = me->nonactive_on[i] & layers[i];

        me->layers[i]       &= ~layers[i];
        me->active_on[i]    &= ~layers[i];
        me->nonactive_on[i] &= ~layers[i];
    }

    /*
     * If my active layer was one of the layers I just gave up,
     * reset my active layer to my fist layer.
     */
    if (EMlayer_in_layers((IGRshort)me->active_layer, layers))
    {
        me->active_layer = EMget_first_layer (me->layers);
    }
    
 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Message: EMreuse_layers                                           |
 |                                                                           |
 | This method is sent by a local part to the file part when it is deleted   |
 | or when it's layer assignment is changed using the EMset_layers message.  |
 | The file part will add these assigned and displayed layers to it's list   |
 | of available layers.                                                      |
 |                                                                           |
 | Input:   IGRlong * layers       Layer array, 32 IGRlong.                  |
 |          IGRlong * active_on    Active on layers.                         |
 |          IGRlong * nonactive_on NonActive on layers.                      |
 |                                                                           |
 | Output:  IGRlong * msg          Return code.                              |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMreuse_layers (IGRlong * msg;
                       IGRlong * layers;
                       IGRlong * active_on;
                       IGRlong * nonactive_on)
{
    IGRlong  om_msg = OM_S_SUCCESS;
    IGRint   i;
    IGRshort active_layer;
    
    *msg = ASM_S_SUCCESS;
 
    if (EM_IS_LOCAL_PART(me->props))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Make sure this is a valid set of layers to return.
     */
    if (!EMis_layer_subset(layers, active_on) ||
        !EMis_layer_subset(layers, nonactive_on))
    {
        *msg = ASM_E_INVARGS;
        goto quit;
    }
    
    /*
     * Absorb the layers.
     */
    for (i=0; i<32; ++i)
    {
        me->layers[i]       |= layers[i];
        me->active_on[i]    |= active_on[i];
        me->nonactive_on[i] |= nonactive_on[i];
    }

    /*
     * If the active layer is now on one of my layers, make
     * me active.
     */
    gr$get_active_layer (buffer = &active_layer);
    
    if (EMlayer_in_layers(active_layer, me->layers))
    {
        om_msg = om$send (msg = message EMlocalpart.EMset_active (msg, TRUE),
                          targetid = my_id);
    }
    
 quit:
    
    return om_msg;
}

end implementation EMlocalpart;




