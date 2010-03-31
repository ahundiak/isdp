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

%safe
static IGRboolean      EFget_gap_curve();
%endsafe

#ifndef DEBUG
#define DEBUG 0
#endif


/* 
 DESCRIPTION
  
 This function merges several curves together to form a single curve.

 RETURN VALUES

 *msg	  		 completion code
                         - MSSUCC if successful
                         - MANOMEMORY if no dynamic memory available
                         - MSFAIL (severe) if failure
                           due to allocation problems
 **the_merged_curve      pointer to the resulting merged curve
  
 NOTES

 The merged curve is reparameterized based on the length of it's polygon.
 The previous statement is no longer true.
 The speed could be much improved if BSalloc and BSfree were not called.
 It should use the curve size macro and therefore only one malloc would
 be needed, but alas there is no time.
   
 ALGORITHM
  
 Get all the curves and merge them together.

 HISTORY

 ss	09/30/86 : Design date.
 rlw	12/24/86 : Modified to reparameterize curve after merge.
 rlw	05/19/87 : Removed this functionality from the merge curve method
                   and reworked it.
 rlw	09/15/87 : Modified to use new math merge routine.  Also
                   reparameterization is different.
 rlw	12/13/87 : Modified such that if rational both
                   end weights will be 1.0.  I believe this is causing 
                   problems in surface modelling.
 rlw	03/22/88 : Fixed an invalid error check I noticed while reviewing
                   the code.
 SM	11-Oct-89: Added argument to optionally pass in curve buffers instead
		   of objects and a flag indicating whether an attempt should
		   be made to fill gaps with line segments.
		   Consequently, changed the function name from 
		   'EFmerge_the_curves' to 'EFmerge_curves'.
 SM    21-Aug-92   Fixed a crash when the first curve was degenerate resulting
                   in the 'merged_curve' pointers remaining NULL even during
                   second iteration of the loop.
 SM    08-Mar-93   Dieter provided a new routine BSmergecvnn2() which has
                   the gap tolerance as an input arguement. Changed the
                   original call to BSmergecvnn to this new function and passed
                   2*cht as the gap tolerance. The implication of this being
                   that we can now merge even if the gap is more than bastol
                   but less than 2*cht. 
                   The closure property of the merged curve DOES NOT have to be
                   checked against 2*cht becuase the merge routine ensures the 
                   common points between 2 curves to be EXACTLY the same
                   after merging.
 */

IGRboolean EFmerge_curves(
  number_of_curves,
  curves,
  curvebuffs, 
  my_stupid_id,
  the_merged_curve,
  try_filling_gaps, 
  msg)

