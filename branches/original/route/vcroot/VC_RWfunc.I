
/* $Id: VC_RWfunc.I,v 1.1.1.1 2001/01/04 21:12:37 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcroot/VC_RWfunc.I
 *
 * Description:
 *      Raceway trace functions
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VC_RWfunc.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.7  1997/08/12  21:52:10  pinnacle
# Replaced: vcroot/VC_RWfunc.I for:  by hverstee for cabling
#
# Revision 1.6  1997/07/14  21:58:38  pinnacle
# Replaced: vcroot/VC_RWfunc.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  16:06:34  pinnacle
# Replaced: vcroot/VC_RWfunc.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/06  22:33:32  pinnacle
# Replaced: vcroot/VC_RWfunc.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/26  16:55:30  pinnacle
# Replaced: vcroot/VC_RWfunc.I for:  by hverstee for cabling
#
# Revision 1.2  1996/11/19  14:24:40  pinnacle
# Replaced: vcroot/VC_RWfunc.I for:  by hverstee for cabling
#
# Revision 1.1  1996/11/15  19:09:50  pinnacle
# Created: vcroot/VC_RWfunc.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCproto.h"

/*      This functionality was moved to ROUTE -- see VRtracer   */

#ifdef     OBSOLETE

#include "VRtracer.h"

#include "VDmem.h"

#include "bsdistptpt.h"


static
struct VR_tracerec   *TracLoc;

static IGRint         nBuf;
static IGRshort       nTrLoc;

static IGRboolean     bPATH;    /*   looking for a path....    */
static IGRboolean     bBR;      /*   branches found            */

static   int     iisafe;   /* safeguard against wild recursion   */

/*
#define MY_DEBUG 
*/

/***********  EXTERN ***********/

from  NDnode    import  NDget_objects;

from  VRGeneric import  VRGetCorrections;
from  VRGeneric import  VRGetNumberOfCpts;

from  VRCorrection import  VRGetCptIndex;



extern
IGRint     VC_RWthru  (IGRlong       *msg,
                struct GRid          *CompIn,
                struct GRid          *CorrIn,
                       IGRshort      *nNum,
                       IGRshort      *nCPin,
                       IGRshort      *nCPout,
                struct GRid          *Correct,
                struct GRid          *CompOut,
                struct GRmd_env      *md_env)
{

  IGRint       status;
  IGRlong      retmsg;
  IGRint       nNB, iNB;
  IGRint       i, j;
  IGRshort     i1CP, i2CP;

  struct GRid  CrrArr[VRT_MAX_FANOUT];
  struct GRid  CmpArr[VRT_MAX_FANOUT];
  struct GRid  Corr;
  struct GRmd_env   *envdum;

  *nNum = 0;
  *msg  = MSSUCC;

  envdum = md_env;    /* compiler warning    */

#ifdef MY_DEBUG
/*
  printf ("RWthru from <%d %d>, ref <%d %d>\n",CompIn->objid,CompIn->osnum,
                                               CorrIn->objid,CorrIn->osnum);
*/
#endif

  status =
  om$send (msg = message VRGeneric.VRGetCorrections
                                   (&retmsg, VRT_MAX_FANOUT, CrrArr, &nNB),
      senderid = NULL_OBJID,
      targetid = CompIn->objid,
      targetos = CompIn->osnum);

  for (i=0; i<nNB; i++)
  {
    if ((CrrArr[i].objid == CorrIn->objid) &&
        (CrrArr[i].osnum == CorrIn->osnum))       continue;

    status =
    om$send (msg = message NDnode.NDget_objects
                                  ( ND_ROOT, CmpArr, VRT_MAX_FANOUT,
                                     NULL, 0, OM_K_MAXINT, &iNB),
        senderid = NULL_OBJID,
        targetid = CrrArr[i].objid,
        targetos = CrrArr[i].osnum);

    for (j=0; j<iNB; j++)
    {
      if ((CmpArr[j].objid == CompIn->objid) &&
          (CmpArr[j].osnum == CompIn->osnum))        continue;

#ifdef MY_DEBUG
/*
      printf (" corr %d <%d %d> comp %d <%d %d>\n", i,
                     CrrArr[i].objid, CrrArr[i].osnum, j,
                     CmpArr[j].objid, CmpArr[j].osnum);
*/
#endif

      Corr = CrrArr[i];

      status =
      om$send (msg = message VRCorrection.VRGetCptIndex
                                 (&retmsg, CompIn, &i1CP),
          senderid = NULL_OBJID,
          targetid = CrrArr[i].objid,
          targetos = CrrArr[i].osnum);

      status =
      om$send (msg = message VRCorrection.VRGetCptIndex
                                 (&retmsg, &CmpArr[j], &i2CP),
          senderid = NULL_OBJID,
          targetid = CrrArr[i].objid,
          targetos = CrrArr[i].osnum);

#ifdef MY_DEBUG
/*
  printf ("Corr and cpts <%d %d> %d %d\n",
                    CrrArr[i].objid, CrrArr[i].osnum, i1CP, i2CP);
*/
#endif

      if (CompOut)
        CompOut[*nNum] = CmpArr[j];

      if (Correct)
        Correct[*nNum] = CrrArr[i];

      if (nCPin)
        nCPin[*nNum] = i1CP;

      if (nCPout)
        nCPout[*nNum] = i2CP;

      (*nNum)++;
    }
  }

#ifdef MY_DEBUG

