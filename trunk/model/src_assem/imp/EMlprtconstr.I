class implementation EMlocalpart;

#include <grimport.h>
#include <DIprims.h>
#include <ex.h>
#include "exdef.h"
#include "exmacros.h"
#include <igr.h>
#include <igrtypedef.h>
#include <igrdp.h>
#include <godef.h>
#include <go.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <griodef.h>
#include <grio.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

#include <assemdef.h>
#include <assem.h>
#include <assemmacros.h>

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

from EMasmmgr import EMset_item_number;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMconstruct                                                       |
 |                                                                           |
 | This method constructs the EMlocalpart object. The class_attr structure   |
 | for this object is EMlocalpart_class_attr defined in assem.h.             |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 | Gang            10/16/93     modification                                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMconstruct (IGRlong         * msg;
                    struct GRmd_env * mod_env;
                    IGRchar         * class_attr)
{
    IGRlong                  om_msg = OM_S_SUCCESS;
    IGRlong                  ok;
    EMlocalpart_class_attr * part_attr;
    EMdescribe_class_attr    desc_attr;
    IGRchar                  loc_directory[DI_PATH_MAX], loc_name[MAX_NAME];
    struct GRid              file_part_id, my_grid;
    IGRint                   part_type;
    IGRint                   i;
    EMattr                   attr;
    IGRboolean               old_system_mode, initialized = FALSE;
    IGRshort                 active_layer;
    OM_S_OBJID               super_objid;
    
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    /*
     * Turn on system mode.
     */
    old_system_mode = EMdesc_set_system_mode(TRUE);
    
    /*
     * Set some local args.
     */
    *msg = ASM_S_SUCCESS;

    /*
     * Reclaim the class attribute structure.
     */    
    part_attr = (EMlocalpart_class_attr *)class_attr;

    /*
     * Initialize my instance data.
     */
    me->active_layer = -1;
    me->active_display = part_attr->props & EM_DISPLAY_PROPS;

    for (i=0; i<32; ++i)
    {
        me->layers[i] = 0;
        me->active_on[i] = 0;
        me->nonactive_on[i] = 0;
    }
        
    /*
     * Get the file part.
     */
    om_msg = asm$get_file_part (msg = msg, 
                                mod_env = mod_env, 
                                part_id = &file_part_id);
    
    if (om_msg & *msg & 1)
    {
        part_type = EM_LOCAL_PART;
    }
    else /* Isn't a file part yet ... */
    {
        part_type = EM_FILE_PART;
        *msg = ASM_S_SUCCESS;
        om_msg = OM_S_SUCCESS;
        file_part_id.objid = my_id;
        file_part_id.osnum = OM_Gw_current_OS;
    }
    
    /*
     * Process the struct members according to the part type.
     */
    switch (part_type)
    {
    case EM_LOCAL_PART:
        if (!(part_attr->layers))
        {
            *msg = MSFAIL;
        }
          
        /* No break intentional! */

    case EM_FILE_PART:
        if (!(part_attr->number) || !(part_attr->revision) ||
            (part_attr->number[0] == '\0') || (part_attr->revision[0] == '\0'))
        {
            *msg = MSFAIL;
        }
        break;

    default:
        *msg = MSFAIL;
        break;
    }

    /*
     * If the arguments are screwed up ...
     */
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }    
    
    /*
     * If this is a local part see if part already exists ...
     */
    if (part_type == EM_LOCAL_PART)
    {
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

        om_msg = OM_S_SUCCESS;
        *msg = ASM_S_SUCCESS;
    }
    
    /*
     * Get the basename for the file we are in.
     */
    om_msg = di$give_pathname (osnum = mod_env->md_id.osnum,
                               pathname = (desc_attr.directory = loc_directory));

    if (!(om_msg & 1) || (om_msg == DIR_W_NAME_NOT_FOUND))
    {
        goto quit;
    }
    
    strcat (desc_attr.directory, ":");

    /*
     * Get the appropriate directory for the part.
     */
    strcat (desc_attr.directory, "definition");

    /*
     * If this is a local part get the name of the file part,
     * since that's where this object will be created.
     */
    if (part_type == EM_LOCAL_PART)
    {
        om_msg = di$untranslate (objname = desc_attr.directory,
                                 objid = file_part_id.objid,
                                 osnum = file_part_id.osnum);

        if (!(om_msg & 1))
        {
            goto quit;
        }
    }
        
    /*
     * Construct the name for the part.
     */
    sprintf (desc_attr.name = loc_name,
             "%s_%s",
             part_attr->number,
             part_attr->revision);

    /*
     * Set my describe stuff.
     */
    desc_attr.props = part_attr->props;
    desc_attr.feature_id = 0;
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
     * Assign the layers ...
     */
    switch (part_type)
    {
    case EM_FILE_PART:

        for (i=0; i<32; ++i)
        {
            me->layers[i] = me->active_on[i] = me->nonactive_on[i] = 0xffffffff;
        }
        
        gr$get_active_layer(buffer = &active_layer);

        me->active_layer = active_layer;

        om_msg = asm$set_active_part (msg = msg,
                                      part_id = &my_grid);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        break;

    case EM_LOCAL_PART:
        /*
         * Set my list of layers. EMset_layers will take care of removing
         * the list of layers from the file part.
         */
        om_msg = om$send (msg = message EMlocalpart.EMset_layers 
                                                     (msg,
                                                      part_attr->layers,
                                                      NULL, NULL),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        break;
    }
    
    /*
     * Add the part number.
     * Fill desc. with "Part Number" instead of null string. It should reflect
     * in Edit part Definition form -- Anand TR#119700590
     */
    attr.info.type = EM_PART_ATTR;
    strcpy (attr.info.name, "number");
    strcpy (attr.info.desc, "Part Number");
    //attr.info.desc[0] = '\0';
    attr.value.type = EM_STRING;
    strcpy (attr.value.syntax, part_attr->number);
        
    om_msg = asm$add_attribute (msg = msg,
                                id = &my_grid,
                                attribute = &attr);

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
    
    om_msg = asm$add_attribute (msg = msg,
                                id = &my_grid,
                                attribute = &attr);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /* create the assembly manager object */

    ex$get_super(mod_id = mod_env->md_id.objid,
                 mod_osnum = mod_env->md_id.osnum,
                 super_name = "asmmgr",
                 create = TRUE,
                 super_class = "EMasmmgr",
                 super_id = &super_objid);
    
    {
        EMattr * p_attr;
        
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

        /*
         * If it is a local part, post the itemno into the asmmgr object
         *                            - 05/10/94
         */
        if(part_type == EM_LOCAL_PART)
        {
            om_msg = om$send( msg = message EMasmmgr.EMset_item_number( msg,
                                                        p_attr->value.syntax),  
                                targetid = super_objid,
                                targetos = mod_env->md_id.osnum);

	    if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
        }
        om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, p_attr),
                                  targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }

    /*
     * Add the remaining user attributes ...
     *
     * NOTE: System mode is turned off so we do the appropriate 
     * attribute creation checking in the EMadd_attr method.
     *
     * Commented temporarly for demo.    -Gang.
     *EMdesc_set_system_mode(FALSE);
     */

    for (i = 0; i < part_attr->num_attrs; ++i)
    {
        /*
         * Add the attribute ...
         */
      
        if(strcmp(part_attr->attrs[i].info.name, "itemno") != 0)
         {
           asm$add_attribute (msg = &ok,
                              id = &my_grid,
                              attribute = &(part_attr->attrs[i]));
         }
    }

    EMdesc_set_system_mode(TRUE);

    /*
     * Construct the dummy instance of this part, to support assembly constraints
     */
    if( part_type == EM_LOCAL_PART )
    {
    struct GRid lprtid;

    lprtid.objid = my_id;
    lprtid.osnum = OM_Gw_current_OS;
    om_msg = EMput_dummy_instance( msg, &lprtid, mod_env );
    }

 quit:
        
    /*
     * If anything failed ...
     */
    if (!(om_msg & *msg & 1))
    {
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
    else
    {
        EMbom_update (BOM_ADD_ENTRY, my_id, OM_Gw_current_OS, mod_env);
    }

    /*
     * Restore the system mode.
     */
    EMdesc_set_system_mode(old_system_mode);

    return (om_msg);
}

