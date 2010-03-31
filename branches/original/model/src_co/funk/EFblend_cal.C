/*******    name   EFblend_crval

Description

   Math routine to calculate value, 1.derivative and 2.derivative across a
   surface edge, where the surface is represented by the contol point rows
   as B-spline curves. Since the B-spline curves represent a surface, 
   information about the knots in cross direction must be provided :
   in form of "average mesh lengh", s. C. de Boor , A Practical Guide to 
   Splines, p.139.
   

History :  created 01/26/94  - GEB

Parameter description

 par                  INPUT         parameter, where to evaluate
 cont                 INPUT         0: value only
                                    1: value and 1.derivative
                                    2: value, 1. and 2.derivatives
 order                INPUT         the order cross to row
 cr_mesh              INPUT         "average mesh lengh"
                                    [0]: (knot[order] - knot[1])/(order - 1)
                                    for 2.derivative:
                                    [1]: (knot[order+1] - knot[2])/(order - 1) 
                                    [2]: (knot[order] - knot[2])/(order - 2) 

 row                  INPUT         array of pointer to rows (B-splines)
                                    row[0]: 1.row = surface boundary
                                        1   2.row (if cont > 0)
                                        2   3.row (if cont == 2)
 rational             INPUT         TRUE/FALSE

 pt                   OUTPUT        the value at par (a point)
 dpt                                1.derivative  
 ddpt                               2.derivative (set to zero if order = 2) 
 rc                   OUTPUT        The return code.
                                    BSSUCC: values were calculated
   

************************************************************************/

   #include  <stdio.h> 
   #include  <math.h>
   
   #include  "maerr.h"  

   #include  "igrtypedef.h"

   #include  "bs.h"
   #include  "bserr.h"
   #include  "bstypes.h"
   #include  "bsdefs.h"
   #include  "bsparameters.h"
 
   #include  "igr.h"   

   #define   IZERO         0
   #define   ZERO          0.0
   #define   ONE           1
   #define   ORDER_MIN     2


   IGRint EFblend_crval ( IGRdouble             par,
                          IGRint                cont,
                          IGRint                order,
                          IGRdouble             cr_mesh[3],
                          struct IGRbsp_curve   *row[3],
                          IGRboolean            rational,
                          IGRpoint              pt,
                          IGRpoint              dpt,
                          IGRpoint              ddpt,
                          BSrc                  *rc          )
   {



     # include "bscveval.h"           /*  prototype  */
     extern IGRboolean MAbcueval();

     IGRint     status;
     IGRint     j, k, nderiv;
     IGRshort   dim34;
     IGRlong    msg;

     IGRpoint   eval[3], dum;
     IGRdouble  wg[3];
     IGRdouble  fact1;


/*********     Start of executable code       *******************/


     *rc = BSSUCC;
     status = 1;

     if ( cont < 0 || cont > 2)
        {
         *rc = BSINARG;
         goto wrapup;
        }

     if ( rational )
        dim34 = 1;
     else
        dim34 = 0;

     if ( (cont == 2)  &&  (order == ORDER_MIN) )
        { 
         nderiv = 1;
         ddpt[0] = ZERO;
         ddpt[1] = ZERO;
         ddpt[2] = ZERO;
        }
     else
        nderiv = cont;

     for ( j = 0; j <= nderiv; j++ )
         {
          wg[j] = ONE;
          BScveval(*(row + j), par, IZERO, eval + j, rc);
          if ( *rc != BSSUCC ) goto wrapup;  
          if ( rational )
             status = MAbcueval(&msg, *(row + j), &dim34, &par,
                      dum, wg + j);

          if (status == FALSE)
             {
              *rc = -2;
              goto wrapup;
             }        
         }
    
     if (rational)
        fact1 = wg[1] / wg[0];
     else 
        fact1 = ONE;

     for ( k = 0; k < 3; k++ )
         {
          pt[k]  = *(*eval + k);
          if (nderiv > 0)
             {
              dpt[k] = (*(*(eval + 1) + k) - pt[k])/cr_mesh[0]; 
              dpt[k] = fact1*dpt[k];
             }
          if (nderiv > 1)
             ddpt[k] = ( (*(*(eval + 2) + k) - *(*(eval + 1) + k))/cr_mesh[1]
                        - dpt[k] ) / cr_mesh[2];  
         }


     wrapup:     
     status = 0;
     return status;             
   } 
