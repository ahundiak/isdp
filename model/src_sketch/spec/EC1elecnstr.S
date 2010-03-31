class specification EC1elecnstr (1:0) of super_cmd;

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igrtypedef.h"
#include "igrdef.h" 
#include "igr.h"
#include "igrdp.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSdpb.h"

instance EC1elecnstr
  {
  struct GRmd_env active_md_env;
  struct GRevent locate_event;
  struct GRlc_stack locate_stack;

  IGRboolean two_elements, use_event;
  struct GRlc_info parmele;
  struct GRevent otherele_event;
  
  IGRchar accept_prompt[GR_MAX_CHAR];
  };
 
override init, wakeup, execute;

end specification EC1elecnstr;

