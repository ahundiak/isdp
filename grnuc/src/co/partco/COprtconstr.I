/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include <DIprims.h>
#include <DImacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include "partmacros.h"

from GRconnector    import GRflexconn;
from GRowner        import GRdrop;
from ACdiowner      import ACadd_component;
from GRgraphics     import GRconstruct, GRdelete;

IGRint  COpart_construct_func ( msg, 
                                mod_env,
                                parts_dir, 
                                catalog,
                                number,
                                revision,
                                description,
                                part,
                                attr, 
                                value,
                                type,
                                num,
                                object, 
                                num_objects,
                                gg_flag )
    IGRint          *   msg;
    struct GRmd_env *   mod_env;
    IGRchar         *   parts_dir;
    IGRchar         *   catalog;
    IGRchar         *   number;
    IGRchar         *   revision;
    IGRchar         *   description;
    struct GRid     *   part;
    IGRchar         *   attr[];
    IGRchar         *   value[];
    IGRint              type[];
    IGRint              num;
    struct GRobj_env    object[];
    IGRint              num_objects;
    IGRint              gg_flag;
{
    IGRint                      om_msg = OM_S_SUCCESS;
    long                        ok;
    IGRint                      i;
    long                        flag = 0, maxi = OM_K_MAXINT;
    struct GRid                 grgrp;
    struct GRvg_construct       arglist;
    struct GRpart_class_attr    part_attr;
    IGRint                      nret, buffersize;
    struct GRmd_env             env_info;

    *msg = MSSUCC;

    /*
     * If the module info was not supplied get the current module.
     */
    if (!mod_env)
    {
        buffersize = sizeof(struct GRmd_env);
        gr$get_module_env ( msg = msg,
                            sizbuf = &buffersize,
                            buffer = &env_info,
                            nret = &nret );
        mod_env = &env_info;
    }

    arglist.msg = (long *)msg;
    arglist.env_info = mod_env;
    arglist.newflag = TRUE;
    arglist.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
    arglist.name = NULL;
    arglist.class_attr = NULL;

    /*
     * If there are objects to add and the graphic group flag is set.
     */
    if ((object && num_objects) && gg_flag)
    {
        /*
         * Construct a group of the graphic objects.
         */
        grgrp.osnum = mod_env->md_id.osnum;
        om_msg = om$construct ( classname = "GRgrgrp",
                                osnum = grgrp.osnum,
                                p_objid = &grgrp.objid,
                                msg = message GRgraphics.GRconstruct(&arglist));

        /*
         * If the construction was successful.
         */
        if ( (om_msg & *msg & 1) && object && num_objects )
        {
            /*
             * Add the components.
             */
            for (i=0; i<num_objects; ++i)
            {
                if (object[i].obj_id.osnum == mod_env->md_id.osnum)
                {
                    /*
                     * Add component to the graphic group.
                     */
                    om_msg = om$send ( msg = message GRconnector.GRflexconn
                                                            ( (long *)msg, 
                                                              &flag,
                                                              &grgrp,
                                                              &maxi, 
                                                              &maxi ),
                                       senderid = NULL_OBJID,
                                       targetid = object[i].obj_id.objid,
                                       targetos = object[i].obj_id.osnum );
                                       
                    if (!(om_msg & *msg & 1)) break;
                }
            }

            if (!(om_msg & *msg & 1)) 
            {
                om$send ( msg = message GRowner.GRdrop ( &ok, mod_env ),
                          senderid = NULL_OBJID,
                          targetid = grgrp.objid,
                          targetos = grgrp.osnum );
            }
        }
    }

    if ( om_msg & *msg & 1 )
    {
        /*
         * Construct the part.
         */
        part->osnum = mod_env->md_id.osnum;
        part_attr.parts_dir = parts_dir;
        part_attr.catalog = catalog;
        part_attr.number = number;
        part_attr.revision = revision;
        part_attr.description = description;
        part_attr.attr = attr;
        part_attr.value = value;
        part_attr.type = type;
        part_attr.num = num;
        arglist.class_attr = (char *)&part_attr;
            
        om_msg = om$construct ( classname = "GRpart",
                                osnum = part->osnum,
                                p_objid = &(part->objid),
                                msg = message GRgraphics.GRconstruct (&arglist));

        /*
         * If the failed ...
         */
        if ( !(om_msg & *msg & 1) )
        {
            /*
             * And a graphic group was constructed ...
             */
            if ((object && num_objects) && gg_flag)
            {
                /*
                 * Drop the graphic group.
                 */
                om$send ( msg = message GRowner.GRdrop ( &ok, mod_env ),
                          senderid = NULL_OBJID,
                          targetid = grgrp.objid,
                          targetos = grgrp.osnum );
            }
        }
        else if (object && num_objects) /* Everything is ok */
        {
            /*
             * If a graphic group was constructed ...
             */
            if (gg_flag)
            {
                /*
                 * Add the graphic group to the part.
                 */                
                om_msg = om$send ( msg = message ACdiowner.ACadd_component
                                                            ( (long *)msg, &grgrp ),
                                   senderid = NULL_OBJID,
                                   targetid = part->objid,
                                   targetos = part->osnum );
            }
            else
            {
                for (i=0; i<num_objects; ++i)
                {
                    /*
                     * Add the graphics to the part.
                     */                
                    om_msg = om$send ( msg = message ACdiowner.ACadd_component
                                                        ( (long *)msg, 
                                                          &object[i].obj_id ),
                                       senderid = NULL_OBJID,
                                       targetid = part->objid,
                                       targetos = part->osnum );

                    if (!(om_msg & *msg & 1)) break;
                }
            }
            
            /*
             * If this failed drop the part.
             */
            if ( !(om_msg & *msg & 1) )
            {
                om$send ( msg = message GRowner.GRdrop (&ok, mod_env),
                          senderid = NULL_OBJID,
                          targetid = part->objid,
                          targetos = part->osnum );
            }
        }
    }

    return(om_msg);
}

