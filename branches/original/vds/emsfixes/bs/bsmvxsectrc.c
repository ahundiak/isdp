/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmvxsectrc

Abstract
    This routine will create a surface by moving cross section curves
along trace curves, changing their shapes and orientations using law
curves.

Synopsis
    void BSmvxsectrc(numtrc, trcurves, numcs, cscurves, on_site, 
                     scale_height, trpars, orient_abs, vmat, orig, 
                     dir_x, dir_y, const_dir, closed, shapelaw, slawcvs,
                     orientlaw, olawcvs, tsf1, tsf2, ssf1, ssf2, surf, rc)

    IGRint                numtrc
    struct IGRbsp_curve   *trcurves[]
    IGRint                numcs
    struct IGRbsp_curve   *cscurves[]
    IGRboolean            on_site
    IGRboolean            scale_height
    IGRdouble             trpars[]
    IGRdouble             vmat[3][3]
    IGRpoint              orig[]
    IGRpoint              dir_x[], dir_y[]
    IGRboolean            const_dir
    IGRboolean            closed
    IGRboolean            orient_abs
    IGRboolean            shapelaw
    struct IGRbsp_curve   *slawcvs[]
    IGRboolean            orientlaw 
    struct IGRbsp_curve   *olawcvs[]
    struct IGRbsp_surface *tsf1, *tsf2,
                          *ssf1, *ssf2    
    struct IGRbsp_surface **surf
    BSrc                  *rc

Description
    Input to this routine is:
    numtrc                the number of trace curves
    trcurves[]            these are the trace curves, sections move along
                          trace curves, using corresponding points 
                          between traces as references to determine 
                          shape and orientation of intermediate cross
                          sections; on_view can only have one trace !
    numcs                 the number of cross section curves ... has to be
                          greater than one in case of more than two traces
    cscurves[]            these are the cross section curves which mainly
                          decide the shape of the surface, because we 
                          move the cross sections along the traces...
                          these cross sections need to be planar, lines
                          or points.
    on_site               if TRUE, then the cross section curves are 
                          placed exactly where you want it in reference 
                          to the trace curves, 
                          if FALSE, then the cross section curves
                          are placed in the same view and the following 
                          data (rotation matrix, origins) tells where to 
                          place the cross sections in reference to the 
                          trace (note that since all the cross sections 
                          are placed in the same view, there will only be
                          one view matrix)
    scale_height          if scale_height is TRUE (only if you have two 
                          traces and one cross section), then the height 
                          of the cross section curve will be scaled as it
                          moves along the trace scaling the width, other-
                          wise the height stays constant
    trpars[]              if on_site is FALSE, then these are the para-
                          meters on the trace curve at which cross
                          sections will be placed ...for instance,
                          orig[0] is for cscurves[0] and orig[0] will be
                          moved onto the trace at trpars[0]
    vmat                  if on_site is FALSE, then this is the rotation
                          matrix for rotating the cross section curves
                          from the global position (in a view) to a local
                          xy system
    orig[]                if on_site is FALSE, then these are the origins
                          for the cross sections in reference to the
                          trace...origins are given in reference to the 
                          view that the cross section(s) were placed in...
                          the origin point given will be moved to a 
                          corresponding point(trpars[]) on the trace
    (direction points are only for on_view...
     the direction data following is given in space to define local
     coordinate systems at the reference points(trpars[]) on the trace 
     curve...the view coordinate system of the sections will be 
     transformed to the local systems)
    dir_x[]               defines a local x-axis for local systems at
                          trace points(trpars[]) on the trace curve 
    dir_y[]               along with trace points and dir_x[], defines an 
                          xy plane for local systems at the trace points
    const_dir             if there is more than one cross section on 
                          view, whether other orientations are desired 
                          for other sections, or whether the orientation 
                          for the first section will be used also for the
                          other ones(resulting in parallel planes on site)
    closed                whether the output surface is desired to be
                          closed or not...if closed is set to TRUE, then
                          the trace curve(s) have to be closed and in case
                          of more than one cross section the first one has
                          to be the same as the last one
    orient_abs            defines in case of one or two traces how to 
                          orient the cross sections as they move along the
                          trace(s)
                          1 : constant absolute position...which means
                              that in the case of one cross section only,
                              the position of the cross section at  
                              beginning will remain constant, just shifted
                              along, in case of multiple cross sections,
                              the position will change from one absolute
                              position into the next one, regardless of
                              the geometry of the trace curve(s)
                          0 : relative position...which means that in the
                              case of one cross section, the position of 
                              the cross section at the beginning with 
                              respect to the normal plane of trace curve 
                              will stay relatively constant throughout 
                              the movement, in the case of multiple cross
                              sections, the orientation of the cross 
                              sections will change from one relative
                              position w.r.t. the trace curve normal, 
                              into another relative position w.r.t. the 
                              trace curve normal... this beginning 
                              position is determined by either placing the
                              cross sections on_site or if on_view by 
                              giving the dir_x[]'s, dir_y[]'s and orig[]'s
                              ...if section(s) are desired to be normal to
                              the trace then they should be placed normal
    shapelaw              (for one ore two traces) whether law curves are
                          input to define how to change the shape between
                          two cross sections while moving along the
                          trace(s)
    slawcvs[]             if shapelaw = 1, then the law curve(s) (xy 
                          plane) for scaling the cross sections...there 
                          are numcrs - 1 law curves
    orientlaw             (for one ore two traces) whether law curves are
                          input to define how to vary the orientation
                          between two cross section planes while moving
                          along the trace(s)
    olawcvs[]             if orientlaw = 1, then the law curves(xy plane) 
                          for scaling the cross section orientations...
                          there are numcrs - 1 law curves
    *tsf1, *tsf2,         if on_site is TRUE, then
                          surfaces containing traces...tsf1 contains
                          first trace and if two traces, then tsf2 
                          contains second trace...these will provide the
                          end tangent constraints for the cross section
                          curves
    *ssf1, *ssf2          if on_site is TRUE, then
                          surfaces containing end cross sections...
                          ssf1 contains first section, and if more than 
                          one cross section, then ssf2 contains end cross 
                          section.. these will provide the end tangent
                          constraints for the trace curves.

    Output to this routine is the surface(surf) constructed by moving the
cross section(s) along the trace(s).

Return Values
    BSSUCC is returned if all is successful.

Notes
    If there are more than 2 traces, then the cross sections have to touch
the traces.

Index
    em

Keywords

History
    S.G. Catron    07/18/89  : Creation date.
    S.G. Catron    10/30/89  : If cross section is closed and it does not
                               touch the trace, then don't shuffle it.
    S.G. Catron    11/09/89  : For the case of one trace and one cross
                               section and the cross section was a line,
                               the "vecsum" was not being set, but was
                               being used.  Hence one of the smat vectors
                               zero and BSnorvec was giving an error.
                               I modified it so the vecsum is along
                               the cross section line.
    S.G. Catron    12/07/89  : There was an error in setting the trparsar.
    S.G. Catron    12/21/89  : Moved around the calls to BSmdistcvcv and
                               BSpl_cv_int.  Call BSmdistcvcv first, then
                               BSpl_cv_int.
    S.G. Catron    01/03/90  : Removed line to set dist to 0 in case that
                               BSmdistcvcv finds a distance greater than
                               chrdht_tol between trace and cross section.
    S.G. Catron    01/08/90  : If the cross sections happen to be slightly
                               non-planar and there are two traces, there 
                               was a problem with the smat.  The modifica-
                               tion made was to make sure that the 
                               smat[0](first vector in smat) was the 
                               actual connecting vector between the two
                               traces.  The connecting vector was pre-
                               viously found, but we crossed and crossed
                               back making it slightly off.
    S.G. Catron    01/12/90  : If it's a degenerate cross section or 
                               trace, never call BSclcvshffl to shuffle
                               the curve.
    S.G. Catron    01/22/90  : There was a problem with a circular trace
                               and the cross section was more than 
                               chrdht_tol from the trace.  So, if the 
                               parameter found from BSmdistcvcv is more
                               than chrdht_tol from the trace, but 
                               BSpl_cv_int finds a parameter way off from
                               parameter of BSmdistcvcv, use the 
                               BSmdistcvcv parameter.
   S.G. Catron     01/24/90  : If there are more than 2 traces, then the
                               cross sections have to touch the traces. 
                               It was only looking at greater than 3 
                               traces.  Don't forget to free stuff from
                               BSmdistcvcv if there is an error.
   S.G. Catron     02/16/90  : The calculation of the smat and tmat for
                               one trace was wrong sometimes.  It was 
                               using a plane normal from the trace curve
                               even if the trace was not planar.  So, now
                               a vecsum is found from the cross section
                               and that is crossed with the trace tangent
                               to get the other vector.
   S.G. Catron     02/27/90  : Check to see if the cross sections are
                               closed and there are more than 2 traces.
                               If so make sure the first and last traces
                               are equal.
   S.G. Catron     03/22/90  : There was a bug, when there was one trace
                               and the cross sections had no normal.
                               Some code was added to find the vecsum
                               when there was no normal vector.
   S.G. Catron     04/26/90  : Check the trace curves, when the cross
                               section is closed, to see if they start at
                               the beginning of the cross section and the
                               orientation is the same.  Also, there was
                               a bug in first call to tanvecBSmvxsectrc.
                               It was using the wrong index.
   S.G. Catron     05/23/90  : There was a bug in the shuffling of the
                               cross sections.
   S.G. Catron     06/11/90  : Change the scale_height input to TRUE, if
                               not two traces, otherwise leave as input.
   S.G. Catron     06/28/90  : Added code to call BSruled_sf1 if one or
                               two, order 2 traces and one or two cross
                               sections.  Also to up the degree for an
                               order two trace if there was a law curve
                               sent in. There was an error in an if
                               statement checking for parameters in the
                               "csparsar" array.  It was to check for 
                               parameters decreasing in the closed case
                               where 0 may need to be a 1 or vice versa.
   S.G. Catron     07/25/90  : Added code to check if the cross sections
                               were closed, only 2 traces and the traces  
                               touched the cross sections. Then make 
                               a third trace by coping the first.
                               There was an error in reversing the traces.
   S.G. Catron     08/01/90  : Added code to up the degree if the trace
                               was order 2, 2 poles and there were surface
                               tangents input.
   S.G. Catron     08/06/90  : Added code in the numtrc = 1 case, to use
                               the principal normal if the trace was
                               non-planar and smooth, when you're finding
                               the tmat's.
   S.G. Catron     09/14/90  : Changed the if statement for 1 trace when
                               finding the smat.[If( code == 3 || numcs
                               > 1 )...changed to...If( code == 3 ) ]
                               Also changed to always allocate for smat's.
   S.G. Catron     09/17/90  : In deciding which output to use from either
                               BSmdistcvcv or BSpl_cv_int, if it's the
                               first or last cross section and the 
                               parameter is either t[deg] or t[np], then
                               use output from BSmdistcvcv.
   S.G. Catron     10/15/90  : I added some code to make sure the trace
                               curve had enough knots when there was a 
                               law curve input.
   S.G. Catron     10/16/90  : I didn't initialize increasenp to FALSE.
   S.G. Catron     10/18/90  : The booleans for degenerate traces were
                               messed up when I copied first trace to 
                               last trace because the cross section was
                               closed.(tdegen0 and tdegen1)
   S.G. Catron     10/21/90  : I fixed all the apogee compiler problems.
   S.G. Catron     11/14/90  : I changed the law curve that is created 
                               when one is not input.
   S.G. Catron     12/14/90  : There was a problem when the trace was 
                               closed and the first cross section didn't
                               touch the trace.  It was finding the wrong
                               trace parameter value for that first 
                               cross section.
   S.G. Catron     01/04/91  : If cross section first pole touches trace
                               with dist_tol, then set cross section pole
                               exactly to trace point.  Also moved static
                               routine to top.
   S.G. Catron     01/17/91  : There was a problem with having a 
                               degenerate trace  second and the cross
                               section closed.  The array of cross
                               section parameters(csparsar) was not being
                               set correctly.
   S.G. Catron     03/04/91  : Fixed memory problem with tcvs.  It happens
                               when cross sections are closed and first 
                               curve gets copied to last curve and numtrc 
                               increased.
   S.G. Catron     03/05/91  : Error in using ttrcurves when it should
                               be using tcvs.
   S.G. Catron     04/06/91  : Fixed the correction done two days ago.
                               It was not freeing all the memory for the
                               one trace case.
   S.G. Catron     08/13/91  : If cross sections are closed and numtrc
                               is 2 _a_n_d orient_abs, then don't increase
                               numtrc as usual, because orient_abs does
                               not work for more than 2 traces. 
   S.G. Catron     10/22/91  : Changed tolerance check for numtrc > 2 and
                               section not touching trace.  Use dist_tol
                               instead of chrdht_tol.
   S.G. Catron     11/15/91  : Added check for degenerate interior trace 
                               curves.  Shuffle was erroring due to 
                               degeneracy.                                
   S.G. Catron     01/09/92  : Normally you only get one minimum distance 
                               point from BSmdistcvcv, but for this case 
                               there was an overlap...the trace was very
                               small but not degenerate...so, I added code
                               that checks to see which point is really 
                               the minimum distance.
   S.G. Catron     01/10/92  : There was a bug in one of the calls to 
                               BScveval.  The number of derivatives should
                               be 0 instead of 1.(There was only space
                               for 0)
   S.G. Catron     01/16/92  : I commented out a section of code that was
                               overwriting the input cross section first
                               and last pole.  This happened when the 
                               trace touched the first or last pole of 
                               section within dist_tol, but I over wrote 
                               the pole with the intersection point from 
                               BSmdistcvcv.
   S.G. Catron     03/19/92  : There was a bug in the code that checks
                               the BSpl_cv_int parameters against the
                               BSmdistcvcv parameter.  This happens when
                               trclosed = TRUE.
   S.G. Catron     03/09/93  : Accessing cscurves out of bounds on
                               call to tanvecBSmvxsectrc.(cscurves is not
                               used in tanvecBSmvxsectrc)
   S.G. Catron     03/17/93  : Added error check to see if someone passed
                               only 1 cross section and it's degenerate.
                               (purify)
   S.G. Catron     05/28/93  : Don't return error for numtrc =3 and 1
                               cross section.
   S.G. Catron     08/30/93  : Changed the code when on_site, cross 
                               section is linear and vecsum and trcnvec
                               are collinear.  Set smat[2] to the tansum.
                               This fixes Ulli's skinning problem.
   S.G. Catron     12/02/93  : Added code to set cross section parameter
                               values(csparsar[j][i]) to cusp value if
                               it is within tolerance.
   S.G. Catron     01/06/94  : I need to initialize p1bnd to 0 every
                               time there is a call to BSpl_cv_int and
                               there is more than 1 intersection.
                               Fix for TR 119310338.
   S.G. Catron     03/25/94  : Initialize "tol".(to take care of compile 
                               warning about potentially uninitialized)
   S.G. Catron     07/22/94  : Added an extra check in section where the
                               first(last) cross section is closest to
                               trace knot[deg].  We need to check if the
                               plane of the cross section is within
                               cht to trace endpoint.
    Vivian Y.Hsu 12/10/97  :  Fixed compile warning of gcc in PCSOL.
    S.G. Catron   08/02/00 :  Do not shuffle cross section(s) if only
                              one trace and one cross section OR if
                              one trace and multiple cross sections
                              and the cross sections all have the same
                              minimum distance parameter to the trace
                              curve.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsstk.h"
