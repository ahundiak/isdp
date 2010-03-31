class specification ECDfLPrt (1:0) of COpara;

#include "igetypedef.h"
#include "igrtypedef.h"
#include <gr.h>
#include <grdpbdef.h>
#include "assemdef.h"
#include "assem.h"

instance ECDfLPrt
{
    char *fp;                   /* Main form, for part creation */
};

message do_form( IGRlong *msg; int form_label; int gadget_label; double value);

override init,  sleep, wakeup, execute, delete;

end specification ECDfLPrt;
