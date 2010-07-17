
/* $Id: VCTcondata.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTcondata.I
 *
 * Description:
 *
 *      Methods to return connectivity for terminals
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTcondata.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.6  1997/03/12  16:38:18  pinnacle
# Replaced: vcterm/VCTcondata.I for:  by hverstee for cabling
#
# Revision 1.5  1996/10/25  13:53:08  pinnacle
# Replaced: vcterm/VCTcondata.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/03  18:15:32  pinnacle
# Replaced: vcterm/VCTcondata.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/20  21:22:18  pinnacle
# Replaced: vcterm/VCTcondata.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:38:06  pinnacle
# Replaced: vcterm/VCTcondata.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:26:50  pinnacle
# Created: vcterm/VCTcondata.I by hverstee for cabling
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


method  VCGetThru (IGRlong         *msg ;
            struct VC_contrace     *ConnIn;
            struct VC_contrace     *ConnRef;
                   IGRshort        *nPos;
            struct VC_contrace     *Conn)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        i;
  IGRshort        iNo;
  IGRshort        nEnt, nLay;
  IGRchar         szMod[VC_MAX_MOD_ID];
  IGRchar         szPos[VC_MAX_POS_ID];

  struct VClayout   *Layout;
  struct VCpos      *pPos;
  struct VCpos      *qPos;
  struct GRid       *pGrid;

  *nPos = 0;
  *msg  = MSSUCC;

  strcpy (szMod, ConnIn->OutId.Conn.Term.szModId);
  strcpy (szPos, ConnIn->OutId.Conn.Term.szPosId);

  /*   First find all connecting cable leads     */

  pPos  = NULL;
  qPos  = NULL;
  pGrid = NULL;

  status =
  om$send (msg = message VCCon.VCConList 
                           (&retmsg, VC_REQ_ALL_CPT, VC_CBE_CONNECTED,
                            &iNo, NULL, NULL, NULL, NULL),
      targetid = my_id);

  if (iNo > 0)
  {
    pPos  = _MALLOC (iNo, struct VCpos);
    qPos  = _MALLOC (iNo, struct VCpos);
    pGrid = _MALLOC (iNo, struct GRid);

    status =
    om$send (msg = message VCCon.VCConList 
                           (&retmsg, VC_REQ_ALL_CPT, VC_CBE_CONNECTED,
                            &iNo, pPos, qPos, NULL, pGrid),
        targetid = my_id);

    for (i=0; i<iNo; i++)
    {
      if (!(VC_posequal (&pPos[i], &(ConnIn->OutId))))  continue;

      if ((ConnRef->GRid.objid == pGrid[i].objid) &&
          (ConnRef->GRid.osnum == pGrid[i].osnum) &&
          (VC_posequal (&(ConnRef->OutId), &qPos[i])))  continue;

      if (Conn)
      {
#ifdef MY_DEBUG
        printf ("GetThru term <%d> to cab <%d %d>\n",
                 my_id, pGrid[i].objid, pGrid[i].osnum);
#endif
        Conn[*nPos].nTrans     = VCO_CAB_CON;
        Conn[*nPos].GRid       = pGrid[i];
        Conn[*nPos].OutId      = qPos[i];
      }

      (*nPos)++;
    }

    _FREE (pPos);
    _FREE (qPos);
    _FREE (pGrid);
  }

  /*   Then find all layout driven thruconnects         */
  /*   (only when the previous ref entry was a cable)   */

  if (ConnRef->OutId.nType != VC_CABLE_TYPE) goto wrapup;

  status =
  om$send (msg = message VCDB.VCGetLayout
                                (&retmsg, szMod, &nEnt, &nLay, NULL),
      targetid = my_id);

  if (nLay > 0)
  {
    Layout = _MALLOC (nLay, struct VClayout);

    status =
    om$send (msg = message VCDB.VCGetLayout
                                  (&retmsg, szMod, &nEnt, &nLay, Layout),
        targetid = my_id);

    switch (Layout[0].nTOPO)
    {
      case VC_TOPO_TRG: /* single terminator topology,
                                      add indicator if needed */
        break;

      case VC_TOPO_TIC:
        for (i=0; i<nLay; i++)
        {
          if (strcmp (szPos, Layout[i].pDef.Conn.Term.szPosId) == 0)
          {
            if (Conn)
            {
              Conn[*nPos].OutId  = Layout[i].pAlt;
              Conn[*nPos].GRid   = ConnIn->GRid;
              Conn[*nPos].nTrans = VCO_CON_CON;
            }

            (*nPos)++;
            break;
          }

          if (strcmp (szPos, Layout[i].pAlt.Conn.Term.szPosId) == 0)
          {
            if (Conn)
            {
              Conn[*nPos].OutId  = Layout[i].pDef;
              Conn[*nPos].GRid   = ConnIn->GRid;
              Conn[*nPos].nTrans = VCO_CON_CON;
            }

            (*nPos)++;
            break;
          }
        }

        /*    should not get here !!!!!!!  */
        break;

      case VC_TOPO_TST:

        /*   star topology, see if it's fanout   */
        if (strcmp (szPos, Layout[0].pDef.Conn.Term.szPosId) == 0)
        {
          for (i=0; i<nLay; i++)
          {
            if (Conn)
            {
              Conn[*nPos].OutId  = Layout[i].pAlt;
              Conn[*nPos].GRid   = ConnIn->GRid;
              Conn[*nPos].nTrans = VCO_CON_MCON;
            }

            (*nPos)++;
          }
          break;
        }

        /*  may be coming in for a fan-in   */

        for (i=0; i<nLay; i++)
        {
          if (strcmp (szPos, Layout[i].pAlt.Conn.Term.szPosId) == 0)
          {
            if (Conn)
            {
              Conn[*nPos].OutId  = Layout[0].pDef;
              Conn[*nPos].GRid   = ConnIn->GRid;
              Conn[*nPos].nTrans = VCO_MCON_CON;
            }

            (*nPos)++;
            break;
          }
        }

        /*    should not get here !!!!!!!  */
        break;

      default:
        break;
    }

    _FREE (Layout);
  }

  wrapup:

  /*   if nothing found add a terminator    */

  if (*nPos == 0)
  {
    if (Conn)
    {
      Conn[*nPos].OutId.nType = VC_UNKNOWN;
      Conn[*nPos].GRid.objid  = NULL_OBJID;
      Conn[*nPos].nTrans      = VCO_SEPARATE;
    }

    (*nPos)++;
  }

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
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        i;
  IGRshort        nEnt, nLay;
  IGRchar         szMod[VC_MAX_MOD_ID];
  IGRchar         szPos[VC_MAX_POS_ID];
  IGRboolean      bBR1, bBR2;
  IGRshort        nTR1, nTR2;

  struct VC_contrace     AltTrace;
  struct VClayout       *Layout;
  struct VC_contrace    *Trac1, *Trac2;

  strcpy (szMod, ConId->OutId.Conn.Term.szModId);
  strcpy (szPos, ConId->OutId.Conn.Term.szPosId);

