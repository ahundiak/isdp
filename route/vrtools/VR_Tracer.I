
/* $Id: VR_Tracer.I,v 1.1.1.1 2001/01/04 21:13:12 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrtools/VR_Tracer.I
 *
 * Description:
 *      Route network trace functions
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VR_Tracer.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/03/11  22:59:44  pinnacle
# Replaced: vrtools/VR_Tracer.I for:  by hverstee for route
#
# Revision 1.1  1997/03/11  17:12:06  pinnacle
# Created: vrtools/VR_Tracer.I by hverstee for route
#
 *
 * History:
 *  03/07/97      hv      New
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

#include "VRtracer.h"

#include "VDmem.h"

#include "bsdistptpt.h"

/*     static variables during recursion .....    */

%safe
static
struct VR_tracerec   *TracLoc = NULL;

static IGRint         nBuf;
static IGRshort       nTrLoc;

static IGRboolean     bPATH;    /*   looking for a path....    */
static IGRboolean     bBR;      /*   branches found            */

static IGRshort       nBRctr;   /*   branch counter            */

static IGRint         iisafe;   /* safeguard against wild recursion   */
%endsafe

/*
#define MY_DEBUG 
*/

/***********  EXTERN ***********/

from  ASnode    import  ASreturn_go;

from  NDnode    import  NDget_objects;

from  VRGeneric import  VRGetCorrections;
from  VRGeneric import  VRGetNumberOfCpts;

from  VRCorrection import  VRGetCptIndex;



/*     Recursive trace function, not callable by user    */

static
IGRint  VR_trace_rec (IGRlong     *msg,
                      IGRshort     nConEnds,
               struct GRid        *ConEnd,
                      IGRboolean  *bOK,
                      IGRshort     nBRnum,
               struct GRmd_env    *md_env)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        nPos;
  IGRshort        i, k;
  IGRshort        ie;
  IGRshort        nll;
  IGRshort        nTRbranch;

  IGRshort        iCin[VRT_MAX_FANOUT];
  IGRshort        iCot[VRT_MAX_FANOUT];

  struct GRid     TracCono[VRT_MAX_FANOUT];
  struct GRid     TracCoro[VRT_MAX_FANOUT];

  nTRbranch = nll = nTrLoc -1;
  status = OM_E_NODYNMEM;

#ifdef MY_DEBUG
  /*    safeguard against runaway recursion     */
  iisafe++;
  if (iisafe >= VRT_MAX_RECURSE) goto FI_TERM;

  printf ("recurse %d iisafe %d \n",nTrLoc, iisafe);
  printf (" current last tracloc grid <%d %d>\n",
                    TracLoc[nll].Comp.objid, TracLoc[nll].Comp.osnum);
#endif

  /*   increment buffer if needed    */

  if (nTrLoc >= nBuf)
  {
    nBuf += VRT_TRACE_INCBUF;

    TracLoc = _REALLOC (TracLoc, nBuf, struct VR_tracerec);

    if (TracLoc == 0)
    {
      nTrLoc = 0;
      goto FI_TERM;
    }
  }

  /*   find (max fanout) number of connecting components   */
  status =
  VR_cmp_nxt  (&retmsg, &TracLoc[nll].Comp, &TracLoc[nll].Corr,
               &nPos, iCin, iCot, TracCoro, TracCono);

  if (nPos > 1) bBR = TRUE;

  /*   add the components to the trace    */

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
    TracLoc[nTrLoc].nBR      = nBRctr;
    TracLoc[nTrLoc].iBack    = nBRnum;

    if (i > 0)
    {
      nBRctr++;
      nBRnum = nTrLoc;
    }

#ifdef MY_DEBUG
    printf ("REC %d comp, corr, cin,cout <%d %d> <%d %d> %d %d\n",nTrLoc,
                    TracLoc[nTrLoc].Comp.objid, TracLoc[nTrLoc].Comp.osnum,
                    TracLoc[nTrLoc].Corr.objid, TracLoc[nTrLoc].Corr.osnum,
                    TracLoc[nTrLoc].nCPfrom, TracLoc[nTrLoc].nCPto);
#endif

    (nTrLoc)++;

    for (ie=0; ie<nConEnds; ie++)
    {
      if ((TracCono[i].objid == ConEnd[ie].objid) &&
          (TracCono[i].osnum == ConEnd[ie].osnum))
      {
        *msg   = MSSUCC;
        if (bPATH) *bOK   = TRUE;
        status = OM_S_SUCCESS;
        goto FI_TERM;        /*  normal termination of pathfinder   */
      }
    }

    /* No end yet, recurse further        */
    status =
    VR_trace_rec (msg, nConEnds, ConEnd, bOK, nBRnum, md_env);
 
    if (*bOK) goto FI_TERM;   /* found end of path, go up the
                                   recursive ladder                 */

    if ((!(*bOK)) && bPATH)
    {  /*   back up if we're looking for a path    */
       nTrLoc--;
    }

    BYPASS:
    if (!(status & OM_S_SUCCESS)) break;
  }

  FI_TERM:
  return (status);
}


