/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <grownerdef.h>
#include <DIprims.h>

/*
 * Method :
 *
 *      GRdrop
 *
 * Abstract :
 *
 *      This routine deletes all the attribute objects before dropping
 *      the part.
 *  
 * Arguments :
 *
 *      *msg        IGRlong         return code.
 *      *mod_env    struct GRmd_env module environment.
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *      Jamal Shakra        08/15/91 Modification data.
 *
 */
method GRdrop ( IGRlong * msg; struct GRmd_env * mod_env )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    struct GRid     part;
    IGRchar         partdir[DI_PATH_MAX], partname[DI_PATH_MAX];
    IGRint          count = 0, i;
    OM_S_CHANSELECT comp_chan;
                  
    *msg = MSSUCC;
       
    part.objid = my_id;
    part.osnum = OM_Gw_current_OS;

    /*
     * If this isn't a delete of a dynamic copy ...
     */
    if (mod_env->md_id.objid != NULL_OBJID)
    {
        /*
         * Make sure it's ok with PDM to delete the part.
         */
        if (!PDMpre_delete(&part, mod_env))
        {
            om_msg = OM_E_ABORT;
            *msg = MSFAIL;
            goto quit;
        }
    }
        
    GRget_to_comp_chansel ( &comp_chan );
    
    if ( di$untranslate ( objid = my_id,
                          osnum = OM_Gw_current_OS,
                          objname = partname ) == DIR_S_SUCCESS )
    {
        strcpy ( partdir, partname );
        *((IGRchar *)strrchr(partdir, ':')) = '\0';

        /*
         * Determine the number of parts of this type.
         */
        if ( GRpart_get_count ( partdir, NULL, &count ) )
        {
            /*
             * Delete all the attribute id's from this part. 
             */
            for (i=me->nb_attr-1; i>=0; --i)
            {
                om$send ( msg = message Root.delete (1),
                          p_chanselect = &comp_chan,
                          from = me->attr_def[i].index,
                          to = me->attr_def[i].index );
            }                                    
              
            /*
             * Unlink myself before dropping.
             */
            DIunlink_dir ( partname, 1 );

            /*
             * If this was the last part of this type, delete the 
             * part directory.
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

            om_msg = om$send ( msg = message GRowner.GRdrop ( msg, mod_env ),
                               mode = OM_e_wrt_message,
                               targetid = my_id );
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
             * Notify PDM of part deletion.
             */
            PDMpost_delete (&part, mod_env);
        }
    }
    
 quit:
    
    return (om_msg);
}

end implementation GRpart;