IGRlong		number_of_curves;
struct		GRlc_info curves[];
struct 		IGRbsp_curve curvebuffs[];
OM_S_OBJID	my_stupid_id;
struct		IGRbsp_curve **the_merged_curve;
IGRboolean	try_filling_gaps;
IGRlong		*msg;
{
 IGRchar		*generic_pointer;
 IGRshort		order;
 IGRboolean		status, rational, merged = FALSE;
 IGRlong		msg_loc, i, sts, num_poles;
 struct			IGRbsp_curve *tmp_curve, *merged_curve, *new_curve;
 struct			IGRbsp_curve *curve, gap_curve;
 IGRboolean		filling_gap = FALSE;
 IGRdouble		gap_poles[6], gap_knots[4];
 IGRdouble		cht, mergetol, bastol;
 struct GRlc_info	*remaining_curves = NULL;
 struct IGRbsp_curve    *remaining_buffs = NULL;
 IGRlong		num_remaining = 0;

/*
 * Initialize
 */
 *msg = MSSUCC;
 *the_merged_curve = NULL;
 tmp_curve = NULL;
 merged_curve = NULL;
 new_curve = NULL;
 if(!number_of_curves)
  {
   *msg = MSFAIL;
   goto wrapup;
  }

 BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht);
 BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, bastol);
 if(curvebuffs)
  {
   remaining_buffs = (struct IGRbsp_curve *) om$malloc(size = 
                     number_of_curves * sizeof(struct IGRbsp_curve));
   EMerr_hndlr(!remaining_buffs, *msg, MANOMEMORY, wrapup);
  }
 else
  {
   remaining_curves = (struct GRlc_info *) om$malloc(size =
                    number_of_curves * sizeof(struct GRlc_info));
   EMerr_hndlr(!remaining_curves, *msg, MANOMEMORY, wrapup);
  }

 if(try_filling_gaps)
  {
   gap_curve.poles = gap_poles;
   gap_curve.knots = gap_knots;
   gap_curve.weights = NULL;
   gap_curve.num_boundaries = 0;
   gap_curve.bdrys = NULL;
   gap_curve.order = 2;
   gap_curve.periodic = FALSE;
   gap_curve.non_uniform = FALSE;
   gap_curve.num_poles = 2;
   gap_curve.num_knots = 4;
   gap_curve.rational = FALSE;
   gap_curve.weights = NULL;
   gap_curve.planar = FALSE;
   gap_curve.phy_closed = FALSE;
   gap_curve.knots[0] = 0.0;
   gap_curve.knots[1] = 0.0;
   gap_curve.knots[1] = 1.0;
   gap_curve.knots[1] = 1.0;
  }

 mergetol = bastol;