/*     General routing network trace function     */

/*     NOTE: it is the callers responsibility to free the allocated
             memory!!!! ( = &TracTab)                                      */

extern
IGRint  VR_trace

      (IGRlong      *msg,       /*  O - return message                     */
       IGRboolean    bSpath,    /*  I - flag, look for single path         */
struct GRid         *ConId,     /*  I - start component for tracer         */
       IGRshort      nConEnds,  /*  I - number of endpoints                */
struct GRid         *ConEnd,    /*  I - (optional) ends of trace           */
       IGRshort     *nTrac,     /*  O - Number of records output           */
struct VR_tracerec **TracTab,   /*  O - Output trace table                 */
       IGRboolean   *bBranched, /*  O - Flag, branched trace found         */
struct GRmd_env     *md_env)    /*  I - environment                        */

{
  IGRint          status;
  IGRlong         retmsg;
  IGRint          NumCP;
  IGRboolean      bOK;
  IGRshort        nPos;
  IGRshort        i;
  IGRshort        nBRnum;

  IGRshort        iCin[VRT_MAX_FANOUT];
  IGRshort        iCot[VRT_MAX_FANOUT];

  struct GRid     TracCono[VRT_MAX_FANOUT];
  struct GRid     TracCoro[VRT_MAX_FANOUT];

  /*   initialize and exit if no initial memory available   */

  *msg   = MSFAIL;
  bOK    = FALSE;
  bBR    = FALSE;
  bPATH  = bSpath;
  iisafe = 0;
  nBRctr = 0;
  nBRnum = 0;
  status = OM_E_NODYNMEM;

  _FREE (TracLoc);    /*    If left from a previous call, Free first  */

  nTrLoc  = *nTrac = 0;
  nBuf    = VRT_TRACE_INCBUF;
  TracLoc = _MALLOC (nBuf, struct VR_tracerec);

  if (TracLoc == NULL) goto FI_TERM;

  /*    seed recursion with first (picked) component   */

  status =
  om$send (msg = message VRGeneric.VRGetNumberOfCpts
                                (&retmsg, &NumCP, md_env),
      senderid = NULL_OBJID,
      targetid = ConId->objid,
      targetos = ConId->osnum);

  bBR = (NumCP > 2);

  TracLoc[nTrLoc].Comp       = *ConId;
  TracLoc[nTrLoc].Corr.objid = NULL_OBJID;
  TracLoc[nTrLoc].Corr.osnum = ConId->osnum;
  TracLoc[nTrLoc].nCPfrom    = 0;
  TracLoc[nTrLoc].nBR        = nBRctr;
  TracLoc[nTrLoc].iBack      = -1;

  nTrLoc++;

  /*    find the (max_fanout) connecting components   */

  status =
  VR_cmp_nxt  (&retmsg, ConId, &TracLoc[nTrLoc-1].Corr,
              &nPos, iCin, iCot, TracCoro, TracCono);

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

    if (i > 0) nBRctr++;

    TracLoc[nTrLoc].Comp     = TracCono[i];
    TracLoc[nTrLoc].Corr     = TracCoro[i];
    TracLoc[nTrLoc].nCPfrom  = iCot[i];
    TracLoc[nTrLoc].nBR      = nBRctr;
    TracLoc[nTrLoc].iBack    = nBRnum;
    TracLoc[nTrLoc-1].nCPto  = iCin[i];

#ifdef MY_DEBUG
    printf ("BASE %d comp, corr, cin,cout <%d %d> <%d %d> %d %d\n",nTrLoc,
                    TracLoc[nTrLoc].Comp.objid, TracLoc[nTrLoc].Comp.osnum,
                    TracLoc[nTrLoc].Corr.objid, TracLoc[nTrLoc].Corr.osnum,
                    TracLoc[nTrLoc].nCPfrom, TracLoc[nTrLoc].nCPto);
#endif

    nTrLoc++;

    /*  enter the recursion .....   */

    status =
    VR_trace_rec (msg, nConEnds, ConEnd, &bOK, nBRnum, md_env);

    if (!(status & OM_S_SUCCESS)) break;

    if (bOK) break;
  }

  /*   set exit cpt of trace    */
  TracLoc[nTrLoc-1].nCPto  = 0;

  FI_TERM:
  if (nTrac)
    *nTrac     = nTrLoc;
  if (TracTab)
    *TracTab   = TracLoc;
  if (bBranched)
    *bBranched = bBR;
  return (status);
}

end implementation Root;

