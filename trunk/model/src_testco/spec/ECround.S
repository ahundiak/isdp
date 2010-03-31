/* ###################   APOGEE COMPILED   ################## */
class specification ECround (1:0) of ECsfedloc;

/*

HISTORY

April 1991      AMD        Creation of the new ECround class. Most of
                           the instance data has been moved to the 
                           superclass ECsfedloc.
Nov. 1992 	Tapadia    Modified to support the new phoenix rounding 
			   interface. Split this into 2 files (ECround.S) for 
			   round edge & round vertex & (ECchamfer.S) for 
			   chamfer edge & chamfer vertex.
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


instance ECround
{
  IGRboolean    associative;
};

override  init, execute, wakeup, sleep;

end specification ECround;
