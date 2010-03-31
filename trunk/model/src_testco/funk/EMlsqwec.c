/***************************************************************************



    TWlsqwec


Abstract
    Solve a least squares problem with equality constraints

Synopsis
    void TWlsqwec ( nvar, nequ, ncon, nrhs, matc, rhsc, mata, rhsa, sol, rc)

    IGRint        nvar;
    IGRint        nequ;
    IGRint        ncon;
    IGRint        nrhs;
    IGRdouble     matc[];
    IGRdouble     rhsc[];
    IGRdouble     mata[];
    IGRdouble     rhsa[];
    IGRdouble     sol [];
    BSrc          *rc;

Description
    This routine solves a linear least-squares problem consisting of equations
    which are to be approximated and equality constraints to be fulfilled.
    The approximation equations are stored in matrix 'mata' with the right hand
    sides 'rhsa', the constraint equations are stored in matrix 'matc' with 
    right hand sides 'rhsc'. Each equation is one row in the matrix.  
    Note that several right hand sides can be given to solve for several 
    dimensions at once. Each right hand side is to be stored row-wise in rhsc
    and rhsa. The solution will also be stored row-wise times nrhs.
 

    In mathematical terms this can be described by:

    NOTATION

    A m x n matrix A is a matrix with a(i,j), i=1,...,m, j=1,...n,
    with m rows and n columns. Note that in C the matrix is stored
    row-wise, that is j runs first.
    
    PROBLEM LSE (Least squares with Equality Constraints)

       Given the (nequ) x (nvar) matrix A ('mata')
             the (ncon) x (nvar) matrix C ('matc')
             the (nrhs) x (nequ) vector a ('rhsa')
             the (nrhs) x (ncon) vector c ('rhsc').

       Find  the (nrhs) x (nvar)  vector x ('sol') that satisfies

                      C x =  c
 
       and minimizes

                   || A x  = a ||.
 

    EXISTENCE OF SOLUTION

    It can be shown that if 'nvar' > 'ncon' and C has rank = 'ncon'
    a solution exists.    
                                                               ( C )
    The solution is unique if and only if the augmented matrix ( A )
    has rank 'nvar'. 
    In the case of non-uniqueness there is a possibility to compute a
    solution of minimal length which is not implemented here. Uniqueness of
    the solution is always assumed.

    METHOD

    The method to solve this uses the concept of the null space described 
    in "Solving Least Squares Problems" by C.L.Lawson and R.J.Hanson,
    Prentice Hall, 1974, "Chapter 20 - Linear least squares with linear
    equality constraints using a basis of the null space".
 
    Input:
       nvar       number of variables
       nequ       number of equations
       ncon       number of constraints
       nrhs       number of right hand sides
       matc       matrix of constraint equations 
                                        must be dimensioned to [ncon][nvar]
       rhsc       matrix of right hand sides for constraints 
                                        must be dimensioned to [nrhs][ncon]
       mata       matrix of approximation equations 
                                        must be dimensioned to [nequ][nvar]
       rhsa       matrix of right hand sides for approximations
                                        must be dimensioned to [nrhs][nequ]
    
    Output:
       sol        matrix of solutions
                                        must be dimensioned to [nrhs][nvar]
       *rc;       BSSUCC       if successful
                  BSINARG      if invalid argument 
                               1. ncon + nequ < nvar 
                               2. ncon        > nvar.
                  BSIDGENRAT   if matrix 'matc' is numerically rank deficient
                  BSIDGENRAT   if matrix of reduced (unconstrained) problem
                               is rank-deficient

Return Values
    none

Notes 
    The calling routine must set up the correct dimensions for the matrices
    fill in the equations and the right hand sides. 
    The calling routine must ensure that the constraint equations are not
    contradictory or linear dependent (that is: rank (matc) = ncon), and
    that the approximation equations are such that mata has full rank
    (that is: rank (mata) = nvar-ncon). See existence and uniqueness of
    solution.

Index
    md

Keywords
    Aprroximation_with_equality_constraints
   
History
    Thomas H. Weissbarth.     12/17/93: Creation date. Rewritten from
                                        Fortran Version by G. Bollmann
*****************************************************************************
*/

/*   General header files and defines  */
  
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include "bs.h"
#include "bsparameters.h"


#define thw_abs(a)    ((a)< 0 ?(-a):(a)) 
#define max(a, b) ((a)>(b)?(a):(b))
#define min(a, b) ((a)>(b)?(b):(a))

#define ZERO  0.0

#define LOWER  1
#define UPPER  2           

/****************************************************************************
*
*     Static function definition:
*
*        sglehousehtrTWlsqwec     -  set up and/or apply a single householder
*                                    transformation Q = I + (1/b)*(u*u')  
*                                    where  I  = identity matrix
*                                           u  = (column) vector
*                                           u' = u transform
*                                           b  = -(|| u ||**2)/2
*                                    
*****************************************************************************
*/
 
static void sglehousehtrTWlsqwec   (sel, lpivot,  l1, m, u, iue, up, c, 
                                    ice,    icv, ncv)


/*****  Input/Output  *****/

IGRint              sel;           /* sel  = 1: select algorithm H1        */
                                   /*           set up transformation which*/
                                   /*           zeros elements l1 thru m of*/
                                   /*           array u, apply to matrix c */
                                   /*           according to ncv           */
                                   /*      = 2: select algorithm H2        */
                                   /*           apply transformation to u  */
                                   /*           and c                      */
IGRint              lpivot;        /* pivot element with                   */
                                   /*          1 <= lpivot < l1 <= m       */
                                   /* elements 1 <= lpivot remain unchanged*/
                                   /* element  lpivot changes              */
                                   /* elements lpivot+1 < l1-1 unchanged   */
                                   /* elements l1 <= m are to be zeroed    */
IGRint              l1;            /* in the implementation l1>m permitted */
IGRint              m;             /* this will result in Q == I           */
IGRdouble           u[];           /* array u contains m elements with     */
                                   /* storage increment iue between element*/
                                   /* on entry with mode=1, u contains the */
                                   /* pivot vector                         */
IGRint              iue;           /* storage increment for u of consecuti-*/
                                   /* ve elements                          */
IGRdouble           up[];          /* for mode=2, up will contain the      */
                                   /* result produced by previous call with*/
                                   /* mode=1                               */
IGRdouble           c[];           /* array c is regarded as a matrix      */ 
                                   /* containing ncv > 0 m-vectors         */
                                   /* with storage increment ice between   */
                                   /* elements of one vector and storage   */
                                   /* increment of icv between vectors     */
                                   /* on output c contains the set of ncv  */
                                   /* vectors resulting from multiplying   */
                                   /* the given vectors by Q               */
IGRint              ice,icv,ncv;

/*****  Notes  *****/
/* 
   The implementation follows the program in the book by Lawson/Hanson,
   describing the H12 algorithm (pages 271 ff) and implementation (page 308).
   The choice of parameter names and the description follows the implemen-
   tation of the Householder transformation H12 algorithm described on page
   271 ff.                                                                 
*/
{
   IGRint    j,i,i2,i3,i4,incr,k,k1;
   IGRdouble cl,clinv,sm,sm1,b;

/***************************************************************************
 *    Start of executable code
*/

   if (lpivot <= 0   ) goto wrapup;
   if (lpivot >= l1  ) goto wrapup;
   if (l1     >  m   ) goto wrapup;

   k       = iue*(lpivot-1);
   cl      = thw_abs(u[k]);

   if ((sel == 2) && (cl <= ZERO))  goto wrapup;

/*
 *  On first entry construct transformation
*/
   if (sel == 1)
     {
/*
 *       Construct transformation
*/
      for (j=l1,k1=(l1-1)*iue; j<=m; j++,k1+=iue)          
         cl      = max(thw_abs(u[k1]), cl);

      if (cl    <= ZERO) goto wrapup;        /* pivot is zero */
 
      clinv      = 1.0/cl;
      sm         = u[k]*clinv;
      sm         = sm*sm;

      for (j=l1,k1=(l1-1)*iue; j<=m; j++,k1+=iue)
         {
          sm1    = u[k1]*clinv;
          sm    += sm1*sm1;            
         }
      
      cl         = cl*sqrt(sm);
      if (u[k]   > ZERO) 
        cl       =-cl;
      up[0]      = u[k]-cl;
      u[k]       = cl;
     }

/*
 *  Return if nothing is to be transformed
*/   
   if (ncv <= 0)  goto wrapup;  

/*
 *  On subsequent entries 
*/

/*
 *       Apply transformation
*/
   b            = up[0]*u[k];
   if (b       >= ZERO)   goto wrapup;
   b            = 1.0/b;
   i2           = -icv+ice*(lpivot-1);
   incr         = ice*(l1-lpivot);

   for (j=1; j<=ncv; j++)
      {
       i2      += icv;
       i3       = i2+incr;
       i4       = i3;  
       sm       = c[i2]*up[0];
       
       for (i=l1,k1=(l1-1)*iue; i<=m; i++,k1+=iue)
          {
           sm   += c[i3]*u[k1];
           i3   += ice;
          }

       if (sm  == ZERO) continue;

       sm      *= b;
       c[i2]   += sm*up[0];
       
       for (i=l1,k1=(l1-1)*iue; i<=m; i++,k1+=iue)
          {
           c[i4] += sm*u[k1];
           i4    += ice;
          }
      }         
 
/****************************************************************************
 *   wrap up
*/
wrapup:
   return;
}

