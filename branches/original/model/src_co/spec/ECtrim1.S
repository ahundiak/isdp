/*
 *  class       : ECtrim1
 *  
 *  abstract:
 *    this command 
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

class specification ECtrim1 (1:0) of COnpt;

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


instance ECtrim1
{
  IGRint            save_state;
  IGRdouble         parm_sel;
  IGRboolean        extend_b_extend;

  struct GRevent    locate_event1,
                    accept_event1,
                    locate_event2, 
                    accept_event2;


  struct GRlc_stack locate_stack;

  struct GRid        saved_ele,
                     last_extend_ele,
                     bound_ele,
                     last_extend_ele1,
                     last_extend_ele2;

  IGRpoint          last_extend_from, last_extend_to;

  struct GRmd_env    module_info_u,
                     module_info_b;

  struct GRparms     geom_parms_b;
};


override 
  init,
  wakeup,
  sleep,
  execute,
  delete;

end specification ECtrim1;