#include "bsparameters.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsmemory.h"
#include "bstypes.h"
#endif

#define BSVOID
#include <math.h>
#define MAXNUM 100
#define MAXNUM2 200
#define MINPOLES  10

static void tanvecBSmvxsectrc(
IGRint              tnumtrc,
struct IGRbsp_curve *tcvs[],
IGRint              j,
IGRdouble           **trparsar,
IGRboolean          allopen,
struct IGRbsp_curve *cscv,
IGRint              tanvec,
IGRvector           vecsum, 
IGRvector	   tansum,
IGRpoint            trcpt,
BSrc                *rc)

{
#ifndef DONOTSPROTO
#include "bscveval.h"
#endif 
   IGRint i,k, num_derv, n_int, div;
   IGRpoint eval[2], lasteval, leval[2], reval[2];

   *rc = BSSUCC;

   if( tanvec == 0 || tanvec == 2 )
      num_derv = 1;
   else
      num_derv = 0;
   for(i=0; i< tnumtrc; i++)
   {
      if( !allopen && i > 1)
         continue;
      BScveval( tcvs[i], trparsar[i][j], num_derv, eval, rc );
      if (BSERROR(*rc))
         goto wrapup;
      if(  i > 0)
      {
         /* sum vectors between traces, so we can later take
            average */
         /* sum tangents so we can later take average */
         for(k=0; k<3; k++)
         {
            if( tanvec != 0 )
            {
               vecsum[k] += (eval[0][k] - lasteval[k]);
               lasteval[k] = eval[0][k];
            }
            if( tanvec != 1 )
               tansum[k] += eval[1][k];
         }
      }
      else
      {
         /* initialize tangent and set point to last eval for
            use in next loop */
         for(k=0; k<3; k++)
         {
            trcpt[k] = eval[0][k];
            if( tanvec == 3 )
               /* only want the trace point */
               goto wrapup;
            if( tanvec != 1 )
               tansum[k] = eval[1][k];
            if( tanvec != 0 )
            {
               lasteval[k] = eval[0][k];
               vecsum[k] = 0.0;
            }

         }
      }
   } /* end for */
   if( tnumtrc > 1 )
   {
      if( !allopen && tnumtrc > 2 )
         div = tnumtrc -1;
      else
         div = tnumtrc;
      for(i=0; i<3; i++)
      {
         if( tanvec != 1 )
            tansum[i] /= div;
         if( tanvec != 0 )
            vecsum[i] /= (div-1);
      }
   }
   else
   {
      if( tanvec == 2 || tanvec == 1 )
      {
         if(allopen )
         {
            /* all cross sections are open, so find vector 
              between first and last pole */
            n_int = cscv->num_poles-1;
            if( cscv->rational )
            {
               for(k=0; k<3; k++)
                  vecsum[k] = cscv->poles[n_int*3+k]/ cscv->weights[n_int]
                              - cscv->poles[k] /  cscv->weights[0];
            }
            else
            {
               for(k=0; k<3; k++)
                  vecsum[k] = cscv->poles[n_int*3+k] - cscv->poles[k];
            }
         }
         else
         {
            num_derv = 1;
            /* some cross sections are closed */
            /* average first and last tangents */
            BScveval( cscv, cscv->knots[cscv->order-1], num_derv, leval, 
                      rc );
            if (BSERROR(*rc))
               goto wrapup;
            BScveval( cscv, cscv->knots[cscv->num_poles], num_derv, reval,
                      rc );
            if (BSERROR(*rc))
               goto wrapup;
            for(k=0; k<3; k++)
               vecsum[k] = (leval[1][k] + reval[1][k]) / 2.0;
         }
      }
   }

   wrapup:
   return;
}


static void linBSmvxsectrc(
struct IGRbsp_curve *tcv,
IGRdouble           tknot_tol,
IGRboolean          *linearpieces,
BSrc                *rc)
{

#ifndef DONOTSPROTO
#include "bscollinmn2.h"
#include "bsfindmkts.h"
#endif 
   IGRboolean collin, tmulalloc=FALSE, indexalloc=FALSE;
   IGRint *index=NULL, aindex[MAXNUM], num_mul,
          num, i, sum;
   IGRdouble *tmul=NULL, atmul[MAXNUM], *wts=NULL;

   *rc = BSSUCC;

   if( tcv->num_poles > MAXNUM )
   {
      tmul = (IGRdouble *)BSstackalloc((unsigned)( tcv->num_poles *
                                   sizeof(IGRdouble)));
      if(!tmul )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      tmulalloc = TRUE;
      index = (IGRint *)BSstackalloc((unsigned)( tcv->num_poles * 
                                        sizeof(IGRint)));
      if(! index )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      indexalloc = TRUE;
   }
   else
   {
      tmul = atmul;
      index = aindex;
   }
   (void)BSfindmkts(rc, &tcv->order, &tcv->num_poles, tcv->knots, 
                       &tknot_tol, &num_mul, tmul, index);
   if(BSERROR(*rc))
     goto wrapup;
   *linearpieces = FALSE;
   sum = 0;
   for(i=0; i<= num_mul; i++)
   {
      if( num_mul == 0 )
      {
         num = tcv->num_poles;
      }
      else
      {
         if( i == 0 )
            num = index[0];
         else
         {
            if( i == num_mul )
               num = tcv->num_poles - index[i-1] + 1;
            else
               num = index[i] - index[i-1] +1 ;
         }
      }
      if( tcv->rational)
         BScollinmn2(num, (IGRpoint *)&tcv->poles[sum*3], 
                     &tcv->weights[sum], &collin, rc);
      else
         BScollinmn2(num, (IGRpoint *)&tcv->poles[sum*3], wts, &collin,
                     rc);

      if(BSERROR(*rc))
         goto wrapup;
      sum += (num-1);
      if( collin )
      {
         *linearpieces = TRUE;
         break;
      }
   }

   wrapup:
   if( index && indexalloc )
      BSstackdealloc((char *) index );
   if( tmul && tmulalloc )
      BSstackdealloc((char *) tmul );
   return;
}

