/* $Id: bsmksfb2cs.c,v 1.1.1.1 2001/01/04 21:07:27 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/bsmksfb2cs.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: bsmksfb2cs.c,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/01/09  16:45:44  pinnacle
 * Created: emsfixes/bs/bsmksfb2cs.c by azuurhou for vds
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      01/09/98        adz             integration date
 ***************************************************************************/



/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSmksfb2cs

Abstract
    This routine creates a surface through cross section curve/s(one or
two) and along trace curves.  

Synopsis
    void BSmksfb2cs(numtrc, tcvs, numcs, csl, tmat, smat, 
                    scale_height, lawcvs, lawcvo, 
                    orient_abs, tsf1, tsf2, csf1, csf2, surf, rc);
 
    IGRint                numtrc
    struct IGRbsp_curve   *tcvs[]
    IGRint                numcs
    struct IGRbsp_curve   *csl[]
    BSmat                 tmat[],
                          smat[]
    IGRboolean            scale_height
    struct IGRbsp_curve   *lawcvs,
                          *lawcvo
    IGRboolean            orient_abs
    struct IGRbsp_surface *tsf1,
                          *tsf2,
                          *csf1,
                          *csf2
    struct IGRbsp_surface **surf
    BSrc                  *rc

Description
    Input to this routine is:

    numtrc                the number of trace curves
    *tcvs[]               trace curves(compatible)
    numcs                 number of cross sections, 1 or 2
    *csl[]                the cross section curves, split already at the
                          trace curves(so there are (numtrc-1) * numcs
                          cross section curve pieces)
                          if ( numtrc < 3) then the curves are in the
                          xy-plane(this is the place where all the scaling
                          and such will take place )
                          but if (numtrc > 2) then the curves are global
    tmat[],               these are the tangent(transformation) matrices 
                          at each cross section
    smat[]                these are the positional(tranformation) matrices
                          for each cross section, these are in reference                            to the tmat[]'s
    *lawcvs,              law curve for scaling between cross sections,
                          only if two cross sections
    *lawcvo               law curve for scaling the orientation between 
                          the cross sections, only if two cross sections
    orient_abs            this will tell how to orient the cross sections
                          as it's moved along the trace 
                          1 : constant absolute position...which means
                              that in the case of one cross section only,
                              the position of the cross section at  
                              beginning will remain constant, just shifted
                              along, in case of multiple cross sections,
                              the position will change from one absolute
                              position into the next one, regardless of
                              the geometry of the trace curves
                          0 : relative position...which means that in the
                              case of one cross section, the position of 
                              the cross section at the beginning with 
                              respect to the normal plane of trace curve 
                              will stay relatively constant throughout 
                              the movement, in the case of multiple cross
                              sections, the orientation of the cross 
                              sections will change from one relative point
                              w.r.t. the trace curve normal, into another
                              relative position w.r.t. the curve normal...
    (Note that if any of the following tangent surfaces are not to be
     input, then please set to NULL)
    *tsf1,                    this is the surface tangent along the
                              first trace
    *tsf2,                    this is the surface tangent along the 
                              last trace
    *csf1,                    this is the surface tangent along the first
                              cross section
    *csf2                     this is the surface tangent along the last
                              cross section

    Output for this routine is:
    **surf                    this is the skin surface through the
                              cross sections along the traces

Return Values
    BSSUCC is returned if all is successful.

Notes
    
Index
    em

Keywords

History
    S.G. Catron    08/28/89  : Creation date.
    S.G. Catron    11/17/89  : The call argument list in fuction call
                               BSfxuvplmkt changed, due to trying to keep
                               the original cusps of the trace curves.
                               Also there was an error in calculating the 
                               tangents using the input surface .
    S.G. Catron    12/21/89  : When there are more than 3 traces and you
                               are trying to cut with the plane, don't do
                               the first and last one(not necessary).
    S.G. Catron    02/16/90  : It was not keeping the tangent constraints
                               from the input surface on the last cross
                               section constructed.(This was only for the
                               case of one input cross section.)
    S.G. Catron    02/22/90  : Find the tangent constraints for fitting
                               the interior curves in this routine instead
                               of BSwavsc2cvs.  Also find the model space
                               tangents instead of the local tangents.
    S.G. Catron    04/26/90  : I added code to check for cusps along the
                               trace(when only 1 trace), and to project
                               the cross section at that cusp to a
                               plane defined by the average of the left
                               and right tangents.
    S.G. Catron    05/23/90  : There was a bug in using the wrong tangent
                               when the previous cross section was okay
                               and the next was degenerate.
    S.G. Catron    05/25/90  : I had to add some code for situation of
                               three traces, two cross sections, and first
                               cross section was degenerate.  
    S.G. Catron    06/28/90  : There was a error in the case of more than
                               two traces in the call to BSsfthcvsbd.  If
                               there were tangent surfaces input, then it
                               was sending the surfaces in each time and
                               that was of course wrong.
    S.G. Catron    06/29/90  : If numnodes =2 and tangent surfaces input,
                               there was an error in not setting space for
                               the tangent vector.
    S.G. Catron    07/25/90  : Make sure if the cross section multiple 
                               knots were not cusps, then the surface has
                               no cusps either.  Also if the cross 
                               sections were closed, make sure the surface
                               is also exactly closed.
    S.G. Catron    08/01/90  : For 3 traces and only 1 cross section, it
                               wasn't scaling the last cross section.
    S.G. Catron    08/06/90  : Added code in the case of numtrc = 1, and
                               non-planar when finding the atmat's.
    S.G. Catron    08/10/90  : If the cross section has order 2, don't
                               add any interior knots.
    S.G. Catron    09/14/90  : Extracted code to make a new routine called
                               BSfndintcrs.  Also changed it alot for the
                               1 trace case.  For instance, the trace is 
                               now broke down in pieces and BSfndintcrs is
                               called in a loop.  Also for 1 trace, I
                               made a new routine called BSfndtsmats, 
                               which find the tmat's and smat's at each
                               ends of each piece.
    D. Breden      09/15/90  : Corrected typo in statement initializing
                               k=0.
    S.G. Catron    10/18/90  : Make sure not to overwrite input tmat's.
    S.G. Catron    10/24/90  : There was an error in the logic while 
                               trying to find the normal vectors for the 
                               plane cuts.  It was the case of a 
                               degenerate first cross section . I also 
                               fixed apogee compiler errors.
    S.G. Catron    01/04/91  : Set array cvsl to NULL.  Also moved static
                               routines to top.
    S.G. Catron    01/14/91  : Fixed problems with principal normal
                               flipping.  This is in the one trace case
                               with more than one piece.
    S.G. Catron    03/06/91  : Added calls to new routines for finding a
                               least squares plane(BSlsqplvpts and 
                               BSlsqptlnpl).  Also added code for numtrc
                               > 3, to refit the trace curves with 
                               intersection points from BSpl_cv_int.
    S.G. Catron    03/19/91  : Took out code for refitting traces, because
                               the original traces would not be contained
                               in the output surface.  Also made the 
                               insertion value for numtrc > 3 equal to 1.
                               That way we fit more cross section curves.
    S.G. Catron    04/25/91  : When projecting cross section onto avgtan
                               plane and there is two cross sections,
                               use the lderv[1] instead of rderv[1].
    S.G. Catron    06/05/91  : Check for NULL pointer before copying 
                               tmat.
    S.G. Catron    07/09/91  : Fixed problem with principal normal...
                               don't always flip tsmat[1] if ttmat[1] has
                               to be flipped.
    S.G. Catron    09/16/91  : Took out all fixing of multiple knots
                               no cusp.  It's now done in the next upper
                               level routine.
    S.G. Catron    11/15/91  : Added a check for interior degenerate
                               trace curves(numtrc > 2), because 
                               BSpl_cv_int will error with degenerate
                               curve.
    S.G. Catron    11/19/91  : Make sure before flipping the normals, 
                               that the tangents are not flipping.
    S.G. Catron    09/15/92  : Before calling BSnodevals, change _t_h_e
                               knot_tol to the appropriate knot tolerance
                               for the trace curve because BSnodevals 
                               extracts the knot_tol inside.
    S.G. Catron    03/09/93  : Initialize ncsp. Using nvec[i] when it
                               had not been set(code=1).
    S.G. Catron    06/23/93  : Added code for principal normal flips.
                               Added a check for midnodes, instead of
                               looking at previous node.
    S.G. Catron    09/03/93  : Set fpar0 and fpar1 separately for lawcvs
                               and lawcvo.
    S.G. Catron    01/06/94  : Added "ifdef DEBUG" so I can print out
                               interior cross sections.
    S.G. Catron    01/09/98  : In section after call to BSprncp_nor where
                               rc=BSNOSOLUTION...when copying the previous
                               atmat[l-2], the tangent row should be
                               negated.  We store -tan in the atmat, and
                               the midmat[2] is expected to not be 
                               negated.
*/

#include <stdio.h>

#include <math.h>
#include "bsdefs.h"
#include "bserr.h"
#include "bsstackalloc.h"
#include "bsstk.h"
#define  BSVOID
#include "bsparameters.h"
#include "bsmemory.h"
#include "bstypes.h"
#define  MAXNUM 50
#define  SMAXNUM 20
#define MAXNUM2 100

