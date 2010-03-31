class implementation EMcachepart;

#include <grimport.h>
#include <DIprims.h>
#include <grerr.h>
#include <gocmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <refdef.h>
#include <alloca.h>

#include <assemdef.h>
#include <assem.h>
#include <assemmacros.h>
#include <assempriv.h>

from GRreffile import GRgetrfprops, GRgetenvironment;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: remove                                                          |
 |                                                                           |
 | If this is the last instance delete myself.                               |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 | jhw              7/20/93     modified for new part class.                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method IGRdir.remove (DIint *status; DIchar *name; DIint index)
{
    IGRlong  om_msg = OM_S_SUCCESS, msg;
    IGRint   count;
    EMmemb   memb;
    
    /*
     * Get the member.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_memb (&msg,
                                                           name,
                                                           EM_MEMBER_TYPES,
                                                           index,
                                                           &memb),
                      targetid = my_id);
    
    if (!(om_msg & msg & 1))
    {
        *status = DIR_E_ABORT;
        goto quit;
    }
    
    /*
     * Remove the member.
     */
    om_msg = om$send (msg = message EMdescribe.remove (status, 
                                                       NULL, 
                                                       memb.index),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

    if ((om_msg & *status & 1) && (memb.type == EM_INSTANCE))
    {
        om_msg = om$send (msg = message EMdescribe.EMnum_membs 
                                            (&msg, EM_INSTANCE, &count),
                          targetid = my_id);

        /*
         * If that was the last instance, delete myself.
         */
        if (om_msg & msg & 1)
        {
            if (count == 0)
            {
                om_msg = om$send (msg = message EMdescribe.EMdelete (&msg),
                                  targetid = my_id);
            
                if (!(msg & 1))
                {
                    *status = DIR_E_ABORT;
                }
            }
        }
        else
        {
            *status = DIR_E_ABORT;
        }
    }

 quit:
    
    return(om_msg);
}        

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMlegal_memb_op                                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/18/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMlegal_memb_op (IGRlong *msg; IGRint operation; EMmemb * memb)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = ASM_S_SUCCESS;

    if (!EMdesc_get_system_mode())
    {
        /*
         * Don't allow modification of part or instance attributes
         * on a reference part since they are a reflection of the 
         * file's file part attributes.
         */
        if ((memb->type & (EM_PART_ATTR | EM_INSTANCE_ATTR)) &&
            (me->props & EM_REFERENCE_PART))
        {
            /*
             * Allow only the modification of the filename.
             */
            if (!((operation == EM_MOD) && !(strcmp(memb->name, "filename"))))
            {
                *msg = ASM_E_ILLEGALOP;
                goto quit;
            }
        }

        om_msg = om$send (msg = message EMpart.EMlegal_memb_op (msg,
                                                                operation,
                                                                memb),
                          mode = OM_e_wrt_message,
                          targetid = my_id);
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMupdate                                                         |
 |                                                                           |
 | This method will cause parts to update themselves according to certain    |
 | criteria. If the part is a reference part the update will be based on the |
 | reference file and the file part. If the part is a graphic part no action |
 | will be taken at this time.                                               |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code.                             |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History: dkk     07/20/94    modified                                     |
 +---------------------------------------------------------------------------*/
method EMupdate (IGRlong *msg)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRboolean old_system_mode;
    struct GRid *inst_list = NULL;
    
    *msg = ASM_S_SUCCESS;
    
    old_system_mode = EMdesc_set_system_mode(TRUE);
    
    /*
     * If this is a reference cached part.
     */
    if (EM_IS_REFERENCE_PART(me->props))
    {
        unsigned long rfprops;
        EMmemb        memb;
        IGRint        i, count;
        

        /*
         * Get the number of instances.
         */
        om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                                EM_INSTANCE,
                                                                &count),
                          targetid = my_id);

        if (!(om_msg & *msg & 1) || (count == 0))
        {
            om_msg = OM_S_SUCCESS;
            *msg = ASM_S_SUCCESS;
            goto quit;
        }
        
        /*
         * Get one of my instances.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_INSTANCE,
                                                               0, 
                                                               &memb),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            om_msg = OM_S_SUCCESS;
            *msg = ASM_S_SUCCESS;
            goto quit;
        }
        
        /*
         * Get the instance's reference file attachment.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_GRAPHIC,
                                                               0,
                                                               &memb),
                          targetid = memb.id.objid,
                          targetos = memb.id.osnum);

        if (!(om_msg & *msg & 1))
        {
            om_msg = OM_S_SUCCESS;
            *msg = ASM_S_SUCCESS;
            goto quit;
        }
        
        /*
         * Get the properties of the reference file attachement.
         */
        om_msg = om$send (msg = message GRreffile.GRgetrfprops (msg, &rfprops),
                          targetid = memb.id.objid,
                          targetos = memb.id.osnum);
        
        /*
         * Update my properties based on the reference file properties.
         */
        me->props &= ~(EM_READONLY | EM_BACKGROUND | EM_DETACHED);
        me->props |= ((rfprops & GRRF_IS_READ_ONLY) ? EM_READONLY   : 0) |
                     ((rfprops & GRRF_BACKGROUND)   ? EM_BACKGROUND : 0) |
                     ((rfprops & GRRF_UNLOADED)     ? EM_DETACHED   : 0);
        
        /*
         * If the reference file is attached see if either the part
         * number or revision has changed.
         */
        if (!EM_IS_DETACHED(me->props))
        {
            EMattr          fp_number, fp_revision;
            EMattr          my_number, my_revision;
            struct GRid     part_id;

            /*
             * Get the number and revision on myself.
             */
            part_id.objid = my_id;
            part_id.osnum = OM_Gw_current_OS;
            
            om_msg = asm$get_part_identity (msg = msg,
                                            part_id = &part_id,
                                            number = &my_number,
                                            revision = &my_revision);
            /*
             * Get the file part.
             */
            om_msg = om$send (msg = message EMcachepart.EMget_definition 
                                                 (msg, &part_id),
                              targetid = my_id);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            /*
             * Get the number and revision on the file part.
             */
            om_msg = asm$get_part_identity (msg = msg,
                                            part_id = &part_id,
                                            number = &fp_number,
                                            revision = &fp_revision);
            /*
             * If the part number and/or revision are different.
             */
            if (strcmp(fp_number.value.data.s, my_number.value.data.s) ||
                strcmp(fp_revision.value.data.s, my_revision.value.data.s))
            {
                IGRchar new_name[DI_PATH_MAX], old_name[DI_PATH_MAX];

                /*
                 * Modify the number and revision locally.
                 */
                om_msg = om$send (msg = message EMdescribe.EMmod_attr
                                                             (msg,
                                                              "number",
                                                              0,
                                                              -1,
                                                              &fp_number),
                                  mode = OM_e_wrt_message,
                                  targetid = my_id);

                if (!(om_msg & *msg & 1))
                {
                    goto quit;
                }
                
                om_msg = om$send (msg = message EMdescribe.EMmod_attr
                                                            (msg,
                                                             "revision",
                                                             0,
                                                             -1,
                                                             &fp_revision),
                                  mode = OM_e_wrt_message,
                                  targetid = my_id);

                if (!(om_msg & *msg & 1))
                {
                    goto quit;
                }

                /*
                 * Now update my name.
                 */
                if (di$untranslate (objid = my_id,
                                    objname = old_name) != DIR_S_SUCCESS)
                {
                    *msg = ASM_E_ABORT;
                    goto quit;
                }
                  
                om_msg = di$give_pathname (osnum = OM_Gw_current_OS,
                                           pathname = new_name);
                
                if (!(om_msg & 1) || (om_msg == DIR_W_NAME_NOT_FOUND))
                {
                    *msg = ASM_E_ABORT;
                    goto quit;
                }
                  
                sprintf (&new_name[strlen(new_name)], ":%s:%s_%s", 
                         "assembly",
                         fp_number.value.data.s, 
                         fp_revision.value.data.s);

                if (strcmp(new_name, old_name))
                {
                    sprintf (new_name, "%s_%s", 
                             fp_number.value.data.s, 
                             fp_revision.value.data.s);

		    part_id.objid = my_id;
                    part_id.osnum = OM_Gw_current_OS;

                    om_msg = EMrename_directory (msg, &part_id, new_name);
                
                    if (!(om_msg & *msg & 1))
                    {
                        goto quit;
                    }
                }

                /*
                 * Now have all my instances update themselves. This will
                 * cause them to change their names according to my cached
                 * part number and revision.
                 */
                inst_list = (struct GRid *)malloc(count * sizeof(struct GRid));
                for (i=0; i<count; ++i)
                {
                    om_msg = om$send (msg = message EMdescribe.EMget_memb
                                                               (msg,
                                                                NULL,
                                                                EM_INSTANCE,
                                                                i,
                                                                &memb),
                                      targetid = my_id);
                    
                    if (om_msg & *msg & 1)
                    {
                        inst_list[i] = memb.id;
                    }
                }

                for (i=0; i<count; ++i)
                {
                        om_msg = om$send (msg = message EMdescribe.EMupdate(msg),
                                          targetid = inst_list[i].objid,
                                          targetos = inst_list[i].osnum);
                
                    if (!(om_msg & *msg & 1))
                    {
                        goto quit;
                    }
                }                

                /*
                 * Now update the BOM.
                 */
                EMbom_update (BOM_MOD_ENTRY, my_id, OM_Gw_current_OS, NULL);
            }
        }
    }

 quit:
    
    /*
     * Restore the system mode.
     */
    EMdesc_set_system_mode(old_system_mode);
    if (inst_list)
        free(inst_list);

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMget_definition                                                 |
 |                                                                           |
 | This method will return the part which defines this cached part.          |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code.                         |
 |          struct GRid * definition_id Definition.                          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_definition (IGRlong * msg; struct GRid * definition_id)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = ASM_S_SUCCESS;
    
    definition_id->objid = NULL_OBJID;

    if (EM_IS_REFERENCE_PART(me->props))
    {
        struct GRmd_env mod_env, env_path;
        EMmemb          memb;
        
        /*
         * Get one of the instances.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_INSTANCE,
                                                               0,
                                                               &memb),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * Get the reference file.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_GRAPHIC,
                                                               0,
                                                               &memb),
                          targetid = memb.id.objid,
                          targetos = memb.id.osnum);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * Get the module for the reference file.
         */
        om_msg = om$send (msg = message GRreffile.GRgetenvironment
                                                  (msg,
                                                   &env_path,
                                                   &mod_env),
                          targetid = memb.id.objid,
                          targetos = memb.id.osnum);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
            
        /*
         * Get the file part.
         */
        om_msg = asm$get_file_part (msg = msg,
                                    mod_env = &mod_env,
                                    part_id = definition_id);
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
    else /* Return myself. */
    {
        definition_id->objid = my_id;
        definition_id->osnum = OM_Gw_current_OS;
    }
    
 quit:
    
    return om_msg;
}

end implementation EMcachepart;






