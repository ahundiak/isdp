
/* $Id: VCCattach.I,v 1.2 2001/02/20 01:08:34 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCattach.I
 *
 * Description:
 *
 *      Methods to attach/detach parents to/from a cable
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCattach.I,v $
 *      Revision 1.2  2001/02/20 01:08:34  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/14  09:34:58  pinnacle
# Replaced: vccable/VCCattach.I for: TR 179800931 by aharihar for route
#
# Revision 1.4  1998/04/02  20:07:44  pinnacle
# Replaced: vccable/VCCattach.I for:  by azuurhou for route
#
# Revision 1.3  1998/04/01  19:54:40  pinnacle
# Replaced: vccable/VCCattach.I for:  by kddinov for route
#
# Revision 1.2  1998/03/31  07:10:36  pinnacle
# Replaced: vccable/VCCattach.I for: TR 179800045 by aharihar for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.7  1997/07/29  14:54:14  pinnacle
# Replaced: vccable/VCCattach.I for:  by hverstee for cabling
#
# Revision 1.6  1997/07/22  21:39:26  pinnacle
# Replaced: vccable/VCCattach.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  20:46:56  pinnacle
# Replaced: vccable/VCCattach.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/31  18:02:34  pinnacle
# Replaced: vccable/VCCattach.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/20  20:49:22  pinnacle
# Replaced: vccable/VCCattach.I for:  by hverstee for cabling
#
# Revision 1.2  1996/11/21  21:28:04  pinnacle
# Replaced: vccable/VCCattach.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:46:08  pinnacle
# Created: vccable/VCCattach.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      07/08/96    hv          Initial
 *	04/02/98    adz		Change the calls for GetOffset/SetOffset
 *	Apr 14, 98  Anand    	Fix for TR 179800931
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
#define MY_DEBUG   1
*/

#include "VDmem.h"

#include "nddef.h"
#include "ndmacros.h"
#include "vrdbgmacros.h"

#define  VC_ATT_SW_OFFSET     1000



