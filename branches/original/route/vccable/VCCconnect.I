
/* $Id: VCCconnect.I,v 1.3 2002/05/08 15:48:22 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCTconnect.I
 *
 * Description:
 *
 *      Methods to manage connectivity for cables
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCconnect.I,v $
 *      Revision 1.3  2002/05/08 15:48:22  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.2  2001/02/20 01:08:45  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/04/01  19:44:46  pinnacle
# Replaced: vccable/VCCconnect.I for:  by kddinov for route
#
# Revision 1.3  1997/12/19  16:44:46  pinnacle
# Replaced: vccable/VCCconnect.I for:  by kddinov for route
#
# Revision 1.7  1997/11/17  23:43:44  pinnacle
# Replaced: vccable/VCCconnect.I for:  by kddinov for cabling
#
# Revision 1.6  1997/08/15  12:44:20  pinnacle
# Replaced: vccable/VCCconnect.I for:  by hverstee for cabling
#
# Revision 1.5  1997/07/15  21:26:08  pinnacle
# Replaced: vccable/VCCconnect.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/06  22:54:02  pinnacle
# Replaced: vccable/VCCconnect.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/18  18:48:30  pinnacle
# Replaced: vccable/VCCconnect.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:43:04  pinnacle
# Replaced: vccable/VCCconnect.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:47:14  pinnacle
# Created: vccable/VCCconnect.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
#define  MY_DEBUG	1
*/

#include "VDmem.h"
#include "VCproto.h"
#include "vrdbgmacros.h"


struct  VCAutoSig
{
   IGRchar     szSig1[VC_MAX_SIG_ID];
   IGRchar     szSig2[VC_MAX_SIG_ID];
};


method  VCConnect(IGRlong         *msg;
                  IGRshort         num;
           struct VCpos           *ConId;
           struct VCpos           *OConId;
           struct GRid            *OGRid)
{
  IGRshort        i, j;
  IGRshort        iNo;
  IGRshort        nCpt;

SetProc(VCCable_VCConnect ); Begin

  *msg = MSFAIL;
  if (num <= 0) return (OM_S_SUCCESS);

  if ((ConId == NULL) || (OConId == NULL) ||
      (OGRid == NULL))  return (OM_E_INVARG);

  iNo = om$dimension_of (varray = me->Connect_Data);

  for (i=0; i<num; i++)
  {
    nCpt = ConId[i].Conn.Cable.nCpt;

    if ((nCpt < 0) || (nCpt > 1)) return (OM_E_INVARG);

    for (j=0; j<iNo; j++)
    {
      if (me->Connect_Data[j].nEndStat[nCpt] & VC_CBE_PASSTHRU) continue;

      if (strcmp (ConId[i].Conn.Cable.szLeadId,
                  me->Connect_Data[j].LeadNam) == 0)
      {
        strcpy (me->Connect_Data[j].FibEnds[nCpt].szModId,
                OConId[i].Conn.Term.szModId);
        strcpy (me->Connect_Data[j].FibEnds[nCpt].szPosId,
                OConId[i].Conn.Term.szPosId);
        me->Connect_Data[j].nEndStat[nCpt] = VC_CBE_CONNECTED;
      }
    }
  }

  *msg = MSSUCC;

End;
  return (OM_S_SUCCESS);
}

method  VCConDisc(IGRlong         *msg;
                  IGRshort         num;
           struct VCpos           *ConId;
           struct VCpos           *OConId;
           struct GRid            *OGRid)
{
  IGRshort        i, j;
  IGRshort        iNo;
  IGRshort        nCpt;

SetProc(VCCable_VCConDisc ); Begin

  *msg = MSFAIL;
  if (num <= 0) return (OM_S_SUCCESS);

  if (ConId == NULL)  return (OM_E_INVARG);

  iNo = om$dimension_of (varray = me->Connect_Data);