/****************************************************************************
*
*     Static function definition:
*
*        solvtriangsysTWlsqwec    -  solve a triangular system of 
*                                    linear equations
*
*****************************************************************************
*/

static void solvtriangsysTWlsqwec ( nrows, ncols, mat, vec, type)

/******  INPUT  *****/
IGRint                nrows;       /* number of rows of matrix             */
IGRint                ncols;       /* number of columns of matrix          */
IGRdouble             mat[];       /* matrix                               */
IGRdouble             vec[];       /* ncols-vector (right hand side)       */
IGRshort              type;        /* type of matrix                       */
                                   /*   type = 1 lower triangular matrix   */
                                   /*          2 upper triangular matrix   */

/*****   OUTPUT  *****/
/*                    vec[];          solution                             */

/******  NOTE   *****/
/*
    It is assumed that always nrows <= ncols, so that in case of 

    a lower triangular matrix we have

                            ncols       
                    ( x * * ... * * * * )
                    ( x x * ... * * * * )
                           .......         nrows
                    ( x x ... x * * * * )
                    ( x x ... x x * * * )

    and in case of an upper triangular matrix we have
        
                            ncols
                    ( * ... * x ... x x )
                    ( * ... * * x ... x )
                           .......         nrows
                    ( * * ... * * * x x )
                    ( * * ... * * * * x )
   
   where x is substantial and * is irrelevant.
*/ 

{
   IGRint     i,i1,i2,j,j1;

/***************************************************************************
 *    Start of executable code
*/
  
   if (type == LOWER)
     {
      vec[0] /= mat[0];
      if (nrows>1)
        { 
/*     
 *    Forward elimination for lower triangular matrix
*/
         for (i=2; i<=nrows; i++)
            {
             i1=i-1;
             i2=i1*ncols;
             for (j=0; j<i1; j++) 
                vec[i1] -= mat[i2+j]*vec[j];
             vec[i1] /= mat[i2+i1];
            };
        }
     }

   if (type == UPPER)
     {
      vec[nrows-1] /= mat[nrows*ncols-1];
      if (nrows>1)
/*
 *    Backward elimination for upper triangular matrix
*/
        {
         for (i=2; i<=nrows; i++)
            {
             i1=nrows-i;
             i2=i1*ncols+(ncols-nrows);
             for (j=1; j<i; j++)
                {
                 j1=nrows-j;      
                 vec[i1] -= mat[i2+j1]*vec[j1];
                }
             vec[i1] /= mat[i2+i1];
            };
        }
     }
     
/*****************************************************************************
 *    wrap up
*/

   return;
}

/*******************  End of static function definitions  *******************/


/****************************************************************************
 *
 *                         TWlsqwec  Routine
 *
 ****************************************************************************/
                
void TWlsqwec ( nvar, nequ, ncon, nrhs, matc, rhsc, mata, rhsa, sol, rc)

IGRint        nvar;
IGRint        nequ;
IGRint        ncon;
IGRint        nrhs;
IGRdouble     matc[];
IGRdouble     rhsc[];
IGRdouble     mata[];
IGRdouble     rhsa[];
IGRdouble     sol [];
BSrc          *rc;

/*
 *   The references in the implementation are to the algorithm outlined in
 *   the book, chapter 20, algorithm LSE (20.24)
*/

