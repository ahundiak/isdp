/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COggadd

Description
   This command class will add elements to an existing graphic group.

History
   HGW 05/14/86 : Creation Date
   HGW 06/23/86 : Change for new locate and exec
   HGW 08/01/86 : Changed names from complex to graphic group.
   mrm 10/01/86 : OM 4.0 conversion
   mrm 12/31/86 : Convert to use graphics sets
   HGW 09/30/87 : Changes for version 1.1
*/

class specification COggadd (0:5) of COroot;

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
#include "growner.h"
#include "grgs.h"

instance COggadd
{
   IGRboolean           mod_flag;     /* display in all views for locate */
   IGRint               event_on_q;   /* set if a event is put on queue  */
   IGRint               init_success; /* set if TRUE is successful init  */
   IGRint               locate_state; /* internal to locate              */
   OMuword              classes[3];   /* Locate classes                  */
   struct GRevent       locate_point; /* Event used in locate            */
   struct GRlc_locate   gg_attr;      /* locate attr for gg              */
   struct GRlc_locate   ele_attr;     /* locate attr for element         */
   struct GRlc_stack    locate_stack; /* locate stack                    */
   OM_S_CLASSLIST       eligible_classes; /* eligible classes            */
   variable struct GRobj_env  object_array[];
   channel
   {
    (rel_ordered,
     many_to_many,                    /* channels to graphic sets for    */
     initial = 1,                     /* the graphic group and graphics  */
     increment = 1)                   /* objects                         */
   } to_gg_gs, to_gs_gs;
};

override init, execute, delete;

end specification COggadd;
