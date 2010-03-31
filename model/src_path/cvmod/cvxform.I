/*
  OVERVIEW

  This file consists of functions related to transforming Curve Entities.


  HISTORY

  Satya    : 12/01/96  :  Creation
*/

class implementation GRbspline;

#include "marptsxfo.h"
#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"

PWresult pwTransformBspline
(
  PWmatrix trans_mat,
  struct IGRbsp_curve *cvin,
  struct IGRbsp_curve *cvout
)
{
   PWresult PWsts = PW_K_Success;
   long OMmsg;
 
   MArptsxform (&OMmsg, &cvin->num_poles, &cvin->rational, cvin->weights,
               trans_mat, cvin->poles, cvout->poles);
   OnErrorState( !(1&OMmsg), PWsts,
             SetError( PW_K_Pathway, PW_K_Error), wrapup);

wrapup:
   PW_Wrapup (PWsts, "pwTransformBspline");
   return (PWsts);
}
 
end implementation GRbspline;
