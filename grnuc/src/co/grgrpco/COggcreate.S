/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COggcreate

Description
   This method implements the create graphic group command.

History
   HGW 05/14/86 : Creation Date
   HGW 06/17/86 : Changed to new locate.
   mrm 10/01/86 : OM 4.0 conversion
   mrm 12/31/86 : Convert to use graphics sets
   HGW 12/17/87 : Changes for version 1.1
*/

class specification COggcreate (0:5) of COroot;

#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "exmacros.h"
#include "growner.h"
#include "grgs.h"

instance COggcreate
{
   IGRint                create_flag;  /* set for graphic group creation */
   IGRint                event_on_q;   /* set if a event is put on queue */
   IGRint                init_success; /* set if TRUE is successful init */
   IGRint                locate_state; /* state internal to locate       */
   IGRshort              gg_properties;/* Graphic group properties       */
   struct GRevent        locate_point; /* Event used in locate           */
   struct GRlc_stack     locate_stack; /* locate stack                   */
   struct GRlc_locate    attr;         /* locate attr eg class, level    */
   struct GRvg_construct constr;       /* construction arguments         */
   variable struct GRobj_env  object_array[];

   channel
   {
     (rel_ordered,
      many_to_many,
      initial=1,
      increment=1)                      /* channels to graphic group and */
   }                     to_gg, to_gs;  /* graphic set                   */
};

override init, execute, delete;

end specification COggcreate;
