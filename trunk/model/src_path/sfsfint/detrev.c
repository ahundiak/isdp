/* Includes */

#include <stdio.h>
#include <math.h>

typedef unsigned int GRobjid;
typedef short GRspacenum;

#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "bsgeom_cvsf.h"

#include "msdef.h"
#include "ma.h"

#define EMmsg_obj_include 1

#include "emsdattyp.h"
#include "emsinter.h"

#include "PWminimum.h"
#include "PWattrib.h"
#include "PWattribid.h"
#include "PWgmdata.h"
#include "PWerror.h"
#include "PWapi/edptproj.h"
#include "PWapi/changedata.h"
#include "PWapi/intcvpts.h"

#include "PWapi/edgeom.h"
#include "PWapi/edprops.h"

/* -------------------------------------------------------------------------*/
/*                              API Definition                              */
/* -------------------------------------------------------------------------*/

/*
  ABSTRACT
     Determines whether the logical flow of the input intersection curve is
     same or opposite to the logical input coincident edge direction.

  ARGUMENTS

     coinc_ed       I   Edge id of the edge which is coincident with the 
                        input intersection curve.
     intobj         I   Input intersection curve.
     uvtol          I   uv-tolerance which is required to be passed to the 
                        point project routine.

  RETURN CODE

     This function returns the following return code.

     TRUE  -  If the input intersection flows opposite to the edge flow.
     FALSE -  Otherwise

  KEYWORDS

  CAVEATS

  HISTORY
     Subhasish         Creation
*/


PWboolean  pwDetIntReversal
(
  PWobjid             coinc_ed,
  struct EMSintobj    *intobj,
  double              uvtol
)
{
  long               rc;
  unsigned int       retval;
  int                i;
  PWpoint2d          endpts[2];
  PWboolean          free_uvcvdata=FALSE, reversed=FALSE, edreversed=FALSE;
  struct PWid        edobj;
  struct PWcvpt      cvpt[2];
  struct PWcvparam   param0, param1;
  struct PWcvdata    loc_uvcvdata;
  struct PWcvpt      loc_uvcvpt[2];
  PWmatrix           mat;
  unsigned short     mattyp;
  enum PWtopopostype topopos;
  PWboolean aflag=0;
  struct GRmd_env rfenv;

  /*
   * Initialize
   */
  retval = PW_K_Success;
  loc_uvcvdata.datatype = PWcvdata_null;
  loc_uvcvpt[0].p_attrib = NULL;
  loc_uvcvpt[1].p_attrib = NULL;
  mattyp = 2;

  if(aflag = pwIsActivationOn())
  {
    pwGetActiveModuleEnv(&rfenv);
    memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
    mattyp = rfenv.md_env.matrix_type;
  }
  else
  {
    MAidmx (&rc, mat);
    OnErrorState (rc!=MSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }

  for (i=0; i<2; i++)
  {
    cvpt[i].p_attrib = NULL;
  }

  edobj.objid = coinc_ed;
  edobj.osnum = intobj->this_obj_node->this_obj.osnum;
  /****
  pwGetEdEndPts( intobj->this_uvintobj.data.object->objid,
                 intobj->this_uvintobj.data.object->osnum,
                 endpts[0], endpts[1] );
  *****/
  /*
   * Convert the dataselect to cvdata
   */
  retval = pwChangeEMSCvdata (&intobj->this_uvintobj, &loc_uvcvdata,
                              mattyp, mat, &free_uvcvdata);
  OnErrorCode (retval, wrapup);

  retval = pwGetInternalCvPts (&loc_uvcvdata, 2, PWtopopos_middle, 
                               loc_uvcvpt);
  OnErrorCode (retval, wrapup);

  for (i=0; i<2; i++)
    memcpy (endpts[i], loc_uvcvpt[i].pt, 2*sizeof (double));

  retval = pwEdPtProject (&edobj, 2, endpts, uvtol, cvpt);
  OnErrorCode (retval, wrapup);

  param0 = cvpt[0].cvparam;
  param1 = cvpt[1].cvparam;
  if (((double)(param0.spaninx) + param0.spanpar ) >
      ((double)(param1.spaninx) + param1.spanpar ))
    reversed = TRUE;

  if( intobj->reversed )
    reversed = !reversed;
  edreversed = pwIsEdRev (edobj.objid, edobj.osnum);
  if (edreversed)
    reversed = !reversed ;

  wrapup:
  for (i=0; i<2; i++)
  {
    if( cvpt[i].p_attrib )
      pwFreeAttribList( cvpt[i].p_attrib );
  }
  if (free_uvcvdata)
  {
    pwFreeCvdata (&loc_uvcvdata);
  }/* if free_uvcvdata */
  return(reversed);
}/* end of Function: DetIntReveral */
