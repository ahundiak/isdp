/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COsdcreate

Description
   This is the class for the create symbol definition command object.

History
   mrm 05/14/86 : Creation Date
   HGW 07/03/86 : Finished coding and tested
   HGW 08/05/86 : Changed termonology
   mrm 10/01/86 : OM 4.0 conversion
   HGW 12/17/87 : Changes for version 1.1
\*/

class specification COsdcreate (1:0) of COroot;

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
#include "codef.h"
#include "grdpbdef.h"

instance COsdcreate
{
   IGRboolean    ele_located;          /* has an element been located?  */
   IGRchar       dbtype[MAX_DB_TYPE_SIZE]; /* Database type             */
   IGRchar       sdh_classname[20];    /* symbol def header classname   */
   IGRint        locate_state;         /* Internal locate state         */
   IGRint        init_success;         /* if TRUE is successful init    */
   IGRint        name_length;          /* # chars in name               */
   IGRint        desc_length;          /* # chars in description        */
   struct GRnamdesc      namdesc;      /* sym def name & description    */
   struct GRmd_env       asl_env;      /* active symbol lib information */
   struct GRevent        event;        /* event structure               */
   struct GRlc_locate    attr;         /* locate attributes             */
   struct GRvg_construct const_list;   /* construction list             */
   struct GRlc_stack     locate_stack; /* stack for the locate filter   */
   channel 
   {
      (rel_ordered,
       many_to_many,
       initial=1,
       increment=1)
   }  to_gs_channel;                   /* channel to the saveset        */
};

override init, wakeup, delete, execute;

end specification COsdcreate;