  for (i=0; i<num; i++)
  {
    nCpt = ConId[i].Conn.Cable.nCpt;
    if ((nCpt < 0) || (nCpt > 1)) return (OM_E_INVARG);

    for (j=0; j<iNo; j++)
    {
      if (me->Connect_Data[j].nEndStat[nCpt] & VC_CBE_PASSTHRU) continue;

      if (strcmp (ConId[i].Conn.Cable.szLeadId,
                  me->Connect_Data[j].LeadNam) == 0)
      {
        me->Connect_Data[j].FibEnds[nCpt].szModId[0] = '\0';
        me->Connect_Data[j].FibEnds[nCpt].szPosId[0] = '\0';
        me->Connect_Data[j].nEndStat[nCpt] = VC_CBE_OPEN;
      }
    }
  }

  *msg = MSSUCC;

End;
  return (OM_S_SUCCESS);
}

method  VCConDscall (IGRlong        *msg;
                     IGRshort        nCpt)
{
  IGRshort        j;
  IGRshort        iNo;

SetProc(VCCable_VCConDscall ); Begin

  *msg = MSSUCC;

  if ((nCpt < 0) || (nCpt > 1)) return (OM_E_INVARG);

  iNo = om$dimension_of (varray = me->Connect_Data);

  for (j=0; j<iNo; j++)
  {
    if (me->Connect_Data[j].nEndStat[nCpt] & VC_CBE_PASSTHRU) continue;

    me->Connect_Data[j].FibEnds[nCpt].szModId[0] = '\0';
    me->Connect_Data[j].FibEnds[nCpt].szPosId[0] = '\0';
    me->Connect_Data[j].nEndStat[nCpt] = VC_CBE_OPEN;
  }

End;
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
  IGRlong         retmsg;
  IGRint          status;
  IGRshort        j;
  IGRshort        iNo;

  struct GRid    Term;

SetProc(VCCable_VCConList ); Begin

  *msg  = MSFAIL;
  *nPos = 0;

  if ((nCpt < 0) || (nCpt > 1)) return (OM_E_INVARG);

  status =
  om$send (msg = message VCCable.VCCbTerm (&retmsg, nCpt, &Term),
      targetid = my_id);

  iNo = om$dimension_of (varray = me->Connect_Data);

#ifdef MY_DEBUG
  printf (" cable has %d leads\n",iNo);
#endif

  for (j=0; j<iNo; j++)
  {
#ifdef MY_DEBUG
  printf (" transitions: %x %x\n",nTrans, me->Connect_Data[j].nEndStat[nCpt]);
#endif

    if (!(nTrans & me->Connect_Data[j].nEndStat[nCpt])) continue;

    if (nStates)    nStates[*nPos] = me->Connect_Data[j].nEndStat[nCpt];

    if (PosTab)
    {
      PosTab[*nPos].nType = VC_CABLE_TYPE;

      /* KDD 11-97 Initialize */
      PosTab[*nPos].Conn.Cable.szLeadId[0] = '\0';
      PosTab[*nPos].Conn.Cable.bPass = FALSE;

      strcpy (PosTab[*nPos].Conn.Cable.szLeadId,
              me->Connect_Data[j].LeadNam);

      PosTab[*nPos].Conn.Cable.nCpt = nCpt;
    }

    if (PosOth)
    {
      /* KDD 11-97 Initialize */
      PosOth[*nPos].Conn.Term.szModId[nCpt] = '\0'; 
      PosOth[*nPos].Conn.Term.szPosId[nCpt] = '\0'; 

      if (me->Connect_Data[j].nEndStat[nCpt] & VC_CBE_CONNECTED)
      {
        PosOth[*nPos].nType = VC_TERM_TYPE;

        strcpy (PosOth[*nPos].Conn.Term.szModId,
                me->Connect_Data[j].FibEnds[nCpt].szModId);
        strcpy (PosOth[*nPos].Conn.Term.szPosId,
                me->Connect_Data[j].FibEnds[nCpt].szPosId);
      }
      else
      {
        PosOth[*nPos].nType = VC_UNKNOWN;
      }
    }

    if (PosGRid)
      PosGRid[*nPos] = Term;

    (*nPos)++;
  }

  *msg = MSSUCC;

End;
  return (OM_S_SUCCESS);
}

