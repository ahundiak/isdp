class implementation EMpart;

#include <grimport.h>
#include <OMindex.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <ex.h>
#include <igrdp.h>
#include <igr.h>
#include <dpdef.h>
#include <dp.h>
#include <go.h>
#include <griodef.h>
#include <grio.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <refdef.h>
#include <ref.h>
#include <exmacros.h>
#include <csdef.h>
#include <grcoordsys.h>

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

from EMlocalpart import EMget_active_local_part, EMget_layers;
from EMinstance import EMlink_part_attr;
from EMasmmgr import EMget_item_number;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMcreate_part                                                   |
 |                                                                           |
 | This function creates a part definition.                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMcreate_part (IGRlong          *msg,                 /* OUTPUT */
                       struct GRmd_env  *mod_env,             /* INPUT */
                       IGRint           type,                 /* INPUT */
                       IGRint           display,              /* INPUT */
                       IGRint           behavior,             /* INPUT */
                       IGRuint          app_props,            /* INPUT */
                       IGRchar          *number,              /* INPUT */
                       IGRchar          *revision,            /* INPUT */
                       IGRchar          *filename,            /* INPUT */
                       IGRchar          *view,                /* INPUT */
                       IGRint           num_attributes,       /* INPUT */
                       EMattr           *attributes,          /* INPUT */
                       IGRlong          *layers,              /* INPUT */
                       IGRchar          *layers_string,       /* INPUT */
                       struct GRid      *part_id,             /* OUTPUT */
                       struct GRid      *ref_id)              /* INPUTOUTPUT */
{   
    IGRlong                om_msg = OM_S_SUCCESS;
    struct GRmd_env        loc_mod_env;
    struct GRid            loc_part_id;
    EMlocalpart_class_attr local_part_attr;
    EMcachepart_class_attr cache_part_attr;
    IGRlong                loc_layers[32];
    IGRchar               *class_attr;
    IGRint                 count = 0;
    
    *msg = MSSUCC;

    /*
     * Default module env. to current if mod_env is NULL.
     */
    if (!mod_env)
    {
        mod_env = &loc_mod_env;
        gr$get_module_env(buffer = mod_env);
    }

    /*
     * Use the local part id is one isn't provided.
     */
    if (!part_id)
    {
        part_id = &loc_part_id;
    }

    /*
     * If the number and revision is specified and a part with
     * that number and revision exists already return that part
     * and an error message.
     */
    if (number && revision)
    {
        om_msg = asm$get_part (msg = msg,
                               mod_env = mod_env,
                               type = EM_PART_TYPES,
                               number = number,
                               revision = revision,
                               part_id = part_id);

        if (om_msg & *msg & 1)
        {
            *msg = ASM_E_PARTDEFINED;
            
            if (ref_id) 
            {
                ref_id->objid = NULL_OBJID;
            }
            
            goto quit;
        }

        om_msg = OM_S_SUCCESS;
        *msg = MSSUCC;
    }
    
    /*
     * Switch on the type of part.
     */
    switch (type)
    {
    case EM_REFERENCE_PART:
        
        /*
         * If this is a reference part a filename must be specified.
         */
        if (!filename)
        {
            *msg = ASM_E_INVARGS;
            goto quit;
        }
        
        /*
         * See if a reference part exists with that filename already.
         */
        om_msg = asm$part_count (msg = msg,
                                 mod_env = mod_env,
                                 type = EM_REFERENCE_PART,
                                 count = &count);
        
        if ((om_msg & *msg & 1) && (count > 0))
        {
            IGRint i;
            EMattr attr;
            
            for (i=0; i<count; ++i)
            {
                om_msg = asm$get_part (msg = msg,
                                       mod_env = mod_env,
                                       type = EM_REFERENCE_PART,
                                       index = i,
                                       part_id = part_id);
    
                if (om_msg & *msg & 1)
                {
                    om_msg = asm$get_attribute (msg = msg,
                                                name = "filename",
                                                id = part_id,
                                                attribute = &attr);
                    
                    if ((om_msg & *msg & 1) && 
                        (!strcmp (filename, attr.value.data.s)))
                    {
                        *msg = ASM_E_PARTDEFINED;

                        if (ref_id)
                        {
                            ref_id->objid = NULL_OBJID;
                        }
            
                        goto quit;
                    }
                    else
                    {
                        om_msg = OM_S_SUCCESS;
                        *msg = MSSUCC;
                    }
                }
                else
                {
                    om_msg = OM_S_SUCCESS;
                    *msg = MSSUCC;
                }
            }
        }
        break;
        
    case EM_GRAPHIC_PART:
    case EM_NONGRAPHIC_PART:
    case EM_LOCAL_PART:
    case EM_FILE_PART:

        if (!(number && revision))
        {
            *msg = ASM_E_INVARGS;
            goto quit;
        }
        break;

    }
    
