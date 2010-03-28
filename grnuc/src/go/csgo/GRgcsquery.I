/*
Name
        GRcsmgr.GRget_query_info

Description
        This method takes a coordinate system type and returns the number
        of user inputs required and a pointer to an array of input information
        structures. Each input information structure has a prompt, its 
        corresponding input mask, and a default value.  This input information
        is stored at the individual coordinate system class level, such as
        GRgencs.

Synopsis
        IGRlong *msg            O   return code
                                        MSSUCC - successful completion
                                        MSINARG - invalid cstype
        IGRchar *cstype         I   type of coord sys, e.g. "rectangular",
                                    "spherical", "cylindrical"
        IGRshort *num_inputs    O   number of input values required
        struct GRcsquery_info **query_info  O   ptr to query information

History
        kt      10/20/86    design and implementation
        mrm     12/31/92    changed to use GRget_cstype_info & 
                            GRget_csquery_info
*/

class implementation GRgencs;

#include "grimport.h"
#include "grmessage.h"
#include "msdef.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "cspriv.h"
#include "gocmacros.h"

extern struct GRcstype_info *GRget_cstype_info();
extern struct GRcsquery_info *GRget_csquery_info();

method GRget_query_info (IGRlong *msg;
                         IGRchar *cstype;
                         IGRshort *num_inputs;
                         struct GRcsquery_info **query_info)
{
    IGRint i;
    struct GRcstype_info *p_cstypes;
    struct GRcsquery_info *p_queryinfo;

    *msg = MSINARG;
    p_cstypes = GRget_cstype_info();
    p_queryinfo = GRget_csquery_info();

    for (i = 0; i < NUM_CS_TYPES; i++)
    {
        if (!strncmp(cstype, p_cstypes[i].cstype, strlen(cstype)))
        {
            *msg = MSSUCC;
            *num_inputs = p_cstypes[i].num_inputs;
            *query_info = &p_queryinfo[p_cstypes[i].index_into_query_table];
            break;
        }
    }
    return (OM_S_SUCCESS);
}

end implementation GRgencs;
