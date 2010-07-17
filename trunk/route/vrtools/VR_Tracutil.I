
/* $Id: VR_Tracutil.I,v 1.1.1.1 2001/01/04 21:13:12 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrtools/VR_Tracutil.I
 *
 * Description:
 *      Route network trace functions
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VR_Tracutil.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1997/03/11  17:12:30  pinnacle
# Created: vrtools/VR_Tracutil.I by hverstee for route
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

/*
#define MY_DEBUG 
*/

/***********  EXTERN ***********/

from  ASnode    import  ASreturn_go;

from  NDnode    import  NDget_objects;

from  VRGeneric import  VRGetCorrections;
from  VRGeneric import  VRGetNumberOfCpts;

from  VRCorrection import  VRGetCptIndex;

extern  GRclassid   OPP_VRCptIn_class_id;
extern  GRclassid   OPP_ACpretendin_class_id;




extern
IGRint   VR_cmp_nxt   (IGRlong       *msg,
                struct GRid          *CompIn,
                struct GRid          *CorrIn,
                       IGRshort      *nNum,
                       IGRshort      *nCPin,
                       IGRshort      *nCPout,
                struct GRid          *Correct,
                struct GRid          *CompOut)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     i1CP[VRT_MAX_FANOUT];
  IGRshort     i2CP[VRT_MAX_FANOUT];
  IGRshort     nCR;
  IGRshort     i;
  GRclassid    MyclassId;

  struct GRid  CmpRef[VRT_MAX_FANOUT];

  for (i=0; i<VRT_MAX_FANOUT; i++)
  {
    CmpRef[i].objid = NULL_OBJID;
    CmpRef[i].osnum = CompIn->osnum;
  }

  om$get_classid (objid = CompIn->objid,
                  osnum = CompIn->osnum,
              p_classid = &MyclassId);

  status =
  VR_cmp_thru (msg, CompIn, CorrIn, nNum, nCPin, nCPout, Correct, CompOut);

  if (CorrIn->objid != NULL_OBJID)
  {  /*   see if we may be crossing a file boundary     */
    nCR = 0;

    if (MyclassId == OPP_VRCptIn_class_id)
    {  /*   here we really MUST be crossing      */
      status =
      VR_cmp_upR (&retmsg, CompIn, i1CP, i2CP, CmpRef);

      if (retmsg == MSSUCC) nCR = 1;
    }
    else
    {  /*   here we may be crossing down     */
      status =
      VR_cmp_dnR (&retmsg, CompIn, &nCR, i1CP, i2CP, CmpRef);
    }

    for (i=0; i<nCR; i++)
    {  /*   found a crossing, add   */
      if (Correct)
      {
        Correct[*nNum].objid = NULL_OBJID;
        Correct[*nNum].osnum = CmpRef[i].osnum;
      }

      if (CompOut)
      {
        CompOut[*nNum].objid = CmpRef[i].objid;
        CompOut[*nNum].osnum = CmpRef[i].osnum;
      }

      if (nCPin)
        nCPin[*nNum] = i1CP[i];

      if (nCPout)
        nCPout[*nNum] = i2CP[i];

      (*nNum)++;
    }
  }

  return (OM_S_SUCCESS);
}



/*       Cross UP into ref file     */

extern
IGRint  VR_cmp_upR   (IGRlong       *msg,
               struct GRid          *CompIn,
                      IGRshort      *nCPin,
                      IGRshort      *nCPout,
               struct GRid          *CompOut)
{
  IGRint      status;
  IGRshort    mattyp;
  IGRdouble   dMat[16];

  *msg = MSSUCC;

#ifdef MY_DEBUG
  printf (" CrossUP ref from %d %d\n",CompIn->objid, CompIn->osnum);
#endif

  status =
  om$send (msg = message ASnode.ASreturn_go (CompOut, &mattyp, dMat),
      senderid = NULL_OBJID,
      targetid = CompIn->objid,
      targetos = CompIn->osnum);

#ifdef MY_DEBUG
  printf (" CrossUP ref to   %d %d\n",CompOut->objid, CompOut->osnum);
#endif