/*
 * For each curve get the geometry and merge it in with the rest
 */
 for (i = 0; i < number_of_curves; i++)
  {
   IGRboolean degenerate = FALSE;

   filling_gap = FALSE;
   merged = FALSE;

   if( (i == (number_of_curves - 1)) && !num_remaining)
    mergetol = 2*cht;

   if(curvebuffs) curve = &curvebuffs[i];
   else
    {
     /*
      * Get the abstract buffer of the curve
     */
     sts = om$send(msg = message GRcurve.GRgenabsg(msg,
           &curves[i].module_info.md_env.matrix_type,
           curves[i].module_info.md_env.matrix, &generic_pointer),
           senderid = my_stupid_id,
           targetid = curves[i].located_obj.objid,
           targetos = curves[i].located_obj.osnum);
     EMerr_hndlr(!(1 & sts), *msg, MSFAIL, wrapup);
     curve = (struct  IGRbsp_curve *) generic_pointer;
    }
   
   BStstcvdegn(curve, &degenerate, &msg_loc ); /* Check for degeneracy    */
   if (degenerate) continue;                   /* If yes, skip this curve */

   BSalloccv(curve->order, 2*curve->num_poles, curve->rational, 0, &tmp_curve,
             &msg_loc);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MANOMEMORY, wrapup);

   status = BScv_copy(&msg_loc, curve, tmp_curve);
   EMerr_hndlr(!status, *msg, MSFAIL, wrapup);

   /*
    * Merge it with the rest of them
    */
   if(!merged_curve)
    {
     merged_curve = tmp_curve;
     tmp_curve = NULL;
     continue;
    }

   if(merged_curve && merged_curve->phy_closed)
    continue;

   /*
    * Allocate the curve structure for
    * the resulting merged curve.
    */
   order = (merged_curve->order >= tmp_curve->order ? 
           merged_curve->order : tmp_curve->order);

   if (merged_curve->order == tmp_curve->order)
     num_poles = merged_curve->num_poles + tmp_curve->num_poles - 1;
   else if (merged_curve->order > tmp_curve->order)
     num_poles = merged_curve->num_poles + tmp_curve->num_poles +
                 ((tmp_curve->num_poles - tmp_curve->order + 2) *
                 (merged_curve->order - tmp_curve->order));
   else
    num_poles = tmp_curve->num_poles + merged_curve->num_poles +
                ((merged_curve->num_poles - merged_curve->order + 2) *
                (tmp_curve->order - merged_curve->order));
   rational = merged_curve->rational || tmp_curve->rational;

   BSalloccv(order, 2*num_poles, rational, 0, &new_curve, &msg_loc);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MANOMEMORY, wrapup);

   merged = FALSE;
   BSmergcvnn2(merged_curve, tmp_curve, mergetol, new_curve, &msg_loc);
   if (msg_loc != BSSUCC)
    {
     if(try_filling_gaps)
      {
       filling_gap = TRUE;
       if(EFget_gap_curve(merged_curve, tmp_curve, &gap_curve))
	{
         BSmergcvnn2(merged_curve, &gap_curve, mergetol, new_curve, &msg_loc);
         EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, wrapup);
         merged = TRUE;
        }
       else EMerr_hndlr(TRUE, *msg, MSFAIL, wrapup);
      }
     else
      {
       if(curvebuffs)
        remaining_buffs[num_remaining++] = curvebuffs[i];
       else
        remaining_curves[num_remaining++] = curves[i];
       merged = FALSE;
      }
    }
   else merged = TRUE;

   status = BSfreecv(&msg_loc, tmp_curve);
   tmp_curve = NULL;
   if(merged)
    {
     status = BSfreecv(&msg_loc, merged_curve);
     merged_curve = new_curve;
     new_curve = NULL;
     if(filling_gap) i--;		/* to stay on same input curve */
    }
   else
    {
     status = BSfreecv(&msg_loc, new_curve);
     new_curve = NULL;
    }

  } /* for (i = 0; i < object_count; i++) */


  /* Try with 2*cht as the mergetol, if some curves did not merge within
   * bastol.
  */

 mergetol = 2*cht;
 new_curve = NULL;
 tmp_curve = NULL;

  /*
   * For each curve get the geometry and merge it in with the rest
  */
 for (i = 0; i < num_remaining; i++)
  {
   if(curvebuffs) curve = &remaining_buffs[i];
   else
    {
     /*
      * Get the abstract buffer of the curve
     */
     sts = om$send(msg = message GRcurve.GRgenabsg(msg,
           &remaining_curves[i].module_info.md_env.matrix_type,
           remaining_curves[i].module_info.md_env.matrix, &generic_pointer),
           senderid = my_stupid_id,
           targetid = remaining_curves[i].located_obj.objid,
           targetos = remaining_curves[i].located_obj.osnum);
     EMerr_hndlr(!(1 & sts), *msg, MSFAIL, wrapup);
     curve = (struct  IGRbsp_curve *) generic_pointer;
   }
   
  BSalloccv(curve->order, 2*curve->num_poles, curve->rational, 0, &tmp_curve,
             &msg_loc);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MANOMEMORY, wrapup);

  status = BScv_copy(&msg_loc, curve, tmp_curve);
  EMerr_hndlr(!status, *msg, MSFAIL, wrapup);

  /*
   * Merge it with the rest of them
   */
  if(!merged_curve) /* Can happen if none of the curves merged earlier */
   {
    merged_curve = tmp_curve;
    tmp_curve = NULL;
    continue;
   }

  if(merged_curve && merged_curve->phy_closed)
   continue;

  /*
   * Allocate the curve structure for
   * the resulting merged curve.
  */
  order = (merged_curve->order >= tmp_curve->order ? 
          merged_curve->order : tmp_curve->order);
  if (merged_curve->order == tmp_curve->order)
   num_poles = merged_curve->num_poles + tmp_curve->num_poles - 1;
  else if (merged_curve->order > tmp_curve->order)
   num_poles = merged_curve->num_poles + tmp_curve->num_poles +
               ((tmp_curve->num_poles - tmp_curve->order + 2) *
               (merged_curve->order - tmp_curve->order));
  else
   num_poles = tmp_curve->num_poles + merged_curve->num_poles +
               ((merged_curve->num_poles - merged_curve->order + 2) *
               (tmp_curve->order - merged_curve->order));
  rational = merged_curve->rational || tmp_curve->rational;
  BSalloccv(order, 2*num_poles, rational, 0, &new_curve, &msg_loc);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MANOMEMORY, wrapup);

  BSmergcvnn2(merged_curve, tmp_curve, mergetol, new_curve, &msg_loc);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, wrapup);

  status = BSfreecv(&msg_loc, tmp_curve);
  tmp_curve = NULL;
  status = BSfreecv(&msg_loc, merged_curve);
  merged_curve = new_curve;
  new_curve = NULL;

  } /* for (i = 0; i < num_remaining; i++) */

 EMerr_hndlr(!merged_curve, *msg, MSFAIL, wrapup);

 /*
  * Fix the end weights
  */
 if (merged_curve->rational)
  {

   BSchgcvewts(merged_curve, merged_curve, &msg_loc);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, wrapup);
  }

 /*
  * Reparameterize
  */
 status = BSnorkts(&msg_loc, &merged_curve->order, &merged_curve->num_poles,
          merged_curve->knots);
 EMerr_hndlr(!status, *msg, MSFAIL, wrapup);

 /*
  * Return the results
  */
 merged_curve->num_boundaries = 0;
 *the_merged_curve = merged_curve;
 merged_curve = NULL;

