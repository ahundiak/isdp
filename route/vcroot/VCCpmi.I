
/* $Id: VCCpmi.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCCpmi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCpmi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/08/13  14:05:30  pinnacle
# Replaced: vcroot/VCCpmi.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/06  22:33:10  pinnacle
# Replaced: vcroot/VCCpmi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:10:48  pinnacle
# Created: vcroot/VCCpmi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

/*          NOT CURRENTLY USED               */

class implementation VCCpm;

#include "bsmkvec.h"
#include "bslenvec.h"

from   VCRoot  import  VCGetMatrix;

/*
#define MY_DEBUG 1
*/


method VCp_init ( IGRlong         *msg; 
           struct GRid            *Copy;
           struct GRmd_env        *pModEnv)
{ /*     MUST BE OVERRIDDEN TO IMPLEMENT    */
  IGRint      status;
  IGRlong     retmsg;

  *msg  = MSSUCC;

  me->VCp_stat = VC_CPM_INACTIVE;
  me->VCp_half = FALSE;

  status = om$vla_set_dimension (varray = me->VCpt, size = 0);

  status = om$vla_set_dimension (varray = me->VCspread, size = 0);

  if (Copy != NULL)
  {
    IGRshort    nEnt;
    IGRshort    i;

    status =
    om$send (msg = message VCCpm.VCp_ncpt (&retmsg, &nEnt),
        targetid = Copy->objid,
        targetos = Copy->osnum);
    
    status = om$vla_set_dimension (varray = me->VCpt, size = nEnt);

    for (i=0; i<nEnt; i++)
    {
      me->VCp_stat = VC_CPM_ACTIVE;

      status =
      om$send (msg = message VCCpm.VCp_ccpt (&retmsg, i, &me->VCpt[i]),
          targetid = Copy->objid,
          targetos = Copy->osnum);
    }
  }

  return (OM_S_SUCCESS);
}

method  VCp_ccpt (IGRlong         *msg ;
                  IGRshort         nIndex;
           struct VCCpm_ptmgr     *VCpm)
{
  IGRshort    nEnt;

  nEnt = om$dimension_of (varray = me->VCpt);

  if ((nIndex>=0) && (nIndex<nEnt))
  {
    VCpm->nCp   = me->VCpt[nIndex].nCp;
    VCpm->bFree = me->VCpt[nIndex].bFree;
    VCpm->dX    = me->VCpt[nIndex].dX;
    VCpm->dY    = me->VCpt[nIndex].dY;
    VCpm->dZ    = me->VCpt[nIndex].dZ;
    VCpm->dAxy  = me->VCpt[nIndex].dAxy;
    VCpm->dAz   = me->VCpt[nIndex].dAz;
    VCpm->dOrnt = me->VCpt[nIndex].dOrnt;
  }

  return (OM_S_SUCCESS);
}



method  VCp_acpt (IGRlong         *msg ;
           struct VCCpm_ptmgr     *VCpm)
{
  IGRshort     nEnt;
  IGRint       status;

  *msg = MSSUCC;

  me->VCp_stat = VC_CPM_ACTIVE;

  nEnt = om$dimension_of (varray = me->VCpt);

  status = om$vla_set_dimension (varray = me->VCpt, size = (nEnt + 1));

  me->VCpt[nEnt].nCp    = nEnt;
  me->VCpt[nEnt].bFree  = VCpm->bFree;
  me->VCpt[nEnt].dX     = VCpm->dX;
  me->VCpt[nEnt].dY     = VCpm->dY;
  me->VCpt[nEnt].dZ     = VCpm->dZ;
  me->VCpt[nEnt].dAxy   = VCpm->dAxy;
  me->VCpt[nEnt].dAz    = VCpm->dAz;
  me->VCpt[nEnt].dOrnt  = VCpm->dOrnt;

  return (OM_S_SUCCESS);
}

method  VCp_ncpt (IGRlong         *msg ;
                  IGRshort        *nCpt)
{
  *msg = MSSUCC;

  *nCpt = om$dimension_of (varray = me->VCpt);

  return (OM_S_SUCCESS);
}

