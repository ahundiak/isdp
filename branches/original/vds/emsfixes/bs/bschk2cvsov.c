/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSchk2cvsov

Abstract
    This routine checks if 2 curves are overlapping/touching within a given
    tolerance.  

Synopsis
    void BSchk2cvsov( struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, IGRdouble search_tol, 
                      IGRint option, IGRint *OvLapCode, IGRint *numDistCvs1,
                      struct IGRbsp_curve ***DCvs1, IGRint *numDistCvs2, struct IGRbsp_curve ***DCvs2,
                      IGRint *numOvCvs, struct IGRbsp_curve ***OCvs, BSrc *rc )

Description
    Input
      cv1, cv2      Input curves
      search_tol    tolerance used to connect curves and also determine overlapping

      option       -1 - return only the OvLapCode
                    0 - return only the distinct parts of the curves
                    1 - return only the overlap portions of the curves
                    2 - return both distinct and overlap portions


    Output
      OvLapCode     described below in Notes
      numDistCvs1   number of distinct curves for cv1
      DCvs1         distinct curves from cv1
      numDistCvs2   number of distinct curves for cv2
      DCvs2         distinct curves from cv2
      numOvCvs      number of overlapping curves
      OCvs          overlapping portions of cv1 and cv2
  
                    
Return Values
    If memory cannot be allocated, rc returns BSNOMEMORY. If no errors occur,
rc returns BSSUCC.

Notes
    This routine allocates the output memory.   Use BSfreecv to free curves.

    ovLapCode - this describes which case we have
       -1:  cv1 is NOT within search_tol of cv2
        0:  curve endpoints are touching within search_tol and thus we can connect
        1:  cv2 endpoint is within search_tol to somewhere on cv1.  cv2 will be
            extended and cv1 possibly split.
        2:  cv1 endpoint is within search_tol to somewhere on cv2.  cv1 will be
            extended and cv2 possibly split.
        3:  cv1 is entirely overlapping with cv2.  No distinct curves will be returned
            for cv1, but cv2 will have some.
        4:  cv2 is entirely overlapping with cv1.  No distinct curves will be returned
            for cv2, but cv1 will have some.
        5:  portion of cv1 and cv2 are overlapping and a portion of each is distinct.
        6:  entire portion of cv1 and cv2 are overlapping each other.
        7:  similar to 6: where the endpoints are touching ,  but curves aren't overlapping
        8:  cv1 endpoints are touching, but curves aren't overlapping
		9:  cv2 endpoints are touching, but curves aren't overlapping
		
Index
    md

Keywords

History
    S.G. Catron    10/25/00  : Creation date.
    S.G. Catron    03/08/01  : TR 4406 - Typo in ovLapCode=4 section.
                               "tCv = lCv"
    S.G. Catron    08/22/2001: TR                                
*****/

#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsmalloc.h"
#include "bsmemory.h"
#include "bsparameters.h"
#endif
#define BSVOID

# define X    0 
# define Y    1 
# define Z    2

# define AVGPT( startPt1, startPt2, avg)     \
{                                                                       \
    avg[X] = (startPt1[X] + startPt2[X]) * 0.5;              \
    avg[Y] = (startPt1[Y] + startPt2[Y]) * 0.5;              \
    avg[Z] = (startPt1[Z] + startPt2[Z]) * 0.5;              \
}
# define EQUAL( Pt1, Pt2)     \
{                                                                       \
    Pt1[X] = (Pt2[X]) ;              \
    Pt1[Y] = (Pt2[Y]) ;              \
    Pt1[Z] = (Pt2[Z]) ;              \
}


/* find the minimum distance of the midpoint of cv1 to cv2 */
/* also if cv2 is closed, check if cv1 is crossing seam */
static void chkmidBSchk2cvsov(struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, IGRdouble mpar[4], IGRdouble *dist, IGRint *cross, BSrc *rc )
{
#ifndef DONOTSPROTO
#include "bscveval.h"
#include "bsmdstptcv.h"
#endif 
  IGRdouble midpar, par;
  IGRint nd0=0;
  IGRpoint midPt, base;

  *rc = BSSUCC;

  if( *cross == -1 )
    midpar = (*dist + mpar[1]) * 0.5;
  else
    midpar = (cv1->knots[cv1->num_poles] + cv1->knots[cv1->order-1] ) * 0.5;
  BScveval (cv1, midpar, nd0, &midPt, rc);
  if(BSERROR(*rc))
    goto wrapup;
  BSmdstptcv (cv2, midPt, &par, base, dist, rc);   
  if (BSERROR(*rc))
    goto wrapup;
  /* if *cross is TRUE and phy_closed, check if cv1 is overlaping cv2 across the seam */
  if( *cross==1 && cv2->phy_closed )
  {
    if( (par < mpar[0] && par > mpar[1]) ||
        (par > mpar[0] && par < mpar[1])  )
      *cross = 0;    
  }
  else
    *cross = 0;          

  wrapup:
return;
}

