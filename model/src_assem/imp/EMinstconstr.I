class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grerr.h>
#include <gocmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <godef.h>
#include <csdef.h>
#include <grcoordsys.h>
#include <igrdef.h>
#include <igr.h>
#include <refdef.h>
#include <ref.h>
#include <refmacros.h>

#include <assemdef.h>
#include <assem.h>
#include <assemmacros.h>
#include <assempriv.h>

extern OMuword OPP_GRreffile_class_id;

from EMpart import EMget_instancename;
from GRreffile import GRgetlbsys, GRrfunload;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMconstruct                                                     |
 |                                                                           |
 | This method construct the instance definition.                            |
 |                                                                           |
 | Graphic Parts:                                                            |
 |      IGRuint       props                                                  |
 |      struct GRid * part_id                                                |
 |      struct GRid * graphic_id                                             |
 |      IGRint        quantity                                               |
 |   or                                                                      |
 |      IGRuint       props                                                  |
 |      IGRchar     * number      Lookup up existing part id, create it if   |
 |      IGRchar     * revision    it doesn't exist.                          |
 |      struct GRid * graphic_id                                             |
 |      IGRint        quantity                                               |
 |                                                                           |
 | Non Graphic Parts:                                                        |
 |      IGRuint       props                                                  |
 |      struct GRid * part_id                                                |
 |      IGRint        quantity                                               |
 |   or                                                                      |
 |      IGRuint       props                                                  |
 |      IGRchar     * number      Lookup up existing part id, create it if   |
 |      IGRchar     * revision    doesn't exist.                             |
 |      IGRint        quantity                                               |
 |                                                                           |
 | Reference Part Arguments:                                                 |
 |      IGRuint       props                                                  |
 |      IGRchar     * filename    Model filename where part is defined.      |
 |      IGRchar     * view        Saved view to use for attachement. Opt.    |
 |      IGRdouble   * origin                                                 |
 |      IGRdouble   * matrix                                                 |
 |      IGRint        quantity                                               |
 |   or                                                                      |
 |      IGRuint       props                                                  |
 |      IGRchar     * number      Number and revision will be used to find   |
 |      IGRchar     * revision    the filename in the directory system.      |
 |      IGRchar     * view        Saved view to use for attachement. Opt.    |
 |      IGRdouble   * origin                                                 |
 |      IGRdouble   * matrix                                                 |
 |      IGRint        quantity                                               |
 |   or                                                                      |
 |      IGRuint       props                                                  |
 |      struct GRid * part_id     Id of the part to create instance from.    |
 |      IGRchar     * view        Saved view to use for attachement. Opt.    |
 |      IGRdouble   * origin                                                 |
 |      IGRdouble   * matrix                                                 |
 |      IGRint        quantity                                               |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 | jhw              7/20/93     modification for new part classes.           |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMconstruct (IGRlong         * msg;
                    struct GRmd_env * mod_env;
                    IGRchar         * class_attr)
{
    IGRlong                  om_msg = OM_S_SUCCESS, ok;
    EMinstance_class_attr  * instance_attr;
    EMdescribe_class_attr    desc_attr;
    IGRchar                  loc_directory[DI_PATH_MAX], loc_name[MAX_NAME];
    IGRchar                  loc_filename[1024], loc_view[256];
    IGRuint                  loc_props, ref_props, handle_props;
    IGRint                   part_type;
    struct GRid              loc_part_id, ref_id, tmp_ref_id, handle_id;
    IGRboolean               part_created = FALSE, handle_created = FALSE;
    IGRboolean               reffile_created = FALSE;
    EMmemb                   memb;
    EMattr                   attr;
    IGRboolean               old_system_mode;
    IGRint                   i, count;
    struct GRid              my_grid;
    IGRmatrix                loc_matrix;
    IGRdouble                loc_origin[3];
    IGRboolean               initialized = FALSE;

    IGRint                   num_common_attrs;
    EMattr                   *common_attrs = NULL;    
    /*
     * Initialize variables.
     */
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    *msg = ASM_S_SUCCESS;

    ref_id.objid = tmp_ref_id.objid = NULL_OBJID;

    handle_id.objid = loc_part_id.objid = NULL_OBJID;

    desc_attr.directory = loc_directory;
    desc_attr.name = loc_name;
    
    /*
     * Turn on system mode.
     */
    old_system_mode = EMdesc_set_system_mode(TRUE);

    /*
     * Reclaim the class attribute structure.
     */    
    instance_attr = (EMinstance_class_attr *)class_attr;

    /*
     * Extract the part type.
     */
    part_type = instance_attr->props & EM_PART_TYPES;
    
    /*
     * If the part type wasn't specified ...
     */
    if (!part_type)
    {
        /*
         * If there a part id was specified get the part type
         * from the part defintion.
         */
        if (instance_attr->part_id)
        {
            om_msg = om$send (msg = message EMdescribe.EMget_type
                                                 (msg, &part_type),
                              targetid = instance_attr->part_id->objid,
                              targetos = instance_attr->part_id->osnum);
        }
        else if (instance_attr->filename)
        {
            part_type = EM_REFERENCE_PART;
        }
        else if (instance_attr->graphic_ids)
        {
            part_type = EM_GRAPHIC_PART;
        }

        instance_attr->props |= part_type;
    }
    
    if (!(om_msg & *msg & 1) || !part_type)
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Check the input arguments according to the part type.
     */
    switch (part_type)
    {
    case EM_GRAPHIC_PART:
        if (!(instance_attr->num_graphics) || !(instance_attr->graphic_ids))
        {
            *msg = ASM_E_ABORT;
            break;
        }

        /* No Break Intentional! */

    case EM_NONGRAPHIC_PART:
        if (!(instance_attr->part_id) && 
            !(instance_attr->number && instance_attr->revision))
        {
            *msg = ASM_E_ABORT;
        }
        break;

    case EM_REFERENCE_PART:
	/* Changed this condition so that even if we give the filename, 
 	   number,rev and partid, along with a graphic and if it's a
	   reference file, it should be possible to create instance for
           it        - 07/29/94
        */
        if (!(instance_attr->filename) && 
            !(instance_attr->number && instance_attr->revision) &&
            !(instance_attr->part_id))
        {
            if (!(instance_attr->graphic_ids))
            {
                *msg = ASM_E_ABORT;
	        break;
            }
        }
        {            
            /*
             * If a graphic object is specified see if it's a reference
             * file. Might be a conversion request.
             */
            if ((instance_attr->num_graphics == 1) &&
                (instance_attr->graphic_ids != NULL))
            {   
                om_msg = gr$get_ref_parameters (msg = msg,
                                                mod_env = mod_env,
                                                ref_grid = instance_attr->graphic_ids,
                                                ref_properties = NULL,
                                                filename = loc_filename,
                                                saved_view = loc_view);
                    
                if (om_msg & *msg & 1)
                {
                    struct IGRlbsys lbsys;
                    
                    instance_attr->filename = loc_filename;
                    instance_attr->view = loc_view;

                    om_msg = om$send (msg = message GRreffile.GRgetlbsys 
                                                 (msg,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &lbsys),
                                      targetid = instance_attr->graphic_ids[0].objid,
                                      targetos = instance_attr->graphic_ids[0].osnum);
                    
                    memcpy (loc_matrix, lbsys.matrix, sizeof(IGRmatrix));

                    loc_origin[0] = lbsys.matrix[3];
                    loc_origin[1] = lbsys.matrix[7];
                    loc_origin[2] = lbsys.matrix[11];

                    instance_attr->matrix = loc_matrix;
                    instance_attr->origin = loc_origin;

                    ref_id.objid = instance_attr->graphic_ids[0].objid;
                    ref_id.osnum = instance_attr->graphic_ids[0].osnum;
                }
            }
        }
        break;

    default:
        *msg = ASM_E_ABORT;
        break;
    }

    /*
     * If the arguments were bad error out.
     */
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Collect all the common attributes and send them to create_part,
     * so that they will be added to the cached part.
     */
    num_common_attrs = 0;
    for (i = 0; i < instance_attr->num_attributes; i++)
    {
        if (instance_attr->attributes[i].info.type == EM_COMMON_ATTR)
        {
            common_attrs = (EMattr *)malloc ((num_common_attrs+1)*sizeof(EMattr));
            common_attrs[num_common_attrs++] = instance_attr->attributes[i];
        }
    }

    /*
     * If we don't have a part id yet ...
     */
    if (!(instance_attr->part_id))
    {
        /*
         * If the number and revision where specified...
         */
        if (instance_attr->number && instance_attr->revision)
        {
            /*
             * Try to find the part in the assembly directory. 
             */
            om_msg = asm$get_part (msg = msg,
                                   mod_env = mod_env,
                                   type = EM_CACHED_PART,
                                   number = instance_attr->number,
                                   revision = instance_attr->revision,
                                   part_id = instance_attr->part_id);

            if (om_msg & *msg & 1)
            {
                instance_attr->part_id = &loc_part_id;

                /*
                 * If the part is a reference part we need to 
                 * get the filename for the reference file
                 * construction.
                 */
                if (part_type == EM_REFERENCE_PART)
                {
                    /*
                     * Get the filename.
                     */
                    om_msg = om$send (msg = message EMdescribe.EMget_attr
                                                       (msg,
                                                        "filename",
                                                        EM_PART_ATTR,
                                                        -1,
                                                        &attr),
                                      targetid = instance_attr->part_id->objid,
                                      targetos = instance_attr->part_id->osnum);

                    if (om_msg & *msg & 1)
                    {
                        instance_attr->filename = attr.value.data.s;
                    }
                }
            }
            /* Else if it's a reference part... */
            else if (part_type == EM_REFERENCE_PART) 
            {
                /*
                 * If we have a filename ...
                 */
                if (instance_attr->filename)
                {
                    /*
                     * Create the part defininition from the specified file. 
                     */
		    /*
                     * Added number and revision to the call - 07/03/94, so
                     * that if we know these, we need not open the file to
                     * get them. Also added the return msg check, to make sure
                     * that if the cachepart is existing, take that into a/c.
                     */
                    om_msg = EMcreate_part (msg,
                                            mod_env,
                                            part_type,
                                            instance_attr->props & EM_DISPLAY_PROPS,
                                            instance_attr->props & EM_BEHAVIOR_PROPS,
                                            0,
                                            instance_attr->number,
                                            instance_attr->revision,
                                            instance_attr->filename,
                                            instance_attr->view,
                                            num_common_attrs,
                                            common_attrs,
                                            NULL,
                                            NULL,
                                            &loc_part_id,
                                            &tmp_ref_id);

                    if (*msg == ASM_E_PARTDEFINED)
                    {
                        instance_attr->part_id = &loc_part_id;
                        *msg = ASM_S_SUCCESS;
                    }
                    else if (om_msg & *msg & 1)
                    {
                        instance_attr->part_id = &loc_part_id;
                        part_created = TRUE;
                    }
                }
                else
                {
                    *msg = ASM_E_INVARGS;
                }
            }
            else
            {
                *msg = ASM_E_INVARGS;
            }
        }
        else if ((part_type == EM_REFERENCE_PART) && (instance_attr->filename))
        {
            /*
             * Create the part defininition from the specified file. 
             */
            om_msg = EMcreate_part (msg,
                                    mod_env,
                                    part_type,
                                    instance_attr->props & EM_DISPLAY_PROPS,
                                    instance_attr->props & EM_BEHAVIOR_PROPS,
                                    0,
                                    NULL,
                                    NULL,
                                    instance_attr->filename,
                                    instance_attr->view,
                                    num_common_attrs,
                                    common_attrs,
                                    0,
                                    NULL,
                                    &loc_part_id,
                                    (instance_attr->graphic_ids == NULL) ?
                                    &tmp_ref_id : &ref_id);

            if (*msg == ASM_E_PARTDEFINED)
            {
                instance_attr->part_id = &loc_part_id;
                *msg = ASM_S_SUCCESS;
            }
            else if (om_msg & *msg & 1)
            {
                instance_attr->part_id = &loc_part_id;
                part_created = TRUE;
            }
        }
        else 
        {
            *msg = ASM_E_INVARGS;
        }
    }

    /*
     * If something screwed up ...
     */
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    /*
     * Get a unique name for myself from the part defintion.
     */
    om_msg = om$send (msg = message EMpart.EMget_instancename
                                          (msg, 
                                           desc_attr.directory,
                                           desc_attr.name),
                      targetid = instance_attr->part_id->objid,
                      targetos = instance_attr->part_id->osnum);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Set the properties.
     */
    desc_attr.props = instance_attr->props;

    /*
     * Set the remaining describe stuff.
     */
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
     * Get the seed quantity attribute from the part.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                           "quantity",
                                                           EM_INSTANCE_ATTR,
                                                           -1,
                                                           &attr),
                      targetid = instance_attr->part_id->objid,
                      targetos = instance_attr->part_id->osnum);
                    
    if (!(om_msg & *msg & 1))
    {
        attr.info.type = EM_INSTANCE_ATTR;
        strcpy (attr.info.name, "quantity");
        attr.info.desc[0] = '\0';
        attr.value.type = EM_INTEGER;
        sprintf (attr.value.syntax, "%d", instance_attr->quantity);
        om_msg = OM_S_SUCCESS;
        *msg = ASM_S_SUCCESS;
    }

    /*
     * If the user didn't specify the quantity attribute, add the default.
     */
    if (!EMget_named_attribute ("quantity", 
                                instance_attr->num_attributes, 
                                instance_attr->attributes))
    {
        om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, &attr),
                          targetid = my_id);
    
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }

    /*
     * Copy any instance attributes from the part onto the instance.
     */
    om_msg = om$send (msg = message EMdescribe.EMnum_attrs (msg,
                                                            EM_INSTANCE_ATTR,
                                                            &count),
                      targetid = instance_attr->part_id->objid,
                      targetos = instance_attr->part_id->osnum);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    for (i=0; i<count; ++i)
    {
        om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                               NULL,
                                                               EM_INSTANCE_ATTR,
                                                               i,
                                                               &attr),
                      targetid = instance_attr->part_id->objid,
                      targetos = instance_attr->part_id->osnum);

        if (!(om_msg & *msg & 1))
        {
            continue;
        }
        
        om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, &attr),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            continue;
        }
    }

    /*
     * Do the part specific constructions.
     */
    switch (part_type)
    {  
    case EM_GRAPHIC_PART:
        if (!(instance_attr->origin || instance_attr->matrix))
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }
        
	handle_props = GRIS_NEW;
	if(EM_IS_HANDLE_DISPLAYED(instance_attr->props))
	 {
	    handle_props |= GRIS_DISPLAYABLE | GRIS_LOCATABLE;
         }
        om_msg = EMconstruct_handle 
                                   (msg, 
                                    mod_env,
				    handle_props,
                                    NULL,
                                    instance_attr->origin,
                                    instance_attr->matrix,
                                    &handle_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        handle_created = TRUE;
            
        /*
         * Connect handle to part instance with the name of this
         * instance. This is necessary since the cs uses it's
         * name to display the text.
         */
        memb.type = EM_HANDLE;
        strcpy (memb.name, desc_attr.name);
        memb.desc[0] = '\0';
        memb.id.objid = handle_id.objid;
        memb.id.osnum = handle_id.osnum;
        
        om_msg = om$send (msg = message EMdescribe.EMadd_memb(msg, &memb),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Add the graphic objects to the instance.
         */
        memb.type = EM_GRAPHIC;
        memb.desc[0] = '\0';

        for (i=0; i<instance_attr->num_graphics; ++i)
        {
            sprintf (memb.name, "gr%d", i+1);
            memb.id.objid = instance_attr->graphic_ids[i].objid;
            memb.id.osnum = instance_attr->graphic_ids[i].osnum;

            om_msg = om$send (msg = message EMdescribe.EMadd_memb (msg, &memb),
                              targetid = my_id);
        }

        /* No break intentional. */

    case EM_NONGRAPHIC_PART:
        /*
         * Add the other attributes.
         */
        for (i=0; i<instance_attr->num_attributes; i++)
        {
            /*
             * KLUDGE: Do we have to add only the instance attributes here ??
             */
            om_msg = om$send (msg = message EMdescribe.EMadd_attr
                                     (msg, &(instance_attr->attributes[i])),
                              targetid = my_id);
        }

        break;

    case EM_REFERENCE_PART:
        ref_props = (EM_IS_READONLY(instance_attr->props) ? 
                     GRRF_IS_READ_ONLY :0) |
                    (EM_IS_BACKGROUND(instance_attr->props) ? 
                     GRRF_BACKGROUND : 0) |
                    (EM_IS_DETACHED(instance_attr->props) ?
                     GRRF_UNLOADED : 0) |
                    GRRF_SHRINK_WRAP | GRRF_SAVED_VIEW_USED;

        loc_props = GRIS_NEW |
                    (EM_IS_GRAPHIC_DISPLAYED(instance_attr->props) ?
                     (GRIS_DISPLAYABLE | GRIS_LOCATABLE) : 0);

        if (ref_id.objid == NULL_OBJID)
        {
            /*
             * Construct reference attachment.
             */
            om_msg = EMconstruct_reffile (msg,
                                          mod_env,
                                          instance_attr->filename,
                                          instance_attr->view,
                                          loc_props,
                                          ref_props,
                                          NULL,
                                          instance_attr->origin,
                                          instance_attr->matrix,
                                          &ref_id);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            reffile_created = TRUE;
        }

        /*
         * If the reference file was unloaded.
         */
        if (EM_IS_DETACHED(instance_attr->props))
        {
            om_msg = om$send (msg = message GRreffile.GRrfunload (msg),
                              targetid = ref_id.objid,
                              targetos = ref_id.osnum);
        }

        /*
         * Add reference attachment to part instance.
         */
        memb.type = EM_GRAPHIC;
        strcpy (memb.name, "reffile");
        memb.desc[0] = '\0';
        memb.id.objid = ref_id.objid;
        memb.id.osnum = ref_id.osnum;

        om_msg = om$send (msg = message EMdescribe.EMadd_memb(msg, &memb),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Construct the handle.
         */
        handle_props = GRIS_NEW;
	if(EM_IS_HANDLE_DISPLAYED(instance_attr->props))
	 {
	    handle_props |= GRIS_DISPLAYABLE | GRIS_LOCATABLE ;
         }

        om_msg = EMconstruct_handle (msg,
                                     mod_env,
				     handle_props,
                                     NULL,
                                     instance_attr->origin,
                                     instance_attr->matrix,
                                     &handle_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        handle_created = TRUE;
        
        /*
         * Add handle to part instance with the name of this
         * instance. This is necessary since the cs uses it's
         * name to display the text.
         */
        memb.type = EM_HANDLE;
        strcpy (memb.name, desc_attr.name);
        memb.desc[0] = '\0';
        memb.id.objid = handle_id.objid;
        memb.id.osnum = handle_id.osnum;

        om_msg = om$send (msg = message EMdescribe.EMadd_memb(msg, &memb),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Add the other attributes.
         */
        for (i=0; i<instance_attr->num_attributes; i++)
        {
            if (instance_attr->attributes[i].info.type == EM_INSTANCE_ATTR)
            {
                om_msg = om$send (msg = message EMdescribe.EMadd_attr
                                  (msg, &(instance_attr->attributes[i])),
                                  targetid = my_id);

                if (!(om_msg & *msg & 1))
                {
                    om_msg = om$send (msg = message EMdescribe.EMmod_attr
                                      (msg, 
                                       instance_attr->attributes[i].info.name,
                                       EM_INSTANCE_ATTR,
                                       -1,
                                       &instance_attr->attributes[i]),
                                      targetid = my_id);
                }
            }
        }

        break;
        
    default:
        *msg = ASM_E_ABORT;
        break;
    }

quit:

    /*
     * If the part had to be created delete the temporary
     * reference file attachement.
     */
    if (part_created)
    {
        if (tmp_ref_id.objid != NULL_OBJID)
        {
            om$send (msg = message GRgraphics.GRdelete (&ok, mod_env),
                     targetid = tmp_ref_id.objid,
                     targetos = tmp_ref_id.osnum);
        }
    }

    /*
     * If something went wrong ...
     */
    if (!(om_msg & *msg & 1))
    {
        /*
         * If we had to created a part.
         */
        if (part_created)
        {
            /*
             * Delete it ...
             */
            om$send (msg = message EMdescribe.EMdelete (&ok),
                     targetid = loc_part_id.objid,
                     targetos = loc_part_id.osnum);
        }
        
        /*
         * If we created a reference file ...
         */
        if (reffile_created)
        {
            /*
             * Delete it ...
             */
            om$send (msg = message GRgraphics.GRdelete (&ok, mod_env),
                     targetid = ref_id.objid,
                     targetos = ref_id.osnum);
        }
        
        /*
         * If we created a handle ...
         */
        if (handle_created)
        {
            /*
             * Delete it ...
             */
            om$send (msg = message GRgraphics.GRdelete (&ok, mod_env),
                     targetid = handle_id.objid,
                     targetos = handle_id.osnum);
        }

        if (initialized)
        {
            /*
             * Finally delete me.
             */
            om$send (msg = message GRgraphics.GRdelete (&ok, mod_env),
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

    /*
     * Free the common attributes memory
     */
    if (common_attrs)
        free (common_attrs);

    return (om_msg);
}

end implementation EMinstance;