    /*
     * Construct part definition argument list.
     */
    if (!EM_IS_CACHED_PART(type))
    {
        if ((layers == NULL) && (layers_string != NULL))
        {
            layers = loc_layers;
            
            om_msg = EMconvert_layer_string_to_mask (msg, 
                                                     layers_string, 
                                                     layers);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
        }
        
        local_part_attr.props = (type & EM_PART_TYPES)         |
                                (display & EM_DISPLAY_PROPS)   |
                                (behavior & EM_BEHAVIOR_PROPS) |
                                (app_props & EM_APPLICATION_PROPS);
        local_part_attr.number = number;
        local_part_attr.revision = revision;
        local_part_attr.num_attrs = num_attributes;
        local_part_attr.attrs = attributes;
        local_part_attr.layers = layers;
        class_attr = (IGRchar *)(&local_part_attr);
    }    
    else
    {
        cache_part_attr.props = (type & EM_PART_TYPES)         |
                                (display & EM_DISPLAY_PROPS)   |
                                (behavior & EM_BEHAVIOR_PROPS) |
                                (app_props & EM_APPLICATION_PROPS);
        cache_part_attr.database = NULL;
        cache_part_attr.catalog = NULL;
        cache_part_attr.filename = filename;
        cache_part_attr.view = view;
        cache_part_attr.number = number;
        cache_part_attr.revision = revision;
        cache_part_attr.num_attrs = num_attributes;
        cache_part_attr.attrs = attributes;
        cache_part_attr.ref_id = ref_id;
        class_attr = (IGRchar *)(&cache_part_attr);
    }

    /*
     * Construct the part definition object.
     */
    part_id->objid = NULL_OBJID;
    part_id->osnum = mod_env->md_id.osnum;
 
    om_msg = om$construct (classname = (EM_IS_CACHED_PART(type)) ?
                                       "EMcachepart" : "EMlocalpart",
                           osnum = part_id->osnum,
                           p_objid = &(part_id->objid),
                           msg = message EMdescribe.EMconstruct (msg,
                                                                 mod_env,
                                                                 class_attr));

quit:
                    
     return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_file_part                                                 |
 |                                                                           |
 | This function returns the definition of a file part.                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_file_part (IGRlong         * msg,     /* OUTPUT */
                         struct GRmd_env * mod_env, /* INPUT  */
                         struct GRid     * part_id) /* OUTPUT */
{
    IGRlong          om_msg = OM_S_SUCCESS;
    struct GRmd_env  loc_mod_env;
    IGRchar          part_path[DI_PATH_MAX];
    struct GRid      dir_id, loc_part_id;
 
    *msg = ASM_S_SUCCESS;

    /*
     * Default module env. to current if mod_env is NULL.
     */
    if (!mod_env)
    {
        mod_env = &loc_mod_env;
        gr$get_module_env(buffer = mod_env);
    }

    /*
     * Allow for a null part id. This lets the caller see if there
     * is a file part defined for this file.
     */
    if (!part_id)
    {
        part_id = &loc_part_id;
    }
 
    /* 
     * Get definition directory id.
     */
    di$give_pathname(osnum = mod_env->md_id.osnum,
                     pathname = part_path);

    strcat(part_path, ":definition");
    
