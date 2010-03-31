/*
  DESCRIPTION

    This function is used to map a trim-point from one space of surface-A
    to the space of surface-B.

  HISTORY

    RV  :  Some time ago  :  Creation
    SS  :  02/01/89       :  Added the use of correlation-parameters.
    SS  :  07/06/93       :  Added the "bdrys" argument.
*/

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"

void EMmap_trim_point (msg, sf, xyz_data, uv_data, bdrys,
                       xyzpt,
		       uvpt, newxyzpt, dist)
IGRlong *msg;
struct IGRbsp_surface *sf;
struct EMSdataselect *xyz_data;
struct EMSdataselect *uv_data;
struct EMSpypoint *bdrys;
IGRdouble *xyzpt;
struct EMSpypoint *uvpt;
IGRdouble *newxyzpt, *dist;
{
  IGRboolean found;
  IGRint i;
  IGRlong stat_func, rc;
  IGRpoint pt;
  IGRdouble chttol, cktol, mdist, *uvaddr;
  enum EMSdatatype dattyp;
  extern void BScveval(), BSmdstptcv(), BSsfeval();
  extern IGRboolean EMis_geomequal_3dpt();
  extern IGRlong EMeval_data();
  extern IGRdouble BSdistptpt();
  
  stat_func = TRUE;
  *msg = EMS_S_Success;

  BSEXTRACTPAR (&rc, BSTOLCHRDHT, chttol);

  /*
   * If signinficant points have been specified, first check if the given
   * point is within tolerance of any of these. If so, then use the information
   * of this significant point (or vertex) as the output.
   */

  found = FALSE;
  if (bdrys)
    {
    cktol = 2 * chttol;
    while (!found && bdrys)
      {
      EMeval_data (&rc, NULL, xyz_data, bdrys->span_inx, bdrys->param,
       TRUE, pt);
      EMerr_hndlr (EMSerror (rc), *msg, EMS_E_Fail, ret_end);

      if (EMis_geomequal_3dpt (pt, xyzpt, cktol))
        {
        *uvpt = *bdrys;
        uvpt->info = NULL;
        uvpt->next = NULL;

        found = TRUE;
        }
      bdrys = bdrys->next;
      }
    }
 
  /*
   * If not already determined above, look for the definition of this map 
   * using the the xyz and uv data. Assume that the parameterization of the 
   * xyz and the uv data is the same.
   */

  dattyp = xyz_data->datatype;
  if (!found)
    {
    if (dattyp == EMSdata_curve3d)
      {
      BSmdstptcv(xyz_data->data.curve, xyzpt, &uvpt->param, pt, &mdist, 
       &rc);
      EMerr_hndlr(rc != BSSUCC,*msg,EMS_E_BSerror,ret_end);
      uvpt->span_inx = 0;
 
      BScveval(uv_data->data.curve, uvpt->param, 0, uvpt->point, &rc);
      EMerr_hndlr(rc != BSSUCC,*msg,EMS_E_BSerror,ret_end);   
      }
    else
      {
      EMcnvtpypts (&rc, xyz_data->data.poly, 3, 1, xyzpt, chttol, uvpt,
       &mdist);
      EMerr_hndlr(EMSerror(rc),*msg,EMS_E_Fail,ret_end);   
  
      i = uvpt->span_inx * 2;
      uvaddr = uv_data->data.poly->points;
      uvpt->point[U] = uvaddr[i] + uvpt->param * (uvaddr[i+2] - uvaddr[i]);
      uvpt->point[V] = uvaddr[i+1] + uvpt->param * (uvaddr[i+3] - uvaddr[i+1]);
      }
    uvpt->info = NULL;
    uvpt->next = NULL;
    }

  /*
   * Return other output data as required.
   */

  if (newxyzpt)
    {
    BSsfeval (sf, uvpt->point[U], uvpt->point[V], 0, newxyzpt, &rc);
    EMerr_hndlr(rc != BSSUCC,*msg,EMS_E_BSerror,ret_end);   
    }

  if (dist)
    {
    *dist = BSdistptpt(&rc, xyzpt, newxyzpt);
    EMerr_hndlr(rc != BSSUCC,*msg,EMS_E_BSerror,ret_end);   
    }

ret_end:
  EMWRAPUP (stat_func, *msg, "EMmap_trim_point");
  return;
}