method   VCCbAttPoint   (IGRlong       *msg;
                  struct GRid          *PntId;
                         IGRint         Type;
                         IGRint         Vtx;
                         IGRint         Sec)
{
  IGRint                status;
  IGRint                NumSec;
  IGRint                NumPar;
  IGRint                NumPin;
  IGRint                isec;
  IGRint                cn_type;
  IGRint                i;
  IGRint                NbBuf;
  struct GRid          *PrBuf;
  struct GRid          *PrLoc;
  struct GRid           mygrid;
  struct VCCL_sectmap  *LocSect;

SetProc(VCCable_VCCbAttPoint ); Begin

  if (PntId == NULL) return (OM_E_INVARG);

  NumSec = om$dimension_of (varray = me->Sect);
  if ((Sec < 0) || (Sec >= NumSec)) return (OM_E_INVARG);

  if (me->Sect[Sec].type != VCC_STRING)       return (OM_E_INVARG);
  if ((Vtx < me->Sect[Sec].iFrom) ||
      (Vtx > me->Sect[Sec].iTo))              return (OM_E_INVARG);

#ifdef MY_DEBUG
  printf (" attach point to section %d vertex %d\n",Sec,Vtx);
#endif

  /*C   Find the current number of parents  */

  status =
  om$send( msg = message NDnode.NDget_objects
                        ((ND_ROOT | ND_IN_BUF), NULL, 0, &PrBuf, 0,
                           OM_K_MAXINT, &NbBuf ),
      targetid = my_id);
  as$status( action = RET_STATUS );

  /*C Allocate temp space */

  LocSect = _MALLOC ((NumSec + 2), struct VCCL_sectmap);
  PrLoc   = _MALLOC ((NbBuf+1) ,struct GRid);

  /*C Insert point in section map replacing vertex   */

  for (i=0; i<=Sec; i++)
    LocSect[i] = me->Sect[i];

  for (i=Sec; i<NumSec; i++)
    LocSect[i+2] = me->Sect[i];

  isec = Sec + 1;
  LocSect[isec-1].iTo   = Vtx + 1;

  LocSect[isec].type    = Type;
  LocSect[isec].iFrom   = -1;
  LocSect[isec].iTo     = -1;
  LocSect[isec].numvert = -1;
  LocSect[isec].strno   = -1;
  LocSect[isec].dY0     =  0;
  LocSect[isec].dZ0     =  0;
  LocSect[isec].dY1     =  0;
  LocSect[isec].dZ1     =  0;
  LocSect[isec].parno   = NbBuf - me->nVCAttr;

  LocSect[isec+1].iFrom = Vtx;
  NumSec += 2;

  /*C Insert new parent in local table  */

  NumPin = NbBuf - me->nVCAttr;
  NumPar = 0;

  for (i=0; i<NumSec; i++)
  {
    if (i == isec)
    {
      PrLoc[NumPar] = *PntId;
      LocSect[i].parno = NumPar;
      NumPar++;
    }
    else
    if (LocSect[i].parno >= 0)
    {
      PrLoc[NumPar] = PrBuf[LocSect[i].parno + me->nVCAttr];
      LocSect[i].parno = NumPar;
      NumPar++;
    }
  }

  /*A  Change size of sections table */

  status =
  om$vla_set_dimension (varray  = me->Sect,
                         size   = NumSec);
  as$status(action = RET_STATUS);

  /*A disconnect from old parents   */

#ifdef MY_DEBUG
  for (i=0; i<NumPin; i++)
    printf ("disconnect <%d %d>\n",PrBuf[me->nVCAttr+i].objid,
                                   PrBuf[me->nVCAttr+i].osnum);
#endif

  if (NumPin > 0)
  {
    status =
    om$send(msg     = message NDnode.NDdisconnect(NumPin, &PrBuf[me->nVCAttr]),
          targetid  = my_id);
    as$status(action = RET_STATUS);
  }

  /*A connect to the new parents */

#ifdef MY_DEBUG
  for (i=0; i<NumPar; i++)
    printf (" reconnect <%d %d>\n",PrLoc[i].objid,
                                   PrLoc[i].osnum);
#endif

  status =
  om$send(msg = message NDnode.NDconnect(NumPar, PrLoc, NULL_GRID, ND_ADD),
     targetid = my_id);
  as$status(action = RET_STATUS);

  /*C  refill instance section table   */

  for (i=0; i<NumSec; i++)
    me->Sect[i] = LocSect[i];

  _FREE (PrLoc);
  _FREE (LocSect);

  /* reset topo counter   */

  me->nVCTopo = NumPar;

#ifdef MY_DEBUG
  for (i=0; i<NumSec; i++)
    printf (" sectmap %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

  /* do the wait batch */

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;
  cn_type      = ND_COMP;

  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &mygrid,
             l_obj_info = &cn_type,
             nb_obj     = 1);

End;
  return status;
}/* end VCCbAttPoint */



