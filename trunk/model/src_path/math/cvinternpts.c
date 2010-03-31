#include <math.h>
#include <alloca.h>

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "prototypes/bscvarreval.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/cvinternpts.h"
#include "PWapi/degengm.h"
#include "PWapi/cvlenquery.h"

/*
  DESCRIPTION

  The following function returns 'num_internalpts' number of points in the
  interior of the given curve. A zero-length tolerance is specified as input
  in order for this function to track degeneracies and closeness to the 
  end-points of the curve. 

  If the input curve is degenerate then the code PW_K_Degenerate is returned
  as an error.

 
  HISTORY

  SS  :  03/01/96  :  Creation
*/
  
PWresult pwGetCvdataInternalPts
(
  struct PWcvdata *cvdata,
  int num_internalpts,
  double lentol,
  struct PWcvpt *internalpts
)
{
  int num_degen_spans, i, j, k, inx, dim, numpts;
  double delta, param, *pts, *intpars;
  PWpoint intpt, *intpts;
  PWresult result=PW_K_Success;
  BSrc bsrc;
  struct PWcvparam cvpar;
  struct IGRbsp_curve *cv;
  enum PWcvdatatype cvtype;

  cvtype = cvdata->datatype;
  switch (cvtype)
  {
    case PWcvdata_py2d:
    case PWcvdata_py:
      if (cvtype == PWcvdata_py2d)
      {
        dim = 2;
        numpts = cvdata->data.py2d.num_pts;
        pts = (double *) cvdata->data.py2d.p_pts;
        num_degen_spans = pwNumDegenSpans2d (numpts, (PWpoint2d *) pts,
                           lentol);
      }
      else
      {
        dim = 3;
        numpts = cvdata->data.py.num_pts;
        pts = (double *) cvdata->data.py.p_pts;
        num_degen_spans = pwNumDegenSpans (numpts, (PWpoint *) pts,
                           lentol);
      }
      OnErrorState (num_degen_spans == numpts-1, result, 
       SetError (PW_K_Pathway, PW_K_Degenerate), wrapup);

      if (num_degen_spans)
      {
        /*
         * Since some degenerate spans have been found, the rudimentary
         * procedure to sub-divide the param-space of the curve may not
         * give good internal points. Go the hard way, dividing up the poly
         * length.
         */

        delta = pwCvdataLen (cvdata) / (num_internalpts + 1);
        for (i=0; i<num_internalpts; i++)
        {
          pwParAtCvdataLen (cvdata, delta * (i+1), &cvpar);

          result = pwPtAtParCvdata (cvdata, &cvpar, intpt);
          OnErrorCode (result, wrapup);

          pwInitCvpt (&internalpts[i], PWtopopos_middle, intpt, dim, 
           cvpar.spaninx, cvpar.spanpar, PW_K_NullObjid);
        }
      }
      else
      {
        /*
         * We can assume that the spans are well distributed. The rudimentary
         * procedure of sub-dividing the param space will work.
         */
       
        delta = (double)(numpts-1) / (double)(num_internalpts+1);
        for (i=0, j=1; i<num_internalpts; i++, j++)
        {
          inx = j * delta;
          param = j * delta - inx;
          inx *= dim;
          for (k=0; k<dim; k++)
            intpt[k] = pts[inx+k] + param * (pts[inx+k+dim] - pts[inx+k]);

          pwInitCvpt (&internalpts[i], PWtopopos_middle, intpt, dim, 
           inx, param, PW_K_NullObjid);
        }
      }
      break;

    case PWcvdata_bspcv:
    case PWcvdata_gmbspcv:
      cv = cvdata->datatype == PWcvdata_bspcv ? 
            cvdata->data.p_bspcv : cvdata->data.p_gmbspcv->bspcv;
      delta = (cv->knots[cv->num_poles] - cv->knots[cv->order -1]) /
              (num_internalpts + 1);
      intpars = (double *) alloca (num_internalpts * sizeof(double));
      for (i=0; i<num_internalpts; i++ )
        intpars[i] = cv->knots[cv->order-1] + (i+1) * delta;

      intpts = (PWpoint *) alloca (num_internalpts * sizeof (PWpoint));
      BScvarreval (&bsrc, cv, intpars, num_internalpts, 0, (double *) intpts);
      OnErrorState (bsrc != BSSUCC, result, 
       SetError (PW_K_BspMath, PW_K_Internal), wrapup);

      for (i=0; i<num_internalpts; i++)
        pwInitCvpt (&internalpts[i], PWtopopos_middle, intpts[i], 3, 
         0, intpars[i], PW_K_NullObjid);

      break;
   }
      
wrapup:     
  PW_Wrapup (result, "pwGetCvdataInternalPts");
  return (result);
}
