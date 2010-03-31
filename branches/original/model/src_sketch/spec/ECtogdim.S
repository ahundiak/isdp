class specification ECtogdim (1:0) of COconst;

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

instance ECtogdim
  {
  struct        GRevent         locate_event;
  struct        GRlc_stack      locate_stack;
  struct        GRlc_info       ele_info;
  };
 
override execute;

end specification ECtogdim;
