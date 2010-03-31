class implementation EMdescribe;

#include <stdio.h>
#include <string.h>
#include <grimport.h>
#include <OMindex.h>
#include <DIprims.h>
#include <grerr.h>
#include <msmacros.h>
#include <grmessage.h>
#include <alloca.h>
#include <OMmacros.h>
#include <exmacros.h>
#include <OMminimum.h>
#include <OMlimits.h>
#include <OMOSfilehdr.h>
#include <igrtypedef.h>
#include <igrdef.h>
#include <igr.h>
#include <igrdp.h>
#include <grownerdef.h>
#include <gocmacros.h>
#include <godef.h>
#include <go.h>
#include <griodef.h>
#include <grio.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <limits.h>
#include <dpdef.h>
#include <dp.h>
#include <dpmacros.h>
#include <refdef.h>
#include <ref.h>
#include <csdef.h>
#include <grcoordsys.h>
#include <grgsdef.h>
#include <grgs.h>
#include <grgsmacros.h>
#include <grpgendef.h>
#include <lcdef.h>
#include <lc.h>
#include <lcmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

from GRgrset import GSstart_transition;
from GRgrset import GSend_transition;
from module  import GRmod_passon;

extern OMuword OPP_GRvg_class_id;

#define OIDS_SIZE  300