method  VCp_rcpt (IGRlong         *msg ;
                  IGRshort         nCpt)
{
  *msg = MSFAIL;

  /*   dangerous... should be implemented per case   */

  return (OM_S_SUCCESS);
}

method  VCp_gcpt  (IGRlong         *msg ;
                   IGRshort         nCpt;
                   IGRboolean      *bFree;
                   IGRdouble       *dCoord;
                   IGRdouble       *dVect;
                   IGRdouble       *dOrnt;
            struct GRmd_env        *pModEnv)
{
  IGRint       status;
  IGRshort     nEnt;
  IGRshort     lCpt;
  IGRlong      retmsg;
  IGRdouble    dRefmat[16];

  struct VCCpm_ptmgr     VCpm;
  struct VCCpm_ptmgr    *pVCpm;

  nEnt = om$dimension_of (varray = me->VCpt);

  if ((nCpt < 0) || (nCpt > 1)) lCpt = 0;
  else                          lCpt = nCpt;

  status =
  om$send (msg = message VCRoot.VCGetMatrix (&retmsg, nCpt,dRefmat,pModEnv),
      targetid = my_id);

  VCpm.nCp    = nCpt;
  VCpm.bFree  = TRUE;
  VCpm.dX     = 0.0;
  VCpm.dY     = 0.0;
  VCpm.dZ     = 0.0;
  VCpm.dAxy   = 0.0;
  VCpm.dAz    = 0.0;
  VCpm.dOrnt  = 0.0;

  if ((nCpt < 0) || ( nCpt >= nEnt))  pVCpm = &VCpm;
  else                                pVCpm = &me->VCpt[nCpt];

  if (dCoord)
  {
    dCoord[0] = dRefmat[3]  + pVCpm->dX;
    dCoord[1] = dRefmat[7]  + pVCpm->dY;
    dCoord[2] = dRefmat[11] + pVCpm->dZ;
  }

  *bFree = pVCpm->bFree;

  if (!(*bFree))
  {
    if (dVect)
    {   /* @@@@@ TBD calculate vector    */
  
    }

    if (dOrnt)
    {   /* @@@@@ TBD calculate vector    */


    }
  }

  return (OM_S_SUCCESS);
}

method  VCp_scpt  (IGRlong         *msg ;
                   IGRdouble       *dIcoord;
                   IGRshort        *nCpt;
                   IGRboolean      *bFree;
                   IGRdouble       *dCoord;
                   IGRdouble       *dVect;
                   IGRdouble       *dOrnt;
            struct GRmd_env        *pModEnv)
{
  IGRint      status;
  IGRlong     retmsg;
  IGRshort    nEnt;
  IGRshort    i;
  IGRdouble   dDist, dCalc;
  IGRdouble   dLC[3], dLV[3],dLO[3];
  IGRdouble   dVec[3];
  IGRboolean  bLfree;
  BSrc        rc;

  *msg  = MSSUCC;
  dDist = 1.0E70;

  nEnt = om$dimension_of (varray = me->VCpt);

  for (i=0; i<nEnt; i++)
  {
    status =
    om$send (msg = message VCCpm.VCp_gcpt (&retmsg, me->VCpt[i].nCp,
                                           &bLfree, dLC, dLV, dLO, pModEnv),
        targetid = my_id);

    BSmkvec ( &rc, dVec, dLC, dIcoord);
    dCalc =  BSlenvec ( &rc, dVec );

    if (dCalc < dDist)
    {
      dDist = dCalc;

      if (dCoord)
      {
        dCoord[0] = dLC[0];
        dCoord[1] = dLC[1];
        dCoord[2] = dLC[2];
      }

      if (dVect)
      {
        dVect[0]  = dLV[0];
        dVect[1]  = dLV[1];
        dVect[2]  = dLV[2];
      }

      if (dOrnt)
      {
        dOrnt[0]  = dLO[0];
        dOrnt[1]  = dLO[1];
        dOrnt[2]  = dLO[2];
      }

      if (bFree) *bFree    = bLfree;
    }
  }

