/* 
  DESCRIPTION

    This function modifies the uv-data (uvcv) and the xyz-data (xyzcv) that
    lie on a given surface (srf) if it finds the ends of the xyz-data
    lying on the natural boundary of srf. The main intention is to force
    the uv-data to end on the natural boundary when seen fit.

    This function assumes the natural parameterization of the surface as
    extending from 0 to 1.
      
  RETURN CODE

    EMS_I_NotFound    - If none of the ends were on boundary to begin
                        with and nor were the ends within tolerance to
                        be pushed to the boundary.
    EMS_I_Modified    - If atleast one of the ends was modified to be
                        pushed to the boundary.
    EMS_I_EndOnSide   - If atleast one of the ends was found to be already
                        at the boundary but no end was modified.

  HISTORY
    
    SS  :  10/21/93  :  Creation
*/

#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "gocmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "EMSbnd.h"
#include "emserr.h"
#include "EMSwrmacros.h"

#define START 0
#define STOP  1

#define U 0
#define V 1
#define W 2

#define LO 0
#define HI 1

#define CONST_U  1
#define CONST_V  2

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

void EFmaptobnd (msg, options, srf, tol, xyzcv, uvcv)
IGRlong	*msg;
IGRushort options;
struct IGRbsp_surface *srf;
IGRdouble tol;
struct EMSdataselect *xyzcv, *uvcv;
{
  IGRboolean tst_plan=TRUE, onbdry[2], tobdry[2];
  IGRshort order[2], isodir[2], mattyp;
  IGRint i, j, uorv[2], hiorlo[2], endinx, blksize;
  IGRlong num_poles[2], msg_loc, msg_save;
  IGRdouble oldtol, kval, par[2], endpt_uv[2][2], endpt_xyz[2][3];
  IGRdouble minpar, mindist, bdrypar[2];
  IGRpoint minpt, bdrypt[2], new_endpt;
  IGRmatrix mat;
  struct IGRbsp_curve *cv;

  *msg = EMS_I_NotFound;

  onbdry[START] = onbdry[STOP] = FALSE;
  tobdry[START] = tobdry[STOP] = FALSE;

  /*
   * Obtain the uv-endpoints and check which end on natural boundaries
   * already. If both end on natural boundaries, this function does not
   * need to do anything further.
   */

  EMgetendpts_uv (&msg_loc, uvcv, FALSE, 1, endpt_uv[START], endpt_uv[STOP]);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
  for (endinx=START; endinx<=STOP; endinx++)
    for (i=U; i<=V; i++)
      if (endpt_uv[endinx][i] == LO || endpt_uv[endinx][i] == HI)
        onbdry[endinx] = TRUE;

  if (onbdry[START] || onbdry[STOP])
    {
    *msg = EMS_I_EndOnSide;
    if (onbdry[START] && onbdry[STOP])
      goto ret_end;
    }

  /*
   * Check if the model-space ends which do not already lie at the boundary,
   * lie within tolerance of any of the natural boundaries of the surface.
   * If so, then retain the relevant information for the next step.
   */

  isodir[U] = CONST_U;
  order[U] = srf->v_order;
  num_poles[U] = srf->v_num_poles;

  isodir[V] = CONST_V;
  order[V] = srf->u_order;
  num_poles[V] = srf->u_num_poles;

  par[LO] = 0.0;
  par[HI] = 1.0;

  EMidmatrix (&msg_loc, &mattyp, mat);
  EMgetendpts_xyz (&msg_loc, &mattyp, mat, xyzcv, FALSE, 1,
   endpt_xyz[START], endpt_xyz[STOP]);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  for (i=U; i<=V; i++)
    {
    GRbc_size (order[i], num_poles[i], srf->rational, 0, blksize);
    cv = (struct IGRbsp_curve *) alloca (blksize);
    GRbc_partition (cv, order[i], num_poles[i], srf->rational, 0);

    for (j=LO; j<=HI; j++)
      {
      BSconstprcv (&msg_loc, srf, &isodir, &par[j], &tst_plan, cv);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      for (endinx=START; endinx<=STOP; endinx++)
        {
        if (onbdry[endinx] || tobdry[endinx])
          continue;

        BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, oldtol);
        BSchangepar (&msg_loc, BSTOLLENVEC, tol);

        BSmdstptcv (cv, endpt_xyz[endinx], &minpar, minpt, &mindist, 
         &msg_save);
        BSchangepar (&msg_loc, BSTOLLENVEC, oldtol);
        EMerr_hndlr (msg_save != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        if (mindist <= tol)
          {
          tobdry[endinx] = TRUE;
          bdrypar[endinx] = minpar;
          OM_BLOCK_MOVE (minpt, bdrypt[endinx], sizeof (IGRpoint));
          uorv[endinx] = i;
          hiorlo[endinx] = j;
          }
        }
      }
    }
  
  /*
   * Figure out the changes that need to be made to the input data,
   * and make them.
   */

  for (endinx=START; endinx<=STOP; endinx++)
    {
    if (tobdry[endinx])
      {
      kval = hiorlo[endinx] == LO ? 0.0 : 1.0;
      if (uorv[endinx] == U)
        new_endpt[U] = kval;
      else
        new_endpt[V] = kval;

      kval = bdrypar[endinx];
      if (uorv[endinx] == U)
        new_endpt[V] = kval;
      else
        new_endpt[U] = kval;

      new_endpt[W] = 0.0;
      EMend_modify_data (&msg_loc, NULL, uvcv, endinx == START, new_endpt);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
 
      EMend_modify_data (&msg_loc, NULL, xyzcv, endinx == START,
       bdrypt[endinx]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }

ret_end:
  return;
}
