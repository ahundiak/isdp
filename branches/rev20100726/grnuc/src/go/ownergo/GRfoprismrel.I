/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRprismrel_owner

Description
   This method determines the relationship of a curve prism or a 
   right prism to an owner object. The type of prism is determined
   from the input variable, type prism.  

   *msg           IGRlong        completion code
   *mx_type       IGRshort       type of matrix
   matrix         IGRmatrix      environment matrix
   *prism_rel     IGRlong        If NULL then return true relationship
                                 of the object to the prism; else return
                                 the relationship that is being checked
                                 The flags for checking are defined in
                                 grgsdef.h
                                    -  TRUE_REL
                                    -  GO_INSIDE
                                    -  GO_OUTSIDE
                                    -  GO_OVERLAP
                                    -  GO_INSIDE | GO_OVERLAP
                                    -  GO_OUTSIDE | GO_OVERLAP
   *component_id  struct GRid    If NULL then ignore, if not NULL then
                                 contians the object id of a component
                                 which has already responded to the
                                 GRprismrel method.
   *component_rel IGRlong        The relationship of the component to
                                 the right prism
                                    0 - component is outside prism 
                                    1 - component is inside prism
                                    2 - component overlaps prism
                                    3 - not requested relationship
   *type_prism    IGRshort       Type of prism 
                                    0 - right prism
                                    1 - curve prism
   *prism         IGRchar        The right or curve prism
   *relationship  IGRlong        The relationship of the curve to
                                 the right prism
                                    0 - curve is outside prism 
                                    1 - curve is inside prism
                                    2 - curve overlaps prism

Notes
   This method is a super set of the GRprismrel method.  This method
   allows the relationship of a component to be passed into the method.

Return Values
    MSSUCC - successful completion
    MSFAIL - error occured
    GR_E_INV_REQUEST - requested relationship was not met
\*/

class implementation GRflxown;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "grgsdef.h"
#include "grerr.h"
#include "gocmacros.h"

method GRprismrel_owner (IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
                         IGRlong *prism_rel; struct GRid *component_id;
                         IGRlong *component_rel; IGRshort *type_prism;
                         IGRchar *prism; IGRlong *relationship)
{
    IGRlong     om_msg;
    IGRshort    prop;

    *msg = MSSUCC;
    om_msg = om$send ( msg = message GRowner.GRget_owner_properties ( msg, 
                                                                      &prop), 
                       targetid = my_id);

    if (prop & GR_SPATIAL) 
    {

      /*
       *  If I am spatial then call my owners method to determine my
       *  relationship.
       */
      om_msg = om$send (mode = OM_e_wrt_message,
                        msg = message GRowner.GRprismrel_owner (msg, 
                                                                mx_type, 
                                                                matrix, 
                                                                prism_rel, 
                                                                component_id, 
                                                                component_rel, 
                                                                type_prism, 
                                                                prism, 
                                                                relationship),
                        targetid = my_id);
    }
    else 
    {
        /* 
         *  If I am logical then return not the requested relationship.
         */
        *msg = GR_E_INV_REQUEST;
        om_msg = OM_S_SUCCESS;
    }
    return (om_msg);
}      
end implementation GRflxown;