struct EMlayer_pass_info
{
    IGRint            size, count;
    OM_S_OBJID      * oids;
    struct GRmd_env * mod_env;
    IGRint         (* func_ptr)();
    IGRchar         * func_args;
};
    
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMconvert_layer_mask_to_string                                  |
 |                                                                           |
 | This function converts a layer bin mask into a string which represents    |
 | those layers.                                                             |
 |                                                                           |
 | Input:   IGRlong         * layers        Layer buffer, 32 IGRlongs.       |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |          IGRchar         * layers_string String describing layers.        |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMconvert_layer_mask_to_string (IGRlong         * msg,
                                        struct GRmd_env * mod_env,
                                        IGRlong         * layers,
                                        IGRchar         * layers_string)
{
    IGRlong    om_msg = OM_S_SUCCESS;
    IGRint     i, j;
    IGRchar  * cp;
    IGRlong    block, mask = 0x00000001;
    IGRint     low_layer, high_layer, layer;
    IGRboolean in_range = FALSE;
    
    *msg = ASM_S_SUCCESS;
    
    /* Done to quite compiler. */
    mod_env = NULL;

    high_layer = low_layer = 0;
    
    *(cp = layers_string) = '\0';

    for (i = 0; i < 32; ++i)
    {
        block = layers[i];

        for (j = 0; j < 32; ++j)
        {
            layer = (i*32) + j;
            
            if (block & (mask << j))
            {
                if (in_range)
                {
                    if (layer == (high_layer + 1))
                    {
                        high_layer = layer;
                    }
                    else
                    {
                        if (high_layer != low_layer)
                        {
                            sprintf (cp, "%d", high_layer);
                            cp += strlen(cp);
                        }
                        else
                        {
                            --cp;
                        }
                        
                        sprintf (cp, ",%d-", layer);
                        low_layer = high_layer = layer;
                    }
                }
                else
                {
                    sprintf (cp, "%d-", layer);
                    low_layer = high_layer = layer;
                    in_range = TRUE;
                }
                cp += strlen (cp);
            }
            else
            {
                if (in_range)
                {
                    if (high_layer != low_layer)
                    {
                        sprintf (cp, "%d", high_layer);
                        cp += strlen(cp);
                    }
                    else
                    {
                        *(--cp) = '\0';
                    }
                        
                    sprintf (cp, ",");
                    cp += strlen(cp);
                    in_range = FALSE;
                }
            }
        }
    }

    if (in_range && (high_layer != low_layer))
    {
        sprintf (cp, "%d", high_layer);
    }
    else
    {
        if (cp != layers_string)
        {
            *(--cp) = '\0';
        }
        else
        {
            *cp = '\0';
        }
    }

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMconvert_string_to_integer                                     |
 |                                                                           |
 | This function converts a string to an integer.                            |
 |                                                                           |
 | Input:   IGRchar         * string        String                           |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |                                                                           |
 | Error:   ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | Return:  IGRint          Integer value.                                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRint EMconvert_string_to_integer (IGRlong * msg,
                                    IGRchar * string)
{
    IGRchar * bcp, * ecp;

    *msg = ASM_S_SUCCESS;
    
    bcp = string;
    
    while (isspace((int)*bcp) && (*bcp != '\0'))
    {
        bcp++;
    }
    
    if (*bcp == '\0')
    {
        *msg = ASM_E_ABORT;
        return INT_MAX;
    }
    
    ecp = bcp;
    
    while (isdigit((int)*ecp) && (*ecp != '\0'))
    {
        ecp++;
    }
    
    if (!isspace((int)*ecp) && (*ecp != '\0'))
    {
        *msg = ASM_E_ABORT;
        return INT_MAX;
    }
    
    *ecp = '\0';
    
    return atoi(bcp);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMconvert_layer_string_to_mask                                  |
 |                                                                           |
 | This function converts a layer string into a bit mask which represents    |
 | those layers.                                                             |
 |                                                                           |
 | Input:   IGRchar         * layers_string String describing layers.        |
 |                                                                           |
 | Output:  IGRlong         * msg           Return code.                     |
 |          IGRlong         * layers        Layer buffer, 32 IGRlongs.       |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMconvert_layer_string_to_mask (IGRlong         * msg,
                                        IGRchar         * layers_string,
                                        IGRlong         * layers)
{
    IGRlong    om_msg = OM_S_SUCCESS;
    IGRint     i;
    IGRchar  * token, * buffer, * cp;
    IGRint     low_layer, high_layer;
    
    buffer = (char *)alloca(strlen(layers_string) + 1);
    strcpy (buffer, layers_string);
    
    for (i=0; i<32; ++i)
    {
        layers[i] =  0;
    }
    
    token = strtok (buffer, ",");
    
    while (token)
    {
        low_layer = high_layer = -1;

        if (cp = strchr(token, '-'))
        {
            *cp = '\0';

            low_layer  = EMconvert_string_to_integer(msg, token);
            high_layer = EMconvert_string_to_integer(msg, ++cp);
            
            if ((low_layer >= 0) && (high_layer < 1024) && 
                (low_layer < high_layer))
            {
                for (i=low_layer; i<=high_layer; ++i)
                {
                    layers[i/32] |= 0x00000001 << (i%32);
                }
            }
        }
        else
        {
            low_layer = EMconvert_string_to_integer (msg, token);

            if ((low_layer >=0) && (low_layer < 1024))
            {
                layers[low_layer/32] |= 0x00000001 << (low_layer%32);
            }
        }

        token = strtok(NULL, ",");
    }

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMis_layer_subset                                               |
 |                                                                           |
 | This function determine whether the input subset is a proper subset of    |
 | layer specified.                                                          |
 |                                                                           |
 | Input:   IGRlong * layers        Layers.                                  |
 |          IGRlong * layer_subset  Subset.                                  |
 |                                                                           |
 | Return:  TRUE or FALSE                                                    |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRboolean EMis_layer_subset (IGRlong * layers, IGRlong * layer_subset)
{
    IGRint i;
    
    for (i=0; i<32; ++i)
    {
        if ((~layers[i]) & layer_subset[i])
        {
            return FALSE;
        }
    }

    return TRUE;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_first_layer                                               |
 |                                                                           |
 | This function returns the first layer in a layer mask.                    |
 |                                                                           |
 | Input:   IGRlong * layers        Layers.                                  |
 |                                                                           |
 | Return:  First layer.                                                     |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_first_layer (IGRlong * layers)
{
    IGRint i, j;
    
    for (i=0; i<32; ++i)
    {
        if (layers[i])
        {
            for (j=0; j<32; ++j)
            {
                if (layers[i] & (0x00000001 << j))
                {
                    return (i*32) + j;
                }
            }
        }
    }

    return -1;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_last_layer                                                |
 |                                                                           |
 | This function returns the last layer in a layer mask.                     |
 |                                                                           |
 | Input:   IGRlong * layers        Layers.                                  |
 |                                                                           |
 | Return:  Last layer.                                                      |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_last_layer (IGRlong * layers)
{
    IGRint i, j;
    
    for (i=31; i>=0; --i)
    {
        if (layers[i])
        {
            for (j=31; j>=0; --j)
            {
                if (layers[i] & (0x00000001 << j))
                {
                    return (i*32) + j;
                }
            }
        }
    }

    return -1;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMlayer_in_layers                                               |
 |                                                                           |
 | This function TRUE if layer is in the layer set.                          |
 |                                                                           |
 | Input:   IGRshort  layer    Layer.                                        |
 |          IGRlong * layers   Layers.                                       |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRboolean EMlayer_in_layers (IGRshort layer, IGRlong * layers)
{
    return (layers[layer/32] & (0x00000001 << (layer%32))) ? TRUE : FALSE;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMlayer_pass_func                                               |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | Jay Wallingford  8/22/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRint EMlayer_pass_func (IGRchar               * args,
                          struct GRlc_info      * new_entry,
                          struct LC_action_args * locate_args,
                          enum GRlocate_action  * action)
{
    IGRlong                    msg;
    IGRint                     i;
    struct EMlayer_pass_info * info;
    struct GRid              * id;

    locate_args = NULL; /* Done to quiet compiler. */

    switch (*action)
    {
    case add_all:
    case add_inside:
    case add_outside:
    case add_overlap:
    case check_object:
        id = &new_entry->located_obj;
        info = (struct EMlayer_pass_info *)args;

        for (i=info->count-1; i>=0; --i)
        {
            if (info->oids[i] == id->objid)
            {
                break;
            }
        }
        
        if (i == -1)
        {
            if (++info->count == info->size)
            {
                info->size += OIDS_SIZE;
                info->oids = (OM_S_OBJID *)om$realloc (ptr = (IGRchar *)info->oids,
                                                       size = info->size * sizeof (OM_S_OBJID));
            }

            info->oids[info->count - 1] = id->objid;

            (*(info->func_ptr))(&msg, 
                                info->mod_env,
                                id,
                                info->func_args); 
        }
        break;
        
    case start_transition:
    case end_transition:
    case post_object:
    case add_nopost:
    default:
        break;
    }
    
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMlayer_pass                                                    |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | Jay Wallingford  9/8/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMlayer_pass (IGRlong               * msg, 
                      struct GRmd_env       * mod_env,
                      IGRlong               * layers,
                      struct GRlc_locate    * attributes,
                      struct GRlc_classes   * classinfo,
                      IGRint               (* func_ptr)(),
                      IGRchar               * func_args)
{
    IGRlong             om_msg = OM_S_SUCCESS, ok;
    struct GRmd_env     loc_mod_env;
    struct GRlc_locate  loc_attributes;
    struct GRlc_classes loc_classinfo;
    OMuword             *rtree_classids, *eligible_classids;
    OM_S_CLASSLIST      rtree_classes, eligible_classes;
    struct EX_button    button;
    struct GRlc_cvl     cvl;
    IGRint              i, begin = 0, fin = 0, size;
    IGRlong             loc_layers[32];
    DB_3D_DBL_BOX       dbl_range;
    OM_S_KEY_DESC       rtree_key;
    DB_3D_DBL_BOX       object_range;
    OM_S_KEY_DESC       key;
    OM_S_MESSAGE        pass_message;
    OM_S_MESSAGE        loc_message;
    struct EMlayer_pass_info layer_pass_info; 
    struct lockludge
    {
        struct GRlc_cvl * cvl;
        OM_p_KEY_DESC     range_key;
    } loc_kludge;

    struct passkludge
    {
        OM_p_MESSAGE    msg;
        OM_p_KEY_DESC   p_select_key;
        char          * p_criteria;
        OM_p_KEY_DESC   p_target_key;
        int             (*user_compare)();
        int           * ret;          
    } pass_kludge;

    *msg = ASM_S_SUCCESS;
    
    /*
     * If the module wasn't specified get the master file's.
     */
    if (!mod_env)
    {
        gr$get_module_env (buffer = (mod_env = &loc_mod_env));
    }
    
    /*
     * If the layers weren't specified use all layers.
     */
    if (!layers)
    {
        layers = loc_layers;
        for (i=0; i<32; ++i)
        {
            layers[0] = 0xffffffff;
        }
    }

    /*
     * If the locate attributes weren't specified use a default.
     */
    if (!attributes)
    {
        attributes = &loc_attributes;

        attributes->properties = IGN_LC_BIT | LC_RW | IGN_DP_BIT | 
                                 LC_NEW_MOD | IGN_PLANAR_BIT     | 
                                 IGN_PHY_OPEN_CLOSED;

        attributes->owner_action = LC_FLEX_OWNER  | LC_RIGID_OWNER | 
                                   LC_EXTERN_CONSTRAINED |
                                   LC_REF_HEADER  | LC_NO_REF_OBJECTS | 
                                   LC_ASSOCIATIVE | LC_HANDLES;
    }
    
    /*
     * If the locate attributes weren't specified use a default.
     */
    if (!classinfo)
    {
        classinfo = &loc_classinfo;

        rtree_classids = (OMuword *) alloca( sizeof( OMuword ) );
        rtree_classids[0] = OPP_GRgraphics_class_id;
        rtree_classes.w_count = 1;
        rtree_classes.w_flags = OM_CLST_subclass;

        rtree_classes.p_classes = rtree_classids;
        
        eligible_classids = (OMuword *) alloca( sizeof( OMuword ) );
        eligible_classids[0] = OPP_GRgraphics_class_id;
        eligible_classes.w_count = 1;
        eligible_classes.w_flags = OM_CLST_subclass;

        eligible_classes.p_classes = eligible_classids;
        
        classinfo->rtree_classes = &rtree_classes;
        classinfo->eligible_classes = &eligible_classes;
    }

    /*
     * Put together a dummy button.
     */
    button.objid = NULL_OBJID;
    button.osnum = mod_env->md_id.osnum;
    
    /*
     *  Since the rtree will automatically make any conversions 
     *  necessary make the required input to 3D_DBL.
     */
    rtree_key.type = KEY_3D_DBL;
    rtree_key.key.p_3ddbl = &dbl_range;
    key.type = KEY_3D_DBL;
    key.key.p_3ddbl = &object_range;

    layer_pass_info.mod_env = mod_env;
    layer_pass_info.size = OIDS_SIZE;
    layer_pass_info.count = 0;
    layer_pass_info.oids = (OM_S_OBJID *)om$malloc(size = OIDS_SIZE * sizeof(OM_S_OBJID));
    layer_pass_info.func_ptr = func_ptr;
    layer_pass_info.func_args = func_args;
    
    cvl.msg = MSSUCC;
    cvl.module = *mod_env;  
    cvl.attributes.type = GR_crit_loc;
    cvl.attributes.obj_attr = *attributes;
    cvl.attributes.acc_tolerance = 0;
    cvl.action_handler = EMlayer_pass_func;
    cvl.act_parms = (IGRchar *)&layer_pass_info;
    cvl.button = button;
    cvl.levels = (IGRint *)layers;
    cvl.classes = classinfo->eligible_classes;
    cvl.locate_args = NULL;
    cvl.prism_attr = NULL;
    cvl.r_classes = classinfo->rtree_classes;
    cvl.data = NULL; /* ????? */
    
    /* 
     *  Form the range tree box.
     */
    rtree_key.key.p_3ddbl->xmin = GRDGNLIMITS_MIN_D;
    rtree_key.key.p_3ddbl->ymin = GRDGNLIMITS_MIN_D;
    rtree_key.key.p_3ddbl->zmin = GRDGNLIMITS_MIN_D;
    rtree_key.key.p_3ddbl->xmax = GRDGNLIMITS_MAX_D;
    rtree_key.key.p_3ddbl->ymax = GRDGNLIMITS_MAX_D;
    rtree_key.key.p_3ddbl->zmax = GRDGNLIMITS_MAX_D;

    /*
     *  Build the locate message
     */
    loc_kludge.cvl = &cvl;
    loc_kludge.range_key = &key;
    size = sizeof (struct lockludge);
    om_msg = om$make_message (classname = "GRgraphics",
                              methodname = "GRlocate",
                              size = size,
                              p_arglist = &loc_kludge,
                              p_msg = &loc_message);
    
    /*
     *  Build the pass message
     */
    pass_kludge.msg = &loc_message;
    pass_kludge.p_select_key = &rtree_key;
    pass_kludge.p_criteria = NULL;
    pass_kludge.p_target_key = &key;
    pass_kludge.user_compare = NULL;
    pass_kludge.ret = (IGRint *)&ok;

    size = sizeof (struct passkludge);

    om_msg = om$make_message (classname = "GRrtree",
                              methodname = "pass",
                              size = size,
                              p_arglist = &pass_kludge,
                              p_msg = &pass_message);

    /*
     *  Now send these 2 embedded messages to module
     */
    om_msg = om$send (msg = message module.GRmod_passon (msg, 
                                                         &pass_message, 
                                                         "module.primary", 
                                                         &begin, 
                                                         &fin),
                      senderid = NULL_OBJID, 
                      targetid = mod_env->md_id.objid,
                      targetos = mod_env->md_id.osnum);


    /*
     * Deallocate the pass buffer.
     */
    om$dealloc (ptr = layer_pass_info.oids);
    
    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_layer_subset                                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | Jay Wallingford  9/15/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_layer_subset (IGRlong * msg,
                            IGRlong * layers,
                            IGRint    num_layers,
                            IGRlong * layer_subset)
{
    IGRlong shift_bit = 0x00000001;
    IGRint  num_found = 0, i, j, start_i, start_j;

    *msg = ASM_S_SUCCESS;

    /*
     * For all the incoming layers ...
     */
    for (i=0; i<32; ++i)
    {
        /*  
         * For all the bits in this layer entry ...
         */
        for (j=0; j<32; ++j)
        {
            /*
             * If the bit is in the incoming layers ...
             */
            if (layers[i] & (shift_bit << j))
            {
                /*  
                 * If this is the first available layer found record
                 * the start entry and bit.
                 */
                if (++num_found == 1)
                {
                    start_i = i;
                    start_j = j;
                }
                   
                /*
                 * If all requested layers have been found.
                 */
                if (num_found == num_layers)
                {   
                    IGRchar buffer[40];
                    
                    sprintf (buffer, "%d-%d", 
                             (start_i * 32) + start_j,
                             (i * 32) + j);

                    EMconvert_layer_string_to_mask (msg, buffer, layer_subset);

                    return OM_S_SUCCESS;
                }
            }
            else /* Start over again. */
            {
                num_found = 0;
            }
        }
    }

    *msg = ASM_E_ABORT;
    
    return OM_E_ABORT;
}

end implementation EMdescribe;