{
   IGRint    mode,incrcol,incrrow;
   IGRint    i,i1,j,j1,k,k1;
   IGRdouble macheps,eps;
   IGRdouble eimin,eimax;


/***************************************************************************
 *
 *              Start of executable code
 *
 ***************************************************************************/
 
/*
 *  Check input
*/
 
    *rc = BSINARG;

    if ((nequ+ncon) < nvar)   goto wrapup;
    if (ncon        > nvar)   goto wrapup;
    *rc = BSSUCC;
 
/*
 *  Determine machine epsilon
*/
    macheps = 1.0e-5;
    do 
      {macheps  = 0.5*macheps;
       eps      = macheps + 1.0;
      }  while (eps > 1.0);
    eps     = 1.0e3 * macheps;

/*
 *  Increments for rows and columns in matrices
 *  !!!  These values are dependent on the language C   !!!
*/
    incrcol = 1;             /* increment per column is one since storage is*/
                             /* row-wise                                    */ 
    incrrow = nvar;          /* increment per row is nvar                   */

/*****************************************************************************
 *
 *  If constraints present: 
*/
    if (ncon > 0)
/*
 *  STEP 1:
 *  Triangulize the constraint matrix MATC using a Householder transformation
 *  [step 1 of algorithm (20.24)]
*/
      {
       mode=1;
       for (j=1,k=0,k1=incrrow; j<=ncon; j++,k+=incrrow,k1+=incrrow)
           sglehousehtrTWlsqwec(mode    , j      , j+1      , nvar     , 
                                &matc[k], incrcol, &sol[j-1], &matc[k1],
                                incrcol , incrrow, ncon-j   );          

/*  Check if the system is singular  */

       eimin= thw_abs(matc[0]);
       eimax= eimin;
       for (j=1,k=0; j<=ncon; j++,k+=incrrow+incrcol)
          {
           eimin = min(thw_abs(matc[k]),eimin);
           eimax = max(thw_abs(matc[k]),eimax);
          }

       if  (eimax <= ZERO)
          {
           *rc   = BSIDGENRAT;
           goto wrapup;
          }
       if  ((eimin/eimax) < eps)
          {
           *rc   = BSIDGENRAT;
           goto wrapup;
          }
/*
 *  STEP 2:
 *  Solve for the constraints 
 *  [Step 3 and 4 of algorithm (20.24)]
*/
       for (i=1,k=0; i<=nrhs; i++,k+=ncon)
          solvtriangsysTWlsqwec (ncon, nvar, &matc[0], &rhsc[k],LOWER);       


       if (ncon == nvar)
/*
 *  Special case: constraints only, apply transformation to solution of
 *  constraint solution to obtain solution of original problem
*/
         {
          mode  = 2;
          for (i=1; i<=ncon;i++)
             {
              j   = ncon-i;
              k   = j*incrrow;
              j++;
              sglehousehtrTWlsqwec(mode    , j      , j+1      , nvar     , 
                                   &matc[k], incrcol, &sol[j-1], &rhsc[0],
                                   incrcol , ncon   , nrhs     );          
             }
          for (i=1,k=0; i<=nrhs; i++,k+=ncon)
             for (j=0;j<ncon;j++)
                sol[k+j] = rhsc[k+j];
          goto wrapup;
         }
       else
         {
/*
 *  STEP 3:
 *  Apply the transformation to the matrix of equations MATA 
 *  [Step 2 of algorithm (20.24)]
*/

          mode=2;
          for (j=1,k=0; j<=ncon; j++,k+=incrrow)
              sglehousehtrTWlsqwec(mode    , j      , j+1      , nvar     , 
                                   &matc[k], incrcol, &sol[j-1], &mata[0] ,
                                   incrcol , incrrow, nequ     );          

/*
 *  STEP 4: 
 *  Construct the reduced (unconstrained) least squares problem  - [(20.21)] 
 *  [Step 5 of algorithm (20.40)]
*/
          for (i=1,i1=0,k1=0; i<=nrhs; i++,i1+=nequ,k1+=ncon)
             for (j=1,j1=0; j<=nequ;j++,j1+=incrrow)
                for (k=0; k<ncon; k++)
                   rhsa[i1+j-1] -= mata[j1+k]*rhsc[k1+k];
         }
      }   

/*
 *  STEP 5:
 *  Solve the unconstrained problem  - Step 6 [(20.22)]
 *  [Step 6 of algorithm (20.40)]
*/
      
/*   First triangulize the matrix mata using householder transformation
 *   starting from column ncon+1
*/

    mode=1;
    for (j=1,k=ncon,k1=ncon; j<=nvar-ncon; j++,k+=incrcol,k1+=1)
        sglehousehtrTWlsqwec(mode    , j      , j+1        , nequ            , 
                             &mata[k], incrrow, &sol[k1]   , &mata[k+incrcol],
                             incrrow , incrcol, nvar-ncon-j);

/*
 *  STEP 6:
 *  Apply the transformation to the right hand side 
 *  [Step 7 of algorithm (20.40)]
*/
    mode=2;
    for (j=1,k=ncon,k1=ncon; j<=nvar-ncon; j++,k+=incrcol,k1+=1)
        sglehousehtrTWlsqwec(mode    , j      , j+1       , nequ    , 
                             &mata[k], incrrow, &sol[k1]  , &rhsa[0],
                             incrcol , nequ   , nrhs      );

/*  Check if the system is singular  */

    eimin= thw_abs(mata[ncon]);
    eimax= eimin;
    for (j=1,k=ncon; j<=nvar-ncon; j++,k+=incrrow+incrcol)
       {
        eimin = min(thw_abs(mata[k]), eimin);
        eimax = max(thw_abs(mata[k]), eimax);
       }

    if  (eimax <= ZERO)
       {
        *rc   = BSIDGENRAT;
        goto wrapup;
       }
    if  ((eimin/eimax) < eps)
       {
        *rc   = BSIDGENRAT;
        goto wrapup;
       }


/* 
 *  STEP 7:
 *  Solve the triangular system computing the solution of the LSQ problem
*/
    for (i=1,k=0; i<=nrhs; i++,k+=nequ)
       solvtriangsysTWlsqwec (nvar-ncon, nvar,  &mata[0], &rhsa[k], UPPER);
      
/*
 *  Store solution
*/
    for (i=1,i1=0,k1=ncon; i<=nrhs; i++,i1+=nequ,k1+=nvar)
       for (k=0; k<nvar-ncon; k++)
          sol[k1+k] = rhsa[i1+k];



    if (ncon > 0)

/*
 *  Apply the orthogonal transformation which has been constructed from
 *  the constraints to the solution vector sol  -  [equation (20.23)]
*/
      {
       for (j=0;j<ncon;j++)
          mata[j] = sol[j];                  /* save the transformation */

       for (i=1,i1=0,k1=0; i<=nrhs; i++,i1+=nvar,k1+=ncon)
          for (k=0; k<ncon; k++)
             sol[i1+k] = rhsc[k1+k];

       mode=2;
       for (i=1; i<=ncon; i++)
          {
           j = ncon - i;
           k = j*incrrow;
           j++;
           sglehousehtrTWlsqwec(mode    , j      , j+1       , nvar   , 
                                &matc[k], incrcol, &mata[j-1], &sol[0],
                                incrcol , nvar   , nrhs      );
          }
      }

/***************************************************************************
 *  Wrapup
*/
wrapup:
   return;
}
/*****************************************************************************

Name
    TWlsqweccv

Abstract
    Compute a B-spline curve using a linear, weighted, discrete least-square 
    fit with equality constraints to approximate a given set of points.

Synopsis
    void TWlsqweccv ( num_pts,    pdim,      pts,    order, num_poles,   knots,
                          par, num_fix,     pfix, num_der1,     pder1,  deriv1, 
                     opt_der2,  deriv2, num_wgts,    pwgts,      wgts, opt_end, 
                       opt_sm,   smfac,      crv,       rc)

    IGRlong             num_pts;
    IGRshort            pdim;
    IGRdouble           pts[];
    IGRshort            order;
    IGRlong             num_poles;    
    IGRdouble           knots[];
    IGRdouble           par[];
    IGRshort            num_fix;
    IGRshort            pfix[];
    IGRshort            num_der1;
    IGRshort            pder1[];
    IGRdouble           deriv1[];
    IGRshort            opt_der2;
    IGRdouble           deriv2[];
    IGRshort            num_wgts;
    IGRshort            pwgts[];
    IGRdouble           wgts[];
    IGRshort            opt_end;
    IGRshort            opt_sm;
    IGRdouble           smfac;

    struct IGRbsp_curve *crv;
    BSrc                *rc;

Description
    This routine computes a B-spline curve using a linear, weighted discrete
    least-square fit with equality constraints to approximate a given set 
    of points. This routine basically sets up the approximation and 
    constraint equations. For computing the curve it calls routine TWlsqwec.

    POINTS

      Points are stored in the array pts. For 1 <= j <= num_pts pts[j-1][] is
      the j-th point. The second index refers to the dimensionality.
      A point may have dimensionality 2 (p = (u,v)        -  points in 2D space)
                                      3 (p = (x,y,z)      -  points in 3D space)
                                      4 (p = (wx,wy,wz,w) -  points in 4D space)
      Points of dimensionality 4 are called rational points.The fourth 
      component w for a rational point must be greater bas_tol.
      Each point has a parameter assigned to it. The parameter values are
      strictly increasing and have to be consistent with the knot vector (see
      below). For the j-th point the parameter is par[j-1].

    CONSTRAINTS

      The points may have certain constraints:

       1. Interpolation
          A point in the set may be interpolated. The interpolation informa-
          tion is contained in num_fix and pfix. If num_fix > 0, array 
          pfix contains integers pointing to the point in the array pts 
          to be interpolated, for instance, let
                   pfix[i] = j,  where  0 <= i <  num_fix
                                        1 <= j <= num_pts,
          then the j-th point in pts, that is pts[j-1][k], where 
          0 <= k <= pdim-1, is to be  interpolated.
          The point may be rational.  
       2. First derivative interpolation      
          A point in the set may have a first derivative constraint. The
          information is contained in num_der1 and pder1. If num_der1 > 0,
          array pder1 contains integers pointing to the points in the array
          pts to have a first-derivate constraint, for instance, let
                   pder[i] = j,  where  0 <= i <= num_der1
                                        1 <= j <= num_pts,
          then the j-th point has a first derivative prescribed by
          deriv1[i-1][]. Note that in array deriv1 the derivative is at
          the i-th location.
          If the point is not interpolated, then this has to be understood
          that the curve at parameter par[j-1] will have the prescribed first
          derivative.
          This constraint is only valid for non-rational points. 
       3. Second derivative at start/end of curve
          The beginning and/or the end of the curve may have a second
          derivative constraint. If opt_der2 = 0, no constraint is given.
          If opt_der2 = 1, a constraint is imposed at par[0], start of 
          curve. The value is deriv2[0][]. If opt_der2 = 2, a constraint
          is imposed at par[num_pts-1], the end of the curve. The value is 
          deriv2[1][]. If opt_der2 = 3, constraints at both ends are imposed. 
          This constraint is only valid for non-rational points. 
       4. Weighted point approximation
          A point in the set may be weighted. The information is contained in
          num_wgts, pwgts and wgts. If num_wgts > 0, array pwgts contains
          integers pointing to the points in the array pts to weight the
          approximation equation for this point, for instance, let
                   pwgts[i] = j,  where  0 <= i < num_wgts
                                         1 <= j <= num_pts,
          then the j-th point has a weight of wgts[i-1].
          The weights should be greater than zero. The larger the value the
          more weight the point will get, that is, the curve will be attracted
          to the point given in pts.

    END CONDITIONS for FIRST and SECOND DERIVATIVES 

      End conditions can be specified for both ends of the curve. A prerequi-
      sit is that the first and the last point in the set are identical.
      Periodicity conditions can be specified in this case:
          opt_end =  0    no conditions
                  =  1    make first derivatives equal 
                  =  2    make first and second derivatives equal
      (Note: If the first/second derivative is prescribed at one end of the 
             curve and opt_end > 0, the other end cannot have a first/second
             derivative prescribed even if the constraints do not contradict.)

    SMOOTHING

      The smoothing condition opt_sm controls whether the poles will move 
      freely during the approximation or whether they are constrained. 
      The smoothing factor smfac >0 can be considered as a weight factor.
   
    KNOT and PARAMETER DISTRIBUTION

      The knot vector and the parameter distribution must be specified by the 
      caller. The first knot must be 0.0, the last knot must be 1.0. The
      first and last knots must be a multiple knot of multiplicity = order.
      The parameters in array par must be strictly increasing and must be
      consistent with the knot vector, that is the first parameter 
      par[0] = 0.0, the last par[num_pts-1] = 1.0. If a point is to be a
      segment boundary, the parameter must appear as an inner knot.

    RESTRICTIONS

      1. It is the responsibility of the caller to ensure that the constraint
         information is consistent, that is that the constraints are not
         contradictory or linear dependent, and that the constraints given
         for one segment do not exceed the order of the curve. 
      2. The following conditions will result in rc=BSINARG
         Let num_con = num_fix + num_der1 + num_der2 + opt_end be the
         number of constraints where
                                                 ( 0  opt_der2 = 0
                                      num_der2 = ( 1  opt_der2 = 1,2
                                                 ( 2  opt_der2 = 3

         a) (num_pts  < num_poles) && (opt_sm == 0)
            In this case there are not sufficient equations to solve the
            problem.
            For opt_sm == 1, sufficient smoothing equations will be added
            so that the problem can be solved.
         b) num_con  >  num_poles
            In this case there are too many constraints to solve the problem.
         c) num_pts < 4
            These cases should be handled separately.
         c) points are rational (pdim == 4) and 
            1) the weight array in the IGRbsp_curve has not been assigned or
            2) constraint equations for first/second derivatives are specified  
            3) end conditions are specified 
   
    Input:
       num_pts          number of points (num_pts >= 4)
       pdim             dimension of points (pdim=2,3,4)
       pts              array of points 
                         (pts[j][k], 0 <= j <= num_pts-1, 1 <= k <= pdim-1,
                          pts[j][0] = first component of (j-1)-th point, 
                          pts[j][3] > 0.0 if pdim=4)
       order            order of B-spline (2 <= order <= 16)
       num_poles        number of poles for B-spline curve
       knots            knots of B-spline curve (num_knots = order+num_poles)
                         (knots[l], 0<=l<=num_knots-1
                          knots[0]          =...=knots[ord-1]           =0.0;
                          knots[num_poles-1]=...=knot[num_poles+order-1]=1.0;
                          knots[j] <= knots[j+i],    i=1,..,order-1, 
                          knots[j] <  knots[j+order]
                          (The knots with order < j < num_poles are called 
                          inner knots.))
       par              parameter distribution for pts
                         (par[j],               0 <= j <= num_pts-1,
                          par[0]       = 0.0;
                          par[num_pts] = 1.0;
                          par[j-1] <  par[j],   1 <  j <= num_pts-1)
       num_fix          number of points to be interpolated
       pfix             integer array for point reference
                         (pfix[k] = j           0 <= k <= num_fix-1,
                                                1 <= j <= num_pts;
                              j-th point is interpolated)  
       num_der1         number of points which have first derivative
                        prescribed
       pder1            integer array for point reference
       deriv1           first derivatives at points in pder1 
                         (pder1[k] = j        0 <= k <= num_der1-1,
                                              1 <= j <= num_pts;
                          deriv1[k][]         first derivative at pts[j-1]
                                              (only 2 or 3 components) )
       opt_der2         optional second derivative at beginning/end of curve
                         (opt_der2 = 0  no second derivative conditions,
                                   = 1  second derivative at par[0],
                                   = 2  second derivative at par[num_pts-1],
                                   = 3  second derivative at par[0] and
                                                             par[num_pts-1])
       deriv2           second drivatives at beginning/end of curve
                         (opt_der2 = 1,2,3: deriv2[0][] secnd deriv at start,
                                            deriv2[1][]             at end
                                            (only 2 or 3 components)  )
       num_wgts         number of points to have a weight for the weighted
                        approximation
       pwgts            integer array for point reference
       wgts             array to contain the weights for the weighted 
                        least square
                         (pwgts[k] = j        0 <= k <= num_wgts-1,
                                              1 <= j <= num_pts;
                          wgts[k]             weight at pts[j-1])
       opt_end          optional end conditions 
                         (opt_end = 0  no conditions,
                                  = 1  first derivatives at ends equal
                                  = 2  first and second derivatives at ends 
                                       equal
       opt_sm           optional smoothing
                         (opt_sm    = 0  no smoothing
                                      1  add smoothing equations)
       smfac            smoothing factor (> 0.0) 

    Output
       crv              B-spline curve
       rc               BSSUCC     if successful
                        BSINARG    if invalid argument 
                        BSIDGENRAT if inconsistent information

Return Values
    None
       
Notes
    The B-spline curve data for crv must have been allocated by the user. 
    Only the poles are filled into the structure, all other information is
    left untouched. If pdim=2 the z-component of the poles is zeroed. If
    pdim=4, the weights are filled in and the poles are not multiplied by the 
    weight since the points are of the form (wx,wy,wz,w). 

Index

Keywords
    Least-square-fit curve    

History
    Thomas H. Weissbarth.   12/17/93: Creation date. Reimplemented from ICEM.
    Thomas H. Weissbarth.   05/31/94: Rework input parameters for weighted
                                      approximation.
******************************************************************************
*/  
 
