class implementation EMSplane;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "bsparameters.h"
#include "bserr.h"
#include "EMSssprops.h"
#include "EMSproject.h"
#include "EMSsubbs.h"

#define PROJECT_V_ORDER     2
#define PROJECT_V_NUMPOLES  2

#define LOW_LEFT  0
#define LOW_RIGHT 1
#define UP_LEFT   2
#define UP_RIGHT  3

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1
#define Z 2

method EMis_rect_plane (IGRlong *msg; IGRboolean *is_rect_plane)
{
  IGRboolean EMis_rect_plane();

  *msg = EMS_S_Success;

  *is_rect_plane = EMis_rect_plane (ME.EMSsubbs->ss_props & EMSformat,
                    ME.EMSsubbs->packed_data);

  return (OM_S_SUCCESS);
}


IGRboolean EMis_rect_plane (format, sfinst_ptr)
IGRint format;
IGRchar *sfinst_ptr;
{
  IGRboolean is_rect_plane, rational;
  IGRuchar u_order, v_order;
  IGRushort u_num_poles, v_num_poles;
  IGRint i, j, k;
  IGRlong msg_loc;
  IGRdouble tol_sq, tol_dot, *dptr, sum_sq[2];
  IGRpoint *poles;
  IGRvector vecs[2][2], sidevec, prjvec;
  struct EMSbsplineSurfaceHeader *bsphdr;
  struct EMSprojectedSurfaceHeader *prjhdr;
  extern IGRdouble BSdotp();

  is_rect_plane = TRUE;

  /*
   * If the surface is not order-2 and has more than two poles
   * this does not qualify
   */
  
  if (format == EMSbsplineFormat)
    {
    bsphdr = (struct EMSbsplineSurfaceHeader *) sfinst_ptr;
    u_order = bsphdr->u_order;
    v_order = bsphdr->v_order;
    u_num_poles = bsphdr->u_num_poles;
    v_num_poles = bsphdr->v_num_poles;
    }
  else if (format == EMSprojectedFormat)
    {
    prjhdr = (struct EMSprojectedSurfaceHeader *) sfinst_ptr;
    u_order = prjhdr->order;
    v_order = PROJECT_V_ORDER;
    u_num_poles = prjhdr->num_poles;
    v_num_poles = PROJECT_V_NUMPOLES;
    }
  else
    goto ret_end;

  if (u_order != 2 || v_order != 2 || u_num_poles != 2 || v_num_poles != 2)
    {
    is_rect_plane = FALSE;
    goto ret_end;
    }

  /*
   * If the surface is rational then it is not a "rectangular"
   * plane
   */

  if (format == EMSbsplineFormat)
    rational = bsphdr->bs_props & EMSIS_RATIONAL;
  else
    rational = prjhdr->pj_props & EMSIS_PJ_RATIONAL;

  if (rational)
    {
    is_rect_plane = FALSE;
    goto ret_end;
    }


  /*
   * If the length of any side is degenerate or the opposite sides are unequal,
   * then this surface does not qualify
   * Also, if the two sides are not orthgonal, then this is not a 
   * rectangular plane
   */

  if (format == EMSbsplineFormat)
    {  
    poles = (IGRpoint *) bsphdr->double_data;
    for (i=LOW_LEFT, j=FIRST; i<=UP_LEFT; i+=2, j++)
      for (k=X; k<=Z; k++)
        vecs[U][j][k] = poles[i+1][k] - poles[i][k];
    for (i=LOW_LEFT, j=FIRST; i<=LOW_RIGHT; i++, j++)
      for (k=X; k<=Z; k++)
        vecs[V][j][k] = poles[i+2][k] - poles[i][k];
  
    BSEXTRACTPAR (&msg_loc, BSTOLSQLENVEC, tol_sq);
    for (i=U; i<=V; i++)
      {
      for (j=FIRST; j<=SECOND; j++)
        {
        sum_sq[j] = 0.0;
        dptr = (IGRdouble *) vecs[i][j];
        for (k=X; k<=Z; k++)
          sum_sq[j] += dptr[k] * dptr[k];
  
        if (fabs (sum_sq[j]) < tol_sq)
          {
          is_rect_plane = FALSE;
          goto ret_end;
          }
        }
      
      if (fabs (sum_sq[FIRST] - sum_sq[SECOND]) > tol_sq)
        {
        is_rect_plane = FALSE;
        goto ret_end;
        }
      }

    BSEXTRACTPAR (&msg_loc, BSTOLORTHOVEC, tol_dot);
    BSnorvec (&msg_loc, vecs[U][FIRST]);
    BSnorvec (&msg_loc, vecs[V][FIRST]);
    if (fabs (BSdotp (&msg_loc, vecs[U][FIRST], vecs[V][FIRST])) > tol_dot)
      {
      is_rect_plane = FALSE;
      goto ret_end;
      }
    }
  else
    {
    if ((prjhdr->pj_props & EMS_PJ_SUBTYPE) != EMSIS_PJ_ORTHO)
      {
      if ((prjhdr->pj_props & EMS_PJ_SUBTYPE) != EMSIS_PJ_VECTOR)
        {
        is_rect_plane = FALSE;
        goto ret_end;
        }

      poles = (IGRpoint *) prjhdr->projection_data.vector_format.end_of_data;
      for (i=X; i<=Z; i++)
        sidevec[i] = poles[SECOND][i] - poles[FIRST][i];
      BSnorvec (&msg_loc, sidevec);

      OM_BLOCK_MOVE (prjhdr->projection_data.vector_format.projection,
       prjvec, sizeof (IGRvector));
      BSnorvec (&msg_loc, prjvec);

      BSEXTRACTPAR (&msg_loc, BSTOLORTHOVEC, tol_dot);
      if (fabs (BSdotp (&msg_loc, sidevec, prjvec)) > tol_dot)
        {
        is_rect_plane = FALSE;
        goto ret_end;
        }
      }
    }

ret_end:
  return (is_rect_plane);
}

end implementation EMSplane;
