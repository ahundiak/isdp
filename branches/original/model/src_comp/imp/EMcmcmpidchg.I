/*
 Description

 This method is sent to an owner when one of it's children has
 changed object id's.  Examples of operations which do this are
 split, partial delete, fragment, etc..

 The default owner action (inherited from GRowner) reconnects the
 children on to the to_components channel.  This is OK for flexible
 owners like graphic groups but is not appropriate for rigid owners.
 As a rigid owner I must know that my child has changed since only
 I could have asked it to do so.

 Simply put there is nothing I should do when a child tells me that
 he has changed id's.

 History

 08/05/88 : rlw : Creation date

 */

class implementation EMScomposite;

#include "EMScc.h"
#include "msdef.h"

method GRcomponent_idchanged(
 IGRlong *msg;
 IGRshort *num_comp_ids;
 struct GRid *comp_ids)
{
 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}

end implementation EMScomposite;