  for (i=0; i<*nNum; i++)
  {
    printf ("THRU out %d",i);

    if (CompOut)
      printf (" <%d %d> \n",CompOut[i].objid, CompOut[i].osnum);
    else
      printf ("\n");
  }
#endif

  return (OM_S_SUCCESS);
}




static
IGRint  VC_rw_trace_rec (IGRlong     *msg,
                  struct GRid        *ConEnd,
                         IGRboolean  *bOK,
                  struct GRmd_env    *md_env)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        nPos;
  IGRshort        i, k;
  IGRshort        nll;

  IGRshort        iCin[VRT_MAX_FANOUT];
  IGRshort        iCot[VRT_MAX_FANOUT];

  struct GRid     TracCono[VRT_MAX_FANOUT];
  struct GRid     TracCoro[VRT_MAX_FANOUT];

  nll = nTrLoc -1;

  iisafe++;
  if (iisafe >= VRT_MAX_RECURSE) return (OM_E_NODYNMEM);

#ifdef MY_DEBUG
/*
  printf ("recurse %d iisafe %d \n",nTrLoc, iisafe);
  printf (" current last tracloc grid <%d %d>\n",
                    TracLoc[nll].Comp.objid, TracLoc[nll].Comp.osnum);
*/
#endif

  /*   increment buffer if needed    */

  if (nTrLoc >= nBuf)
  {
    nBuf += VRT_TRACE_INCBUF;

    TracLoc = _REALLOC (TracLoc, nBuf, struct VR_tracerec);

    if (TracLoc == 0)
    {
      nTrLoc = 0;
      return (OM_E_NODYNMEM);
    }
  }

  status =
  VC_RWthru (&retmsg, &TracLoc[nll].Comp, &TracLoc[nll].Corr,
               &nPos, iCin, iCot, TracCoro, TracCono, md_env);

  if (nPos > 1) bBR = TRUE;

  for (i=0; i<nPos; i++)
  {
    IGRint    NumCP;

    /*   block loops..... */
    for (k=0; k<nTrLoc; k++)
    {
      if ((TracCono[i].objid == TracLoc[k].Comp.objid) &&
          (TracCono[i].osnum == TracLoc[k].Comp.osnum)) goto BYPASS;
    }

    /*  check for unused connectpoints at branches    */

    status =
    om$send (msg = message VRGeneric.VRGetNumberOfCpts
                                (&retmsg, &NumCP, md_env),
        senderid = NULL_OBJID,
        targetid = TracCono[i].objid,
        targetos = TracCono[i].osnum);

    if (NumCP > 2) bBR = TRUE;

    TracLoc[nTrLoc].Comp = TracCono[i];
    TracLoc[nTrLoc].Corr = TracCoro[i];
    TracLoc[nTrLoc].nCPfrom  = iCot[i];
    TracLoc[nTrLoc-1].nCPto  = iCin[i];

#ifdef MY_DEBUG
    printf ("REC %d comp, corr, cin,cout <%d %d> <%d %d> %d %d\n",nTrLoc,
                    TracLoc[nTrLoc].Comp.objid, TracLoc[nTrLoc].Comp.osnum,
                    TracLoc[nTrLoc].Corr.objid, TracLoc[nTrLoc].Corr.osnum,
                    TracLoc[nTrLoc].nCPfrom, TracLoc[nTrLoc].nCPto);
#endif

    (nTrLoc)++;

    if ((TracCono[i].objid == ConEnd->objid) &&
        (TracCono[i].osnum == ConEnd->osnum))
    {
      *msg = MSSUCC;
      *bOK = TRUE;
#ifdef MY_DEBUG
      printf ("Normal end recursion at %d\n", (nTrLoc));
#endif

      return (OM_S_SUCCESS);
    }
    else
    {
      status =
      VC_rw_trace_rec (msg, ConEnd, bOK, md_env);
 
      if (*bOK) return (status);

      if ((!(*bOK)) && bPATH)
      {
#ifdef MY_DEBUG
         printf ("different path, back at %d\n", (nTrLoc));
#endif

         nTrLoc--;
      }
    }

    BYPASS:
    if (!(status & OM_S_SUCCESS)) break;
  }

  return (status);
}



