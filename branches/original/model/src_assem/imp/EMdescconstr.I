class implementation EMdescribe;

#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>

#include <assemdef.h>
#include <assem.h>

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMconstruct                                                       |
 |                                                                           |
 | This method constructs the EMdescribe object. The class_attr structure    |
 | for this object is EMdescribe_class_attr defined in assem.h.              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMconstruct (IGRlong         * msg;
                    struct GRmd_env * mod_env;
                    IGRchar         * class_attr)
{
    IGRlong                  om_msg = OM_S_SUCCESS;
    IGRint                   i;
    IGRchar                  loc_directory[DI_PATH_MAX];
    IGRchar                  path[DI_PATH_MAX];
    OMuword                  osnum;
    OM_S_OBJID               objid;
    EMdescribe_class_attr *  desc_attr;
    DIint                    status = DIR_S_SUCCESS, index;
    IGRboolean               old_system_mode;
    
    *msg = ASM_S_SUCCESS;

    /*
     * Turn on the system mode.
     */
    old_system_mode = EMdesc_set_system_mode(TRUE);
    
    /*
     * Initialize myself as a directory.
     */
    om_msg = om$send (msg = message IGRdir.init (&status),
                      targetid = my_id);
    
    if (!(om_msg & status & 1))
    {
        *msg = ASM_E_DIRCREATE;
        goto quit;
    }
    
    /*
     * Reclaim the class attribute structure.
     */    
    desc_attr = (EMdescribe_class_attr *)class_attr;

    /* 
     * Set the properties.
     */
    me->props = desc_attr->props; 

    /*
     * If the name wasn't specified error out.
     */
    if (!desc_attr->name || (desc_attr->name[0] == '\0'))
    {
        *msg = ASM_E_INVARGS;
        goto quit;
    }
    
    objid = NULL_OBJID;

    /*
     * If the directory wasn't specified or is a relative path ...
     */
    if ((desc_attr->directory == NULL)      ||
        ((desc_attr->directory != NULL)     &&
         ((desc_attr->directory[0] == '\0') ||
          (desc_attr->directory[0] != ':'))))
    {
        /*
         * Get the currect working directory.
         */
        di$pwd (dirname = loc_directory,
                p_osnum = &osnum);
        
        /*
         * Make sure we're in the master os.
         */
        if (osnum != mod_env->md_id.osnum)
        {
            *msg = ASM_E_INVARGS;
            goto quit;
        }

        /*
         * If directory is a relative path ...
         */
        if (desc_attr->directory && (desc_attr->directory[0] != ':'))
        {
            /*
             * Construct the full name.
             */
            strncat (loc_directory, ":", DI_PATH_MAX - 1);
            strncat (loc_directory, desc_attr->directory, DI_PATH_MAX - 1);
        }
            
        desc_attr->directory = loc_directory;
    }
        
    /*
     * If the directory that this object goes in doesn't
     * exist ...
     */       
    if ( di$translate (objname = desc_attr->directory,
                       p_osnum = &osnum,
                       p_objid = &objid) != DIR_S_SUCCESS )
    {
        strcpy (path, desc_attr->directory);
        strcat (path, ":");

        /*
         * Create it and all the other directories necessary
         * for it to be created.
         */
        if ( di$mkpath (pathname = path,
                        p_osnum = &osnum ) == DIR_S_SUCCESS)
        {
            /*
             * Get the newly created directory id.
             */
            di$translate (objname = desc_attr->directory,
                          p_osnum = &osnum,
                          p_objid = &objid);
        }
    }

    if (objid == NULL_OBJID)
    {
        *msg = ASM_E_DIRCREATE;
        goto quit;
    }
    
    /*
     * Add myself to my parent directory.
     */
    om_msg = om$send (msg = message IGRdir.add (&status,
                                                desc_attr->name,
                                                my_id,
                                                &index),
                      targetid = objid,
                      targetos = osnum);

    if (!(om_msg & status & 1))
    {
        *msg = ASM_E_DIRCREATE;
        goto quit;
    }
                       
    /*
     * If the feature name was provided add the locate_info 
     * as an attribute.
     */
    if (desc_attr->feature_id && desc_attr->feature_name)
    {
        EMattr attr;
        
        attr.info.type = EM_ATTRIBUTE;
        strcpy (attr.info.name, "locate_name");
        attr.info.desc[0] = '\0';
        attr.value.type = EM_STRING;
        strcpy (attr.value.syntax, desc_attr->feature_name);

        om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, &attr),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
    
    /*
     * Add the other attributes.
     */
    for (i=0; i<desc_attr->num_attributes; i++)
    {
        om_msg = om$send (msg = message EMdescribe.EMadd_attr
                                                (msg,
                                                 &(desc_attr->attributes[i])),
                          targetid = my_id);
    }

    /*
     * Add the described object.
     */
    if (desc_attr->feature_id)
    {
        om_msg = om$send (msg = message EMdescribe.EMadd_notify
                                              (msg, desc_attr->feature_id),
                          targetid = my_id);
    }

    /*
     * If anything failed delete the myself.
     */
    if (!(om_msg & *msg & 1))
    {
        IGRlong     ok;
        
        om$send (msg = message EMdescribe.EMdelete (&ok),
                 targetid = my_id);
    }

 quit:
    
    /*
     * Restore system mode.
     */
    EMdesc_set_system_mode(old_system_mode);
    
    return(om_msg);
}

end implementation EMdescribe;
