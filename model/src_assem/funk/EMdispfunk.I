class implementation EMdescribe;

#include <stdio.h>
#include <string.h>
#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <alloca.h>
#include <OMmacros.h>
#include <exmacros.h>
#include <OMminimum.h>
#include <OMlimits.h>
#include <OMOSfilehdr.h>
#include <ex.h>
#include <igr.h>
#include <gr.h>
#include <igrdp.h>
#include <dp.h>
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
#include <lcdef.h>
#include <lc.h>

#include "assemdef.h"
#include "assem.h"

from GRvg       import GRgetsymb;
from GRgraphics import GRchgprops, GRgetprops;
from GRgraphics import GRdelete;
from GRcontext  import GRgetmodule_env;
from EMSdatplnmgr import EMget_info;

extern OMuword OPP_GRreffile_class_id;
extern OMuword OPP_EMinstance_class_id;
extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_GRcsbase_class_id;
extern OMuword OPP_GRgencs_class_id;
extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_GRtext_class_id;
extern OMuword OPP_DMroot_class_id;
extern OMuword OPP_EMSdatpln_class_id;
extern OMuword OPP_SKconstraint_class_id;
extern OMuword OPP_EMScnstr_class_id;
extern OMuword OPP_SKmgr_class_id;
extern OMuword OPP_GRcmpowner_class_id;
extern OMuword OPP_SKexplicit_class_id;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_graphic_display_type                                      |
 |                                                                           |
 | This function returns the graphic display type of the input element. The  |
 | return type will be one of the following defined in assemdef.h.           |
 |                                                                           |
 |  EM_GRAPHIC_DISPLAYED    - Should graphics be displayed?                  |
 |  EM_SOLIDSURF_DISPLAYED  - Should solids and surfaces be displayed?       |
 |  EM_WIREFRAME_DISPLAYED  - Should wireframe geometry be displayed?        |
 |  EM_TEXT_DISPLAYED       - Should text be displayed?                      |
 |  EM_DIMENSION_DISPLAYED  - Should dimensions be displayed?                |
 |  EM_REFPLANE_DISPLAYED   - Should reference planes be displayed?          |
 |  EM_CONSTRAINT_DISPLAYED - Should constraints be displayed?               |
 |                                                                           |
 | Input:   struct GRid * graphic_id    Graphic element to type.             |
 |                                                                           |
 | Ouput:   OMuword     * classid       Graphic element classid.             |
 |                                                                           |
 | Return:  The element type is returned. If it doesn't fall into one of the |
 |          catagories described above 0 will be returned.                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRint EMget_graphic_display_type (struct GRid * gr_id, OMuword * classid)
{
    OMuword loc_classid;
    IGRint type = 0;
    
    if (!classid)
    {
        classid = &loc_classid;
    }
    
    om$get_classid (objid = gr_id->objid,
                    osnum = gr_id->osnum,
                    p_classid = classid);

    if ((om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id,
                               subclassid = *classid) == OM_S_SUCCESS) ||
        (om$is_ancestry_valid (superclassid = OPP_EMSsurface_class_id,
                               subclassid = *classid) == OM_S_SUCCESS))
    {
        type = EM_SOLIDSURF_DISPLAYED;
    }
    else if ((om$is_ancestry_valid (superclassid = OPP_GRgencs_class_id,
                                    subclassid = *classid) == OM_S_SUCCESS))
    {
        if (*classid != OPP_GRcsbase_class_id)
        {
            type = EM_HANDLE_DISPLAYED;
        }
    }
    else if ((om$is_ancestry_valid (superclassid = OPP_DMroot_class_id,
                                    subclassid = *classid) == OM_S_SUCCESS) ||
             (om$is_ancestry_valid (superclassid = OPP_SKexplicit_class_id,
                                    subclassid = *classid) == OM_S_SUCCESS) ||
             (om$is_ancestry_valid (superclassid = OPP_EMScnstr_class_id,
                                    subclassid = *classid) == OM_S_SUCCESS))
    {
        type = EM_DIMENSION_DISPLAYED;
    }
    else if (om$is_ancestry_valid (superclassid = OPP_EMSdatpln_class_id,
                                   subclassid = *classid) == OM_S_SUCCESS)
    {
        type = EM_REFPLANE_DISPLAYED;
    }
    else if (om$is_ancestry_valid (superclassid = OPP_SKconstraint_class_id,
                                    subclassid = *classid) == OM_S_SUCCESS)
    {
        type = EM_CONSTRAINT_DISPLAYED;
    }
    else if (om$is_ancestry_valid (superclassid = OPP_GRcurve_class_id,
                                   subclassid = *classid) == OM_S_SUCCESS)
    {
        type = EM_WIREFRAME_DISPLAYED;
    }
    else if (om$is_ancestry_valid (superclassid = OPP_GRtext_class_id,
                                   subclassid = *classid) == OM_S_SUCCESS)
    {
        type = EM_TEXT_DISPLAYED;
    }
    else if (om$is_ancestry_valid (superclassid = OPP_GRcmpowner_class_id,
                                   subclassid = *classid) == OM_S_SUCCESS)
    {
        type = 0;
    }
    else if (om$is_ancestry_valid (superclassid = OPP_GRreffile_class_id,
                                   subclassid = *classid) == OM_S_SUCCESS)
    {
        type = EM_GRAPHIC_DISPLAYED;
    }

    return type;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMis_type_displayed                                             |
 |                                                                           |
 | This function determines if the input type be displayed                   |
 | according to an input element type display mask.                          |
 | The mask should consist of a combination of the following bit mask that   |
 | that are defined in assemdef.h:                                           |
 |                                                                           |
 |  EM_GRAPHIC_DISPLAYED    - Should graphics be displayed?                  |
 |  EM_SOLIDSURF_DISPLAYED  - Should solids and surfaces be displayed?       |
 |  EM_WIREFRAME_DISPLAYED  - Should wireframe geometry be displayed?        |
 |  EM_TEXT_DISPLAYED       - Should text be displayed?                      |
 |  EM_DIMENSION_DISPLAYED  - Should dimensions be displayed?                |
 |  EM_REFPLANE_DISPLAYED   - Should reference planes be displayed?          |
 |  EM_CONSTRAINT_DISPLAYED - Should constraints be displayed?               |
 |                                                                           |
 | Input:   IGRint        types         Element types to display.            |
 |          IGRint        type          Graphic element type.                |
 |                                                                           |
 | Output:  IGRlong     * msg           ASM_S_SUCCESS - Graphic was typed.   |
 |                                      ASM_E_ABORT   - Graphic wasn't typed.|
 |                                                                           |
 | Return:  TRUE if is should be displayed, FALSE otherwise.                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRboolean EMis_type_displayed (IGRlong     * msg,
                                IGRint        types,
                                IGRint        type)
{
    IGRboolean displayed = FALSE;
    
    *msg = ASM_S_SUCCESS;
    
    /*
     * If the display is on ...
     */
    if (types & EM_GRAPHIC_DISPLAYED)
    {
        /*
         * If any types are off ...
         */
        if (types != EM_DISPLAY_TYPES)
        {
            if (type == 0)
            {
                /*
                 * We encountered an unclassifiable type.
                 */
                displayed = TRUE;
            }   
            else 
            {
                displayed = (types & type) ? TRUE : FALSE;
            }
        }
        else
        {
            displayed = TRUE;
        }
    }        
    
    return displayed;
}

