class implementation EMinstance;

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

#include "refdef.h"
#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"

from EMcachepart import EMget_definition;
from GRcontext import GRgetmodule_env;
from GRreffile import GRgetrfprops, GRchgrfprops;

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
 | Input: struct GRmd_env * mod_env     Module of object.                    |
 |        IGRint          * display     Display mask, may be NULL.           |
 |        IGRlong         * layers      Displayed layers, may be NULL.       |
 |        IGRboolean        update      Update the display of the objects?   |
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
    IGRuint       old_props;
    IGRint        loc_display, old_display;
    IGRboolean    pointer_display_changed = FALSE;
    IGRboolean    display_changed = FALSE;

    *msg = ASM_S_SUCCESS;

    old_display = (old_props = me->props) & EM_DISPLAY_PROPS;

    /*
     * If the display wasn't specified ...
     */
    if (display == NULL)
    {
        loc_display = old_display;
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
         * If the display has changed ...
         */
        if (*display != old_display)
        {

            if(((*display & EM_HANDLE_DISPLAYED) && 
                !(old_display & EM_HANDLE_DISPLAYED)) ||
               ((old_display & EM_HANDLE_DISPLAYED) &&
                !(*display & EM_HANDLE_DISPLAYED)))
             {
               pointer_display_changed = TRUE;
             }
            me->props = *display | (me->props & ~EM_DISPLAY_PROPS);
            display_changed = TRUE;
        }
    }

    /*
     * Adjust the display of the handle and the graphics.
     */
    if (display_changed)
    {
        EMmemb memb;
        IGRint count, i;
        struct GRid ctx_id;
        struct GRid ref_id;
        struct GRmd_env ref_modenv;
        OM_S_CHANSELECT ctx_chan;
        OM_S_OBJECT_LINKAGE *list=NULL;
        IGRint ref_layers[32];
        
        om_msg = om$send (msg = message EMdescribe.EMnum_membs 
                                              (msg,
                                               EM_GRAPHIC | EM_HANDLE,
                                               &count),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        for (i=0; i<count; ++i)
        {
            om_msg = om$send (msg = message EMdescribe.EMget_memb 
                                                (msg,
                                                 NULL,
                                                 EM_GRAPHIC | EM_HANDLE,
                                                 i,
                                                 &memb),
                              targetid = my_id);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            om_msg = EMset_graphic_display (msg, 
                                            mod_env,
                                            0,
                                            NULL,
                                            &memb.id, 
                                            display, 
                                            layers, 
                                            update);
        }

        /*
         * If this is a reference part.
         */

      if(!pointer_display_changed)
        if (EM_IS_REFERENCE_PART(me->props))
        {
            if(EM_IS_GRAPHIC_DISPLAYED(me->props))
             {
               om_msg = om$send (msg = message EMdescribe.EMget_memb 
                                                 (msg,
                                                  NULL,
                                                  EM_GRAPHIC,
                                                  0,
                                                  &memb),
                                 targetid = my_id);
            
               if (!(om_msg & *msg & 1))
                {
                   goto quit;
                }

               ref_id.objid = memb.id.objid;
               ref_id.osnum = memb.id.osnum;
             
               ctx_chan.type = OM_e_name;
               ctx_chan.u_sel.name = "GRreffile.to_context";

               om$get_channel_count(objid = ref_id.objid,
                                    osnum = ref_id.osnum,
                                    p_chanselect = &ctx_chan,
                                    count = (OMuint *)&count);

               list = (OM_S_OBJECT_LINKAGE *) malloc(sizeof(OM_S_OBJECT_LINKAGE)* count);

               /* get the context objectids for this attachment */

                  om_msg = om$get_channel_objects(objid = ref_id.objid,
                                                 osnum = ref_id.osnum,
                                                 p_chanselect = &ctx_chan,
                                                 size = count,
                                                 list = list,
                                                 count = (OMuint *)&count);

               /* get the correct context object */

               for(i=0; i < count; i++)
                 {
                    if(list[i].osnum == EX_active_OS_num)
                     {
                       ctx_id.objid = list[i].S_objid;
                       ctx_id.osnum = list[i].osnum;
                       break;
                     }
                 }

               /* get the module environment from the context */

              om_msg = om$send(msg = message GRcontext.GRgetmodule_env(msg,
                                                                   &ref_modenv),
                               targetid = ctx_id.objid,
                               targetos = ctx_id.osnum);
               free(list);
               
              for(i =0; i <32; i++)
               {
                 ref_layers[i] = 0xffffffff;
               }

               EMset_layer_display(msg,
                                   &ref_modenv,
                                   ref_layers,
                                   *display,
                                   NULL,
                                   TRUE); 
             }
        }
        
        if (om_msg & *msg & 1)
        {
            EMbom_update (BOM_MOD_PROPS, my_id, OM_Gw_current_OS, NULL);
        }
    }
    
 quit:
    
    return om_msg;
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

    /*
     * Can't make an instance active.
     */
    if (behavior & EM_DESCRIBE_ACTIVE)
    {
        behavior &= ~EM_DESCRIBE_ACTIVE;
    }

    me->props = (me->props & ~EM_BEHAVIOR_PROPS) | 
                (behavior & EM_BEHAVIOR_PROPS);
    
    /*
     * If this is a reference part.
     */

    if (EM_IS_REFERENCE_PART(me->props))
    {
       EMmemb memb;
       IGRulong ref_props;
       IGRshort flag;

         om_msg = om$send(msg = message EMdescribe.EMget_memb
                                                   ( msg,
                                                     NULL,
                                                     EM_GRAPHIC,
                                                     0,
                                                     &memb),
                          targetid = my_id);
         if(*msg & om_msg & 1)
          {
             om_msg = om$send(msg = message GRreffile.GRgetrfprops(msg,
                                                                   &ref_props),
                              targetid = memb.id.objid,
                              targetos = memb.id.osnum);

            if(me->props & EM_BACKGROUND)
              ref_props = ref_props | GRRF_BACKGROUND;
            else
              ref_props = ref_props & ~GRRF_BACKGROUND;

            flag = 2;
            om_msg = om$send(msg = message GRreffile.GRchgrfprops(msg,
                                                                  &flag,
                                                                  &ref_props),
                             targetid = memb.id.objid,
                             targetos = memb.id.osnum);
          }
    }

    if (om_msg & *msg & 1)
    {
        EMbom_update (BOM_MOD_PROPS, my_id, OM_Gw_current_OS, NULL);
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |									     |
 |  Method: EMupdate_display						     |
 |  									     |
 |  This method updates the display of the part instance object with the     |
 |  display properties stored in the object instance data.                   |
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
    IGRint        display;

    *msg = ASM_S_SUCCESS;

    display = me->props & EM_DISPLAY_PROPS;

    /*
     * Adjust the display of the handle and the graphics.
     */
    
    {
        EMmemb memb;
        IGRint count, i;
        struct GRid ctx_id;
        struct GRid ref_id;
        struct GRmd_env ref_modenv;
        OM_S_CHANSELECT ctx_chan;
        OM_S_OBJECT_LINKAGE *list=NULL;
        IGRint ref_layers[32];
        
        om_msg = om$send (msg = message EMdescribe.EMnum_membs 
                                              (msg,
                                               EM_GRAPHIC | EM_HANDLE,
                                               &count),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        for (i=0; i<count; ++i)
        {
            om_msg = om$send (msg = message EMdescribe.EMget_memb 
                                                (msg,
                                                 NULL,
                                                 EM_GRAPHIC | EM_HANDLE,
                                                 i,
                                                 &memb),
                              targetid = my_id);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            om_msg = EMset_graphic_display (msg, 
                                            mod_env,
                                            0,
                                            NULL,
                                            &memb.id, 
                                            &display, 
                                            NULL, 
                                            TRUE);
        }

        /*
         * If this is a reference part.
         */

       if (EM_IS_REFERENCE_PART(me->props))
        {
            if(EM_IS_GRAPHIC_DISPLAYED(me->props))
             {
               om_msg = om$send (msg = message EMdescribe.EMget_memb 
                                                 (msg,
                                                  NULL,
                                                  EM_GRAPHIC,
                                                  0,
                                                  &memb),
                                 targetid = my_id);
            
               if (!(om_msg & *msg & 1))
                {
                   goto quit;
                }

               ref_id.objid = memb.id.objid;
               ref_id.osnum = memb.id.osnum;
             
               ctx_chan.type = OM_e_name;
               ctx_chan.u_sel.name = "GRreffile.to_context";

               om$get_channel_count(objid = ref_id.objid,
                                    osnum = ref_id.osnum,
                                    p_chanselect = &ctx_chan,
                                    count = (OMuint *)&count);

               list = (OM_S_OBJECT_LINKAGE *) malloc(sizeof(OM_S_OBJECT_LINKAGE)* count);

               /* get the context objectids for this attachment */

                  om_msg = om$get_channel_objects(objid = ref_id.objid,
                                                 osnum = ref_id.osnum,
                                                 p_chanselect = &ctx_chan,
                                                 size = count,
                                                 list = list,
                                                 count = (OMuint *)&count);

               /* get the correct context object */

               for(i=0; i < count; i++)
                 {
                    if(list[i].osnum == EX_active_OS_num)
                     {
                       ctx_id.objid = list[i].S_objid;
                       ctx_id.osnum = list[i].osnum;
                       break;
                     }
                 }

               /* get the module environment from the context */

              om_msg = om$send(msg = message GRcontext.GRgetmodule_env(msg,
                                                                   &ref_modenv),
                               targetid = ctx_id.objid,
                               targetos = ctx_id.osnum);
               free(list);
               
              for(i =0; i <32; i++)
               {
                 ref_layers[i] = 0xffffffff;
               }

               EMset_layer_display(msg,
                                   &ref_modenv,
                                   ref_layers,
                                   display,
                                   NULL,
                                   TRUE); 
             }
        }
        
    }
    
 quit:
    
    return om_msg;

}



end implementation EMinstance;

