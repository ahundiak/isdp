/*
 *  class       : ECblendsf
 *  
 *  abstract:
 *    this command generates a blend surface between two surfaces. 
 *  
 *  overridden messages: 
 *  
 *    execute:  
 *      user
 *  
 *  instance data:
 *  
 *    events -
 * 
 */ 

class specification ECblendsf (1:0) of super_cmd; 

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "exdef.h"
#include "ex.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dpdef.h"
#include "dp.h"
#include "lcdef.h"
#include "lc.h"

#include "EMSblend_sf.h"
#include "saved_blend.h"
#include "ecbls_for.h"
#include "ecbls_inf.h"

/**      GWERNER        **/
/*..# include "HDcmd.h"  */
/*..# include "HDmsg.h"  */


# define MAX_NUM_EVENTS 9


instance ECblendsf
{
  IGRint            source;                 /*  source surface index  */
  IGRint            wrk_mode;               /*  0 = create / 1 = ext modify */
  IGRint            cv_flag1, cv_flag2;     /*  int blend curve flag  */
  IGRint            dir_flag1, dir_flag2;   /*  int blend tangent dir flag  */

  struct GRlc_info  curve1, curve2;

  struct GRmd_env   cur_module_info_sf1, cur_module_info_sf2;
  struct GRid       cur_grid_sf1, cur_grid_sf2;

  struct GRid       blend_grid;
  OMuint            blend_tag;

  struct GRlc_stack locate_stack;
  struct GRevent    locate_event[MAX_NUM_EVENTS+1];
  struct GRevent    accept_event[MAX_NUM_EVENTS+1];


          
  GRobjid           last_surface_1, last_surface_2;
  IGRboolean        global_assoc_flag;
  IGRint            bl_sf_control;     /*  parallel modify blend control  */


  struct HDbd_form_sf_p  HDbd_f_par;   /*  modify control values  (Form)  */

  IGRboolean        modify;            /*  true if in modify mode  */
  IGRint            number_modify;
  IGRint            last_modify_sts;   /*  status of last executed modify  */

  IGRdouble         rot_mat[9];        /*  start view rot matrix   */
  IGRdouble         disp_fakt;         /*  start view zoom faktor  */

  /*  main basic surface info  */
  struct EMSblend_sf_end_condition  b_start_cond;
  struct EMSblend_sf_end_condition  b_ende_cond;

  struct HDbd_ext_inf               b_start_inf;
  struct HDbd_ext_inf               b_ende_inf;

  IGRint             indx_sf1, indx_sf2,     /*  selection index  */
                     indx_cv1, indx_cv2, 
                     indx_pa1, indx_pa2,
                     indx_ve1, indx_ve2;
 

  /*  last saved parameter lists of blend  */
  struct saved_blend                last_blend;  
  struct saved_blend                last_but_one_blend; 

};


override
  init,
  wakeup,
  sleep,
  execute,
  delete,
  status_disp;


end specification ECblendsf;
