
/* $Id: VRCOPFunc2i.I,v 1.2 2002/04/10 15:04:37 louis Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        route/vrco/VRCOPFunc2i.I
 *
 * Description:
 *
 * Implementation file for VRCO service functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRCOPFunc2i.I,v $
 *      Revision 1.2  2002/04/10 15:04:37  louis
 *      TR5649-standardize tolerances
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/03/08  05:35:28  pinnacle
# Replaced: vrco/VRCOPFunc2i.I for:  by ashankar for route240
#
# Revision 1.5  1996/03/07  12:12:24  pinnacle
# Replaced: vrco/VRCOPFunc2i.I for:  by ashankar for route240
#
# Revision 1.4  1996/01/16  21:27:00  pinnacle
# Replaced: vrco/VRCOPFunc2i.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/04  21:41:22  pinnacle
# Replaced: vrco/VRCOPFunc2i.I for:  by hverstee for route240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/02/91          ON            New
 *      01/04/96          HV            Cleanup
 *      04/05/02          law           TR5649-standardize tolerance with
 *                                      VRGetTol
 *
 * -------------------------------------------------------------------*/

class implementation VRCOProduct;

#include "nddef.h"
#include "ndmacros.h"
#include "exmacros.h"
#include "VRco.h"
#include "VRMath.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "MS.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "VRDbParamDef.h"

#include "bsdotp.h"
#include "bslenvec.h"

%safe
#include <math.h>
%endsafe

#define AS_DEBUG

from     VRGeneric    import    VRGetNumberOfCpts;
from     VRGeneric    import    VRGetCptGeom;

/* ====================================================================    */

IGRint VRCheckSupportOrientation (IGRlong      *msg,
                           struct GRid         *pCompId,
                                  IGRdouble    *dOrientationVector,
                           struct GRmd_env     *pMdEnv)
{
  IGRint       NbCpts;
  IGRshort     j;
  IGRdouble    dCptOrientation [3], dLong;
  BSrc         rc;
  IGRlong      status;

  *msg = MSSUCC;

  /* Check length of user orientation vector */
  dLong = BSlenvec (&rc,dOrientationVector);

  if (dLong < VRGetTol(VR_DIST_TOL))
  {
    /*"Orientation vector < VR_EPSILON = %lf \n", dLong */
    *msg = BAD_ORIEN;
    return OM_S_SUCCESS;
  }

  /*| Get Number of connect points */
  status=
  om$send( msg = message VRGeneric.VRGetNumberOfCpts (msg, &NbCpts, pMdEnv),
      senderid = NULL_OBJID,
      targetid = pCompId->objid,
      targetos = pCompId->osnum);
  as$status ();

  /*********************** Check Orientation of Support **********************/

  /*| Check Orientation for total number of Connect points directions */
  /*"NbCpts Got : %d\n",NbCpts */
  for (j=0;j<NbCpts;j++)
  {
    status=
    om$send( msg = message VRGeneric.VRGetCptGeom
                             (msg, j, (IGRdouble *) NULL,
                                      dCptOrientation, (IGRdouble *) NULL,
                                      pMdEnv),
        senderid = NULL_OBJID,
        targetid = pCompId->objid,
        targetos = pCompId->osnum);
    as$status ( action = RET_STATUS );

    dLong = BSdotp (&rc,dCptOrientation,dOrientationVector);

#ifdef MY_DEBUG
    printf ("Orient (%lf,%lf,%lf) for Cpt %d\n", dCptOrientation [0],
        dCptOrientation [1],dCptOrientation [2], j);
    printf ("BSdotp = %lf\n",dLong);
#endif

 
    if (dLong  > (1-VRGetTol(VR_DOTPROD_TOL)))
    { /*| Bad Direction of Hanger */
      *msg = BAD_ORIEN;
      return OM_S_SUCCESS;
    }
  } /* end for */

  return OM_S_SUCCESS;
} /* end function VRCheckSupportOrientation */

/* ==================== VRGetParamBoxClone ============================    */
IGRint    VRGetParamBoxClone (IGRlong     *msg,
                       struct GRid        *ParamBox,
                       struct GRid        *ParamBoxCopy)
{
  IGRlong        status;

  ParamBoxCopy->objid = NULL_OBJID;
  ParamBoxCopy->osnum = ParamBox->osnum;

  status = 
  VR$ModifyCollection(  p_msg                   = msg,
                        Operation               = VR_MERGE_COLL,
                        p_InputCollectionId     = ParamBox,
                        p_OutputCollectionId    = ParamBoxCopy);
  as$status();

  return    OM_S_SUCCESS;
} /* end function VRGetParamBoxClone */

/* ==================== VRTrimRightLefSpace ===========================    */

IGRint    VRTrimRightLeftSpace (IGRchar        *szStringIn )
{
  IGRchar *pStringIn, *pStringOut, szStringOut [255];

  pStringIn = szStringIn;
  pStringOut = szStringOut;

  /* First get rid of front blank */
  while (*pStringIn == ' ' || *pStringIn == '\t')
    pStringIn++;
  strcpy (szStringOut, pStringIn);

  /* Go to the end of string */
  while (*pStringOut != 0)
    pStringOut++;

  pStringOut--;
  /* Get rid of right blank */
  while (*pStringOut == ' ' || *pStringIn == '\t')
    *pStringOut-- = 0;

  strcpy ( szStringIn, szStringOut );

  return    OM_S_SUCCESS;

} /* end function VRTrimRightLeftSpace */

