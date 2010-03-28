/* #######################    APOGEE COMPILED   ######################## */
class implementation  GRcoxhatch;

#include "coimport.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "exdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"


method GRxhget_gg(IGRlong         *msg; 
                  struct GRid      *xhatch_gg)
{
  IGRlong                      status;   
  OM_S_CHANSELECT              chansel;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  status = om$make_chanselect(chanaddr     = &me->to_components,
   		              p_chanselect = &chansel );

  status = om$get_objid_at_index (objid = my_id, 
				  p_chanselect = &chansel,
				  index = 0, 
				  objidaddr = &xhatch_gg->objid, 
				  osnumaddr = &xhatch_gg->osnum);

  if( ! (status & 1)) *msg = MSFAIL;
  return(status);
}

end implementation GRcoxhatch;




