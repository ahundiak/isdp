/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRgraphics
     METHOD NAME: GRcptform

     Abstract: 
                This method copies and transforms an object.
-----
%SC%    

     GRcptform(msg,md_env,matrix,new_dsenv,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env      GRmd_env       original object's context info
     matrix       IGRmatrix      transformation matrix to be applied
                                 to copy
     *new_dsenv   GRmd_env       copied object's context info
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *newobjid    GRobjid        object id of copy
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:   none.

     Methods:   GRcopy
                GRxform
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.

-----
%CH%

     CHANGE HISTORY:
        
        KMO     03/19/86 : Creation date.
        KMO     03/27/86 : Design date.
        JHW     07/12/89 : Added call to gr$add_to_active_owner.
        AIC     01/03/92 : Handle case in which copy doesn't copy, but
                           returns success. Clean up error handling.
        HGB     08/06/93 : replace if (status & 1) goto wrapup by
                                   if (!(status & 1)) goto wrapup so that
                           the call to gr$add_to_active_owner is made.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
        This method copies the input object and transforms
        the copy using the input transformation matrix.
----*/
/*EH*/

class implementation GRgraphics;

#include "msdef.h"
#include "OMmacros.h"
#include "grownmacros.h"

method GRcptform(IGRlong *msg; struct GRmd_env *obj_dsenv;
                 IGRmatrix matrix; struct GRmd_env *new_dsenv;
                 GRobjid *newobjid)
{
    IGRshort    mx_type;

    IGRlong     status;                 /* method return status */
    GRobjid     internal_id = NULL_OBJID;
    struct GRmd_env local_env;

    /* initialize variables */

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    local_env = *new_dsenv;
    local_env.md_id.objid = NULL_OBJID;

    status = om$send(msg = message GRgraphics.GRcopy(msg, obj_dsenv,
                        &local_env,&internal_id),
                     targetid = my_id);
    if(! (status & 1 & *msg)) goto wrapup;
    if(internal_id == NULL_OBJID) goto wrapup;

    MAtypemx(msg,matrix,&mx_type);

    status = om$send(msg = message GRgraphics.GRxform(msg, &local_env,
                        &mx_type,matrix,newobjid),
                     targetid = internal_id,
                     targetos = local_env.md_id.osnum);

    if(! ( 1 & status & *msg)) goto wrapup;

    /* if the module id is not NULL_OBJID, add the copy to the
     * R-tree.
     */
    if ( !IF_NULL_OBJID(new_dsenv->md_id.objid))
    {
        status = om$send(msg = message GRgraphics.GRaddwrng(msg,new_dsenv),
                         targetid = *newobjid,
                         targetos = new_dsenv->md_id.osnum);
        if (!(status & 1)) goto wrapup;
    }

    gr$add_to_active_owner( msg = msg,
                            mod_env = new_dsenv,
                            osnum = new_dsenv->md_id.osnum,
                            objid = *newobjid );

wrapup:
    return(status);
}

end implementation GRgraphics;