  return (OM_S_SUCCESS);
}




method  VCp_gcab  (IGRlong         *msg ;
                   IGRshort         nCpt;
                   IGRshort         nCab;
                   IGRboolean      *bFree;
                   IGRdouble       *dCoord;
                   IGRdouble       *dVect;
            struct GRmd_env        *pModEnv)
{
  IGRint      status;
  IGRlong     retmsg;
  IGRshort    nEnt;
  IGRshort    i;

  IGRdouble   dLC[3];
  IGRdouble   dLV[3];
  IGRdouble   dOR[3];

  *msg  = MSSUCC;

  nEnt = om$dimension_of (varray = me->VCspread);

  status =
  om$send (msg = message VCCpm.VCp_gcpt
                           (&retmsg, nCpt, bFree, dLC, dLV, dOR, pModEnv),
      targetid = my_id);

  if (dVect && (!(*bFree)))
  {
    dVect[0] = dLV[0];
    dVect[1] = dLV[1];
    dVect[2] = dLV[2];
  }

  for (i=0; i<nEnt; i++)
  {
    if ((me->VCspread[i].nCab == nCab) &&
        (me->VCspread[i].nCpt == nCpt))
    {   /*    found cable spread  adjust coordinates */

      /* @@@@ TBD  no adjustment for now  */
      dCoord[0] = dLC[0];
      dCoord[1] = dLC[1];
      dCoord[2] = dLC[2];

      return (OM_S_SUCCESS);
    }
  }

  /*   not found, give cpt coords   */

  if (dCoord)
  {
    dCoord[0] = dLC[0];
    dCoord[1] = dLC[1];
    dCoord[2] = dLC[2];
  }

  return OM_S_SUCCESS;
}

method  VCp_acab (IGRlong         *msg ;
                  IGRshort         nCpt;
                  IGRshort         nCab)
{
  IGRshort     nEnt;
  IGRint       status;

  *msg = MSSUCC;

  nEnt = om$dimension_of (varray = me->VCspread);

  status = om$vla_set_dimension (varray = me->VCspread, size = (nEnt + 1));

  me->VCspread[nEnt].nCab = nCab;
  me->VCspread[nEnt].nCpt = nCpt;

  me->VCspread[nEnt].dAngle = 0.0;
  me->VCspread[nEnt].dDist  = 0.0;

  return (OM_S_SUCCESS);
}

method  VCp_rcab (IGRlong         *msg ;
                  IGRshort         nCpt;
                  IGRshort         nCab)
{
  IGRshort     nEnt;
  IGRshort     i, j;
  IGRint       status;

  *msg = MSFAIL;

  nEnt = om$dimension_of (varray = me->VCspread);

  for (i=0; i<nEnt; i++)
  {
    if ((me->VCspread[i].nCab == nCab) &&
        (me->VCspread[i].nCpt == nCpt))
    {
      for (j=i; j<(nEnt-1); j++)
      {
        me->VCspread[j].nCab   = me->VCspread[j+1].nCab;
        me->VCspread[j].nCpt   = me->VCspread[j+1].nCpt;
        me->VCspread[j].dAngle = me->VCspread[j+1].dAngle;
        me->VCspread[j].dDist  = me->VCspread[j+1].dDist;
      }

      status =
      om$vla_set_dimension (varray = me->VCspread, size = (nEnt - 1));

      *msg = MSSUCC;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

method  VCp_scab (IGRlong         *msg ;
                  IGRshort         nCpt;
                  IGRshort         nCab;
                  IGRdouble        dAngle;
                  IGRdouble        dDist)
{
  IGRshort     nEnt;
  IGRshort     i;

  *msg = MSFAIL;

  nEnt = om$dimension_of (varray = me->VCspread);

  for (i=0; i<nEnt; i++)
  {
    if ((me->VCspread[i].nCab == nCab) &&
        (me->VCspread[i].nCpt == nCpt))
    {
      me->VCspread[i].dAngle = dAngle;
      me->VCspread[i].dDist  = dDist;

      *msg = MSSUCC;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

end implementation VCCpm;

