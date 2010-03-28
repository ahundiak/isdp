class specification COrevcell (1:0) of CEO;



#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMindex.h"
#include "gr.h"


instance COrevcell
{
    IGRint                          count, changes;
    IGRint                          delete_count;
    IGRint                          form_state;
    IGRint                          row;
    struct GRmd_env                 asl_env;
    variable OM_S_BTREE_CONTENTS    symlibobjs[];
    variable GRobjid                delete_object[];
};


message init_instance ();

message fill_in_form ();

override form_notification;

end specification COrevcell;