/*    General header files and prototypes     */
 
#include <stdio.h>
#include <math.h>
#include "bs.h"
#include "bsparameters.h"
#include "bsdbgrc.h"
#include "bsstackalloc.h"

extern void TWlsqwec ();


/****************************************************************************
*
*   Static function definition
*
*         evalTWlsqweccv    - evaluate the basic B-spline functions at a
*                             parameter 
*
*****************************************************************************/

static void evalTWlsqweccv (border, nbpols, bknots, bpar, bder, 
                             index,   bval,     rc) 

/*****  Input  *****/
IGRshort       border;         /* order of basis spline                     */
IGRint         nbpols;         /* number of poles                           */
IGRdouble      bknots[];       /* knots to be used                          */
IGRdouble      bpar;           /* parameter at which to evaluate            */
IGRint         bder;           /* derivative to compute                     */
                               /*    = 0 zero derivative                    */
                               /*    = 1 first derivative                   */
                               /*    = 2 second derivative                  */

/***** Output  *****/
IGRint         *index;         /* index of span                             */
IGRdouble      bval[];         /* values of basis splines                   */
BSrc           *rc;            

{
/*   include prototypes   */
#include "bsfindspn.h"         /* find index of span for parameter value    */ 
#include "bsmansf0.h"          /* compute basis B spline functions (bBSf)   */
#include "bsmansf1.h"          /* compute first derivate of bBSf            */
#include "bsmansf2.h"          /* compute second derivative of bBSf         */

IGRdouble      b[MAX_ORDER];   /* B-spline blending functions               */
IGRdouble      bd[MAX_ORDER];  /* B-spline first derivative blending funct. */

IGRlong        num_poles;      /* long definition for BSfindspn             */
IGRboolean     status;         /* return status from BSfindspn              */

/****************************************************************************
*    Start of executable code
*/
 
   *rc = BSSUCC;
     
/*   
 *  Find span where B splines are non-zero
*/
   num_poles = nbpols;
   status = BSfindspn (rc,&border, &num_poles, bknots, &bpar, index);
   if (!status)
     goto wrapup;

/*
 *  Compute B-spline blending functions
*/
   if (bder == 0) 
     BSmansf0 (rc, border, bknots, *index, bpar, bval);
   if (bder == 1)
     BSmansf1 (rc, border, bknots, *index, bpar, b, bval);
   if (bder == 2)
     BSmansf2 (rc, border, bknots, *index, bpar, b, bd, bval);

/***************************************************************************
*   Wrapup and return
*/
wrapup:
   if (BSERROR (*rc))  BSdbgrc (*rc, "evalTWlsqweccv");

   return;  
}


/****************************************************************************
*
*                         TWlsqweccv Routine
*
*****************************************************************************/

void TWlsqweccv ( num_pts,    pdim,      pts,    order, num_poles,   knots,
                      par, num_fix,     pfix, num_der1,     pder1,  deriv1, 
                 opt_der2,  deriv2, num_wgts,    pwgts,      wgts, opt_end, 
                   opt_sm,   smfac,      crv,       rc)

IGRlong             num_pts;
IGRshort            pdim;
IGRdouble           pts[];
IGRshort            order;
IGRlong             num_poles;    
IGRdouble           knots[];
IGRdouble           par[];
IGRshort            num_fix;
IGRshort            pfix[];
IGRshort            num_der1;
IGRshort            pder1[];
IGRdouble           deriv1[];
IGRshort            opt_der2;
IGRdouble           deriv2[];
IGRshort            num_wgts;
IGRshort            pwgts[];
IGRdouble           wgts[];
IGRshort            opt_end;
IGRshort            opt_sm;
IGRdouble           smfac;

struct IGRbsp_curve *crv;
BSrc                *rc;

