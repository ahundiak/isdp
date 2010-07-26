class specification COwnarea (1:0) of COwndmnpl;



#include <stdio.h>
#include <FI.h>

#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "igrdp.h"


instance COwnarea
{
   struct GRevent       first_event;
   struct GRevent       *events[2];
   struct GRid		src_window;   /* the window fence is on */
				     /* display can be on other windows */

   struct DPele_header  element; 
   struct IGRpolyline	fence; 
   IGRdouble		fence_p[15];  /* for 5 points, (wld) */

   IGRint		fence_exists;     /* TRUE or FALSE */

   IGRdouble		wld_to_view[16];  
   IGRdouble		view_to_wld[16];

   IGRint		ref_plane_lock_mode;
};


override dynamics;

message erase_fence ();

message store_fence1 ();

message store_fence2 ();

message dp_fence (IGRlong *msg; IGRdouble *point; );

message fence_zoom ();

message my_init ( long * sts );

message my_wakeup ( long * sts );

message my_sleep ( long * sts );

end specification COwnarea;
