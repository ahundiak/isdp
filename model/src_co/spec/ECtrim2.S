/*
 *  class       : ECtrim2
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

class specification ECtrim2 (1:0) of COnpt;

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


instance ECtrim2
{
  IGRint            save_state;
  IGRdouble         loc_tol_old;
  struct GRevent    locate_event;
  struct GRevent    accept_event;
  struct GRlc_stack locate_stack;

  struct GRid       last_extend_ele1,   last_extend_ele2;
  IGRpoint          last_extend_1_from, last_extend_1_to,
                    last_extend_2_from, last_extend_2_to;

  struct GRmd_env   module_info_u, module_info_b;

  OM_S_OBJID        saved1_objid, saved2_objid;

  struct GRparms geom_parms_b;
};

override 
  init,
  wakeup,
  sleep,
  execute,
  delete;

end specification ECtrim2;

