/* $Id: VDsupOff.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/VDsupOff.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupOff.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1997/11/25  15:50:52  pinnacle
# NULL_GRID
#
# Revision 1.4  1997/10/29  15:23:44  pinnacle
# Add VDmaster.h
#
# Revision 1.3  1997/10/28  18:16:14  pinnacle
# Assorted 2.5 Fixes
#
 *
 * History:
 *      MM/DD/YY   AUTHOR  DESCRIPTION
 *      10/28/97   ah      added header
 *      07/11/97   EJM     CR#179701494  Support curve enhancements
 *                         Added code to sort trace curves.
 *      11/25/97   ah      Deleted extern NULL_GRID
 ***************************************************************************/

class implementation VDsupGen;

#include "VDmsg.h"

#include "VDsupMisc.h"
#include "VDsupMac.h"
#include "VDsupCons.h"

#include "vdloft.h"
#include "VDsupPO.h"

typedef struct {

  TGRbsp_curve *bsp;

  IGRdouble     basePar;
  TGRpoint      basePt;

  IGRdouble     tracePar;
  TGRpoint      tracePt;

  IGRdouble     dirPar;

  IGRdouble     dist;

} VDsupTraceInfo;

IGRstat VDsupConsOff(VDsupConsInfo *info)
{
  VDsupTraceInfo *traceList = NULL;
  VDsupTraceInfo tempList;
  VDsupTraceInfo *trace;

  TGRlc_info lc;

  IGRint i,j;
  IGRint traceNum = info->traceNum;

  TGRbsp_curve *baseBsp = NULL;
  TGRpoint     *ptList  = NULL;

  IGRdouble dist;

  TGRmd_env *md_env = info->md_env;
  IGRlong    cnt    = (IGRlong)info->cnt;

  IGRstat sts,l_msg,l_ret;

  /* Fail Flag */
  SetProc(VDsupConsOff); Begin

  l_ret = MSFAIL;
  *info->feetNum = 0;

  /* Find number of trace curves */ 
  if (traceNum < 2) {
    __CheckRC(0,0,"Less than 2 trace curves",wrapup);
  }

  /* Get Reference Object Geometry */
  sts = VDsupGetCrvOrSurfGeom(info,&info->baseObj1Lc,&baseBsp);
  __CheckSTS(sts,"Reference Geometry",wrapup);

  /* Allocate trace info */
  traceList = _CALLOC(traceNum,VDsupTraceInfo);
  __CheckPtr(traceList,"Allocating trace info",wrapup);

  ptList = _CALLOC(traceNum,TGRpoint);
  __CheckPtr(ptList,"Allocating point list",wrapup);

  /* Process each trace curve */
  for(i = 0; i < traceNum; i++) {

    trace = &traceList[i];

    sts = VDsupGetLcInfo(md_env,&info->tl[VDSUP_I_TRACE_BEG + (2*i)],&lc);
    __CheckSTS(sts,"Trace Lc",wrapup);

    /* Get Trace Object Geometry */
    sts = VDsupGetCrvOrSurfGeom(info,&lc,&trace->bsp);
    __CheckSTS(sts,"Trace Geometry",wrapup);

    sts = VDsupIntCrvCrv(
       baseBsp,        trace->bsp,
      &trace->basePt, &trace->tracePt,
      &trace->basePar,&trace->tracePar,
      &dist
    );
    __CheckSTS(sts,"IntCrvCrv",wrapup);

    sts = VDsupGetPtCrvPar(
      trace->bsp,
     &info->dirPt,
     &trace->dirPar
    );
    __CheckSTS(sts,"Point Curve Par",wrapup);
  }

  /* Sort trace curves in ascending order using base parameter value */
  for(i = 0; i < traceNum - 1; ++i)
     for(j = i+1; j < traceNum; ++j)
        if(traceList[i].basePar > traceList[j].basePar)
        {
          tempList = traceList[i];
          traceList[i] = traceList[j];
          traceList[j] = tempList;
        }
/*
  for(i = 0; i < traceNum; i++)
    printf("\n   traceList[%d].basePar = %f\n", i, traceList[i].basePar );
*/

  /* Extract Distances */
  if (fabs(info->dis2) < .0001) info->dis2 = info->dis1;
  if (fabs(info->dis1 - info->dis2) < .0001) {
    for(i = 0; i < traceNum; i++) {
      traceList[i].dist = info->dis1;
    }
  }
  else {
    traceList[0].dist = info->dis1;
    traceList[traceNum-1].dist = info->dis2;
    for(i = 1; i < (traceNum - 1); i++) {

      POapplaw2val(
        0,  /* LAW */
        info->dis1, 
        info->dis2,
        traceList[0].basePar,
        traceList[traceNum-1].basePar,
        traceList[i].basePar,
       &traceList[i].dist,
       &l_msg
      );
    }
  }

  /* Loop for each curve */
  for(j = 0; j < cnt; j++) {

    /* Find end point on each trace curve */
    for(i = 0; i < traceNum; i++) {

      trace = &traceList[i];
  
      sts = VDsupGetDistPt(
        trace->bsp,
        trace->tracePar,
        trace->dirPar,
        trace->dist * (j+1),
       &ptList[i]
      );
      if (!(sts & 1)) goto wrapupx;
    }
    sts = VDsupPlaceCurve(info,ptList,j);
    __CheckSTS(sts,"Placing Curve",wrapup);
  }

wrapupx:
  l_ret = MSSUCC;

wrapup:

  _FREE(baseBsp);
  _FREE(ptList);

  if (traceList) {
    for(i = 0; i < traceNum; i++) { 
      _FREE(traceList[i].bsp);
    }
    _FREE(traceList);
  }
  
  End
  return l_ret;
}

end implementation VDsupGen;
