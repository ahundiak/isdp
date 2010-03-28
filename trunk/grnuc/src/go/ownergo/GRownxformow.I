/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRxform_owner

Description
    This method transforms the geometry of an owner graphics object 
    by a matrix.  

    *msg           IGRlong           completion code
    *obj_dsenv     struct GRmd_env   md_env structure 
    *matrix_type   IGRshort          the type of the matrix
    matrix         IGRmatrix         the given transformation matrix
    *newobjid      GRobjid           objid of the transformed object
    *cont          IGRint            If 1 - pass xform to all objects
                                       0 - do not pass xform to all objects

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    Gray Winn       10/27/87    Coding Date
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"

method GRxform_owner (IGRlong *msg; 
                      struct GRmd_env *mod_env; 
                      IGRshort *matrix_type; 
                      IGRmatrix matrix; 
                      GRobjid *newobjid; 
                      IGRint *cont)
{
    IGRlong  om_msg;

    /*
     *  The newobjid must be assigned in this routine so that
     *  the calling routine may assume that a valid object id
     *  is in newobjid.  Note that this object can not change
     *  classes.
     */
    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;   
    *newobjid = my_id;
    *cont = TRUE;
    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_XFORMED);
    return (OM_S_SUCCESS);
}
end implementation GRowner;
