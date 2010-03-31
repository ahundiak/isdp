/* ###################   APOGEE COMPILED   ################## */
class specification ECreplace(1:0) of ECelements;

/*
HISTORY
   scw  08/14/94   clarified sleep method
*/


# include "EMS.h"
# include <stdio.h>
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
#include "EMSdpb.h"

instance ECreplace
   {
   struct EMdpbinfo  dpb_info;
   IGRboolean  associative_flag;
   struct GRid surf[2];
   IGRboolean uniform_draft;
   IGRboolean  is_associative;
   IGRint num_surfs;
   IGRint num_located;
   struct GRevent event[2];
   struct EX_button button;
   variable struct GRlc_info loc_info[];
   IGRint action;
   struct GRid cons_id;
   };

override init, wakeup, execute, super_cmd.sleep;
 

end specification ECreplace;