/* check the minimum distance of an endpoint of the other curve to "cv1" */
static void mdistBSchk2cvsov(struct IGRbsp_curve *cv1, IGRdouble search_tol, IGRpoint Ptcv2, IGRpoint startPt1, IGRpoint endPt1,
                             IGRboolean *m2B, IGRboolean *m2, IGRboolean *mSB1, IGRboolean *mEB1,
                             IGRpoint rS2, IGRpoint rS1, IGRpoint rE1, IGRint *mcountB,
			     IGRint *mcount, IGRdouble mpar[4], BSrc *rc )
{
#ifndef DONOTSPROTO
#include "bsmdstptcv.h"
#include "bsdistptpts.h"
#endif 

  IGRdouble dist, par, search_tolS;
  IGRpoint mPt;
  
  *rc = BSSUCC;
  search_tolS = search_tol * search_tol;
  
  BSmdstptcv (cv1, Ptcv2, &par, mPt, &dist, rc);   
  if (BSERROR(*rc))
    goto wrapup;
  if( dist < search_tol )
  {
    *m2 = TRUE;
    mpar[*mcount - *mcountB] = par;
    *mcount += 1;
    dist = BSdistptpts(rc, mPt, startPt1 );
    EQUAL(rS2,mPt);
    if( dist < search_tolS )
    {
      *mcountB += 1;
      if (*mSB1 )
      {
        /* if we already found mSB1, then we have 2 end points which meet minimum distance critera to
           each other....we should average take an average instead of just using minimum distance point */
        AVGPT(mPt, startPt1, rS2 );
        EQUAL(rS1,rS2);
      }
      else
      {
        EQUAL(rS1,mPt);
        EQUAL(rS2,mPt);	
      }
      *m2B = *mSB1 = TRUE;
    }
    else
    {
      dist = BSdistptpts(rc, mPt, endPt1 );        
      if( dist < search_tolS )
      {
        if (*mEB1 )
        {
          AVGPT(mPt, endPt1,rS2 );
          EQUAL(rS1,rS2);	
        }
        else
        {
          EQUAL(rE1,mPt);	
          EQUAL(rS2,mPt);		  
        }
        *m2B = *mEB1 = TRUE;
        *mcountB += 1;
      }
    }        
  }
wrapup:
return;
}


  
/* Set the endpoint  */
static void setendBSchk2cvsov( struct IGRbsp_curve *Cv, IGRint whichend, IGRpoint avgpt1 )
{
  IGRint ii;
  
  if( whichend )
  {
    ii = Cv->num_poles-1;
    if( Cv->rational )
    {
      Cv->poles[ii*3] = avgpt1[0] * Cv->weights[ii];
      Cv->poles[ii*3+1] = avgpt1[1] * Cv->weights[ii];
      Cv->poles[ii*3+2] = avgpt1[2] * Cv->weights[ii];            
    }
    else
    {
      Cv->poles[ii*3] = avgpt1[0];
      Cv->poles[ii*3+1] = avgpt1[1];
      Cv->poles[ii*3+2] = avgpt1[2];
    }
  }
  else
  {
    if( Cv->rational )
    {
      Cv->poles[0] = avgpt1[0] * Cv->weights[0];
      Cv->poles[1] = avgpt1[1] * Cv->weights[0];
      Cv->poles[2] = avgpt1[2] * Cv->weights[0];
    }
    else
    {
      Cv->poles[0] = avgpt1[0];
      Cv->poles[1] = avgpt1[1];
      Cv->poles[2] = avgpt1[2];
    }
  }
return;
}    
/* allocate and copy */
static void allcopyBSchk2cvsov( struct IGRbsp_curve ***Cvs, int numCvs, IGRint ind, IGRboolean copy,
                                struct IGRbsp_curve *ICv, BSrc *rc )
{
#ifndef DONOTSPROTO
#include "bsalloccv.h"
#include "bscv_copy.h"
#endif 
    
