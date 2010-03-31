class implementation EMlocalpart;

#include <grimport.h>
#include <DIprims.h>
#include <OMmacros.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <stdlib.h>
#include <alloca.h>
#include <godef.h>
#include <go.h>
#include <dpdef.h>
#include <dp.h>
#include <dpmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"

from GRnotify import GRntfyconn, GRntfydisconn;
from GRvg     import GRchgprops;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_display                                                     |
 |                                                                           |
 | This message will return the default types of elements and element layers |
 | that are being stored for this object, if any at all. If the information  |
 | is not stored a full element mask and layers mask will be returned. The   |
 | EMdescribe object will store the last set element display mask but will   |
 | not store the layers. The element display mask will indicate the          |
 | following:                                                                |
 |                                                                           |
 |  EM_GRAPHIC_DISPLAYED    - Should graphics be displayed?                  |
 |  EM_SOLIDSURF_DISPLAYED  - Should solids and surfaces be displayed?       |
 |  EM_WIREFRAME_DISPLAYED  - Should wireframe geometry be displayed?        |
 |  EM_TEXT_DISPLAYED       - Should text be displayed?                      |
 |  EM_DIMENSION_DISPLAYED  - Should dimensions be displayed?                |
 |  EM_REFPLANE_DISPLAYED   - Should reference planes be displayed?          |
 |  EM_CONSTRAINT_DISPLAYED - Should constraints be displayed?               |
 |                                                                           |
 | These defines are found in the assemdef.h include file.                   |
 |                                                                           |
 | The layers mask indicate which layers were used to turn the display on/off|
 | for graphics. This mask an array of 32 IGRlongs whose bits represent all  |
 | layers from 1 to 1023.                                                    |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |          IGRint      * display       Display mask.                        |
 |          IGRlong     * layers        Layers, 32 IGRlong.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_display (IGRlong    * msg;
                      IGRint     * display;
                      IGRlong    * layers)
{
    IGRint size = 32 * sizeof(IGRlong);
    
    *msg = ASM_S_SUCCESS;

    if (EM_IS_DESCRIBE_ACTIVE (me->props))
    {
        if (display)
        {
            *display = (me->active_display & EM_DISPLAY_PROPS);
        }
    
        if (layers)
        {
            memcpy (layers, me->active_on, size);
        }
    }
    else
    {
        if (display)
        {
            *display = (me->props & EM_DISPLAY_PROPS);
        }
    
        if (layers)
        {
            memcpy (layers, me->nonactive_on, size);
        }
    }

    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_display                                                     |
 |                                                                           |
 | This method will set the display of graphics according to a bit mask      |
 | which may consist of the following:                                       |
 |                                                                           |
 |  EM_GRAPHIC_DISPLAYED    - Should graphics be displayed?                  |
 |  EM_SOLIDSURF_DISPLAYED  - Should solids and surfaces be displayed?       |
 |  EM_WIREFRAME_DISPLAYED  - Should wireframe geometry be displayed?        |
 |  EM_TEXT_DISPLAYED       - Should text be displayed?                      |
 |  EM_DIMENSION_DISPLAYED  - Should dimensions be displayed?                |
 |  EM_REFPLANE_DISPLAYED   - Should reference planes be displayed?          |
 |  EM_CONSTRAINT_DISPLAYED - Should constraints be displayed?               |
 |                                                                           |
 | These defines are found in the assemdef.h include file.                   |
 |                                                                           |
 | It also allows the display on/off for graphics to be set by element layer.|
 | This is done using a array of 32 IGRlongs whose bits represent all layers |
 | from 1 to 1024.                                                           |
 |                                                                           |
 | Input: struct GRmd_env * mod_env   Object module environment.             |
 |        IGRint      * display       Display mask, may be NULL.             |
 |        IGRlong     * layers        Displayed layers, may be NULL.         |
 |        IGRboolean    update        Update the display of the objects?     |
 |                                                                           |
 | Output: IGRlong     * msg       Return code                               |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_display (IGRlong          * msg;
                      struct GRmd_env  * mod_env;
                      IGRint           * display;
                      IGRlong          * layers;
                      IGRboolean         update)
{
    IGRlong       om_msg = OM_S_SUCCESS;
    IGRint        i;
    IGRuint       old_props;
    IGRint        loc_display;
    IGRboolean    display_changed = FALSE, layers_changed = FALSE;
    IGRlong     * p_layers;
        

    *msg = ASM_S_SUCCESS;

    old_props = me->props;

    /*
     * If the display wasn't specified ...
     */
    if (display == NULL)
    {
        loc_display = (EM_IS_DESCRIBE_ACTIVE(me->props)) ?
                    me->active_display :(me->props & EM_DISPLAY_PROPS);
        display = &loc_display;
    }
    else
    {
        /*
         * Always work with the loc_display since the passed in
         * display may be the address of the instance display
         * properties.
         */
        loc_display = *display;
        display = &loc_display;
        
        /*
         * Only allow display properties to be set.
         */
        *display &= EM_DISPLAY_PROPS;

        /*
         * Set the new display properties for active or nonactive.
         */
        if (EM_IS_DESCRIBE_ACTIVE(me->props))
        {
            /*
             * If the display have changed ...
             */
            if (*display != me->active_display)
            {
                me->active_display = *display;
                display_changed = TRUE;
            }
        }
        else
        {
            /*
             * If the display has changed ...
             */
            if (*display != (me->props & EM_DISPLAY_PROPS))
            {
                me->props = *display | (me->props & ~EM_DISPLAY_PROPS);
                display_changed = TRUE;
            }
        }
    }

    /*
     * Get the appropriate layers on set.
     */
    p_layers = (EM_IS_DESCRIBE_ACTIVE (me->props)) ? 
               me->active_on : me->nonactive_on;
        
    /*
     * If the layers were specified ...
     */
    if (layers)
    {
        /*
         * Make sure these are a proper subset of the
         * owned layers.
         */
        if (!(EMis_layer_subset (me->layers, layers)))
        {
            *msg = ASM_E_INVARGS;
            goto quit;
        }

        /*
         * See if any of the layers have changed.
         */
        for (i=0; i<32; i++)
        {
            if (layers[i] != p_layers[i])
            {
                layers_changed = TRUE;
                break;
            }
        }
    }
    else
    {
        layers = p_layers;
    }

    /*
     * If the display changed to erase or if the display is on ...
     */
    if (layers_changed || display_changed)
    {
        /*
         * Update the display of all my layer's graphics.
         */
        om_msg = EMset_layer_display (msg, 
                                      mod_env,           /* Module env */
                                      me->layers,        /* Owned layers */
                                      *display,          /* On Display Types */
                                      layers,            /* On layers */
                                      update);           /* Update display */
    }

 quit:
    
    if (om_msg & *msg & 1)
    {
        EMbom_update (BOM_MOD_PROPS, my_id, OM_Gw_current_OS, mod_env);
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_props                                                       |
 |                                                                           |
 | This method returns the properties of the describe object. If the object  |
 | is active the active display properties will be returned instead of the   |
 | non-active.                                                               |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRuint *     props       Properties of object.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_props (IGRlong * msg; IGRuint * props)
{
    *msg = ASM_S_SUCCESS;
    *props = me->props;

    if (EM_IS_DESCRIBE_ACTIVE(*props))
    {
        *props &= ~EM_DISPLAY_PROPS;
        *props |= (me->active_display & EM_DISPLAY_PROPS);
    }
    
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |									     |
 |  Method: EMupdate_display						     |
 |  									     |
 |  This method updates the display of the localpart object with the         |
 |  display properties and layers info stored in the object instance data.   |
 |									     |
 |  Input:  struct GRmd_env   *mod_env   Module environment.                 |
 |									     |
 |  Output: IGRlong           *msg       Return code.                        |
 |									     |
 |  Return: ASM_S_SUCCESS     Successful.				     |
 |          ASM_E_ABORT       Catostrophic error.                            |
 |									     |
 +---------------------------------------------------------------------------*/
method EMupdate_display (IGRlong          * msg;
                         struct GRmd_env  * mod_env)
{
    IGRlong       om_msg = OM_S_SUCCESS;
    IGRuint       old_props;
    IGRint        display;
    IGRlong     * p_layers;
        

    *msg = ASM_S_SUCCESS;

    old_props = me->props;

    display = (EM_IS_DESCRIBE_ACTIVE(me->props)) ?
                    me->active_display :(me->props & EM_DISPLAY_PROPS);

    p_layers = (EM_IS_DESCRIBE_ACTIVE (me->props)) ? 
               me->active_on : me->nonactive_on;
        
    /*
     * Update the display of all my layer's graphics.
     */
    om_msg = EMset_layer_display (msg, 
                                  mod_env,           /* Module env */
                                  me->layers,        /* Owned layers */
                                  display,           /* On Display Types */
                                  p_layers,          /* On layers */
                                  TRUE);             /* Update display */

    return om_msg;

}

end implementation EMlocalpart;


