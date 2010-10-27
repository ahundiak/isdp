/* $Id: VDsupEqu.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/VDsupEqu.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupEqu.I,v $
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
 *      MM/DD/YY        AUTHOR   DESCRIPTIO
 *      10/28/97        ah       added header
 *      07/11/97        EJM      CR#179701494  Support curve enhancements
 *                               Added code to sort trace curves.
 *      11/25/97        ah       Deleted extern NULL_GRID
 ***************************************************************************/

class implementation VDsupGen;

#include "bsarclen.h"

#include "VDmsg.h"

#include "VDsupMisc.h"
#include "VDsupMac.h"
#include "VDsupCons.h"

typedef struct {

  TGRbsp_curve *bsp;

  IGRdouble     basePar;   /* for sorting trace curves */

  IGRdouble     trace1Par;
  TGRpoint      trace1Pt;

  IGRdouble     trace2Par;
  TGRpoint      trace2Pt;

  IGRdouble     dist;

} VDsupTraceInfo;

IGRstat VDsupConsEqu(VDsupConsInfo *info)
{
  VDsupTraceInfo *traceList = NULL;
  VDsupTraceInfo tempList;
  VDsupTraceInfo *trace;

  TGRlc_info lc;

  IGRint traceNum = info->traceNum;
  IGRint i,j;

  TGRbsp_curve *base1Bsp = NULL;
  TGRbsp_curve *base2Bsp = NULL;

  TGRpoint     *ptList = NULL;

  IGRdouble  dist;
  IGRdouble  parM; /* par, */
  TGRpoint   pt;
  IGRboolean bool;

  BSrc bsrc;

  TGRmd_env *md_env = info->md_env;
  IGRlong    cnt = (IGRlong)info->cnt;

  IGRstat sts,l_ret;

  /* Fail Flag */
  SetProc(VDsupConsEqu); Begin

  l_ret = MSFAIL;
  *info->feetNum = 0;

  /* Find number of trace curves */ 
  if (traceNum < 2) {
    __CheckRC(0,0,"Less than 2 trace curves",wrapup);
  }

  /* Get Reference Object Geometry */
  sts = VDsupGetCrvOrSurfGeom(info,&info->baseObj1Lc,&base1Bsp);
  __CheckSTS(sts,"Reference 1 Geometry",wrapup);

  sts = VDsupGetCrvOrSurfGeom(info,&info->baseObj2Lc,&base2Bsp);
  __CheckSTS(sts,"Reference 2 Geometry",wrapup);

  /* Allocate Trace Data */
  traceList = _CALLOC(traceNum,VDsupTraceInfo);
  __CheckPtr(traceList,"Allocating trace info",wrapup);

  ptList = _CALLOC(traceNum,TGRpoint);
  __CheckPtr(ptList,"Allocating trace info",wrapup);

  /* Process each trace curve */
  for(i = 0; i < traceNum; i++) {

    trace = &traceList[i];

    sts = VDsupGetLcInfo(md_env,&info->tl[VDSUP_I_TRACE_BEG+(2*i)],&lc);
    __CheckSTS(sts,"Trace Lc",wrapup);

    /* Get Trace Object Geometry */
    sts = VDsupGetCrvOrSurfGeom(info,&lc,&trace->bsp);
    __CheckSTS(sts,"Trace Geometry",wrapup);

    sts = VDsupIntCrvCrv(
       base1Bsp,trace->bsp,
      &pt,   &trace->trace1Pt,
      &trace->basePar,  &trace->trace1Par,
      &dist
    );
    __CheckSTS(sts,"IntCrvCrv 1",wrapup);

     sts = VDsupIntCrvCrv(
       base2Bsp,trace->bsp,
      &pt,   &trace->trace2Pt,
      &trace->basePar,  &trace->trace2Par,
      &dist
    );
    __CheckSTS(sts,"IntCrvCrv 2",wrapup);
   
    /* Get Distance along trace curve between intersection pts */
    parM = (trace->trace1Par + trace->trace2Par) / 2.0;
    BSarclen(&bsrc,&bool,
      trace->bsp,
     &trace->trace1Par,
     &trace->trace2Par,
     &parM,
     &trace->dist
    );
    trace->dist = trace->dist / (cnt + 1);
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

  /* Loop for each curve */
  for(j = 0; j < cnt; j++) {

    /* Find end point on each trace curve */
    for(i = 0; i < traceNum; i++) {

      trace = &traceList[i];
  
      sts = VDsupGetDistPt(
        trace->bsp,
        trace->trace1Par,
        trace->trace2Par,
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

  _FREE(base1Bsp);
  _FREE(base2Bsp);
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
