
/* $Id: VCTconpath.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTconpath.I
 *
 * Description:
 *
 *      Method to return connectivity path
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTconpath.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/03/12  16:37:44  pinnacle
# Replaced: vcterm/VCTconpath.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/25  13:53:28  pinnacle
# Replaced: vcterm/VCTconpath.I for:  by hverstee for cabling
#
# Revision 1.1  1996/10/03  18:15:14  pinnacle
# Created: vcterm/VCTconpath.I by hverstee for cabling
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

#define   VCPATH_LOCBUF            25
#define   VCPATH_INCR             100

typedef  struct VC_contrace     *TPTR;

static
IGRint   VCP_ALLOC (IGRshort      nReq,
                    IGRshort      nFill,
                    IGRshort     *nNow,
                    TPTR         *BUF)
{
  IGRshort    nTot;
  IGRshort    nNeed;
  IGRshort    i;
  TPTR        NB;
  TPTR        XB;
  IGRboolean  bOK;

  nTot  = *nNow;
  nNeed = nReq + nFill;
  bOK   = TRUE;

  while (nNeed > nTot)
  {
    nTot += VCPATH_INCR;
    bOK   = FALSE;
  }

  if (bOK) return (OM_S_SUCCESS);

#ifdef MY_DEBUG
  printf ("P_ALLOC nTot, nNeed, nReq %d %d %d\n",nTot,nNeed, nReq);
#endif

  NB = _MALLOC (nTot, struct VC_contrace);

  if (NB == NULL)
  {
    _FREE (*BUF);
    return (OM_E_NODYNMEM);
  }

  for (i=0; i<nFill; i++)
  {
    XB = BUF[i];

    NB[i] = *XB;
  }

  _FREE (*BUF);

  *BUF = NB;
  *nNow = nTot;

#ifdef MY_DEBUG
  printf ("P_ALLOC done, buffer now %d\n",nTot);
#endif

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
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        i, j, k;
  IGRshort        nPos;
  IGRshort        nCur, nNxt;
  TPTR            pRef[VCPATH_LOCBUF];
  TPTR            pNow[VCPATH_LOCBUF];
  TPTR            qRef[VCPATH_LOCBUF];
  TPTR            qNow[VCPATH_LOCBUF];
  IGRshort        nTRAC;
  IGRshort        nFILL;
  IGRshort        nLEV;

  struct VC_contrace      TracCur;
  struct VC_contrace      TracRef;
  struct VC_contrace      TracCono[VCPATH_LOCBUF];
  struct VC_contrace     *TRAC;

#ifdef MY_DEBUG
  printf (" enter getptrc\n");
#endif

  /*   start size of buffer    */

  nLEV = 0;

  nTRAC = 0;
  nFILL = 0;
  TRAC  = NULL;

  TracCur        = *ConId;
  TracCur.nIndex = nLEV;

  nPos = 1;
  status = VCP_ALLOC (nPos, nFILL, &nTRAC, &TRAC);
  as$status(action = RET_STATUS);

  TRAC[nFILL] = TracCur;
  nFILL++;

  TracRef        = *ConId;
  TracRef.nIndex = nLEV;

  pRef[0] = &TracRef;
  pNow[0] = &TracCur;
  nCur    = 1;

#ifdef MY_DEBUG
  printf (" enter getptrc main loop\n");
#endif

  while (nCur > 0)
  {
    nNxt = 0;

    for (i=0; i<nCur; i++)
    {
      status =
      om$send (msg = message VCCon.VCGetThru
                      (&retmsg, pNow[i], pRef[i], &nPos, TracCono),
          targetid = pNow[i]->GRid.objid,
          targetos = pNow[i]->GRid.osnum);

      as$status();

      /*   check for terminator    */

#ifdef MY_DEBUG
  printf (" from gettru <%d %d> %d items out\n",pNow[i]->GRid.objid,
                   pNow[i]->GRid.osnum, nPos);
#endif

      /*   add to output if not duplicate and not end indicator  */

      status = VCP_ALLOC (nPos, nFILL, &nTRAC, &TRAC);
      as$status(action = RET_STATUS);

      if (nPos > 1) *bBranched = TRUE;

      for (j=0; j<nPos; j++)
      {
        if (TracCono[j].nTrans == VCO_SEPARATE) goto BYPASS;

        for (k=0; k<nFILL; k++)
          if (VC_node_equal (&TRAC[k], &TracCono[j])) goto BYPASS;

        if (j >= 1)
        {
          nLEV++;
          TracCono[j].nIndex = nLEV;
        }
        else
        {
          TracCono[j].nIndex = (pNow[i])->nIndex;
        }
#ifdef MY_DEBUG
        printf ("index set at %d to %d\n",nFILL, TracCono[j].nIndex);
#endif
    
        TRAC[nFILL] = TracCono[j];
        qNow[nNxt]  = &TRAC[nFILL];
        qRef[nNxt]  = pNow[i];

        nFILL++;
        nNxt++;

        BYPASS:;
      }
    }

    for (i=0; i<nNxt; i++)
    {
      pNow[i] = qNow[i];
      pRef[i] = qRef[i];
    }

    nCur = nNxt;
#ifdef MY_DEBUG
    printf (" endloop, ncur = %d\n",nCur);
#endif
  }

  if (nLEV > 0)
  {  /*   multisegmented or branched trace - sort    */
    IGRshort   i, jin, jout;
    struct VC_contrace     *ATRAC;
    
    ATRAC = _MALLOC ((nFILL + 1), struct VC_contrace);

    jout = 0;

    for (i=0; i<=nLEV; i++)
    {
      for (jin=0; jin<nFILL; jin++)
      {
        if (TRAC[jin].nIndex == i)
        {
          ATRAC[jout] = TRAC[jin];
          jout++;
        }
      }
    }

    *TracTab = ATRAC;
    _FREE (TRAC);
  }
  else
    *TracTab = TRAC;

  *nTrac   = nFILL;

  return (status);
}

end implementation VCTerm;

