
/* $Id: VCCmdVXDyn.I,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdVXDyn.I
 *
 * Description:
 *
 *      Dynamics for ins/move/del vertex command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdVXDyn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/05/19  19:52:48  pinnacle
# Replaced: vccmdutil/VCCmdVXDyn.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/07  16:17:44  pinnacle
# Replaced: vccmdutil/VCCmdVXDyn.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/12  22:27:10  pinnacle
# Replaced: vccmdutil/VCCmdVXDyn.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/25  19:13:02  pinnacle
# Replaced: vccmdutil/VCCmdVXDyn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:03:16  pinnacle
# Created: vccmdutil/VCCmdVXDyn.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      07/10/96    hv          Initial
 *
 *************************************************************************/

class implementation VCCmdVX;

#include <stdio.h>
#include <float.h>

#include "FI.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMtypes.h"
#include "ODE.h"

#include "igetypedef.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "grio.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "bsvalues.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsdistptpt.h"

#include "asmacros.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "VRMcForm.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "parametric.h"

/*
#define MY_DEBUG
*/

/***************************************************************************
  Dynamics function
***************************************************************************/

IGRint VCmlmoddyn (info,point,matrix,objects,num_objects,buffers,
                 num_buffers, dummy_in1,dummy_in2,dummy_in3,dummy_out1,
                 dummy_out2, dummy_out3 )

struct          VCmlmoddyn_info  *info;
struct          EX_button        *point;
IGRdouble                        *matrix;
struct          GRid             **objects;
IGRint                           *num_objects;
struct          DPele_header     **buffers;
IGRint                           *num_buffers;
IGRchar                          *dummy_in1;
IGRchar                          *dummy_in2;
IGRchar                          *dummy_in3;
IGRchar                          **dummy_out1;
IGRchar                          **dummy_out2;
IGRchar                          **dummy_out3;

{
  IGRint       status;
  IGRdouble    dP[3];

  if (info->dynamics == VC_MLDYN_MVTX)
  {
    dP[0] = point->x;
    dP[1] = point->y;
    dP[2] = point->z;

#ifdef MY_DEBUG
    printf (" to dynamic detent\n");
#endif
    status = VC_detent (dP, &info->Detent, 
                        &info->dpele_buff.geometry.polyline->points[3]);
#ifdef MY_DEBUG
    printf (" from detent %f %f %f - %f %f %f\n",
               dP[0],dP[1], dP[2],
               info->dpele_buff.geometry.polyline->points[3],
               info->dpele_buff.geometry.polyline->points[4],
               info->dpele_buff.geometry.polyline->points[5]);
#endif

    if (info->dy_index >= 0)
    {
        if (info->dy_index > 2)
          printf ("Dynamics out of range %d!!!!!\n",info->dy_index);

        info->dpele_buff.geometry.polyline->points[info->dy_index+3]
                         = info->dy_value;
#ifdef MY_DEBUG
        printf (" adjust dyn buff, index-value %d %f\n",(info->dy_index+3),
                               info->dy_value);
#endif
    }

    *buffers = &info->dpele_buff;
    *num_buffers = 1;

  }
  else
      {    /* section  -- get rid of compiler messages    */
        IGRdouble         *Lmatrix;
        struct GRid       *Lobjects;
        IGRint            *Lnum;
        IGRchar           *Ldummy;

        Lmatrix  = matrix;
        Lobjects = *objects;
        Lnum     = num_objects;
        Ldummy   = dummy_in1;
        Ldummy   = dummy_in2;
        Ldummy   = dummy_in3;
        Ldummy   = *dummy_out1;
        Ldummy   = *dummy_out2;
        Ldummy   = *dummy_out3;
      }

  return (TRUE);
}

extern
IGRint VC_detent (IGRdouble      *dPTin,
           struct VCVX_detent    *pDet,
                  IGRdouble      *dPTout)
{
  IGRint      i;
  IGRdouble   dD;
  IGRint      isav;
  IGRdouble   dSAV;
  IGRdouble  *pD;
  BSrc        rc;

  /*   for default no detent   */

  for (i=0; i<3; i++)
    dPTout[i] = dPTin[i];

  if (pDet->NumCorners < 0)    return (OM_S_SUCCESS);

  if (pDet->NumCorners == 0)   /*   detent on line   */
  {
    isav = pDet->nDigit -1;

    for (i=0; i<3; i++)
    {
      if (i == isav) continue;

      dD  = fabs (dPTin[i] - pDet->dCorners[i]);

      if (dD < pDet->dDist) dPTout[i] = pDet->dCorners[i];
    }
  }
  else
  {
    dSAV = MAXDOUBLE;
    isav = -1;

    for (i=0; i< pDet->NumCorners; i++)
    {
      pD = (IGRdouble *) &pDet->dCorners[i*3];
      dD  = BSdistptpt (&rc, dPTin, pD);

      if (dD < dSAV)
      {
        dSAV = dD;
        isav = i;
      }
    }
#ifdef MY_DEBUG
    printf (" DETENT, snap to %d\n", isav);
#endif

    if ((isav >= 0) && (dSAV < pDet->dDist))
    {
      for (i=0; i<3; i++)
        dPTout[i] = pDet->dCorners[isav*3 + i];
    }
  }

  return (OM_S_SUCCESS);
}


end implementation VCCmdVX;

