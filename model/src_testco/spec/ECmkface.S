/* ###################   APOGEE COMPILED   ################## */
class specification ECmkface (1:0) of CObuild;

/* lc.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef OMlimits_include
# include "OMlimits.h"
# endif

# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

# ifndef lcdef_include
# include "lcdef.h"
# endif

# ifndef lc_include
# include "lc.h"
# endif

# ifndef lcmacros_include
# include "lcmacros.h"
# endif

/* end of lc.h replacement */

#include "EMSdpb.h"

instance ECmkface
 {
  struct        GRevent         locate_event;
  struct        GRlc_stack      locate_stack;
  variable struct GRlc_info     locobj[20];
  struct        GRlc_info       srf_info;
  struct        GRid            active_state_GRid;
  struct        GRid            mkface_obj_GRid;
  struct        EMdpbinfo       dpb_info;
  IGRboolean                    associative_flag;
  IGRint                        numcrv;
  IGRlong                       process_phase;
 };
 
override wakeup, execute, sleep;

end specification ECmkface;
