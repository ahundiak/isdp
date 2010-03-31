class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <dpdef.h>
#include <dp.h>
#include <dpmacros.h>
#include <csdef.h>
#include <grcoordsys.h>
#include <refdef.h>
#include <ref.h>
#include <alloca.h>

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMcreate_instance                                               |
 |                                                                           |
 | This function creates an instance of a part.                              |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMcreate_instance (IGRlong         * msg,
                           struct GRmd_env * mod_env,
                           IGRint            type,
                           IGRint            display,
                           IGRint            behavior,
                           IGRuint           app_props,
                           struct GRid     * part_id,
                           IGRchar         * filename,
                           IGRchar         * view,
                           IGRchar         * number,
                           IGRchar         * revision,
                           IGRint            quantity,
                           IGRint            num_graphics,
                           struct GRid     * graphic_ids,
                           IGRdouble       * origin,
                           struct GRid     * window_id,
                           IGRdouble       * matrix,
                           IGRint            num_attributes,
                           EMattr          * attributes,
                           struct GRid     * instance_id)
{
    IGRlong                 om_msg = OM_S_SUCCESS;
    struct GRmd_env         loc_mod_env;
    EMinstance_class_attr   inst_attr;
    struct GRid             loc_instance_id;
    IGRmatrix               loc_matrix;
    
    *msg = ASM_S_SUCCESS;
    
    /*
     * Default to the current module environment.
     */
    if (!mod_env)
    {
        mod_env = &loc_mod_env;
        gr$get_module_env(buffer = mod_env);
    }

    /*
     * If the instance id wasn't specified use a local one.
     */
    if (!instance_id)
    {
        instance_id = &loc_instance_id;
    }

    /*
     * If the window id was specified get the placement matrix...
     */
    if (window_id)
    {
        IGRlong error;
        IGRlong num_bytes;
        struct var_list var_list[2];
        IGRmatrix tmp_matrix;
        IGRshort i=4;
        
        matrix = &loc_matrix[0];
        
        var_list[0].var = VW_ROT_NO_CON;
        var_list[0].var_ptr = (IGRchar *)tmp_matrix;
        var_list[0].num_bytes = sizeof(IGRdouble) * 16;
        var_list[0].bytes_returned = &num_bytes;
        var_list[1].var = END_PARAM;
        
        om_msg = dp$inq_set_gragad (msg = msg,
                                    osnum = window_id->osnum,
                                    gragad_objid = window_id->objid,
                                    which_error = &error,
                                    var_list = var_list);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        MAtrnmx (msg, &i, tmp_matrix, matrix);
        
        if (!(*msg & 1))
        {
            goto quit;
        }
    }
    
    /*
     * Setup the instance attribute arguments.
     */
    inst_attr.props = (type & EM_PART_TYPES)        |
                      (display & EM_DISPLAY_PROPS)  |
                      (behavior & EM_BEHAVIOR_PROPS)|
                      (app_props & EM_APPLICATION_PROPS);
    inst_attr.part_id = part_id;
    inst_attr.filename = filename;
    inst_attr.view = view;
    inst_attr.number = number;
    inst_attr.revision = revision;
    inst_attr.num_graphics = num_graphics;
    inst_attr.graphic_ids = graphic_ids;
    inst_attr.origin = origin;
    inst_attr.matrix = matrix;
    inst_attr.quantity = quantity;
    inst_attr.num_attributes = num_attributes;
    inst_attr.attributes = attributes;

    instance_id->osnum = mod_env->md_id.osnum;
    
