/*
Name
        GRptlnproc

Description
        This file contains the methods GRptprocess and GRlnprocess for
        the class GRowner.  They are overridden to provide more
        efficient proximity checks for location of owners which are in
        the Rtree (ie top-down locate).  Each component will be passed
        the GR__process method until an object passes the proximity
        check or all components are exhausted (locate is tiring work!).

History
        mrm     04/16/91    creation
                04/22/91    always return OM_S_SUCCESS from GRownptlnproc
*/

class implementation GRowner;

#include "msdef.h"
#include "grerr.h"

IGRint GRownptlnproc(msg, objid, proc_msg)
IGRlong *msg;
OM_S_OBJID objid;
OM_p_MESSAGE proc_msg;
{
    IGRint i = 0, sts = OM_S_SUCCESS;
    OM_S_CHANSELECT to_comp;

    *msg = GR_I_OUTSIDE_TOL;
    GRget_to_comp_chansel(&to_comp);
    do
    {
        sts = om$send(msg = proc_msg,
                      senderid = objid,
                      p_chanselect = &to_comp,
                      from = i,
                      to = i);
        i++;
    } while ((sts & *msg & 1) && (sts != OM_I_CHAN_EMPTY) && (*msg != MSSUCC));

    return(OM_S_SUCCESS);
}

method GRptprocess(IGRlong *msg; IGRshort *mxtype;
                   IGRmatrix mx; IGRdouble *acctol; 
                   IGRpoint pt, projpt; struct GRparms *projparms)
{
    return(GRownptlnproc(msg, my_id, OPPmargs));
}

method GRlnprocess(IGRlong *msg; IGRshort *mxtype;
                   IGRmatrix mx; IGRdouble *acctol;
                   struct IGRline *line; IGRpoint linept, projpt;
		   IGRdouble *t; struct GRparms *projparms)
{
    return(GRownptlnproc(msg, my_id, OPPmargs));
}

end implementation GRowner;
