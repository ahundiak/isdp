/*
Name
        GRdpb$GRcheck_class

Description
        This method checks a classid against the classlists representing
        objects that are ineligible for locate.  A return msg of TRUE
        indicates that the classid is eligible for locate; FALSE
        indicates that it is not. 

History
        rc      ??/??/??    creation
        mrm     05/01/91    2.0 changes
*/

class implementation GRdpb;

#include "OMmacros.h"
#include "lcmacros.h"
#include "lcdef.h"

method GRcheckclass(IGRlong *msg; OMuword classid)
{
    IGRint nclasslists, sts, i;
    struct GRelclass *p;

    *msg = TRUE;
    nclasslists = om$dimension_of(varray = me->elclass);

    for (i = 0; i < nclasslists; i++)
    {
        /*
            If the properties indicate this entry has been turned off,
            and it has a genuine classlist, check it against the input
            class.  If this were an owner category that does not have a
            real classlist associated with it, the macro lc$classchek
            would say that the class passed the check and the object
            would be rejected, when in fact it should still be eligible. 
        */

        if (!(me->elclass[i].properties & DPB_LOCATABLE) &&
              me->elclass[i].classlist.w_count)
        {
            /*
                Fix the pointer in the OM_S_CLASSLIST structure.  This
                is necessary because VLA's can move in memory without
                the object being notified. 
            */

            p = &me->elclass[i];
            p->classlist.p_classes = &me->classids[p->index];

            /*
                Check the classid against the list of classes which
                has been turned off.  If the classid fails to pass
                the check, set the return code and return.
            */

            if (lc$classchek(rc = &sts,
                             classid_to_check = classid,
                             eligible_classes = &p->classlist,
                             mode = LC_NO_DPB))
            {
                *msg = FALSE;
                break;
            }
        }
    }
    return (OM_S_SUCCESS);
}

end implementation GRdpb;