/*
 * Eof
 */
wrapup:
 if (tmp_curve)    status = BSfreecv (&msg_loc, tmp_curve);
 if (merged_curve) status = BSfreecv (&msg_loc, merged_curve);
 if (new_curve)    status = BSfreecv (&msg_loc, new_curve);
 if (remaining_curves) om$dealloc(ptr = remaining_curves);
 if (remaining_buffs) om$dealloc(ptr = remaining_buffs);
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}



static IGRboolean EFget_gap_curve(cv1, cv2, cv3)
struct IGRbsp_curve	*cv1, *cv2, *cv3;
{
 IGRdouble		pt1[2][3], pt2[2][3], dist, lentol, mindist, 
			*ptr1 = NULL, *ptr2 = NULL;
 IGRlong		rc, sts = OM_S_SUCCESS;
 struct EMSdataselect	junk;
 extern IGRint		EMgetendpts_xyz();
 IGRint			sz = sizeof(IGRpoint), i;

#if DEBUG
 printf("Filling Gap between curves\n");
#endif

 BSEXTRACTPAR(&rc, BSTOLLENVEC, lentol);

 junk.datatype = EMSdata_curve3d;
 junk.data.curve = cv1;

 sts = EMgetendpts_xyz(&rc, NULL, NULL, &junk, FALSE, 1, pt1[0], pt1[1]);
 if(!(1&sts&rc)) goto wrapup;

 junk.data.curve = cv2;
 sts = EMgetendpts_xyz(&rc, NULL, NULL, &junk, FALSE, 1, pt2[0], pt2[1]);
 if(!(1&sts&rc)) goto wrapup;

 /* Linesegment between cv1 and cv2. 
    If one of the ends of cv2 is already within tolerance from stop
    point of cv1, it indicates some problem other than a gap.
 */
 mindist = MAXDOUBLE;
 for(i=0; i<2; i++)
  {
   dist = BSdistptpt(&rc, pt1[1], pt2[i]);
   if(dist<lentol) return(FALSE);
   if(dist < mindist)
    {
     ptr1 = pt1[1];
     ptr2 = pt2[i];
     mindist = dist;
    }

   dist = BSdistptpt(&rc, pt1[0], pt2[i]);
   if(dist<lentol) return(FALSE);
   if(dist < mindist)
    {
     ptr1 = pt1[0];
     ptr2 = pt2[i];
     mindist = dist;
    }
  }

 OM_BLOCK_MOVE(ptr1, cv3->poles, sz);
 OM_BLOCK_MOVE(ptr2, &cv3->poles[3], sz);

wrapup:
if(1&sts)
return(TRUE);
else return(FALSE);
}



end implementation GRsubbc;
