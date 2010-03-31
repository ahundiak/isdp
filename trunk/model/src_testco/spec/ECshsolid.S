/*
ABSTRACT:

   This is the Command Object Class for 'Thin-Wall' or 'Shell' solids.

NOTES:


HISTORY:
 Sudhakar :  25Jul'93  :  Added override of 'element_located' method
                          to avoid identifying surfaces more than once.
 Sudhakar :  19May'93  :  Added 'is_solid' instance data to enable
                          handling of 'thinwall from composite surface'.
 Sudhakar :  03/10/93  :  Modified to sub-class from 'ECcsoffset' for
                          Phoenix ThinWall.
    ??    :     ??     :  Creation.
*/

class specification ECshsolid (1:3) of ECcsoffset;

#include "FI.h"
#include "dp.h"
#include "dpstruct.h"
#include "lcdef.h"
#include "lc.h"
#include "EMSfeadef.h"  /* for struct hole_data */


instance ECshsolid
  {
    IGRboolean symmetric;
    IGRboolean is_solid;
    IGRint num_opensfs;
    variable GRobjid open_surf_ids[];
  };

override
  status_disp, init, execute, 
  dir_dynamics,  /* Motivation: To handle symmetric arrow */
  do_form,       /* Motivation: Different no. of gadgets */
/*
        File :EMshslform.I
*/
  element_located;  /* Motivation: To avoid duplicate locates 
                      File :      ECshsolidi.I  */

end specification ECshsolid;


