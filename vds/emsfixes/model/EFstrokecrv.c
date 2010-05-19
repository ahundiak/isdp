/* $Id: EFstrokecrv.c,v 1.2 2001/07/10 18:14:59 hans Exp $  */
/***************************************************************************
* I/VDS
*
* File: emsfixes/model/EFstrokecrv.c
*
* Description:
*
* Dependencies:
*
* Revision History:
*      $Log: EFstrokecrv.c,v $
*      Revision 1.2  2001/07/10 18:14:59  hans
*      Fix for TR# 5409 (mass property crash)
*
*      Revision 1.1.1.1  2001/01/04 21:07:28  cvs
*      Initial import to CVS
*
 * Revision 1.1  2000/02/08  17:33:00  pinnacle
 * initial revision
 *
# Revision 1.1  2000/01/04  08:33:16  pinnacle
*
* History:
*       MM/DD/YY  AUTHOR        DESCRIPTION
*       02/08/00  Rama Rao      TR#179901004 - Changed the active bastol
*				according to the changes in CHT.
*       07/10/2001 HF           Modified call: from BSchangepar(BSTOLBASIS)
*                                              to   BSchgdeppar(BSTOLBASIS)
***************************************************************************/

/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
DESCRIPTION

   This function strokes out a bspline curve given a chord height tolerance.
   The input required is a curve, stroke tolerance, and a polyline
   structure.

RETURN VALUES

   polyline		The stroked curve
   msg			MSSUCC - No problems
                        MANOMEMORY - No memory (from BS math)
			MSFAIL - Failure in BS math

HISTORY

    01/22/87 : rlw : creation date
    04/10/87 : rlw : Modified max points per span from 100 to 40
    04/28/87 : rlw : Renamed this function from stroke_the_curve.
    06/10/87 : rlw : Switched back to a BS routine in order to try and
                     reduce the number of points which are output.  It
                     no longer limits the maximum number of points per span.
    07/13/87 : pp  : Modified the function to accomadate the change in the
                     arguments to the math stroker routine. They now return
                     parameters of the stroked points too.
    07/09/93 :Sudha: Modified for BSprototypes anisfication
    02/04/00 :  RR : Change the bastol according to the changes in CHT.

 */

#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igr_include
# include "igr.h"
# endif
#include "msdef.h"                      /* MS error return codes */
#include "madef.h"                      /* macro + MA error return codes */
#include "bs.h"				/* Needed by emsbreak.h */
#include "bsparameters.h"		/* More bs stuff */
#include "bsparameters.h"
#include "bschtptstcv.h"
#include "bschangepar.h"
#include "bschgdeppar.h"

IGRboolean EFstroke_the_curve(
 curve,                         /* Curve to be stroked */
 tolerance,                     /* Chord height tolerance */
 poly_line,                     /* The stroked curve */
 msg)                           /* Error return code */

struct          IGRbsp_curve *curve;
double          *tolerance;
struct          IGRpolyline *poly_line;
IGRlong         *msg;
{
 IGRboolean     status;
 IGRlong	loc_msg, msg_loc;
 IGRdouble	saved_cht, saved_bastol;
 IGRdouble	*params;
/*
 * Initialize
 */
 *msg = MSSUCC;
 params = NULL;
 poly_line->num_points = 0;
 poly_line->points = NULL;
/*
 * Extract the existing chord height tolerance and change it if necessary
 */
 status = BSEXTRACTPAR(&loc_msg, BSTOLCHRDHT, saved_cht);
 if (*tolerance != saved_cht)
 {
  status = BSEXTRACTPAR(&loc_msg, BSTOLBASIS, saved_bastol);
/* Start VDS correction - Rama Rao 02/07/2000 - HF 07/10/2001 */
  status = BSchangepar(&loc_msg, BSTOLCHRDHT, *tolerance);
  /*status = BSchangepar(&loc_msg, BSTOLBASIS, (*tolerance)*(saved_bastol/saved_cht) );*/
  BSchgdeppar((*tolerance)*(saved_bastol/saved_cht), &loc_msg);
/* End VDS correction - Rama Rao 02/07/2000 - HF 07/10/2001 */
 }

/*
 * Stroke away
 */
 BSchtptstcv(
   curve,
   (IGRint *)&poly_line->num_points,
   (IGRpoint **)&poly_line->points,
   &params,
   &loc_msg);
/*
 * Restore the tolerance, if necessary
 */
 if (*tolerance != saved_cht)
 {
  status = BSchangepar(&msg_loc, BSTOLCHRDHT, saved_cht);
/* Start VDS correction - Rama Rao 02/07/2000 - HF 07/10/2001 */
  /*status = BSchangepar(&msg_loc, BSTOLBASIS, saved_bastol);*/
  BSchgdeppar(saved_bastol, &loc_msg);
/* End VDS correction - Rama Rao 02/07/2000 - HF 07/10/2001 */
 }

/*
 * See if the stroker failed
 */
  if (loc_msg != BSSUCC)
   {
    if ((loc_msg == BSNOMEMORY) || (loc_msg == BSNOSTKMEMORY))
     *msg = MANOMEMORY;
    else
     *msg = MSFAIL;
   }
/*
 * End of routine
 */

 if (params) free (params);
 if (1 & *msg)
  return(TRUE);
 else
  {
   if (poly_line->points) free(poly_line->points);
   poly_line->num_points = 0;
   poly_line->points = NULL;
   return(FALSE);
  }
}