IGRint COpart_construct_partslist_func ( msg, 
                                         mod_env,
                                         partslist,
                                         name,
                                         desc,
                                         block,
                                         cols,
                                         attribute,
                                         justification,
                                         text,
                                         line )
    IGRint          * msg;
    struct GRmd_env * mod_env;
    struct GRid     * partslist;
    IGRchar         * name;
    IGRchar         * desc;
    struct GRid     * block;
    IGRint            cols;
    IGRchar        ** attribute;
    IGRchar        ** justification;
    struct GRid     * text;
    struct GRid     * line;

{
    IGRint              om_msg = OM_S_SUCCESS;
    IGRchar             parts_dir[DI_PATH_MAX];
    struct GRmd_env     mod_info;
    IGRchar             buffer[256];
    IGRint              buffersize, nret;
    IGRint              i, j;
    IGRchar             attr_data[50 * MAX_ATTR], * attr[53];
    IGRchar             * value[53];
    IGRint              type[53], * type_p;
    struct GRobj_env    object[100];
    IGRint              num_objects, num_attrs;

    *msg = MSSUCC;

    /*
     * Get the module enviroment if it is not provided.
     */
    if (!mod_env)
    {
        buffersize = sizeof ( struct GRmd_env );
        gr$get_module_env ( msg = msg,
                            sizbuf = &buffersize,
                            buffer = &mod_info,
                            nret = &nret );
                            
        mod_env = &mod_info;
    }

    di$give_pathname ( osnum = mod_env->md_id.osnum,
                       pathname = parts_dir );
    strcpy (buffer, parts_dir);
                               
    /*
     * Make the partslist directory.
     */
    di$strcat ( to = buffer, from = "partslist" );
    di$mkdir ( dirname = buffer );
    
    /*
     *  BLOCKS (next line only)
     */
    di$strcat ( to = parts_dir, from = "blocks" );

    /* 
     * Fill in the attribute/value arrays.
     */
    attr[0] = "name";
    value[0] = (name) ? name : "partslist";
    attr[1] = "desc";
    value[1] = (desc) ? desc : "partslist";
    attr[2] = "cols";
    sprintf(buffer, "%d", cols);
    value[2] = buffer;

    num_attrs = (cols * 2) + 3;
    
    for (i=3,j=0; i<num_attrs; ++i,++j) 
    {
        attr[i] = &attr_data[j * MAX_ATTR];
    }

    for (i=0, j=3; i<cols; ++i, j+=2)
    {
        sprintf(attr[j], "attr%d", i);
        value[j] = attribute[i];

        sprintf(attr[j+1], "just%d", i);
        value[j+1] = justification[i];
    }

    /*
     * Fill in the object enviroment array.
     */
    object[0].obj_id = *block;
    object[0].mod_env = *mod_env;

    for (i=0,j=1; i<cols; ++i,++j)
    {
        object[j].obj_id = text[i];
        object[j].mod_env = *mod_env;
    }

    for (i=0,j=cols+1; i<cols-1; ++i,++j)
    {
        object[j].obj_id = line[i];
        object[j].mod_env = *mod_env;
    }

    num_objects = num_attrs - 3;

    type_p = type;
    
    for (i=0; i<num_attrs; ++i)
    {
        type_p[i] = GR_STATIC_ATTR;
    }
    
    /*
     * Construct the partslist.
     */
    om_msg = co$part_construct ( msg = msg,
                                 mod_env = mod_env,
                                 part = partslist,
                                 catalog = (IGRchar *)NULL,
                                 number = (IGRchar *)NULL,
                                 revision = (IGRchar *)NULL,
                                 description = (IGRchar *)NULL,
                                 parts_dir = parts_dir, 
                                 attr = attr,
                                 value = value,
                                 type = type_p,
                                 num = num_attrs,
                                 object = object,
                                 num_objects = num_objects,
                                 gg_flag = TRUE );
    return (om_msg);
}

end implementation COpart;