IGRlong EMcontext_display(msg,
                          mod_env,
                          num_mod_env,
                          ctx_mdenv,
                          gr_id,
                          mode)
IGRlong *msg;
struct GRmd_env *mod_env;
IGRint num_mod_env;
struct GRmd_env *ctx_mdenv;
struct GRid   *gr_id;
enum GRdpmode mode;
{
  IGRint i;
  IGRlong sts;
  IGRmatrix        * p_matrix[1];
  IGRshort         * p_matrix_type;

  sts = 1;

  if(num_mod_env == 0)
   {

          p_matrix_type = &(mod_env->md_env.matrix_type);
          p_matrix[0] = (IGRmatrix *)mod_env->md_env.matrix;

          sts = dp$display (msg = msg,
                            osnum = gr_id->osnum,
                            mode = mode,
                            oids = gr_id,
                            mtx_type = p_matrix_type,
                            matrix = p_matrix);
   }
  else
   {
    for(i=0; i < num_mod_env; i++)
     {
          p_matrix_type = &(ctx_mdenv[i].md_env.matrix_type);
          p_matrix[0] = (IGRmatrix *)ctx_mdenv[i].md_env.matrix;
          sts = dp$display (msg = msg,
                            osnum = gr_id->osnum,
                            mode = mode,
                            oids = gr_id,
                            mtx_type = p_matrix_type,
                            matrix = p_matrix);
     }
   }


