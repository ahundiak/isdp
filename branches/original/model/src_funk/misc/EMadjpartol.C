#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"

extern IGRboolean WANT_POST220_BEHAVIOR;

/*
 * History
 *    PP : Changed the high tolerance for planes from 1e-07 to 1e-04 due
 *         to problems in closing off loops during solid construction 
 */

void EMadjust_paramtol (msg, srf, inpartol, outpartol)
IGRlong *msg;
struct IGRbsp_surface *srf;
IGRdouble inpartol, *outpartol;
{
  IGRboolean linear_planar=FALSE, stat;
  IGRlong msg_loc;

  *msg = EMS_S_Success;
  
  if (srf && srf->planar)
    EFis_linear_map_ok (&msg_loc, srf, &linear_planar);

  if (WANT_POST220_BEHAVIOR ? (srf && srf->planar && !linear_planar) : 
                              (srf && srf->planar))
    {
    if (inpartol > EMS_HIGH_UVPLANAR_LENTOL)
      *outpartol = EMS_HIGH_UVPLANAR_LENTOL;
    else
      *outpartol = inpartol;
    }
  else
    {
    if (inpartol > EMS_HIGH_UVLENTOL)
      *outpartol = EMS_HIGH_UVLENTOL;
    else 
      *outpartol = inpartol;
    }
}


