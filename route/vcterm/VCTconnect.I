
/* $Id: VCTconnect.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTconnect.I
 *
 * Description:
 *
 *      Methods to manage connectivity for terminals
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTconnect.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/07/22  07:44:02  pinnacle
# Replaced: vcterm/VCTconnect.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.4  1997/07/22  21:42:20  pinnacle
# Replaced: vcterm/VCTconnect.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/12  16:38:00  pinnacle
# Replaced: vcterm/VCTconnect.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/25  13:53:44  pinnacle
# Replaced: vcterm/VCTconnect.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:27:08  pinnacle
# Created: vcterm/VCTconnect.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCTerm;

#include  "VDmem.h"

/*
#define  MY_DEBUG
*/

method  VCConnect(IGRlong         *msg;
                  IGRshort         num;
           struct VCpos           *ConId;
           struct VCpos           *OConId;
           struct GRid            *OGRid)
{
  IGRlong         retmsg;
  IGRint          status;
  IGRshort        i;
  IGRshort        iSt, iNo;

  struct GRid     Cabgr;
  struct GRid    *meself;

  *msg = MSFAIL;
  if (num <= 0) return (OM_S_SUCCESS);

  if ((ConId == NULL) || (OConId == NULL) ||
      (OGRid == NULL))                             return (OM_E_INVARG);

  *msg = MSSUCC;
  Cabgr.objid = NULL_OBJID;

  meself = _MALLOC (num, struct GRid);

  for (i=0; i<num; i++)
  {
    meself[i].objid = my_id;
    meself[i].osnum = OM_Gw_current_OS;
  }

  iSt = 0;
  iNo = 0;

  for (i=0; i<num; i++)
  {
    if (Cabgr.objid != OGRid[i].objid)
    {
      if ((iNo > 0) || (i == (num - 1)))
      {
        status =
        om$send (msg = message VCCon.VCConnect (&retmsg, iNo,
                                     &OConId[iSt], &ConId[iSt], meself),
            targetid = Cabgr.objid,
            targetos = Cabgr.osnum);

        if (retmsg != MSSUCC) *msg = retmsg;
      }

      Cabgr.objid = OGRid[i].objid;
      Cabgr.osnum = OGRid[i].osnum;

      iSt = i;
      iNo = 0;
    }

    iNo++;
  }

  _FREE (meself);

  return (OM_S_SUCCESS);
}

method  VCConDisc(IGRlong         *msg;
                  IGRshort         num;
           struct VCpos           *ConId;
           struct VCpos           *OConId;
           struct GRid            *OGRid)
{
  IGRlong         retmsg;
  IGRint          status;
  IGRshort        i;
  IGRshort        iSt, iNo;

  struct GRid     Cabgr;
  struct GRid    *meself;

  *msg = MSFAIL;
  if (num <= 0) return (OM_S_SUCCESS);

  if ((ConId == NULL) || (OConId == NULL) ||
      (OGRid == NULL))                            return (OM_E_INVARG);

  *msg = MSSUCC;
  Cabgr.objid = NULL_OBJID;

  meself = _MALLOC (num, struct GRid);

  for (i=0; i<num; i++)
  {
    meself[i].objid = my_id;
    meself[i].osnum = OM_Gw_current_OS;
  }

  iSt = 0;
  iNo = 0;

  for (i=0; i<num; i++)
  {
    if (Cabgr.objid != OGRid[i].objid)
    {
      if ((iNo > 0) || (i == (num - 1)))
      {
        status =
        om$send (msg = message VCCon.VCConDisc (&retmsg, iNo,
                                     &OConId[iSt], &ConId[iSt], meself),
            targetid = Cabgr.objid,
            targetos = Cabgr.osnum);

        if (retmsg != MSSUCC) *msg = retmsg;
      }

      Cabgr.objid = OGRid[i].objid;
      Cabgr.osnum = OGRid[i].osnum;

      iSt = i;
      iNo = 0;
    }

    iNo++;
  }

  _FREE (meself);

  return (OM_S_SUCCESS);
}

method  VCConDscall (IGRlong        *msg;
                     IGRshort        nCpt)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     iNum, i;
  IGRshort    *iCp;

  struct GRid   *List;

  *msg = MSSUCC;

  status =
  om$send (msg = message VCRoot.VCGetTopology (&retmsg, nCpt, &iNum,
                                 NULL, NULL, NULL, NULL),
      targetid = my_id);

  if (iNum > 0)
  {
    List = _MALLOC (iNum, struct GRid);
    iCp  = _MALLOC (iNum, IGRshort);

    status =
    om$send (msg = message VCRoot.VCGetTopology (&retmsg, nCpt, &iNum,
                                 List, iCp, NULL, NULL),
        targetid = my_id);

    for (i=0; i<iNum; i++)
    {
      status =
      om$send (msg = message VCCon.VCConDscall (&retmsg, iCp[i]),
          targetid = List[i].objid,
          targetos = List[i].osnum);
    }

    _FREE (List);
    _FREE (iCp);
  }

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
  IGRshort        i;
  IGRshort        jj;
  IGRshort        iAdd;
  IGRshort        iSt, iNo;
  IGRshort       *nCPC;
  IGRshort       *nSTT;

  struct GRid    *Cables;
  struct VCpos   *Loctab;
  struct VCpos   *Locoth;
  struct GRid    *LocGR;

  *msg  = MSFAIL;
  *nPos = 0;

  Loctab = NULL;
  Locoth = NULL;
  LocGR  = NULL;
  nSTT   = NULL;

  status =
  om$send (msg = message VCRoot.VCGetTopology (&retmsg, nCpt, &iNo,
                                              NULL, NULL, NULL, NULL),
      targetid = my_id);
  if (iNo <= 0) return (OM_S_SUCCESS);

  Cables = _MALLOC (iNo, struct GRid);
  nCPC   = _MALLOC (iNo, IGRshort);

  status =
  om$send (msg = message VCRoot.VCGetTopology (&retmsg, nCpt, &iNo,
                                              Cables, nCPC, NULL, NULL),
      targetid = my_id);
#ifdef MY_DEBUG
  printf (" VCConList term - %d cables\n",iNo);
#endif

  iSt = 0;

  for (i=0; i<iNo; i++)
  {
     /* found this while fixing the TR179801132 */
     if (PosTab)  Loctab = &PosTab[iSt]; // changing PosOth->PosTab -Alwin
     if (PosOth)  Locoth = &PosOth[iSt]; // changing PosTab->PosOth -Alwin

     if (PosGRid) LocGR  = &PosGRid[iSt];
     if (nStates) nSTT   = &nStates[iSt];

     status =
     om$send (msg = message VCCon.VCConList (&retmsg, nCPC[i], nTrans, &iAdd,
                                              Loctab, Locoth, nSTT, NULL),
         targetid = Cables[i].objid,
         targetos = Cables[i].osnum);

#ifdef MY_DEBUG
  printf (" VCConList term to cable <%d %d> , %d found\n",Cables[i].objid,
                                                 Cables[i].osnum, iAdd);
#endif

     for (jj=0; jj<iAdd; jj++)
     {
       if (PosGRid)
         PosGRid[jj+iSt] = Cables[i];

#ifdef MY_DEBUG
       printf (" From Cable <%d %d>, cpt %d, termpt %d returned\n",
               Cables[i].objid,Cables[i].osnum, nCPC[i], iAdd);

#endif
     }

     iSt += iAdd;
  }

  *msg = retmsg;

  *nPos = iSt;


  _FREE (Cables);
  _FREE (nCPC);

  return (OM_S_SUCCESS);
}

end implementation VCTerm;

