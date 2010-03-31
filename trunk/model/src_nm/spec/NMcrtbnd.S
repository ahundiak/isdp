class specification NMcrtbnd (1:0) of CObuild;

# include "igrtypedef.h"
# include "OMlimits.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "ex.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "griodef.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
#include "EMSdpb.h"

instance NMcrtbnd
 {
  struct GRevent                locate_event;
  struct GRevent                first_bound_event;
  struct GRlc_stack 		locate_stack;
  struct EMdpbinfo              dpb_info;
  IGRboolean                    associative_flag;
  variable struct GRlc_info 	cvs[20];
  int				numsf, totalcvs;
  variable struct GRlc_info 	sf[5];
  variable int			numcv_persf[5];
  variable IGRboolean		points[5];
  int				num_gluesf;
  variable struct GRid		glue_sf[5];
  IGRboolean			glue_set_shown;
  struct GRid			construct_id;
 };
 
override wakeup, execute, sleep, delete;

end specification NMcrtbnd;

