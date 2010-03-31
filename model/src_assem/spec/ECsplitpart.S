class specification ECsplitpart (0:1) of COpara;

#include "codef.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "grio.h"
#include "lc.h"
#include "DIdef.h"



instance ECsplitpart
{
  variable struct GRid  obj_list[1];
  IGRlong  num_obj;
  IGRchar  filename[DI_PATH_MAX];
  IGRchar  seedfile[DI_PATH_MAX];
  IGRchar  *split_form_ptr;
  IGRboolean delete;
  struct GRevent event1;
  struct GRevent event2;
  struct GRevent event3;
};

override 

  init,
  wakeup,
  sleep,
  execute,
  delete,
  status_disp;

message form_notification(int form_label,label;double value; char *fp;
			  int init_notf);

end specification ECsplitpart;
