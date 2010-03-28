/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This is the class for the convert symbol reference to symbol
   command object.

History
   HGW 07/29/86 : Creation Date
   HGW 07/29/86 : Changed to new locate.
   HGW 08/04/86 : Changed termonology
   mrm 10/01/86 : OM 4.0 conversion
   HGW 02/16/87 : Change to use new method.
   HGW 11/16/87 : Changes for version 1.1
\*/

class specification COsmtocl (1:0) of COroot;

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

instance COsmtocl
{
   IGRint         event_on_q;   /* Flag set if a event is put on queue  */
   IGRint         init_success; /* Flag set if TRUE is successful init  */
   IGRint         locate_state; /* Internal locate state                */
   OMuword        classes;      /* Locatable classes                    */
   OM_S_CLASSLIST eligible_classes; /* Class structure                  */
   struct GRevent     locate_point; /* Event used in locate             */
   struct GRlc_locate attr;         /* locate attr eg class, owner      */
   struct GRlc_stack  locate_stack; /* locate stack                     */
   channel 
   {
      (rel_ordered,
       many_to_many,
       initial=1,
       increment=1)
   }  to_gs_channel;                   /* channel to the saveset     */
};

override init, delete, execute;

end specification COsmtocl;
