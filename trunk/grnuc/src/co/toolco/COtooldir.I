/* #######################    APOGEE COMPILED   ######################## */
/******************************************************************************

Methods:

    path
    cd

Description:    

    The method path constructs a system path from the specified name.

    The method cd changes directory to the specified directory.

History:    

    jay wallingford     10/15/89    creation date
						  
Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/
class implementation COtools;

#include <coimport.h>
#include <DItypedef.h>
#include <DIdef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <comiscmac.h>

method cd ( IGRchar * dirname )
{
    di$cd ( dirname = dirname );
    return (OM_S_SUCCESS);
}

method path (IGRchar * name; 
            IGRchar * path )
{
    IGRint size, nret, msg;
    struct GRmd_env mod_env;

    /*
     * Get the current module enviroment.
     */
    size = sizeof ( struct GRmd_env );
    gr$get_module_env ( msg = &msg,
                        sizbuf = &size,
                        buffer = &mod_env,
                        nret = &nret );
    
    /*
     * Get the system path.
     */
    di$give_pathname (osnum = mod_env.md_id.osnum,
                      pathname = path );

    /*
     * Tack on the file/dir path.
     */
    strcat (path, name);

    return(OM_S_SUCCESS);
}
                  
end implementation COtools;

