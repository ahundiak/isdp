/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
  BUGS

    The extension might produce a degenerate polyline under some special
    circumstances - if the polyline has two points and the other polyline
    intersects this one at the interior point.
*/

# include <math.h>

# include "OMminimum.h"
# include "OMerrordef.h"
# include "OMmacros.h"
# include "igetypedef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdef.h"
# include "igrdp.h"
# include "gr.h"
# include "godef.h"
# include "go.h"
# include "emsdef.h"
# include "emserr.h"
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
# include "EMSmsgdef.h"

# define FIRST  0
# define SECOND 1

void EMextend_2dpolylines (msg, poly1, poly2, at_stop1, at_stop2, bastol, 
                           datachg1, datachg2)
IGRlong *msg;
struct IGRpolyline *poly1, *poly2;
IGRboolean at_stop1, at_stop2;
IGRdouble *bastol;
enum EMSmaniptype *datachg1, *datachg2;
{
  IGRboolean stat_func, at_stop[2];
  IGRint i, inx, blksize;
  IGRlong msg_loc;
  IGRdouble segs[2][4], par[2][2], intpts[2][2];
  struct IGRpolyline *polys[2];
  enum EMScvinttype type[2];
  enum EMSmaniptype *datachg[2];
  void EMinsertpts();
  IGRboolean EF2dpyint();

  *msg = EMS_S_Success;

  if (at_stop1)
    {
    blksize = 2 * sizeof (IGRdouble);
    inx = (poly1->num_points-1) * 2;
    OM_BLOCK_MOVE (&poly1->points[inx], segs[FIRST], blksize);
    OM_BLOCK_MOVE (&poly1->points[inx-2], &segs[FIRST][2], blksize);
    }
  else
    OM_BLOCK_MOVE (poly1->points, segs[FIRST], 4 * sizeof (IGRdouble));

  if (at_stop2)
    {
    blksize = 2 * sizeof (IGRdouble);
    inx = (poly2->num_points-1) * 2;
    OM_BLOCK_MOVE (&poly2->points[inx], segs[SECOND], blksize);
    OM_BLOCK_MOVE (&poly2->points[inx-2], &segs[SECOND][2], blksize);
    }
  else
    OM_BLOCK_MOVE (poly2->points, segs[SECOND], 4 * sizeof (IGRdouble));

  stat_func = EF2dpyint (bastol, segs[FIRST], &segs[FIRST][2],
               segs[SECOND], &segs[SECOND][2],
               &type[SECOND], par[SECOND], &type[FIRST], par[FIRST],
               intpts, &msg_loc);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (stat_func)
    {
    polys[FIRST] = poly1;
    polys[SECOND] = poly2;
    at_stop[FIRST] = at_stop1;
    at_stop[SECOND] = at_stop2;
    datachg[FIRST] = datachg1;
    datachg[SECOND] = datachg2;
 
    for (i=FIRST; i<SECOND+1; i++)
      {
      if (type[i] == EMScvint_middle ||
          polys[i]->num_points == 2)
        {
        inx = (at_stop[i] ? polys[i]->num_points-1 : 0) * 2;
        OM_BLOCK_MOVE (intpts[0], &polys[i]->points[inx], 
         2 * sizeof (IGRdouble));

        if (datachg[i]) 
          *datachg[i] = EMSmanip_modify;
        }
      else if (((type[i] == EMScvint_end || type[i] == EMScvint_endcoll) && 
                (par[i][0] == 1.0)) ||
               (type[i] == EMScvint_collapsed))
        {
        if (! at_stop1)
          {
          blksize = (polys[i]->num_points-1) * 2;
          OM_BLOCK_MOVE (&polys[i]->points[2], &polys[i], blksize);
          }
        polys[i]->num_points--;

        if (datachg[i]) 
          *datachg[i] = EMSmanip_delete; 
        }
      else if (type[i] == EMScvint_overlap)
        {
        *msg = EMS_W_Coincident;
        if (datachg[i]) 
          *datachg[i] = EMSmanip_null;
        break;
        }
      }
    }
  else
    {
    inx = at_stop1 ? poly1->num_points : 0;
    EMinsertpts (&msg_loc, 2, 1, segs[SECOND], inx, poly1->num_points,
     &poly1->points);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    poly1->num_points++;

    if (datachg1) 
      *datachg1 = EMSmanip_insert;
    if (datachg2)
      *datachg2 = EMSmanip_null;
    }

ret_end:
  msg_loc = TRUE;
  EMWRAPUP (*msg, msg_loc, "EMextend_2dpolylines");
}

