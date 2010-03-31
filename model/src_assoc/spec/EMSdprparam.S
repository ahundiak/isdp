/* ###################   APOGEE COMPILED   ################## */
class specification EMSdprparam (3:0) of GRowner;
/*
Abstract
    This is the class to support storage of parameters during the update of a 
    DPR tree.

Notes
    This is an instanciated class.
    This class should only be temporary in the filed space.

History
    DLB     01/14/91    Creation.
*/

#include "EMSmsgdef.h"
#include "emserr.h"
#include "EMSdpr.h"

instance EMSdprparam
{
  IGRint                 display_count;
  OM_S_OBJID             *display_ids;       
  IGRint                 num_compute_info;
  struct EMScompute_info *compute_info;
  IGRint                 num_chg_ids;
  GRobjid                *chg_ids;
  unsigned char          status;
};

override GRvg;

message EMinit(IGRlong           *EMmsg;
               IGRushort option;
               GRobjid           top_state_id);

message EMput_display_ids(IGRlong           *EMmsg;
                          IGRint            num_display_ids;
                          GRobjid           *display_ids;
                          IGRushort options);

message EMget_display_ids(IGRlong           *EMmsg;
                          IGRint            *num_display_ids;
                          GRobjid           **display_ids;
                          IGRushort options);

message EMput_compute_info(IGRlong                *EMmsg;
                           IGRint                 num_compute_info;
                           struct EMScompute_info *compute_info;
                           IGRushort      options);

message EMget_compute_info(IGRlong                *EMmsg;
                           IGRint                 *num_compute_info;
                           struct EMScompute_info **compute_info;
                           IGRushort      options);

message EMdisplay(IGRlong                *EMmsg;
                  struct GRmd_env        *env;
                  IGRushort      options);

message EMdelete(IGRlong                *EMmsg;
                 IGRushort      options);
  
message EMputGetChangedId(IGRlong *EMmsg; IGRint  *num_ids; GRobjid **ids;
                          IGRushort options);

message EMsetStatus(IGRlong *EMmsg; IGRboolean clear; OMuword status);

message EMgetStatus(IGRlong *EMmsg; OMuword *status);

override
    GRlocate_owner,
    debug;

end specification EMSdprparam;
