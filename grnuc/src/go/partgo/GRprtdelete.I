/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <DIprims.h>

/*
 * Method : 
 *
 *      GRdelete
 *
 * Abstract :
 *
 *	This routine deletes the part and also makes sure that
 *      any attributes shared by other parts are disconnected
 *      before the part is deleted.
 *
 * Arguments :
 *
 *      *msg    IGRlong     Completion code.
 *      *info   GRobj_info  Structure for information about 
 *                          the object
 * Return Values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *      Jamal Shakra        08/15/91 Modify data.
 *
 */
method GRdelete ( IGRlong * msg; struct GRmd_env * mod_env )
{
    IGRint          om_msg = OM_S_SUCCESS;
    struct GRid     part;
    IGRchar         partdir[DI_PATH_MAX], path[DI_PATH_MAX];
    IGRint          count = 0;
    
    *msg = MSSUCC;
        
    part.objid = my_id;
    part.osnum = OM_Gw_current_OS;

    /*
     * If this isn't a delete of a dynamic copy ...
     */
    if (mod_env->md_id.objid != NULL_OBJID)
    {
        /*
         * Make sure it's ok with PDM to delete this part.
         */
        if (!PDMpre_delete(&part, mod_env))
        {
            om_msg = OM_E_ABORT;
            *msg = MSFAIL;
            goto quit;
        }
    }
    
    /*
     * Determine the number of parts of this type.
     */
    if ( GRpart_get_count ( partdir, &part, &count ) )
    {
        /*
         * Delete myself.
         */
        om_msg = om$send ( msg = message ACdiowner.GRdelete ( msg, 
                                                              mod_env ),
                           mode = OM_e_wrt_message,
                           targetid = my_id );

        /*
         * Remove all synonym (or links) in the directory system.
         *
         * KLUDGE: This should be put in the ACdiowner class's GRdelete
         *         method so synonym (links) will be removed.
         */
        while (di$untranslate(objname = path, objid = my_id) == DIR_S_SUCCESS)
        {
            di$rmdir ( dirname = path );
        }
        
        /*
         * If this was the last part of this type, 
         * delete the part directory.
         */
        if ( count == 1 )
        {
            di$rmdir ( dirname = partdir );
        
            /* check to see if the part dir is the last part in the catalog 
               dir, if so, delete the catalog dir */
            count = 0;
            *((IGRchar *)strrchr(partdir,':')) = '\0';
            if ( !(GRpart_get_count ( partdir, NULL, &count )) )
               {
                di$rmdir ( dirname = partdir );
               } 
            
        }
    }

    if (om_msg & *msg & 1)
    {
        /*
         * If this isn't a delete of a dynamic copy ...
         */
        if (mod_env->md_id.objid != NULL_OBJID)
        {
            /*
             * Notify EDM of deletion.
             */
            PDMpost_delete (&part, mod_env);
        }
    }
    
 quit:
    
    return (om_msg);
}

end implementation GRpart;