{
/*  Declarations for routine TWlsqwec  */

   IGRint           nvar;              /* number of variables               */
   IGRint           nequ;              /* number of approximation equations */
   IGRint           ncon;              /* number of constraint equations    */
   IGRint           nrhs;              /* number of right hand sides        */
   IGRdouble        *mata;             /* matrix for approximation equations*/
   IGRdouble        *rhsa;             /* right hand side for approx. equ.  */
   IGRdouble        *matc;             /* matrix for constraint equations   */
   IGRdouble        *rhsc;             /* right hand side for constr. equ.  */
   IGRdouble        *sol;              /* solution vector                   */
   IGRdouble        *res;              /* result                            */

   IGRdouble        *wrkarea;          /* work area to be allocated         */

   IGRint           s_mata;            /* size of matrix mata               */
   IGRint           s_matc;            /* size of matrix matc               */
   IGRint           s_rhsa;            /* size of right hand side (appr.)   */
   IGRint           s_rhsc;            /* size of right hand side (constr.) */
   IGRint           s_sol;             /* size of solution vector           */

   IGRint           s_wrkarea;         /* size of complete workarea         */

   IGRint           num_rowa;          /* number of row for mata            */
   IGRint           num_rowc;          /* number of row for matc            */
   IGRint           size_row;          /* row size of matrix mata, matc     */
   IGRint           nder;              /* number of derivatives to be comp. */
   IGRint           nce;               /* number of constraint equation     */
   IGRint           nae;               /* number of approximation equation  */

   IGRint           num_der2;          /* number of second derivatives      */
   IGRint           num_sm;            /* number of smoothing equations     */

   IGRdouble        p;                 /* parameter value where to evaluate */
   IGRdouble        eval[MAX_ORDER];   /* B-spline blending functions       */
   IGRint           ind;               /* span index                        */
   IGRdouble        fac1,fac2;         /* factors for derivatives           */
   IGRdouble        weight;            /* weight for weighted approximation */
   IGRboolean       ipc;               /* TRUE if point is interpolated     */
   IGRdouble        dti0,dti1,dti2;
   IGRdouble        dtin,dtin1,dtin2;
 
   IGRint           i,i1,j,k,k1,k2;    /* loop, array indices               */

/****************************************************************************
 *
 *       Start of executable code
 *
 ****************************************************************************/

   wrkarea = NULL;
     
/*
 *  Check input
*/ 
   *rc = BSINARG;

   if (num_pts < 4)                                 goto wrapup;

   num_der2 = 0;
   if (opt_der2 > 0)
     {
      if ((opt_der2 == 1) || (opt_der2 == 2))
        num_der2 = 1;
      if  (opt_der2 == 3)
        num_der2 = 2;
     }
   ncon = num_fix + num_der1 + num_der2 + opt_end; 

   if ((num_pts < num_poles) && (opt_sm == 0))      goto wrapup;

   if (ncon > num_poles)                            goto wrapup;

   if ((pdim == 4) && (!crv->weights))              goto wrapup;

   if ((pdim == 4) && ((num_der1 > 0) || 
                       (num_der2 > 0) ||
                       (opt_end  > 0)))             goto wrapup;


/*
 *  Obtain memory for setting up the equations
*/

   nvar      = num_poles;
   num_sm    = 0;
   if (opt_sm == 1) 
      num_sm    = nvar - 2;
   nequ      = num_pts - num_fix + num_sm;

   s_mata    = nequ*nvar;
   s_matc    = ncon*nvar;
   s_rhsa    = nequ*pdim;
   s_rhsc    = ncon*pdim;
   s_sol     = nvar*pdim;

   s_wrkarea = s_mata + s_rhsa + s_matc + s_rhsc + s_sol;
   s_wrkarea *= sizeof (IGRdouble); 

   wrkarea   = (IGRdouble *) BSstackalloc ((unsigned)s_wrkarea);
   if (!wrkarea)  goto nomem;
 
   mata      = wrkarea;
   matc      = mata + s_mata;
   rhsa      = matc + s_matc;
   rhsc      = rhsa + s_rhsa;
   sol       = rhsc + s_rhsc;

/****************************************************************************
 *
 *  Set up matrices containing approximation and constraint equations
 *
 ***************************************************************************/
 
   size_row     = nvar;

/****************************************************************************
 *  Compute constraint equations
*/
   num_rowc = 0;
   nce      = 0;
   p        = 0.0;


/*
 *     Compute equations for interpolation constraints
*/

   if (num_fix > 0)
     {
      nder = 0;
      for (i = 0; i < num_fix; i++)
         {
          j = pfix[i];
          p = par[j-1];
          for (k = 0; k < nvar; k++)
             matc[num_rowc + k] = 0.0;
/* evaluate basis functions of B splines at parameter p                    */
          evalTWlsqweccv ( order,     nvar, &knots[0], p, nder, 
                           &ind,  &eval[0],        rc); 
          if (BSERROR (*rc)) goto wrapup;
          k1 = ind-order+1;
/* insert values of basis splines into matrix                              */
          for (k = k1, k2 = 0; k <= ind; k++, k2++)
              matc[num_rowc + k] = eval[k2];
/* insert right hand side                                                  */
          k2 = (j-1)*pdim-1;
          for (k = 1, k1 = nce; k <= pdim; k++, k1+=ncon)
              rhsc[k1] = pts[k2+k];

/* jump to next row                                                        */
          num_rowc += size_row;
          nce++;
         }
     }

/*
 *     Compute equations for first derivative constraints
*/

   if (num_der1 > 0)
     {
      nder = 1;

      for (i = 0; i < num_der1; i++)
         {
          j = pder1[i];
          p = par[j-1];
          for (k = 0; k < nvar; k++)
             matc[num_rowc + k] = 0.0;
/* evaluate basis functions of B splines at parameter p                    */
          evalTWlsqweccv ( order,     nvar, &knots[0], p, nder, 
                           &ind,  &eval[0],        rc); 
          if (BSERROR (*rc)) goto wrapup;
          k1 = ind-order+1;
/* insert values of basis splines into matrix                              */
          for (k = k1, k2 = 0; k <= ind; k++, k2++)
              matc[num_rowc + k] = eval[k2];
/* insert right hand side                                                  */
          k2 = i*pdim-1;
          for (k = 1, k1 = nce; k <= pdim; k++, k1+=ncon)
              rhsc[k1] = deriv1[k2+k];
/* jump to next row                                                        */
          num_rowc += size_row;
          nce++;
         }
     }

/*
 *     Compute equations for second derivative constraints
*/

   if (num_der2 > 0)
     {
      nder = 2;
      for (i = 1; i <= 2; i++)
         {
          if ((opt_der2 == i) || (opt_der2 == 3))
            {
             if (i == 1)
                p = par[0];
             if (i == 2)
                p = par[num_pts-1];

             for (k = 0; k < nvar; k++)
                matc[num_rowc + k] = 0.0;
/* evaluate basis functions of B splines at parameter p                    */
             evalTWlsqweccv ( order,     nvar, &knots[0], p, nder, 
                              &ind,  &eval[0],        rc); 
             if (BSERROR (*rc)) goto wrapup;
             k1 = ind-order+1;
/* insert values of basis splines into matrix                              */
             for (k = k1, k2 = 0; k <= ind; k++, k2++)
                matc[num_rowc + k] = eval[k2];
/* insert right hand side                                                  */
             k2 = (i-1)*pdim-1;
             for (k = 1, k1 = nce; k <= pdim; k++, k1+=ncon)
                rhsc[k1] = deriv2[k2+k];
/* jump to next row                                                        */
             num_rowc += size_row;
             nce++;
            }
         }
     }

/*
 *     Compute equations for end conditions
*/

   if (opt_end > 0)
     {
      k2 = num_poles+order-1;

      for (k = 0; k < nvar; k++)
         matc[num_rowc + k] = 0.0;

      dti0 = knots[order  ] - knots[1];
      dtin = knots[k2   -1] - knots[num_poles-1];

      matc[num_rowc          ] = -1.0/dti0;
      matc[num_rowc +       1] =  1.0/dti0;
      matc[num_rowc + nvar -1] =  1.0/dtin;
      matc[num_rowc + nvar -2] = -1.0/dtin;
/* insert right hand side                                                  */
      for (k = 1, k1 = nce; k <= pdim; k++, k1+=ncon)
         rhsc[k1] = 0.0;
/* jump to next row                                                        */
      num_rowc += size_row;
      nce++;

      if (opt_end == 2)
        {
         dti1 = knots[order+1] - knots[2];
         dti2 = knots[order+0] - knots[2];
         dtin1= knots[k2   -2] - knots[num_poles-2];
         dtin2= knots[k2   -2] - knots[num_poles-1]; 
         dti2 = 1.0/dti2;
         dtin2= 1.0/dtin2;

         matc[num_rowc          ] =  dti2/dti0;
         matc[num_rowc +       1] = -dti2*(1.0/dti0 + 1.0/dti1);
         matc[num_rowc +       2] =  dti2/dti1;
         matc[num_rowc + nvar -1] = -dtin2/dtin;
         matc[num_rowc + nvar -2] =  dtin2*(1.0/dtin + 1.0/dtin1);
         matc[num_rowc + nvar -3] = -dtin2/dtin1;
/* insert right hand side                                                  */
         for (k = 1, k1 = nce; k <= pdim; k++, k1+=ncon)
            rhsc[k1] = 0.0;
/* jump to next row                                                        */
         num_rowc += size_row;
         nce++;
        }
     }

/****************************************************************************
 *  Compute approximation equations
*/
   num_rowa = 0;
   nae      = 0;

   nder = 0;

   for (i = 0; i < num_pts; i++)
      {
/* check if this point has an interpolation condition                      */
       ipc = FALSE;
       for (j = 0; j < num_fix; j++)
          {
           if (pfix[j] == (i+1)) 
             ipc = TRUE;
          }
       if (ipc == TRUE)  continue; 

       p = par[i];
       for (k = 0; k < nvar; k++)
          mata[num_rowa + k] = 0.0;
/* check for weighted approximation                                        */
       weight = 1.0;
       for (j = 0; j < num_wgts; j++)
          {
           if (pwgts[j] == (i+1))
             {
              weight = wgts[j];
              break;
             }
          }
/* evaluate basis functions of B splines at parameter p                    */
       evalTWlsqweccv ( order,     nvar, &knots[0], p, nder, 
                        &ind,  &eval[0],        rc);
       if (BSERROR (*rc)) goto wrapup;
       k1 = ind-order+1;
/* insert values of basis splines into matrix                              */
       for (k = k1, k2 = 0; k <= ind; k++, k2++)
          mata[num_rowa + k] = weight*eval[k2];
/* insert right hand side                                                  */
       k2 = i*pdim-1;
       for (k = 1, k1 = nae; k <= pdim; k++, k1+=nequ)
          rhsa[k1] = weight*pts[k2+k];

/* jump to next row                                                        */
       num_rowa += size_row;
       nae++;
      }

/****************************************************************************
*  Compute smoothing equations
*
*/
   if (num_sm > 0)
     {
      fac1 = smfac/2.0;
      fac2 = smfac;

      for (i = 1, i1 = 0; i <= num_sm; i++, i1++)   
         {
          for (k = 0 ; k < nvar; k++)
             mata[num_rowa + k] = 0.0;
          mata[num_rowa+i1+0] =  fac2;
          mata[num_rowa+i1+1] = -2.0*fac2;
          mata[num_rowa+i1+2] =  fac2;
          for (k = 1, k1 = nae; k <= pdim; k++, k1+=nequ)
             rhsa[k1] = 0.0;
          num_rowa += size_row;
          nae++;
         }
      }

/***************************************************************************
*
*        Compute the solution
*
****************************************************************************/

   nrhs = pdim;
   TWlsqwec (nvar, nequ, ncon, nrhs, matc, rhsc, mata, rhsa, 
              sol, rc);

   if (BSERROR (*rc)) goto wrapup;

/****************************************************************************
 *  Store solution
*/
   k1 = nvar;
   p  = 0.0;
   
   for (i=0, k=0; i<nvar; i++, k=k+3)
      {
       res = &sol[i];
       crv->poles[k]    = *res;
       res  = res + k1;
       crv->poles[k+1]  = *res;
    
       if (pdim >= 3)
         {
          res  =  res + k1;
          p    =  *res;
         }
       crv->poles[k+2]  = p;

       if (pdim == 4)
         {    
          res   =  res + k1;
          crv->weights[i]   = *res;
         }

      }
   goto wrapup;

/****************************************************************************
 * 
 *  Error return
 *
*/
nomem:
   *rc  = BSNOSTKMEMORY;    
   goto wrapup;


/****************************************************************************
 *
 *  Wrapup and Return
 *
*/
wrapup:

   if (wrkarea)
     BSstackdealloc ((char *) wrkarea);

/*
 *   Return
*/
   if (BSERROR (*rc))   BSdbgrc (*rc, "TWlsqweccv");

   return;
}