   return(sts);
}

IGRlong EMget_module_context(msg,
                             osnum,
                             num_ctx_mod,
                             ctx_mod_env)
IGRlong *msg;
GRspacenum osnum;
IGRint *num_ctx_mod;
struct GRmd_env *ctx_mod_env;
{
      IGRlong om_msg;
      struct GRmd_env *p_mdenv;
      struct GRid ref_mgr;
      IGRint  count,ctx_count,i;
      struct GRmd_env ref_env;
      OM_S_OBJECT_LINKAGE   *p_ctxid = NULL;
      OM_S_CHANSELECT to_context;
      struct GRid  current_modid;

      ex$get_cur_mod(id = &current_modid.objid, osnum = &current_modid.osnum);

         /*
          * Gather all modules environments with respect to master file
          * for display.
          */

         om_msg =    ex$get_super (
                        mod_id = current_modid.objid,
                        mod_osnum = current_modid.osnum,
                        super_name = "Ref Mgr",
                        super_class = "Super_rfmgr",
                        create = 0,
                        super_id = &ref_mgr.objid,
                        super_osnum = &ref_mgr.osnum );
         if( !(om_msg & 1))
          {
            return(om_msg);
          }

         to_context.type = OM_e_name;
         to_context.u_sel.name = "Super_rfmgr.to_context";

         om_msg = om$get_channel_count(objid = ref_mgr.objid,
                                       osnum = ref_mgr.osnum,
                                       p_chanselect = &to_context,
                                       count = (OMuint *)&count);
         if(!(om_msg & 1))
          {
            return(om_msg);
          }

         p_ctxid = (OM_S_OBJECT_LINKAGE *)malloc(sizeof(OM_S_OBJECT_LINKAGE) * count);
         if(!p_ctxid)
          {
            return(om_msg);
          }

         om_msg = om$get_channel_objects(objid = ref_mgr.objid,
                                         osnum = ref_mgr.osnum,
                                         p_chanselect = &to_context,
                                         size = count,
                                         list = p_ctxid,
                                         count = (OMuint *) &count);

         if(!(om_msg & 1))
          {
            if(p_ctxid)
              free(p_ctxid);
            return(om_msg);
          }

         p_mdenv = (struct GRmd_env *)malloc(sizeof(struct GRmd_env ) * 10);
         ctx_count = 0;

         for(i=0; i < count; i++)
          {
            om_msg = om$send(msg = message GRcontext.GRgetmodule_env(msg,
                                                               &ref_env),
                             senderid = NULL_OBJID,
                             targetid = p_ctxid[i].S_objid,
                             targetos = p_ctxid[i].osnum);
            if(ref_env.md_id.osnum == osnum)
             {
                if(ctx_count > 10)
                 {
                    p_mdenv = (struct GRmd_env *)realloc(p_mdenv, sizeof(struct
GRmd_env) * 10);
                 }

                p_mdenv[ctx_count] = ref_env;
                ctx_count++;
             }


          }

         if(p_ctxid);
          free(p_ctxid);

       *num_ctx_mod = ctx_count;
       ctx_mod_env = p_mdenv;

