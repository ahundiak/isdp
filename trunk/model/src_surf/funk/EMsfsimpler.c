/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include "igrtypedef.h"
#include "igr.h"

IGRboolean EMfirst_surf_simpler (sf1, sf2)
struct IGRbsp_surface *sf1, *sf2;
{
  if (! sf1->rational && sf2->rational)
    return (TRUE);
  else if ((sf1->u_order + sf1->v_order) < (sf2->u_order + sf2->v_order))
    return (TRUE);
  else if (sf1->planar && ! sf2->planar)
    return (TRUE);
  else
    return (FALSE);
}