/*****************************************************************************

Name
    TWlsqweccv0

Abstract
    Compute a B-spline curve using a linear, weighted, discrete least-square 
    fit with equality constraints to approximate a given set of (rational) 
    points. Set up routine for TWlsqweccv.

Synopsis
    void TWlsqweccv0  ( num_pts,      pdim,       pts, order, num_knots, knots,
                        opt_par,       par,   num_fix,  pfix,   num_tan,  ptan,
                            tan, opt_curv0, opt_curv1,  curv,  num_wgts, pwgts,
                           wgts,   opt_end,    opt_sm, smfac,       crv,    rc)

    IGRlong             num_pts;
    IGRshort            pdim;
    IGRdouble           pts[];
    IGRshort            order;
    IGRlong             num_knots;
    IGRdouble           knots[];
    IGRshort            opt_par;
    IGRdouble           par[];
    IGRshort            num_fix;
    IGRshort            pfix[];
    IGRshort            num_tan;
    IGRshort            ptan[];
    IGRdouble           tan[];
    IGRshort            opt_curv0;
    IGRshort            opt_curv1;
    IGRdouble           curv[];
    IGRshort            num_wgts;
    IGRshort            pwgts[];
    IGRdouble           wgts[];
    IGRshort            opt_end;
    IGRshort            opt_sm;
    IGRdouble           smfac;

    struct IGRbsp_curve *crv;
    BSrc                *rc;

Description
    This routine computes a B-spline curve using a linear, weighted discrete
    least-square fit with equality constraints to approximate a given set 
    of points. For computing the curve it calls routine TWlsqweccv.
    This routine basically computes the parameter distribution, if not 
    provided, and the first/second derivative data from the tangent and 
    curvature information. If this is all known, the routine TWlsqweccv can 
    be called directly.

    POINTS

      Points are stored in the array pts. For 1 <= j <= num_pts pts[j-1][] is
      the j-th point. The second index refers to the dimensionality.
      A point may have dimensionality 2 (p = (u,v)        -  points in 2D space)
                                      3 (p = (x,y,z)      -  points in 3D space)
                                      4 (p = (wx,wy,wz,w) -  points in 4D space)
      Points of dimensionality 4 are called rational points. The fourth 
      component w for a rational point must be greater bas_tol.
      
      It is not checked in this routine if all points are identical so that
      the curve would degenerate into one point. This should be checked by
      the caller before calling this routine.
 
      Each point may have, optionally, a parameter assigned to it. In this  
      case, the parameter values are strictly increasing and have to be 
      consistent with the knot vector (see below). For the j-th point 
      the parameter is par[j-1].

    CONSTRAINTS

      The points may have certain constraints:

       1. Interpolation
          A point in the set may be interpolated. The interpolation informa-
          tion is contained in num_fix and pfix. If num_fix > 0, array 
          pfix contains integers pointing to the points in the array pts 
          to be interpolated, for instance, let
                   pfix[i] = j,  where  0 <= i <  num_fix
                                        1 <= j <= num_pts,
          then the j-th point in pts, that is pts[j-1][k], where 
          0 <= k <= pdim-1, is to be  interpolated.
          The point may be rational.  
       2. Tangent interpolation      
          A point in the set may have a tangent constraint. The
          information is contained in num_tan and tan. If num_tan > 0,
          array ptan contains integers pointing to the points in the array
          pts to have a tangent constraint, for instance, let
                   ptan[i] = j,  where  0 <= i <  num_tan
                                        1 <= j <= num_pts,
          then the j-th point has a tangent prescribed by tan[i-1][]. The
          tangent must be normalized, that is the length must be one.  
          Note that in array tan the tangent is at the i-th location. 
          The tangent is a vector and has a direction. The first derivative
          of the curve will point in the same direction as the tangent.
          If the point is not interpolated, then this has to be understood
          that the curve at parameter par[j-1] will have the prescribed 
          tangent.
          This constraint is only valid for non-rational points. 
       3. Curvature at start/end of curve
          The beginning and/or the end of the curve may have a curvature
          constraint. The variable opt_curv0 specifies conditions for the
          start of the curve (at par[0]), opt_curv1 for the end
          (at par[num_pts-1]). If opt_curv# = 0, no constraint is given.
          If opt_curv0 = 1, a constraint is imposed at par[0], start of 
          curve. The vector is curv[0][]. If opt_curv1 = 1, a constraint
          is imposed at par[num_pts-1], the end of the curve. The vector is 
          curv[1][]. If opt_curv# = 2, a zero curvature is imposed by
          constraining the second derivative at the respective end to vanish.
          Note that curv[][] is a vector denoting the curvature vector. The
          curvature vector is normal to the tangent, lies in the
          osculating plane and its length is the reciprocal value of the radius
          of curvature. The curvature vector may be zero imposing a zero
          curvature without forcing the second derivative to vanish but to
          make it collinear with the first derivative.
          This constraint is only valid for non-rational points. 
       4. Weighted point approximation
          A point in the set may be weighted. The information is contained in
          num_wgts, pwgts and wgts. If num_wgts > 0, array pwgts contains
          integers pointing to the points in the array pts to weight the
          approximation equation for this point, for instance, let 
                   pwgts[i] = j,  where  0 <= i <  num_wgts
                                         1 <= j <= num_pts,
          then the j-th point has a weight of wgts[i-1]. 
          The weights should be greater than zero. The larger the value the
          more weight the point will get, that is, the curve will be attracted
          to the point given in pts.



    END CONDITIONS for FIRST and SECOND DERIVATIVES 

      End conditions can be specified for both ends of the curve. A prerequi-
      sit is that the first and the last point in the set are identical.
      Periodicity conditions can be in this case: 
          opt_end =  0    no conditions
                  =  1    make first derivatives equal 
                  =  2    make first derivatives and second derivatives equal
      (Note: If the tangent/curvature (vector) is prescribed at one end of the 
             curve and opt_end > 0, the other end cannot have a tangent/
             curvature constraint prescribed even if the constraints do 
             not contradict.)

    SMOOTHING

      The smoothing condition opt_sm controls whether the poles will move 
      freely during the approximation or whether they are constrained. 
      The smoothing factor smfac >0 can be considered as a weight factor.
   
    KNOT and PARAMETER DISTRIBUTION

      The num_knots and the knot vector must be specified by the user. 
      The first and last knot must have a multiplicity of order. The
      first knot equals 0.0, the last knot equals 1.0.
      The parameter opt_par determines how the parameter distribution is
      handled. 
      If opt_par = 0, then the array par contains the parameters
      assigned to the points in the point set. The parameters in array par 
      must be strictly increasing and must be consistent with the knot vector,
      that is the first parameter par[0] = 0.0, the last par[num_pts-1] = 1.0. 
      if opt_par > 0, the parameter distribution is computed, the options are
      equidistant, chordal and centripedal. This is only recommended when there
      are no interpolation conditions (num_fix = num_tan = 0) to avoid the
      possibility to have to many constraints in one segment.

    RESTRICTIONS

      1. It is the responsibility of the caller to ensure that the constraint
         information is consistent, that is that the constraints are not
         linear dependent (two or more constraints of the same type for one
         point) and that the constraints given for one segment do not 
         exceed the order of the curve. 
      2. The following conditions will result in rc=BSINARG
         Let num_con = num_fix + num_tan + num_curv + opt_end be the
         number of constraints where
                                  num_curv = num_curv0 + num_curv1
                                  ( = 0 opt_curv# = 0
                with num_curv# =  ( = 1 opt_curv# = 1,2 and tangent constraint
                                  ( = 2 opt_curv# = 1,2 and no tangent constr.

         Let num_poles = num_knots - order 
                       = order + sum_over_i (multinner(i))
                                  where multinner(i) = multiplicity of the
                                                       i-th inner knot
         a) (num_pts +(num_con - num_fix) < num_poles) && (opt_sm == 0)
            In this case there is not enough data/constraints to compute the 
            curve. For opt_sm == 1, additional conditions are defined so that a
            curve can be computed.
            In case num_con = num_fix and num_pts < num_poles (too many
            variables) the opt_sm != 0 indication allows to compute a curve.
            For instance, if num_fix = num_pts (each point is interpolated) and
            num_poles > num_pts, the additional smoothing gives a pleasant
            curve using the excessive variables for smoothing. 
         b) num_con > num_poles = num_knots - order
            In this case, too many conditions are specified.
         c) num_pts < 4
            This special case should be handled by a different routine. In 
            addition, all points should not be identical. However, this is not 
            checked in this routine.
         d) points are rational (pdim == 4) and 
            1) the weight array in the IGRbsp_curve has not been assigned or
            2) conditions for tangent/curvature are specified or
            3) end conditions are specified  
   
    Input:
       num_pts          number of points (num_pts >= 4)
       pdim             dimension of points (pdim=2,3,4)
       pts              array of points 
                         (pts[j][k], 0 <= j <= num_pts-1, 0 <= k <= pdim-1,
                          pts[j][0] = first component of (j-1)-th point, 
                          pts[j][3] > 0.0 if pdim=4)
       order            order of B-spline (2 <= order <= 16)
       num_knots        number of knots in knot vector (counting the
                        multiplicities)
       knots            knots of B-spline curve
                         (knots[l], 0<=l<=num_knots-1
                          knots[0]          =...=knots[ord-1]           =0.0;
                          knots[num_poles-1]=...=knot[num_poles+order-1]=1.0;
                          knots[j] <= knots[j+i],    i=1,..,order-2, 
                          knots[j] <  knots[j+order-1])
       opt_par          optional parameter distribution
                         (opt_par  = 0  parameter distribution specified in
                                        array par
                                     1  compute equidistant distribution
                                     2  compute chordal distribution
                                     3  compute centripedal distribution)
       par              parameter distribution for pts, if opt_par = 0 user
                        must specify the distribution, in case opt_par > 0
                        routine computes distribution and stores this in par,
                        so par must be dimensioned accordingly
                         (par[j],               0 <= j <= num_pts-1,
                          par[0]         = 0.0;
                          par[num_pts-1] = 1.0;
                          par[j-1] <  par[j],   1 <  j <= num_pts-1)
       num_fix          number of points to be interpolated
       pfix             integer array for point reference
                         (pfix[k] = j           0 <= k <= num_fix-1,
                                                1 <= j <= num_pts;
                              j-th point is interpolated)  
       num_tan          number of points which have tangent prescribed
       ptan             integer array for point reference
       tan              tangent at points in ptan 
                         (ptan[k] = j        0 <= k <= num_tan-1,
                                             1 <= j <= num_pts;
                          tan[k][]           unitized tangent at pts[j-1]) 
       opt_curv0        optional curvature at beginning of curve
                         (opt_curv0 = 0 no curvature conditions
                                    = 1 curvature vector at par[0],
                                    = 2 curvature zero (forcing second
                                        derivative to be zero)
       opt_curv1        optional curvature at end of curve
                         (opt_curv1 = 0 no curvature conditions
                                    = 1 curvature vector at par[num_pts-1],
                                    = 2 curvature zero (forcing second 
                                        derivative to be zero)
       curv             curvature vectors at beginning/end of curve
                         (curv[0][k] curv. vector at start,
                          curv[1][k]              at end)
       num_wgts         number of points to have a weight for the weighted
                        approximation
       pwgts            integer array for point reference 
       wgts             array to contain the weights for the weighted 
                        least square
                         (pwgts[k] = j        0 <= k <= num_wgts-1,
                                              1 <= j <= num_pts;
                          wgts[k]             weight at pts[j-1]) 
       opt_end          optional end conditions 
                         (opt_end = 0  no conditions,
                                  = 1  first derivatives at ends equal
                                  = 2  first and second derivatives at ends 
                                       equal
       opt_sm           optional smoothing
                         (opt_sm    = 0  no smoothing
                                      1  add smoothing equations)
       smfac            smoothing factor (> 0.0) 

    Output
       par              parameter distribution (if opt_par > 0)
       crv              B-spline curve
       rc               BSSUCC     if successful
                        BSINARG    if invalid argument 
                        BSIDGENRAT if inconsistent information

Return Values
    None
       
Notes
    The B-spline curve data for crv must have been allocated by the user. 
    Only the poles are filled into the structure, all other information is
    left untouched. If pdim=2 the z-component of the poles is zeroed. If
    pdim=4, the weights are filled in and the poles are not multiplied by the 
    weight since the points are already of the form (wx,wy,wz,w). 

Index

Keywords
    Least-square-fit curve    

History
    Thomas H. Weissbarth.   01/15/94: Creation date. 
    Thomas H. Weissbarth.   05/31/94: Rework input parameters for weighted
                                      approximation.
******************************************************************************
*/  
 
