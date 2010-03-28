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

History
   Gray Winn   11/10/87 : Creation date
\*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgsdef.h"
#include "grerr.h"
#include "gocmacros.h"
#include "bserr.h"

#define  OUTSIDE        0
#define  INSIDE         1
#define  OVERLAPPING    2

method GRprismrel_owner (IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
                         IGRlong *prism_rel; struct GRid *component_id;
                         IGRlong *component_rel; IGRshort *type_prism;
                         IGRchar *prism; IGRlong *relationship)
{
IGRlong           om_msg; 

   om_msg = om$send (mode = OM_e_wrt_message,
            msg = message GRlbsys.GRprismrel (msg, mx_type, matrix,
            prism_rel, type_prism, prism, relationship),
            targetid = my_id);

   return (om_msg);
}
end implementation GRclhdr;
