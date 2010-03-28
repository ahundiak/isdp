/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <OMmacros.h>
#include <DIprims.h>
#include <DImacros.h>
#include <grownerdef.h>
#include <partdef.h>

/*
 * Method :
 *
 *      GRchg_part
 *
 * Abstract :
 *
 *      This routine changes a part to a new part type.
 *  
 * Arguments :
 *
 *      *msg    IGRlong     Completion code.
 *      *number IGRchar     Part number.
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      jay wallingford     3/9/90  Creation data.
 *      Jamal Shakra        08/14/91 Modify date.
 */
method GRchg_part ( IGRlong *   msg;
                    IGRchar *   catalog; 
                    IGRchar *   number;
                    IGRchar *   revision )
{
    IGRint  om_msg = OM_S_SUCCESS;
    OMuword osnum;
    GRobjid objid;
    IGRchar mydir[DI_PATH_MAX], partdir[DI_PATH_MAX];
    IGRchar new_mydir[DI_PATH_MAX], new_partdir[DI_PATH_MAX], 
            numrev[DI_PATH_MAX];
    IGRchar attr[MAX_ATTR], value[MAX_VALUE];
    IGRint  type, i, is_template=0, index;
    struct GRid template;

    *msg = MSSUCC;
   
    /*
     * Get my directory, my part directory and my new part directory.
     */
    di$untranslate ( objid = my_id, objname = mydir );
    strcpy (partdir, mydir);
    *((IGRchar *)strrchr(partdir,':')) = '\0';
    strcpy (new_partdir, partdir);
    *((IGRchar *)strrchr(new_partdir, ':')) = '\0';

    /*
     * Construct the catalog directory, if catalog is specified. 
     */
    if (catalog)
     {
      di$strcat (to = new_partdir, from = catalog);
     }

    else
     {
      di$strcat (to = new_partdir, from = "local");
     }

    /*
     * Construct number!revision directory, if revision is specified. 
     */
    if ( (revision) && (number) )
     {
      sprintf(numrev,"%s!%s" ,number ,revision);
      di$strcat (to = new_partdir, from = numrev);
     }

    osnum = OM_Gw_current_OS;
        
    /*
     * If the new parts directory is not found make it.
     */
    if ( di$translate ( objname = new_partdir,
                        osnum = osnum,
                        p_objid = &objid ) != DIR_S_SUCCESS )
    {
        strcat (new_partdir, ":");

        /*
         * di$mkpath will construct all directories nessesary
         * to get the part directory including the partslist
         * directory.
         */
        if ( di$mkpath ( pathname = new_partdir,
                         p_osnum = &osnum ) != DIR_S_SUCCESS )
        {
            *msg = MSFAIL;
        }
        else
        {
            *((IGRchar *)strrchr(new_partdir,':')) = '\0';

            is_template = FALSE;
        }
    }
    else
    {
        /*
         * Try to find a template in the new part directory.
         */
        is_template = ( di$index ( dirname = new_partdir,
                                   index = 0,
                                   p_objid = &template.objid,
                                   p_osnum = &template.osnum )
                        == DIR_S_SUCCESS );
    }

    if (*msg & 1)
    {
        /*
         * Get a new name for myself.
         */
        GRpart_get_partname ( new_partdir, new_mydir );
        di$rename (oldname = mydir, newname = new_mydir);
        
        /*
         * If there are no other objects in the old part directory
         * delete it.
         */
        if ( di$index ( dirname = partdir,
                        index = 0,
                        p_objid = &objid,
                        p_osnum = &osnum ) != DIR_S_SUCCESS )
        {
            di$rmdir ( dirname = partdir );
        }

        /*
         * Make sure I have the correct part number.
         */
        index = -1;
        attr[0] = '\0';
        om_msg = om$send ( msg = message GRpart.GRget_attribute ( msg,
                                                                  NUMBER_NAME,
                                                                  &index,
                                                                  value,
                                                                  NULL ),
                           targetid = my_id );
             
        /*
         * If the part number has not already been changed ...
         */
        if ((om_msg & *msg & 1) && strcmp(value, number))
        {
            om_msg = om$send ( msg = message ACdiowner.ACmod_attribute 
                                                               ( msg,
                                                                 attr,
                                                                 number ),
                               mode = OM_e_wrt_message,
                               targetid = my_id );
        }

        if ((om_msg & *msg & 1) && is_template)
        {
            /*
             * Copy/update attributes from the template object.
             */
            om_msg = om$send ( msg = message GRpart.GRcopy_attributes 
                                        ( msg, 
                                          &template,
                                          GR_COMMON_ATTR | GR_DYNAMIC_ATTR ),
                               targetid = my_id );
               
            /*
             * If there are any GR_COMMON_ATTR attributes on myself which
             * are not on the template, make those attributes GR_DYNAMIC_ATTR.
             */
            for (i=0; i<me->nb_attr; ++i)
            {
                /*
                 * Get my attribute at index i.
                 */
                attr[0] = '\0';
                om_msg = om$send ( msg = message GRpart.GRget_attribute 
                                                                    ( msg,
                                                                      attr,
                                                                      &i,
                                                                      value,
                                                                      &type ),
                                   targetid = my_id );
                                  
                if ((om_msg & *msg & 1) && (type & GR_COMMON_ATTR))
                {
                    /*
                     * See if the template has this attribute.
                     */
                    om_msg = om$send ( msg = message GRpart.GRget_attribute 
                                                                    ( msg,
                                                                      attr,
                                                                      NULL,
                                                                      value,
                                                                      &type ),
                                       targetid = template.objid,
                                       targetos = template.osnum );

                    /*
                     * If it doesn't make this attribute a dynamic attribute.
                     */
                    if (!(om_msg & *msg & 1))
                    {
                        me->attr_type[i] = GR_DYNAMIC_ATTR;
                    }
                }
            }
        }
    }

    return (om_msg);
}

end implementation GRpart;