IGRint EMput_dummy_instance( msg, localpart, mod_env )
IGRlong *msg;
struct  GRid *localpart;
struct  GRmd_env *mod_env;
{
IGRint om_msg = OM_S_SUCCESS;
struct GRid inst_id, constraint_id;
EMmemb instmemb;

    *msg = MSSUCC;
    /*
     * Construct a dummy EMinstance object and put a GROUND constraint on it
     * then add this dummy as a component to the localpart.
     */
    inst_id.objid = NULL_OBJID;
    inst_id.osnum = mod_env->md_id.osnum;
 
    om_msg = om$construct (classname = "EMinstance",
                           osnum = inst_id.osnum,
                           p_objid = &inst_id.objid );

    strcpy( instmemb.name, "DmyInst");
    instmemb.type = EM_INSTANCE;
    instmemb.desc[0] = '\0';
    instmemb.id.objid = inst_id.objid;
    instmemb.id.osnum = inst_id.osnum;
    
    om_msg = om$send (msg = message EMdescribe.EMadd_memb (msg,
                                                           &instmemb),
			  senderid = NULL_OBJID,
                          targetid = localpart->objid,
                          targetos = localpart->osnum);

    if (!(om_msg & *msg & 1))
    {
        verbose(printf("addmemb failed\n"));
        goto quit;
    }

    om_msg = asm$add_constraint (msg = msg,
                                 instance2_id = &inst_id,
                                 constraint_id = &constraint_id);

    if (!(om_msg & *msg & 1))
    {
        verbose(printf("addconstr failed\n"));
        goto quit;
    }

quit:
    return (om_msg);
}

end implementation EMlocalpart;