    om_msg = om$construct (classname = "EMinstance", 
                           msg = message EMdescribe.EMconstruct 
                                                   (msg,
                                                    mod_env,
                                                    (IGRchar *)(&inst_attr)),
                           osnum = instance_id->osnum,
                           p_objid = &(instance_id->objid));

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMinstance_count                                                |
 |                                                                           |
 | This function returns the number of instances of a cached part.           |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMinstance_count (IGRlong        * msg,
                          struct GRid    * part_id,
                          IGRint         * count)
{
    IGRlong           om_msg = OM_S_SUCCESS;

    *msg = ASM_S_SUCCESS;
    
    if (count == NULL)
    {
        *msg = ASM_E_INVARGS;
    }
    else
    {
        *count = 0;

        om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                                EM_INSTANCE,
                                                                count),
                          senderid = NULL_OBJID,
                          targetid = part_id->objid,
                          targetos = part_id->osnum);
    }
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_instance                                                  |
 |                                                                           |
 | This function gets an instance of a local or referenced part definition   |
 | by index or by name.                                                      |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_instance (IGRlong      * msg,
                        struct GRid  * part_id,
                        IGRint         index,
                        struct GRid  * instance_id)
{
    IGRlong          om_msg = OM_S_SUCCESS;
    struct GRid      loc_instance_id;
    EMmemb           memb;

    *msg = ASM_S_SUCCESS;

    if (!instance_id)
    {
        instance_id = &loc_instance_id;
    }
    
    /*
     * If the part_id isn't specified error out.
     */
    if (!part_id)
    {
        *msg = ASM_E_INVARGS;
        goto quit;
    }
 
    /*
     * Get the index'th instance member from the part.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_memb 
                                                 (msg,
                                                  NULL,
                                                  EM_INSTANCE,
                                                  index,
                                                  &memb),
                      senderid = NULL_OBJID,
                      targetid = part_id->objid,
                      targetos = part_id->osnum);

    if ((om_msg & *msg & 1) && (instance_id != NULL))
    {
        instance_id->objid = memb.id.objid;
        instance_id->osnum = memb.id.osnum;
    } 
 
 quit:
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_instance_part                                             |
 |                                                                           |
 | This function returns the local or referenced part definition that        |
 | describes the instance.                                                   |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_instance_part (IGRlong     * msg,
                             struct GRid * instance_id,
                             struct GRid * part_id)
{
    IGRint           om_msg = OM_S_SUCCESS;
    
    *msg = ASM_S_SUCCESS;

    if (instance_id == NULL)
    {
        *msg = ASM_E_INVARGS;
    }
    else
    {
        part_id->objid = NULL_OBJID;
        part_id->osnum = instance_id->osnum;
        
        /*
         * Get the instance's part definition.
         */
        om_msg = om$send (msg = message EMinstance.EMget_part (msg, part_id),
                          senderid = NULL_OBJID,
                          targetid = instance_id->objid,
                          targetos = instance_id->osnum);
    }

    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMnum_instance_graphics                                         |
 |                                                                           |
 | This function returns the number of graphics which description the        |
 | instance graphically.                                                     |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMnum_instance_graphics (IGRlong      * msg,
                                 struct GRid  * instance_id,
                                 IGRint       * num_graphics)
{
    IGRlong om_msg;
    IGRint  loc_count;
    
    *msg = ASM_S_SUCCESS;

    if (!num_graphics)
    {
        num_graphics = &loc_count;
    }
    
    *num_graphics = 0;

    om_msg = om$send (msg = message EMinstance.EMnum_membs(msg,
                                                           EM_GRAPHIC,
                                                           num_graphics),
                      senderid = NULL_OBJID,
                      targetid = instance_id->objid,
                      targetos = instance_id->osnum);

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_instance_graphics                                         |
 |                                                                           |
 | This function returns the graphic descriptions of the instance.           |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_instance_graphics (IGRlong      * msg,
                                 struct GRid  * instance_id,
                                 IGRint       * num_graphics,
                                 struct GRid  * graphic_ids)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  count, i;
    EMmemb  memb;
    
    *msg = ASM_S_SUCCESS;

    om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                            EM_GRAPHIC,
                                                            &count),
                      senderid = NULL_OBJID,
                      targetid = instance_id->objid,
                      targetos = instance_id->osnum);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    if (num_graphics && (*num_graphics >= count))
    {
        for (i=0; i<count; ++i)
        {
            om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                                   NULL,
                                                                   EM_GRAPHIC,
                                                                   i,
                                                                   &memb),
                              senderid = NULL_OBJID,
                              targetid = instance_id->objid,
                              targetos = instance_id->osnum);
        
            if (!(om_msg & *msg & 1))
            {
                continue;
            }

            graphic_ids[i] = memb.id;
        }
    }
    else if (num_graphics)
    {
        *num_graphics = count;
        *msg = ASM_E_ABORT;
    }

 quit:
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_instance_handle                                           |
 |                                                                           |
 | This function returns the handle for the instance.                        |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_instance_handle  (IGRlong      * msg,
                                struct GRid  * instance_id,
                                struct GRid  * handle_id)
{
    IGRlong om_msg = OM_S_SUCCESS;
    EMmemb  memb;
    
