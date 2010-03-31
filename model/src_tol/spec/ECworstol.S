/* ###################   APOGEE COMPILED   ################## */
class specification ECworstol(1:0) of COconst;

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

instance ECworstol
 {
  struct        GRevent         locate_event;
  struct        GRlc_stack      locate_stack;
  struct        GRlc_info       ele1_info;
  IGRint                        num_located;
  IGRint                        form;
  IGRint                        form_num;
  IGRint                        num_loc;
  IGRboolean                    form_requested;


  IGRint                        driven_dim_type;
  IGRchar                       driven_dim_name[20];
  IGRdouble                     driven_dim_value;
  IGRdouble                     driven_dim_hi_tol;
  IGRdouble                     driven_dim_lo_tol;
  IGRdouble                     driven_dim_moments[4];
  IGRdouble                     driven_dim_percent_rej;
  IGRdouble                     worst_case_driven_dim_val1;
  IGRdouble                     worst_case_driven_dim_val2;


  variable struct GRlc_info     ele2_info[2];
  variable struct GRid          driving_dim_grid[2];
  variable IGRint               driving_dim_type[2];
  variable IGRchar              *driving_dim_name[2];
  variable IGRdouble            driving_dim_value[2];
  variable IGRdouble            driving_dim_hi_tol[2];
  variable IGRdouble            driving_dim_lo_tol[2];
  variable IGRdouble            driving_dim_sensitivity[2];
  variable IGRdouble            driving_dim_percentage_contrb[2];
  variable IGRdouble            driving_dim_sgma[2];

  variable IGRdouble            worst_case_driving_dim_val1[2];
  variable IGRdouble            worst_case_driving_dim_val2[2];

  variable IGRint               driving_dim_selected[2];

 };
 
 message update_status_form();
 message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);

/* overrides */

override
delete,
init,
execute,
sleep,
wakeup,

status_disp;

end specification ECworstol;
