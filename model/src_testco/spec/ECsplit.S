/* ###################   APOGEE COMPILED   ################## */
class specification ECsplit (1:0) of COconst;

# include "igr.h"
# include "gr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "go.h"
# include "lcdef.h"
# include "griodef.h"
# include "grio.h"
# include "lc.h" 

instance ECsplit
{
  variable   IGRdouble parms[2]; /* vla of u or v parameters   */
  IGRint     num_states;         /* total num of active states */
  IGRint     option;             /* 0 = U direction; 1 = V direction */
  IGRint     num_parms;          /* number of parms have so far */
  GRobjid    isocrv_id;          /* extracted curve id */

  struct EX_button  saved_event;  /* saved point for dx keyin use */
  struct GRevent    event;        /* locate and get events */
  struct GRevent    event1;       /* accept event of locate */
  struct GRlc_stack locate_stack; /* for locate purposes */
  struct GRlc_info  surf_info;    /* surface locate information */

  struct GRid       active_state_GRid; /* active id when command starts */
  struct GRid       top_lm_GRid;       /* lm id on top of lm stack */
  struct GRid       split_obj_GRid;    /* split face dpr id */

  variable struct GRid state_list[]; /*VLA of active states*/

  IGRboolean have_owner;         /* surface owned by a composite */
  IGRboolean obj_hilited;        /* surface is hilited */
  IGRboolean iso_displayed;      /* iso curve is displayed */
  IGRboolean top_lm_active;      /* dpr tree was undone to top lm */

};

override execute, wakeup, sleep, delete;

end specification ECsplit;