    *msg = ASM_S_SUCCESS;

    om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                           NULL,
                                                           EM_HANDLE,
                                                           0,
                                                           &memb),
                      senderid = NULL_OBJID,
                      targetid = instance_id->objid,
                      targetos = instance_id->osnum);
    
    if (om_msg & *msg & 1)
    {
        handle_id->objid = memb.id.objid;
        handle_id->osnum = memb.id.osnum;
    }

    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_instance_name                                             |
 |                                                                           |
 | This function returns the name of the instance within it's part definition|
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_instance_name (IGRlong        *msg,
                             struct GRid    *instance_id,
                             IGRchar        *name)
{
    IGRlong           om_msg = OM_S_SUCCESS;
    IGRchar path[DI_PATH_MAX], instname[DI_PATH_MAX], dirname[DI_PATH_MAX];

    *msg = ASM_S_SUCCESS;

    if (di$untranslate (objid = instance_id->objid,
                        osnum = instance_id->osnum,
              	        objname = path) == DIR_S_SUCCESS)
    {
        /*
         * Get the base name.
         */
        om_msg = di$split (pathname = path, 
                  	dirname = dirname,
                  	name = instname);
        /*
         * If it is a dummy Instance, get the local part name which it is
         * representing
         */
        if(!strcmp(instname,"DmyInst"))    
        {
            om_msg = di$split (pathname = dirname, 
                      		name = name);
            return( om_msg );
        }
    }

    om_msg = om$send (msg = message GRgraphics.GRgetname (msg, name),
                      senderid = NULL_OBJID,
                      targetid = instance_id->objid, 
                      targetos = instance_id->osnum);
    
    return om_msg;
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMset_instance_name                                             |
 |                                                                           |
 | This function changes the name of the specified instance.                 |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMset_instance_name (IGRlong        *msg,
                             struct GRid    *instance_id,
                             IGRchar        *name)
{
    IGRlong           om_msg;
    struct GRmd_env   dummy_env;

    om_msg = om$send (msg = message GRgraphics.GRchgname (msg, 
                                                          &dummy_env,
                                                          name),
                      senderid = NULL_OBJID,
                      targetid = instance_id->objid, 
                      targetos = instance_id->osnum);
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_instance_type                                             |
 |                                                                           |
 | This function returns the type of part instance was create from.          |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_instance_type (IGRlong     * msg,            /* OUTPUT */
                             struct GRid * instance_id,    /* INPUT  */
                             IGRint      * type)           /* OUTPUT */
{
    IGRlong          om_msg;
    IGRint           loc_type;
    struct GRid      part_id;
 
    *msg = ASM_S_SUCCESS;

    om_msg = asm$get_instance_part (msg = msg,
                                    instance_id = instance_id,
                                    part_id = &part_id);
    
    if (om_msg & *msg & 1)
    {
        /* 
         * Get part properties. 
         */
        om_msg = om$send (msg = message EMdescribe.EMget_type (msg, 
                                                               &loc_type),
                          senderid = NULL_OBJID,
                          targetid = part_id.objid,
                          targetos = part_id.osnum);

        if (om_msg & *msg & 1)
        {
            if (type)
            {
                *type = loc_type;
            }
        }
    }
 
    return(om_msg);
}

end implementation EMinstance;