/* ==================== VRGetLocatedPocketMenuName ========================= */

IGRint    VRGetLocatedPocketMenuName (IGRshort    nProduct,
                                      IGRint      nCompType,
                                      IGRint      nCompTopo,
                                      IGRchar    *PocketMenuName)
{
  strcpy( PocketMenuName, NOTDEFPKTMNU);

  switch (nProduct)
  {
    case VR_PIPING:

      switch (nCompType)
      {
        case VRP_V_PIPE_TYPE:
          break;
        case VRP_V_ELBOW_TYPE:
          strcpy (PocketMenuName,PPIPEPKTMNU);
          break;
        case VRP_V_BRANCH_TYPE:
          strcpy (PocketMenuName,PTEEPKTMNU);
          break;
        case VRP_V_REDUCER_TYPE:
          strcpy (PocketMenuName,PREDUCERPKTMNU);
          break;
        case VRP_V_VALVE_TYPE:
          strcpy (PocketMenuName,PVALVEPKTMNU);
          break;
        case VRP_V_FLANGE_TYPE:
          strcpy (PocketMenuName,PFLANGEPKTMNU);
          break;
        case VRP_V_PIPE_END_TYPE:
          strcpy (PocketMenuName,PPIPEENDSPKTMNU);
          break;
        case VRP_V_MISCELLANEOUS_TYPE:
          strcpy (PocketMenuName,PMISCPKTMNU);
          break;
        case VRP_V_BOLT_GASKET_TYPE:
          strcpy (PocketMenuName,PBOLTPKTMNU);
          break;
        case VRP_V_SPECIALITY_TYPE:
          strcpy (PocketMenuName,PSPECIALPKTMNU);
          break;
        case VRP_V_INSTRUMENT_TYPE:
          strcpy (PocketMenuName,PINSTRUPKTMNU);
          break;
        case VRP_V_BEND_TYPE:
          strcpy (PocketMenuName,PELBOWPKTMNU);
          break;
        case VRP_V_NOZZLE_TYPE:
          strcpy (PocketMenuName,PNOZZLEPKTMNU);
          break;
        case VRP_V_ECCRED_TYPE:
          strcpy (PocketMenuName,PECCREDPKTMNU);
          break;

/* titi
        case VRP_V_CONNEC_TYPE:
          strcpy (PocketMenuName,PCONNECPKTMNU);
          break;
*/

        default:
          strcpy (PocketMenuName, NOTDEFPKTMNU);
          break;

      } /* end switch VR_PIPING */
      break;

    case VR_HVAC:
    case VR_RWAY:
      switch (nCompType)
      {
        case VRH_V_DUCT_TYPE:
          strcpy (PocketMenuName, HDUCTPKTMNU);
          break;
        case VRH_V_ELBOW_BEND_TYPE:
          strcpy (PocketMenuName, HELBOWPKTMNU );
          break;
        case VRH_V_BRANCH_TYPE:
          strcpy (PocketMenuName, HTEEPKTMNU);
          break;
        case VRH_V_REDUCER_TYPE:
          strcpy (PocketMenuName, HREDUCERPKTMNU);
          break;
        case VRH_V_OFFSET_TYPE:
          strcpy (PocketMenuName, HOFFSETPKTMNU);
          break;
        case VRH_V_SIZE_TRANSITION_TYPE:
          strcpy (PocketMenuName, HTRANSITPKTMNU);
          break;
        case VRH_V_DUCT_END_TYPE:
          strcpy (PocketMenuName, HDUCTENDSPKTMNU);
          break;
        case VRH_V_SPLIT_TYPE:
          strcpy (PocketMenuName, HTEEPKTMNU);
          break;
        case VRH_V_ORIENT_TRANSITION_TYPE:
          strcpy (PocketMenuName, HORITRANSPKTMNU);
          break;
        case VRH_V_MISCELLANEOUS_TYPE:
          strcpy (PocketMenuName, HMISCPKTMNU);
          break;
        case VRH_V_SUPPORT_TYPE:
          strcpy (PocketMenuName, HSUPPORTPKTMNU);
          break;
        case VRH_V_DEVICE_TYPE:
          if (nCompTopo == VRH_V_CLOSURE_TOPO)
          {
            /* Termination device */
            strcpy (PocketMenuName, HTDEVICEPKTMNU);
          }
          else
          {
            /* Inline device */
            strcpy (PocketMenuName, HDEVICEPKTMNU);
          }
          break;

        default:
          strcpy (PocketMenuName, NOTDEFPKTMNU);
          break;
      } /* end switch */
      break;

  } /* end switch on porduct */

  /*"Located Pkt Name is <%s>\n", *PocketMenuName */
  return OM_S_SUCCESS;

}/* end function VRGetLocatedPocketMenuName */

end implementation VRCOProduct;