    if (di$translate (objname = part_path,
                      p_objid = &dir_id.objid,
                      p_osnum = &dir_id.osnum) == DIR_S_SUCCESS)
    {
        IGRint   status = DIR_S_SUCCESS;
        IGRint   index = 0;
        
        part_id->objid = NULL_OBJID;
        part_id->osnum = dir_id.osnum;
        
        /*
         * Get the part id by index.
         */
        om_msg = om$send (msg = message IGRdir.translate (&status,
                                                          NULL,
                                                          index,
                                                          NULL,
                                                          &part_id->objid),
                          senderid = NULL_OBJID,
                          targetid = dir_id.objid,
                          targetos = dir_id.osnum);
        
        if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
        {
            *msg = ASM_E_ABORT;
        }
    }
    else
    {
        *msg = ASM_E_ABORT;
    }
    
    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMlocal_part_count                                              |
 |                                                                           |
 | This function returns the number of local part definitions.               |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMlocal_part_count (IGRlong          *msg,                 /* OUTPUT */
                            struct GRmd_env  *mod_env,             /* INPUT  */
                            IGRint           *count)               /* OUTPUT */
{
    IGRlong          om_msg = OM_S_SUCCESS;
    struct GRmd_env  loc_mod_env;
    IGRint           loc_count;
    struct GRid      file_part_id;
    
    *msg = ASM_S_SUCCESS;

    if (!count)
    {
        count = &loc_count;
    }
    
    *count = 0;

    /*
     * Default module env. to current if mod_env is NULL.
     */
    if (!mod_env)
    {
        mod_env = &loc_mod_env;
        gr$get_module_env(buffer = mod_env);
    }
    
    om_msg = asm$get_file_part (msg = msg,
                                part_id = &file_part_id);
        
    if (!(om_msg & *msg & 1))
    {
        om_msg = OM_S_SUCCESS;
        *msg = ASM_S_SUCCESS;
        *count = 0;
        goto quit;
    }

    om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                            EM_PART,
                                                            count),
                      senderid = NULL_OBJID,
                      targetid = file_part_id.objid,
                      targetos = file_part_id.osnum);

 quit:
    
    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_local_part                                                |
 |                                                                           |
 | This function returns the local part by index or number/revision.         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_local_part (IGRlong          *msg,                 /* OUTPUT */
                          struct GRmd_env  *mod_env,             /* INPUT */
                          IGRchar          *number,              /* INPUT */
                          IGRchar          *revision,            /* INPUT */
                          IGRint           index,                /* INPUT */
                          struct GRid      *part_id)             /* OUTPUT */
{
    IGRlong          om_msg = OM_S_SUCCESS;
    struct GRmd_env  loc_mod_env;
    IGRint           count, i;
    struct GRid      file_part_id;
    struct GRid      loc_part_id;
    
    *msg = ASM_S_SUCCESS;

    /*
     * Default module env. to current if mod_env is NULL.
     */
    if (!mod_env)
    {
        mod_env = &loc_mod_env;
        gr$get_module_env(buffer = mod_env);
    }

    if (!part_id)
    {
        part_id = &loc_part_id;
    }
        
