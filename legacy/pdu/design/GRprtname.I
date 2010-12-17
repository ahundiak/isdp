/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <DIprims.h>
#include <DImacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

/*
 * Method :
 *
 *      GRgetname
 *
 * Abstract :
 *
 *      This method gets the name for the part.
 *
 * Arguments :
 *
 *      *msg              IGRlong            Return code.
 *      name              GRname             Name of the object.
 *
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 *
 * Notes :
 * 
 *      This is a KLUDGE which will not work in all cases!
 */
method GRgetname ( IGRlong * msg; IGRchar * name )
{
    struct GRid my_grid;
    
    *msg = MSSUCC;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    *msg = GRget_part_name (&my_grid, name, 1);

    if (!(*msg & 1)) name[0] = '\0';
        
    return (OM_S_SUCCESS);
}

/*
 * Method :
 *
 *      GRputname
 *
 * Abstract :
 *
 *      This method puts the name for the element in the current directory.
 *
 * Arguments :
 *
 *      *msg              IGRlong            Return code.
 *      name              GRname             Name of the object.
 *
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 *
 * Notes :
 * 
 *      This is a KLUDGE which will not work in all cases!
 */
method GRputname ( IGRlong * msg; IGRchar * name )
{
    IGRint      om_msg = OM_S_SUCCESS;
    IGRchar     real_name[DI_PATH_MAX];

    *msg = MSSUCC;
        
    DIexpanse (name, real_name);

    if ( !GRis_part_name(real_name) )
    {
        if (name[0] != '\0')
        {
            om_msg = di$link ( objid = my_id, newname = real_name );
        }
    }
    else *msg = MSFAIL;
    
    return (om_msg & 1);
}

/*
 * Method :
 *
 *      GRchgname
 *
 * Abstract :
 *
 *      This method changes the name for the element in the current directory.
 *
 * Arguments :
 *
 *      *msg              IGRlong            Return code.
 *      name              GRname             Name of the object.
 *
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 *
 * Notes :
 * 
 *      This is a KLUDGE which will not work in all cases!
 */
method GRchgname ( IGRlong * msg; 
                   struct GRmd_env * env;
                   IGRchar * name )
{
    IGRint  om_msg = OM_S_SUCCESS;
    struct GRid my_grid;
    IGRchar old_name[DI_PATH_MAX], real_name[DI_PATH_MAX];
    
    *msg = MSSUCC;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    /*
     * If this is a PDM part and PDM isn't loaded and this is being done 
     * for undo delete don't allow the name to be changed.
     */
    if (!strncmp(name, ".deleted_", 9) && 
        PDMpart_check(&my_grid))
    {
        goto quit;
    }
    
    DIexpanse (name, real_name);

    if ( !GRis_part_name(real_name) )
    {
        *msg = GRget_part_name (&my_grid, old_name, 1);
        
        if ( !(*msg & 1) || (old_name[0] == '\0') )
        {
            om_msg = di$link ( objid = my_id, newname = real_name );
            *msg = MSSUCC;
        }
        else
        {
            om_msg = di$rename ( oldname = old_name, newname = real_name );
        }
    }
    else *msg = MSFAIL;

 quit:
    
    return (om_msg & 1);
}

IGRint GRis_part_name (name)
    IGRchar * name;
{
    IGRint          msg = MSSUCC, buffersize, nret, len;
    struct GRmd_env mod_env;
    IGRchar         parts_dir[DI_PATH_MAX];

    buffersize = sizeof(struct GRmd_env);
    gr$get_module_env ( msg = &msg,
                        sizbuf = &buffersize,
                        buffer = &mod_env,
                        nret = &nret );
                        
    GRpart_get_default_parts_dir (&mod_env, parts_dir);

    if ( ((len = strlen(parts_dir)) < strlen(name)) &&
         !strncmp(name,parts_dir,len) )
    {
        return (TRUE);
    }
    
    return (FALSE);
}

IGRint GRget_part_name (p_grid, name, synonym)
    struct GRid * p_grid;
    IGRchar     * name;
    IGRint        synonym;
{
    IGRchar parts_dir[DI_PATH_MAX];
    IGRint  i, count, nret, buffersize, msg;
    struct GRmd_env mod_env;
    IGRint  len;

    msg = MSSUCC;
    
    buffersize = sizeof(struct GRmd_env);
    gr$get_module_env ( msg = &msg,
                        sizbuf = &buffersize,
                        buffer = &mod_env,
                        nret = &nret );
                        
    GRpart_get_default_parts_dir (&mod_env, parts_dir);

    len = strlen (parts_dir);
        
    di$start_untrans ( ptr = &count, 
                       objid = p_grid->objid, 
                       osnum = p_grid->osnum);

    if (count > 1)
    {
        for (i=0; i<count; ++i)
        {
            di$fetch_untrans ( objname = name, index = i );

            if ( (synonym && ( (len > strlen(name)) || 
                  strncmp(parts_dir,name,len) ) ) ||
                 (!synonym && ( (len < strlen(name)) && 
                  !strncmp(parts_dir,name,len) ) ) )
            {
                return (MSSUCC);
            }
        }

        msg = MSFAIL;
    }
    else if (synonym) 
    {
        name[0] = '\0';
    }
    else
    {
        di$fetch_untrans ( objname = name, index = 0 );
    }
 
    return (msg);   
}
    
end implementation GRpart;
