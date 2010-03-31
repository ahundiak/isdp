class implementation NMstartup;

#include "igr.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "griodef.h"
#include "exdef.h"
#include "nm.h"
#include "griodef.h"

extern struct NMgmssi_cache NMnonmanigm_ssi_cache;
/*extern IGRboolean _new_sfsfint_math;*/

method execute(int *response; char *response_data; int pos)
{

 NMnonmanigm_ssi_cache.elemid.objid = NULL_OBJID;
 NMnonmanigm_ssi_cache.is_valid  = FALSE;
 /*************** New math has now been fixed
 _new_sfsfint_math = 0;
 UI_status("Old math routine active");
 sleep(2);
 UI_status("");
 ****************/
 *response = TERMINATE;
 return(OM_S_SUCCESS);
}

end implementation NMstartup;
