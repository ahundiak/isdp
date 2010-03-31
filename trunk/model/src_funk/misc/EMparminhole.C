/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "emsdattyp.h"

/*
Abstract
    This function determines if a parameter value lies in a hole of a
    loopset boundary.

Arguments
    EMparm_in_hole(parm, parm_span, bdrys, want_start_bdry, bdry_parm)

    IGRdouble            parm             input parameter value to check
                                          to see if in a hole.

    IGRint               parm_span        input span index of the parameter
                                          value if a linestring, etc.

    struct EMSpypoint    bdrys            input loopset boundaries.

    IGRboolean           want_start_bdry  input TRUE if want the first
                                          boundary parameter of the hole
                                          returned.

    IGRdouble            *bdry_parm       output the returned boundary
                                          parameter.

Notes

Files
    EMparminhole.C

History
    dhm    10/28/88    creation date.
*/


IGRboolean EMparm_in_hole(parm, parm_span, bdrys, bdry_parm)
IGRdouble     parm;
IGRint        parm_span;
struct EMSpypoint    *bdrys;
IGRdouble     bdry_parm[2];

{
  IGRboolean    at_start = TRUE, at_end = TRUE, in_hole_stat = FALSE;
  struct EMSpypoint    *pyptr, *nxptr;

  /*
   * If no bdrys, then the whole curve is in a hole.
   */

  if (bdrys == NULL)
  {
    in_hole_stat = TRUE;
    bdry_parm[0] = 0.0;
    bdry_parm[1] = 1.0;
    goto ret_end;
  }

  if (bdrys->param == 0.0)
    pyptr = bdrys->next;
  else
  {
    at_start = FALSE;
    pyptr = bdrys;
  }

  while (pyptr)
  {
    if (at_start)
      nxptr = pyptr->next;
    else
      nxptr = pyptr;

    if (!nxptr)
    {
      if (pyptr->param == 1.0)
        break;
      else
        at_end = FALSE;
    }

    if ( !at_start ||
       ( (parm + parm_span) >= (pyptr->param + pyptr->span_inx) ) )
    {
      if ( !at_end ||
         ( (parm + parm_span) <= (nxptr->param + nxptr->span_inx) ) )
      {
        if (at_start)
          bdry_parm[0] = pyptr->param;
        else
          bdry_parm[0] = 0.0;

        if (at_end)
          bdry_parm[1] = nxptr->param;
        else
          bdry_parm[1] = 1.0;

        in_hole_stat = TRUE;
        break;

      }  /* end if parm <= nxptr->param */

      at_start = TRUE;
      pyptr = nxptr->next;

    }  /* end if parm >= pyptr->param */
    else
      break;

  }  /* end while loop */


  ret_end:
    return(in_hole_stat);
}