/*    General header files and prototypes     */
 
#include <stdio.h>
#include <math.h>
#include "bs.h"
#include "bsparameters.h"
#include "bscveval.h"
#include "bsdbgrc.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "bsstackalloc.h"


extern void TWlsqweccv();

/****************************************************************************
*
*                         TWlsqweccv0 Routine
*
*****************************************************************************/

void TWlsqweccv0  (num_pts,      pdim,       pts,  order, num_knots,    knots,
                   opt_par,       par,   num_fix,   pfix,   num_tan,     ptan, 
                       tan, opt_curv0, opt_curv1,   curv,  num_wgts,    pwgts,  
                      wgts,   opt_end,    opt_sm,  smfac,       crv,       rc)

IGRlong             num_pts;
IGRshort            pdim;
IGRdouble           pts[];
IGRshort            order;
IGRlong             num_knots;    
IGRdouble           knots[];
IGRshort            opt_par;
IGRdouble           par[];
IGRshort            num_fix;
IGRshort            pfix[];
IGRshort            num_tan;
IGRshort            ptan[];
IGRdouble           tan[];
IGRshort            opt_curv0;
IGRshort            opt_curv1;
IGRdouble           curv[];
IGRshort            num_wgts;
IGRshort            pwgts[];
IGRdouble           wgts[];
IGRshort            opt_end;
IGRshort            opt_sm;
IGRdouble           smfac;

struct IGRbsp_curve *crv;
BSrc                *rc;

