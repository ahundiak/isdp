/* ###################   APOGEE COMPILED   ################## */
class specification ECdlift (1:0) of COconst;

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

#include "EMSlift.h"
#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"

instance ECdlift
{
  struct    GRevent               locate_event;
  struct    GRlc_stack            locate_stack;
  struct    GRlc_info             sf_info;
  struct    GRid                  active_state_GRid, 
                                  locmod_obj_GRid;
  IGRpoint                        from_pt, to_pt, sf_nrml;
  struct  EMSdlft_info            dlift_info;
  variable struct EMSdlft_lp_info lps_info[];
  variable struct EMSdlft_ed_info eds_info[];
  variable struct GRevent         d_angle_mem[];
  struct GRevent                  event_magnatude_mem, 
                                  sf_d_angle_mem;
  IGRint                          cur_lp, cur_ed,
                                  last_state_processed,
                                  last_dangle_state_processed,
                                  last_fillet_state_processed;  
  IGRboolean                      sf_hi, single_sf_lift, 
                                  associative, pos_mag_outside;
 };
 
override wakeup, execute, sleep;

end specification ECdlift;
