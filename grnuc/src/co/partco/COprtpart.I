/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <DIprims.h>
#include <DImacros.h>

from GRpart import GRget_attribute;

IGRint COpart_get_parts_func ( msg, 
                               mod_env,
                               parts_dir, 
                               catalog, 
                               part,
                               number,
                               revision,
                               description,
                               quantity,
                               num )
    IGRint          *   msg;
    struct GRmd_env *   mod_env;
    IGRchar         *   parts_dir;
    IGRchar         *   catalog;
    struct GRid     *   part;
    IGRchar         **  number;
    IGRchar         **  revision;
    IGRchar         **  description;
    IGRint          *   quantity;
    IGRint          *   num;
{
    IGRint              om_msg = OM_S_SUCCESS;
    struct GRmd_env     module_buffer;
    IGRchar             pwd[DI_PATH_MAX];
    IGRint              count, true_count, i, index;
    IGRchar             partdir[DI_PATH_MAX];
    IGRchar             partslist_buffer[DI_PATH_MAX]; 
    IGRint              buffersize, nret;
    struct GRid         part_id;

    *msg = MSSUCC;

    /*
     * If the module enviroment is not supplied get it.
     */
    if (!mod_env)
    {
        mod_env = &module_buffer;
        buffersize = sizeof (struct GRmd_env);
        gr$get_module_env ( msg = msg,
                            sizbuf = &buffersize,
                            buffer = &mod_env,
                            nret = &nret );    
    }

    /*
     * If the parts directory is not specified use the default.
     */
    if ( !parts_dir )
    {
        parts_dir = partslist_buffer;
        GRpart_get_default_parts_dir (mod_env, parts_dir);

    /*
     * If the catalog directory is not specified use the default.
     */
        if ( !catalog )
        {
            GRpart_get_default_catalog_dir (mod_env,parts_dir);
        }

        else
        {
            strcat(parts_dir,":");
            strcat(parts_dir,catalog);
        }
    }
    
    /*
     * Save the current directory.
     */
    di$pwd ( dirname = pwd );
    
    /*
     * Change to the parts directory.
     */
    if ( di$cd ( dirname = parts_dir ) == DIR_S_SUCCESS)
    {
        /*
         * If just the num is specified, get the number of part types
         * in the parts directory.
         */
        if ( !part && !number && num ) 
        {
            di$ls ( ptr = num );
        }
        else /* Get the partslist information. */
        {
            /*
             * For all the entries in the parts directory.
             */
            di$start_ls ( ptr = &count );
        
            for (i=0, true_count = 0; i<count; ++i)
            {
                /*
                 * Get the next part directory name.
                 */
                if ( di$fetch_ls ( line = partdir, index = i ) == DIR_S_SUCCESS )
                {
                    /*
                     * Get a representative part.
                     */
                    if ( di$index ( dirname = partdir,
                                    index = 0, 
                                    p_objid = &part_id.objid,
                                    p_osnum = &part_id.osnum ) == DIR_S_SUCCESS )
                    {
                        /*
                         * If part list was specified set the id of the
                         * representative part.
                         */
                        if (part) part[true_count] = part_id;
                                
                        /*
                         * If part number was specified get the part number
                         * from the representative part.
                         */
                        if (number) 
                        {
                            index = -1;
                            om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                         ( (long *)msg, 
                                                           NUMBER_NAME, 
                                                           &index, 
                                                           number[true_count],
                                                           NULL ),
                                               senderid = NULL_OBJID,
                                               targetid = part_id.objid,
                                               targetos = part_id.osnum );
                        }
                                                               
                        /*
                         * If part revision was specified get the part revision 
                         * from the representative part.
                         */
                        if (revision) 
                        {
                            index = -1;
                            om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                         ( (long *)msg, 
                                                           REVISION_NAME, 
                                                           &index, 
                                                           revision[true_count],
                                                           NULL ),
                                               senderid = NULL_OBJID,
                                               targetid = part_id.objid,
                                               targetos = part_id.osnum );
                        }
                                                               
                        /*
                         * If part description was specified get the part 
                         * description from the representative part.
                         */
                        if (description)
                        {
                            index = -1;
                            om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                         ( (long *)msg, 
                                                           DESCRIPTION_NAME, 
                                                           &index, 
                                                           description[true_count],
                                                           NULL ),
                                               senderid = NULL_OBJID,
                                               targetid = part_id.objid,
                                               targetos = part_id.osnum );
                        }

                        /*
                         * If quantity was specified get the number of parts
                         * in the partdir.
                         */
                        if (quantity)
                        {
                            di$strcat (to = partdir, from = "*");
                            di$ls ( regexp = partdir,
                                    ptr = &quantity[true_count] );
                        }
                    
                        /*
                         * If everything went ok bump up the count of part types.
                         */
                        if (om_msg & *msg & 1) ++true_count;
                    }
                }
            }
        
            if ( num ) *num = true_count;
        }

       /*
         * Change back to the saved directory.
         */
        di$cd ( dirname = pwd );
    }
    else 
    {
        if (num) *num = 0;
        else *msg = MSFAIL;
    }

    return (om_msg);
}

end implementation COpart;
