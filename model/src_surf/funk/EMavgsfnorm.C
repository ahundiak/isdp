#include "igrtypedef.h"
#include "igr.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "bssfevaln.h"
#include "bsnorvec.h"

#define U 0
#define V 1

/*
  DESCRIPTION

    This function computes the normal to the given surface (oriented or
    natural) at a given xyz point. The normal is computed at the minimum
    distance location
*/

void EMgetsfnorm (msg, srf, pt, sfpt, natnorm, norm)
IGRlong *msg;
struct IGRbsp_surface *srf;
IGRpoint pt, sfpt;
IGRvector natnorm, norm;
{
  IGRboolean allonsf;
  IGRlong i, msg_loc;
  IGRdouble loc_dist, uv[2];
  IGRpoint loc_sfpt;
  IGRvector loc_norm;
  void EMavgsfnorm();

  *msg = EMS_S_Success;

  BSmdstptssf (1, pt, srf, uv, loc_sfpt, &loc_dist, &allonsf, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 
  EMavgsfnorm (&msg_loc, srf, uv[U], uv[V], loc_sfpt, loc_norm);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (sfpt)
    blkmv (sizeof (IGRpoint), loc_sfpt, sfpt);

  if (natnorm)
    blkmv (sizeof (IGRvector), loc_norm, natnorm);

  if (norm)
    {
    blkmv (sizeof (IGRvector), loc_norm, norm);
    if (!srf->pos_orient)
      for (i=X; i<=Z; i++)
        norm[i] = -norm[i];
    }

ret_end:
  return;
}


/*
  DESCRIPTION

    This function returns the unit normal to a surface, taking
    into account cusp-points/lines at the surface. The possible
    normals (in 1-4 directions) are averaged. If the average is 
    a zero-length normal, EMS_I_NoSolution is returned.

  HISTORY
	
    Sudha 07/06/93 Modified for BSprottypes ansification
*/

void EMavgsfnorm (msg, srf, u, v, sfpt, natnorm)
IGRlong *msg;
struct IGRbsp_surface *srf;
IGRdouble u, v;
IGRdouble *sfpt;
IGRvector natnorm;
{
  IGRboolean stat_func;
  IGRint i, j, numnorms;
  IGRlong msg_loc;
  IGRdouble sum;
  IGRvector normals[4];

  *msg = EMS_S_Success;

  BSsfevaln (srf, u, v, 0, &numnorms, sfpt, normals, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

  for (i=0; i<3; i++)  
    {
    natnorm[i] = 0.0;
    sum = 0.0;
    for (j=0; j<numnorms; j++)
      sum += normals[j][i];
    natnorm[i] = (sum / numnorms);
    }

  if (numnorms > 1)
    {
    stat_func = BSnorvec (&msg_loc, natnorm);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_I_NoSolution, ret_end);
    }

ret_end:;
}