#ifdef MY_DEBUG
  printf ("GetTrace term start at %s %s\n", szMod, szPos);
#endif

  AltTrace             = *ConId;
  AltTrace.OutId.nType = VC_UNKNOWN;

  Trac1 = Trac2 = NULL;
  bBR1  = bBR2  = FALSE;
  nTR1  = nTR2  = 0;

  /*  find signal if requested    */

  if (SigId)
  {
    status =
    om$send (msg = message VCCon.VCGetSignal
                          (&retmsg, &ConId->OutId, SigId),
        targetid = my_id);
    as$status();
  }

  /*  find the terminal thruconnect (if any)    */

  status =
  om$send (msg = message VCDB.VCGetLayout
                                (&retmsg, szMod, &nEnt, &nLay, NULL),
      targetid = my_id);

  if (nLay > 0)
  {
    Layout = _MALLOC (nLay, struct VClayout);

    status =
    om$send (msg = message VCDB.VCGetLayout
                                  (&retmsg, szMod, &nEnt, &nLay, Layout),
        targetid = my_id);

    switch (Layout[0].nTOPO)
    {
      default:
      case VC_TOPO_TRG: /* single terminator topology,
                           no thruconnect possible     */
        break;

      case VC_TOPO_TIC:
        for (i=0; i<nLay; i++)
        {
          if (strcmp (szPos, Layout[i].pDef.Conn.Term.szPosId) == 0)
          {
            AltTrace.OutId.nType = VC_TERM_TYPE;
            strcpy (AltTrace.OutId.Conn.Term.szModId, szMod);
            strcpy (AltTrace.OutId.Conn.Term.szPosId,
                    Layout[i].pAlt.Conn.Term.szPosId);
            break;
          }

          if (strcmp (szPos, Layout[i].pAlt.Conn.Term.szPosId) == 0)
          {
            AltTrace.OutId.nType = VC_TERM_TYPE;
            strcpy (AltTrace.OutId.Conn.Term.szModId, szMod);
            strcpy (AltTrace.OutId.Conn.Term.szPosId,
                    Layout[i].pDef.Conn.Term.szPosId);
            break;
          }
        }
        /*    should not get here !!!!!!!  */
        break;

      case VC_TOPO_TST:

        /*   star topology, allow only fan-in..... */
        for (i=0; i<nLay; i++)
        {
          if (strcmp (szPos, Layout[i].pAlt.Conn.Term.szPosId) == 0)
          {
            AltTrace.OutId.nType = VC_TERM_TYPE;
            strcpy (AltTrace.OutId.Conn.Term.szModId, szMod);
            strcpy (AltTrace.OutId.Conn.Term.szPosId,
                    Layout[0].pDef.Conn.Term.szPosId);
            break;
          }
        }
        /*    should not get here !!!!!!!  */
        break;
    }

    _FREE (Layout);
  }

  /*   now get one or two paths     */

