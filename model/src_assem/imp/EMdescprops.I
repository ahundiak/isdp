class implementation EMdescribe;

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
 | Method: EMget_props                                                       |
 |                                                                           |
 | This method returns the properties of the describe object.                |
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
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_props                                                       |
 |                                                                           |
 | This method will set the properties of the describe object.               |
 |                                                                           |
 | Input :  IGRuint       props       Properties of object                   |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_props (IGRlong * msg; IGRuint props)
{
    *msg = ASM_S_SUCCESS;
    me->props = props;
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_type                                                        |
 |                                                                           |
 | This method returns the type of the describe object. Possible types are   |
 | as follows:                                                               |
 |                                                                           |
 |      EM_DESCRIPTION      - General EMdescribe object.                     |
 |      EM_FILE_PART        - Local part which defines file as part.         |
 |      EM_LOCAL_PART       - Local part which subdivides file part.         |
 |      EM_REFERENCE_PART   - Cached part which is instance of file part.    |
 |      EM_GRAPHIC_PART     - Cached part which defines graphic as part.     |
 |      EM_NONGRAPHIC_PART  - Cahced part which flags presence of part/inst. |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRint  *     type        Type of object.                        |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 | Note: There is no cooresponding EMset_type since it's not possible to     |
 |       transform a part of one type to a part of another type.             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_type (IGRlong * msg; IGRint * type)
{
    *msg = ASM_S_SUCCESS;
    *type = me->props & EM_DESCRIBE_TYPES;
    return OM_S_SUCCESS;
}

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
 | Note: It is questionable whether this message is very useful for          |
 | EMdescribe objects. But it will become more useful with the EMlocalpart   |
 | class which is a subclass of EMdescribe.                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_display (IGRlong    * msg;
                      IGRint     * display;
                      IGRlong    * layers)
{
    IGRint i;
    
    *msg = ASM_S_SUCCESS;
    
    if (display)
    {
        *display = (me->props & EM_DISPLAY_PROPS);
    }
    
    if (layers)
    {
        for (i=0; i<32; ++i)
        {
            layers[i] = 0xffffffff;
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
 | Input:   struct GRmd_env * mod_env   Module environment for object.       |
 |          IGRint          * display   Display mask, may be NULL.           |
 |          IGRlong         * layers    Layers, may be NULL.                 |
 |          IGRboolean        update    Update the display of the objects?   |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_display (IGRlong         * msg;
                      struct GRmd_env * mod_env;
                      IGRint          * display;
                      IGRlong         * layers;
                      IGRboolean        update)
{
    IGRlong       om_msg = OM_S_SUCCESS;
    EMmemb      * membs;
    IGRint        i, count;
    IGRuint       old_props, new_props;
    IGRint        loc_display;
    IGRboolean    display_changed;

    *msg = ASM_S_SUCCESS;

    old_props = me->props;

    /*
     * If the display mask wasn't specified ...
     */
    if (display == NULL)
    {
        loc_display = me->props & EM_DISPLAY_PROPS;
        display = &loc_display;
        new_props = old_props;
    }
    else
    {
        /*
         * Only allow display properties to be set.
         */
        *display &= EM_DISPLAY_PROPS;
    
        /*
         * Get the new properties
         */
        new_props = (*display & EM_DISPLAY_PROPS) | 
                    (old_props & ~EM_DISPLAY_PROPS);

        /*
         * Set the properties
         */
        me->props = new_props;
    }

    /*
     * See if the display has been toggled to on or off.
     */
    display_changed = EM_IS_GRAPHIC_DISPLAYED(old_props) !=
                      EM_IS_GRAPHIC_DISPLAYED(new_props);
    
    /*
     * If the display changed to erase or is the display is on ...
     */
    if ((display_changed && !EM_IS_GRAPHIC_DISPLAYED(new_props)) ||
        EM_IS_GRAPHIC_DISPLAYED (new_props))
    {
        /*
         * Get the graphic objects.
         */
        om_msg = om$send (msg = message EMdescribe.EMnum_membs
                                                        (msg, 
                                                         EM_GRAPHIC | EM_HANDLE,
                                                         &count),
                          targetid = my_id);
            
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
            
        membs = (EMmemb *)alloca(count * sizeof(EMmemb));
        
        om_msg = om$send (msg = message EMdescribe.EMget_membs
                                                   (msg, 
                                                    EM_GRAPHIC | EM_HANDLE,
                                                    count,
                                                    membs),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
                
        for (i=0; i<count; ++i)
        {
            /*
             * Set the graphic display.
             */
            
            om_msg = EMset_graphic_display (msg,
                                            mod_env,
                                            0,
                                            NULL,
                                            &membs[i].id,
                                            display,
                                            layers,
                                            update);

            if (!(om_msg & *msg & 1))
            {
                *msg = ASM_S_SUCCESS;
                om_msg = OM_S_SUCCESS;
            }
        }
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_behavior                                                    |
 |                                                                           |
 | This method returns the behavior properties of the describe object. These |
 | properties are as follows:                                                |
 |                                                                           |
 |  EM_PART_ACTIVE      - Local part is active part?                         |
 |  EM_FILE_IN_BOM      - Instance in file appear in BOM?                    |
 |  EM_IN_BOM           - This part/instance appears in BOM?                 |
 |  EM_WRITABLE         - Reference file is writable?                        |
 |  EM_BACKGROUND       - Reference file is background?                      |
 |  EM_ATTACHED         - Reference file is attached?                        |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRint  *     behavior    Properties of object.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_behavior (IGRlong * msg; IGRint * behavior)
{
    *msg = ASM_S_SUCCESS;
    *behavior = me->props & EM_BEHAVIOR_PROPS;
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_behavior                                                    |
 |                                                                           |
 | This method sets the behavior properties of the describe object. These    |
 | properties are as follows:                                                |
 |                                                                           |
 |  EM_PART_ACTIVE      - Local part is active part?                         |
 |  EM_FILE_IN_BOM      - Instance in file appear in BOM?                    |
 |  EM_IN_BOM           - This part/instance appears in BOM?                 |
 |  EM_WRITABLE         - Reference file is writable?                        |
 |  EM_BACKGROUND       - Reference file is background?                      |
 |  EM_ATTACHED         - Reference file is attached?                        |
 |                                                                           |
 | Input:  IGRint        behavior    Properties of object.                   |
 |                                                                           |
 | Output: IGRlong *     msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_behavior (IGRlong * msg; IGRint behavior)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = ASM_S_SUCCESS;

    if ((behavior & EM_DESCRIBE_ACTIVE) != (me->props & EM_DESCRIBE_ACTIVE))
    {
        /*
         * Activate or deactivate.
         */
        om_msg = om$send (msg = message EMdescribe.EMset_active 
                                             (msg,
                                              behavior & EM_DESCRIBE_ACTIVE),
                          targetid = my_id);
    }

    me->props = (me->props & ~EM_BEHAVIOR_PROPS) | (behavior & EM_BEHAVIOR_PROPS);
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_application_properties                                      |
 |                                                                           |
 | This method returns the application specific properties of the describe   |
 | object. These properties are defined by the application and consist of    |
 | the 4 high bits in the properties word:                                   |
 |                                                                           |
 |  EM_APPLICATION_PROPS - 0xf0000000                                        |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRuint *     props       Application properties of object.      |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_application_properties (IGRlong * msg; IGRuint * props)
{
    *msg = ASM_S_SUCCESS;
    *props = me->props & EM_APPLICATION_PROPS;
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_application_properties                                      |
 |                                                                           |
 | This method sets the application specific properties of the describe      |
 | object. These properties are defined by the application and consist of    |
 | the 4 high bits in the properties word:                                   |
 |                                                                           |
 |  EM_APPLICATION_PROPS - 0xf0000000, mask for 4 application bits.          |
 |                                                                           |
 | Input:  IGRuint       props       Properties of object.                   |
 |                                                                           |
 | Output: IGRlong *     msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_application_properties (IGRlong * msg; IGRuint props)
{
    *msg = ASM_S_SUCCESS;
    me->props = (me->props & ~EM_APPLICATION_PROPS) | (props & EM_APPLICATION_PROPS);
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |								    	     |
 |  Method : EMupdate_display					             |
 |                                                                           |
 |  This method updates the display of the describe object with the display  |
 |   properties stored in the object instance data.                          |
 |									     |
 |  Input:  struct GRmd_env   *mod_env    Module environment.                |
 |									     |
 |  Output: IGRlong           *msg        Return code.			     |
 |									     |
 |  Return: ASM_S_SUCCESS     Successful.				     |
 |          ASM_E_ABORT       Catostrophic error.                            |
 |									     |
 +---------------------------------------------------------------------------*/
method EMupdate_display (IGRlong         * msg;
                         struct GRmd_env * mod_env)
{
    IGRlong       om_msg = OM_S_SUCCESS;
    EMmemb      * membs;
    IGRint        i, count;
    IGRint        display;

    *msg = ASM_S_SUCCESS;

    display = me->props & EM_DISPLAY_PROPS;

    {
        /*
         * Get the graphic objects.
         */
        om_msg = om$send (msg = message EMdescribe.EMnum_membs
                                                        (msg, 
                                                         EM_GRAPHIC | EM_HANDLE,
                                                         &count),
                          targetid = my_id);
            
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
            
        membs = (EMmemb *)alloca(count * sizeof(EMmemb));
        
        om_msg = om$send (msg = message EMdescribe.EMget_membs
                                                   (msg, 
                                                    EM_GRAPHIC | EM_HANDLE,
                                                    count,
                                                    membs),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
                
        for (i=0; i<count; ++i)
        {
            /*
             * Set the graphic display.
             */
            
            om_msg = EMset_graphic_display (msg,
                                            mod_env,
                                            0,
                                            NULL,
                                            &membs[i].id,
                                            &display,
                                            NULL,
                                            TRUE);

            if (!(om_msg & *msg & 1))
            {
                *msg = ASM_S_SUCCESS;
                om_msg = OM_S_SUCCESS;
            }
        }
    }

 quit:
    
    return om_msg;
}


end implementation EMdescribe;

