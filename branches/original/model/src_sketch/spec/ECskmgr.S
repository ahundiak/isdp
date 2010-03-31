class specification ECskmgr (2:0) of ECelements;

#include "FI.h"

instance ECskmgr
{
  IGRboolean is_vg;
  Form       form_ptr;
  int        auto_mask;
};

override init, wakeup, super_cmd.sleep, execute, get_locate_criteria,
         status_disp, delete;

message do_form (long *msg; int GadgetLabel);

end specification ECskmgr;