void BSmvxsectrc(
IGRint                numtrc,
struct IGRbsp_curve   *trcurves[],
IGRint                numcs,
struct IGRbsp_curve   *cscurves[],
IGRboolean            on_site,
IGRboolean            scale_height,
IGRdouble             trpars[],
IGRboolean            orient_abs,
IGRdouble             vmat[3][3],
IGRpoint              orig[],
IGRpoint              dir_x[],
 IGRpoint	 dir_y[],
IGRboolean            const_dir,
IGRboolean            closed,

IGRboolean            shapelaw,
struct IGRbsp_curve   *slawcvs[],
IGRboolean            orientlaw,
struct IGRbsp_curve   *olawcvs[],
struct IGRbsp_surface *tsf1,
 struct IGRbsp_surface 	 *tsf2,
struct IGRbsp_surface                       *ssf1,
 struct IGRbsp_surface 	 *ssf2,
struct IGRbsp_surface **surf,
BSrc                  *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscveval.h"
#include "bsmdistcvcv.h"
#include "bsbrkcvaprs.h"
#include "bscrossp.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bspl_cv_int.h"
#include "bsdotp.h"
#include "bsavgpts.h"
#include "bsortcrstrc.h"
#include "bsplanar2.h"
#include "bscvoton.h"
#include "bscvntoo.h"
#include "bsclcvshffl.h"
#include "bscv_copy.h"
#include "bsarclength.h"
#include "bscumdist.h"
#include "bschangepar.h"
#include "bsmkcstrsf.h"
#include "bscvkttol2.h"
#include "bststcvdegn.h"
#include "bsmdstptcv.h"
#include "bsallocsf.h"
#include "bsalloccv.h"
#include "bsmkcvscp.h"
#include "bssf_proj.h"
#include "bsruled_sf1.h"
#include "bslenvecsq.h"
#include "bsprncp_nor.h"
#include "bsadd_kts.h"
#include "bscv_enokts.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bsfndcvcsp.h"
#include "bsupthedegr.h"
#include "bsproj1.h"
#endif 
   IGRdouble par1, par2, *p1=NULL,
             mmdist, tdeg, tnp, *par=NULL,
             apar[MAXNUM],
             *p2=NULL, **trparsar=NULL,
             *trp[MAXNUM], trarray[MAXNUM],
             **csparsar=NULL, *csp[MAXNUM],
             csarray[MAXNUM], sttrpar, *newkts=NULL,
             scale=1.0, lknots[MAXNUM2], anewkts[MAXNUM],
             gknots[MAXNUM2], sqdist, dist_sqtol, dist_tol,
             mdist, dist, lweights[MAXNUM2],
             gweights[MAXNUM2], dot, acsps[MAXNUM],
             *u1=NULL, *a=NULL, *b=NULL, *csps=NULL,
             au1[MAXNUM], aa[MAXNUM],bb[MAXNUM],
             *arcl=NULL, aarcl[MAXNUM], tdist, 
             tknots[MAXNUM], *sarcl=NULL, asarcl[MAXNUM],
             tweights[MAXNUM], del, deg, np,d=0, dd=0,
             cknots[8], chrdht_tol, cumdist, arclen_tol,
             temp_tol, knot_tol, cross_sqtol, len, delta0=0, delta1=0,
             cknot_tol, *ptr, *ptr2, *wptr, *wptr2, tol=0.0;
   IGRvector lft_norm, trcnvec,
             tansum, vecsum, nvec, vec;
   IGRpoint  pt1, pt2, *pts1=NULL, 
             *pts2=NULL, lpoles[MAXNUM2],
             gpoles[MAXNUM2], eval[2],
             avgpt, *int_pts=NULL,pjpt,
             aint_pts[MAXNUM], tpoles[MAXNUM],
             cpoles[4], trcpt, ppts1, ppts2;
   IGRint    i, j, k, sizeg=0, m_int, newnump,
             sizel=0, sum=0, count, code,
             n_int, n_seg, num_derv=1, nd0=0,
             max, sumpoles, sumknots, ind=0,
             num_poles, num_knots, sizet=0, sum2=0,
             tanvec, index, tnumtrc=numtrc, tn, ncsp,
             num_csp;
   IGRshort  degg = 3, p1bnd=0;
   IGRboolean status, dir=TRUE, csclosed=FALSE, trclosed=FALSE,
              tst_plan=FALSE, increasedeg=FALSE, okay,
              torient_abs=orient_abs, *nonvec=NULL, anonvec[MAXNUM],
              allopen, degen0, degen1, alltouch=TRUE, *degen=NULL,
              tscale_height, adegen[MAXNUM],
              tequal, allocttrcurves=FALSE, shuffle=FALSE, same_par=FALSE,
              csparsaralloc=FALSE, rule=FALSE, enough_memory=TRUE,
              tcode, linearpieces, smooth=FALSE, cspsalloc=FALSE,
              increasenp=FALSE, newktsalloc=FALSE, degenalloc=FALSE,
              int_ptsalloc=FALSE, aalloc=FALSE, balloc=FALSE,
              u1alloc=FALSE, alreadyset,
              paralloc=FALSE;
   BSmat     *smat=NULL, asmat[MAXNUM],
             *tmat=NULL, atmat[MAXNUM];
   struct IGRbsp_curve **csl=NULL, **csg=NULL,
             *acsl[MAXNUM], *acsg[MAXNUM],
             **tcvs=NULL, *atcvs[MAXNUM],
             *csptr, *trptr, **lawcvss=NULL,
             *alawcvss[MAXNUM], **lawcvso=NULL,
             *alawcvso[MAXNUM], curve, **ttrcurves=NULL,
             *attrcurves[MAXNUM], *cpcscvs[2], *savetcvs=NULL,
             *tcv;
   BSrc      rc1;

   *rc = BSSUCC;
   if( numtrc > 1 && !on_site )
   {
      *rc = BSINARG;
      goto wrapup;
   }
   if( numtrc > 3 && numcs == 1 )
   {
      *rc = BSINARG;
      goto wrapup;
   } 

   tscale_height = scale_height;
   if( numtrc > 2 )
      tscale_height = TRUE;

   BSEXTRACTPAR(rc, BSTOLARCLEN, arclen_tol);
   BSEXTRACTPAR(rc, BSTOLSQLENVEC, dist_sqtol);
   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);
   BSEXTRACTPAR(rc, BSTOLCHRDHT, chrdht_tol);
   BSEXTRACTPAR(rc, BSTOLSQCOLLINVEC, cross_sqtol);

   cpcscvs[0] = NULL;
   cpcscvs[1] = NULL;
   if( numtrc < 3 && trcurves[0]->order == 2 && (numcs == 2 || numcs == 1)
       && !shapelaw && !orientlaw )
   {
      if( trcurves[0]->num_poles == 2 )
      {
         rule = FALSE;
         if( numtrc == 2 )
         {
            if( trcurves[1]->order == 2 && trcurves[1]->num_poles == 2 &&
                 numcs == 2)
               rule = TRUE;
         }
         else
            rule = TRUE;
         if( rule )
         {
            if( numcs == 2 )
            {
               BSmkcvscp(numcs, cscurves, cpcscvs, rc);
               if(BSERROR(*rc))
                  goto wrapup;
               j = 2;
               BSallocsf(cpcscvs[0]->order, cpcscvs[0]->order,
                         cpcscvs[0]->num_poles, j, cpcscvs[0]->rational, 
                         0, surf, rc);
               if(BSERROR(*rc))
                  goto wrapup;
               (void)BSruled_sf1(rc, cpcscvs[0], cpcscvs[1], *surf);
            }
            else
            {
               j = 2;
               BSallocsf(cscurves[0]->order, cscurves[0]->order,
                      cscurves[0]->num_poles, j, cscurves[0]->rational,
                        0, surf, rc);
               if(BSERROR(*rc))
                  goto wrapup;
               if( trcurves[0]->rational)
               {
                  for(i=0; i<3; i++)
                  {
                     pt1[i] = trcurves[0]->poles[i] / 
                                 trcurves[0]->weights[0];
                     pt2[i] = trcurves[0]->poles[3+i] / 
                                 trcurves[0]->weights[1];
                  }
               }
               else
               {
                  for(i=0; i<3; i++)
                  {
                     pt1[i] = trcurves[0]->poles[i]; 
                     pt2[i] = trcurves[0]->poles[3+i];
                  }
               }
               (void)BSsf_proj(rc, cscurves[0], pt1, pt2, *surf);
            }
            goto wrapup;
         }
      }
   }   

   if( closed )
   {
      /* check to see if all the traces are closed */
      for(i=0; i< numtrc; i++)
      {
         par1 = trcurves[i]->knots[trcurves[i]->order - 1];
         par2 = trcurves[i]->knots[trcurves[i]->num_poles];
         BScveval( trcurves[i], par1, 0, (IGRpoint *)pt1, rc );
         if (BSERROR(*rc))
            goto wrapup;

         BScveval( trcurves[i], par2, 0, (IGRpoint *)pt2, rc );
         if (BSERROR(*rc))
            goto wrapup;

         sqdist = BSdistptpts( rc, pt1, pt2 );
         if (BSERROR(*rc))
            goto wrapup;

         if (sqdist > dist_sqtol)
         {
            *rc = BSINARG;
            goto wrapup;
         }  
      }
   }
   degen0 = FALSE;
   degen1 = FALSE;
   if( numtrc > 1 && numcs == 1)
   {
      degen0 = TRUE;
      degen1 = TRUE;
      par1 = trcurves[0]->knots[trcurves[0]->order - 1];
      BScveval( trcurves[0], par1, 0, (IGRpoint *)pt1, rc );
      if (BSERROR(*rc))
         goto wrapup;
      for(i=1; i< numtrc; i++)
      {
         /* check trace endpoints for degeneracy */
         par1 = trcurves[i]->knots[trcurves[i]->order - 1];
         BScveval( trcurves[i], par1, 0, (IGRpoint *)pt2, rc );
         if (BSERROR(*rc))
            goto wrapup;
         sqdist = BSdistptpts( rc, pt1, pt2 );
         if (BSERROR(*rc))
            goto wrapup;
         if (sqdist > dist_sqtol)
         {
            degen0 = FALSE;
            break;
         }
      }
      par1 = trcurves[0]->knots[trcurves[0]->num_poles];
      BScveval( trcurves[0], par1, 0, (IGRpoint *)pt1, rc );
      if (BSERROR(*rc))
         goto wrapup;
      for(i=1; i< numtrc; i++)
      {
         /* check trace endpoints for degeneracy */
         par1 = trcurves[i]->knots[trcurves[i]->num_poles];
         BScveval( trcurves[i], par1, 0, (IGRpoint *)pt2, rc );
         if (BSERROR(*rc))
            goto wrapup;
         sqdist = BSdistptpts( rc, pt1, pt2 );
         if (BSERROR(*rc))
            goto wrapup;
         if (sqdist > dist_sqtol)
         {
            degen1 = FALSE;
            break;
         }
      }
   }
   else
   {
      /* check if the cross sections are degenerate */
      BStstcvdegn(cscurves[0], &degen0, rc);
      if(BSERROR(*rc))
         goto wrapup;
      if( degen0 && numcs == 1 )
      {
         *rc = BSINARG;
         goto wrapup;
      }
      if( numcs > 1 )
      {
         BStstcvdegn(cscurves[numcs-1], &degen1, rc);
         if(BSERROR(*rc))
            goto wrapup;
      }
   }
   if( numcs == 1 && degen0 )
   {
      *rc = BSINARG;
      goto wrapup;
   }

   if(orient_abs && numtrc > 2 )
   {
      torient_abs = FALSE;
   }

   allopen = TRUE;
   for(i=0; i<numcs; i++)
   {
      if( (i == 0 && degen0) || (i == numcs -1 && degen1) )
         continue;
      if( cscurves[i]->phy_closed )
      {
         csclosed = TRUE;
         allopen = FALSE;
      }
   }
   if( csclosed && !(numtrc == 1 && numcs == 1) )
      shuffle = TRUE;
   if( shuffle && numtrc == 1 )
      same_par = TRUE;
      
   tequal = TRUE;
   if( csclosed && numtrc > 2)
   {
      /* check to see if the first trace and the last trace are the same..
         if they are not, then add a last curve equal to the first  */
      tequal = FALSE;
      if( trcurves[0]->num_poles == trcurves[numtrc-1]->num_poles &&
          trcurves[0]->order == trcurves[numtrc-1]->order &&
          trcurves[0]->rational == trcurves[numtrc-1]->rational )
      {
         tequal = TRUE;
         if( trcurves[0]->rational )
         {
            ptr = trcurves[0]->poles;
            wptr = trcurves[0]->weights;
            ptr2 = trcurves[numtrc-1]->poles;
            wptr2 = trcurves[numtrc -1]->weights;
            for(i=0; i< trcurves[0]->num_poles; i++)
            {
               sqdist = 0;
               for(j=0; j<3; j++)
               {
                  sqdist += (*ptr / *wptr - *ptr2 / *wptr2) * 
                          (*ptr / *wptr - *ptr2 / *wptr2) ;
                  ptr++;
                  ptr2++;
               }
               if( sqdist > dist_sqtol )
               {
                  tequal = FALSE;
                  break;
               }
               wptr++;
               wptr2++;
            }
         }
         else
         {
            for(i=0; i< trcurves[0]->num_poles; i++)
            {
               ptr = trcurves[0]->poles;               
               ptr2 = trcurves[numtrc-1]->poles;
               sqdist = BSdistptpts(rc, ptr, ptr2 );
               if(BSERROR(*rc))
                  goto wrapup;
               if( sqdist > dist_sqtol)
               {
                  tequal = FALSE;
                  break;
               }
               ptr += 3;
               ptr2 += 3;
            }
         }
      }
      
   }        
   if( !tequal )
      tnumtrc = numtrc + 1;

   if( tnumtrc > MAXNUM )
   {
      ttrcurves = (struct IGRbsp_curve **)BSstackalloc((unsigned)(
                  tnumtrc * sizeof(struct IGRbsp_curve  *)));
      if( !ttrcurves )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      allocttrcurves = TRUE;
   }
   else
   {
      ttrcurves = attrcurves;
   }

   if( csclosed && numtrc > 2 )
   {
      /* now check to see if the traces are oriented correctly around
         the closed cross section */
      if( degen0)
         index = numcs -1;
      else
         index = 0;
      if( cscurves[index]->rational)
         for(i=0; i<3; i++)
            pt1[i] = cscurves[index]->poles[i]/cscurves[index]->weights[0];
      else
         for(i=0; i<3; i++)
            pt1[i] = cscurves[index]->poles[i];
      j = 0;
      BSmdstptcv(trcurves[0], pt1, &par1, pt2, &mdist, rc);
      if(BSERROR(*rc))
         goto wrapup;
      for(i=1; i< numtrc; i++)
      {
         BSmdstptcv(trcurves[i], pt1, &par1, pt2, &dist, rc);
         if(BSERROR(*rc))
            goto wrapup;
         if( dist < mdist )
         {
            mdist = dist;
            j = i;
         }
      }
      k = (j+1) % numtrc;
      if( trcurves[k]->rational)
         for(i=0; i<3; i++)
            pt1[i] =trcurves[k]->poles[i]/trcurves[k]->weights[0];
      else
         for(i=0; i<3; i++)
            pt1[i] = trcurves[k]->poles[i];
      BSmdstptcv(cscurves[index], pt1, &par1, pt2, &dist, rc);
      if(BSERROR(*rc))
         goto wrapup;
      k = (j+2) % numtrc;
      if( trcurves[k]->rational)
         for(i=0; i<3; i++)
            pt1[i] = trcurves[k]->poles[i]/trcurves[k]->weights[0];
      else
         for(i=0; i<3; i++)
            pt1[i] = trcurves[k]->poles[i];
      BSmdstptcv(cscurves[index], pt1, &par2, pt2, &dist, rc);
      if(BSERROR(*rc))
         goto wrapup;
      if( par1 > par2 )
      {
         /* we need to reverse the trace order */
         for(i=0; i< numtrc; i++)
         {
            k = j - i;
            if( k < 0 )
               k = numtrc - tequal + k;
            ttrcurves[i] = trcurves[k];
         }
      }            
      else
      {
         for(i=0; i<numtrc; i++)
         {
            k = (j+i) % (numtrc-tequal);
            ttrcurves[i] = trcurves[k]; 
         }
      }
   }
   else
      for(i=0; i<numtrc; i++)
         ttrcurves[i] = trcurves[i];
   if( !tequal )
      ttrcurves[i] = ttrcurves[0];

   if( tnumtrc > MAXNUM )
   {
      degen = (IGRboolean *)BSstackalloc((unsigned)( tnumtrc * sizeof
                                (IGRboolean )));
      if(! degen )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      degenalloc = TRUE;
   }
   else
      degen = adegen;
   for(i=0; i<tnumtrc; i++)
   {
      BStstcvdegn(ttrcurves[i], &degen[i], rc);
      if(BSERROR(*rc))
         goto wrapup;
   }
   if( degen[0] )
   {
      delta0 = numcs > 1 ? (numcs -1) : 1;
      delta0 =(ttrcurves[0]->knots[ttrcurves[0]->num_poles]
              - ttrcurves[0]->knots[ttrcurves[0]->order-1]) / delta0;
   }
   j = tnumtrc -1;
   if( degen[j] )
   {
      delta1 = numcs > 1 ? (numcs -1) : 1;
      delta1 =(ttrcurves[j]->knots[ttrcurves[j]->num_poles]
              - ttrcurves[j]->knots[ttrcurves[j]->order-1]) / delta1;
   }
   if( degen[0] && tnumtrc == 1 )
   {
      *rc = BSINARG;
      goto wrapup;
   }
      
   trclosed = FALSE;
   for(i=0; i<tnumtrc; i++)
   {
      if( degen[i] )
         continue;
      if( ttrcurves[i]->phy_closed )
         trclosed = TRUE;
   }
   BScvkttol2(ttrcurves[0]->order, ttrcurves[0]->knots, 
              ttrcurves[0]->num_poles, ttrcurves[0]->poles, 
              ttrcurves[0]->weights, &knot_tol, rc);
   if(BSERROR(*rc))
      goto wrapup;
   BScvkttol2(cscurves[0]->order, cscurves[0]->knots, 
              cscurves[0]->num_poles, cscurves[0]->poles, 
              cscurves[0]->weights, &cknot_tol, rc);
   if(BSERROR(*rc))
      goto wrapup;
   if( trclosed )
   {
      if( !on_site )
      {
         /* if first and last cross not at the same place on the
            trace, then we don't need to shuffle */
         if( fabs(trpars[0] - trpars[numcs-1]) > knot_tol )
            trclosed = FALSE;
      }
   }
   if( numcs > MAXNUM )
   {
      csl = (struct IGRbsp_curve **)BSstackalloc((unsigned)(
                    numcs * sizeof(struct IGRbsp_curve  *)));
      if( !csl )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      csl = acsl;
   }

   sumknots = 0;
   sumpoles = 0;
   sizel = numcs;
   for(i=0; i<numcs; i++)
   {
      num_poles = cscurves[i]->phy_closed ? 2 * cscurves[i]->num_poles-1 :
                  cscurves[i]->num_poles;
      num_knots = num_poles + cscurves[i]->order;
      if( (sumknots + num_knots) > MAXNUM )
      {
         sizel = i;
         break;
      }
      csl[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)(
                            sizeof(struct IGRbsp_curve )));
      if(!csl[i])
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      csl[i]->poles = &lpoles[sumpoles][0];
      csl[i]->knots = &lknots[sumknots];
      csl[i]->weights = NULL;
      if( cscurves[i]->rational )
         csl[i]->weights = &lweights[sumpoles];
      else
         csl[i]->weights = NULL;
      sumknots += num_knots;
      sumpoles += num_poles;
   }
   if( numcs > sizel )
   {
      for(i = sizel; i< numcs; i++)
      {
         num_poles = cscurves[i]->phy_closed ? 2 * cscurves[i]->num_poles
                     -1 : cscurves[i]->num_poles;
         num_knots = num_poles + cscurves[i]->order;
         BSstkallocv(rc, csl[i], num_poles, cscurves[i]->rational, 
                     num_knots, NULL);
         if(BSERROR(*rc))
         {
            goto wrapup;
         }
      }
   }
   
   if( csclosed || !on_site )
   {
      if( numcs > MAXNUM )
      {
         csg = (struct IGRbsp_curve **)BSstackalloc((unsigned)(
                       numcs * sizeof(struct IGRbsp_curve  *)));
         if( !csg )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         csg = acsg;
      }
      for(i=0; i<numcs; i++)
         csg[i] = NULL;
      sumknots = 0;
      sumpoles = 0;
      sizeg = numcs;
      for(i=0; i<numcs; i++)
      {
         num_poles = cscurves[i]->phy_closed ? 2 * cscurves[i]->num_poles
                     -1 : cscurves[i]->num_poles;
         num_knots = num_poles + cscurves[i]->order;
         if( (sumknots + num_knots) > MAXNUM )
         {
            sizeg = i;
            break;
         }
         csg[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)(
                               sizeof(struct IGRbsp_curve )));
         if(!csg[i])
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         csg[i]->poles = &gpoles[sumpoles][0];
         csg[i]->knots = &gknots[sumknots];
         csg[i]->weights = NULL;
         if( cscurves[i]->rational )
            csg[i]->weights = &gweights[sumpoles];
         else
            csg[i]->weights = NULL;
         sumknots += num_knots;
         sumpoles += num_poles;
      }
      if( numcs > sizeg )
      {
         for(i = sizeg; i< numcs; i++)
         {
            num_poles = cscurves[i]->phy_closed ? 2*cscurves[i]->num_poles
                        -1 : cscurves[i]->num_poles;
            num_knots = num_poles + cscurves[i]->order;
            BSstkallocv(rc, csg[i], num_poles, cscurves[i]->rational, 
                        num_knots, NULL);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
   }
   else
   {
      csg = cscurves;
   }
   if( csclosed && numtrc ==2 )
      /* allocate an extra one in case we want to copy the first trace
         to a third trace if necessary */
      i = tnumtrc + 1;
   else
      i = tnumtrc;

   if( i > MAXNUM )
   {
      tcvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)(
                    i * sizeof(struct IGRbsp_curve  *)));
      if( !tcvs )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      tcvs = atcvs;
   }
   for(i=0; i< tnumtrc; i++)
      tcvs[i] = NULL;

   if( (ttrcurves[0]->num_poles == 2 ) && 
       (shapelaw || orientlaw || ssf1 || ssf2) )
   {
      increasedeg = TRUE;
      for(i=1; i< tnumtrc; i++)    
      {
         if( ttrcurves[i]->order != 2 )
         {
            increasedeg = FALSE;
            break;
         }
      }  
   }

   if( trclosed  || increasedeg )
   {
      sumknots = 0;
      sumpoles = 0;
      sizet = tnumtrc;
      for(i=0; i<tnumtrc; i++)
      {
         if( degen[i] )
            continue;
         if( increasedeg )
         {
            if( ttrcurves[i]->phy_closed )
               num_poles = 2 * ttrcurves[i]->num_poles+1 +
                      (ttrcurves[i]->num_poles-ttrcurves[i]->order)*2;
            else
               num_poles = ttrcurves[i]->num_poles + 2 + 
                        (ttrcurves[i]->num_poles-ttrcurves[i]->order)*2;
            num_knots = num_poles + 4;
         }
         else
         {
            if( ttrcurves[i]->phy_closed )
               num_poles = 2*ttrcurves[i]->num_poles-1;
            else
               num_poles = ttrcurves[i]->num_poles;
            num_knots = num_poles + ttrcurves[i]->order;
         }
         if( (sumknots + num_knots) > MAXNUM )
         {
            sizet = i;
            break;
         }
         tcvs[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)(
                               sizeof(struct IGRbsp_curve )));
         if(!tcvs[i])
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         tcvs[i]->poles = &tpoles[sumpoles][0];
         tcvs[i]->knots = &tknots[sumknots];
         tcvs[i]->weights = NULL;
         if( ttrcurves[i]->rational )
            tcvs[i]->weights = &tweights[sumpoles];
         else
            tcvs[i]->weights = NULL;
         sumknots += num_knots;
         sumpoles += num_poles;
      }
      if( tnumtrc > sizet )
      {
         for(i = sizet; i< tnumtrc; i++)
         {
            num_poles = ttrcurves[i]->phy_closed ? 2*ttrcurves[i]->num_poles
                        -1 : ttrcurves[i]->num_poles;
            num_knots = num_poles + ttrcurves[i]->order;
            BSstkallocv(rc, tcvs[i], num_poles, ttrcurves[i]->rational, 
                        num_knots, NULL);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }
   }

   if( tnumtrc > 2 || shuffle)
   {
      csparsaralloc = TRUE;
      if( numcs > MAXNUM )
      {
         csparsar = (IGRdouble **)BSstackalloc((unsigned)( numcs * 
                                        sizeof(IGRdouble *)));
         if( !csparsar )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         csparsar = &csp[0];
      }
      if( csclosed && tnumtrc == 2 )
         tn = 3;
      else
         tn = tnumtrc;
      sum2 = MAXNUM / tn;
      count = 0;
      for(i=0; i< numcs; i++)
      {
         if( i >= sum2 )
         {
            csparsar[i] = (IGRdouble *)BSstackalloc((unsigned)( tn
                                  * sizeof(IGRdouble )));
            if( !csparsar[i] )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
         }
         else
         {
            csparsar[i] = &csarray[count];
            count += tn;
         }
      }
   }

   if( on_site )
   {
      /* since this must be on_site, then we need to find arrays of trace 
         parameters at each cross section intersection */
      sum = numcs;
      count = 0;
      if( csclosed && tnumtrc == 2 )
         tn = 3;
      else
         tn = tnumtrc;
      if( tn > MAXNUM )
      {
         trparsar = (IGRdouble **)BSstackalloc((unsigned)( tn * sizeof
                    (IGRdouble *)));
         if( !trparsar )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         trparsar = &trp[0];
      }
      sum = MAXNUM / numcs;
      for(i=0; i< tn; i++)
      {
         if( i >= sum )
         {
            trparsar[i] = (IGRdouble *)BSstackalloc((unsigned)( numcs
                                  * sizeof(IGRdouble )));
            if( !trparsar[i] )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
         }
         else
         {
            trparsar[i] = &trarray[count];
            count += numcs;
         }
      }
   }
   else
   {
      /* on_view */
      trparsar = &trp[0];
      if( trclosed )
      {
         if( numcs > MAXNUM )
         {
            trparsar[0] = (IGRdouble *)BSstackalloc((unsigned)( numcs
                                  * sizeof(IGRdouble )));
            if( !trparsar[0] )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
         }
         else
         {
            trparsar[0] = trarray;
         }

         /* need to copy trpars to trparsar because the parameters may
            have to be shuffled */
         for(i=0; i< numcs; i++)
            trparsar[0][i] = trpars[i];
      }
      else
      {
         trparsar[0] = trpars;
      }
   }

   /* allocate for each smat */
   if( numcs > MAXNUM )
   {
      smat = (BSmat *)BSstackalloc((unsigned)( numcs * sizeof
                                                            (BSmat)));
      if(! smat )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      smat = asmat;
   }

   if( !torient_abs && tnumtrc < 3 )
   {
      /* allocate for each tmat */
      if( numcs > MAXNUM )
      {
         tmat = (BSmat *)BSstackalloc((unsigned)( numcs * sizeof
                                                                (BSmat)));
         if(! tmat )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         tmat = atmat;
      }
   }
   /* I need some space for output from BSpl_cv_int, which needs to
      be maximum number of poles for the trace curves */
   max = ttrcurves[0]->num_poles;
   for(i=1; i< tnumtrc; i++)
   {
      if( ttrcurves[i]->num_poles > max )
         max = ttrcurves[i]->num_poles;
   }
   if( max > MAXNUM )
   {
      u1 = (IGRdouble *)BSstackalloc((unsigned)( max * 
                                          sizeof(IGRdouble)));
      if(!u1 )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      u1alloc = TRUE;
      a = (IGRdouble *)BSstackalloc((unsigned)( max * 
                                          sizeof(IGRdouble)));
      if(!a )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      aalloc = TRUE;
      b = (IGRdouble *)BSstackalloc((unsigned)( max * 
                                          sizeof(IGRdouble)));
      if(!b )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      balloc = TRUE;
      int_pts = (IGRpoint *)BSstackalloc((unsigned)( max * 
                                          sizeof(IGRpoint)));
      if(!int_pts )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      int_ptsalloc = TRUE;
   }
   else
   {
      u1 = au1;
      a = aa;
      b = bb;
      int_pts = aint_pts;
   }
   if( !orientlaw || !shapelaw )
   {
      if( numcs  > MAXNUM )
      {
         arcl = (IGRdouble *)BSstackalloc((unsigned)( numcs * sizeof
                                                        (IGRdouble)));
         if(! arcl )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         sarcl = (IGRdouble *)BSstackalloc((unsigned)( numcs * sizeof
                                                        (IGRdouble)));
         if(! sarcl )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         arcl = aarcl;
         sarcl = asarcl;
      }
   }
   if( !on_site )
   {
      for(i=0; i<numcs; i++)
      {
         BScveval( ttrcurves[0], trpars[i], num_derv, eval, rc );
         if (BSERROR(*rc))
            goto wrapup;
         if( (degen1 && i == numcs-1)  || (const_dir && i > 0 ) )
         {
            par1 = cscurves[i]->knots[cscurves[i]->order -1];
            BScveval(cscurves[i], par1, nd0, (IGRpoint *)pt1, rc);
            if(BSERROR(*rc))
               goto wrapup;
            if( degen1 && i == numcs -1 )
            {
               /* copy smat[0] and transform curve to global and local */
               for(j=0; j< 3; j++)
               {
                  smat[i][0][j] = smat[i-1][0][j];
                  smat[i][1][j] = smat[i-1][1][j];
                  smat[i][2][j] = smat[i-1][2][j];
               }
            }
            else
            {
               /* copy smat[0] and transform curve to global and local */
               for(j=0; j< 3; j++)
               {
                  smat[i][0][j] = smat[0][0][j];
                  smat[i][1][j] = smat[0][1][j];
                  smat[i][2][j] = smat[0][2][j];
               }
            }
            status = BScvoton(rc, pt1, vmat, &scale, cscurves[i], 
                              csl[i]);
            if(BSERROR(*rc))
               goto wrapup;
            status = BScvntoo(rc, eval[0], smat[i], &scale,csl[i],csg[i]);
            if(BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            BSortcrstrc(eval[0], dir_x[i], dir_y[i], cscurves[i], orig[i],
                        vmat, smat[i], csl[i], csg[i], rc);
            if(BSERROR(*rc))
              goto wrapup;
         }
      }
   }   
   if( on_site || (!on_site && (csclosed || trclosed) ) )
   {
      if( numcs > MAXNUM )
      {
         nonvec = (IGRboolean *)BSstackalloc((unsigned)( numcs * 
                                    sizeof(IGRboolean )));
         if(!nonvec )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
         nonvec = anonvec;
      if( tnumtrc > 2 || shuffle)
      {
         /* find the maximum number for array of cusps */
         max = 0;
         for(j=0; j< numcs; j++)
         {
            csptr = on_site ? cscurves[j] : csg[j];      
            max = MAX(csptr->num_poles, max );
         }
         if( max > MAXNUM )
         {
            par = (IGRdouble *)BSstackalloc((unsigned)( max * sizeof
                                          (IGRdouble )));
            if(! par )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            paralloc = TRUE;
         }
         else
            par = apar;
         tol = MAX(1e-3, cknot_tol * 100);
      }

      for(j=0; j< numcs; j++)
      { 
         csptr = on_site ? cscurves[j] : csg[j];
         nonvec[j] = FALSE;
         if( !orientlaw || !shapelaw )
            arcl[j] = 0.0;
         /* cut each trace with the plane of each jth cross section */
         status = BSavgpts(rc, csptr->num_poles,csptr->poles, 
                           csptr->weights, avgpt);
         if(BSERROR(*rc))
            goto wrapup;
         if( on_site )
         {
            BSplanar2(csptr->num_poles, (IGRpoint *)csptr->poles,
                      csptr->weights, &code, nvec, rc);
            if(BSERROR(*rc))
               goto wrapup;
            if( code == 2 || code == 1)
               nonvec[j] = TRUE;               
            if( tnumtrc < 3 && !nonvec[j])
            {
               for(k=0; k<3; k++)
                  smat[j][2][k] = nvec[k];
            }
         }
         else
         {
            for(k=0; k<3; k++)
               nvec[k] = smat[j][2][k];
         }

         if( tnumtrc > 2 || shuffle)
         {
            BSfndcvcsp(csptr, &num_csp, par, rc );
            if(BSERROR(*rc))
               goto wrapup;
            if( csptr->phy_closed && num_csp > 0)
            {
               /* check if t[deg] is a cusp, and if it is, add t[np] */
               if( fabs(par[0] - csptr->knots[csptr->order-1])<cknot_tol )
               {
                  par[num_csp] = csptr->knots[csptr->num_poles];
                  num_csp += 1;
               }
            }
         }

         for(i=0; i< tnumtrc; i++)
         {
            alreadyset = FALSE;
            if( (i == 0 || i == tnumtrc-1) && degen[i] )
            {  
               alreadyset = TRUE;
               if( i == 0 )
               {
                  trparsar[i][j] = j*delta0;
                  if( tnumtrc > 2 || shuffle)
                     csparsar[j][i] = csptr->knots[csptr->order-1];
               }
               else
               {
                  trparsar[i][j] = j*delta1;        
                  if( tnumtrc > 2 || shuffle)
                     csparsar[j][i] = csptr->knots[csptr->num_poles];
               }
               if( j == 0 )
               {
                  tcvs[i] = ttrcurves[i];               
                  tcvs[i]->phy_closed = FALSE;
               }
               if( !(csclosed && tnumtrc == 2 ) )
                  continue;
            }
            trptr = j == 0 ? ttrcurves[i] : tcvs[i];
            n_int = 0;
            dist = 0;
            BSmdistcvcv(trptr, csptr, &m_int, &p1, &p2, 
                        &pts1, &pts2, &dist, rc);
            if(BSERROR(*rc))
               goto wrapup;
            if( m_int > 1 )
            {
               /* normally you only get one minimum distance point, but
                  for one case there was an overlap...the trace was very
                  small but not degenerate...so, this code checks to see
                  which point is really the minimum distance */
               BScveval(trptr, p1[0], nd0, (IGRpoint *)ppts1, rc);
               if(BSERROR(*rc))
                  goto wrapup;
               BScveval(csptr, p2[0], nd0, (IGRpoint *)ppts2, rc);
               if(BSERROR(*rc))
                  goto wrapup;
               mdist = BSdistptpts(rc, ppts1, ppts2 );
               if(BSERROR(*rc))
                  goto wrapup;
               for(k=1; k<m_int; k++)
               {
                  BScveval(trptr, p1[k], nd0, (IGRpoint *)ppts1, rc);
                  if(BSERROR(*rc))
                     goto wrapup;
                  BScveval(csptr, p2[k], nd0, (IGRpoint *)ppts2, rc);
                  if(BSERROR(*rc))
                     goto wrapup;

                  mmdist = BSdistptpts(rc, ppts1, ppts2 );
                  if( mmdist < mdist )
                  {
                     p1[0] = p1[k];
                     p2[0] = p2[k];
                     mdist = mmdist;
                  }
               }
            }
            if( dist > dist_tol  )
            {
               if( tnumtrc > 2 )
               {
                  /* when more than 2 traces, they have to touch the
                     cross sections */
                  *rc = BSINARG;
                  goto wrapup;
               }
               if( dist > chrdht_tol  )
                  alltouch = FALSE;
            }
            okay = FALSE;
            if( dist > dist_tol && (j == 0 || j == numcs -1 ) )
            {
               if( j == 0 && fabs(p1[0] - trptr->knots[trptr->order-1])
                   < knot_tol )
                  okay = TRUE;
               else
                  if( j == numcs -1 && fabs(p1[0] - 
                            trptr->knots[trptr->num_poles]) < knot_tol)
                  okay = TRUE;
               if( okay)
               {
                  (void)BSproj1(rc, pts1[0], nvec, avgpt, pjpt );
                  if(BSERROR(*rc))
                     goto wrapup;
                  tdist = BSdistptpt(rc, pjpt, pts1[0] );
                  if( tdist > chrdht_tol )
                     okay = FALSE;
               }
            }

            if( dist > chrdht_tol && !nonvec[j] && !okay)
            {
               /* try plane curve intersection */
               status = BSpl_cv_int(rc, trptr, avgpt, nvec, &n_int, 
                             (IGRdouble *)int_pts, u1, &n_seg, a, b);
               if(BSERROR(*rc))
                  goto wrapup;
               if( n_seg > 0 )
               {
                  /* I don't believe you can have the cross section 
                     overlaping with the trace curve */
                  if( !degen[i] )
                  {
                     *rc = BSINARG;
                     goto wrapup;
                  }   
               }
               ind = 0;
               if( n_int > 1 )
               {
                  /* find the closest u1 to p1 and that will be our
                     parameter...be carefull with closed traces, some
                     parameters could be mixed between tdeg and tnp */
                  tdeg = trptr->knots[trptr->order -1];
                  tnp = trptr->knots[trptr->num_poles];

                  if( trclosed )
                  {
                     p1bnd = 0;
                     /* check for p1[0] or u1[] being t[deg] or t[np] */
                     if( fabs(p1[0] - tdeg) < knot_tol || 
                         fabs(p1[0] - tnp) < knot_tol  )
                        p1bnd = 1;
                     if( fabs(u1[0] - tdeg) < knot_tol || 
                         fabs(u1[0] - tnp) < knot_tol  )  
                     {
                        if( p1bnd)
                           p1bnd = 2;
                        else
                           d = MIN( fabs(tdeg - p1[0]) ,
                                    fabs(tnp - p1[0])  );
                     }
                     else
                     {
                        if( p1bnd )
                           d = MIN( fabs(tdeg - u1[0]) ,
                                    fabs(tnp - u1[0] ) );
                        else
                           d = fabs(u1[0] - p1[0]);
                     }
                  }
                  else
                     d = fabs(u1[0] - p1[0]);

                  if( p1bnd != 2 )
                  {
                     for(k=1; k< n_int;k++)
                     {
                        if( trclosed )
                        {
                           if( fabs(u1[k] - tdeg) < knot_tol || 
                               fabs(u1[k] - tnp) < knot_tol  )  
                           {
                              if( p1bnd)
                              {
                                 ind = k;
                                 break;
                              }
                              else
                                 dd = MIN( fabs(tdeg - p1[0]) ,
                                           fabs(tnp - p1[0])  );
                           }
                           else
                           {
                              if( p1bnd )
                                 dd = MIN( fabs(tdeg - u1[k]) ,
                                           fabs(tnp - u1[k]) );
                              else
                                 dd = fabs(u1[k] - p1[0]);
                           }
                        }
                        else
                           dd = fabs(u1[k] - p1[0]);
                        if( dd  < d )
                        {
                           d = dd;
                           ind = k;
                        }
                     }
                  }
               }           
               if( n_int == 0 )
               {
               
                  if( j == 0 && i == 0)
                  {
                     /* if mdistcvcv wasn't within tolerance and pl_cv_int
                        didn't find anything and if this is the first
                        cross section and first trace, THEN error */
                     *rc = BSINARG;
                     goto wrapup;
                  }
                  /* then use previous results from BSmdistcvcv  */
                  if( j == 0 )
                     sttrpar = p1[0];
                  if( on_site && !alreadyset)
                     trparsar[i][j] = p1[0];
                  if( tnumtrc > 2 || shuffle)
                     csparsar[j][i] = p2[0]; 
               }
               else 
               {
                  /* use output from BSpl_cv_int */
                  if( j == 0 )
                     sttrpar = u1[ind];
                  if( on_site && !alreadyset)
                     trparsar[i][j] = u1[ind];
                  else
                     sttrpar = trparsar[0][j];
               }
            }
            else
            {
               if( j == 0 && i == 0 && dist > chrdht_tol && !okay )
               {
                  /* if could not call pl_cv_int and dist > chrdht_tol
                     and first cross/trace  then error */
                  *rc = BSINARG;
                  goto wrapup;
               }
               /* set output from BSmdistcvcv */
               if( j == 0 )
                  sttrpar = p1[0];
               if( on_site && !alreadyset )
                  trparsar[i][j] = p1[0];
               if( !csptr->phy_closed && dist < dist_tol)
               {
                  if( fabs(p2[0] - csptr->knots[csptr->order-1]) <
                      cknot_tol )
                  {

                     /***** make sure the start of every cross section is 
                        exactly touching the trace 

I commented out this section, and section just below, because it was 
changing the input..causing output to be different in 1 or 2 loops.. 
commenting out did not make any noticable change in output
                     BSMEMCPY( sizeof(IGRpoint), pts1, csptr->poles );
                     if( csptr->rational)
                        for(k=0; k<3; k++)
                           csptr->poles[k] *= csptr->weights[0];
*/
                     p2[0] = csptr->knots[csptr->order-1];
                  }
                  else
                  {
                     if( fabs(p2[0] - csptr->knots[csptr->num_poles]) <
                         cknot_tol )
                     {
                        /* make sure the end of every cross section is 
                           exactly touching the trace */
  /*
                        BSMEMCPY( sizeof(IGRpoint), pts1, &csptr->poles[
                                  (csptr->num_poles-1)*3]);
                        if( csptr->rational)
                           for(k=0; k<3; k++)
                              csptr->poles[(csptr->num_poles-1)*3+k] *= 
                              csptr->weights[csptr->num_poles-1];
*/
                        p2[0] = csptr->knots[csptr->num_poles];
                     }
                  }
               }
               if( tnumtrc > 2 || shuffle)
               {
                  csparsar[j][i] = p2[0];
                  if( dist < 2 * chrdht_tol )
                  {
                     /* check to see if the parameter on the cross section
                        is within tolerance to a cusp value and if so, set
                        it to that cusp value */
                     for(k=0; k< num_csp; k++)
                     {
                        if( fabs(csparsar[j][i] - par[k]) < tol )
                        {
                           /* check the xyz distance */
                           BScveval(csptr, par[k],nd0,(IGRpoint *)pt1,rc);
                           if(BSERROR(*rc))
                              goto wrapup;
                           BScveval(trptr, trparsar[i][j], nd0, 
                                    (IGRpoint *)pt2, rc);
                           if(BSERROR(*rc))
                              goto wrapup;
                           dist = BSdistptpt(rc, pt1, pt2 );
                           if( dist < 2 * chrdht_tol )
                              csparsar[j][i] = par[k];
                           break;
                        }
                     }
                     /* check if 1 trace and shuffle=TRUE, if each parameter is the same */
                     if( numtrc == 1 && shuffle && same_par)
                     {
                        if( j > 0  && fabs(csparsar[j][i] - csparsar[j-1][i]) > cknot_tol )
                           same_par = FALSE;
                     }
                  }
               }
            }                     
            if( on_site )
            {
               if( j > 0 && trclosed )
                  if( (j == numcs-1 && trparsar[i][j] < trparsar[i][j-1])
                     || (j == 1 && fabs(trparsar[i][j]- trparsar[i][j-1])
                     < knot_tol ) )
                     trparsar[i][j] = tcvs[i]->knots[tcvs[i]->num_poles];
               if( tnumtrc > 2 )
                  if( i > 0 && csclosed )
                     if( csparsar[j][i] < csparsar[j][i-1])
                     {
                        /* parameters shouldn't be decreasing */
                        if( fabs(csparsar[j][i]- 
                            csptr->knots[csptr->order-1]) < cknot_tol)
                           csparsar[j][i] = csptr->knots[
                                            csptr->num_poles];
                        else
                        {
                           if( fabs(csparsar[j][i-1] - 
                              csptr->knots[csptr->num_poles]) < cknot_tol)
                              csparsar[j][i-1] = 
                                           csptr->knots[csptr->order-1];
                        }
                     }
            }
            if( p1  )
               BSdealloc((char *) p1);
            p1 = NULL;
            if( p2 )
               BSdealloc((char *)p2);
            p2 = NULL;
            if( pts1 )
               BSdealloc((char *)pts1 );
            pts1 = NULL;
            if( pts2 )
               BSdealloc((char *)pts2 );
            pts2 = NULL;

            if( i == 0 )
            {
               if( csptr->phy_closed &&
                   !((j == 0 && degen0) || (j == numcs-1 && degen1) ) )
                  if( dist > chrdht_tol )
                     shuffle = FALSE;
            }
            
            if( j == 0 && ttrcurves[i]->phy_closed  && 
               !degen[i] )
            {
               /* shuffle the trace curve so that it will start at
                  sttrpar, which is at first cross section  */
               status = BSclcvshffl(rc, ttrcurves[i], &sttrpar, &dir, 
                                    tcvs[i] );
               if( BSERROR(*rc))
                   goto wrapup;
               if( on_site )
                  trparsar[i][j] = ttrcurves[i]->knots[
                                                   ttrcurves[i]->order-1];
               else
               {
                  /* I need to shuffle the input parameters,  I've already
                     copied them to a temporary array */
                  for(k=1; k<numcs; k++)
                  {
                     if( trparsar[0][k] > trparsar[0][0] )
                        trparsar[0][k] -= trparsar[0][0];
                     else
                        trparsar[0][k] = trparsar[0][k] - 
                           tcvs[i]->knots[tcvs[i]->order-1] +
                           tcvs[i]->knots[tcvs[i]->num_poles] - 
                           trparsar[0][0];
                  }
                  trparsar[0][0] = 0.0;
                  /* this is on_view and we need nothing else(csparsar or
                     trparsar), so break out of loop */
                  if( !csclosed )
                     break;
               }
            }
            else
            {
               if( j == 0 )
               {
                  if( trclosed || increasedeg)
                  {
                     status = BScv_copy(rc, ttrcurves[i], tcvs[i] );
                     if(BSERROR(*rc))
                     goto wrapup;
                  }
                  else
                  {
                    tcvs[i] = ttrcurves[i];
                  }
               }
            }
         }  /* end for j  */
      }  /* end for i  */

      if( alltouch && csclosed && tnumtrc == 2 && !orient_abs)
      {
         tcvs[2] = tcvs[0];
         tnumtrc = 3;
         degen[tnumtrc-1] = degen[0];
         for(i=0; i< numcs; i++)
         {
            csparsar[i][2] = csparsar[i][0];
            trparsar[2][i] = trparsar[0][i];
         }         
      }
      if( increasedeg )
      {
         /* If the trace is order two and the law curves were input,
            we need to increase the degree to 3, so that the trace will
            have at least 4 poles.  Therefore there will be 2 interior
            cross sections made.    */

         for(i=0; i<tnumtrc; i++)
         {
            (void)BSupthedegr(rc, tcvs[i], &degg, &enough_memory);
            if(BSERROR(*rc))
               goto wrapup;
         }
      }
      increasenp = FALSE;
      if( (shapelaw || orientlaw) && tcvs[0]->num_poles < MINPOLES)
      {
         /* check to see if we need to increase the number of poles */
         increasenp = TRUE;
         ind = 0;
         for(i=1; i< tnumtrc; i++)    
         {
            if( tcvs[i]->num_poles > MINPOLES )
            {
               increasenp = FALSE;
               break;
            }
            else
               if( tcvs[i]->num_poles > tcvs[ind]->num_poles )
                  ind = i;
         }  
      }
      /** don't change ind after this point **/
      if( increasenp )
      {
         /* we want to have at least MINPOLES in the trace curve, because
            we have a law curve as input */
         if( MINPOLES + tcvs[ind]->num_poles > MAXNUM )
         {
            newkts = (IGRdouble *)BSstackalloc((unsigned)( (MINPOLES + 
                              tcvs[ind]->num_poles) * sizeof(IGRdouble)));
            if( !newkts)
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            newktsalloc = FALSE;
         }
         else
            newkts = anewkts;

         BScv_enokts(tcvs[ind]->num_poles, tcvs[ind]->order, 
                     tcvs[ind]->knots, MINPOLES, &newnump, newkts, rc);
         if(BSERROR(*rc))
            goto wrapup;
         /* save the pointer to tcvs[ind],  allocate a new curve,
            then at wrapup free new tcvs[ind] and restore pointer to
            tcvs[ind] before freeing */
         savetcvs = tcvs[ind];
         BSalloccv(tcvs[ind]->order, newnump, tcvs[ind]->rational,
                   0, &tcv, rc);
         if(BSERROR(*rc))
            goto wrapup;
         BSadd_kts(tcvs[ind], newnump, newkts, tcv, rc);
         if(BSERROR(*rc))
            goto wrapup;
         tcvs[ind] = tcv;
      }
                
      /* for 1 trace and multiple cross sections -
         check if we had the same parameter on each cross section where the
         trace touched it,  if same_par=TRUE, then let's don't shuffle */
      if( same_par && shuffle )
         shuffle = FALSE;
      if( shuffle )
      {
         for(j=0; j< numcs; j++)
         {
            csptr = on_site ? cscurves[j] : csg[j];
            deg = csptr->knots[cscurves[j]->order-1];
            np = csptr->knots[cscurves[j]->num_poles];
            if( csptr->phy_closed &&
                !((j == 0 && degen0) || (j == numcs-1 && degen1) ) &&
                !( (fabs(csparsar[j][0] - deg) < cknot_tol ) ||
                   (fabs(csparsar[j][0] - np) < cknot_tol ) )  )
            {
               /* shuffle the cross section so that it will start at
                  first trace  */
               status = BSclcvshffl(rc, csptr, &csparsar[j][0], &dir, 
                                    csg[j] );
               if( BSERROR(*rc))
                   goto wrapup;
               if( !on_site )
               {
                  status = BSclcvshffl(rc, csl[j], &csparsar[j][0], &dir, 
                                       csl[j] );
                  if( BSERROR(*rc))
                      goto wrapup;
               }
               if( tnumtrc > 2 )
               {
                  /* we have to shuffle the cross sections parameters */
                  del = np - deg;
                  for(i=1; i< tnumtrc-1; i++)
                  {
                     csparsar[j][i] -= csparsar[j][0];
                     if( csparsar[j][i] < deg)
                        csparsar[j][i] += del;
                     else
                     { 
                        if( csparsar[j][i] > np )
                           csparsar[j][i] -= del;
                     }               
                  }
                  csparsar[j][0] = deg;
                  csparsar[j][tnumtrc-1] = np;
               }             
            } 
            else
            {
               if( csclosed )
               {
                  if(fabs(csparsar[j][0] - np) < cknot_tol )
                     csparsar[j][0] = deg;
                  if( fabs(csparsar[j][tnumtrc-1] - deg) < cknot_tol )
                     csparsar[j][tnumtrc-1] = np;
                  status = BScv_copy(rc, csptr, csg[j] );
                  if(BSERROR(*rc))
                     goto wrapup;
               }
            }
         }
      }
   }
   else
   {
      tcvs = ttrcurves;
   }

   if( numcs > 1 )
   {
      if( numcs -1 > MAXNUM )
      {
         lawcvso = (struct IGRbsp_curve **)BSstackalloc((unsigned)(
                           (numcs-1) * sizeof(struct IGRbsp_curve *)));
         if( !lawcvso )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         lawcvss = (struct IGRbsp_curve **)BSstackalloc((unsigned)(
                           (numcs-1) * sizeof(struct IGRbsp_curve *)));
         if( !lawcvss )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         lawcvso = alawcvso;
         lawcvss = alawcvss;
      }
      for(i=0; i< numcs-1; i++)
      {
         lawcvso[i] = NULL;
         lawcvss[i] = NULL;
      }
      if( !shapelaw || !orientlaw )
      {
         count = 0;
         for(i=0; i< numcs; i++)
            sarcl[i] = 0.0;
         for(i=0; i< tnumtrc; i++)
         {
            if( degen[i] )
            {
               count += 1;
               continue;
            }
            trptr = tcvs[i];
            status = BScumdist(rc, &trptr->num_poles, trptr->poles, 
                               trptr->weights, &cumdist);
            if(BSERROR(*rc))
               goto wrapup;

            temp_tol = cumdist / 100;
            /* change arclen_tol back to new temp_tol */
            status = BSchangepar(rc, BSTOLARCLEN, temp_tol);
            if(BSERROR(*rc))
               goto wrapup;

            for(j=0; j< numcs; j++)
            {
               if( j == 0 )
                  arcl[j] = 0.0;
               else
               {
                  /* we need law curves for scaling between cross sections
                   */
                  /* find an average array of arclengths along the traces 
                     between each cross section, this array will be used
                     later to take one law curve and split it into 
                     numcs -1 law curves */
                  status = BSarclength(rc, trptr, &trparsar[i][j-1], 
                                       &trparsar[i][j], &arcl[j]);
                  if(BSERROR(*rc))
                     goto wrapup;
                  arcl[j] += arcl[j-1];
               }
            }
            /* normalize each trace */
            for(j=1; j< numcs; j++)
            {
               arcl[j] /= arcl[numcs-1];
               sarcl[j] += arcl[j];           
            }
         }
         /* change arclen_tol back to original */
         status = BSchangepar(rc, BSTOLARCLEN, arclen_tol );
         if(BSERROR(*rc))
            goto wrapup;
         if( tnumtrc > 1 )
         {
            n_int = tnumtrc - count;
            /* find the average */
            for(i=1; i<numcs; i++)
            {
               sarcl[i] /= n_int;
            }
         }
         /* now find the law curves */
         /* create the law curve which will be split */
         curve.order = 4;
         curve.num_poles = 4;
         curve.non_uniform = 0;
         curve.periodic = 0;
         curve.num_knots = 8;
         curve.rational = 0;
         curve.phy_closed = 0;
         curve.planar = 1;
         curve.knots = cknots;
         curve.poles = &cpoles[0][0];
         curve.knots[0] = curve.knots[1] = curve.knots[2] =curve.knots[3]=
                          0.0;
         curve.knots[4] = curve.knots[5] = curve.knots[6] =curve.knots[7]=
                          1.0;
         curve.poles[0] = curve.poles[1] = curve.poles[2] =curve.poles[5]=
         curve.poles[8] = curve.poles[11] = curve.poles[4] = 0.0;
         curve.poles[3] = .05;
         curve.poles[6] = .95;
         curve.poles[7] = curve.poles[9] = curve.poles[10] = 1.0;

         if( !orientlaw )      
         {
            BSbrkcvaprs(&curve, numcs, sarcl, tst_plan, lawcvso, rc);
            if(BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            for(i=0; i< numcs-1; i++)
            {
               lawcvso[i] = olawcvs[i];
            }
         }
         if( !shapelaw )
         {
            if( !orientlaw )
            {
               /* copy lawcvso */
               for(j=0; j< numcs-1; j++)
               {
                  BSstkallocv(rc, lawcvss[j], lawcvso[j]->num_poles, 
                              lawcvso[j]->rational, lawcvso[j]->num_knots,
                              NULL);
                  if(BSERROR(*rc))
                     goto wrapup;
                  status = BScv_copy(rc, lawcvso[j], lawcvss[j]);
                  if(BSERROR(*rc))
                     goto wrapup;
               }
            }
            else
            { 
               BSbrkcvaprs(&curve, numcs, sarcl, tst_plan, lawcvss, rc);
               if(BSERROR(*rc))
                  goto wrapup;
            }
         }
         else
         {
            for(i=0; i< numcs-1; i++)
            {
               lawcvss[i] = slawcvs[i];
            }
         }
      }
      else
      {
         for(i=0; i< numcs-1; i++)
         {
            lawcvso[i] = olawcvs[i];
            lawcvss[i] = slawcvs[i];
         }
      }
   } /* more than one cross section */

   /* if tnumtrc > 2, then we don't need the smat's or tmat's */
   if( tnumtrc > 2 && !(numtrc == 2 && orient_abs) )
   {
      BSmkcstrsf(tnumtrc, tcvs, numcs, csg, tmat, smat, tscale_height,
                 csparsar, trparsar, lawcvss, lawcvso, torient_abs, tsf1, 
                 tsf2, ssf1, ssf2, surf, rc);
      goto wrapup;
   }

   if( on_site )
   {
      if( !csclosed || (csclosed && !shuffle) )
      {
         if( csclosed && !shuffle )
         {
            for(i=numcs-1; i>=sizeg; i--)
            {
               if( csg[i] )
               {
                  BSstkfreecv(&rc1, csg[i]);
                  if(BSERROR(rc1) && BSOKAY(*rc) )
                     *rc = rc1;
                  csg[i]=NULL;
               }
            }
            for(i=sizeg-1; i>=0; i--)
            {
               if( csg[i] )
               {
                  BSstackdealloc((char *)csg[i] );
                  csg[i]=NULL;
               }
            } 
            if( numcs > MAXNUM )
            {
               if( csg )
                  BSstackdealloc((char *) csg );
               csg=NULL;
            }
         }   
         csg = cscurves;
      }
      if( tnumtrc == 1 )
      {
         /* find trace normal */
         BSplanar2(tcvs[0]->num_poles, (IGRpoint *)tcvs[0]->poles,
                   tcvs[0]->weights, &code, trcnvec, rc);
         if(BSERROR(*rc))
            goto wrapup;

         if(  code != 3 )
         {
            smooth = TRUE;
            if( tcvs[0]->num_poles > MAXNUM )
            {
               csps = (IGRdouble *)BSstackalloc((unsigned)( 
                        tcvs[0]->num_poles * sizeof(IGRdouble )));
               if(! csps )
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }
               cspsalloc = TRUE;
            }
            else
               csps = acsps;
            BSfndcvcsp(tcvs[0], &ncsp, csps, rc);
            if(BSERROR(*rc))
               goto wrapup;
            if( ncsp > 0 )
               smooth = FALSE;
            else
            {
               /* check for linear pieces */
               linBSmvxsectrc(tcvs[0], knot_tol, &linearpieces, rc);
               if(BSERROR(*rc))
                  goto wrapup;               
               if( linearpieces )
                  smooth = FALSE;
            }
         }
         BScveval( tcvs[0], trparsar[0][0], num_derv, eval, rc );
         if (BSERROR(*rc))
            goto wrapup;
         /* check to see if the first cross section is degenerate,
            if it is use the next one */
         if( degen0 )
         {
            if( numcs > 1)
               index = 1;
            else
            {
               *rc = BSINARG;
               goto wrapup;
            }
         }
         else
            index = 0;
         tanvec = 1;
         tanvecBSmvxsectrc(tnumtrc, tcvs, index, trparsar, allopen, 
                           cscurves[index], tanvec, vecsum,tansum, trcpt,
                           rc);
         if( BSERROR(*rc))
             goto wrapup;

         if( code == 2 )
         {
            /* find a trace normal */
            status = BScrossp(rc, vecsum, eval[1], trcnvec);
            if(BSERROR(*rc))
               goto wrapup;
         }
      }

      for(j=0; j< numcs; j++)
      { 
         tanvec = 2;
         if( tnumtrc == 1 )
         {
            if( !nonvec[j] && numcs == 1)
               tanvec = 0;
         }
         if( j == 0 && degen0 )
            continue;
        
         if( numcs > 1 && j == numcs -1 && degen1 )
         {
            if( torient_abs)
            {
               /* copy previous smat */
               for(i=0; i<3; i++)
               {
                  smat[j][0][i] = smat[j-1][0][i];
                  smat[j][1][i] = smat[j-1][1][i];                        
                  smat[j][2][i] = smat[j-1][2][i];                        
               }
            }
            else
            {
               for(i=0; i<3; i++)
                  vecsum[i] = tmat[j-1][0][i];
            }
            tanvec = 0;
         }
         tanvecBSmvxsectrc(tnumtrc, tcvs, j, trparsar, allopen, 
                           cscurves[j], tanvec, vecsum,tansum, trcpt, rc);
         if( BSERROR(*rc))
             goto wrapup;
         if( tnumtrc > 1 )
         {
            status = BScrossp(rc, vecsum, tansum, lft_norm);
            if(BSERROR(*rc))
              goto wrapup;
            if( !torient_abs)
            {
               for(k=0; k<3; k++)
               {
                  tmat[j][1][k] = lft_norm[k];
               }
            }
            /* since we averaged the tangents and connecting vectors,
            tansum and vecsum are not perpendicular...so we have to
            make them perpendicular */
            status = BScrossp(rc, lft_norm, vecsum, tansum);
            if(BSERROR(*rc))
              goto wrapup;
         }
         if( !torient_abs )
         {
            /* need the tmat's */
            status = BSnorvec(rc, tansum );
            if(BSERROR(*rc))
               goto wrapup;
            for(k=0; k<3; k++)
            {
               tmat[j][2][k] = tansum[k];
               tmat[j][0][k] = vecsum[k];
            }
            if( tnumtrc == 1  )
            {
               if( code == 3 || numcs > 1)
               {
                  for(k=0; k<3; k++)
                     tmat[j][1][k] = trcnvec[k];
                  status = BScrossp(rc, tmat[j][2], tmat[j][1], 
                                    tmat[j][0]);
                  if(BSERROR(*rc))
                     goto wrapup;
                  status = BScrossp(rc, tmat[j][0], tmat[j][2], 
                                    tmat[j][1]);
                  if(BSERROR(*rc))
                     goto wrapup;
               }
               else
               {
                  if( !smooth )
                  {
                     status = BScrossp(rc, tmat[j][0], tmat[j][2], 
                                       tmat[j][1]);
                     if(BSERROR(*rc))
                        goto wrapup; 
                  }
                  else
                  {
                     (void)BSprncp_nor(rc, tcvs[0], &tcvs[0]->knots[
                                       tcvs[0]->order-1], tmat[j][1], vec,
                                       &tcode );
                     if(BSERROR(*rc))
                        goto wrapup;
                  }
                  status = BScrossp(rc, tmat[j][2], tmat[j][1], 
                                    tmat[j][0]);
                  if(BSERROR(*rc))
                     goto wrapup;
               }
            }            
            for(k=0; k<3; k++)
            {
               tmat[j][2][k] *= -1.0;
            }
            status = BSnorvec(rc, tmat[j][0] );
            if(BSERROR(*rc))
               goto wrapup;
            status = BSnorvec(rc, tmat[j][1] );
            if(BSERROR(*rc))
               goto wrapup;
         }                         
         if( numcs > 1 && j == numcs -1 && degen1 )
         {
            if( !torient_abs )
            {
               for(i=0; i<3; i++)
               {
                  smat[j][0][i] = tmat[j][0][i];
                  smat[j][1][i] = tmat[j][1][i];                        
                  smat[j][2][i] = tmat[j][2][i];                        
               }
            }            
            BScvoton(rc, trcpt, smat[j], &scale, csg[j], csl[j]);
            if(BSERROR(*rc))
               goto wrapup; 
            break;
         }
         /* find smat[]'s */
         if( tnumtrc == 1 )
         {
            if( nonvec[j] )
            {
               /* this cross section is linear */
               /* smat[j][0] is along line */
               status = BScrossp(rc, vecsum, trcnvec, smat[j][2]);
               if(BSERROR(*rc))
                  goto wrapup;
               len = BSlenvecsq(rc, smat[j][2]);
               if( len < cross_sqtol )
               {
                  for(k=0; k<3; k++)
                     smat[j][2][k] = -tansum[k];
               }
               else
               {
                  if( BSdotp(rc, smat[j][2], tansum) > 0 )
                     for(k=0; k<3; k++)
                        smat[j][2][k] *= -1.0;
               }
               status = BScrossp(rc, trcnvec, smat[j][2], 
                                 smat[j][0]);
               if(BSERROR(*rc))
                  goto wrapup;
            }
            else
            {
               /* find dot product of cross normal and trace tangent */
               dot = BSdotp(rc, smat[j][2], tansum);
               if(BSERROR(*rc))
                  goto wrapup;
               if(  dot > 0 )
               {
                  /* needs to be opposite direction */
                  for(k=0; k<3; k++)
                     smat[j][2][k] = -smat[j][2][k];
               }  
               if( code == 3 )
               {
                  status = BScrossp(rc, trcnvec, smat[j][2], smat[j][0]);
                  if(BSERROR(*rc))
                     goto wrapup;
               }
               else
               {
                  for(k=0; k<3; k++)
                     smat[j][0][k] = vecsum[k];
               }
            }
            status = BScrossp(rc, smat[j][2], smat[j][0], smat[j][1]);
            if(BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            /* tnumtrc > 1  */
            if( nonvec[j] )
            {
               /* this cross section is linear */
               /* smat[j][0] is along line */
               for(k=0; k<3; k++)
                  smat[j][0][k] = vecsum[k];
               status = BScrossp(rc, smat[j][0], tansum, smat[j][1]);
               if(BSERROR(*rc))
                   goto wrapup;
               status = BScrossp(rc, smat[j][0], smat[j][1], smat[j][2]);
               if(BSERROR(*rc))
                  goto wrapup;
              
            }
            else
            {
               /* find dot product of cross normal and trace tangent */
               dot = BSdotp(rc, smat[j][2], tansum);
               if(BSERROR(*rc))
                  goto wrapup;
               if(  dot > 0 )
               {
                  /* needs to be opposite direction */
                  for(k=0; k<3; k++)
                     smat[j][2][k] = -smat[j][2][k];
               }  
               status = BScrossp(rc, smat[j][2], vecsum, smat[j][1]);
               if(BSERROR(*rc))
                  goto wrapup;
               for(k=0; k<3; k++)
                  smat[j][0][k] = vecsum[k];
               status = BScrossp(rc, smat[j][0], smat[j][1], smat[j][2]);
               if(BSERROR(*rc))
                  goto wrapup;
            }
         }
         status = BSnorvec(rc, smat[j][1] );
         if(BSERROR(*rc))
            goto wrapup;
         status = BSnorvec(rc, smat[j][2] );
         if(BSERROR(*rc))
            goto wrapup;
         status = BSnorvec(rc, smat[j][0] );
         if(BSERROR(*rc))
             goto wrapup;
         /* find the local curves */
         BScvoton(rc, trcpt, smat[j], &scale, csg[j], csl[j]);
         if(BSERROR(*rc))
            goto wrapup; 
      }
      /* if degen0, then we skipped over j = 0 for the tmat, so we could
         use the next vecsum  */
      if( degen0  )
      {
         if( !torient_abs)
         {
            tanvec = 0;
            tanvecBSmvxsectrc(tnumtrc, tcvs, 0, trparsar, allopen, 
                              cscurves[0], tanvec, vecsum, tansum, trcpt, 
                              rc);
            if( BSERROR(*rc))
                goto wrapup;
            status = BScrossp(rc, tmat[1][0], tansum, tmat[0][1]);
            if(BSERROR(*rc))
              goto wrapup;
            status = BScrossp(rc, tmat[0][1], tmat[1][0], tansum);
            if(BSERROR(*rc))
              goto wrapup;
            for(k=0; k<3; k++)
            {
               tmat[0][2][k] = -tansum[k];
               tmat[0][0][k] = tmat[1][0][k];
            }
            status = BSnorvec(rc, tmat[0][0] );         
            if(BSERROR(*rc))
               goto wrapup;
            status = BSnorvec(rc, tmat[0][1] );
            if(BSERROR(*rc))
               goto wrapup;
            status = BSnorvec(rc, tmat[0][2] );
            if(BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            tanvec = 3;
            tanvecBSmvxsectrc(tnumtrc, tcvs, 0, trparsar, allopen, 
                              cscurves[0], tanvec, vecsum,tansum, trcpt, 
                              rc);
            if( BSERROR(*rc))
                goto wrapup;
         }
         if( torient_abs)
         {
            /* copy the smat[1] into smat[0] */
            for(i=0; i<3; i++)
            {
               smat[0][0][i] = smat[1][0][i];
               smat[0][1][i] = smat[1][1][i];
               smat[0][2][i] = smat[1][2][i];
            }
         }
         else
         {
            /* copy the tmat[0] into smat[0] */
            for(i=0; i<3; i++)
            {
               smat[0][0][i] = tmat[0][0][i];
               smat[0][1][i] = tmat[0][1][i];
               smat[0][2][i] = tmat[0][2][i];
            }
         }
         BScvoton(rc, trcpt, smat[0], &scale, csg[0], csl[0]);
         if(BSERROR(*rc))
            goto wrapup; 
      }
   }
   else
   {
      /* not on_site so,
         orient the curves on_site */
   
      for(i=0; i< numcs; i++)
      {

         BScveval( tcvs[0], trparsar[0][i], num_derv, eval, rc );
         if (BSERROR(*rc))
            goto wrapup;
         if( !torient_abs )
         {
            for(k=0; k<3; k++)
            {
               tmat[i][1][k] = smat[i][1][k];
               tmat[i][2][k] = -eval[1][k];
            }
            status = BScrossp(rc, tmat[i][1], tmat[i][2], tmat[i][0]);
            if(BSERROR(*rc))
               goto wrapup;
            status = BScrossp(rc, tmat[i][2], tmat[i][0], tmat[i][1]);
            if(BSERROR(*rc))
               goto wrapup;
            status = BSnorvec(rc, tmat[i][0]);
            if(BSERROR(*rc))
            goto wrapup;
            status = BSnorvec(rc, tmat[i][1]);
            if(BSERROR(*rc))
               goto wrapup;
            status = BSnorvec(rc, tmat[i][2]);
            if(BSERROR(*rc))
               goto wrapup;
         }      
      }
   }
   BSmkcstrsf(tnumtrc, tcvs, numcs, csl, tmat, smat, tscale_height,
              csparsar, trparsar, lawcvss, lawcvso, torient_abs, tsf1, 
              tsf2, ssf1, ssf2, surf, rc);
   status = status;
   wrapup:
   if( csps && cspsalloc )
      BSstackdealloc((char *) csps );
   if( p1  )
      BSdealloc((char *) p1);
   if( p2 )
      BSdealloc((char *)p2);
   if( pts1 )
      BSdealloc((char *)pts1 );
   if( pts2 )
      BSdealloc((char *)pts2 );
   if( rule && cpcscvs[0] )
   {
      for(i=numcs-1; i>=0; i--)
      {

         (void)BSfreecv(&rc1, cpcscvs[i] );
         if(BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
      }
   }
   if( !shapelaw && lawcvss)
   {
      if( !orientlaw )
      {
         for(j=numcs-2; j>=0; j--)
         {
            if( lawcvss[j] )
            {
               BSstkfreecv(&rc1, lawcvss[j]);
               if(BSERROR(rc1) && BSOKAY(*rc) )
                  *rc = rc1;
            }
         }
      }
      else
      { 
         for(j=numcs-2; j>=0; j--)
         {
            if( lawcvss[j] )
            {
               status = BSfreecv(&rc1, lawcvss[j]);
               if(BSERROR(rc1) && BSOKAY(*rc) )
                  *rc = rc1;
            }
         }
      }
   }
   if( !orientlaw && lawcvso)
   {    
      for(i = numcs -2; i>=0; i--)
      {
         if( lawcvso[i] )
         {
            status = BSfreecv(&rc1,lawcvso[i]);
            if(BSERROR(rc1) && BSOKAY(*rc) )
            {
               *rc = rc1;
            }
         }
      }
   }

   if( numcs -1 > MAXNUM )
   {
      if( lawcvss )
         BSstackdealloc((char *)lawcvss);
      if( lawcvso )
      BSstackdealloc((char *)lawcvso);
   }
   if( newkts && newktsalloc )
      BSstackdealloc((char *) newkts);

   if( increasenp)
   {
      if( tcvs[ind] )
      {
         (void)BSfreecv(&rc1, tcvs[ind]);
         if(BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
      }
      tcvs[ind] = savetcvs;
   }
   if( tcvs  )
   {
      if( trclosed || increasedeg)
      {
         if( tnumtrc > sizet )
         {
            /* check to see if addresses are the same */
            if( tnumtrc > 2 && tcvs[tnumtrc-1] == tcvs[0] )
               j = tnumtrc-1;
            else
               j = tnumtrc;
            for(i = j-1; i>=sizet; i--)
            {
               if( degen[i] )
                  continue;
               BSstkfreecv(&rc1, tcvs[i]);
               if(BSERROR(rc1) && BSOKAY(*rc) )
                  *rc = rc1;
            }
         }
         for(i=sizet-1; i>=0; i--)
         {
            if( i == 0 && degen[i] )
               continue;
            if( tcvs[i])
               BSstackdealloc((char *)tcvs[i]);
         }
      }
      if( tnumtrc > MAXNUM )
      {
         BSstackdealloc((char *)tcvs);
      }
   }

   if( ((csclosed ) || !on_site) && csg && csg != cscurves)
   {
      for(i=numcs-1; i>=sizeg; i--)
      {
         if( csg[i] )
          {
            BSstkfreecv(&rc1, csg[i]);
            if(BSERROR(rc1) && BSOKAY(*rc) )
               *rc = rc1;
         }
      }
      for(i=sizeg-1; i>=0; i--)
      {
         if( csg[i] )
         {
            BSstackdealloc((char *)csg[i] );
         }
      } 
      if( numcs > MAXNUM )
      {
         if( csg )
            BSstackdealloc((char *) csg );
      }
   }
   if( par && paralloc )
      BSstackdealloc((char *) par );

   if( numcs > MAXNUM && nonvec )
      BSstackdealloc((char *) nonvec);
   if( !orientlaw || !shapelaw )
   {
      if( numcs > MAXNUM )
      {
         if( sarcl)
            BSstackdealloc((char *) sarcl);
         if( arcl)
            BSstackdealloc((char *) arcl);
      }
   }
   if( int_ptsalloc && int_pts)
      BSstackdealloc((char *) int_pts );
   if( balloc && b )
      BSstackdealloc((char *) b );
   if( aalloc && a )
      BSstackdealloc((char *) a );
   if( u1alloc && u1 )
      BSstackdealloc((char *) u1 );

   if( csparsar && csparsaralloc )
   {
      if( sum2 < numcs )
      {
         for(i=numcs-1; i>=sum2; i--)
         {
            if( csparsar[i] )
               BSstackdealloc((char *) csparsar[i] );
         }
         if( numcs > MAXNUM )
            BSstackdealloc((char *) csparsar );
      }
   }

   if( on_site || (!on_site && trclosed ) )
   {
      if ( trparsar )
      {
         if( on_site )
         {
            if( sum < tnumtrc )
            {
               for(i=tnumtrc-1; i>=sum; i--)
               {
                  if( trparsar[i] )
                     BSstackdealloc((char *) trparsar[i] );
               }
            }
         }
         else
         {
            if( numcs > MAXNUM )
               BSstackdealloc((char *)trparsar[0] );
         }
         if( tnumtrc > MAXNUM )
            BSstackdealloc((char *) trparsar );
      }
   }   
   if( !torient_abs && tnumtrc < 3)
   {
      if( numcs > MAXNUM )
      {
         if( tmat )
            BSstackdealloc((char *) tmat );
      }
   }
   if( numcs > MAXNUM )
   {
      if( smat )
         BSstackdealloc((char *) smat );
   }
   if( csl )
   {
      for(i=numcs-1; i>=sizel; i--)
      {
         if( csl[i] )
         {
            BSstkfreecv(&rc1, csl[i]);
            if(BSERROR(rc1) && BSOKAY(*rc) )
               *rc = rc1;
         }
      }
      for(i=sizel-1; i>=0; i--)
      {
         if( csl[i] )
            BSstackdealloc((char *)csl[i] );
      } 
      if( numcs > MAXNUM )
         BSstackdealloc((char *) csl );
   }
   if( degen && degenalloc )
      BSstackdealloc((char *) degen);
   if( allocttrcurves && ttrcurves )
      BSstackdealloc((char *) ttrcurves);

   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSmvxsectrc");
   return;
   }
}


