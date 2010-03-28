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


method GRxhupdate_definition(IGRlong                *msg; 
                             struct GRxhatchpat     *pattern_def)
{
  IGRlong                      status;   

  status = OM_S_SUCCESS;
  *msg = MSSUCC;



  return(status);
}

end implementation GRcoxhatch;



