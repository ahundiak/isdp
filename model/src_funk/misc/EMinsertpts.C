/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
   EM_E_NoDynamicMemory - Just what it says
*/

#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emserr.h"

void EMinsertpts (msg, dim, numinspts, inspts, atinx, numpts, pts)
IGRlong *msg;
IGRshort dim;
IGRint numinspts;
IGRdouble *inspts;
IGRint atinx, numpts;
IGRdouble **pts;
{
  IGRint blksize;
  IGRlong dummy_stat;
  IGRdouble *ptsptr;

  *msg = EMS_S_Success;

  blksize = (numpts + numinspts) * dim * sizeof (IGRdouble);
  *pts = (IGRdouble *) om$realloc (ptr = (IGRchar *) *pts, size = blksize);
  EMerr_hndlr (! *pts, *msg, EMS_E_NoDynamicMemory, ret_end);
  ptsptr = *pts;

  if (atinx > numpts)
    atinx = numpts;
  blksize = (numpts - atinx) * dim * sizeof (IGRdouble);
  if (blksize)
    OM_BLOCK_MOVE (&ptsptr[atinx * dim], 
                   &ptsptr[(atinx + numinspts) * dim],
                   blksize);

  blksize = numinspts * dim * sizeof (IGRdouble);
  OM_BLOCK_MOVE (inspts, &ptsptr[atinx * dim], blksize);

ret_end:
  dummy_stat = TRUE;
  EMWRAPUP (*msg, dummy_stat, "EMinsertpts");
}


