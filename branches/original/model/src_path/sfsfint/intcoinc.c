#include<stdio.h>
#include<math.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWattrib.h"
#include "PWattribid.h"
#include<OMminimum.h>
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "bsgeom_cvsf.h"
#include "msdef.h"
#include "ma.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"

#include "PWapi/mdstptgm.h"
#include "PWapi/changedata.h"
#include "PWapi/intcvpts.h"


PWboolean pwAreIntobjsCoinc
(
   struct EMSintobj  *p_intcv1,
   struct EMSintobj  *p_intcv2,
   double            tol
)
{
  PWresult          retval;
  long              rc;
  int               i;
  double            sqdist=0.0;
  struct PWcvpt     p_intpts[3];
  struct PWcvdata   cvdata[2];
  struct PWcvdata   *p_temp_cvdata1=NULL, *p_temp_cvdata2=NULL;
  PWpoint           minpt;
  struct PWcvparam  minpar;
  PWboolean         intobj_coinc=TRUE, free_cvdata[2];
  unsigned short    mattyp;
  PWmatrix          mat;
  PWboolean         aflag=0;
  struct GRmd_env   rfenv;

  /* Initialize */
  retval = PW_K_Success;
  for (i=0; i<=1; i++)
  {
    free_cvdata[i]=FALSE;
  }

  if(aflag = pwIsActivationOn())
  {
    pwGetActiveModuleEnv(&rfenv);
    memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
    mattyp = rfenv.md_env.matrix_type;
  }
  else
  {
    mattyp = 2;
    MAidmx (&rc, mat);
    OnErrorState (rc!=MSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }

  /*
   * Convert the input dataselect (this_uvintobj) into a PWcvdata
   * structure
   */
  retval = pwChangeEMSCvdata (&p_intcv1->this_uvintobj, &cvdata[0], 
                              mattyp, mat, &free_cvdata[0]);
  OnErrorCode (retval, wrapup);
  retval = pwChangeEMSCvdata (&p_intcv2->this_uvintobj, &cvdata[1],
                              mattyp, mat, &free_cvdata[1]);
  OnErrorCode (retval, wrapup);


  for( i=0; i<=1; i++)
  { 
    p_temp_cvdata1 = i? &cvdata[1] : &cvdata[0];
    p_temp_cvdata2 = i? &cvdata[0] : &cvdata[1];
    /*
     * Take 3 internal points on p_intcv1 and project it onto p_intcv2
     */
    retval = pwGetInternalCvPts (p_temp_cvdata1, 3, PWtopopos_middle,
                                 p_intpts);
    /* 
     * Project the 3 pts obtained above onto the other intersection and
     * get the minimum distance between this point and the projected point
     */
    for (i=0; i<3; i++)
    {
      sqdist = pwMinDistSqPtCvdata (p_intpts[i].pt, p_temp_cvdata2, minpt,
                                    &minpar);
      /*
       *  Check if the mindist returned by ptproject is within the uvtol
       */
      if (fabs (sqrt (sqdist)) > tol)
      {
        intobj_coinc = FALSE;
        goto wrapup;
      }
    }
  }
  wrapup:
  for (i=0; i<=1; i++)
  {
    if (free_cvdata[i])
    {
      pwFreeCvdata (&cvdata[i]);
    }
  }
  if ( GetCodeType( retval) == PW_K_Error )
  {
      return (FALSE);
  }
  return(intobj_coinc );
}/* end of function pwAreIntobjsCoinc */
