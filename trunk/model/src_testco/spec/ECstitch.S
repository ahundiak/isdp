/* ###################   APOGEE COMPILED   ################## */
class specification ECstitch (1:0) of ECelement;

/*
HISTORY

15 May 1989 jBk Removed overrides of init, wakeup and sleep and
                instance data struct GRmd_env mod_info.
*/

override execute;

# include "EMS.h"

# include <stdio.h>

# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"

instance ECstitch
   {
   struct GRid surf[2];
   struct EMSstitch_info pair;
   IGRboolean is_fileptr;
   IGRboolean use_sti_tol;
   IGRdouble match_tol;
   IGRint sample_size;
   struct EX_button button;
   FILE *fileptr;
   };

end specification ECstitch;