static void matBSmksfb2cs(
IGRdouble trnod1,
IGRdouble	 trnod2,
struct IGRbsp_curve *tcv1,
struct IGRbsp_curve 	 *tcv2,
IGRvector           nvec,
BSmat               smat,
BSrc                *rc)
{
#include "bscveval.h"
#include "bscrossp.h"
#include "bsnorvec.h"
   IGRpoint eval[2], eval1[2];
   IGRint num_derv0=0, k;

   *rc = BSSUCC;


   BScveval(tcv1, trnod1, num_derv0, eval, rc);
   if(BSERROR(*rc))
      goto wrapup; 
   BScveval(tcv2, trnod2, num_derv0, eval1, rc);
   if(BSERROR(*rc))
      goto wrapup; 
   for(k=0; k<3; k++)
      smat[0][k] = eval[0][k] - eval1[0][k];
   for(k=0; k<3; k++)
      smat[2][k] = -nvec[k];
   (void)BScrossp(rc, smat[2], smat[0], smat[1] );
   if(BSERROR(*rc))
      goto wrapup;
   (void)BSnorvec(rc, smat[0]);
   if(BSERROR(*rc))
      goto wrapup;
   (void)BSnorvec(rc, smat[1]);
   if(BSERROR(*rc))
      goto wrapup;
   (void)BSnorvec(rc, smat[2]);
   if(BSERROR(*rc))
      goto wrapup;

   wrapup:
   return;
}
/* this routine dots vec1 with mat[1] and according to "which", it negates
   either vec1 or mat(mat[0] and mat[1])  */
