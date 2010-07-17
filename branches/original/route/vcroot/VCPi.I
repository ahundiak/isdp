
/* $Id: VCPi.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCPi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCPi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.6  1997/08/15  12:40:54  pinnacle
# Replaced: vcroot/VCPi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/07/22  14:31:18  pinnacle
# Replaced: vcroot/VCPi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/04/28  21:47:22  pinnacle
# Replaced: vcroot/VCPi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:52:04  pinnacle
# Replaced: vcroot/VCPi.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/14  18:29:44  pinnacle
# Replaced: vcroot/VCPi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:11:18  pinnacle
# Created: vcroot/VCPi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class implementation VCP;

#include "bsmkvec.h"
#include "bslenvec.h"

#include "VCproto.h"

from VCRoot      import     VCGetMatrix;

/*
#define MY_DEBUG 1
*/


method VCP_init ( IGRlong         *msg; 
           struct GRid            *Copy;
           struct GRmd_env        *pModEnv)
{
  IGRint      status;

  struct   GRmd_env     *pLocmod;

  *msg    = MSSUCC;
  pLocmod = pModEnv;
  status  = om$vla_set_dimension (varray = me->VCoff, size = 0);

  if (Copy != NULL)
  {
    GRclassid      CpClass;
    IGRshort       nCPT;

    status =
    om$get_classid (objid      = Copy->objid,
                    osnum      = Copy->osnum,
                    p_classid  = &CpClass);
    if (om$is_ancestry_valid (subclassid = CpClass,
                            superclassid = OPP_VCP_class_id ) == OM_S_SUCCESS)
    {  /*    copy from another terminal.....   */
       /*    @@@@@@@@@@@@        TBD     @@@@@@@@@@@@@@@@@@@@@   */
       /*     presumably also if a virtual terminal is created   */
       /*     for a reference file. The original may have some   */
       /*     dynamic connectpoints which should not be deleted  */

      IGRlong     retmsg;
      IGRshort    nNum, i;

      struct VCP_ptmgr   VP;

      status =
      om$send (msg = message VCP.VCP_num (&retmsg, &nNum),
          targetid = Copy->objid,
          targetos = Copy->osnum);

      for (i=0; i<nNum; i++)
      {
        status =
        om$send (msg = message VCP.VCP_get (&retmsg, i, &VP),
            targetid = Copy->objid,
            targetos = Copy->osnum);

        VP.bAdded = FALSE;

        status =
        om$send (msg = message VCP.VCP_add (&retmsg, &VP,&nCPT),
            targetid = my_id);
      }
    }
    else
    {


       /*    @@@@@@@@@@@@        TBD     @@@@@@@@@@@@@@@@@@@@@   */
       /*     connectpoints embedded in macro -- load            */

    }
  }

  return (OM_S_SUCCESS);
}

method  VCP_reorg (IGRlong         *msg)
{ /*  dummy, actual implementation with the terminals ....  */

  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCP_addpt (IGRlong         *msg ;
                   IGRdouble       *dCoord;
                   IGRdouble       *dProj;
            struct GRmd_env        *md_env;
                   IGRshort        *nCpt)
{
  IGRint       status;
  IGRshort     nC;
  IGRdouble    dRefMat[16];
  IGRdouble    dOff[3];
  IGRint       Type;
  IGRshort     nVal;

  struct VCP_ptmgr   VP;

  nC = 0;

  status =
  om$send (msg = message VCRoot.VCGetMatrix (msg, nC, dRefMat, md_env),
      targetid = my_id);

  if (dProj == NULL)
  {
    Type = VC_TOFF_COORDS;
    nVal = 3;

    status =
    VC_to_offset (dRefMat, Type, nVal, dCoord, dOff);

    VP.dX = dOff[0];
    VP.dY = dOff[1];
    VP.dZ = dOff[2];

    VP.bAdded = TRUE;
    VP.bFree  = TRUE;

    VP.dOff1  = 0.0;
    VP.dOff2  = 0.0;
    VP.dOff3  = 0.0;

    status =
    om$send (msg = message VCP.VCP_add (msg, &VP, nCpt),
        targetid = my_id);
  }
  else
  {
     /*     IMPLEMENT DIRECTIONAL CONNECTPOINTS HERE      */
     /*     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      */

  }

  return (status);
}


method  VCP_add  (IGRlong         *msg ;
           struct VCP_ptmgr       *VCpm;
                  IGRshort        *nCpt)
{
  IGRshort     nEnt;
  IGRint       status;

  *msg = MSSUCC;

  nEnt  = om$dimension_of (varray = me->VCoff);
  *nCpt = nEnt + 1;

  status = om$vla_set_dimension (varray = me->VCoff, size = (*nCpt));

  me->VCoff[nEnt]  = *VCpm;
#ifdef MY_DEBUG
  printf (" Add cpt %d at %f %f %f\n",*nCpt, VCpm->dX,VCpm->dY,VCpm->dZ);
#endif

  return (OM_S_SUCCESS);
}

method  VCP_get  (IGRlong         *msg ;
                  IGRshort         nCP;
           struct VCP_ptmgr       *VCpm)
{
  IGRshort     nEnt;

  *msg = MSFAIL;

  nEnt = om$dimension_of (varray = me->VCoff);

  if ((nCP <= nEnt) && (nCP > 0))
  {
    *msg  = MSSUCC;
    *VCpm = me->VCoff[nCP-1];
  }

  return (OM_S_SUCCESS);
}


method  VCP_num  (IGRlong         *msg ;
                  IGRshort        *nCpt)
{
  *msg = MSSUCC;

  *nCpt = om$dimension_of (varray = me->VCoff);

  return (OM_S_SUCCESS);
}

method  VCP_rem (IGRlong         *msg ;
                 IGRshort         nCpt)
{
  IGRshort     nEnt;
  IGRint       status;
  IGRint       i;

  *msg = MSSUCC;

  nEnt = om$dimension_of (varray = me->VCoff);

  if ((nCpt > nEnt+1) || (nCpt < 1)) return (OM_E_INVARG);

  for (i=(nCpt-1); i < (nEnt-1); i++)
    me->VCoff[i] = me->VCoff[i+1];

  status = om$vla_set_dimension (varray = me->VCoff, size = (nEnt - 1));

  return (OM_S_SUCCESS);
}

method  VCP_calc  (IGRlong         *msg ;
                   IGRshort         nCpt;
                   IGRdouble       *dMatIn;
                   IGRdouble       *dMatOut)
{
  IGRint      status;
  IGRshort    iDim;
  IGRint      Type;
  IGRint      nEnt;
  IGRdouble   dOff[3];     /*   no vectors, only offsets           */
                           /*   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  */
                           /*   if required do orientations later  */

  /*   we default to the center (null point) without offset   */

  Type = 0;
  iDim = 0;
  nEnt = om$dimension_of (varray = me->VCoff);
  dOff[0] = dOff[1] = dOff[2] = 0.0;

  if ((nCpt > 0) && (nCpt <= nEnt))
  { /*   dynamic connectpoint, get rel offset   */
    Type = VC_TOFF_COORDS;
    iDim = 3;

    dOff[0] = me->VCoff[nCpt-1].dX;
    dOff[1] = me->VCoff[nCpt-1].dY;
    dOff[2] = me->VCoff[nCpt-1].dZ;
  }

  status = VC_to_world (dMatIn, Type, iDim, dOff, dMatOut);

  return (OM_S_SUCCESS);
}

end implementation VCP;
