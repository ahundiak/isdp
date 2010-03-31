/*
  DESCRIPTION

    The ordering of points is such that the angle is measure in the counter-
    clockwise direction starting from the first segment. The point comprising
    the segment radiate outward from the vertex. If three (3) points are
    input, the segments consists of points 1-2 and points 1-3, respectively.
    If four (4) points input, the segments consist of points 1-2 and 3-4,
    respectively.

    If "moreinfo" is input, it is assumed to be the "diminfo" for this
    angle dimension. Then the ordering, etc. is derived from the information
    contained in there. If no "moreinfo" is passed in, the ordering is
    derived geometrically.


  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

class implementation SKrelornt;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "dimplan.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimcomplex.h"
#include "diminfo.h"
#include "dimangular.h"
#include "bserr.h"
#include "maidmx.h"
#include "bsxln.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

#define ORIGIN_PT    0
#define FIRST_ENDPT  1
#define SECOND_ENDPT 2

#define ORIGIN_PT1   0
#define ENDPT1       1
#define ORIGIN_PT2   2
#define ENDPT2       3

#define FIRST_SEG  0
#define SECOND_SEG 2

#define ORIGIN  0
#define MEASURE 1

#define FIRST  0
#define THIRD  2

#define X 0
#define Y 1

%safe
static void swapobj();
%endsafe

from DMsrc import DMgive_src_info;
from SKvariable import SKgetvar;

method SKorder_points (IGRlong *msg; IGRushort options;
                       IGRint num_pts; GRobjid *pt_ids;
                       IGRchar *moreinfo)
{
  IGRboolean reverse;
  IGRint i, inx;
  IGRlong msg_loc, stat_OM;
  IGRdouble dist1, dist2, dotp;
  IGRpoint ptvals[4], xpt;
  IGRvector vec1, vec2, crossp, zaxis;
  struct GRid dim_src_id;
  struct diminfo *diminfo;
  struct dim_src_info dim_src_info;
  struct GRmd_env md_env;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (num_pts < 3 || num_pts > 4, *msg, EMS_E_InvalidArg, ret_end);

  if (moreinfo)
    {
    diminfo = (struct diminfo *) moreinfo;

    if (num_pts == 3)
      {
      if (diminfo->ang_sector & CLOCK_WISE)
        swapobj (1, &pt_ids[FIRST_ENDPT], &pt_ids[SECOND_ENDPT]);
      }

    else
      {
      md_env.md_env.matrix_type = MAIDMX;
      MAidmx (&msg_loc, md_env.md_env.matrix);
      for (i=ORIGIN; i<=MEASURE; i++)
        {
        dim_src_id = diminfo->list[i == ORIGIN ? DIM_CPX_ORIG : DIM_CPX_MEAS];

        ex$get_modid (mod_osnum = dim_src_id.osnum,
         mod_id = &md_env.md_id.objid);
        md_env.md_id.osnum = dim_src_id.osnum;

        stat_OM = om$send (msg = message DMsrc.DMgive_src_info ((int *) &msg_loc,
                   &md_env, &dim_src_info), targetid = dim_src_id.objid,
                   targetos = dim_src_id.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

        if (dim_src_info.type == DMkeyseg)
          {
          if (dim_src_info.var.dm_keyseg.u_par > 0.5)
            reverse = TRUE;
          else
            reverse = FALSE;
          }
        else
          reverse = FALSE;

        if (!(diminfo->ang_sector & (i == ORIGIN ? ORIG_START : MEAS_START)))
          reverse = !reverse;

        if (reverse)
          {
          inx = i == ORIGIN ? FIRST : THIRD;
          swapobj (1, &pt_ids[inx], &pt_ids[inx+1]);
          }
        }
      
      if (diminfo->ang_sector & CLOCK_WISE)
        swapobj (2, &pt_ids[FIRST_SEG], &pt_ids[SECOND_SEG]);
      }
    }
  else 
    {
    for (i=0; i<num_pts; i++)
      {
      stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
                 NULL, NULL, ptvals[i]), targetid = pt_ids[i]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    if (num_pts == 3)
      {
      BSmkvec (&msg_loc, vec1, ptvals[ORIGIN_PT], ptvals[FIRST_ENDPT]);
      BSnorvec (&msg_loc, vec1);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);

      BSmkvec (&msg_loc, vec2, ptvals[ORIGIN_PT], ptvals[SECOND_ENDPT]);
      BSnorvec (&msg_loc, vec2);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);
      }
    else
      {
      BSmkvec (&msg_loc, vec1, ptvals[ORIGIN_PT1], ptvals[ENDPT1]);
      BSnorvec (&msg_loc, vec1);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);

      BSmkvec (&msg_loc, vec2, ptvals[ORIGIN_PT2], ptvals[ENDPT2]);
      BSnorvec (&msg_loc, vec2);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);

      BSxln (&msg_loc, ptvals[ORIGIN_PT1], ptvals[ENDPT1],
       ptvals[ORIGIN_PT2], ptvals[ENDPT2], xpt);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);

      dist1 = BSdistptpt (&msg_loc, ptvals[ORIGIN_PT1], xpt);
      dist2 = BSdistptpt (&msg_loc, ptvals[ENDPT1], xpt);
 
      if (dist1 > dist2)
        {
        swapobj (1, &pt_ids[ORIGIN_PT1], &pt_ids[ENDPT1]);
        for (i=X; i<=Y; i++)
          vec1[i] = -vec1[i];
        }

      dist1 = BSdistptpt (&msg_loc, ptvals[ORIGIN_PT2], xpt);
      dist2 = BSdistptpt (&msg_loc, ptvals[ENDPT2], xpt);
 
      if (dist1 > dist2)
        {
        swapobj (1, &pt_ids[ORIGIN_PT2], &pt_ids[ENDPT2]);
        for (i=X; i<=Y; i++)
          vec2[i] = -vec2[i];
        }
      }

    BScrossp (&msg_loc, vec1, vec2, crossp);
    zaxis[0] = zaxis[1] = 0.0;
    zaxis[2] = 1.0;

    dotp = BSdotp (&msg_loc, zaxis, crossp);
    if (dotp < 0.0)
      {
      if (num_pts == 3)
        swapobj (1, &pt_ids[FIRST_ENDPT], &pt_ids[SECOND_ENDPT]);
      else
        swapobj (2, &pt_ids[FIRST_SEG], &pt_ids[SECOND_SEG]);
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKrelornt.SKordpts");
  return (stat_OM);
}

static void swapobj (num, obj1, obj2)
IGRint num;
GRobjid *obj1, *obj2;
{
  IGRint blksize;
  GRobjid tmpobj, tmpobjs[2];

  if (num == 1)
    {
    tmpobj = *obj1;
    *obj1 = *obj2;
    *obj2 = tmpobj;
    }
  else
    {
    blksize = 2 * sizeof (GRobjid);
    OM_BLOCK_MOVE (obj1, tmpobjs, blksize);
    OM_BLOCK_MOVE (obj2, obj1, blksize);
    OM_BLOCK_MOVE (tmpobjs, obj2, blksize);
    }

  return;
}

end implementation SKrelornt;

