/* 
 DESCRIPTION
  
 This method takes a list of curve object ids (along with other
 necessary information about each of the curves) and merges all of them
 together, forming a single curve. The order in which this 
 merge takes place is strictly in the order in which they are present in
 the input curves array. That is, no attempt is made to try permutations 
 and  combinations among the curves to find continuity. If continuity 
 conditions are not met between successive curves, the method aborts and an
 error status is returned. No merged curve object gets created in
 this case. If all went well a merged curve object is output.

 RETURN VALUES

 *msg	  		 completion code
                         - MSSUCC if successful
                         - MANOMEMORY if no dynamic memory available
                         - MSINARG if math failed, note that this probably
                           indicates that the input curves were not connected
                         - MSFAIL (severe) if failure
                           due to allocation problems

 NOTES

 This method has been modified to perform a fast merge, i.e. the
 curve is not reprameterized after merging.
   
 ALGORITHM
  
 Get all the curves and merge them together.

 HISTORY

 ss	09/30/86 : Design date.
 rlw	12/24/86 : Modified to reparameterize curve after merge.
 rlw	05/19/87 : Removed the bulk of functionality from this method
                   and put it into a function, since this logic was
                   also needed by composite curves.  See below.
 rlw	09/15/87 : Modified to call another merge curve from the math group
 rlw	12/13/87 : Modified merge curve function such that if rational both
                   end weights will be 1.0.  I believe this is causing 
                   problems in surface modelling.
 rlw	03/22/88 : Fixed an invalid error check I noticed while reviewing
                   the code.
 rlw    02/28/89 : Modified to add conditional compilation statements
                   for the I/DRAW product.
 SM	11-Oct-89: Pass NULL for curve buffers to 'EFmerge_curves'.
 Inasu  02-Jul-90: Modified to skip the degenerate curves.
 Sudha  06/16/93     Modified for BSprototype ansification

 */

class implementation GRsubbc;

#include "EMS.h"
# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif
# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif
# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif
#include "OMerrordef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "bs.h"				/* Has bs error codes */
#include "madef.h"			/* Has MAIDMX */
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "OMmacros.h"			/* OM_BLOCK_MOVE */
#include "bsparameters.h"		/* BSTOLLENVEC */
#include "bststcvdegn.h"
#include "bsparameters.h"
#include "bsnorkts.h"
#include "bsmergcvnn2.h"
#include "bsfreecv.h"
#include "bsdistptpt.h"
#include "bscv_copy.h"
#include "bschgcvewts.h"
#include "bsalloccv.h"


#ifndef DEBUG
#define DEBUG 0
#endif

extern IGRboolean  EFmerge_curves();

#ifndef IDRAW
method EMmerge_curves(
  IGRlong	number_of_curves;
  struct	GRlc_info curves[];
  struct	GRvg_construct *construct_list;
  IGRlong	*msg)
{
 IGRboolean	status;
 IGRlong	msg_loc, sts;
 struct		IGRbsp_curve *merged_curve;
/*
 * Initialize
 */
 *msg = MSSUCC;
 merged_curve = NULL;
/*
 * Merge the curves
 */
 status = EFmerge_curves(
   number_of_curves,
   curves,
   NULL, 
   my_id,
   &merged_curve,
   FALSE, 
   msg);
  if (!status) goto wrapup;
/*
 * Fill the instance data
 */
 construct_list->geometry = (IGRchar *) merged_curve;
 sts = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRconstruct(
                construct_list),
               senderid = my_id,
               targetid = my_id);
 construct_list->geometry = NULL;
  if (!(1 & sts)) goto wrapup;
/*
 * Error logic
 */
wrapup:
 if (merged_curve) status = BSfreecv(&msg_loc, merged_curve);
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  {
   sts = om$send(mode = OM_e_wrt_object,
                 msg = message Root.delete(1),
                 senderid = my_id,
                 targetid = my_id);
   return(OM_E_ABORT);
  }
}
#endif


end implementation GRsubbc;