method  VCCbAutoCon (IGRlong     *msg;
                     IGRshort     nCpt)
{
  IGRint       status;
  IGRlong      retmsg;

  struct GRid  Term;

SetProc(VCCable_VCCbAutoCon ); Begin

  *msg = MSSUCC;

  status =
  om$send (msg = message VCCable.VCCbTerm (&retmsg, nCpt, &Term),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" Autoconnect term <%d %d>\n",Term.objid,Term.osnum);
#endif

  if (Term.objid != NULL_OBJID)
  {
    IGRshort     nTab, nEnt;
    IGRshort     nLD;
    IGRshort     i, j;

    struct VClayout   *Layout;
    struct VCAutoSig  *Stab;
    struct VCpos       MyPos;

    status =
    om$send (msg = message VCDB.VCGetLayout
                                (&retmsg, NULL, &nEnt, &nTab, NULL),
        targetid = Term.objid,
        targetos = Term.osnum);

    Layout = _MALLOC (nTab, struct VClayout);
    Stab   = _MALLOC (nTab, struct VCAutoSig);

    status =
    om$send (msg = message VCDB.VCGetLayout
                                (&retmsg, NULL, &nEnt, &nTab, Layout),
        targetid = Term.objid,
        targetos = Term.osnum);

    for (i=0; i<nTab; i++)
    {
      VC_INITSTR (Stab[i].szSig1);
      VC_INITSTR (Stab[i].szSig2);

      if (Layout[i].pDef.nType == VC_TERM_TYPE)
      {
        status =
        om$send (msg = message VCCon.VCGetSignal
                     (&retmsg, &Layout[i].pDef, Stab[i].szSig1),
          targetid = Term.objid,
          targetos = Term.osnum);
      }

      if (Layout[i].pAlt.nType == VC_TERM_TYPE)
      {
        status =
        om$send (msg = message VCCon.VCGetSignal
                     (&retmsg, &Layout[i].pAlt, Stab[i].szSig2),
          targetid = Term.objid,
          targetos = Term.osnum);
      }
#ifdef MY_DEBUG
      printf (" termsignals %s - %s\n",Stab[i].szSig1,Stab[i].szSig2);
#endif
    }

    nLD = om$dimension_of (varray = me->Connect_Data);

    for (i=0; i<nLD; i++)
    {
      if (!(me->Connect_Data[i].nEndStat[nCpt] & VC_CBE_OPEN)) continue;
      if (VC_EMPTYSTR(me->Connect_Data[i].SigNam))             continue;

      MyPos.Conn.Cable.nCpt = nCpt;
      strcpy (MyPos.Conn.Cable.szLeadId, me->Connect_Data[i].LeadNam);

#ifdef MY_DEBUG
      printf (" empty lead %s signal %s\n",me->Connect_Data[i].LeadNam,
                                           me->Connect_Data[i].SigNam);
#endif

      for (j=0; j<nTab; j++)
      {
        /*   for now, we don't autoconnect thruconnect topology
             (which side do we connect ????)                      */

        if (Layout[j].nTOPO == VC_TOPO_TIC)     continue;

        if (strcmp (me->Connect_Data[i].SigNam, Stab[j].szSig1) == 0)
        {
          status =
          om$send (msg = message VCCon.VCConnect
                     (&retmsg, (IGRshort) 1, &MyPos, &Layout[i].pDef, &Term),
              targetid = my_id);
#ifdef MY_DEBUG
          printf (" CONNECTED\n");
#endif
        }

        if (strcmp (me->Connect_Data[i].SigNam, Stab[j].szSig2) == 0)
        {
          status =
          om$send (msg = message VCCon.VCConnect
                     (&retmsg, (IGRshort) 1, &MyPos, &Layout[i].pAlt, &Term),
              targetid = my_id);
#ifdef MY_DEBUG
          printf (" CONNECTED\n");
#endif
        }
      }
    }

    _FREE (Layout);
    _FREE (Stab);
  }

End;
  return (OM_S_SUCCESS);
}

end implementation VCCable;