method   VCCbAttGuide   (IGRlong       *msg;
                  struct GRid          *ConId;
                         IGRint         iCFrom;
                         IGRint         iCTo;
                         IGRint         Vtx1;
                         IGRint         Vtx2;
                         IGRint         Sec)
{
  IGRint                status;
  IGRint                cn_type;
  IGRint                NumSec;
  IGRint                NumPar;
  IGRint                NumPin;
  IGRint                isec;
  IGRint                i;
  IGRint                NbBuf;
  struct GRid          *PrBuf = NULL ;
  struct GRid          *PrLoc;
  struct GRid           mygrid;
  struct VCCL_sectmap  *LocSect;

SetProc(VCCable_VCCbAttGuide ); Begin

  if (ConId == NULL) return (OM_E_INVARG);

  if (Vtx1 > Vtx2)   /*  reverse them, makes no diff   */
  {
    IGRint       iSav;

    iSav = Vtx1;
    Vtx1 = Vtx2;
    Vtx2 = iSav;
    iSav   = iCFrom;
    iCFrom = iCTo;
    iCTo   = iSav;
  }
#ifdef MY_DEBUG
  printf ("conduit ptrs %d %d %d %d\n",Vtx1,Vtx2,iCFrom,iCTo);
#endif

  NumSec = om$dimension_of (varray = me->Sect);
  if ((Sec < 0) || (Sec >= NumSec))           return (OM_E_INVARG);

  if (me->Sect[Sec].type != VCC_STRING) return (OM_E_INVARG);
  if ((Vtx1 < me->Sect[Sec].iFrom) ||
      (Vtx2 > me->Sect[Sec].iTo))             return (OM_E_INVARG);

#ifdef MY_DEBUG
  printf (" attach conduit \n");
  for (i=0; i<NumSec; i++)
    printf (" sectmap %d %f %f %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

  /*C   Find the current number of parents  */

  status =
  om$send( msg = message NDnode.NDget_objects
                        ((ND_ROOT | ND_IN_BUF), NULL, 0, &PrBuf, 0,
                           OM_K_MAXINT, &NbBuf ),
      targetid = my_id);
  as$status( action = RET_STATUS );

  /*C Allocate temp space */

  LocSect = _MALLOC ((NumSec + 2), struct VCCL_sectmap);
  PrLoc   = _MALLOC ((NbBuf+1) ,struct GRid);

  /*C Insert conduit in section map replacing vertex range  */

  for (i=0; i<=Sec; i++)
    LocSect[i] = me->Sect[i];

  for (i=Sec; i<NumSec; i++)
    LocSect[i+2] = me->Sect[i];

  isec = Sec + 1;
  LocSect[isec-1].iTo     = Vtx1 + 1;
  LocSect[isec-1].numvert = LocSect[isec].iTo - LocSect[isec].iFrom + 1;

  /* create conduit section  */
  /*  NOTE: create  two end vertices and TWO conduit sections..... */

  LocSect[isec].type    = VCC_GUIDE_PARENT;
  LocSect[isec].numvert = 0;
  LocSect[isec].iFrom   = iCFrom;
  LocSect[isec].iTo     = iCTo;
  LocSect[isec].strno   = -1;
  LocSect[isec].dY0     =  0;
  LocSect[isec].dZ0     =  0;
  LocSect[isec].dY1     =  0;
  LocSect[isec].dZ1     =  0;
  LocSect[isec].parno   = NbBuf - me->nVCAttr;

  LocSect[isec+1].iFrom   = Vtx2;
  LocSect[isec+1].numvert = LocSect[isec+1].iTo - LocSect[isec+1].iFrom + 1;
  NumSec += 2;

#ifdef MY_DEBUG
  for (i=0; i<NumSec; i++)
    printf (" locsect %d %f %f %d %d %d\n",LocSect[i].type,
                                           LocSect[i].iFrom,
                                           LocSect[i].iTo,
                                           LocSect[i].parno,
                                           LocSect[i].strno,
                                           LocSect[i].numvert);
#endif

  /*C Insert new parent in local table  */

  NumPin = NbBuf - me->nVCAttr;
  NumPar = 0;

  for (i=0; i<NumSec; i++)
  {
    if (i == isec)
    {
#ifdef MY_DEBUG
      printf (" insert parent <%d %d> loc %d sec %d\n",
                      ConId->objid,ConId->osnum,NumPar,i);
#endif
      PrLoc[NumPar] = *ConId;
      LocSect[i].parno = NumPar;
      NumPar++;
    }
    else
    if (LocSect[i].parno >= 0)
    {
      IGRint   iiloc;

      iiloc = LocSect[i].parno + me->nVCAttr;

#ifdef MY_DEBUG
      printf (" move parent <%d %d> from %d to %d sec %d\n",
                 PrBuf[iiloc].objid,PrBuf[iiloc].osnum, iiloc, NumPar,i);
#endif
      PrLoc[NumPar] = PrBuf[iiloc];
      LocSect[i].parno = NumPar;
      NumPar++;
    }
  }

  /*A  Change size of sections table */

  status =
  om$vla_set_dimension (varray  = me->Sect,
                         size   = NumSec);
  as$status(action = RET_STATUS);

  /*A disconnect from old parents   */

#ifdef MY_DEBUG
  for (i=0; i<NumPin; i++)
    printf ("disconnect <%d %d>\n",PrBuf[me->nVCAttr+i].objid,
                                   PrBuf[me->nVCAttr+i].osnum);
#endif

  if (NumPin > 0)
  {
    status =
    om$send(msg     = message NDnode.NDdisconnect(NumPin, &PrBuf[me->nVCAttr]),
          targetid  = my_id);
    as$status(action = RET_STATUS);
  }

  /*A connect to the new parent list  */

#ifdef MY_DEBUG
  for (i=0; i<NumPar; i++)
    printf (" reconnect <%d %d>\n",PrLoc[i].objid,
                                   PrLoc[i].osnum);
#endif

  status =
  om$send(msg = message NDnode.NDconnect(NumPar, PrLoc, NULL_GRID, ND_ADD),
     targetid = my_id);
  as$status(action = RET_STATUS);

  /*C  refill instance section table   */

  for (i=0; i<NumSec; i++)
    me->Sect[i] = LocSect[i];

  _FREE (PrLoc);
  _FREE (LocSect);

  /*   reset topo parents counter    */

  me->nVCTopo = NumPar;

#ifdef MY_DEBUG
  for (i=0; i<NumSec; i++)
    printf (" sectmap %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

  /* do the wait batch */

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;
  cn_type      = ND_COMP;

  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &mygrid,
             l_obj_info = &cn_type,
             nb_obj     = 1);

End;
  return status;
}/* end VCCbAttGuide */



method   VCCbAttRway    (IGRlong       *msg;
                         IGRshort       nNum;
                  struct VR_tracerec   *ConId;
                         IGRint         Vtx1;
                         IGRint         Vtx2;
                         IGRint         Sec)
{
  IGRint                status;
  IGRint                cn_type;
  IGRint                NumSec;
  IGRint                NumPar;
  IGRint                NumPin;
  IGRint                isec;
  IGRint                i;
  IGRint                NbBuf;
  struct GRid          *PrBuf;
  struct GRid          *PrLoc = NULL ;
  struct GRid           mygrid;
  struct VCCL_sectmap  *LocSect = NULL ;

SetProc(VCCable_VCCbAttRway ); Begin

  if (ConId == NULL) return (OM_E_INVARG);

#ifdef MY_DEBUG
  printf ("rway ptrs %d %d \n",Vtx1,Vtx2);
  for (i=0; i<nNum; i++)
  {
    printf ("Trace in <%d %d> %d %d\n",
                  ConId[i].Comp.objid, ConId[i].Comp.osnum,
                  ConId[i].nCPfrom, ConId[i].nCPto);

  }
#endif

  NumSec = om$dimension_of (varray = me->Sect);
  if ((Sec < 0) || (Sec >= NumSec))           return (OM_E_INVARG);

  if (me->Sect[Sec].type != VCC_STRING)       return (OM_E_INVARG);
  if (Vtx1 > Vtx2)                            return (OM_E_INVARG);

  if ((Vtx1 < me->Sect[Sec].iFrom) ||
      (Vtx2 > me->Sect[Sec].iTo))             return (OM_E_INVARG);

#ifdef MY_DEBUG
  printf (" attach raceway \n");
  for (i=0; i<NumSec; i++)
    printf (" sectmap %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

  /*C   Find the current number of parents  */

  status =
  om$send( msg = message NDnode.NDget_objects
                        ((ND_ROOT | ND_IN_BUF), NULL, 0, &PrBuf, 0,
                           OM_K_MAXINT, &NbBuf ),
      targetid = my_id);
  as$status( msg = "NDnode.NDget_objects", action=GOTO_VALUE, value=wrapup );
  /*C Allocate temp space */

  LocSect = _MALLOC ((NumSec+2+nNum), struct VCCL_sectmap);
  PrLoc   = _MALLOC ((NbBuf+1+nNum) ,struct GRid);

  /*C Insert conduit in section map replacing vertex range  */
  for (i=0; i<=Sec; i++)	LocSect[i] = me->Sect[i];
  for (i=Sec; i<NumSec; i++)	LocSect[i+nNum+1] = me->Sect[i];

  LocSect[Sec].iTo     = Vtx1 + 1;
  LocSect[Sec].numvert = LocSect[Sec].iTo - LocSect[Sec].iFrom + 1;

  for (i=0; i<nNum; i++)
  {
    isec = Sec + 1 + i;

    /* create raceway sections  */
  
    LocSect[isec].type    = VCC_RWAY_PARENT;
    LocSect[isec].numvert =  0;
    LocSect[isec].iFrom   = ConId[i].nCPfrom;
    LocSect[isec].iTo     = ConId[i].nCPto;
    LocSect[isec].strno   = -1;
    LocSect[isec].dY0     =  0;
    LocSect[isec].dZ0     =  0;
    LocSect[isec].dY1     =  0;
    LocSect[isec].dZ1     =  0;
    LocSect[isec].parno   = VC_ATT_SW_OFFSET + i;
  }

  isec = Sec + nNum;
  LocSect[isec+1].iFrom   = Vtx2;
  LocSect[isec+1].numvert = LocSect[isec+1].iTo - LocSect[isec+1].iFrom + 1;


  NumSec = NumSec + nNum + 1;

#ifdef vdsDEBUG
  for (i=0; i<NumSec; i++)
    printf (" locsect %d %f %f %d %d %d\n",LocSect[i].type,
                                           LocSect[i].iFrom,
                                           LocSect[i].iTo,
                                           LocSect[i].parno,
                                           LocSect[i].strno,
                                           LocSect[i].numvert);
#endif

  /*C Insert new parent in local table  */

  NumPin = NbBuf - me->nVCAttr;
  NumPar = 0;

  for (i=0; i<NumSec; i++)
  {
    IGRshort    indic;

    if (LocSect[i].parno < 0) continue;

    if (LocSect[i].parno >= VC_ATT_SW_OFFSET)
    {
      indic = LocSect[i].parno - VC_ATT_SW_OFFSET;
      PrLoc[NumPar] = ConId[indic].Comp;

#ifdef vdsDEBUG
      printf (" insert parent <%d %d> loc %d sec %d\n",
                ConId[indic].Comp.objid,ConId[indic].Comp.osnum,NumPar,i);
#endif
    }
    else
    {
      indic = LocSect[i].parno + me->nVCAttr;
      PrLoc[NumPar] = PrBuf[indic];

#ifdef vdsDEBUG
      printf (" move parent <%d %d> from %d to %d sec %d\n",
                 PrBuf[indic].objid,PrBuf[indic].osnum, indic, NumPar,i);
#endif
    }

    LocSect[i].parno = NumPar;
    NumPar++;
  }

  /*A  Change size of sections table */

  status =
  om$vla_set_dimension (varray  = me->Sect,
                         size   = NumSec);
  as$status( msg = "vla_set_dimension", action = GOTO_VALUE, value = wrapup );

  /*A disconnect from old parents   */

#ifdef MY_DEBUG
  for (i=0; i<NumPin; i++)
    printf ("disconnect <%d %d>\n",PrBuf[me->nVCAttr+i].objid,
                                   PrBuf[me->nVCAttr+i].osnum);
#endif

  if (NumPin > 0)
  {
    status =
    om$send(msg     = message NDnode.NDdisconnect(NumPin, &PrBuf[me->nVCAttr]),
          targetid  = my_id);
    as$status( msg = "NDnode.NDdisconnect", action = GOTO_VALUE, value = wrapup );
  }

  /*A connect to the new parent list  */

#ifdef MY_DEBUG
  for (i=0; i<NumPar; i++)
    printf (" reconnect <%d %d>\n",PrLoc[i].objid,
                                   PrLoc[i].osnum);
#endif

  status =
  om$send(msg = message NDnode.NDconnect(NumPar, PrLoc, NULL_GRID, ND_ADD),
     targetid = my_id);
  as$status( msg = "NDnode.NDconnect", action = GOTO_VALUE, value = wrapup );

  /*C  refill instance section table   */

  for (i=0; i<NumSec; i++)
    me->Sect[i] = LocSect[i];


  /*   reset topo parents counter    */

  me->nVCTopo = NumPar;

#ifdef MY_DEBUG
  for (i=0; i<NumSec; i++)
    printf (" sectmap %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

  /* do the wait batch */

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;
  cn_type      = ND_COMP;

  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &mygrid,
             l_obj_info = &cn_type,
             nb_obj     = 1);

	status = OM_S_SUCCESS ;

wrapup:

	_FREE (PrLoc);
	_FREE (LocSect);
	End;
	return status;

}/* end VCCbAttRway */




method   VCCbDetach     (IGRlong       *msg;
                  struct GRid          *PntId)
{
  IGRint                status;
  IGRint                i;
  IGRlong               retmsg;
  IGRint                NoDet;
  IGRint                Nod1, Nod2;
  IGRint                NoPar;
  IGRint                NoSec;
  IGRint                Nos1, Nos2;
  IGRint                NumPar;
  IGRshort              CurSize;
  IGRint                NbBuf;
  IGRint                cn_type;
  struct GRid           mygrid;
  struct GRid          *PrBuf = NULL ;
  struct VCOffset	*pOffset = NULL,
			*p1Offset = NULL ;

  SetProc( VCCable_VCCbDetach ); Begin 

  __DBGpr_obj(" Parent ID",*PntId);
  if (PntId == NULL)
  {
    __DBGpr_com(" Input arg invalid, PntId is NULL");
    End
    return (OM_E_INVARG);
  }

#ifdef vdsDEBUG
  printf (" detach point or conduit\n");
#endif

  /*A initialization */

 *msg     = MSFAIL;
  Nod1 = Nod2 = NoDet   = -1;
  Nos1 = Nos2 = NoSec   = -1;
  NbBuf   = 1;

  CurSize = om$dimension_of (varray = me->Sect);
  __DBGpr_int(" Dimension of me->Sect",CurSize);

#ifdef vdsDEBUG
  for (i=0; i<CurSize; i++)
    printf (" sectmap %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

  /* get list of parents  */

  status =
  om$send( msg  = message NDnode.NDget_objects
                   ((ND_ROOT | ND_IN_BUF), NULL, 0, &PrBuf, 0,
                         OM_K_MAXINT, &NbBuf ),
       targetid = my_id);
  as$status( action = RET_STATUS );

  for (i=0; i<NbBuf; i++)
  {
    __DBGpr_obj(" Parent list",PrBuf[i]);
    if ((PrBuf[i].objid != PntId->objid) ||
        (PrBuf[i].osnum != PntId->osnum)) continue;

    Nod1 = Nod2 = NoDet = i;
    break;
  }

  if (NoDet < 0)
  {
    __DBGpr_com(" Parent not found!");
    End
    return (status);
  }

  NoPar = NoDet - me->nVCAttr;
  __DBGpr_int(" Number of Parents",NoPar);
  if (NoPar < 0)
  {
    __DBGpr_com(" Parent not found!");
    End
    return (status);
  }

  for (i=0; i<CurSize; i++)
  {
    if (me->Sect[i].parno != NoPar) continue;

    Nos1 = Nos2 = NoSec = i;
    break;
  }

  if (NoSec < 0)
  {
    __DBGpr_com(" Mismatch in Section map");
    End
    return (status);
  }

  if ((me->Sect[NoSec].type == VCC_TERM_PARENT) ||
      (me->Sect[NoSec].type == VCC_TERM_CHILD))
  { /*    disconnect leads from terminal   */

    IGRshort    indic ;
    IGRshort	NoOffsets=0;

    indic = (NoSec == 0) ? 0 : 1;
    __DBGpr_int(" indic",indic);

    status =
    om$send (msg = message VCCable.VCConDscall (&retmsg, indic),
        targetid = my_id);

 /* Below lines of code added by Anand for removing offset of cable vertex from
    which the terminal is deleted */

    status =
    om$send(msg = message VCCable.VCCGetOffset( (void *)&pOffset, &NoOffsets ),
	    targetid = my_id );
    __DBGpr_int(" NoOffsets",NoOffsets);

    if( NoOffsets>0 )
    {
	IGRshort count=0;
	__DBGpr_com(" Going to reset offsets");

	if( NoOffsets > 1 )
	{
	    p1Offset = _CALLOC( NoOffsets-1 , struct VCOffset );

/* The fix for 179800931. The condition in the for statement below was split
   into two separate conditions: one in the for statement, and one as an
   explicit if condition just immediately after the for statement. Somehow,
   this works, while the former didn't!!  Anand */

	    for( i=0, count=0 ; i < NoOffsets ; i++ )
	    {
		__DBGpr_vec(" Offset - i",pOffset[i].Offset);
		__DBGpr_int(" Index - i",pOffset[i].Index);

		if( pOffset[i].Index != indic )
		{
		    p1Offset[count]		= pOffset[i];
		    __DBGpr_vec(" Offset - count",p1Offset[count].Offset);
		    p1Offset[count].Index   = count++ ;
		}
	    }
	}

	NoOffsets--;
 
	status =
	om$send( msg = message VCCable.VCCSetOffset( (void *)p1Offset,
							  NoOffsets ),
		   targetid = my_id);
	as$status(msg = "VCCable.VCCSetOffset", action = GOTO_VALUE,
			value = wrapup );
    }
  } /* End of if condition */

 /* Above lines of code added by Anand */

  if (me->Sect[NoSec].type == VCC_RWAY_PARENT)
  {
    while ((Nos1 > 0) && (me->Sect[Nos1-1].type == VCC_RWAY_PARENT))
    {
      Nod1--;
      Nos1--;
    }

    while ((Nos2 < (CurSize-1)) && (me->Sect[Nos2+1].type == VCC_RWAY_PARENT))
    {
      Nod2++;
      Nos2++;
    }
  }

  /*A  disconnect this parent   */

  NoPar  = NbBuf - me->nVCAttr;
  NumPar = Nod2 - Nod1 + 1;
#ifdef vdsDEBUG
  printf ("disconnect parents from %d to %d\n",Nod1, Nod2);
  printf (" Detach, buffer %d original %d detached %d\n",NbBuf,NoPar, NumPar);
#endif

  status =
  om$send(msg     = message NDnode.NDdisconnect(NumPar, &PrBuf[Nod1]),
        targetid  = my_id);
  as$status();

  /*   reset topo parents counter    */

  me->nVCTopo = NoPar - NumPar;

  /*A update section table for next recompute */

 *msg     = MSSUCC;

  for (i=Nos1; i<=Nos2; i++)
  {
    if ((me->Sect[i].type == VCC_POINT_PARENT) ||
        (me->Sect[i].type == VCC_TERM_PULL)    ||
        (me->Sect[i].type == VCC_TERM_PARENT))

        me->Sect[i].type    = VCC_FREE_VERTEX;
    else
    if (me->Sect[i].type == VCC_GUIDE_PARENT)
        me->Sect[i].type    = VCC_FREE_GUIDE;
    else
    if (me->Sect[i].type == VCC_RWAY_PARENT)
        me->Sect[i].type    = VCC_FREE_RWAY;

    me->Sect[i].iFrom   = -1;
    me->Sect[i].iTo     = -1;
    me->Sect[i].parno   = -1;
    me->Sect[i].strno   = -1;
    me->Sect[i].numvert = -1;
  }

  for (i=0; i<CurSize; i++)
  {
    if (me->Sect[i].parno >= NoPar) me->Sect[i].parno -= NumPar;
  }

#ifdef vdsDEBUG
  for (i=0; i<CurSize; i++)
    printf (" sectmap %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

  /* do the wait batch */

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;
  cn_type      = ND_COMP;

  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &mygrid,
             l_obj_info = &cn_type,
             nb_obj     = 1);

	status = OM_S_SUCCESS ;

wrapup:

	_FREE( pOffset );
	_FREE( p1Offset );
	End
	return status;

}/* end VCCbDetach */

end implementation VCCable;