extern
IGRint  VC_rw_trace  (IGRlong        *msg,
               struct GRid           *ConId,
               struct GRid           *ConEnd,
                      IGRshort       *nTrac,
               struct VR_tracerec   **TracTab,
                      IGRboolean     *bBranched,
               struct GRmd_env       *md_env)

{
  IGRint          status;
  IGRlong         retmsg;
  IGRint          NumCP;
  IGRboolean      bOK;
  IGRshort        nPos;
  IGRshort        i;

  IGRshort        iCin[VRT_MAX_FANOUT];
  IGRshort        iCot[VRT_MAX_FANOUT];

  struct GRid     TracCono[VRT_MAX_FANOUT];
  struct GRid     TracCoro[VRT_MAX_FANOUT];

  *msg   = MSFAIL;
  bOK    = FALSE;
  bPATH  = (ConEnd->objid != NULL_OBJID);
  iisafe = 0;

  /*    Free first???  */

  nTrLoc  = *nTrac = 0;
  nBuf    = VRT_TRACE_INCBUF;
  TracLoc = _MALLOC (nBuf, struct VR_tracerec);

  if (TracLoc == NULL) return (OM_E_NODYNMEM);

  status =
  om$send (msg = message VRGeneric.VRGetNumberOfCpts
                                (&retmsg, &NumCP, md_env),
      senderid = NULL_OBJID,
      targetid = ConId->objid,
      targetos = ConId->osnum);

  bBR = (NumCP > 2);

  TracLoc[nTrLoc].Comp  = *ConId;
  TracLoc[nTrLoc].Corr.objid = NULL_OBJID;
  TracLoc[nTrLoc].Corr.osnum = ConId->osnum;
  TracLoc[nTrLoc].nCPfrom = 0;

  nTrLoc++;

  status =
  VC_RWthru (&retmsg, ConId, &TracLoc[nTrLoc-1].Corr,
              &nPos, iCin, iCot, TracCoro, TracCono, md_env);

  if (nPos > 1) bBR = TRUE;

  for (i=0; i<nPos; i++)
  {
    /*  check for unused connectpoints at branches    */

    status =
    om$send (msg = message VRGeneric.VRGetNumberOfCpts
                                (&retmsg, &NumCP, md_env),
        senderid = NULL_OBJID,
        targetid = TracCono[i].objid,
        targetos = TracCono[i].osnum);

    if (NumCP > 2) bBR = TRUE;

    TracLoc[nTrLoc].Comp     = TracCono[i];
    TracLoc[nTrLoc].Corr     = TracCoro[i];
    TracLoc[nTrLoc].nCPfrom  = iCot[i];
    TracLoc[nTrLoc-1].nCPto  = iCin[i];

#ifdef MY_DEBUG
    printf ("BASE %d comp, corr, cin,cout <%d %d> <%d %d> %d %d\n",nTrLoc,
                    TracLoc[nTrLoc].Comp.objid, TracLoc[nTrLoc].Comp.osnum,
                    TracLoc[nTrLoc].Corr.objid, TracLoc[nTrLoc].Corr.osnum,
                    TracLoc[nTrLoc].nCPfrom, TracLoc[nTrLoc].nCPto);
#endif

    nTrLoc++;

    status =
    VC_rw_trace_rec (msg, ConEnd, &bOK, md_env);

    if (!(status & OM_S_SUCCESS)) break;

    if (bOK) break;
  }

  /*   set exit cpt of trace    */
  TracLoc[nTrLoc-1].nCPto  = 0;

  *nTrac     = nTrLoc;
  *TracTab   = TracLoc;
  *bBranched = bBR;

  return (status);
}
#endif


end implementation Root;

