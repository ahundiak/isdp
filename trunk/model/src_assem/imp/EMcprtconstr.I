class implementation EMcachepart;

#include <grimport.h>
#include <DIprims.h>
#include <grerr.h>
#include <gr.h>
#include <godef.h>
#include <gocmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <OMindex.h>
#include <refdef.h>
#include <ref.h>
#include <alloca.h>
#include <ex.h>
#include "exdef.h"
#include "exmacros.h"

#include <assemdef.h>
#include <assem.h>
#include <assemmacros.h>
#include <assempriv.h>

from GRgraphics import GRdelete;
from GRreffile  import GRgetenvironment;
from EMasmmgr   import EMset_item_number;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRconstruct                                                     |
 |                                                                           |
 | This method construct the part definition.                                |
 |                                                                           |
 | Different sets of EMpart_class_attr members are used in defining the part |
 | depending on the type of part being created. The type of the part         |
 | is determined by and'ing the props with EM_PART_TYPES.                    |
 |                                                                           |
 | Graphic, Non Graphic and File Parts:                                      |
 |      IGRchar * number                                                     |
 |      IGRchar * revision                                                   |
 |      IGRint  * num_attrs                                                  |
 |      EMattr  * attrs                                                      |
 |                                                                           |
 | Reference Part Arguments:                                                 |
 |      IGRchar * filename    Model filename where part is defined.          |
 |   or                                                                      |
 |      IGRchar * number      Number and revision will be used to find the   |
 |      IGRchar * revision    filename in the directory system.              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMconstruct (IGRlong         * msg; 
                    struct GRmd_env * mod_env; 
                    IGRchar         * class_attr)
{
    IGRlong                   om_msg = OM_S_SUCCESS, ok;
    EMcachepart_class_attr *  part_attr;
    EMdescribe_class_attr     desc_attr;
    IGRchar                   loc_directory[DI_PATH_MAX];
    IGRchar                   loc_name[MAX_NAME];
    IGRint                    part_type;
    struct GRid            *  ref_id, loc_ref_id;
    IGRboolean                reffile_created = FALSE, add_attribute;
    IGRint                    i;
    EMattr                    attr, * p_attr;
    IGRchar                   loc_number[MAX_VALUE], loc_revision[MAX_VALUE];
    IGRboolean                old_system_mode, initialized = FALSE;
    
    /*
     * Turn on system mode.
     */
    old_system_mode = EMdesc_set_system_mode(TRUE);
    
    /*
     * Set some local args.
     */
    *msg = ASM_S_SUCCESS;
    desc_attr.directory = loc_directory;
    desc_attr.name = loc_name;
    
    /*
     * Reclaim the class attribute structure.
     */    
    part_attr = (EMcachepart_class_attr *)class_attr;

    /*
     * Setup the ref_id.
     */
    ref_id = (part_attr->ref_id) ? part_attr->ref_id : &loc_ref_id;
    
    /*
     * Set the part type.
     */
    part_type = (part_attr->props & EM_PART_TYPES);

    /*
     * Get the basename for the file we are in.
     */
    di$give_pathname (osnum = mod_env->md_id.osnum,
                      pathname = desc_attr.directory);

    strcat (desc_attr.directory, ":assembly");

    /*
     * Process the struct members according to the part type.
     */
    switch (part_type)
    {
    case EM_GRAPHIC_PART:
    case EM_NONGRAPHIC_PART:
        if (!(part_attr->number) || !(part_attr->revision))
        {
            *msg = MSFAIL;
        }
        break;

    case EM_REFERENCE_PART:
        if (!(part_attr->filename) && 
            !(part_attr->number && part_attr->revision))
        {
            *msg = MSFAIL;
            break;
        }

        /*
         * Make sure we don't add any extraneous attributes.
         */
        for (i = 0; i < part_attr->num_attrs; i++)
            if (part_attr->attrs[i].info.type != EM_COMMON_ATTR )
                *msg = MSFAIL;                        
        
        /*
         * If a number and revision haven't be specified
         * open the file and get the number, revision, and
         * attributes from the EM_FILE_PART that defines the 
         * file.
         */
        if (!part_attr->number && !part_attr->revision)
        {
            struct GRid        part_id;
            struct GRmd_env    part_mod_env, env_path;

            /*
             * If either there isn't an incoming ref_id or it's a NULL_OBJID.
             */
            if ((part_attr->ref_id == NULL) ||
                (part_attr->ref_id->objid == NULL_OBJID))
            {
                IGRuint loc_props, ref_props;

                ref_props = (EM_IS_READONLY(part_attr->props) ? 
                             GRRF_IS_READ_ONLY :0) | 
                            GRIS_TEMPORARY;

                loc_props = GRIS_NEW | GRNOT_IN_RTREE;
                
                om_msg = EMconstruct_reffile (msg,
                                              mod_env,
                                              part_attr->filename,
                                              NULL,
                                              loc_props,
                                              ref_props,
                                              NULL, NULL, NULL,
                                              ref_id);
                if (!(om_msg & *msg & 1))
                {
                    break;
                }

                reffile_created = TRUE;
            }
            else /* Converting an existing reffile into an instance. */
            {
                *ref_id = *part_attr->ref_id;
            }

            /*
             * Get the osnum and module id of the file from the reference file.
             */
            om_msg = om$send (msg = message GRreffile.GRgetenvironment 
                                               (msg, &env_path, &part_mod_env),
                              senderid = NULL_OBJID,
                              targetid = ref_id->objid,
                              targetos = ref_id->osnum);

            if (!(om_msg & *msg & 1))
            {
                break;
            }
        
            /* 
             * Get file part definition.
             */ 
            om_msg = asm$get_file_part(msg = msg,
                                       mod_env = &part_mod_env,
                                       part_id = &part_id);

            if (!(om_msg & *msg & 1))
            {
                break;
            }

            /*
             * Get the number and revision
             */
            om_msg = om$send (msg = message EMdescribe.EMget_attr
                                                     (msg,
                                                      "number",
                                                      EM_ATTRIBUTE_MEMBERS,
                                                      0,
                                                      &attr),
                              senderid = NULL_OBJID,
                              targetid = part_id.objid,
                              targetos = part_id.osnum);
            
            if (!(om_msg & *msg & 1))
            {
                break;
            }

            strcpy (part_attr->number = loc_number, attr.value.data.s);
            
            om_msg = om$send (msg = message EMdescribe.EMget_attr
                                                     (msg,
                                                      "revision",
                                                      EM_ATTRIBUTE_MEMBERS,
                                                      0,
                                                      &attr),
                              senderid = NULL_OBJID,
                              targetid = part_id.objid,
                              targetos = part_id.osnum);
            
            if (!(om_msg & *msg & 1))
            {
                break;
            }
    
            strcpy (part_attr->revision = loc_revision, attr.value.data.s);

/******* Commented this out, should not get the itemno from the part
         definition        ------------- 05/12/94 ***********
            om_msg = om$send (msg = message EMdescribe.EMget_attr
                                                     (msg,
                                                      "itemno",
                                                      EM_ATTRIBUTE_MEMBERS,
                                                      0,
                                                      &attr),
                              senderid = NULL_OBJID,
                              targetid = part_id.objid,
                              targetos = part_id.osnum);
            
            if (om_msg & *msg & 1)
            {
                part_attr->num_attrs = 1;
                part_attr->attrs = (EMattr *)alloca(sizeof(EMattr));
                part_attr->attrs[0] = attr;
            }
            else
            {
                om_msg = OM_S_SUCCESS;
                *msg = ASM_S_SUCCESS;
            }
*******/    
            /*
             * If the ref_id wasn't specified by the caller delete it. If
             * the ref_id arg is set it indicates that the caller wants to 
             * delete the temporary reference file himself.
             */
            if (ref_id == &loc_ref_id)
            {
                /*
                 * Delete the reference file.
                 */
                om$send (msg = message GRgraphics.GRdelete (&ok, mod_env),
                         senderid = NULL_OBJID,
                         targetid = ref_id->objid,
                         targetos = ref_id->osnum);
                
                reffile_created = FALSE;
            }
        }

        break;

    default:
        *msg = MSFAIL;
        break;
    }

    /*
     * If the number and revision are still not specified
     * error out.
     */
    if (!(part_attr->number) || !(part_attr->revision))
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    /*
     * If the arguments are screwed up ...
     */
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }    
    
    /*
     * If the part already exists ...
     */
    om_msg = asm$get_part (msg = msg, 
                           mod_env = mod_env, 
                           type = EM_PART_TYPES,
                           number = part_attr->number, 
                           revision = part_attr->revision);
    
    if (om_msg & *msg & 1)
    {
        *msg = ASM_E_PARTDEFINED;
        goto quit;
    }
    else
    {
        om_msg = OM_S_SUCCESS;
        *msg = MSSUCC;
    }
    
    /*
     * Construct the name for the part.
     */
    sprintf (desc_attr.name,
             "%s_%s",
             part_attr->number,
             part_attr->revision);


    /*
     * Set the remaining describe construction arguments.
     */
    desc_attr.props = part_attr->props;
    desc_attr.feature_id = NULL;
    desc_attr.feature_name = NULL;
    desc_attr.num_attributes = 0;
    desc_attr.attributes = NULL;
    
    /*
     * Construct the object.
     */
    om_msg = om$send (msg = message EMdescribe.EMconstruct 
                                                    (msg,
                                                     mod_env,
                                                     (IGRchar *)(&desc_attr)),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    initialized = TRUE;
    
    /*
     * Add the part number.
     */
    attr.info.type = EM_PART_ATTR;
    strcpy (attr.info.name, "number");
    attr.info.desc[0] = '\0';
    attr.value.type = EM_STRING;
    strcpy (attr.value.syntax, part_attr->number);
        
    om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, &attr),
                      targetid = my_id);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
        
    /*
     * Add the part revision.
     */
    attr.info.type = EM_PART_ATTR;
    strcpy (attr.info.name, "revision");
    attr.info.desc[0] = '\0';
    attr.value.type = EM_STRING;
    strcpy (attr.value.syntax, part_attr->revision);
    
    om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, &attr),
                      targetid = my_id);
           
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    {
    OM_S_OBJID super_objid;

        super_objid = NULL_OBJID;

        /* get the assembly manager object and post the itemno - 05/10/94  */
        ex$get_super(mod_id = mod_env->md_id.objid,
                 mod_osnum = mod_env->md_id.osnum,
                 super_name = "asmmgr",
                 super_class = "EMasmmgr",
                 super_id = &super_objid);
        /*
         * See if the called specified an item number ...
         */
        if (p_attr = EMget_named_attribute ("itemno",
                                        part_attr->num_attrs,
                                        part_attr->attrs))
        {
            if ((p_attr->info.type == EM_COMMON_ATTR) &&
                (p_attr->value.type == EM_STRING))
            {
                IGRchar buffer[MAX_VALUE];

		/* Changed -- 05/12/94 **/
		strcpy(buffer, p_attr->value.syntax);
                while (!EMitem_string_unique(buffer))
                {
                    EMget_next_item_string(buffer,p_attr->value.syntax);
                    strcpy (buffer, p_attr->value.syntax);
                }
            }
        }
        else
        {
            /*
             * Add a default item number attribute.
             */
            EMnext_itemno_attribute (msg, mod_env, &attr);

            p_attr = &attr; /* for later use */    
        }

        om_msg = om$send( msg = message EMasmmgr.EMset_item_number( msg,
                                                        p_attr->value.syntax),  
                                targetid = super_objid,
                                targetos = mod_env->md_id.osnum);
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg,p_attr),
                              targetid = my_id);
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
    
    /*
     * Add the part type specific attributes ...
     */
    switch (part_type)
    {
    case EM_GRAPHIC_PART:
    case EM_NONGRAPHIC_PART:
        break;

    case EM_REFERENCE_PART:
        /*
         * Add the part filename.
         */
        attr.info.type = EM_PART_ATTR;
        strcpy (attr.info.name, "filename");
        attr.info.desc[0] = '\0';
        attr.value.type = EM_STRING;
        strcpy (attr.value.syntax, part_attr->filename);
    
        om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, &attr),
                          targetid = my_id);
           
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        break;
    }
    
    /*
     * Add the remaining attributes ...
     */
    for (i = 0; i < part_attr->num_attrs; ++i)
    {
        add_attribute = TRUE;
        
        /*
         * Make sure the standard part and common attributes don't
         * get added again.
         */
        if (!strcmp(part_attr->attrs[i].info.name, "number")   ||
            !strcmp(part_attr->attrs[i].info.name, "revision") ||
            !strcmp(part_attr->attrs[i].info.name, "count")    ||
            !strcmp(part_attr->attrs[i].info.name, "itemno"))
        {
            add_attribute = FALSE;
        }
        
        /*
         * Make sure any of the part type specific attributes don't
         * get added again.
         */
        switch (part_type)
        {
        case EM_REFERENCE_PART:
            if (!strcmp(part_attr->attrs[i].info.name, "filename"))
            {
                add_attribute = FALSE;
            }
            break;
        }

        /*
         * Add the attribute ...
         */
        if (add_attribute)
        {
            om_msg = om$send (msg = message EMdescribe.EMadd_attr 
                                       (msg, &(part_attr->attrs[i])),
                              targetid = my_id);
        }
    }

 quit:
        
    /*
     * If anything failed ...
     */
    if (!(om_msg & *msg & 1))
    {
        IGRlong     ok;

        /*
         * Delete the reference file if it's still open.
         */
        if (reffile_created)
        {
            om$send (msg = message GRgraphics.GRdelete (&ok, mod_env),
                     targetid = ref_id->objid,
                     targetos = ref_id->osnum);
        }
        
        if (initialized)
        {
            /*
             * Finally delete me.
             */
            om$send (msg = message EMdescribe.EMdelete (&ok),
                     targetid = my_id);
        }
        else /* Directory never was initialized. */
        {
            /*
             * Rood delete it to avoid memory overwrites.
             */
            om$send (msg = message Root.delete (1),
                     mode = OM_e_wrt_message,
                     targetid = my_id);
        }
    }

    /*
     * Restore the system mode.
     */
    EMdesc_set_system_mode(old_system_mode);

    return (om_msg);
}

end implementation EMcachepart;






