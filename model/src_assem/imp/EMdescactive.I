class implementation EMdescribe;

#include <grimport.h>
#include <DIprims.h>
#include <OMmacros.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_active                                                      |
 |                                                                           |
 | This method returns whether the part is active or not.                    |
 |                                                                           |
 | Output:  IGRlong    * msg         Return code.                            |
 |          IGRboolean * active      Part active?                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_active (IGRlong * msg; IGRboolean * active)
{
    *msg = ASM_S_SUCCESS;

    *active = (me->props & EM_DESCRIBE_ACTIVE);

    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_active                                                      |
 |                                                                           |
 | This method sets whether the part is active or not.                       |
 |                                                                           |
 | Input:   IGRboolean   active      Make part active?                       |
 |                                                                           |
 | Output:  IGRlong    * msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_active (IGRlong * msg; IGRboolean active)
{
    IGRchar name[DI_PATH_MAX];
    
    /*
     * If the part is being made active ...
     */
    if (active)
    {
        /*
         * Get it's name ...
         */
        if (di$untranslate (objid = my_id,
                            osnum = OM_Gw_current_OS,
                            objname = name) != DIR_S_SUCCESS)
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }
        
        /*
         * And make it the working directory.
         */
        if (!(di$cd (dirname = name) & 1))
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }

        me->props |= EM_DESCRIBE_ACTIVE;
    }
    else /* Deactivation */
    {
        struct GRid dir_id;
        
        /*
         * Get the current working directory.
         */
        if (!(di$pwd (p_dirid = &dir_id.objid,
                      p_osnum = &dir_id.osnum,
                      dirname = name) & 1))
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }
        
        /*
         * If I'm still the current directory, change directory
         * to someplace else ...
         */
        if ((dir_id.objid == my_id) &&
            (dir_id.osnum == OM_Gw_current_OS))
        {
            /*
             * Get the name of the "usr" directory ... ughhh!
             */
            if (!(di$give_pathname (osnum = OM_Gw_current_OS,
                                    pathname = name) & 1))
            {
                *msg = ASM_E_ABORT;
                goto quit;
            }
            
            strcat (name, ":usr");
            
            /*
             * This is ugly. We should figure out 
             * another way of deactivating a description.
             */
            if (!(di$cd (dirname = name) & 1))
            {
                /*
                 * Make the "usr" directory.
                 */
                if (!(di$mkdir (dirname = name,
                                osnum = OM_Gw_current_OS) & 1))
                {
                    /* 
                     * We're screwed!
                     */
                    *msg = ASM_E_ABORT;
                    goto quit;
                }
                
                if (!(di$cd (dirname = name) & 1))
                {
                    *msg = ASM_E_ABORT;
                    goto quit;
                }
            }
        }

        me->props &= ~EM_DESCRIBE_ACTIVE;
    }
    
 quit:
    
    return OM_S_SUCCESS;
}

end implementation EMdescribe;




