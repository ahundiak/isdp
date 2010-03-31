class specification RFactref (1:0) of super_cmd;

#include "stdio.h"
#include "FI.h"
#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "igrdef.h"
#include "lcdef.h"
#include "lc.h"


instance RFactref
{
  Form form;
  int form_displayed;
  int form_finished;
  struct GRevent locate_event, acc_event;
  struct GRlc_stack locate_stack;

  struct GRid rfhead;
};

message rfform_notification(int f_label; int g_label; double value; Form fp);

override
   init,wakeup,execute;

end specification RFactref;
