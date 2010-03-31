class specification ECblendcv (1:0) of super_cmd;

/*
This command generates a blend curve between two curves.
*/

# include "GRtypedef.h"
# include "gr.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "igrdp.h"
# include "EMSblend_cv.h"
# include "ecblc_for.h"



# define MAX_NUM_EVENTS 4


struct ext_pnt_info
{
    struct GRlc_info    base_crv;        /*  base curve main info            */
    struct GRlc_info    ib_pnt;          /*  internal blend start/end point  */
};




instance ECblendcv
{
  struct GRid       blend_grid;
  OMuint            blend_tag;
  struct GRevent    locate_event[MAX_NUM_EVENTS+1];
  struct GRevent    accept_event[MAX_NUM_EVENTS+1];
  GRobjid           last_curve_1, last_curve_2;
  IGRboolean        internal_1_mode, internal_2_mode;
  IGRboolean        modify;
  IGRint            bl_cv_control;     /*  initial modify blend control  */
  IGRboolean        global_assoc_flag;
  IGRint            last_modify_sts; 
  OMuword           first_cv_classid;
  IGRdouble         rot_mat[9];      /* cur view rotation matrix  */
  IGRdouble         disp_fakt;       /* cur view zoom factor      */

  struct EMSblend_cv_end_condition  b_start_cond,
                                    b_ende_cond;

  /*  external point information  */
  struct ext_pnt_info  ext_pnt1,     /*  start curve related ext point  */
                       ext_pnt2;     /*  end   curve related ext point  */

  /*  modify control values  (Form)  */
  struct HDbd_form_params       HDbd_f_par;
};

override

    init,          /* Justification: Preset last used flags            */
    wakeup,        /* Justification: Display highlighted graphics      */
    sleep,         /* Justifacation: Unhighlight highlighted graphics  */
    execute,       /* Justification: Perform blend                     */
    status_disp,
    delete; 

end specification ECblendcv;
