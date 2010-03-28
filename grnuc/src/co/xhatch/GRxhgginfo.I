/* #######################    APOGEE COMPILED   ######################## */
class implementation  GRxhgg;

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
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  
  IGRlong                      status;   

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  ex$message(msgnumb = GR_I_CrosshatchingGG, buff = info->type);

/*  strcpy(info->type,"Crosshatching graphics group"); */

  return(status);
}

end implementation GRxhgg;

