class specification ECsplitlprt (0:1) of COpara;

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
#include "assemdef.h"
#include "assem.h"



instance ECsplitlprt
{
  struct GRid    local_part;
  IGRchar        *split_form_ptr;
  IGRchar        *status_form_ptr;
  IGRchar        filename[DI_PATH_MAX];
  IGRchar        seedfile[DI_PATH_MAX];
  IGRboolean     delete;
  IGRboolean     place_part;
  struct GRid    view_id;
  IGRint         num_attrs;
  variable EMattr attrs[1];
};

override 

  init,
  wakeup,
  sleep,
  execute,
  delete,
  status_disp;

message split_form_notify(int form_label,label;double value; char *fp;
			  int init_notf);

message status_form_notify(int form_label,label;double value; char *fp;
			  int init_notf);

end specification ECsplitlprt;