#ifdef MY_DEBUG
  printf ("GetTrace term to ptrc\n");
#endif

  status =
  om$send (msg = message VCCon.VCConGetPtrc
                   (msg, TransFlags, ConId, &bBR1, &nTR1, &Trac1, NULL),
      targetid = my_id);
  as$status();

  if (AltTrace.OutId.nType == VC_UNKNOWN)
  {  /*  this was an end terminal, return directly   */
    *bBranched = bBR1;
    *nTrac     = nTR1;
    *TracTab  = Trac1;
#ifdef MY_DEBUG
  printf ("GetTrace term done, from end\n");
#endif

  }
  else
  { /*  intermediate connector, find other branch   */
    IGRint               nTot;
    struct VC_contrace   *TracTot;

#ifdef MY_DEBUG
  printf ("GetTrace thruterm, second branch\n");
#endif

    status =
    om$send (msg = message VCCon.VCConGetPtrc
                     (msg, TransFlags, &AltTrace, &bBR2, &nTR2, &Trac2, NULL),
        targetid = my_id);
    as$status();

#ifdef MY_DEBUG
  printf ("Gettwo branches %d %d\n",nTR1, nTR2);
#endif

    nTot = nTR1 + nTR2;

    TracTot = _MALLOC (nTot, struct VC_contrace);

    if (TracTot == NULL)
      status = OM_E_NODYNMEM;
    else
    {
      IGRint ii;

      *nTrac = nTot;
      *bBranched = (bBR1 || bBR2);

      for (i=0; i<nTR1; i++)
        TracTot[i] = Trac1[i];

      ii = nTR1;

      for (i=(nTR2-1); i>= 0; i--)
      {
        TracTot[ii] = Trac2[i];
        ii++;
      }
    }

    *TracTab  = TracTot;

    _FREE (Trac1);
    _FREE (Trac2);
  }

  return (status);
}

end implementation VCTerm;

