class specification COchexp (0:1) of COroot;
 
#include "expression.h"
#include "codef.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dp.h" 
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "grio.h"
#include "lc.h"

instance COchexp
{
  struct  GRevent     Event;     
  struct  GRid        locate_param; 

  IGRchar                loc_prompt[MAX_PROMPT_SIZE];   /* locate prompt */
  IGRchar                acc_prompt[MAX_PROMPT_SIZE];   /* accept prompt */
  IGRchar                reloc_prompt[MAX_PROMPT_SIZE];/* relocate prompt */
  IGRboolean             input_requested;
  struct    GRlc_locate  attr;      /* locate attr eg class, level */
  struct    GRlc_stack   locate_stack; /* stack for the locate filter */
  IGRint              action;       /* an action to be performed */
};

override
  init,
  wakeup,
  execute;

end specification COchexp;
