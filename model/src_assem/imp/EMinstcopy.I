class implementation EMinstance;

#include <grimport.h>
#include <OMmacros.h>
#include <OMprimitives.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <grmessage.h>
#include <msdef.h>
#include <msmacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <alloca.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"
#include "assemmacros.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRcopy                                                          |
 |                                                                           |
 | This method copies the EMdescribe object.                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRcopy (IGRlong         *msg; 
               struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv; 
               GRobjid         *newobjid)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRid         new_desc, new_go;
    EMmemb              memb;
    EMattr              attr;
    IGRint              i, count;
    IGRboolean          old_system_mode;

    *msg = MSSUCC;

    count = om$dimension_of (varray = me->info);
    
    /*
     * Go into system mode. This allows EMdescribe subclasses to ignore
     * normal attribute and member checks on removal, modification and
     * addition.
     */
    old_system_mode = EMdesc_set_system_mode(TRUE);

    /*
     * Copy the owner.
     */
    om_msg = om$send ( msg = message GRowner.GRcopy_owner (msg,
                                                           obj_dsenv,
                                                           new_dsenv,
                                                           newobjid),
                       targetid = my_id );

    if ((om_msg & *msg & 1) && 
        (obj_dsenv->md_id.osnum == new_dsenv->md_id.osnum))
    {
        struct GRmd_env loc_new_dsenv, loc_obj_dsenv;
        
        new_desc.objid = *newobjid;
        new_desc.osnum = new_dsenv->md_id.osnum;
        
        /*
         * Get the local context of the elements. It is neccessary
         * to get the context of the new owner first so that when
         * the old owner gets it's context it will clear the abstract
         * geometry cache.   
         */
        om_msg = om$send (msg = message GRowner.GRget_context
                                                   (msg,
                                                    new_dsenv,
                                                    &loc_new_dsenv),
                          targetid = new_desc.objid,
                          targetos = new_desc.osnum);
        
        om_msg = om$send (msg = message GRowner.GRget_context
                                                   (msg,
                                                    obj_dsenv,
                                                    &loc_obj_dsenv),
                          targetid = my_id);
        
        
        /*
         * Copy the objects.
         */
        for (i=0; i<count; ++i)
        {
            /*
             * Get the member.
             */
            om_msg = om$send (msg = message EMdescribe.EMget_memb 
                                                              (msg,
                                                               NULL,
                                                               EM_MEMBER_TYPES,
                                                               i,
                                                               &memb),
                              targetid = my_id);
            
            if (om_msg & *msg & 1)
            {
                if (memb.type & EM_ATTRIBUTE_MEMBERS)
                {
                    /*
                     * Get the attribute info.
                     */
                    om_msg = om$send (msg = message EMdescribe.EMget_attr 
                                                       (msg,
                                                        memb.name,
                                                        EM_ATTRIBUTE_MEMBERS,
                                                        0,
                                                        &attr),
                                      targetid = my_id);

                    if (om_msg & *msg & 1)
                    {
                        /*
                         * Create the attribute on the new object.
                         */
                        om_msg = om$send (msg = message EMdescribe.EMadd_attr 
                                                                (msg, &attr),
                                          targetid = new_desc.objid,
                                          targetos = new_desc.osnum);
                    }
                }
                else
                {
                    /*
                     * Copy the graphic object.
                     */
                    om_msg = om$send ( msg = message GRgraphics.GRcopy 
                                                          ( msg,
                                                            &loc_obj_dsenv,
                                                            &loc_new_dsenv,
                                                            &(new_go.objid)),
                                      targetid = memb.id.objid,
                                      targetos = memb.id.osnum );
                    /*
                     * If everything is ok connect the object to the new owner.
                     */
                    if (om_msg & *msg & 1)
                    {
                        new_go.osnum = loc_new_dsenv.md_id.osnum;

                        memb.id.objid = new_go.objid;
                        memb.id.osnum = new_go.osnum;
                    
                        /*
                         * If this object is a handle give it the same
                         * name as the copied object.
                         */
                        if (memb.type == EM_HANDLE)
                        {
                            IGRlong ok;
                            
                            om$send (msg = message GRgraphics.GRgetname 
                                                     (&ok, memb.name),
                                     targetid = new_desc.objid,
                                     targetos = new_desc.osnum);
                        }
                        
                        om_msg = om$send ( msg = message EMdescribe.EMadd_memb
                                          ( msg, &memb ),
                                          targetid = new_desc.objid,
                                          targetos = new_desc.osnum );
                    }
                }
            }

            if (!(om_msg & *msg & 1)) break;
        }

        /*
         * If anything failed delete the new object.
         */
        if (!(om_msg & *msg & 1))
        {
            IGRlong     ok;

            om_msg = om$send (msg = message GRgraphics.GRdelete (&ok,
                                                                 new_dsenv),
                              targetid = *newobjid,
                              targetos = new_dsenv->md_id.osnum);

            *newobjid = NULL_OBJID;
        }
    }

    /*
     * Restore the system mode.
     */
    EMdesc_set_system_mode(old_system_mode);

    if ((om_msg & *msg & 1) && (new_dsenv->md_id.objid != NULL_OBJID))
    {
        EMbom_update (BOM_ADD_ENTRY, *newobjid, new_dsenv->md_id.osnum, new_dsenv);
    }

    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRcopy_owner                                                    |
 |                                                                           |
 | This method copies the EMdescribe object.                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRcopy_owner (IGRlong         *msg; 
                     struct GRmd_env *obj_dsenv;
                     struct GRmd_env *new_dsenv; 
                     GRobjid         *newobjid)
{
    IGRlong                 om_msg = OM_S_SUCCESS;
    IGRint                  i;
    OM_S_OBJID              objid;
    OMuword                 classid;
    
    *msg = MSSUCC;

    *newobjid = NULL_OBJID;
    
    /*
     * Get my classid.
     */
    om_msg = om$get_classid (objid = my_id, p_classid = &classid);
    
    if (!(om_msg & 1))
    {
        goto quit;
    }
        
    /*
     * If the original and the new object space are the same...
     */
    if (obj_dsenv->md_id.osnum == new_dsenv->md_id.osnum)
    {
        EMdescribe_class_attr   class_attr;
        IGRchar                 directory[DI_PATH_MAX], name[DI_PATH_MAX];
        IGRchar                 path[DI_PATH_MAX], *cp;

        /*
         * Get my full name.
         */
        if (di$untranslate (objid = my_id,
                            objname = path) != DIR_S_SUCCESS)
        {
            *msg = MSFAIL;
            goto quit;
        }

        /*
         * Get my directory and basename.
         */
        di$split (pathname = path,
                  dirname = directory,
                  name = name);

        /*
         * Make sure the name is unique in the directory.
         */
        strcpy (path, directory);
        strcat (path, ":");
        strcat (path, name);
     
        for (i=1; i<5000; ++i)
        {
            if (di$translate (objname = path, p_objid = &objid) != DIR_S_SUCCESS)
            {
                break;
            }
            
            if (cp = strrchr(name, '#'))
            {
                *cp = '\0';
            }
            
            sprintf (path, "%s:%s#%d", directory, name, i);
        }

        /*
         * If we couldn't find a unique name, error out.
         */
        if (i==5000)
        { 
            *msg = MSFAIL;
            om_msg = OM_E_ABORT;
            goto quit;
        }

        /*
         * Construct the new describe object. 
         */
        om_msg = om$construct (osnum = new_dsenv->md_id.osnum,
                               p_objid = newobjid,
                               classid = classid);
        
        if (!(om_msg & 1))
        {
            goto quit;
        }
    
        /*
         * Initialize the describe class attribute structure.
         */
        class_attr.props = me->props;
        class_attr.directory = directory;
        cp = strrchr(path, ':');
        class_attr.name = ++cp;
        class_attr.feature_name = NULL;
        class_attr.feature_id = NULL;
        class_attr.num_attributes = 0;
        class_attr.attributes = NULL;
    
        /* 
         * Initialize the describe object.
         */
        om_msg = om$send (msg = message EMdescribe.EMconstruct 
                                                 (msg,
                                                  new_dsenv,
                                                  (IGRchar *)(&class_attr)),
                          mode = OM_e_wrt_message,
                          targetid = *newobjid,
                          targetos = new_dsenv->md_id.osnum);
    
        /*
         * If anything failed set objid to NULL_OBJID.
         */
        if (!(om_msg & *msg & 1))
        {
            *newobjid = NULL_OBJID;
            goto quit;
        }       
    }
    else /* Different object space. */
    {
        EMinstance_class_attr instance_attr;
        EMattr                *attrs;
        struct GRid           instance_id, *ids;
        IGRint                num_attrs, num_ids = 1, count;
        
        instance_id.objid = my_id;
        instance_id.osnum = OM_Gw_current_OS;

        /*
         * Copy the reference file into the new object space.
         */
        om_msg = asm$num_instance_graphics (msg = msg,
                                            instance_id = &instance_id,
                                            num_graphics = &num_ids);
        
        ids = (struct GRid *)alloca(num_ids * sizeof(struct GRid));

        om_msg = asm$get_instance_graphics (msg = msg,
                                            instance_id = &instance_id,
                                            num_graphics = &num_ids,
                                            graphic_ids = ids);
        
        for (i=0; i<num_ids; ++i)
        {
            objid = NULL_OBJID;
            
            om_msg = om$send (msg = message GRgraphics.GRcopy (msg,
                                                               obj_dsenv,
                                                               new_dsenv,
                                                               &objid),
                          targetid = ids[i].objid,
                          targetos = ids[i].osnum);
        
            ids[i].objid = objid;
            ids[i].osnum = new_dsenv->md_id.osnum;
        }
        
        /*
         * Get the instance attributes.
         */
        om_msg = asm$attribute_count (msg = msg,
                                      id = &instance_id,
                                      type = EM_INSTANCE_ATTR,
                                      count = &count);
        
        if (count)
        {
            attrs = (EMattr *)alloca(count * sizeof(EMattr));

            for (i=0, num_attrs = 0; i<count; ++i)
            {
                om_msg = asm$get_attribute (msg = msg,
                                            id = &instance_id,   
                                            type = EM_INSTANCE_ATTR,
                                            index = i,
                                            attribute = &attrs[num_attrs]);
                if (om_msg & *msg & 1)
                {
                    num_attrs++;
                }
            }

            if (!num_attrs)
            {
                attrs = NULL;
            }
        }
        else
        {
            num_attrs = NULL;
            attrs = NULL;
        }
                                     
        instance_attr.props = me->props;
        instance_attr.part_id = NULL;
        instance_attr.filename = NULL;
        instance_attr.view = NULL;
        instance_attr.number = NULL;
        instance_attr.revision = NULL;
        instance_attr.num_graphics = num_ids;
        instance_attr.graphic_ids = ids;
        instance_attr.origin = NULL;
        instance_attr.matrix = NULL;
        instance_attr.quantity = 1;
        instance_attr.num_attributes = num_attrs;
        instance_attr.attributes = attrs;

        /*
         * Construct the new describe object. 
         */
        om_msg = om$construct (osnum = new_dsenv->md_id.osnum,
                               p_objid = newobjid,
                               classid = classid);
        
        if (!(om_msg & 1))
        {
            goto quit;
        }
    
        /* 
         * Create the instance object.
         */
        om_msg = om$send (msg = message EMdescribe.EMconstruct 
                                                 (msg,
                                                  new_dsenv,
                                                  (IGRchar *)(&instance_attr)),
                          targetid = *newobjid,
                          targetos = new_dsenv->md_id.osnum);
    
        /*
         * If anything failed set objid to NULL_OBJID.
         */
        if (!(om_msg & *msg & 1))
        {
            *newobjid = NULL_OBJID;
            goto quit;
        }       
    }

 quit:
    
    /*
     * If anything failed and the object hasn't been deleted,
     * delete it now.
     */
    if (!(om_msg & *msg & 1) && (*newobjid != NULL_OBJID))
    {
        IGRlong     ok;

        om_msg = om$send (msg = message GRgraphics.GRdelete (&ok,
                                                             new_dsenv),
                          targetid = *newobjid, 
                          targetos = new_dsenv->md_id.osnum);

        *newobjid = NULL_OBJID;
    }
                
    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRcptform                                                       |
 |                                                                           |
 | This method copies and transforms the EMdescribe object.                  |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  12/12/93     creation                                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRcptform (IGRlong         * msg;
                  struct GRmd_env * obj_dsenv;
                  IGRmatrix         matrix;
                  struct GRmd_env * new_dsenv;
                  GRobjid         * newobjid)
{
    return (om$send (msg = message GRgraphics.GRcptform (msg,
                                                         obj_dsenv,
                                                         matrix,
                                                         new_dsenv,
                                                         newobjid),
                     mode = OM_e_wrt_message,
                     targetid = my_id));
}


end implementation EMinstance;