    om_msg = asm$get_file_part (msg = msg,
                                part_id = &file_part_id);
        
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    if (number && revision)
    {
        EMmemb memb;
        EMattr attr;
        
        om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                                EM_PART,
                                                                &count),
                          senderid = NULL_OBJID,
                          targetid = file_part_id.objid,
                          targetos = file_part_id.osnum);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        for (i=0; i<count; ++i)
        {
            om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                                   NULL,
                                                                   EM_PART,
                                                                   i,
                                                                   &memb),
                              senderid = NULL_OBJID,
                              targetid = file_part_id.objid,
                              targetos = file_part_id.osnum);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            om_msg = asm$get_attribute (msg = msg,
                                        id = &memb.id,
                                        name = "number",
                                        attribute = &attr);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            if (!strcmp(number, attr.value.data.s))
            {
                om_msg = asm$get_attribute (msg = msg,
                                            id = &memb.id,
                                            name = "revision",
                                            attribute = &attr);

                if (!(om_msg & *msg & 1))
                {
                    goto quit;
                }

                if (!strcmp(revision, attr.value.data.s))
                {
                    if (part_id)
                    {
                        part_id->objid = memb.id.objid;
                        part_id->osnum = memb.id.osnum;
                    }
                    
                    break;
                }
            }
        }

        if (i == count)
        {
            *msg = ASM_E_MEMBNOTFOUND;
        }
        else
        {
            om_msg = OM_S_SUCCESS;
            *msg = ASM_S_SUCCESS;
        }
    }
    else if (index >= 0)
    {
        EMmemb memb;
        
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_PART,
                                                               index,
                                                               &memb),
                          senderid = NULL_OBJID,
                          targetid = file_part_id.objid,
                          targetos = file_part_id.osnum);    

        if ((om_msg & *msg & 1) && part_id)
        {
            part_id->objid = memb.id.objid;
            part_id->osnum = memb.id.osnum;
        }
    }
    else
    {
        *msg = ASM_E_INVARGS;
    }

 quit:
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMcached_part_count                                             |
 |                                                                           |
 | This function returns the number of cached part definitions.              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMcached_part_count (IGRlong          *msg,       /* OUTPUT */
                             struct GRmd_env  *mod_env,   /* INPUT  */
                             IGRint            type,      /* INPUT  */
                             IGRint           *count)     /* OUTPUT */
{
    IGRlong          om_msg = OM_S_SUCCESS;
    IGRint           status = DIR_S_SUCCESS;
    struct GRmd_env  loc_mod_env;
    IGRint           i, loc_count, num_parts;
    IGRint           loc_type;
    IGRchar          path[DI_PATH_MAX];
    struct GRid      dir_id, part_id;
    
    *msg = ASM_S_SUCCESS;

    if (!count)
    {
        count = &loc_count;
    }
    
    *count = 0;

    /*
     * Default module env. to current if mod_env is NULL.
     */
    if (!mod_env)
    {
        mod_env = &loc_mod_env;
        gr$get_module_env(buffer = mod_env);
    }

    /*
     * Get file name.
     */
    om_msg = di$give_pathname (osnum = mod_env->md_id.osnum,
                               pathname = path);

    if (!(om_msg & 1))
    {
        goto quit;
    }
    
    /*
     * Get the number of parts in the assembly directory.
     */
    strcat(path, ":assembly");
    
    if (di$translate (objname = path,
                      p_objid = &dir_id.objid,
                      p_osnum = &dir_id.osnum) != DIR_S_SUCCESS)
    {
        goto quit;
    }
    
    strcat(path, ":*");

    status = di$dump (regexp = path,
                      ptr = &num_parts);
 
    if (!(status & 1))
    {
        goto quit;
    }
 
    for (i=0; i<num_parts; i++)
    {
        part_id.objid = NULL_OBJID;
        part_id.osnum = dir_id.osnum;

        /*
         * Get the part id by index out of the assembly directory.
         */
        om_msg = om$send (msg = message IGRdir.translate (&status,
                                                          NULL,
                                                          i,
                                                          NULL,
                                                          &(part_id.objid)),
                          senderid = NULL_OBJID,
                          targetid = dir_id.objid,
                          targetos = dir_id.osnum);
        
        if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }
    
        om_msg = asm$get_part_type (msg = msg,
                                    part_id = &part_id,
                                    type = &loc_type);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    
        if (loc_type & type)
        {
            (*count)++;
        }
    }

 quit:
    
    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_cached_part                                               |
 |                                                                           |
 | This function returns the cache part definition by index or               |
 | number/revision.                                                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_cached_part (IGRlong          *msg,                 /* OUTPUT */
                           struct GRmd_env  *mod_env,             /* INPUT */
                           IGRint            type,                /* INPUT */
                           IGRchar          *number,              /* INPUT */
                           IGRchar          *revision,            /* INPUT */
                           IGRint           index,                /* INPUT */
                           struct GRid      *part_id)             /* OUTPUT */
{
    IGRlong          om_msg = OM_S_SUCCESS;
    struct GRmd_env  loc_mod_env;
    IGRint           i, num_parts, loc_index;
    IGRint           loc_type;
    IGRchar          path[DI_PATH_MAX], name[DI_PATH_MAX];
    IGRchar          *p_name = NULL;
    struct GRid      loc_part_id, dir_id;

    *msg = ASM_S_SUCCESS;
    
    if (!part_id)
    {
        part_id = &loc_part_id;
    }
 
    /*
     * Default module env. to current if mod_env is NULL.
     */
    if (!mod_env)
    {
        mod_env = &loc_mod_env;
        gr$get_module_env(buffer = mod_env);
    }

    /* 
     * If part number and revision are specified
     */
    if (number && revision)
    {
        sprintf (p_name = name, "%s_%s", number, revision);
    }
    else if (index < 0)
    {
        *msg = ASM_E_INVINDEX;
        goto quit;
    }

    /* 
     * Get definition directory id.
     */
    om_msg = di$give_pathname(osnum = mod_env->md_id.osnum,
                              pathname = path);

    if (!(om_msg & 1))
    {
        goto quit;
    }

    strcat(path, ":assembly");