{
   IGRlong          num_poles;         /* number of poles of curve to be    */
                                       /* computed                          */
   IGRint           num_con;           /* number of constraints             */
   IGRshort         num_der1;          /* number of first derivatives       */
   IGRdouble        *deriv1;           /* array for first derivatives       */
   IGRint           s_deriv1;          /* size of deriv1                    */
   IGRint           num_curv;          /* number of curvature conditions    */
   IGRint           sw0,sw1;           /* switches to indicate if a tangent */
                                       /* is prescribed at the start/end    */
                                       /* when a curvature constraint exists*/
   IGRshort         opt_der2;          /* options for second derivatives    */
   IGRdouble        deriv2[6];         /* array for second derivatives      */

   IGRshort         opt_sm1;           /* smoothing option for first compute*/
   IGRdouble        smfac1;            /* smoothing factor for first compute*/

   IGRdouble        *wrkarea;          /* workarea for first and second     */
                                       /* derivatives                       */
   IGRint           s_wrkarea;         /* size of workarea                  */

   IGRdouble        *points;
   IGRdouble        *param;
   IGRdouble        p;
   IGRdouble        dx,dy,dz,dl;
   IGRdouble        delta;             /* parameter step                    */
   IGRint           num_deriv;         /* number of derivatives to evaluate */
   IGRpoint         eval[3];           /* evaluation values                 */
   IGRdouble        dist;              /* point distances                   */
   IGRdouble        dotp;              /* dot product value                 */
   IGRdouble        vec[3];            /* workarea                          */
   IGRdouble        cosa;              /* scalar product value              */

   IGRint           i,i1,j,k;          /* loop indices, array indices       */

/****************************************************************************
 *
 *       Start of executable code
 *
 ****************************************************************************/

   wrkarea = NULL;
   deriv1  = NULL;
     
/***************************************************************************
 *  Check input
*/ 
 
   *rc = BSINARG;

/*  Illegal number of points  */
   if (num_pts < 4)                       goto wrapup;

/*  Curvature conditions at ends  */
   num_curv = 0;
   sw0 = -1;
   sw1 = -1;

    if (opt_curv0 > 0)
     {
      num_curv++;
      if (num_tan > 0)
        {
         for (i = 0; i < num_tan; i++)
            if (ptan[i] == 1) 
              {
               num_curv--;
               sw0 = i;
              }
        }
      if (opt_curv0 == 2)
        num_curv++;
     }
 
   if (opt_curv1 > 0 )
     {
      num_curv++;
      if (num_tan > 0)
        {
         for (i = 0; i < num_tan; i++)
            if (ptan[i] == num_pts) 
              {
               num_curv--;
               sw1 = i;
              }
        }
      if (opt_curv1 == 2)
        num_curv++;
     } 

   num_poles = num_knots - order;
   num_con   = num_fix + num_tan + num_curv + opt_end;

/*  Not enough data/constraints   */
   if ((num_pts + (num_con - num_fix) < num_poles) 
     && (opt_sm == 0))                              goto wrapup;

/*  Too many constraints   */
   if (num_con > num_poles)                         goto wrapup;

/*  Rational points   */
   if ((pdim == 4) && (!crv->weights))              goto wrapup;
   if ((pdim == 4) && ((num_tan > 0)   ||
                       (num_curv> 0)   ||
                       (opt_end > 0)))              goto wrapup;

/*  Adjust smoothing factor   */
   smfac1 = sqrt( (double) num_pts);
   if (opt_sm == 1)
     smfac1 *= smfac;
   else
     smfac1 *= 0.001;


/****************************************************************************
 *
 *  Compute parameter distribution if not present
 *
 ***************************************************************************/

   if (opt_par > 0)
     {
      par[0] =         0.0;
      par[num_pts-1] = 1.0;

      if (opt_par == 1)
        {
/*         Equidistant distribution                                        */
         
         param = &par[1];
         delta = (double ) (num_pts - 1);
         delta = 1.0/delta;
         p     = delta;
         for (k = 1; k< num_pts-1; k++, param++)
            {
             *param = p;
             p     += delta;
            }
        }
  
      if ((opt_par == 2) || (opt_par == 3))
        {
/*         Chordal or centripedal distribution    */

         points = &pts[0];
         param  = &par[1];
         dl = 0.0;
         for (k = 0; k < num_pts-1; k++)
            {
             dx = *(points+pdim) - *points;
             points++;
             dy = *(points+pdim) - *points;
             if (pdim > 2)
               {
                points++;
                dz = *(points+pdim) - *points;
               }
             else
                dz = 0.0;
             dist  = sqrt(dx*dx + dy*dy + dz*dz);
             if (opt_par == 3)
               dist = sqrt (dist);
             dl += dist;
             *param = dl;
             param++;
             points++;
            }    
         param = &par[1];
         for (k = 1; k < num_pts-1; k++, param++)
            *param /= dl;

         par[num_pts-1] = 1.0;
        }
     } 

/****************************************************************************
 *
 *  If tangent or curvature conditions present compute curve and evaluate
 *
 ***************************************************************************/

   num_der1 = 0;
   opt_der2 = 0;

   if ((num_tan > 0) || (num_curv > 0))
     {
 
/*
 *  Obtain memory for computing first and second derivatives
*/

/*   Add two more tangent conditions in case of curvature constraints at end
 *   where we need to also impose tangent constraints
*/
      s_deriv1  = (num_tan+2) *pdim;

      s_wrkarea = s_deriv1*(sizeof (IGRdouble));

      wrkarea   = (IGRdouble *) BSstackalloc ((unsigned) s_wrkarea);
      if (!wrkarea) goto nomem;
    
      deriv1   = wrkarea;

/*  Compute a first guess without imposing any first/second derivatives   */
      num_der1 = 0;
      opt_der2 = 0;

/*  Add smoothing if necessary */
      opt_sm1 = opt_sm;
      if(opt_sm == 0)
        if(num_pts < num_poles)
          opt_sm1 = 1;

      TWlsqweccv ( num_pts,    pdim,      pts,    order, num_poles,   knots,
                       par, num_fix,     pfix, num_der1,      ptan,  deriv1,
                  opt_der2,  deriv2, num_wgts,    pwgts,      wgts, opt_end, 
                   opt_sm1,  smfac1,      crv,       rc);
      if (BSERROR (*rc)) goto wrapup;

/*
 *  Evaluate curve at parameters where constraints are prescribed
*/
      if (num_tan > 0)
        {
/*    First derivatives  */
         num_deriv = 1;

         num_der1 = num_tan;
         for (i = 0; i < num_tan; i++)
            {
             j = ptan[i];
             p = par[j-1];
             BScveval (crv, p, num_deriv, &eval[0], rc);
             if (BSERROR (*rc))  goto wrapup;
             dl  = eval[1][0]*eval[1][0];
             dl += eval[1][1]*eval[1][1];
             dl += eval[1][2]*eval[1][2];
             dl = sqrt (dl);
             i1 = i*pdim;
             cosa = eval[1][0]*tan[i1+0] + eval[1][1]*tan[i1+1];
             if (pdim == 3)
               cosa += eval[1][2]*tan[i1+2];
             cosa = (cosa/dl);
/*        prevent cosa = 0.0 ! */
             cosa = dl*(1.0 - acos(cosa)/3.15);
             deriv1[i1+0]   = cosa*tan[i1+0];
             deriv1[i1+1]   = cosa*tan[i1+1];
             if (pdim == 3)
               deriv1[i1+2] = cosa*tan[i1+2];
            }
        }


      if ((opt_curv0 > 0) || (opt_curv1 > 0))                        
        {
/*    Second derivatives at start or end     */

/*    Default to zero curvature at both ends by forcing second derivative
 *    to vanish
*/
         for (i = 0; i < 6; i++)
            deriv2[i] = 0.0;

/*    Set up correct number of curvature options    */
         if ((opt_curv0 >  0) && (opt_curv1 == 0)) opt_der2 = 1;
         if ((opt_curv0 == 0) && (opt_curv1 >  0)) opt_der2 = 2;
         if ((opt_curv0 >  0) && (opt_curv1 >  0)) opt_der2 = 3;

/*   Check individual options   */      
         num_deriv  = 2;
         if (opt_curv0 == 1)
           {
            p = par[0];
            BScveval (crv, p, num_deriv, &eval[0], rc);
            if (BSERROR (*rc)) goto wrapup;
            if (sw0 < 0)
              {
               vec[0] = eval[1][0];
               vec[1] = eval[1][1];
               vec[2] = eval[1][2];
               BSnorvec (rc, vec);
               num_der1++;
               i1 = num_der1*pdim;
               deriv1[i1+0] = eval[1][0];
               deriv1[i1+1] = eval[1][1];
               if (pdim == 3)
                 deriv1[i1+2] = eval[1][2];
              }
            else
              {
               i1      = pdim*sw0;
               vec[0] = tan[i1+0];
               vec[1] = tan[i1+1];
               if (pdim == 2)
                 {
                  vec[2] = 0.0;
                 }
               else
                 {
                  vec[2] = tan[i1+2];
                 }
              }
            dl   = deriv1[i1]*deriv1[i1] + deriv1[i1+1]*deriv1[i1+1];
            dl  += deriv1[i1+2]*deriv1[i1+2];
            dotp = BSdotp (rc, vec, &eval[2][0]);
            deriv2[0]  = dotp*vec[0] + curv[0]*dl;
            deriv2[1]  = dotp*vec[1] + curv[1]*dl;
            if (pdim ==  3)
              deriv2[2]= dotp*vec[2] + curv[2]*dl;
           }

         if (opt_curv1 == 1)
           {
            p = par[num_pts-1];
            BScveval (crv, p, num_deriv, &eval[0], rc);
            if (BSERROR (*rc)) goto wrapup;
            if (sw1 < 0)
              {
               vec[0] = eval[1][0];
               vec[1] = eval[1][1];
               vec[2] = eval[1][2];
               BSnorvec (rc, vec);
               num_der1++;
               i1 = num_der1*pdim;
               deriv1[i1+0] = eval[1][0];
               deriv1[i1+1] = eval[1][1];
               if (pdim == 3)
                 deriv1[i1+2] = eval[1][2];
              }
            else
              {
               i1      = pdim*sw1;
               vec[0] = tan[i1+0];
               vec[1] = tan[i1+1];
               if (pdim == 2)
                 {
                  vec[2] = 0.0;
                 }
               else
                 {
                  vec[2] = tan[i1+2];
                 }
              }
            dl   = deriv1[i1]*deriv1[i1] + deriv1[i1+1]*deriv1[i1+1];
            dl  += deriv1[i1+2]*deriv1[i1+2];
            dotp = BSdotp (rc, vec, &eval[2][0]);
            if (pdim == 2)
              j  = 2;
            else
              j  = 3;
            deriv2[j+0]  = dotp*vec[0] + curv[j+0]*dl;
            deriv2[j+1]  = dotp*vec[1] + curv[j+1]*dl;
            if (pdim ==  3)
              deriv2[j+2]= dotp*vec[2] + curv[j+2]*dl;
           }
        }
     }

/***************************************************************************
*
*        Compute the solution
*
****************************************************************************/

   *rc = BSSUCC;

   TWlsqweccv ( num_pts,    pdim,      pts,    order, num_poles,   knots,
                    par, num_fix,     pfix, num_der1,      ptan,  deriv1,
               opt_der2,  deriv2, num_wgts,    pwgts,      wgts, opt_end, 
                 opt_sm,  smfac1,      crv,      rc);

   goto wrapup;

/****************************************************************************
 * 
 *  Error return
 *
*/
nomem:
   *rc  = BSNOSTKMEMORY;    
   goto wrapup;


/****************************************************************************
 *
 *  Wrapup and Return
 *
*/
wrapup:

   if (wrkarea)
     BSstackdealloc ((char *) wrkarea);

/*
 *   Return
*/
   if (BSERROR (*rc))   BSdbgrc (*rc, "TWlsqweccv");
   return;
}

