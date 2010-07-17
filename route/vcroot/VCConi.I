
/* $Id: VCConi.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCConi.I
 *
 * Description:
 *   This file contains the method for signal propagation
 *   All other methods must be overridden in the child classes.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCConi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.4  1997/08/13  14:03:58  pinnacle
# Replaced: vcroot/VCConi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/07/14  21:56:08  pinnacle
# Replaced: vcroot/VCConi.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/24  17:13:12  pinnacle
# Replaced: vcroot/VCConi.I for:  by hverstee for cabling
#
# Revision 1.1  1997/01/23  23:25:54  pinnacle
# Created: vcroot/VCConi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCCon;

#include "VDmem.h"

#include "VCchansel.h"

/*
#define MY_DEBUG
*/


method  VCSetSignal (IGRlong         *msg;
              struct VCpos           *ConId;
                     IGRchar         *sigid)

{
  IGRint         status;
  IGRlong        retmsg;
  IGRint         TransFlags;
  IGRshort       nTrace;
  IGRshort       i;
  IGRboolean     bBranch;

  struct VC_contrace    ConTr;
  struct VC_contrace   *TracTab;

  *msg   = MSSUCC;

  TransFlags     = (VCTR_CON_CON | VCTR_TERM_THRU);
  TracTab        = NULL;

  ConTr.OutId = *ConId;
  ConTr.nIndex = 0;
  ConTr.nTrans = 0;
  ConTr.GRid.objid = my_id;
  ConTr.GRid.osnum = OM_Gw_current_OS;

  /*    propagate through trace   */
  status =
  om$send (msg = message VCCon.VCConGetTrace
                                  (&retmsg, TransFlags, &ConTr,
                                   &bBranch, &nTrace, &TracTab, NULL),
      targetid = my_id);

  for (i=0; i<nTrace; i++)
  {
    if (TracTab[i].GRid.osnum != VC_GLB_writable_os) continue;

    if (TracTab[i].GRid.objid == NULL_OBJID)         continue;

    status =
    om$send (msg = message VCCon.VCPutSignal
                               (&retmsg, &TracTab[i].OutId, sigid),
        targetid = TracTab[i].GRid.objid,
        targetos = TracTab[i].GRid.osnum);
  }

  _FREE (TracTab);

  return (OM_S_SUCCESS);
}

method  VCConnect(IGRlong         *msg;
                  IGRshort         num;
           struct VCpos           *ConId;
           struct VCpos           *OConId;
           struct GRid            *OGRid)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCConDisc(IGRlong         *msg;
                  IGRshort         num;
           struct VCpos           *ConId;
           struct VCpos           *OConId;
           struct GRid            *OGRid)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCConDscall (IGRlong        *msg;
                     IGRshort        nCpt)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCGetSignal (IGRlong         *msg;
              struct VCpos           *ConId;
                     IGRchar         *sigid)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCPutSignal (IGRlong         *msg;
              struct VCpos           *ConId;
                     IGRchar         *sigid)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCConList (IGRlong         *msg;
                   IGRshort         nCpt;
                   IGRshort         nTrans;
                   IGRshort        *nPos;
            struct VCpos           *PosTab;
            struct VCpos           *PosOth;
                   IGRshort        *nStates;
            struct GRid            *PosGRid)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCConGet  (IGRlong         *msg;
                   IGRint           TransFlags;
            struct VCpos           *PosIn;
                   IGRshort        *nItems;
            struct VCpos           *PosOut;
            struct GRid            *OutGRid)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCPutTopo (IGRlong         *msg;
                   IGRshort         nTot;
            struct VCfullpos       *PosTab)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCGetThru (IGRlong         *msg ;
            struct VC_contrace     *ConnIn;
            struct VC_contrace     *ConnRef;
                   IGRshort        *nPos;
            struct VC_contrace     *Conn)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCConGetTrace (IGRlong         *msg ;
                       IGRint           TransFlags;
                struct VC_contrace     *ConId;
                       IGRboolean      *bBranched;
                       IGRshort        *nTrac;
                struct VC_contrace    **TracTab;
                       IGRchar         *SigId)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method  VCConGetPtrc  (IGRlong         *msg ;
                       IGRint           TransFlags;
                struct VC_contrace     *ConId;
                       IGRboolean      *bBranched;
                       IGRshort        *nTrac;
                struct VC_contrace    **TracTab;
                       IGRchar         *SigId)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

end implementation VCCon;

