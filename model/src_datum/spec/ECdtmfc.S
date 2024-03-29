/* ###################   APOGEE COMPILED   ################## */
class specification ECdtmfc (1:0) of ECelement;

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
#include "FI.h"

instance ECdtmfc
 {
  IGRint options;
  IGRint num_hilited;
  IGRboolean is_associative;
  IGRboolean ref_plane_identified;
  IGRboolean form_displayed;
  Form          form;
  struct        GRevent         locate_event;
  struct        GRlc_stack      locate_stack;
  struct        GRlc_info       elems[5];
 };
 
message do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
                IGRdouble value);

message is_status_form_valid(IGRint *valid);

override 
  init, 
  sleep, 
  wakeup, 
  status_disp, 
  delete;
                

end specification ECdtmfc;
