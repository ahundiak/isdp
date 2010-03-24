/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:38:41 $
$Locker:  $
*/

class implementation IGEuserramp;

#include "igrtypedef.h"
#include "GRtypedef.h"
#include "OMminimum.h"
#include "wl.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h";

method get_sim_user_ramp(
   IGRint *which_color_ramp;  
   IGRint *num_shades;  
   IGRint **packed_shades )
{
   return( TRUE );
}

end implementation IGEuserramp;