    if (di$translate (objname = path,
                      p_objid = &dir_id.objid,
                      p_osnum = &dir_id.osnum) == DIR_S_SUCCESS)
    {
        IGRint status = DIR_S_SUCCESS;
     
        part_id->objid = NULL_OBJID;
        part_id->osnum = dir_id.osnum;

        if (number && revision)
        {
            /*
             * Get the part id by name out of the assembly directory.
             */
            om_msg = om$send (msg = message IGRdir.translate (&status,
                                                              p_name,
                                                              -1,
                                                              NULL,
                                                              &part_id->objid),
                              senderid = NULL_OBJID,
                              targetid = dir_id.objid,
                              targetos = dir_id.osnum);
            
            if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
            {
                *msg = ASM_E_ABORT;
                goto quit;
            }
            
            om_msg = asm$get_part_type (msg = msg,
                                        part_id = part_id,
                                        type = &loc_type);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            if (!(type & loc_type))
            {
                *msg = ASM_E_ABORT;
            }
        }
        else
        {
            strcat(path, ":*");

            status = di$dump (regexp = path,
                              ptr = &num_parts);
 
            if (!(status & 1))
            {
                num_parts = 0;
            }

            part_id->osnum = dir_id.osnum;
 
            for (loc_index = 0, i=0; i<num_parts; i++)
            {
                part_id->objid = NULL_OBJID;

                /*
                 * Get the part id by index out of the assembly directory.
                 */
                om_msg = om$send (msg = message IGRdir.translate (&status,
                                                                  NULL,
                                                                  i,
                                                                  NULL,
                                                                  &(part_id->objid)),
                                  senderid = NULL_OBJID,
                                  targetid = dir_id.objid,
                                  targetos = dir_id.osnum);

                if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
                {
                    *msg = ASM_E_MEMBNOTFOUND;
                    goto quit;
                }
                
                om_msg = asm$get_part_type (msg = msg,
                                            part_id = part_id,
                                            type = &loc_type);

                if (!(om_msg & *msg & 1))
                {
                    goto quit;
                }
    
                if (loc_type & type)
                {
                    if (loc_index == index)
                    {
                        break;
                    }
                
                    loc_index++;
                }
            }
        }
    }
    else
    {
        *msg = ASM_E_MEMBNOTFOUND;
    }

 quit:

    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMpart_count                                                    |
 |                                                                           |
 | This function returns the number of part definitions.                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMpart_count (IGRlong          *msg,       /* OUTPUT */
                      struct GRmd_env  *mod_env,   /* INPUT  */
                      IGRint            type,      /* INPUT  */
                      IGRint           *count)     /* OUTPUT */
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  loc_count, temp_count;
    
    if (!count)
    {
        count = &loc_count;
    }
    
    *count = 0;
    
    if (type & EM_FILE_PART)
    {
        if (count)
        {
            *count = 1;
        }
    }

    if (type & EM_LOCAL_PART)
    {
        om_msg = EMlocal_part_count (msg, 
                                     mod_env, 
                                     &temp_count);

        if (om_msg & *msg & 1)
        {
            *count += temp_count;
        }
    }
    
    if (type & EM_CACHED_PART)
    {
        om_msg = EMcached_part_count (msg, 
                                      mod_env, 
                                      type & EM_CACHED_PART, 
                                      &temp_count);

        if (om_msg & *msg & 1)
        {
            *count += temp_count;
        }
    }
    
    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_part                                                      |
 |                                                                           |
 | This function returns the part definition by index or number/revision.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_part (IGRlong          *msg,                 /* OUTPUT */
                    struct GRmd_env  *mod_env,             /* INPUT */
                    IGRint            type,                /* INPUT */
                    IGRchar          *number,              /* INPUT */
                    IGRchar          *revision,            /* INPUT */
                    IGRint           index,                /* INPUT */
                    struct GRid      *part_id)             /* OUTPUT */
{
    IGRlong     om_msg = OM_S_SUCCESS;
    IGRint      count = 0, loc_count;
    struct GRid loc_part_id;

    /*
     * If the part id wasn't supplied use a local one.
     */
    if (!part_id)
    {
        part_id = &loc_part_id;
    }
    