   return(om_msg);

}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMset_graphic_display                                           |
 |                                                                           |
 | This function sets the graphic display for a graphic object given a       |
 | display bit mask and a layer bit mask. It will optionally update the      |
 | display of the graphic object.                                            |
 |                                                                           |
 | The mask should consist of a combination of the following bit mask that   |
 | that are defined in assemdef.h:                                           |
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
 | Input:   struct GRid * gr_id         Graphic element.                     |
 |          IGRint      * types         Element types to display.            |
 |          IGRlong     * layers        Displayable layers.                  |
 |          IGRboolean    update        Update the display?                  |
 |                                                                           |
 | Output:  IGRlong     * msg           Return value.                        |
 |                                                                           |
 | Return:  ASM_S_SUCCESS               Successfull update.                  |
 |          ASM_E_ABORT                 Catostrophic error.                  |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 | Gang             7/14/93     added support for ignoring active ref plane. |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMset_graphic_display (IGRlong         * msg,
                               struct GRmd_env * mod_env,
                               IGRint          num_mod_env,
                               struct GRmd_env *ctx_mdenv,
                               struct GRid     * gr_id,
                               IGRint          * types,
                               IGRlong         * layers,
                               IGRboolean        update)
{
    /*
     * This file is grabbing control of display of all graphic objects in the
     * file. Took it out for RFA+Assembly integration.
     */
    return OM_S_SUCCESS;

#ifdef ET_TU_ASSEMBLY

    IGRlong            om_msg;
    IGRshort           property = GRIS_DISPLAYABLE, set = 0;
    IGRshort           gr_property;
    struct GRsymbology symb;
    IGRshort           gr_layer;
    OMuword            classid;
    IGRint             type;
    IGRmatrix        * p_matrix[1];
    IGRshort         * p_matrix_type;
    p_matrix_type = &(mod_env->md_env.matrix_type);
    p_matrix[0] = (IGRmatrix *)mod_env->md_env.matrix;
   
    /*
     * Get the display flag from the element.
     */
    om_msg = om$send (msg = message GRgraphics.GRgetprops (msg, 
                                                           &gr_property),
                      senderid = NULL_OBJID,
                      targetid = gr_id->objid,
                      targetos = gr_id->osnum);
            
    if (!(om_msg & *msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
    
    /*
     * Get the layer of this object.
     */
    om_msg = om$send (msg = message GRvg.GRgetsymb (msg, &symb),
                      senderid = NULL_OBJID,
                      targetid = gr_id->objid,
                      targetos = gr_id->osnum);
        
    if (!(om_msg & *msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    gr_layer = symb.level;
    

    /*
     * Get the display type for the element.
     */
    type = EMget_graphic_display_type (gr_id, &classid);
    
    if((type == EM_REFPLANE_DISPLAYED) && (gr_id->osnum == EX_active_OS_num))
     {
       OM_S_OBJID mgr_id, active_id;

       mgr_id = NULL_OBJID;
       active_id = NULL_OBJID;

       /* get the reference plane manager */
       ex$get_super(mod_id = mod_env->md_id.objid,
		    mod_osnum = mod_env->md_id.osnum,
		    super_name = "EMSdatplnmgr",
		    create = FALSE,
		    super_class = "EMSdatplnmgr",
		    super_id = &mgr_id);

       if(mgr_id != NULL_OBJID)
	{
	  om_msg =  om$send(msg = message EMSdatplnmgr.EMget_info(msg,
								  0,NULL,
								  NULL,
								  &active_id,
		          					  NULL),
                            senderid = NULL_OBJID,
			    targetid = mgr_id,
			    targetos = gr_id->osnum);

	  if(om_msg & *msg & 1)
	   {
	     if(active_id == gr_id->objid)
	      {
		goto quit;
	      }
	   }
	}
     }

    /*
     * If this is an unknow type ...
     */
    if (type == 0)
    {
        /*
         * If it's an owner ...
         */
        if (om$is_ancestry_valid (superclassid = OPP_GRcmpowner_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            /*
             * And it's not an instance ...
             */
            if (om$is_ancestry_valid (superclassid = OPP_EMinstance_class_id,
                                      subclassid = classid) != OM_S_SUCCESS)
            {
                OM_S_CHANSELECT chansel;
                IGRint          i, count = 0;
                struct GRid     comp_id;
            
                /*
                 * Recurse on all the owner's components.
                 */
                GRget_to_comp_info (&chansel, gr_id->osnum, gr_id->objid, &count);
            
                for (i=0; i<count; ++i)
                {
                    om_msg = om$get_objid_at_index (objid = gr_id->objid,
                                                    osnum = gr_id->osnum,
                                                    p_chanselect = &chansel,
                                                    index = i,
                                                    objidaddr = &(comp_id.objid),
                                                    osnumaddr = &(comp_id.osnum));
                
                    if (om_msg & 1)
                    {
                        om_msg = EMset_graphic_display (msg,
                                                        mod_env,
                                                        num_mod_env,
                                                        ctx_mdenv,
                                                        &comp_id,
                                                        types,
                                                        layers,
                                                        update);
                    }
                }
            }
        }
    }
    else /* Know type. */
    {
        /*
         * If the graphic is currently displayed ...
         */
        if (gr_property & GRIS_DISPLAYABLE)
        {
            /*
             * If either the layers or types will cause this
             * object's display to be turned off ...
             */
            if (((layers) ? !EMlayer_in_layers (gr_layer, layers) : FALSE) ||
                ((types) ? !EMis_type_displayed (msg, *types, type) : FALSE))
            {
                /*
                 * If an update was requested erase the object.
                 */
                if (update)
                {
                    om_msg = EMcontext_display (msg,
                                                mod_env,
                                                num_mod_env,
                                                ctx_mdenv,
                                                gr_id,
                                                GRbehe);
                
                    if (!(om_msg & *msg & 1))
                    {
                        *msg = ASM_E_ABORT;
                        goto quit;
                    }
                }
                
                /*
                 * Set the display bit to off.
                */
                set = 0;
                om_msg = om$send (msg = message GRgraphics.GRchgprops (msg,
                                                                       &set,
                                                                       &property),
                                  senderid = NULL_OBJID,
                                  targetid = gr_id->objid,
                                  targetos = gr_id->osnum);

                if (!(om_msg & *msg & 1))
                {
                    *msg = ASM_E_ABORT;
                    goto quit;
                }
            }
        }
        else /* Object is currently erased. */
        {
            /*
             * If both the layers and types indicate that this
             * object's display should be on ...
             */
            if (((layers) ? EMlayer_in_layers (gr_layer, layers) : TRUE) &&
                ((types) ? EMis_type_displayed (msg, *types, type) : TRUE))
            {
                /*
                 * Set the display bit to on.
                 */
                set = 1;
                om_msg = om$send (msg = message GRgraphics.GRchgprops (msg,
                                                                       &set,
                                                                       &property),
                                  senderid = NULL_OBJID,
                                  targetid = gr_id->objid,
                                  targetos = gr_id->osnum);
                
                if (!(om_msg & *msg & 1))
                {
                    *msg = ASM_E_ABORT;
                    goto quit;
                }

                /*
                 * If an update was requested, display the object.
                 */
                if (update)
                {
                    om_msg = EMcontext_display (msg,
                                                mod_env,
                                                num_mod_env,
                                                ctx_mdenv,
                                                gr_id,
                                                GRbd);
                
                    
                    if (!(om_msg & *msg & 1))
                    {
                        *msg = ASM_E_ABORT;
                        goto quit;
                    }
                }
            }
        }
    }

 quit:    

    return om_msg;

#endif
}

struct EMset_display_info
{
    IGRlong         * layers;
    IGRint          * types;
    IGRint            num_mod_env;
    struct GRmd_env * mod_env;
    IGRboolean        update;
};

IGRint EMset_display_func (IGRlong                   * msg,
                           struct GRmd_env           * mod_env,
                           struct GRid               * id,
                           struct EMset_display_info * info)
{
    return (EMset_graphic_display (msg, 
                                   mod_env, 
                                   info->num_mod_env,
                                   info->mod_env,
                                   id, 
                                   info->types,
                                   info->layers,
                                   info->update));
}

IGRlong EMset_layer_display (IGRlong         * msg,
                             struct GRmd_env * mod_env,
                             IGRlong         * layers,
                             IGRint            types,
                             IGRlong         * on_layers,
                             IGRboolean        update)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct EMset_display_info info;
    struct GRid     current_modid;
    struct GRmd_env *p_mdenv = NULL;
    *msg = ASM_S_SUCCESS;
    return OM_S_SUCCESS;

#ifdef ET_TU_ASSEM
  
    ex$get_cur_mod(id = &current_modid.objid, osnum = &current_modid.osnum);
    
    /*
     * Setup the function arguments.
     */
    info.layers = on_layers;
    info.types = &types;
    info.update = update;

    /*
     * If this is a pass in an obj space other than the master.
     */
    if (mod_env->md_id.osnum != current_modid.osnum)
    {
       IGRint ctx_count;

       EMget_module_context(msg,mod_env->md_id.osnum,&ctx_count,p_mdenv);

       info.num_mod_env = ctx_count;
       info.mod_env = p_mdenv;
    }
    else
    {
        info.num_mod_env = 0;
        info.mod_env = NULL;
    }
    
    /*
     * Invoke the layer pass function.
     */
    om_msg = EMlayer_pass (msg,
                           mod_env,
                           layers,
                           NULL, /* Locate Attributes */
                           NULL, /* Locate Classes */
                           EMset_display_func,
                           (IGRchar *)(&info));
        
    if(p_mdenv)
      free(p_mdenv);
    return om_msg;
#endif
}

struct EMdisplay_graphic_by_layer_info
{
    enum GRdpmode mode;
};

IGRint EMdisplay_graphic_by_layer_func (IGRlong                   * msg,
                                        struct GRmd_env           * mod_env,
                                        struct GRid               * id,
                                        struct EMdisplay_graphic_by_layer_info * info)
{
    IGRmatrix   * p_matrix[1];
    IGRshort    * p_matrix_type;

    *msg = ASM_S_SUCCESS;
    
    p_matrix[0] = (IGRmatrix *)mod_env->md_env.matrix;
    p_matrix_type = &mod_env->md_env.matrix_type;
        
    dp$display (msg = msg,
                osnum = mod_env->md_id.osnum,
                mode = info->mode,
                oids = id,
                mtx_type = p_matrix_type,
                matrix = p_matrix);

    return OM_S_SUCCESS;
}

IGRlong EMdisplay_graphic_by_layer (IGRlong         * msg,
                                    struct GRmd_env * mod_env,
                                    IGRlong         * layers,
                                    enum GRdpmode     mode)
{
    IGRlong                                om_msg = OM_S_SUCCESS;
    struct EMdisplay_graphic_by_layer_info info;
    
    *msg = ASM_S_SUCCESS;

    /*
     * Setup the function arguments.
     */
    info.mode = mode;
    
    /*
     * Invoke the layer pass function.
     */
    om_msg = EMlayer_pass (msg,
                           mod_env,
                           layers,
                           NULL, /* Locate Attributes */
                           NULL, /* Locate Classes */
                           EMdisplay_graphic_by_layer_func,
                           (IGRchar *)(&info));

    return om_msg;
}


IGRlong EMlayer_delete_func(IGRlong *msg, 
                            struct GRmd_env *mod_env,
                            struct GRid *id,
                            IGRchar *info)
{
  IGRlong om_msg;
  OMuword classid;

  om_msg = OM_S_SUCCESS;
  info = NULL; /* for quite compilation */

  om$get_classid(objid = id->objid,
                 osnum = id->osnum,
                 p_classid = &classid);
  if((om$is_ancestry_valid(subclassid = classid,
        superclassname = "EMinstance") != OM_S_SUCCESS) &&
     (om$is_ancestry_valid(subclassid = classid,
        superclassname = "GRcsbase") != OM_S_SUCCESS) &&
     (om$is_ancestry_valid(subclassid = classid,
        superclassname = "EMSdatpln") != OM_S_SUCCESS))
   {
     om_msg = dp$display(msg = msg,
                         osnum = mod_env->md_id.osnum,
                         mode = GRbehe,
                         oids = id);

    om_msg = om$send(msg = message GRgraphics.GRdelete(msg, mod_env),
                     senderid = NULL_OBJID,
                     targetid = id->objid,
                     targetos = id->osnum);
  }
 *msg = MSSUCC;
 return(OM_S_SUCCESS);

}

IGRlong EMupdate_part_display(IGRlong *msg,
			      struct GRid *part_id,
			      struct GRmd_env *mod_env)
{
  IGRint  om_msg;
  struct GRmd_env part_env;

  om_msg = ASM_S_SUCCESS;
  *msg = MSSUCC;

  if(mod_env)
   {
     part_env = *mod_env;
   }
  else
   {
     /* get the current module environment */
     gr$get_module_env(buffer = &part_env);
   }

  om_msg = om$send(msg = message EMdescribe.EMupdate_display(msg,
							     &part_env),
                   senderid = NULL_OBJID,
		   targetid = part_id->objid,
		   targetos = part_id->osnum);
  return(om_msg);

}

end implementation EMdescribe;

