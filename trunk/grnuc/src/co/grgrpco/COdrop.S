/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COdrop

Description
   This is the class for the drop grouping command object.  The drop 
   operation is defined as removing the top level of nesting from the
   group.

Notes
   This command will drop the following groupings.
      1)    graphic groups
      2)    symbols
      3)    cells

History
   HGW 05/14/86 : Creation Date
   HGW 06/17/86 : Changed to new locate.
   HGW 08/04/86 : Changed to new terminology.
   mrm 10/01/86 : OM 4.0 conversion
   HGW 12/17/87 : Changes for version 1.1
   Milind 08/28/97 : Channel added for CR# 11893319 - locate Cell using Fence
\*/

class specification COdrop (0:5) of COroot;

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

instance COdrop
{
   OMuword     classid;       /* Locatable classes                   */
   IGRint      event_on_q;    /* Flag set if a event is put on queue */
   IGRint      init_success;  /* Flag set if TRUE is successful init */
   struct GRevent       locate_point; /* Event used in locate        */
   struct GRlc_locate   attr;         /* locate attr eg class, owner */
   struct GRlc_stack    locate_stack; /* locate stack                */
   OM_S_CLASSLIST       eligible_classes;    /* Class structure      */
   channel
   {
    ( rel_ordered,
      many_to_many,
      initial = 1,
      increment = 1)
   } to_cell_ch;


};

override init, execute;

end specification COdrop;
