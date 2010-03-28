/* #######################    APOGEE COMPILED   ######################## */
/******************************************************************************

Methods:

    access_file
    open_file
    close_file

Description:    

    These methods check access, open and close a files.

History:    

    jay wallingford     04/10/89    creation date
						  
Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COtools;

#include <coimport.h>
#include <stdio.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <comiscmac.h>
#include <OMlimits.h>

method access_file ( IGRint * msg;
                     IGRint mask;
                     IGRchar * name;
                     IGRchar * path )
{
    IGRint mode;

    COtool_access_file ( &mode, name, path );

    /*
     * If the file doesn't exist check to see if it is the 
     * current file.
     */
    if ( !(mode & CO_file_exists) )
    {
        struct GRmd_env mod_env;
        IGRint size, nret;
        IGRchar s1[OM_K_MAXOSNAME_LEN], s2[OM_K_MAXOSNAME_LEN];
        struct EX_var_list ex_var[2];

        /*
         * Get the current module enviroment.
         */
        size = sizeof ( struct GRmd_env );
        gr$get_module_env ( msg = msg,
                            sizbuf = &size,
                            buffer = &mod_env,
                            nret = &nret );

        /*
         * Get the expanded name for the input file.
         */ 
	if ( EX_use_default_dir () )
	{
            size = sizeof ( s1 );

            ex_var[0].var = EX_WORKING_DIR;
            ex_var[0].var_value = s1;
            ex_var[0].num_bytes = &size;
            ex_var[1].var = NULL;

            ex$global ( var = ex_var,
                        which_error = &nret );
        }
        else
        {
            strcpy(s1, getenv("PWD"));
            strcat(s1, "/");
        }
        strcat(s1, name);

        module_build_path(s1);

        /*
         * Get the os name for the current module enviroment.
         */
        om$os_number_to_name ( osnum = mod_env.md_id.osnum,
                               osname = s2 );

        /*
         * If the input file is the same as the current os
         * then allow all requested permissions.
         */
        if ( !strcmp(s1, s2) || !strcmp(name,s2) ) mode = mask;
     }

    *msg = ((mask & mode) == mask) ? MSSUCC : MSFAIL;

    return OM_S_SUCCESS;
}

method open_file ( IGRint * msg;
                   IGRchar * name;
                   IGRchar * op )
{
    if (name)
    {
        *msg = ( me->fp = (char *)fopen ( name, op ) ) ? MSSUCC : MSFAIL;
    }
    else
    {
        me->fp = (char *)stdout;
        *msg = MSSUCC;
    }

    return OM_S_SUCCESS;
}

method close_file ()
{
    if (me->fp != (char *)stdout)
    {
        fclose((FILE *) me->fp);
    }
    
    return OM_S_SUCCESS;
}

end implementation COtools;


