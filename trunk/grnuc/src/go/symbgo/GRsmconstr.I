/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRsmhdr.GRconstruct

Description
        This routine initializes a symbol header object.

Synopsis
        struct GRvg_construct *arglist      standard argument list

Return Values
        MSSUCC    - if successful
        MSFAIL    - if failure

History
        DEM     07/07/86    Design date and Creation date.
        HGW     07/21/86    Added code for display attributes and properties.
        HGW     08/07/86    Changed terminology.
        HGW     11/06/87    Changes for version 1.1
*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "grerr.h"
#include "OMerrordef.h"
#include "grownmacros.h"

method GRconstruct (struct GRvg_construct *arglist)
{
    IGRlong              sts;        /* return code                  */
    GRobjid              new_id;     /* for post method              */
    struct GRsymbology   symb;       /* symbology of object          */
    struct GRpost_info   info;       /* for post method              */

    *arglist->msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  Initialize the graphics objects properties and set the is new bit.
     */
   
    me->properties = arglist->properties | GRIS_NEW;

    /*
     *  Initialize the symbol reference properties to be zero.
     */

    me->owner_properties = 0;

    /*
     *  If display attributes are defined then add them to the
     *  the symbol reference else add the level to the symbol 
     *  reference.  Note that the put symbology method will change 
     *  the symbol properties.
     */

    if (arglist->display)
    {
        symb.level = arglist->level;
        symb.display_attr = *arglist->display;
        sts = om$send (msg = message GRvg.GRputsymb (arglist->msg, &symb),
                       targetid = my_id);

    }
    else
    {
        sts = om$send (msg = message GRvg.GRchglevel
                            (arglist->msg, &arglist->level),
                       targetid = my_id);
    }

    if (sts & 1)
    {
        if (arglist->name)
        {
           sts = om$send (msg = message GRvg.GRputname
                               (arglist->msg,arglist->name),
                          targetid = my_id);
        }

        if (sts & 1)
        {
            info.construct_flag = TRUE;
            sts = om$send (msg = message GRvg.GRpostabsg
                                (arglist->msg, arglist->env_info,
                                 &info, arglist->geometry, &new_id), 
                           targetid = my_id);
        }
    }

    /*
     * see if we succeeded, and if not, delete object
     */

    if (!(sts & *arglist->msg & 1))
    {
        sts = OM_E_ERROR;
        om$send (msg = message Root.delete (NULL), targetid = my_id);
    }
    else
    {
        om$send (msg = message GRowner.GRadd_to_active_owner
                      (arglist->msg, arglist->env_info),
                 targetid = my_id);
    }
    return (sts);
}
end implementation GRsmhdr;