static void dotBSmksfb2cs(
IGRvector vec1,    
IGRvector dtan,    
BSmat     mat,     
IGRint    *which,   
IGRdouble neg,    
IGRint    ind,
BSrc   *rc)    
{
#include "bsdotp.h"
   IGRdouble dot, dot2, ttan[3];
   IGRint   i;

   *rc = BSSUCC;

   for(i=0; i<3; i++)
      ttan[i] = dtan[i] * neg;
   dot = BSdotp(rc, vec1, mat[ind] );
   if(BSERROR(*rc))
      goto wrapup;
   dot2 = BSdotp(rc, ttan, mat[2] );
   if(BSERROR(*rc))
      goto wrapup;
   /* if the normals are flipping, and the same _t_a_n_g_e_n_t_s are not, then
      we need to flip the normal....but if due to sharp curvature of the
      curve then tangents are changing directions, so should the normals
      and we don't need to flip them */
   if( dot < 0 && dot2 > 0)
   {
      if( *which == 1 )
      {
         for(i=0; i<3; i++)
            vec1[i] *= -1;
      }
      else
      {
         for(i=0; i<3; i++)
         {
            mat[0][i] *= -1;
            mat[1][i] *= -1;
         }
      }
      *which = -1;
   }
   wrapup:
   return;
}

 
void BSmksfb2cs(
IGRint                numtrc,
struct IGRbsp_curve   *tcvs[],
IGRint                numcs,
struct IGRbsp_curve   *csl[],
BSmat                 tmat[],
BSmat	smat[],
IGRboolean            scale_height,
struct IGRbsp_curve   *lawcvs,
struct IGRbsp_curve   	*lawcvo,

IGRboolean            orient_abs,
struct IGRbsp_surface *tsf1,
struct IGRbsp_surface                       *tsf2,
struct IGRbsp_surface                       *csf1,
struct IGRbsp_surface 	*csf2,

struct IGRbsp_surface **surf,
BSrc                  *rc)
{
#include "bsdbgrc.h"
#include "bscomb2sfs.h"
#include "bsadktbmkts.h"
#include "bsalloccv.h"
#include "bsallocsf.h"
#include "bscveval.h"
#include "bssfeval.h"
#include "bsnodevals.h"
#include "bsadd_kts.h"
#include "bslawcvvals.h"
#include "bscvkttol2.h"
#include "bsfndspnarr.h"
#include "bsfndcvcsp.h"
#include "bssfthcvsbd.h"
#include "bschgcvewts.h"
#include "bscrossp.h"
#include "bscv_copy.h"
#include "bsnorvec.h"
#include "bsfindmkts.h"
#include "bsprj_cv_pl.h"
#include "bscveval_b.h"
#include "bsarclength.h"
#include "bscumdist.h"
#include "bschangepar.h"
#include "bspl_cv_int.h"
#include "bsfreecv.h"
#include "bsfreesf.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "bslenvecsq.h"
#include "bststsfcusp.h"

#include "bsprncp_nor.h"
#include "bsplanar2.h"
#include "bslsqplvpts.h"
#include "bsfndintcrs.h"
#include "bsbrklincsp.h"
#include "bsfndtsmats.h"
#include "bsfitratcv.h"
#include "bslsqptlnpl.h"
#include "bscvntoo.h"
#include "bststcvdegn.h"

   IGRint  i, j, k, num_mul, sum, nd, l,m, n,
           n_int, n_seg, *mulktind=NULL, ind=0,
           amulktind[MAXNUM], num_poles,
           num_knots, sizep=0, num_derv0=0,
           newnumkts, sizetrnodes=0, numinsert,tnuminsert,
           num_derv1=1, sizecvsl=0, tn, degen,
           sizenewknots=0, num_nodes, end=0,
           tnumtrc, sizetmul, code,
           ncsp=0, trcode, nump, *numpts=NULL,
           anumpts[MAXNUM], *start=NULL,
           astart[MAXNUM], which, which2,
           opt=3;
   IGRdouble  *u1=NULL, au1[MAXNUM], 
              *a=NULL, aa[MAXNUM],
              *b=NULL, bb[MAXNUM],
              **trnodes=NULL, scale=1.0,
              *atrnodes[SMAXNUM],
              atrnodesar[MAXNUM2], *tmul=NULL,
              atmul[MAXNUM], *knots, *newknots=NULL,
              anewknots[MAXNUM], 
              *sfvals=NULL, *ofvals=NULL,
              *ptrsfvals=NULL, *ptrofvals=NULL,
              asfvals[MAXNUM], aofvals[MAXNUM],
              fval0=0, fval1=0, fpar0=0, fpar1=0,
              d, d1, *ptr, *ptr2, avg, *wptr=NULL, *wptr2,
              *arcl=NULL, aarcl[MAXNUM],
              *sarcl=NULL,asarcl[MAXNUM], cumdist, arclen_tol,
              temp_tol, knot_tol, dist_tol, tknot_tol,
              dot, cross_sqtol, len, dist_sqtol,
              *csps=NULL,acsps[MAXNUM], sqdist,
              **ptrtrn, *svptr, delta, *wts=NULL,
              err, tdelta=0, neg=1.0, sknot_tol, midpar;
   IGRpoint   eval[2], avgtan, eval2,
              *int_pts=NULL, aint_pts[MAXNUM],
              vecsum, lasteval, eval1[2],
              *points=NULL, apoints[MAXNUM], lderv[2],
              rderv[2], maxpt;
   IGRvector vec,lnorm, rnorm,  vvec,
             *nvec=NULL, anvec[MAXNUM];
   IGRshort  order;
   IGRboolean  crational, trational, lin=FALSE,
               alloc, planar, dir, rational, nodeopt,
               allocfsurf = FALSE, tmulalloc=FALSE,
               mulktindalloc = FALSE, eval_b=TRUE,
               bound, cspsalloc=FALSE, nodcspsalloc=FALSE,
               *nodcsps=NULL,anodcsps[MAXNUM], prevcode=0,
               *linear=NULL, alinear[MAXNUM], pcode,
               tmat2alloc=FALSE,  tequal=FALSE,
               smat2alloc=FALSE, linearalloc=FALSE,
               startalloc=FALSE, numptsalloc=FALSE,
               failedbefore, *tdegen=NULL, atdegen[MAXNUM],
               tdegenalloc = FALSE, flip;
   struct IGRbsp_curve **cvptr, **csptr, *acsptr[4],
                       *trptr, *cvsl[2], *oncsl[2],
                       **fcvs=NULL, *afcvs[MAXNUM];
   struct IGRbsp_surface   **fsurf=NULL, *afsurf[MAXNUM],
                           *ptrtsf1=NULL, *ptrtsf2=NULL;
   BSmat      *atmat=NULL, aatmat[MAXNUM], *matptr,
              tsmat[2], ttmat[2], otmat[2], midmat;
   BSmat2     *tmat2=NULL, *smat2=NULL, 
              atmat2[SMAXNUM],asmat2[SMAXNUM];
   BSrc       rc1;
   IGRboolean closed;
#ifdef DEBUG
   FILE *outfile;
   extern FILE *fopen();
   static char fname[100] ;
#include "bsprintbspc.h"
   IGRchar name;
   IGRboolean option=FALSE;

   /* this way you can input the file name from the screen 
       this is an output file,  because the 'w' is for writing to  */
   printf("input file name? ");
   scanf("%s",fname);
   if(!(outfile = fopen(fname,"w")))exit(0);
 #endif

   BSEXTRACTPAR(rc, BSTOLARCLEN, arclen_tol);
   BSEXTRACTPAR(rc, BSTOLSQCOLLINVEC, cross_sqtol);
   BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);
   BSEXTRACTPAR(rc, BSTOLSQLENVEC, dist_sqtol );

   oncsl[0] = NULL;
   oncsl[1] = NULL;
   cvsl[0] = NULL;
   cvsl[1] = NULL;

   if( numtrc == 1 )
      tnumtrc = 2;
   else
      tnumtrc = numtrc;

   if( numtrc > MAXNUM )
   {
      fsurf = (struct IGRbsp_surface **)BSstackalloc((unsigned)( 
                           numtrc * sizeof(struct IGRbsp_surface *)));
      if(! fsurf )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      allocfsurf = TRUE;
   }
   else
      fsurf = afsurf;

   for(i=0; i<numtrc; i++)
      fsurf[i] = NULL;
   if( tcvs[0]->rational)
      trational = TRUE;
   else
      trational = FALSE;
   if( numtrc > 3 )
      nodeopt = FALSE;
   else 
      nodeopt = TRUE;

   /* find the node values for each trace */
   if( numtrc > SMAXNUM  )
   {
      trnodes = (IGRdouble **)BSstackalloc((unsigned)( numtrc * sizeof
                                               (IGRdouble *)));
      if(! trnodes )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      trnodes = atrnodes;
   }
   num_poles = tcvs[0]->num_poles;
   tnuminsert = 1;
   numinsert = numtrc > 3 ? tnuminsert : 0;
   num_nodes = (num_poles - 1) * (numinsert+1) + 1;

   sizetrnodes = MIN(MAXNUM2/num_nodes, numtrc );
   for(i=0; i< sizetrnodes; i++)
   {
      trnodes[i] = &atrnodesar[i*num_nodes];
   }
   if( sizetrnodes < numtrc )
   {
      for(i=sizetrnodes; i< numtrc; i++)
      {
         trnodes[i] = (IGRdouble *)BSstackalloc((unsigned)( 
                        num_nodes * sizeof(IGRdouble)));
         if(!trnodes[i] )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
   }

   /* remember traces are compatible */

   BSEXTRACTPAR(rc, BSTOLKNOT, sknot_tol );
   trptr = tcvs[0];
   order = trptr->order;
   BScvkttol2(order, trptr->knots, num_poles, 
              trptr->poles, trptr->weights, &tknot_tol, rc);
   if(BSERROR(*rc))
      goto wrapup;
   (void)BSchangepar(rc, BSTOLKNOT, tknot_tol );
   if(BSERROR(*rc))
     goto wrapup;
   BSnodevals(trptr->order, trptr->num_knots, trptr->knots, numinsert,
              &num_nodes, trnodes[0], rc);
   if(BSERROR(*rc))
   {
      (void)BSchangepar(&rc1, BSTOLKNOT, sknot_tol );
      goto wrapup;
   }
   (void)BSchangepar(rc, BSTOLKNOT, sknot_tol );
   if(BSERROR(*rc))
     goto wrapup;

   for(i=1; i< numtrc; i++)
   {
      for(j=0; j< num_nodes; j++)
         trnodes[i][j] = trnodes[0][j];
   }
   if( numtrc == 1 && !orient_abs )
   {
      if( num_poles > MAXNUM )
      {
         csps = (IGRdouble *)BSstackalloc((unsigned)( num_poles *
                                           sizeof(IGRdouble )));
         if(! csps )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         cspsalloc = TRUE;
      }
      else
         csps = acsps;

      /* find the trace cusps */
      BSfndcvcsp(trptr, &ncsp, csps, rc);
      if(BSERROR(*rc))
         goto wrapup;

      /* set up array flagging which node values are cusps */
      if( num_nodes > MAXNUM )
      {
         nodcsps = (IGRboolean *)BSstackalloc((unsigned)( num_nodes * 
                                    sizeof(IGRboolean)));
         if(! nodcsps )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         nodcspsalloc = TRUE;
      }
      else
         nodcsps = anodcsps;
 
      if( ncsp > 0 )
      {
         j = 0;
         for(i=0; i< ncsp; i++)
         {
            for(; j< num_nodes; j++)
            {
               if( fabs(trnodes[0][j] - csps[i]) < tknot_tol )
               {
                  nodcsps[j] = TRUE;
                  j++;
                  break;
               }
               else
                  nodcsps[j] = FALSE;
            }
         }
         for(; j< num_nodes; j++)
            nodcsps[j] = FALSE;
      }
      else
      {
         for(j=0; j< num_nodes; j++)
            nodcsps[j] = FALSE;
      }         
   }

   if( numtrc > 2 )
   {
      if( numtrc > MAXNUM )
      {
         tdegen = (IGRboolean *)BSstackalloc((unsigned)( numtrc * sizeof
                                         (IGRboolean)));
         if(!tdegen )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         tdegenalloc = TRUE;
      }
      else
         tdegen = atdegen;
      for(i=1; i<numtrc-1; i++)
      {
         BStstcvdegn(tcvs[i], &tdegen[i], rc);
         if(BSERROR(*rc))
            goto wrapup;
         if( tdegen[i] )
         {
            tdelta = num_nodes-1;
            tdelta = (tcvs[0]->knots[tcvs[0]->num_poles] -
                    tcvs[0]->knots[tcvs[0]->order-1]) / tdelta;
         }   
      } 
      /* otherwise we have to do plane cuts to find a kind of average
         node value to place cross section at */
      sizep = num_poles;
      if( sizep > MAXNUM )
      {
         u1 = (IGRdouble *)BSstackalloc((unsigned)( sizep * 
                                             sizeof(IGRdouble)));
         if(!u1 )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         a = (IGRdouble *)BSstackalloc((unsigned)( sizep * 
                                             sizeof(IGRdouble)));
         if(!a )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         b = (IGRdouble *)BSstackalloc((unsigned)( sizep * 
                                             sizeof(IGRdouble)));
         if(!b )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         int_pts = (IGRpoint *)BSstackalloc((unsigned)( sizep * 
                                             sizeof(IGRpoint)));
         if(!int_pts )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         u1 = au1;
         a = aa;
         b = bb;
         int_pts = aint_pts;
      }
      /* allocate space for the normal vectors */
      if( num_nodes  > MAXNUM )
      {
         nvec = (IGRvector *)BSstackalloc((unsigned)( num_nodes *
                              sizeof(IGRvector)));
         if(! nvec )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         nvec = anvec;
      }
      if( numtrc > MAXNUM )
      {
         points = (IGRpoint *)BSstackalloc((unsigned)( numtrc * 
                                         sizeof(IGRpoint)));
         if(! points )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         points = apoints;
      }      
                
      /* check to see if the first trace and the last trace are the 
         same...if three poles are equal, assume traces are the same */
      tequal = TRUE;
      if( trational )
      {
         ptr = trptr->poles;
         wptr = trptr->weights;
         ptr2 = tcvs[numtrc-1]->poles;
         wptr2 = tcvs[numtrc -1]->weights;
         for(i=0; i< MIN(num_poles, 3); i++)
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
         ptr = trptr->poles;               
         ptr2 = tcvs[numtrc-1]->poles;

         for(i=0; i< MIN(num_poles,3); i++)
         {
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
      if( tequal)
         ind = numtrc / 2;
      else
         ind = numtrc -1;


      /* find last normal vector  */
      for(k=0; k<3; k++)
         avgtan[k] = 0.0;
      /* call BSlsqptlnpl to find the least square plane, if one */
      for(j=0; j< numtrc; j++)
      {
         BScveval(tcvs[j], trnodes[j][num_nodes-1], num_derv1, eval, rc);
         if(BSERROR(*rc))
            goto wrapup; 
         for(k=0; k<3; k++)
         {
            points[j][k] = eval[0][k];
            avgtan[k] += eval[1][k];
         }
      }
      for(k=0; k<3; k++)
         vecsum[k] = points[ind][k] - points[0][k];
      end = numtrc - tequal;
      BSlsqptlnpl(end, (IGRdouble *)points, wts, opt, &code,maxpt,
                  nvec[num_nodes-1], &err, rc);
      if(BSERROR(*rc))
         goto wrapup;
      for(k=0; k<3; k++)
         avgtan[k] /= numtrc;

      if( code == 1 || code == 2 )
      {
         if( code == 2 )
         {
            /* points are linear */

            for(k=0; k<3; k++)
               nvec[num_nodes-1][k] = avgtan[k]; 
            /* cross and cross back to get normal vector exactly 
               perpendicular to vecsum */
            (void)BScrossp(rc, vecsum, nvec[num_nodes-1], eval2);
            if(BSERROR(*rc))
               goto wrapup;        
            (void)BScrossp(rc, vecsum, eval2, nvec[num_nodes-1]);
            if(BSERROR(*rc))
               goto wrapup;        
            (void)BSnorvec(rc, nvec[num_nodes-1]);
            if(BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            /* points are coincident...find next to last and copy */
            for(k=0; k<3; k++)
               avgtan[k] = 0.0;
            for(j=0; j< numtrc; j++)
            {
               BScveval(tcvs[j], trnodes[j][num_nodes-2], num_derv1, eval,
                        rc);
               if(BSERROR(*rc))
                  goto wrapup; 
               for(k=0; k<3; k++)
               {
                  points[j][k] = eval[0][k];
                  avgtan[k] += eval[1][k];
               }
            }
            for(k=0; k<3; k++)
               vecsum[k] = points[ind][k] - points[0][k];
            end = numtrc  - tequal;
            BSlsqptlnpl(end, (IGRdouble *)points, wts, opt, &code, maxpt, 
                        nvec[num_nodes-2], &err, rc);
            if(BSERROR(*rc))
               goto wrapup;
            if(code == 1 )
            {
               *rc = BSFAIL;
               goto wrapup;
            }
            if( code == 2 )
            {
               /* points are linear */
   
               for(k=0; k<3; k++)
                  nvec[num_nodes-2][k] = avgtan[k]; 
               /* cross and cross back to get normal vector exactly 
                  perpendicular to vecsum */
               (void)BScrossp(rc, vecsum, nvec[num_nodes-2], eval2);
               if(BSERROR(*rc))
                  goto wrapup;        
               (void)BScrossp(rc, vecsum, eval2, nvec[num_nodes-2]);
               if(BSERROR(*rc))
                  goto wrapup;        
               (void)BSnorvec(rc, nvec[num_nodes-2]);
               if(BSERROR(*rc))
                  goto wrapup;
            }
            for(k=0; k<3; k++)
               nvec[num_nodes-1][k] = nvec[num_nodes-2][k];
         }/*  coincident */
      }         
      dot = BSdotp(rc, avgtan, nvec[num_nodes-1] );
      if(BSERROR(*rc))
         goto wrapup;
      if( dot > 0 )
      {
         for(k=0; k<3; k++)
            nvec[num_nodes-1][k] *= -1;
      }

      rational = FALSE;
      /* remember first and last node values are fine */
      for(i=0; i<num_nodes-1; i++)
      {
         for(k=0; k<3; k++)
            avgtan[k] = 0.0;

         /* call BSlsqplvpts to find the least square plane, if one */
         for(j=0; j< numtrc; j++)
         {
            BScveval(tcvs[j], trnodes[j][i], num_derv1, eval, rc);
            if(BSERROR(*rc))
               goto wrapup; 
            for(k=0; k<3; k++)
            {
               points[j][k] = eval[0][k];
               avgtan[k] += eval[1][k];
            }
         }
         for(k=0; k<3; k++)
         {
            vecsum[k] = points[ind][k] - points[0][k];
         }
         end = numtrc -1 - tequal;
         if( i == 0 )
         {
            end = numtrc  - tequal;
            BSlsqptlnpl(end, (IGRdouble *)points, wts, opt, &code, maxpt, 
                        nvec[0], &err, rc);
         }
         else
         {
            BSlsqplvpts(points[0], vecsum, end, (IGRpoint *)&points[1][0],
                        wts,&code, nvec[i], rc); 
         }
         if(BSERROR(*rc))
            goto wrapup;
         for(k=0; k<3; k++)
            avgtan[k] /= numtrc;
         if( code > 2 )
         {
            dot = BSdotp(rc, avgtan, nvec[i] );
            if(BSERROR(*rc))
               goto wrapup;
            if( dot > 0 )
            {
               for(k=0; k<3; k++)
                  nvec[i][k] *= -1;
            }
         }
         
         if( code == 1 || (prevcode == 1 && code != 2) )
         {
            /* copy the previous one */
            if( prevcode == 1 )
            {
               for(k=0; k<3; k++)
                  nvec[i-1][k] = nvec[i][k];
               prevcode = 0;
            }
            else
            {
               if( i > 0 )
                  for(k=0; k<3; k++)
                     nvec[i][k] = nvec[i-1][k];
               else
                  prevcode = 1;
             }
         }
         else
            if( prevcode != 1) 
               prevcode = 0;

         if( code != 2 && numtrc == 3)
            /* not linear and don't need to cut with plane */
            continue;
         
         if( code == 2 )
         {
            /* points are linear */
            for(k=0; k<3; k++)
               nvec[i][k] = avgtan[k]; 
            /* cross and cross back to get normal vector exactly 
               perpendicular to vecsum */
            (void)BScrossp(rc, vecsum, nvec[i], eval2);
            if(BSERROR(*rc))
               goto wrapup;        
            (void)BScrossp(rc, vecsum, eval2, nvec[i]);
            if(BSERROR(*rc))
               goto wrapup;        
            if( prevcode == 1 )
               for(k=0; k<3; k++)
                  nvec[i-1][k] = nvec[i][k];
            (void)BSnorvec(rc, nvec[i]);
            if(BSERROR(*rc))
               goto wrapup;
            prevcode = 0;
            if( numtrc == 3 )
               /* code was 2, but now we have a normal */
               continue;

         }  /* code = 2 */

         if(i == 0 || i == num_nodes -1)
            continue;   /* at first and last nodes the nodes are fine */
                        /* because we have already split the traces at */
                        /* the cross sections in previous routine */

         failedbefore = FALSE;
         for(j=1; j< numtrc-tequal; j++)
         {
            if( j == ind )
               continue;
            if( tdegen[j] )
            {
               trnodes[j][i] = i * tdelta;
               continue;
            }
            /* now do a plane cut with each trace to find the new node
               point */
            (void)BSpl_cv_int(rc, tcvs[j], points[0], nvec[i], &n_int,
                              (IGRdouble *)int_pts, u1, &n_seg, a, b);
            if(BSERROR(*rc))
               goto wrapup;
            if( n_int == 0 )
            {
               if( failedbefore)
               {
                  *rc = BSNOINTERS;
                  goto wrapup;
               }
               /* we don't want BSpl_cv_int to fail, so we have to find
                  another normal vector  */
               if( i < num_nodes /2 )
               {
                  /* failing at beginning */
                  for(k=0; k<3; k++)
                     nvec[i][k] =  nvec[i-1][k];
               }
               else
               {              
                  delta = num_nodes - i;
                  for(k=0; k<3; k++)
                     nvec[i][k] =  (delta-2)/delta * nvec[i-1][k] + 
                                   2.0/delta * nvec[num_nodes-1][k];
                }
               /* calculate new normal vector */
               (void)BScrossp(rc, nvec[i], vecsum, vvec );
               if(BSERROR(*rc))
                  goto wrapup;
               (void)BScrossp(rc, vecsum, vvec, nvec[i] );
               if(BSERROR(*rc))
                  goto wrapup;
               (void)BSnorvec(rc, nvec[i] );
               if(BSERROR(*rc))
                  goto wrapup;
               dot = BSdotp(rc, avgtan, nvec[i] );
               if(BSERROR(*rc))
                  goto wrapup;
               if( dot > 0 )
               {
                  for(k=0; k<3; k++)
                     nvec[i][k] *= -1;
               }
               j = 0;
               failedbefore = TRUE;
               continue;
            }
            if( n_int > 1 )
            {
               d1 = BSdistptpts(rc, int_pts[0], points[0] );
               if(BSERROR(*rc))
                  goto wrapup;
               trnodes[j][i] = u1[0];
               for(k=1; k< n_int; k++)
               {
                  d = BSdistptpts(rc, int_pts[k], points[0] );
                  if(BSERROR(*rc))
                     goto wrapup;
                  if( d < d1)
                  {
                     trnodes[j][i] = u1[k];
                  }
               }
            }
            else                                      
            {
               trnodes[j][i] = u1[0];
            }
            /* check parameters, must be ascendind */
            if( trnodes[j][i] < trnodes[j][i-1] )
            {
               *rc = BSINVPRVALS;
               goto wrapup;
            }
         }
      }
   }


   if( numcs > 1 )
   {
      /* now that we have the "node values" we need to find the arclengths
         between them on each trace average across all traces and use 
         these parameters to call the law functions later with */
      if( num_nodes  > MAXNUM )
      {
         arcl = (IGRdouble *)BSstackalloc((unsigned)( num_nodes * sizeof
                                                        (IGRdouble)));
         if(! arcl )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         sarcl = (IGRdouble *)BSstackalloc((unsigned)( num_nodes * sizeof
                                                        (IGRdouble)));
         if(! sarcl )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         ofvals = (IGRdouble *)BSstackalloc((unsigned)( num_nodes *
                               sizeof(IGRdouble)));
         if(! ofvals )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         sfvals = (IGRdouble *)BSstackalloc((unsigned)( num_nodes *
                              sizeof(IGRdouble)));
         if(! sfvals )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         arcl = aarcl;
         sarcl = asarcl;
         ofvals = aofvals;
         sfvals = asfvals;
      }
      degen = 0;
      for(i=0; i< numtrc; i++)
      {
         trptr = tcvs[i];
         (void)BScumdist(rc, &trptr->num_poles, trptr->poles, 
                            trptr->weights, &cumdist);
         if(BSERROR(*rc))
            goto wrapup;
         if( cumdist < dist_tol)
         {
            degen += 1;
            continue;
         }
         temp_tol = cumdist / 100;
         /* change arclen_tol back to new temp_tol */
         (void)BSchangepar(rc, BSTOLARCLEN, temp_tol);
         if(BSERROR(*rc))
            goto wrapup;
   
         for(j=0; j< num_nodes; j++)
         {
            if( i == 0 || (i ==1 && degen == 1) )
               sarcl[j] = 0;
            if( j == 0 )
               arcl[j] = 0.0;
            else
            {
               (void)BSarclength(rc, trptr, &trnodes[i][j-1], 
                                    &trnodes[i][j], &arcl[j]);
               if(BSERROR(*rc))
                  goto wrapup;
               arcl[j] += arcl[j-1];
            }
         }
         /* normalize each trace */
         for(j=1; j< num_nodes; j++)
         {
            arcl[j] /= arcl[num_nodes-1];
            sarcl[j] += arcl[j];           
         }
      }
      /* change arclen_tol back to original */
      (void)BSchangepar(rc, BSTOLARCLEN, arclen_tol );
      if(BSERROR(*rc))
        goto wrapup;
      if( numtrc > 1 )
      {
         /* find the average */
         for(i=1; i<num_nodes; i++)
         {
            sarcl[i] /= (numtrc - degen);
         }
      }
      /* find lawcv values for node values */
      fpar0 = lawcvo->knots[lawcvo->order-1];
      fpar1 = lawcvo->knots[lawcvo->num_poles];
      fval0 = 0.0;
      fval1 = 1.0;
      BSlawcvvals(lawcvo, fval0, fval1, fpar0, fpar1, num_nodes,
                  sarcl, lin, ofvals, rc);
      if(BSERROR(*rc))
         goto wrapup;      
      fpar0 = lawcvs->knots[lawcvs->order-1];
      fpar1 = lawcvs->knots[lawcvs->num_poles];

      BSlawcvvals(lawcvs, fval0, fval1, fpar0, fpar1, num_nodes,
                  sarcl, lin, sfvals, rc);
      if(BSERROR(*rc))
         goto wrapup; 
   }
   
   crational = FALSE;
   for(i=0; i< numcs; i++)
   {
      if( csl[i]->rational)
         crational = TRUE;
   }
   rational = crational || trational ;
   /* find the tmat at each node */
   /* we don't need tmat's if it is orient_abs or numtrc > 2 ...
      but we do need the space for sending smat's down to BSfndintcrs */
   if( num_nodes > MAXNUM )
   {
      atmat = (BSmat *)BSstackalloc((unsigned)( num_nodes * sizeof
                                                 (BSmat)));
      if(! atmat )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      atmat = aatmat;
   }
   if( !orient_abs && numtrc < 3 )
   {
      if( numcs == 1 )
         end = num_nodes;
      else
         end = num_nodes -1;
      if ( numtrc > 1 )
      {
         BSplanar2(tcvs[0]->num_poles, (IGRpoint *)tcvs[0]->poles,
                   tcvs[0]->weights, &trcode, vec, rc);
         if(BSERROR(*rc))
            goto wrapup;

         for(j=1; j< end; j++)
         {
            for(i=0; i< numtrc; i++)
            {
               BScveval( tcvs[i], trnodes[i][j], num_derv1, eval, rc );
               if (BSERROR(*rc))
                  goto wrapup;
               if(  i > 0)
               {
                  /* sum vectors between traces, so we can later take
                     average */
                  /* sum tangents so we can later take average */
                  for(k=0; k<3; k++)
                  {
                     vecsum[k] += (eval[0][k] - lasteval[k]);
                     avgtan[k] += eval[1][k];
                  }
               }
               else
               {
                  /* initialize tangent and set point to last eval for
                     use in next loop */
                  for(k=0; k<3; k++)
                  {
                     avgtan[k] = eval[1][k];
                     vecsum[k] = 0.0;
                  }
               }
               for(k=0; k<3; k++)
                  lasteval[k] = eval[0][k];

            } /* end for */
            len = BSlenvecsq(rc, vecsum);
            if(BSERROR(*rc))
               goto wrapup;
            if( len < cross_sqtol )
            {
               /* use previous vecsum  */
               if( j == 1 )
               {
                  for(k=0; k<3; k++)
                     vecsum[k] = tmat[0][0][k];
               }
               else
               {
                  for(k=0; k<3; k++)
                     vecsum[k] = atmat[j-2][0][k];
               }
            }
          
            /* find average of tangents  and connecting vectors */
            if( len > cross_sqtol )
            {
               for(k=0; k<3; k++)
               {
                  avgtan[k] /= numtrc;
                  vecsum[k] /= (numtrc -1 );
               }
            }             
            (void)BScrossp(rc, vecsum, avgtan, atmat[j-1][1]);
            if(BSERROR(*rc))
              goto wrapup;
            /* since we averaged the tangents and connecting vectors,
               avgtan and vecsum are not perpendicular...so we have to
               make them perpendicular */
                (void)BScrossp(rc, atmat[j-1][1], vecsum, avgtan);
            if(BSERROR(*rc))
               goto wrapup;
            (void)BSnorvec(rc, avgtan);
            if(BSERROR(*rc))
               goto wrapup;
            for(k=0; k<3; k++)
            {
               atmat[j-1][2][k] = avgtan[k];
               atmat[j-1][0][k] = vecsum[k];
            }
            for(k=0; k<3; k++)
               atmat[j-1][2][k] *= -1.0;
            (void)BSnorvec(rc, atmat[j-1][0] );
            if(BSERROR(*rc))
               goto wrapup;
            (void)BSnorvec(rc, atmat[j-1][1] );
            if(BSERROR(*rc))
               goto wrapup;
         }                         
      }
   }
   else
   {
      if( numtrc > 2 && numcs > 1)
      {
         /* find smat[0] and smat[1], for later use in finding tangents */
         BScveval(tcvs[0], trnodes[0][0], num_derv0, eval, rc);
         if(BSERROR(*rc))
            goto wrapup; 
         BScveval(tcvs[numtrc-1], trnodes[numtrc-1][0], num_derv0, eval1, 
                  rc);
         if(BSERROR(*rc))
            goto wrapup; 
         for(k=0; k<3; k++)
            vec[k] = eval[0][k] - eval1[0][k];
         len = BSlenvecsq(rc, vec);
         if(BSERROR(*rc))
            goto wrapup;
         if( len < cross_sqtol )
            j = numtrc / 2;
         else
            j = numtrc-1;
         for(i=0; i< num_nodes; i++)
         {
            if( i == 0 )
               matptr = smat;
            else
            {
               if( i == num_nodes-1 )
                  matptr = smat+1;
               else
                  matptr = atmat+(i-1);
            }
            matBSmksfb2cs(trnodes[0][i], trnodes[j][i], tcvs[0], tcvs[j], 
                          nvec[i], *matptr, rc);
            if(BSERROR(*rc))
            {
               if(*rc == BSDGENRAT && (i == 0 || i == num_nodes-1)  )
               {
                  /* it must be degenerate at this point, so copy the 
                      previous one or next one */
                  *rc = BSSUCC;
                  if( i == 0 )
                  {
                     matBSmksfb2cs(trnodes[0][i+1], trnodes[j][i+1], 
                                   tcvs[0], tcvs[j], nvec[i+1],*matptr,rc);
                     if(BSERROR(*rc))
                        goto wrapup;                         
                  }
                  else
                     BSMEMCPY(sizeof(BSmat), (IGRchar *)atmat[i-2], 
                              (IGRchar *)smat[1] );
               }
               else
                  goto wrapup;
            }
         }
      }
   }
   /* allocate the structures for curves returned from BSadd_kts */
   for(i=0; i< numcs; i++)
   {
      cvsl[i] = (struct IGRbsp_curve *)BSstackalloc((unsigned)( sizeof
                                      (struct IGRbsp_curve )));
      if( !cvsl[i] )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }   
   if( numcs == 1 )
      sizetmul = csl[0]->num_poles;
   else
      sizetmul = csl[0]->num_poles + csl[1]->num_poles;

   if( sizetmul > MAXNUM )
   {
      tmulalloc = TRUE;
      tmul = (IGRdouble *)BSstackalloc((unsigned)( sizetmul * sizeof
                                 (IGRdouble)));
      if(! tmul )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
      mulktindalloc = TRUE;
      mulktind = (IGRint *)BSstackalloc((unsigned)( sizetmul * 
                                     sizeof(IGRint)));
      if(! mulktind )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
   {
      tmul = atmul;
      mulktind = amulktind;
   }

   if( num_nodes > MAXNUM )
   {
      fcvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)( 
                            num_nodes *  sizeof(struct IGRbsp_curve *)));
      if(! fcvs )
      {
         *rc = BSNOSTKMEMORY;
         goto wrapup;
      }
   }
   else
      fcvs = afcvs;
   alloc = FALSE;
   
   tn = numtrc == 1 ? 1 : 2;
   if (tmat)
   { 
     BSMEMCPY(sizeof(BSmat), (IGRchar *)tmat[0], (IGRchar *)otmat[0]);
   }
   if( numcs == 2  && tmat)
      BSMEMCPY(sizeof(BSmat), (IGRchar *)tmat[1], (IGRchar *)otmat[1]);
   for(i=0; i< tnumtrc-1; i++)
   {
      order = csl[i*numcs]->order;
      num_knots = csl[i*numcs]->num_knots;
      knots = csl[i*numcs]->knots;
      cvptr = &csl[i*numcs];

      num_poles = num_knots - order;
      /* see if space already allocated for tmul/mulktind is big enough */
      if( num_poles > MAXNUM )
      {
         if( num_poles > sizetmul )
         {
            if( tmulalloc )
            {
               /* free last tmul */
               if( tmul )
                  BSstackdealloc((char *)tmul );
               tmulalloc = FALSE;
               if( mulktind )
                  BSstackdealloc((char *)mulktind );
               mulktind = FALSE;
            }
            sizetmul = num_poles;
            tmulalloc = TRUE;
            tmul = (IGRdouble *)BSstackalloc((unsigned)( num_poles * 
                                sizeof(IGRdouble)));
            if(! tmul )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            mulktindalloc = TRUE;
            mulktind = (IGRint *)BSstackalloc((unsigned)( num_poles * 
                                           sizeof(IGRint)));
            if(! mulktind )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
         }
      }
      BScvkttol2(order, knots, num_poles, cvptr[0]->poles, 
                 cvptr[0]->weights, &knot_tol, rc);
      if(BSERROR(*rc))
         goto wrapup;
      (void)BSfindmkts(rc, &order, (IGRlong *)&num_poles, knots, 
                       &knot_tol, &num_mul, tmul, mulktind);
      if(BSERROR(*rc))
         goto wrapup;
      /* size of newknots is
         even order - num_knots + num_mul + 1
         odd order  - num_knots + (num_mul + 1) * 2
      */
      if( sizenewknots > MAXNUM && newknots)
         BSstackdealloc((char *) newknots);
      if( order % 2 )      
         sizenewknots = num_knots + (num_mul + 1) * 2;
      else
         sizenewknots = num_knots + num_mul + 1;
      if( sizenewknots > MAXNUM )
      {
         newknots = (IGRdouble *)BSstackalloc((unsigned)( sizenewknots *
                                     sizeof(IGRdouble)));
         if(! newknots )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         newknots = anewknots;
      }
      if( order == 2 )
      {
         newnumkts = num_knots;
         for(j=0; j<num_knots; j++)
            newknots[j] = knots[j];
      }
      else
      {         
         BSadktbmkts(order, num_knots, knots, num_mul,mulktind,&newnumkts,
                     newknots, rc);
         if(BSERROR(*rc))
            goto wrapup;
      }
      num_poles = newnumkts - order;
      if(num_mul > 0 ) 
      {
         /* the indices in mulktind have changed and we will need the
            correct ones for BSwavsc2cvs and BSfxuvplmkt */
         BSfndspnarr(order, num_poles, num_mul, tmul, newknots, mulktind,
                     rc);
         if(BSERROR(*rc))
            goto wrapup;
         /* the first parameter it finds is the right side index */
         mulktind[0] -= (order - 2);
         for(j=1; j< num_mul; j++)
            mulktind[j] += 1;
      }

      /* now add knots to cross section curves */   
      for(j=0; j< numcs; j++)
      {
         /* find space for output curves */
         if( i==0 )
         {
            sizecvsl = num_poles;
            BSstkalcvfl(rc, cvsl[j], num_poles, crational, newnumkts, 
                        NULL );
            if(BSERROR(*rc))
               goto wrapup;
         }
         else
         {
            if( num_poles > sizecvsl  )
            {
               /* this means that we allocated curves last time through
                  loop, but they're not big enough */
               BSstkfrcvfl(rc, cvsl[j] );
               if(BSERROR(*rc))
                  goto wrapup;
               BSstkalcvfl(rc, cvsl[j], num_poles, crational, newnumkts, 
                           NULL );
               if(BSERROR(*rc))
                  goto wrapup;
            }
         }
         BSadd_kts(cvptr[j], num_poles, newknots, cvsl[j], rc );
         if(BSERROR(*rc))
            goto wrapup;

      }
      /* allocate array of curves to send to fit routine */
      if( i > 0 )
      {
         if( cvsl[0]->num_poles > fcvs[0]->num_poles )
            alloc = TRUE;
      }
      if( i == 0 || alloc )
      {
         if( i> 0 && alloc)
         {
            /* free previous curves */
            for(j=0; j< num_nodes; j++)
            {  
               (void)BSfreecv(rc, fcvs[j] );
               if(BSERROR(*rc))
                  goto wrapup;
            }
         }
         for(j=0; j<num_nodes; j++)
         {
            trptr = cvsl[0];         
            BSalloccv(trptr->order, trptr->num_poles, trptr->rational,
                      0, &fcvs[j], rc);
            if(BSERROR(*rc))
               goto wrapup;
         }
      }
      sizecvsl = num_poles;
      if( i == 0 && tsf1)
         ptrtsf1 = tsf1;
      else
         ptrtsf1=NULL;
      if( i == tnumtrc -2 )
         ptrtsf2 = tsf2;
      csptr = cvsl;
      BSMEMCPY(sizeof(BSmat), (IGRchar *)smat[0], (IGRchar *)tsmat[0] );
      if( numtrc == 1 && !orient_abs)
      {
         if( num_nodes > MAXNUM )
         {
            numpts = (IGRint *)BSstackalloc((unsigned)( num_nodes * sizeof
                                     (IGRint)));
            if(! numpts )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            numptsalloc = TRUE;
            start = (IGRint *)BSstackalloc((unsigned)( num_nodes * sizeof
                                     (IGRint)));
            if(! start )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            startalloc = TRUE;
            linear = (IGRboolean *)BSstackalloc((unsigned)( num_nodes * 
                             sizeof(IGRboolean)));
            if(! linear )
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }
            linearalloc = TRUE;
         }
         else
         {
            numpts = anumpts;
            start = astart;
            linear = alinear;
         }
         /* find the number of segments */
         BSbrklincsp(tcvs[0], num_nodes, trnodes[0], &nump, numpts, start,
                     linear, rc);
         if(BSERROR(*rc))
            goto wrapup;
         if( nump == 1 && linear[0] )
         {
            BSMEMCPY(sizeof(BSmat), (IGRchar *)otmat[0], 
                     (IGRchar *)ttmat[0] );
            if( numcs == 2 )
            {
               BSMEMCPY(sizeof(BSmat), (IGRchar *)smat[1], 
                        (IGRchar *)tsmat[1] );
               BSMEMCPY(sizeof(BSmat), (IGRchar *)otmat[1], 
                        (IGRchar *)ttmat[1] );
            }
         }
         else
         {
            /* find all the tmats and smats at the beginning and end of
               each piece */
            if( nump+1 > SMAXNUM )
            {
               smat2 = (BSmat2 *)BSstackalloc((unsigned)( (nump+1) *
                                       sizeof(BSmat2)));
               if(!smat2 )
               {
                  *rc = BSNOSTKMEMORY;
                  goto wrapup;
               }
               smat2alloc = TRUE;
               tmat2 = (BSmat2 *)BSstackalloc((unsigned)( (nump+1) *
                                       sizeof(BSmat2)));
               if(!tmat2 )
               {
                  *rc = BSNOSTKMEMORY;
                 goto wrapup;
               }
               tmat2alloc = TRUE;
            }
            else
            {
               smat2 = asmat2;
               tmat2 = atmat2;
            }

            BSfndtsmats(tcvs[0], nump, numpts, linear, trnodes[0], numcs,
                        smat, nodcsps, ofvals, tmat2, smat2, rc);
            if(BSERROR(*rc))
               goto wrapup;
            BSMEMCPY(sizeof(BSmat), (IGRchar *)tmat2[0][0], 
                     (IGRchar *)ttmat[0] );
            BSMEMCPY(sizeof(BSmat), (IGRchar *)ttmat[0], 
                     (IGRchar *)otmat[0] );

            if( numcs == 2 )
            {
               BSMEMCPY(sizeof(BSmat), (IGRchar *)smat2[1][0], 
                        (IGRchar *)tsmat[1] );
               BSMEMCPY(sizeof(BSmat), (IGRchar *)tmat2[1][0], 
                        (IGRchar *)ttmat[1] );
               BSMEMCPY(sizeof(BSmat), (IGRchar *)tmat2[nump][0], 
                        (IGRchar *)otmat[1] );
            }
         }
        
         /* find the first segment of atmat's */
         if( linear[0] )
         {
            if( nump > 1 )
            {
               /* find the principal normal for the last point in 
                  segment and use lft_norm */
               (void)BSprncp_nor(rc, tcvs[0], &trnodes[0][numpts[0]-1],
                                 lnorm, rnorm, &pcode );
               if(BSERROR(*rc))
                  goto wrapup;
            }
            else
               for(k=0; k<3; k++)
                  lnorm[k] = otmat[0][1][k];
         }

         ind = 1;
         end = numcs == 2 ? numpts[0]-1 : numpts[0];
         for(l=1; l< end; l++)
         {
            midpar = (trnodes[0][l] + trnodes[0][l-1]) /2;
            BScveval( tcvs[0], midpar, num_derv1, 
                      (IGRpoint *)&midmat[1][0], rc );
            if (BSERROR(*rc))
               goto wrapup;
            (void)BSnorvec(rc, midmat[2] );
            if(BSERROR(*rc))
               goto wrapup;
            BScveval( tcvs[0], trnodes[0][l], num_derv1, eval, rc );
            if (BSERROR(*rc))
               goto wrapup;
            (void)BSnorvec(rc, eval[1] );
            if(BSERROR(*rc))
               goto wrapup;
            if( !linear[0] )
            {
               (void)BSprncp_nor(rc, tcvs[0], &trnodes[0][l],
                                 lnorm, rnorm, &pcode );
               if(BSERROR(*rc))
               {
                  if( rc[0] == BSNOSOLUTION)
                     /* let lnorm be whatever it was last time */
                  {
                     if( l==1 )
                        for(k=0; k<3; k++)
                           lnorm[k] = otmat[0][1][k];
                     else
                        for(k=0; k<3; k++)
                           lnorm[k] = atmat[l-2][1][k];
                     *rc = BSSUCC;
                  }
                  else
                     goto wrapup;
               }
               (void)BSprncp_nor(rc, tcvs[0], &midpar, midmat[1], rnorm, 
                                 &pcode );
               if( BSERROR(*rc))
               {

                  if( rc[0] == BSNOSOLUTION )
                  {
                     if( l==1 )
                        for(k=0; k<3; k++)
                        {
                           midmat[1][k] = otmat[0][1][k];
                           midmat[2][k] = otmat[0][2][k];
                        }
                     else
                     /* 01/09/98 - SGC
                        since -tan is stored in atmat[l-2][2], we
                        want to unnegate it, because midmat[2] is
                        suppose to be strictly the tangent */
                        for(k=0; k<3; k++)
                        {
                           midmat[1][k] = atmat[l-2][1][k];
                           midmat[2][k] = -atmat[l-2][2][k];
                        }
                     *rc = BSSUCC;
                  }
                  else
                     goto wrapup;
               }                  
               /* check to see if the principal normals are flipping */
               if( l > 1 )
               {
                  which = 1;
                  neg = -1.0;
                  dotBSmksfb2cs(midmat[1], midmat[2], atmat[l-2], &which,
                                neg, ind, rc);
                  if(BSERROR(*rc))
                     goto wrapup;
                  which = 1;
                  neg = 1.0;
                  dotBSmksfb2cs(lnorm, eval[1], midmat, &which, neg, 
                                ind, rc);
                  if(BSERROR(*rc))
                     goto wrapup;
               }
               else
               {
                  which = 1;
                  neg = -1.0;
                  dotBSmksfb2cs(midmat[1], midmat[2], ttmat[0], &which, 
                                neg, ind, rc);
                  if(BSERROR(*rc))
                     goto wrapup;
                  which = 1;
                  neg = 1.0;
                  dotBSmksfb2cs(lnorm, eval[1], midmat, &which, neg, 
                                ind, rc);
                  if(BSERROR(*rc))
                     goto wrapup;
               }
            }
            for(k=0; k<3; k++)
            {
               atmat[l-1][1][k] = lnorm[k];
               atmat[l-1][2][k] = eval[1][k];
            }
            (void)BScrossp(rc, atmat[l-1][2], atmat[l-1][1], 
                           atmat[l-1][0]);
            if(BSERROR(*rc))
               goto wrapup;
            for(k=0; k<3; k++)
               atmat[l-1][2][k] *= -1.0;
            (void)BSnorvec(rc, atmat[l-1][0] );
            if(BSERROR(*rc))
               goto wrapup;
            (void)BSnorvec(rc, atmat[l-1][1] );
            if(BSERROR(*rc))
               goto wrapup;
         }
         if( numcs == 2 )
         {
            which = 2;
            neg = -1.0;
            if( end == 1 )
            {
               /* need to set the "eval" */
               BScveval( tcvs[0], trnodes[0][end], num_derv1, eval, rc );
               if(BSERROR(*rc))
                  goto wrapup;
               (void)BSnorvec(rc, eval[1] );
               if(BSERROR(*rc))
                  goto wrapup;
            }
            dotBSmksfb2cs(lnorm, eval[1], ttmat[1], &which, neg, ind, rc);
            if(BSERROR(*rc))
               goto wrapup;
            if( which == -1 )
            {
               /* make sure because of cusp that principal normals 
                  aren't jumping */
               which = 2;
               neg = -1.0; 
               dotBSmksfb2cs(tsmat[0][1], eval[1], tsmat[1], &which, neg, 
                             ind, rc);
               if(BSERROR(*rc))
                  goto wrapup;
            }
         }
         if( nump > 1 )
         {
            which = 2;
            neg = -1.0;  
            dotBSmksfb2cs(lnorm, eval[1], tmat2[1][0], &which, neg, ind,
                           rc);
            if(BSERROR(*rc))
               goto wrapup;
         }

         if( numcs == 2 )
         {
            /* move the local cross sections on_site */
            BSalloccv(cvsl[0]->order, cvsl[0]->num_poles, 
                      cvsl[0]->rational, 0, &oncsl[0], rc);
            if(BSERROR(*rc))
               goto wrapup;
            BSalloccv(cvsl[0]->order, cvsl[0]->num_poles, 
                      cvsl[0]->rational, 0, &oncsl[1], rc);
            if(BSERROR(*rc))
               goto wrapup;

            BScveval(tcvs[0], trnodes[0][0], num_derv0, eval, rc);
            if(BSERROR(*rc))
               goto wrapup;
            (void)BScvntoo(rc, eval[0], smat[0], &scale, cvsl[0],
                              oncsl[0]);
            if(BSERROR(*rc))
               goto wrapup;
            BScveval(tcvs[0], trnodes[0][num_nodes-1], num_derv0,eval,rc);
            if(BSERROR(*rc))
               goto wrapup;
            (void)BScvntoo(rc, eval[0], smat[1], &scale, cvsl[1],
                              oncsl[1]);
            if(BSERROR(*rc))
               goto wrapup;
            csptr = acsptr;
            csptr[0] = cvsl[0];
            csptr[1] = cvsl[1];
            csptr[2] = oncsl[0];
            csptr[3] = oncsl[1];
         }                     
      }
      else
      {
         /* numtrc > 1 */
         nump = 1;
         BSMEMCPY(sizeof(BSmat), (IGRchar *)otmat[0], 
                  (IGRchar *)ttmat[0] );
         if( numcs == 2 )
         {
            BSMEMCPY(sizeof(BSmat), (IGRchar *)smat[1], 
                     (IGRchar *)tsmat[1] );
            if (tmat)
            {
              BSMEMCPY(sizeof(BSmat), (IGRchar *)tmat[1], 
                       (IGRchar *)ttmat[1] );
            }
         }
      }
      
      sum = 0;
      ptrtrn = &trnodes[i];
      svptr = trnodes[0];

  
      /*** loop over number of pieces ***/
      for(l=0; l< nump; l++)
      {
         if( numtrc == 1 && !orient_abs )
         {
            nd = numpts[l];
            sum = start[l];
         }
         else
         {
            nd = num_nodes;
         }
         if( numcs == 2 )
         {
            ptrofvals = &ofvals[sum];
            ptrsfvals = &sfvals[sum];
         }
         BSfndintcrs(numtrc, &tcvs[i], numcs, csptr, nd, ptrtrn,
                     smat, tsmat, ttmat, atmat, nvec, ptrofvals, 
                     ptrsfvals, scale_height, orient_abs, num_mul, 
                     mulktind, ptrtsf1, ptrtsf2, &fcvs[sum], rc);
         if(BSERROR(*rc))
            goto wrapup;
        
         if( numtrc == 1 && l != nump -1 && !orient_abs)
         {
            which = 2;
            neg = 1.0;  
            ind = 1;
            dotBSmksfb2cs(tmat2[l+1][0][1], tmat2[l+1][0][2],
                           tmat2[l+1][1], &which, neg, ind, rc);
            if(BSERROR(*rc))
                goto wrapup;
            /* flip is not used now, but may be a good idea later */
            flip = FALSE;
            /* find the atmat's for the next loop */
            if( linear[l+1] )
            {
               which2 = 2;
               neg = 1.0;  
               dotBSmksfb2cs(tmat2[l+1][1][1], tmat2[l+1][1][2],
                             tmat2[l+2][0], &which2, neg, ind, rc);
               if(BSERROR(*rc))
                  goto wrapup;
               for(k=0; k<3; k++)
                  lnorm[k] = tmat2[l+2][0][1][k];
               if( which != -1 && which2 == -1 )
                  flip = TRUE;
            }
            end = numcs == 2 ? numpts[l+1]-1 : numpts[l+1];
            for(m=1,n=numpts[l]; m< end; m++,n++)
            {
               (void)BScveval_b(rc, tcvs[0], &trnodes[0][n], &num_derv1, 
                                &eval_b, &bound, lderv, rderv );
               if (BSERROR(*rc))
                  goto wrapup;
               
               (void)BSnorvec(rc, lderv[1] );
               if(BSERROR(*rc))
                  goto wrapup;
               midpar = (trnodes[0][n] + trnodes[0][n-1]) /2;
               BScveval( tcvs[0], midpar, num_derv1, 
                         (IGRpoint *)&midmat[1][0], rc );
               if (BSERROR(*rc))
                  goto wrapup;
               (void)BSnorvec(rc, midmat[2] );
               if(BSERROR(*rc))
                  goto wrapup;

               if( !linear[l+1] )
               {
                  (void)BSprncp_nor(rc, tcvs[0], &trnodes[0][n],
                                    lnorm, rnorm, &pcode );
                  if(BSERROR(*rc))
                     goto wrapup;
                  (void)BSprncp_nor(rc, tcvs[0], &midpar,
                                    midmat[1], rnorm, &pcode );
                  if(BSERROR(*rc))
                     goto wrapup;
                  /* check to see if the normal is flipped from previous
                     normal */
                  if( m > 1 )
                  {
                     which = 1;
                     neg = -1.0;
                     dotBSmksfb2cs(midmat[1], midmat[2],atmat[m-2],&which,
                                   neg, ind, rc);
                     if(BSERROR(*rc))
                        goto wrapup;

                     neg = 1.0;
                     which = 1;
                     dotBSmksfb2cs(lnorm, lderv[1], midmat, &which,
                                   neg, ind, rc);
                     if(BSERROR(*rc))
                        goto wrapup;
                     /* flip is not used, but may be a good idea later */
                     if( (which == -1 && !flip) || 
                         ( which != -1 && flip ) )
                        flip = !flip;
                  }
                  else
                  {
                     which = 1;
                     neg = -1.0;
                     dotBSmksfb2cs(midmat[1], midmat[2], tmat2[l+1][1],
                                   &which, neg, ind, rc);
                     if(BSERROR(*rc))
                        goto wrapup;
                     which = 1;
                     neg = 1.0;
                     dotBSmksfb2cs(lnorm, lderv[1], midmat, &which,
                                   neg, ind, rc);
                     if(BSERROR(*rc))
                        goto wrapup;
                     if( (which == -1 && !flip) || 
                         ( which != -1 && flip ) )
                        flip = !flip;
                  }
               }
               for(k=0; k<3; k++)
               {
                  atmat[m-1][1][k] = lnorm[k];
                  atmat[m-1][2][k] = lderv[1][k];
               }
               (void)BScrossp(rc, atmat[m-1][2], atmat[m-1][1], 
                                 atmat[m-1][0]);
               if(BSERROR(*rc))
                  goto wrapup;
               for(k=0; k<3; k++)
                  atmat[m-1][2][k] *= -1.0;
               (void)BSnorvec(rc, atmat[m-1][0] );
               if(BSERROR(*rc))
                  goto wrapup;
               (void)BSnorvec(rc, atmat[m-1][1] );
               if(BSERROR(*rc))
                  goto wrapup;
            }
            ptrtrn[0] += (numpts[l]-1);
            /* if there is no cusp, then there is only one smat... there
               is always two tmats  */

            BSMEMCPY(sizeof(BSmat), (IGRchar *)tmat2[l+1][1], 
                     (IGRchar *)ttmat[0] );
            if( !linear[l+1] )
            {
               which2 = 2;
               neg = -1.0;
               dotBSmksfb2cs(lnorm, lderv[1], tmat2[l+2][0], &which2, neg,
                             ind, rc);
               if(BSERROR(*rc))
                  goto wrapup;
            }
            ind = 0;
            if( nodcsps[start[l+1]] )
            {
               /* tsmat[0] contains last smati inside BSfndintcrs */
               which = 2;
               neg = 1.0;
               dotBSmksfb2cs(tsmat[0][0], tsmat[0][2], smat2[l+1][1], 
                             &which, neg, ind, rc);
               if(BSERROR(*rc))
                  goto wrapup;

               BSMEMCPY(sizeof(BSmat), (IGRchar *)smat2[l+1][1], 
                        (IGRchar *)tsmat[0] );
            }
            else
            {
               /* tsmat[0] contains last smati inside BSfndintcrs */
               which = 2;
               neg = 1.0;
               dotBSmksfb2cs(tsmat[0][0], tsmat[0][2], smat2[l+1][0], 
                             &which, neg, ind, rc);
               if(BSERROR(*rc))
                  goto wrapup;

               BSMEMCPY(sizeof(BSmat), (IGRchar *)smat2[l+1][0], 
                        (IGRchar *)tsmat[0] );
            }
            if( numcs == 2 )
            {
               /* have to do this, because you can't check nodcsps
                  array when l == nump -2  */
               if( l == nump -2 )
                  k = 0;
               else
                  if( !nodcsps[start[l+2]])
                     k = 0;
                  else
                     k = 1;   
               BSMEMCPY(sizeof(BSmat), (IGRchar *)smat2[l+2][k], 
                        (IGRchar *)tsmat[1] );
               /* make sure because of cusp that principal normals 
                  aren't jumping */
               which = 2;
               neg = 1.0;
               dotBSmksfb2cs(tsmat[0][0], tsmat[0][2], tsmat[1], &which, 
                             neg, ind, rc);
               if(BSERROR(*rc))
                  goto wrapup;
/*
               if( flip )
               {
                  for(k=0; k<3; k++)
                  {
                     tsmat[1][0][k] *= -1;
                     tsmat[1][1][k] *= -1;
                  }
               }
*/
               BSMEMCPY(sizeof(BSmat), (IGRchar *)tmat2[l+2][0], 
                        (IGRchar *)ttmat[1] );
            }
         }
      }
      trnodes[0] = svptr;

#ifdef DEBUG
   for(k=0; k< num_nodes; k++)
      (void)BSprintbspc(outfile,&name, fcvs[k], option );
#endif
      /* this creates a surface through two cross sections and two
         traces */

      if( numtrc > 2 )
      {
         BSallocsf(tcvs[0]->order, fcvs[0]->order, num_nodes,
                   fcvs[0]->num_poles, rational, 0, &fsurf[i], rc);
         if(BSERROR(*rc))
           goto wrapup;
         
         if( i== 0 )
            BSsfthcvsbd(tn, &tcvs[i], nodeopt, &trnodes[i], num_nodes,
                        fcvs, csf1, NULL, fsurf[i], rc);
         else
         {
            if( i == numtrc-2 )
               BSsfthcvsbd(tn, &tcvs[i], nodeopt, &trnodes[i], num_nodes, 
                           fcvs, NULL, csf2, fsurf[i], rc);
            else
               BSsfthcvsbd(tn, &tcvs[i], nodeopt, &trnodes[i], num_nodes, 
                           fcvs, NULL, NULL, fsurf[i], rc);
         }
         if(BSERROR(*rc))
            goto wrapup;

      }
      else
      {
         if( numtrc == 1 && ncsp > 0 && !orient_abs )
         {
            /* check to see if there are any cusps along the trace,
               and if so we need to project the curves at that cusp
               onto the plane defined by the normal as the average
               tangent at that cusp */
            for(k=1; k< num_nodes-1; k++)
            {
               if( nodcsps[k] )
               {
                  /* this node is a cusp  */
                  /* average the left and right tangent at this cusp */
                  (void)BScveval_b(rc, tcvs[0], &trnodes[0][k], 
                                      &num_derv1, &eval_b, &bound, lderv,
                                      rderv);
                  if(BSERROR(*rc))
                     goto wrapup;
                  (void)BSnorvec(rc, lderv[1]);
                  if(BSERROR(*rc))
                     goto wrapup;
                  (void)BSnorvec(rc, rderv[1]);
                  if(BSERROR(*rc))
                     goto wrapup;
                  for(j=0; j<3 ; j++)
                     avgtan[j] = (lderv[1][j] + rderv[1][j]) / 2;
                  (void)BSnorvec(rc, avgtan);
                  if(BSERROR(*rc))
                     goto wrapup;
                  if( numcs == 2 )
                     (void)BSprj_cv_pl(rc, fcvs[k], lderv[0], avgtan, 
                                          lderv[1], fcvs[k] );
                  else
                     (void)BSprj_cv_pl(rc, fcvs[k], lderv[0], avgtan, 
                                          rderv[1], fcvs[k] );
                  if(BSERROR(*rc))
                     goto wrapup;
               }
            }
         }                         
         BSallocsf(tcvs[0]->order, fcvs[0]->order, num_nodes, 
                   fcvs[0]->num_poles, rational, 0, surf, rc);
         if(BSERROR(*rc))
           goto wrapup;

         BSsfthcvsbd(tn, tcvs, nodeopt, trnodes, num_nodes, fcvs, csf1, 
                     csf2, *surf, rc);
         if(BSERROR(*rc))
            goto wrapup;


         /* if cross sections are closed, then make sure the surface
            is also, by setting the poles exactly equal */
         closed = TRUE;
         for(j=0; j< numcs; j++)
         {      
            if( !csl[j]->phy_closed )
            {
               closed = FALSE;
               break;
            }
         }
         if( closed )
         {
            ptr = (*surf)->poles;
            ptr2 = &(*surf)->poles[( ((*surf)->v_num_poles-1) * 
                    (*surf)->u_num_poles) * 3];
            for(j=0; j< (*surf)->u_num_poles; j++)
            {
               for(k=0; k<3; k++)
               {
                  avg = (*ptr + *ptr2) / 2;
                  *ptr++ = avg;
                  *ptr2++ = avg;
               }
            }
            (*surf)->v_phy_closed = TRUE;
         }
      }
   }
   /* merge surface onto last surface */
   if( numtrc > 2 )
   {
      for(i=0; i< numtrc-2; i++)
      {
         n_int = fsurf[i]->v_num_poles + fsurf[i+1]->v_num_poles -1;
         BSallocsf(fsurf[i]->u_order, fsurf[i]->v_order, 
                  fsurf[i]->u_num_poles, n_int, rational, 0, surf, rc);
         if(BSERROR(*rc))
           goto wrapup;
         dir = 0;
         planar = TRUE;

         BScomb2sfs(dir, planar, fsurf[i], fsurf[i+1], *surf, rc);
         if(BSERROR(*rc))
            goto wrapup;

         (void)BSfreesf(rc, fsurf[i]);
         if(BSERROR(*rc))
            goto wrapup;
         fsurf[i] = NULL;

         (void)BSfreesf(rc, fsurf[i+1]);
         if(BSERROR(*rc))
            goto wrapup;
         fsurf[i+1] = NULL;
         if( numtrc > 3 && i != numtrc -3)
            fsurf[i+1] = *surf;
      }
   }

   wrapup:

   if( numtrc > 2 && fsurf)
   {
      for(i=numtrc-1; i>=0; i--)
      {
         if(fsurf[i] )
         {
            (void)BSfreesf(&rc1, fsurf[i] );
            if(BSERROR(rc1) && BSOKAY(*rc))
               *rc = rc1;
         }
      }
      if( allocfsurf)
         BSstackdealloc((char *)fsurf );
   }
   if( fcvs )
   {
      for(i=num_nodes-1; i>=0; i--)
      {
         if( fcvs[i] )
         {
            (void)BSfreecv(&rc1, fcvs[i] );
            if(BSOKAY(*rc) && BSERROR(rc1) )
               *rc = rc1;
         }
      }
      if( num_nodes > MAXNUM )
         BSstackdealloc((char *) fcvs );
   }

   if( cvsl && sizecvsl > 0)
   {
      for(j=numcs -1; j>=0; j--)
      {
         if( cvsl[j] )
         {
            BSstkfrcvfl(&rc1, cvsl[j] );
            if(BSERROR(rc1) && BSOKAY(*rc) )
               *rc = rc1;
         }
      }
   }
   if( oncsl[1] )
   {
      (void)BSfreecv(&rc1, oncsl[1]);
      if(BSERROR(rc1) && BSOKAY(*rc))
         rc1 = rc[0];
   }
   if( oncsl[0] )
   {
      (void)BSfreecv(&rc1, oncsl[0]);
      if(BSERROR(rc1) && BSOKAY(*rc))
         rc1 = rc[0];
   }

   if( tmat2alloc && tmat2 )
      BSstackdealloc((char *) tmat2 );
   if( smat2alloc && smat2 )
      BSstackdealloc((char *) smat2 );
   if( linear && linearalloc)
      BSstackdealloc((char *) linear );
   if( start && startalloc)
      BSstackdealloc((char *) start );
   if( numpts && numptsalloc)
      BSstackdealloc((char *) numpts );

   if( sizenewknots > MAXNUM && newknots)
      BSstackdealloc((char *) newknots);

   if( mulktind && mulktindalloc )
      BSstackdealloc((char *) mulktind );
   if( tmul && tmulalloc )
      BSstackdealloc((char *)tmul );
   for(i=numcs-1; i>=0; i--)
   {
      if( cvsl[i])
         BSstackdealloc((char *) cvsl[i] );
   }   

   if( num_nodes  > MAXNUM && atmat )
      BSstackdealloc((char *)atmat);


   if( numcs > 1 )
   {
      if( num_nodes  > MAXNUM )
      {
         if( sfvals )
            BSstackdealloc((char *)sfvals );
         if( ofvals )
            BSstackdealloc((char *) ofvals);
         if( sarcl )
            BSstackdealloc((char *) sarcl );
         if( arcl )
            BSstackdealloc((char *)arcl );
      }
   }

   if( numtrc > 2 )
   {
      if( numtrc > MAXNUM )
      {
         if( points )
            BSstackdealloc((char *) points );
      }
      if( num_nodes  > MAXNUM )
      {
         if( nvec)
            BSstackdealloc((char *) nvec );
      }
      if( sizep > MAXNUM )
      {
         if( int_pts)
            BSstackdealloc((char *) int_pts );
         if( b )
            BSstackdealloc((char *) b );
         if( a )
            BSstackdealloc((char *) a );
         if( u1 )
            BSstackdealloc((char *) u1 );
      }
   }
   if( tdegen && tdegenalloc )
      BSstackdealloc((char *) tdegen );
   if( nodcsps && nodcspsalloc )
      BSstackdealloc((char *) nodcsps);
   if( csps && cspsalloc )
      BSstackdealloc((char *) csps );

   if( trnodes && sizetrnodes < numtrc )
   {
      for(i=numtrc-1; i>=sizetrnodes; i--)
      {
         if( trnodes[i])
            BSstackdealloc((char *)trnodes[i] );
      }
   }
   if( numtrc > SMAXNUM  && trnodes)
      BSstackdealloc((char *)trnodes);
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSmksfb2cs");
   return;
   }
}


