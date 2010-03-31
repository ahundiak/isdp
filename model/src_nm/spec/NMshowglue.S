class specification NMshowglue (1:0) of ECelement;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "OMlimits.h" 
#include "dp.h"         /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"
#include "EMSdpb.h"

instance NMshowglue
{
 IGRboolean	dpb_edge_locate_flag;
};

override init, wakeup, sleep, delete, execute;

end specification NMshowglue;
