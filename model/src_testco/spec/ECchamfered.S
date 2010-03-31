/* ###################   APOGEE COMPILED   ################## */
class specification ECchamfered (1:0) of ECsfedloc;

/*

HISTORY

12/28/92  Tapadia 	Creation of the new ECchamfered class. Most of the 
			instance data has been moved to the superclass 
			ECsfedloc.
*/

# include "igr.h"
# include "gr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "go.h"
# include "lcdef.h"
# include "griodef.h"
# include "grio.h"
# include "lc.h" 


instance ECchamfered
{
  IGRboolean    associative;
};

override  execute, wakeup, sleep;

end specification ECchamfered;
