/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COggremove

Description
   This command will remove elements from a graphic group.

History
   mrm     12/31/86    creation
   hgw     03/09/87    include file changes
   hgw     12/17/87    Changes for version 1.1
\*/

class specification COggremove (0:5) of COroot;

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
#include "grsymdef.h"
#include "grsym.h"

instance COggremove
{
   IGRint               event_on_q;   /* set if an event is put on queue*/
   IGRint               init_status;  /* set if init is successful      */
   IGRint               locate_state; /* internal to locate             */
   OMuword              classes[3];   /* Locate classes                 */
   struct GRevent       locate_point; /* event used in locate           */
   struct GRlc_stack    locate_stack; /* locate stack                   */
   struct GRlc_locate   gg_attr;      /* locate attributes for gg       */
   struct GRlc_locate   ele_attr;     /* locate attributes for element  */
   OM_S_CLASSLIST       eligible_classes;
                                      /* eligible classes for gg locate */
   struct GR_gg_member_action_args    loc_gg_mem; 
                                      /* locate gg component args       */
   channel
   {
    (rel_ordered,
     many_to_many,                    /* channels to graphic sets for */
     initial = 1,                     /* the graphic group and graphic */
     increment = 1)                   /* objects */
   }  to_gg_gs, to_gs_gs;
};

override init, execute, delete;

end specification COggremove;
