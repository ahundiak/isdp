/* #######################    APOGEE COMPILED   ######################## */
class specification GRlnterm (1:1) of GRlistener,GRcmpowner;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"

instance GRlnterm
{
    struct GRevent   attach_event;
    IGRshort         end_of_curve;            /* first or last pt in curve */
    channel {(many_to_many, rel_ordered, initial=2, increment=2)} to_notify;
};

/* override NDcompute_node; */

override GRnotifylis,GRlocate_owner;
message GRlnterminit(IGRlong         *msg; 
                     struct GRid     *element; 
    	             struct GRevent  *accept_event;
                     struct GRmd_env *ModuleInfo;
                     struct GRid     *cell_id);

end specification GRlnterm;
