
/* $Id: VCRconpath.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCRconpath.I
 *
 * Description:
 *
 *      Recursive function set to find a connectpath
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCRconpath.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.4  1997/03/19  15:52:24  pinnacle
# Replaced: vcroot/VCRconpath.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/15  19:08:50  pinnacle
# Replaced: vcroot/VCRconpath.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/25  13:48:32  pinnacle
# Replaced: vcroot/VCRconpath.I for:  by hverstee for cabling
#
# Revision 1.1  1996/10/03  18:09:06  pinnacle
# Created: vcroot/VCRconpath.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCCon;

#include  "VCproto.h"

#include  "VDmem.h"

/*
#define  MY_DEBUG
*/

static
struct VC_contrace    *TracLoc;

static IGRint         nBuf;
static IGRshort       nTrLoc;

static   int     iisafe;   /* safeguard against wild recursion   */

#define   VC_TRACE_INCBUF        100   /*  buffer increment         */
#define   VC_MAX_FANOUT           10   /*  maximum fanout per node  */
#define   VC_MAX_RECURSE        1000   /*  maximum recursion        */
                                       /*  nodes in path....        */


static
IGRint  VC_con_trace_rec (IGRlong       *msg,
                          IGRint         TransFlags,
                   struct VC_contrace   *ConEnd,
                          IGRboolean    *bOK)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        nPos;
  IGRshort        i, k;
  IGRshort        nll;

  struct VC_contrace      TracCono[VC_MAX_FANOUT];

  nll = nTrLoc -1;

  iisafe++;
  if (iisafe >= VC_MAX_RECURSE) return (OM_E_NODYNMEM);

#ifdef MY_DEBUG
  printf ("recurse %d iisafe %d \n",nTrLoc, iisafe);
  printf (" current last tracloc grid <%d %d>\n",
                    TracLoc[nll].GRid.objid, TracLoc[nll].GRid.osnum);

#endif

  /*   increment buffer if needed    */

  if (nTrLoc >= nBuf)
  {
    nBuf += VC_TRACE_INCBUF;

    TracLoc = _REALLOC (TracLoc, nBuf, struct VC_contrace);

    if (TracLoc == 0)
    {
      nTrLoc = 0;
      return (OM_E_NODYNMEM);
    }
  }

  status =
  om$send (msg = message VCCon.VCGetThru
                              (&retmsg, &TracLoc[nll], &TracLoc[nll-1],
                                &nPos, TracCono),
      senderid = NULL_OBJID,
      targetid = TracLoc[nll].GRid.objid,
      targetos = TracLoc[nll].GRid.osnum);
  as$status();

  for (i=0; i<nPos; i++)
  {
    status = OM_S_SUCCESS;

    /*   block backup..... */
    for (k=0; k<nTrLoc; k++)
      if (VC_node_equal (&TracCono[i], &TracLoc[k])) goto BYPASS;

    TracLoc[nTrLoc] = TracCono[i];
    TracLoc[nTrLoc].nIndex = 0;      /*   no branching.....    */
    (nTrLoc)++;


#ifdef MY_DEBUG
    printf ("move thru from %d %d to  %d \n",nTrLoc, nTrLoc-1, (nTrLoc));
#endif

    if (VC_node_equal (&TracCono[i], ConEnd))
    {
      *msg = MSSUCC;
      *bOK = TRUE;
#ifdef MY_DEBUG
      printf ("Normal end recursion at %d\n", (nTrLoc));
#endif

      return (OM_S_SUCCESS);
    }
    else
    if (TracCono[i].nTrans == VCO_SEPARATE)
    {
      (nTrLoc)--;
      return (OM_S_SUCCESS);
    }
    else
    {
      status =
      VC_con_trace_rec (msg, TransFlags, ConEnd, bOK);
      if (!(*bOK)) nTrLoc--;
    }

    BYPASS:;
    if (!(status & OM_S_SUCCESS)) break;
  }

  return (status);
}



extern
IGRint  VC_con_trace  (IGRlong         *msg,
                       IGRint           TransFlags,
                struct VC_contrace     *ConId,
                struct VC_contrace     *ConEnd,
                       IGRshort        *nTrac,
                struct VC_contrace    **TracTab,
                       IGRchar         *SigId)

{
  IGRint          status;
  IGRlong         retmsg;
  IGRboolean      bOK;
  IGRshort        nPos;
  IGRshort        i;

  struct VC_contrace      TracCono[VC_MAX_FANOUT];

  *msg   = MSFAIL;
  bOK    = FALSE;

#ifdef MY_DEBUG
  iisafe = 0;
#endif

  if (SigId)
  {
    status =
    om$send (msg = message VCCon.VCGetSignal
                          (&retmsg, &ConId->OutId, SigId),
        senderid = NULL_OBJID,
        targetid = ConId->GRid.objid,
        targetos = ConId->GRid.osnum);
    as$status();
#ifdef MY_DEBUG
    printf (" begin trace, sigid %s\n",SigId);
#endif
  }

  /*    Free first???  */

  nTrLoc  = *nTrac = 0;
  nBuf    = VC_TRACE_INCBUF;
  TracLoc = _MALLOC (nBuf, struct VC_contrace);

  if (TracLoc == NULL) return (OM_E_NODYNMEM);

  TracLoc[nTrLoc] = *ConId;
  TracLoc[nTrLoc].nIndex = 0;      /*   no branching.....    */
  nTrLoc++;

  status = 
  om$send (msg = message VCCon.VCGetThru
                      (&retmsg, ConId, ConId, &nPos, TracCono),
      senderid = NULL_OBJID,
      targetid = ConId->GRid.objid,
      targetos = ConId->GRid.osnum);
  as$status();

  if ((nPos == 1) && (TracCono[0].OutId.nType == VC_UNKNOWN)) goto DONE;

  for (i=0; i<nPos; i++)
  {
    TracLoc[nTrLoc] = TracCono[i];
    TracLoc[nTrLoc].nIndex = 0;      /*   no branching.....    */
    nTrLoc++;

#ifdef MY_DEBUG
    printf ("start recurse %d\n",i);
    printf ("start grids <%d %d> and <%d %d>\n",
                       TracLoc[0].GRid.objid, TracLoc[0].GRid.osnum,
                       TracLoc[1].GRid.objid, TracLoc[1].GRid.osnum);
#endif

    status =
    VC_con_trace_rec (msg, TransFlags, ConEnd, &bOK);

    if (!(status & OM_S_SUCCESS)) break;

    if (bOK) break;

    nTrLoc--;
  }

  DONE:
  *nTrac = nTrLoc;
  *TracTab = TracLoc;

  return (status);
}

end implementation VCCon;