  *nCPout = 0;
  *nCPin  = 0;

  return (OM_S_SUCCESS);
}



/*       Cross DOWN from ref file     */

extern
IGRint  VR_cmp_dnR   (IGRlong       *msg,
               struct GRid          *CompIn,
                      IGRshort      *nNum,
                      IGRshort      *nCPin,
                      IGRshort      *nCPout,
               struct GRid          *CompOut)
{
  IGRint      status;
  OMuint      nCount;
  IGRshort    i, j;
  GRclassid   Thisclass;
  GRclassid   Thatclass;
  IGRint      iNC;

  struct GRid             Children[VRT_MAX_FANOUT];
  OM_S_OBJECT_LINKAGE     *Items;

  *msg  = MSFAIL;
  Items = NULL;
  *nNum = 0;

  status =
  om$get_channel_count( objid = CompIn->objid,
                        osnum = CompIn->osnum,
                 p_chanselect = &AS_notification,
                        count = &nCount );

#ifdef MY_DEBUG
  printf (" Channelcounts notification %d \n", nCount);
#endif

  if (nCount > 0)
  {
    Items = _MALLOC (nCount, OM_S_OBJECT_LINKAGE);
    if(!Items) return OM_E_NODYNMEM;

#ifdef MY_DEBUG
  printf (" CrossDOWN ref from %d %d - %d\n",
             CompIn->objid, CompIn->osnum, nCount);
#endif

    status =
    om$get_channel_objects( objid = CompIn->objid,
                            osnum = CompIn->osnum,
                     p_chanselect = &AS_notification,
                             list = Items,
                             size = nCount,
                            count = &nCount );

    for (i=0; i<nCount; i++)
    {
      status =
      om$get_classid (objid = Items[i].S_objid,
                      osnum = Items[i].osnum,
                  p_classid = &Thisclass);

      if (Thisclass != OPP_ACpretendin_class_id) continue;

      status =
      om$send (msg = message NDnode.NDget_objects
                                  ( ND_CHILDREN, Children, VRT_MAX_FANOUT,
                                     NULL, 0, OM_K_MAXINT, &iNC),
        senderid = NULL_OBJID,
        targetid = Items[i].S_objid,
        targetos = Items[i].osnum);

#ifdef MY_DEBUG
  printf (" Pretendin children %d\n",iNC);
#endif

      for (j=0; j<iNC; j++)
      {
        status =
        om$get_classid (objid = Children[j].objid,
                        osnum = Children[j].osnum,
                    p_classid = &Thatclass);

        if (Thatclass != OPP_VRCptIn_class_id) continue;

        *msg  = MSSUCC;

#ifdef MY_DEBUG
  printf (" Found VRCptIn.... %d %d\n",Children[j].objid, Children[j].osnum);
#endif

        if (CompOut)
        {
          CompOut[*nNum].objid = Children[j].objid;
          CompOut[*nNum].osnum = Children[j].osnum;
        }

        if (nCPin)
          nCPin[*nNum] = 0;

        if (nCPout)
          nCPout[*nNum] = 0;

        (*nNum)++;
      }
    }
  }

  _FREE (Items);

  return (OM_S_SUCCESS);
}



extern
IGRint   VR_cmp_thru  (IGRlong       *msg,
                struct GRid          *CompIn,
                struct GRid          *CorrIn,
                       IGRshort      *nNum,
                       IGRshort      *nCPin,
                       IGRshort      *nCPout,
                struct GRid          *Correct,
                struct GRid          *CompOut)
{

  IGRint       status;
  IGRlong      retmsg;
  IGRint       nNB, iNB;
  IGRint       i, j;
  IGRshort     i1CP, i2CP;

  struct GRid  CrrArr[VRT_MAX_FANOUT];
  struct GRid  CmpArr[VRT_MAX_FANOUT];
  struct GRid  Corr;

  *nNum = 0;
  *msg  = MSSUCC;

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
  printf ("Corr and cpts <%d %d> %d %d\n",
                    CrrArr[i].objid, CrrArr[i].osnum, i1CP, i2CP);
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

end implementation Root;

