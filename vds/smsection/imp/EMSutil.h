/* $Id: EMSutil.h,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / EMSutil.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EMSutil.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef EMSutilmacros_include_
#define EMSutilmacros_include_

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exdef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

/* *********************************************************************

  Description
   This macro will stroke a bspline curve given a chord height tolerance.
   In other words this will approximate the bspline with a line string.
 
  Arguments
   IGRlong *msg :  I/O : Completion code.
               MSSUCC        : If all goes well
               MANOMEMORY    : No memory available.
               MSFAIL        : If there is failure of sorts.

   struct IGRbsp_curve *curve : I : Input curve

   IGRdouble tolerance        : I : Tolerance for approximation. This value is
                                    used to determine the extent of
                                    approximation that needs to be done and
                                    represents the maximum distance between
                                    the bspline curve and the line string.
   struct IGRpolyline *polyline : O : Polyline structure representing the
                                      approximate line string.

Notes:

 This routine allocates enough memory to hold the points in the polyline
 structure. The caller needs to dealloc the memory after use.

*********************************************************************** */

#omdef ems$stroke_bspline_curve(
                 msg,
                 curve,
                 tolerance,
                 polyline)
                 
EFstroke_the_curve(curve, &tolerance, polyline, msg);
#endomdef       
#endif
