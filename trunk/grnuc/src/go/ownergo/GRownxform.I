/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRxform
    
Description
    This method sends a message to each of its components to transform
    themselves by the given matrix.  If the object changed classes during
    the transformation then it should still be a component of the owner.

    *msg         IGRlong          Completion code
    *mod_env     struct GRmd_env  Module environment structure 
    *matrix_type IGRshort         The type of the matrix
    matrix       IGRmatrix        The given transformation matrix
    *newobjid    GRobjid          Objid of the transformed object

Notes
    This method calls the GRxform_owner message which will allow the
    owner to transform any geometry.  Then depending on the return
    the message can be fowarded to all the children.

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn 09/08/87      Coding Date
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

extern IGRint   GRget_to_comp_chansel();

method GRxform( IGRlong *msg; 
                struct GRmd_env *mod_env; 
                IGRshort *matrix_type; 
                IGRmatrix matrix; 
                GRobjid *newobjid)
{
    IGRlong           om_msg;
    IGRint            cont;
    GRobjid           temp_objid;
    OM_S_CHANSELECT   chansel;
    struct GRmd_env   local_mod_env;

    *msg = MSSUCC;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        /*
         *  Transform the owner object.
         */
        om_msg = om$send( msg = message GRowner.GRxform_owner ( msg, 
                                                                mod_env, 
                                                                matrix_type,
                                                                matrix, 
                                                                newobjid, 
                                                                &cont),
                          targetid = my_id);

        /*
         *  If the continue flag is set then send the xform to all the 
         *  components.
         */
        if ((om_msg & *msg & 1) && cont) 
        {
            om_msg = om$send (msg = message GRowner.GRget_context (msg, 
                                                                   mod_env,
                                                                   &local_mod_env), 
                              targetid = my_id);

            /* 
             *  Transform the components by the matrix.
             */
            om_msg = om$send(msg = message GRgraphics.GRxform ( msg, 
                                                                &local_mod_env, 
                                                                matrix_type, 
                                                                matrix, 
                                                                &temp_objid),
                             p_chanselect = &chansel);
        }

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_XFORMED);
    }

    return (om_msg);
}

end implementation GRowner;
