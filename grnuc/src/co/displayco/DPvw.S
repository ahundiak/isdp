class specification DPvw (1:0) of CEO_LOCATE, IGEwinsup;

#include <stdio.h>
#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "FI.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"

#include "DPview.h"

instance DPvw
{
   IGRint               ref_plane_lock_mode;
   struct DPbase_gg_t	*base_p;	/* original view parm */
   struct DPview_wrk_t  *wrk_p;	/* working variable   */
   struct DPpyramid_t   *pyrmd_p;	/* pyramid structure  */
};


override pre_delete;
override status_disp;
message COcomm_init(IGRlong *msg;);
message COcomm_wakeup(IGRlong *msg;); /* wake up process common for all viewing commands */
message COcomm_sleep(IGRlong *msg;); /* sleep process common for all viewing commands */


end specification DPvw;