  *rc = BSSUCC;
  
  if( !*Cvs )
  {
    *Cvs = (struct IGRbsp_curve **)BSmalloc((unsigned)( numCvs * sizeof(struct IGRbsp_curve*)));
    if(!*Cvs )
    {
      *rc = BSNOMEMORY;
      goto wrapup;
    }
  }
  BSalloccv(ICv->order, ICv->num_poles, ICv->rational, ICv->num_boundaries, &(*Cvs)[ind], rc );
  if(BSERROR(*rc))
    goto wrapup;                    

  if( copy )
    (void) BScv_copy(rc, ICv, (*Cvs)[ind]);
  
wrapup:
return;
}
				

/**** Main ****/
void BSchk2cvsov( struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, IGRdouble search_tol, 
                  IGRint option, IGRint *ovLapCode, IGRint *numDistCvs1,
                  struct IGRbsp_curve ***DCvs1, IGRint *numDistCvs2, struct IGRbsp_curve ***DCvs2,
                  IGRint *numOvCvs, struct IGRbsp_curve ***OCvs, BSrc *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscveval.h"
#include "bscvsplit.h"
#include "bsactivsplt.h"
#include "bsalloccv.h"
#include "bsdistptpts.h"
#include "bststcvdegn.h"
#include "bsfreecv.h"

#endif 
  IGRpoint startPt1, endPt1, startPt2, endPt2, 
           rS1, rE1, rS2, rE2;
  IGRdouble search_tolS, dist, mPar[4];
  IGRboolean DistinctOut, OverOut, 
             S1B, S2B, E1B, E2B, planar=TRUE,
             mS1, mS2, mE1, mE2, degen,
             mS1B, mS2B, mE1B, mE2B;
  IGRint nd0=0, countB=0, mcountB=0, mcount=0, cross;
  struct IGRbsp_curve *lCv=NULL, *rCv=NULL, *tCv=NULL;
  BSrc rc1;
  
  *rc = BSSUCC;

  *numDistCvs1 = 0;
  *numDistCvs2 = 0;  
  *numOvCvs = 0;
  *ovLapCode = -1;

  BStstcvdegn(cv1,&degen,rc);
  if(BSERROR(*rc))
    goto wrapup;
  if( degen )
  {
    *rc = BSINARG;
    goto wrapup;
  }
  BStstcvdegn(cv2,&degen,rc);
  if(BSERROR(*rc))
    goto wrapup;
  if( degen )
  {
    *rc = BSINARG;
    goto wrapup;
  }
      
  search_tolS = search_tol * search_tol;
  if( option > 0 )
    OverOut = TRUE;
  else
    OverOut = FALSE;
  if( option == 0 || option == 2 )
    DistinctOut = TRUE;  
  else
    DistinctOut = FALSE;
  
  /* find the endpoints */
  BScveval (cv1, cv1->knots[cv1->order-1], nd0, &startPt1, rc);
  if(BSERROR(*rc))
    goto wrapup;
  BScveval (cv1, cv1->knots[cv1->num_poles], nd0, &endPt1, rc);
  if(BSERROR(*rc))
    goto wrapup;
  BScveval (cv2, cv2->knots[cv2->order-1], nd0, &startPt2, rc);
  if(BSERROR(*rc))
    goto wrapup;
  BScveval (cv2, cv2->knots[cv2->num_poles], nd0, &endPt2, rc);
  if(BSERROR(*rc))
    goto wrapup;

  /* first find the squared distances from each of the endpoints */
  S1B = S2B = E1B = E2B = FALSE;
  dist = BSdistptpts(rc, startPt1, startPt2 );
  if( dist <= search_tolS )
  {
    S1B = S2B = TRUE;
    AVGPT(startPt1, startPt2, rS1 );
    EQUAL(rS2,rS1);
    countB += 1;
  }
  dist = BSdistptpts(rc, startPt1, endPt2 );
  if( dist <= search_tolS )
  {
    S1B = E2B = TRUE;
    AVGPT(startPt1, endPt2, rS1 );
    EQUAL(rE2,rS1);
    countB += 1;
  }
  if( !S2B)
  {
    dist = BSdistptpts(rc, endPt1, startPt2 );
    if( dist <= search_tolS )
    {
      E1B = S2B = TRUE;
      AVGPT(endPt1, startPt2, rE1 );
      EQUAL(rS2,rE1);
      countB += 1;
    }
  }
  if( !E2B)
  {
    dist = BSdistptpts(rc, endPt1, endPt2 );
    if( dist <= search_tolS )
    {
      E1B = E2B = TRUE;
      AVGPT(endPt1, endPt2, rE1 );
      EQUAL(rE2,rE1);
      countB += 1;
    }
  }    
  if( countB > 2 )
  {
    *rc = BSINARG;
    goto wrapup;
  }
  mS1 = mS2 = mE1 = mE2 = mS1B = mE1B = mS2B = mE2B = FALSE;
  if( !S1B )
  {
    mdistBSchk2cvsov(cv2, search_tol, startPt1, startPt2, endPt2, &mS1B, &mS1, &mS2B,
                     &mE2B, rS1, rS2, rE2, &mcountB, &mcount, mPar, rc );
    if(BSERROR(*rc))
      goto wrapup;
  }
  if( !E1B && !cv1->phy_closed)
  {
    mdistBSchk2cvsov(cv2, search_tol, endPt1, startPt2, endPt2, &mE1B, &mE1, &mS2B,
                     &mE2B, rE1, rS2, rE2, &mcountB, &mcount, mPar, rc );
    if (BSERROR(*rc))
      goto wrapup;
  }
  if( !S2B )
  {
    mdistBSchk2cvsov(cv1, search_tol, startPt2, startPt1, endPt1, &mS2B, &mS2, &mS1B,
                     &mE1B, rS2, rS1, rE1, &mcountB, &mcount, mPar, rc );
    if (BSERROR(*rc))
      goto wrapup;
  }
  if( !E2B && !cv2->phy_closed)
  {
    mdistBSchk2cvsov(cv1, search_tol, endPt2, startPt1, endPt1, &mE2B, &mE2, &mS1B,
                     &mE1B, rE2, rS1, rE1, &mcountB, &mcount, mPar, rc );
    if (BSERROR(*rc))
      goto wrapup;
  }
  if( mcount == 3 )
  {
    if( cv1->phy_closed )
    {
      /* this means that cv2 is overlapping across cv1's seam */
      /* take away the minimum distance for cv1 */
      mcount = 2;
      mPar[0] = mPar[1];
      mPar[1] = mPar[2];
      mS1 = mE1 = FALSE;
    }
    if( cv2->phy_closed )
    {
      /* this means that cv2 is overlapping across cv1's seam */
      /* take away the minimum distance for cv1 */
      mcount = 2;
      mS2 = mE2 = FALSE;
    }
  }   
  /* if we have more than 2 end points equal or more than 2 minimum distances, then
      something is wrong */
  if( mcountB > 2 || countB > 2 || mcount > 2 )
  {
    *rc = BSINARG;
    goto wrapup;
  }    
  if( mcountB == 0 && countB == 0 && mcount == 0 )
    goto wrapup;

  /* we only have 1 case which we can determine with info thus far and that's case 6: */
  if( countB + mcountB == 2 )
  {
    /* we probably have case 6: curves are overlapping */
    /* to be sure check one of the mid points */
    cross = 0;
    chkmidBSchk2cvsov(cv1, cv2, mPar, &dist, &cross, rc );
    if(BSERROR(*rc))
      goto wrapup;    
    if( dist < search_tol )
    {
      *ovLapCode = 6;
      if( OverOut)
      {
        /* copy cv1 input overlap curve */
        *numOvCvs = 1;
        allcopyBSchk2cvsov( OCvs, *numOvCvs, 0, TRUE, cv1, rc );
      }
      goto wrapup;
    }

    if( mcountB == 2 && (mS1B + mE1B + mS2B + mE2B  == 2) )
    {
      /* we have the case that our endpoints just barely overlap and nothing else on the curve does */
      *ovLapCode = 5;
      if( DistinctOut )
      {
        *numDistCvs1 = 1;
        allcopyBSchk2cvsov( DCvs1, *numDistCvs1, 0, TRUE, cv1, rc );
        *numDistCvs2 = 1;
        allcopyBSchk2cvsov( DCvs2, *numDistCvs2,  0, TRUE, cv2, rc );
        if( mS1B )
          setendBSchk2cvsov((*DCvs1)[0], 0, rS1 );    
        else
          setendBSchk2cvsov((*DCvs1)[0], 1, rE1 );    
        if( mS2B )
          setendBSchk2cvsov((*DCvs2)[0], 0, rS2 );    
        else
          setendBSchk2cvsov((*DCvs2)[0], 1, rE2 );    
      }
      goto wrapup;
    }
      
    /* we have endpoints equal, but curves don't overlap */
    *ovLapCode = 7;
    if( DistinctOut )
    {
      *numDistCvs1 = 1;
      allcopyBSchk2cvsov( DCvs1, *numDistCvs1, 0, TRUE, cv1, rc );
      if(BSERROR(*rc))
        goto wrapup;                    
    
      setendBSchk2cvsov((*DCvs1)[0], 0, rS1 );    
      setendBSchk2cvsov((*DCvs1)[0], 1, rE1 );    
      *numDistCvs2 = 1;
      allcopyBSchk2cvsov( DCvs2, *numDistCvs2, 0, TRUE, cv2, rc );
      if(BSERROR(*rc))
        goto wrapup;                    

      setendBSchk2cvsov((*DCvs2)[0], 0, rS2);    
      setendBSchk2cvsov((*DCvs2)[0], 1, rE2);     	
    }
    goto wrapup;
  }

  /* now we have at MOST 1 set of endpoints < search_tol to each other */
  
  if( mcountB + countB == 1 )
  {
    /* if all minimum distances are > tol, then we have OvLapCode = 0, 1, or 2 */
    if(mcount == 0 || (mcountB && mcount == 1) )
    {
      if(DistinctOut)
      { 
        *numDistCvs1 = 1;
        allcopyBSchk2cvsov( DCvs1, *numDistCvs1, 0, TRUE, cv1, rc );
        if(BSERROR(*rc))
          goto wrapup;                    
        *numDistCvs2 = 1;
        allcopyBSchk2cvsov( DCvs2, *numDistCvs2, 0, TRUE, cv2, rc );
        if(BSERROR(*rc))
          goto wrapup;                    
        if( S1B || mS1B )
          setendBSchk2cvsov((*DCvs1)[0], 0, rS1);    
        else
          setendBSchk2cvsov((*DCvs1)[0], 1, rE1);    
        if( S2B || mS2B )
          setendBSchk2cvsov((*DCvs2)[0], 0, rS2);    
        else
          setendBSchk2cvsov((*DCvs2)[0], 1, rE2);    
      }
      if( countB )
        *ovLapCode = 0;
      else if(mS1 || mE1 )
        *ovLapCode = 2;
      else
        *ovLapCode = 1;
      goto wrapup;
    }

    /**** we now must have ovLapcode = 3 or 4 ****/
    if( mS1 || mE1 )
    {
      /* check the midpoint of cv1 to cv2, to see if < search_tol
         if > tol, then error */
      cross = 0;
      chkmidBSchk2cvsov(cv1, cv2, mPar, &dist, &cross, rc );
      if(BSERROR(*rc))
        goto wrapup;    

      if( dist > search_tol )
      {
        *rc = BSINARG;
        goto wrapup;
      }              
      *ovLapCode = 3;
    }
    else
    {
      /* check the midpoint of cv1 to cv2, to see if < search_tol
         if > tol, then error */
      cross = 0;
      chkmidBSchk2cvsov(cv2, cv1, mPar, &dist, &cross, rc );
      if(BSERROR(*rc))
        goto wrapup;    
      if( dist > search_tol )
      {
        *rc = BSINARG;
        goto wrapup;
      }              
      *ovLapCode = 4;
    }      

    if( DistinctOut )    
    {
      if( *ovLapCode == 3 )
      {
        allcopyBSchk2cvsov( DCvs2, 1, 0, FALSE, cv2, rc );
        if(BSERROR(*rc))
           goto wrapup;
        *numDistCvs2 = 1;
        if( S2B || mS2B )
        {
          BSalloccv(cv2->order,cv2->num_poles,cv2->rational,0,&lCv,rc);
          if(BSERROR(*rc))
            goto wrapup;
          (void)BScvsplit(rc, cv2, &mPar[0], lCv, (*DCvs2)[0], &planar);
        }
        else
        {
          BSalloccv(cv2->order,cv2->num_poles,cv2->rational,0,&rCv,rc);
          if(BSERROR(*rc))
            goto wrapup;
          (void)BScvsplit(rc, cv2, &mPar[0], (*DCvs2)[0], rCv, &planar);
        }
        if(BSERROR(*rc))
          goto wrapup;
      }      
      else
      {
        /* *ovLapCode = 4 */
        allcopyBSchk2cvsov( DCvs1, 1, 0, FALSE, cv1, rc );
        if(BSERROR(*rc))
           goto wrapup;
        *numDistCvs1 = 1;
        if( S1B || mS1B )
	{
          BSalloccv(cv1->order,cv1->num_poles,cv1->rational,0,&lCv,rc);
          if(BSERROR(*rc))
            goto wrapup;
          (void)BScvsplit(rc, cv1, &mPar[0], lCv, (*DCvs1)[0], &planar);
        }
        else
        {
          BSalloccv(cv1->order,cv1->num_poles,cv1->rational,0,&rCv,rc);
          if(BSERROR(*rc))
            goto wrapup;
          (void)BScvsplit(rc, cv1, &mPar[0], (*DCvs1)[0], rCv, &planar);
        }
        if(BSERROR(*rc))
          goto wrapup;
      }      
    }    
    if( OverOut )
    {
      *OCvs = (struct IGRbsp_curve **)BSmalloc((unsigned)( 1 * sizeof(struct IGRbsp_curve*)));
      if(!*OCvs )
      {
        *rc = BSNOMEMORY;
        goto wrapup;
      }
      *numOvCvs = 1;
      if( *ovLapCode == 3 )
      {
        allcopyBSchk2cvsov( OCvs, *numOvCvs, 0, TRUE, cv1, rc );
        if( mS1B || S1B)
          setendBSchk2cvsov((*OCvs)[0], 0, rS1);    	
        else
          setendBSchk2cvsov((*OCvs)[0], 1, rE1);    	
      }
      else
      {
        allcopyBSchk2cvsov( OCvs, *numOvCvs, 0, TRUE, cv2, rc );
        if( mS2B || S2B)
          setendBSchk2cvsov((*OCvs)[0], 0, rS2);    	
        else
          setendBSchk2cvsov((*OCvs)[0], 1, rE2);    	
      }
    }    
    goto wrapup;
  }

  /***** NO set of endpoints are < tol to each other *******/
  /* look at minimum distance points */
  /* if only 1, then we have case OvLapCode = 1 or 2 */

  if( mcount == 1 )
  {
    if( mS1 || mE1 )
      *ovLapCode = 2;
    else
      *ovLapCode = 1;   
    if( DistinctOut )
    {
      if( *ovLapCode == 1 )
      {
        *numDistCvs1 = 2;
        allcopyBSchk2cvsov( DCvs1, 2, 0, FALSE, cv1, rc );
        if(BSERROR(*rc))
           goto wrapup;
        allcopyBSchk2cvsov( DCvs1, 2, 1, FALSE, cv1, rc );
        if(BSERROR(*rc))
           goto wrapup;

        (void)BScvsplit(rc, cv1, &mPar[0], (*DCvs1)[0], (*DCvs1)[1], &planar);      
        if(BSERROR(*rc))
          goto wrapup;
        *numDistCvs2 = 1;
        allcopyBSchk2cvsov( DCvs2, *numDistCvs2, 0, TRUE, cv2, rc );
        if(BSERROR(*rc))
          goto wrapup;
        if( mS2 )
          setendBSchk2cvsov((*DCvs2)[0], 0, rS2);    	
        else
          setendBSchk2cvsov((*DCvs2)[0], 1, rE2);    	
      }
      else
      {
        /*** ovLapCode = 2 ****/
        *numDistCvs2 = 2;
        allcopyBSchk2cvsov( DCvs2, 2, 0, FALSE, cv2, rc );
        if(BSERROR(*rc))
           goto wrapup;
        allcopyBSchk2cvsov( DCvs2, 2, 1, FALSE, cv2, rc );
        if(BSERROR(*rc))
           goto wrapup;
        (void)BScvsplit(rc, cv2, &mPar[0], (*DCvs2)[0], (*DCvs2)[1], &planar);      
        if(BSERROR(*rc))
          goto wrapup;
        *numDistCvs1 = 1;
        allcopyBSchk2cvsov( DCvs1, *numDistCvs1, 0, TRUE, cv1, rc );
        if(BSERROR(*rc))
          goto wrapup;
        if( mS1 )
          setendBSchk2cvsov((*DCvs1)[0], 0, rS1);    	
        else
          setendBSchk2cvsov((*DCvs1)[0], 1, rE1);    	
      }
    }
    goto wrapup;
  }

  /* we should now have at MOST 2 mDist < search_tol */
  /**** OvLapCode = 3, 4 or 5 *****/
  if( mS1 && mE1 )
  {
    *ovLapCode = 3;
    /* make sure the midpt of cv1 is < search_tol to cv2 */
    cross = 1;
    chkmidBSchk2cvsov(cv1, cv2, mPar, &dist, &cross, rc );
    if(BSERROR(*rc))
      goto wrapup;    
    if( dist > search_tol )
    {
      *ovLapCode = 8;
      goto wrapup;
    }
    
    if( DistinctOut )
    {
      /* split cv2 at both mPar */

      *numDistCvs2 = cross==1 ? 1 : 2;
      allcopyBSchk2cvsov( DCvs2, 2, 0, FALSE, cv2, rc );
      if(BSERROR(*rc))
         goto wrapup;
      if( cross==1 )
      {
        BSactivsplt(rc, cv2, &mPar[0], &mPar[1], (*DCvs2)[0], &planar );
        if(BSERROR(*rc))
           goto wrapup;
      }
      else
      {    
        allcopyBSchk2cvsov( DCvs2, 2, 1, FALSE, cv2, rc );
        if(BSERROR(*rc))
           goto wrapup;

        if( mPar[0] < mPar[1] )
        {
          BSalloccv(cv2->order,cv2->num_poles,cv2->rational,0,&rCv,rc);
          if(BSERROR(*rc))
             goto wrapup;
          (void)BScvsplit(rc, cv2, &mPar[0], (*DCvs2)[0], rCv, &planar);
          if(BSERROR(*rc))
            goto wrapup;
          tCv = rCv;
          (void)BScvsplit(rc, cv2, &mPar[1], tCv, (*DCvs2)[1], &planar);
          if(BSERROR(*rc))
            goto wrapup;
        }
        else
        {
          BSalloccv(cv2->order,cv2->num_poles,cv2->rational,0,&lCv,rc);
          if(BSERROR(*rc))
            goto wrapup;
          (void)BScvsplit(rc, cv2, &mPar[0], lCv, (*DCvs2)[0], &planar);
          if(BSERROR(*rc))
            goto wrapup;
          tCv = lCv;
          (void)BScvsplit(rc, cv2, &mPar[1], (*DCvs2)[1], tCv, &planar);
          if(BSERROR(*rc))
            goto wrapup;

        }
        lCv = tCv;
        rCv = NULL;    
      }
    }
    if( OverOut )
    {
      *numOvCvs = 1;
      allcopyBSchk2cvsov( OCvs, *numOvCvs, 0, TRUE, cv1, rc );
    }
    goto wrapup;      
  }

  /**** OvLapCode = 4 or 5 *****/
  if( mS2 && mE2 )
  {
    *ovLapCode = 4;
    /* make sure the midpt of cv1 is < search_tol to cv2 */
    cross = 1;
    chkmidBSchk2cvsov(cv2, cv1, mPar, &dist, &cross, rc );
    if(BSERROR(*rc))
      goto wrapup;    
    if( dist > search_tol )
    {
      *ovLapCode = 9;
      goto wrapup;
    }
    
    if( DistinctOut )
    {
      /* split cv1 at both mPar */
      *numDistCvs1 = cross == 1 ? 1 : 2;
      allcopyBSchk2cvsov( DCvs1, 2, 0, FALSE, cv1, rc );
      if(BSERROR(*rc))
         goto wrapup;
      if( cross==1 )
      {
        BSactivsplt(rc, cv1, &mPar[0], &mPar[1], (*DCvs1)[0], &planar );
        if(BSERROR(*rc))
           goto wrapup;
      }
      else
      {
        allcopyBSchk2cvsov( DCvs1, 2, 1, FALSE, cv1, rc );
        if(BSERROR(*rc))
           goto wrapup;

        if( mPar[0] < mPar[1] )
        {
          BSalloccv(cv1->order,cv1->num_poles,cv1->rational,0,&rCv,rc);
          if(BSERROR(*rc))
            goto wrapup;
          (void)BScvsplit(rc, cv1, &mPar[0], (*DCvs1)[0], rCv, &planar);
          if(BSERROR(*rc))
            goto wrapup;
          tCv = rCv;
          (void)BScvsplit(rc, cv1, &mPar[1], tCv, (*DCvs1)[1], &planar);
          if(BSERROR(*rc))
            goto wrapup;
        }
        else
        {
          BSalloccv(cv1->order,cv1->num_poles,cv1->rational,0,&lCv,rc);
          if(BSERROR(*rc))
            goto wrapup;
          (void)BScvsplit(rc, cv1, &mPar[0], lCv, (*DCvs1)[0], &planar);
          if(BSERROR(*rc))
            goto wrapup;
          tCv = lCv;
          (void)BScvsplit(rc, cv1, &mPar[1], (*DCvs1)[1], tCv, &planar);
          if(BSERROR(*rc))
            goto wrapup;
        }
        lCv = tCv;
        rCv = NULL;
      }
    }
    if( OverOut )
    {
      *numOvCvs = 1;
      allcopyBSchk2cvsov( OCvs, *numOvCvs, 0, TRUE, cv2, rc );
    }
    goto wrapup;      
  }

  /**** we must have OvLapCode = 5 *****/
  *ovLapCode = 5;
  /* make sure midpoint of (supposeably) overlapping part is on */
  cross = -1;
  if( mS1 )
    dist = cv1->knots[cv1->order-1];
  else
    dist = cv1->knots[cv1->num_poles];    
  chkmidBSchk2cvsov(cv1, cv2, mPar, &dist, &cross, rc );
  if(BSERROR(*rc))
    goto wrapup;    
  if( dist > search_tol )
  {
    *rc = BSINARG;
    goto wrapup;
  }
  
  if( OverOut )
  {
    *numOvCvs = 1;
    *OCvs = (struct IGRbsp_curve **)BSmalloc((unsigned)( 1 * sizeof(struct IGRbsp_curve*)));
    if(!*OCvs )
    {
      *rc = BSNOMEMORY;
      goto wrapup;
    }
  }
  if( DistinctOut )
  {
    *numDistCvs1 = 1;
    *DCvs1 = (struct IGRbsp_curve **)BSmalloc((unsigned)( 1 * sizeof(struct IGRbsp_curve*)));
    if(!*DCvs1 )
    {
      *rc = BSNOMEMORY;
      goto wrapup;
    }
    *numDistCvs2 = 1;
    *DCvs2 = (struct IGRbsp_curve **)BSmalloc((unsigned)( 1 * sizeof(struct IGRbsp_curve*)));
    if(!*DCvs2 )
    {
      *rc = BSNOMEMORY;
      goto wrapup;
    }
  }   
  if( DistinctOut || OverOut)
  {
    BSalloccv(cv1->order,cv1->num_poles,cv1->rational,0,&lCv,rc);
    if(BSERROR(*rc))
      goto wrapup;
    BSalloccv(cv1->order,cv1->num_poles,cv1->rational,0,&rCv,rc);
    if(BSERROR(*rc))
      goto wrapup;
    (void)BScvsplit(rc, cv1, &mPar[1], lCv, rCv, &planar);
    if( mS1 )
    {
      if( DistinctOut )
      {
        (*DCvs1)[0] = rCv;
        rCv = NULL;
      }
      if( OverOut )
      {
        (*OCvs)[0] = lCv;
        lCv = NULL;
      }
    }
    else
    {
      if( DistinctOut )
      {
        (*DCvs1)[0] = lCv;
        lCv = NULL;
      }
      if( OverOut )
      {
        (*OCvs)[0] = rCv;
        rCv = NULL;
      }
    }      
    if( DistinctOut )
    {
      BSalloccv(cv2->order,cv2->num_poles,cv2->rational,0,&(*DCvs2)[0],rc);
      if(BSERROR(*rc))
        goto wrapup;
      BSalloccv(cv2->order,cv2->num_poles,cv2->rational,0,&tCv,rc);
      if(BSERROR(*rc))
        goto wrapup;

      if( mS2 )
        (void)BScvsplit(rc, cv2, &mPar[0], tCv, (*DCvs2)[0], &planar);
      else
        (void)BScvsplit(rc, cv2, &mPar[0], (*DCvs2)[0], tCv, &planar);
      lCv = tCv;   
    }      
  }

wrapup:
if( lCv )
{
  (void)BSfreecv(&rc1, lCv );
  if( BSERROR(rc1) && BSOKAY(*rc))
    *rc = rc1;

}
if( rCv )
{
  (void)BSfreecv(&rc1, rCv );
  if( BSERROR(rc1) && BSOKAY(*rc))
    *rc = rc1;
}
  
if(BSERROR(*rc))
    BSdbgrc(*rc,"BSchk2cvsov");
return;
}