    /*
     * If the number and revision were specified.
     */
    if (number && revision)
    {
        EMattr loc_number, loc_revision;
         
        /*
         * See if the file part is it ...
         */
        om_msg = asm$get_file_part (msg = msg,
                                    mod_env = mod_env,
                                    part_id = part_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        om_msg = asm$get_part_identity (msg = msg,
                                        part_id = part_id,
                                        number = &loc_number,
                                        revision = &loc_revision);
                
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        if (!strcmp(loc_number.value.data.s, number) &&
            !strcmp(loc_number.value.data.s, revision))
        {
            goto quit;
        }

        /*
         * See if a local part is it ...
         */
        om_msg = EMget_local_part (msg, 
                                   mod_env, 
                                   number, 
                                   revision, 
                                   -1, 
                                   part_id);
        
        if (om_msg & *msg & 1)
        {
            goto quit;
        }

        /*
         * See if a cached part is it ...
         */
        om_msg = EMget_cached_part (msg, 
                                    mod_env, 
                                    type, 
                                    number, 
                                    revision, 
                                    -1, 
                                    part_id);
    }
    else /* Index is used. */
    {
        if (type & EM_FILE_PART)
        {
            if (index == 0)
            {
                om_msg = asm$get_file_part (msg = msg,
                                            mod_env = mod_env,
                                            part_id = part_id);
                goto quit;
            }

            count = 1;
        }
        
        if (type & EM_LOCAL_PART)
        {
            om_msg = EMlocal_part_count (msg, 
                                         mod_env, 
                                         &loc_count);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            if ((index >= count) && (index < (count + loc_count)))
            {
                /* Decrement the index by count if the type used is the
                   generic EM_PART_TYPES. 27/09/94
                */
		if (type & EM_PART_TYPES)
		    index -= count;

                om_msg = EMget_local_part (msg, 
                                           mod_env,
                                           NULL,
                                           NULL,
                                           index,
                                           part_id);
                goto quit;
            }

            count += loc_count;
        }
        
        if (type & EM_CACHED_PART)
        {
            om_msg = EMcached_part_count (msg, 
                                          mod_env, 
                                          type & EM_CACHED_PART,
                                          &loc_count);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            if ((index >= count) && (index < (count + loc_count)))
            {
                /* Decrement the index by count if the type used is the
                   generic EM_PART_TYPES. 27/09/94
                */
		if (type & EM_PART_TYPES)
		    index -= count;

                om_msg = EMget_cached_part (msg,
                                            mod_env,
                                            type & EM_CACHED_PART,
                                            NULL,
                                            NULL,
                                            index,
                                            part_id);
                goto quit;
            }
        }

    }

 quit:

    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_part_type                                                 |
 |                                                                           |
 | This function returns the part type.                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_part_type (IGRlong     * msg,            /* OUTPUT */
                         struct GRid * part_id,        /* INPUT  */
                         IGRint      * type)           /* OUTPUT */
{
    IGRlong          om_msg;
 
    *msg = ASM_S_SUCCESS;

    /* 
     * Get part properties. 
     */
    om_msg = om$send (msg = message EMdescribe.EMget_type (msg, type),
                      senderid = NULL_OBJID,
                      targetid = part_id->objid,
                      targetos = part_id->osnum);

    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_part_identity                                             |
 |                                                                           |
 | This function returns the part number and revision for a part.            |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_part_identity (IGRlong         * msg,         /* OUTPUT */
                             struct GRid     * part_id,     /* INPUT  */
                             EMattr          * number,      /* OUTPUT */
                             EMattr          * revision,    /* OUTPUT */
                             EMattr          * description) /* OUTPUT */
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    if (number)
    {
        om_msg = asm$get_attribute (msg = msg,
                                    id = part_id,
                                    name = "number",
                                    attribute = number);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
    
    if (revision)
    {
        om_msg = asm$get_attribute (msg = msg,
                                    id = part_id,
                                    name = "revision",
                                    attribute = revision);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }

    if (description)
    {
        om_msg = asm$get_attribute (msg = msg,
                                    id = part_id,
                                    name = "description",
                                    attribute = description);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }

 quit:                           
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_active_part                                               |
 |                                                                           |
 | This function gets the active part.                                       |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_active_part (IGRlong     * msg,            /* OUTPUT */
                           struct GRid * part_id)        /* OUTPUT */
{
    IGRlong         om_msg;
    struct GRid     file_part_id, loc_part_id;
    
    if (!part_id)
    {
        part_id = &loc_part_id;
    }
    
    om_msg = asm$get_file_part (msg = msg,
                                part_id = &file_part_id);
        
    if (!(om_msg & 1))
    {
        goto quit;
    }
        
    om_msg = om$send (msg = message EMlocalpart.EMget_active_local_part (msg,
                                                                         part_id),
                      senderid = NULL_OBJID,
                      targetid = file_part_id.objid,
                      targetos = file_part_id.osnum);
 quit:
    
    return om_msg;
}
                                    
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMset_active_part                                               |
 |                                                                           |
 | This function gets the active part.                                       |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMset_active_part (IGRlong     * msg,            /* OUTPUT */
                           struct GRid * part_id)        /* INPUT  */
{
    IGRlong         om_msg;
    struct GRid     active_id, loc_part_id;
    
    if (part_id == NULL)
    {
        om_msg = asm$get_file_part (msg = msg,
                                    part_id = &loc_part_id);
        
        if (!(om_msg & 1))
        {
            goto quit;
        }
        
        part_id = &loc_part_id;
    }
                                    
    om_msg = asm$get_active_part (msg = msg,
                                  part_id = &active_id);

    if (!(om_msg & *msg & 1))
    {
        active_id.objid = NULL_OBJID;
        om_msg = OM_S_SUCCESS;
        *msg = ASM_S_SUCCESS;
    }

    /*
     * If the part is different.    
     */
    if (part_id->objid != active_id.objid)
    {
        om_msg = om$send (msg = message EMdescribe.EMset_active (msg, TRUE),
                          senderid = NULL_OBJID,
                          targetid = part_id->objid,
                          targetos = part_id->osnum);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
    
 quit:
    
    return om_msg;
}
          
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMnext_part_layer_set                                           |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | Jay Wallingford  9/15/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMnext_part_layer_set (IGRlong * msg,
                               IGRint    num_layers, 
                               IGRlong * first_layer,
                               IGRlong * last_layer,
                               IGRlong * layers)
{   
    IGRlong     om_msg = OM_S_SUCCESS;
    struct GRid part_id;
    IGRint      i;
    IGRlong     file_part_layers[32], loc_layers[32];

    om_msg = asm$get_file_part (msg = msg,
                                part_id = &part_id);

    if (om_msg & *msg & 1)
    {
        om_msg = om$send (msg = message EMlocalpart.EMget_layers (msg,
                                                                  file_part_layers,
                                                                  NULL, NULL),
                          senderid = NULL_OBJID,
                          targetid = part_id.objid,
                          targetos = part_id.osnum);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        if (!layers)
        {
            layers = loc_layers;
        }
        
        om_msg = EMget_layer_subset (msg, 
                                     file_part_layers, 
                                     num_layers, 
                                     layers);
        
        if (om_msg & *msg & 1)
        {
            if (first_layer)
            {
                *first_layer = EMget_first_layer (layers);
            }
            
            if (last_layer)
            {
                *last_layer = EMget_last_layer (layers);
            }
        }
        
    }
    else
    {
        for (i=0; i<32; ++i)
        {
            layers[i] = 0xffffffff;
        }
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMlink_attribute                                                |
 |                                                                           |
 | This function links an attribute on a instance's part to an instance.     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMlink_attribute (IGRlong         * msg,
                          struct GRid     * instance_id,
                          IGRchar         * name,
                          EMattr          * attribute)
{
    IGRlong om_msg = OM_S_SUCCESS;

    *msg = ASM_S_SUCCESS;

    /* 
     * Link attribute to instance.
     */
    om_msg = om$send (msg = message EMinstance.EMlink_part_attr (msg,
                                                                 name,
                                                                 attribute),
                      senderid = NULL_OBJID,
                      targetos = instance_id->osnum,
                      targetid = instance_id->objid);
    
    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMnext_itemno_attribute                                         |
 |                                                                           |
 | This function returns the next available item number for a part.          |
 |                                                                           |
 | Return:  EMattr            Item number.                                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMnext_itemno_attribute (IGRlong         * msg, 
                                 struct GRmd_env * mod_env,
                                 EMattr          * attribute)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    struct GRmd_env loc_mod_env;
    OM_S_OBJID  super_objid;
    
    /*
     * Default module env. to current if mod_env is NULL.
     */
    if (!mod_env)
    {
        mod_env = &loc_mod_env;
        gr$get_module_env(buffer = mod_env);
    }

    ex$get_super (mod_id = mod_env->md_id.objid,
                  mod_osnum = mod_env->md_id.osnum,
                  super_name = "asmmgr",
                  create = TRUE,
                  super_class = "EMasmmgr",
                  super_id = &super_objid);

    om_msg = om$send (msg = message EMasmmgr.EMget_item_number 
                                                     (msg, 
                                                      attribute->value.syntax),
                      senderid = NULL_OBJID,
                      targetid = super_objid,
                      targetos = mod_env->md_id.osnum);

    if (om_msg & *msg & 1)
    {
        attribute->info.type = EM_COMMON_ATTR;
        strcpy (attribute->info.name, "itemno");
        attribute->info.desc[0] = '\0';
        attribute->value.type = EM_STRING;
    }
    
    return om_msg;
}


IGRboolean EMis_itemno_unique( IGRchar * item, IGRlong part_type )
{
    IGRlong     om_msg, msg;
    IGRint      i, count;
    struct GRid part_id;
    EMattr      attr;
    IGRboolean  unique = TRUE;

    om_msg = asm$part_count (msg = &msg,
                             type = part_type,
                             count = &count);
        
    if (!(om_msg & msg & 1))
    {
        goto quit;
    }

    for (i=0; i<count; ++i)
    {
        om_msg = asm$get_part (msg = &msg,
                               type = part_type,
                               index = i,
                               part_id = &part_id);
        
        if (!(om_msg & msg & 1))
        {
            goto quit;
        }
        
        om_msg = asm$get_attribute (msg = &msg,
                                    id = &part_id,
                                    name = "itemno",
                                    attribute = &attr);
        
        if ((om_msg & msg & 1) && !strcmp(attr.value.data.s, item))
        {
            unique = FALSE;
            break;
        }
    }

 quit:
    
    return unique;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMitem_string_unique                                            |
 |                                                                           |
 | This function returns TRUE if the item string isn't being used by any     |
 | parts in the master file, FALSE otherwise.                                |
 |                                                                           |
 | Input:   IGRchar * item                                                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 | krishna kumar    02/10/94    modified - split into two calls              |
 +---------------------------------------------------------------------------*/
IGRboolean EMitem_string_unique (IGRchar * item)
{

/****** combining the localpart and cachepart would not work ****
        Do it individually.

    om_msg = asm$part_count (msg = &msg,
                             type = EM_CACHED_PART | EM_LOCAL_PART,
                             count = &count);

***********************************************************/

    if(EMis_itemno_unique( item, EM_CACHED_PART )) /* unique among cacheparts */
        if(EMis_itemno_unique(item, EM_LOCAL_PART))/* unique among localparts */
            return( TRUE );

    return( FALSE );        
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_next_item_string                                          |
 |                                                                           |
 | This function returns the next item string, based on the input item string|
 |                                                                           |
 | Input:   IGRchar * last_item                                              |
 |                                                                           |
 | Output:  IGRchar * next_item                                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRchar * EMget_next_item_string (IGRchar * last_item, IGRchar * next_item)
{
    IGRint      len;
    IGRboolean  numeric = TRUE, alpha = TRUE;
    IGRchar   * cp, l;
    IGRint      num;

    /*
     * If the last item wasn't specified or it's a empty string ...
     */
    if (!last_item || !(len = strlen (last_item)))
    {
        /*
         * Default to 1.
         */
        strcpy (next_item, "1");
    }
    else
    {
        /*
         * Determine the format of the item number, numberic, alphabetic,
         * or mixed.
         */
        cp = last_item;
    
        while (*cp != '\0')
        {
            if (isalpha((int)*cp))
            {
                numeric = FALSE;
            }
            else if (isdigit((int)*cp))
            {
                alpha = FALSE;
            }
            else
            {
                numeric = alpha = FALSE;
            }
            
            if (!numeric && !alpha)
            {
                break;
            }

            ++cp;
        }
#ifdef DEBUG
printf("itnum %s is numeric=%d, alpha=%d\n",last_item,numeric,alpha);
#endif
        /*
         * Process the next item string according to the format.
         */
        if (numeric)
        {
            /*
             * Get the integer and increment it by one.
             */
            num = atoi(last_item);
            sprintf (next_item, "%d", ++num);
        }
        else if (alpha)
        {
            /* 
             * Increment the alpha item number by one.
             */
            strcpy (cp = next_item, last_item);
            
            while ((*cp == 'z') || (*cp == 'Z')) ++cp;
            
            if (*cp == '\0')
            {
                l = isupper((int)*(cp = next_item)) ? 'A' : 'a';

                while (*cp != NULL) *cp++ = l;
                
                *cp++ = l; *cp = '\0';
            }
            else
            {
                cp = &next_item[len-1];
                
                for (cp = &next_item[len-1];cp != next_item - 1; --cp)
                {
                    if ((*cp == 'z') || (*cp == 'Z'))
                    {
                        *cp -= 25;
                    }
                    else
                    {
                        (*cp)++;
                        break;
                    }
                }
            }
        }
        else
        { 
            /*
             * Increment the mixed item number by one.
             */
            IGRchar loc_last_item[40];
            
            strcpy (loc_last_item, last_item);
            
            num = 0;
            
            cp = &loc_last_item[--len];
            
            while (isdigit((int)*cp) && (cp != loc_last_item)) cp--;
            
            if (cp != &loc_last_item[len])
            {
                num = atoi(++cp);
                *cp = '\0';
            }
        
            sprintf (next_item, "%s%d", loc_last_item, ++num);
        }
    }
    
    return (next_item);
}

end implementation EMpart;
