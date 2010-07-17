
/* $Id: VCMLRway.I,v 1.1.1.1 2001/01/04 21:12:28 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCMLRway.I
 *
 * Description:
 *      Implementation file for place cable command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMLRway.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.10  1997/05/07  14:18:50  pinnacle
# Replaced: vccmd/VCMLRway.I for:  by hverstee for cabling
#
# Revision 1.9  1997/04/28  22:34:42  pinnacle
# Replaced: vccmd/VCMLRway.I for:  by hverstee for cabling
#
# Revision 1.8  1997/03/12  21:58:10  pinnacle
# Replaced: vccmd/VCMLRway.I for:  by hverstee for cabling
#
# Revision 1.7  1997/01/09  23:04:56  pinnacle
# Replaced: vccmd/VCMLRway.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/09  19:59:08  pinnacle
# Replaced: vccmd/VCMLRway.I for:  by hverstee for cabling
#
# Revision 1.4  1996/12/16  19:34:24  pinnacle
# Replaced: vccmd/VCMLRway.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/19  14:26:04  pinnacle
# Replaced: vccmd/VCMLRway.I for:  by hverstee for cabling
#
# Revision 1.1  1996/11/12  21:48:48  pinnacle
# Created: vccmd/VCMLRway.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

/*      This file does the cable to raceway interface

         METHODS

          VCGetRway                raceway start
          VCGetARW                 (optional) raceway end
*/

class implementation VCCmdPC;

#include <ctype.h>
#include <string.h>

#include "bsdistptpt.h"

#include "VDmem.h"

#include "VRcompdef.h"

/*
#define MY_DEBUG 
*/

/***********  EXTERN ***********/

from  VRGeneric         import  VRGetCptGeom;
from  VRGeneric         import  VRGetNumberOfCpts;
from  VRGeneric         import  VRGetStatus;

from  VRCorrection      import  VRGetPipeTempId;

from  GRgraphics        import  GRdisplay;

extern GRclassid  OPP_VRCorrection_class_id;



method VCGetRway ( long * sts)
{
  int                 status = OM_S_SUCCESS;
  IGRlong             retmsg;
  IGRshort            iend[2];
  IGRdouble           d3pt[3];
  IGRdouble           dP1, dP2;
  IGRdouble           dEcoord[6];
  IGRdouble           dEvec[6];
  BSrc                rc;
  IGRint              i;
  IGRint              nnncp;
  IGRshort            nStat;
  IGRboolean          bBRANCH;
  IGRboolean          bPATH;
  IGRshort            nConEnd;

  struct GRid         OtherEnd;

#ifdef MY_DEBUG
  printf ("get raceway begin\n");
#endif

  me->ret = VC_RTC_ALLOK;

  /*A ----- Get located object ----- */
  me->ConnId = me->event1.located_object[0].located_obj;

  status =
  om$send(msg = message VRGeneric.VRGetStatus (&retmsg, &nStat),
     targetid = me->ConnId.objid,
     targetos = me->ConnId.osnum);

  if (nStat & VR_CORRECTION) goto quit;

  bPATH          = FALSE;   /*   get whole network first   */
  nConEnd        = 0;
  OtherEnd.objid = NULL_OBJID;

#ifdef MY_DEBUG
  printf (" current index %d\n",me->nMyPnts);
#endif

  for( i = 0; i < 3; i++ )
    d3pt[i]   = me->myPnts[me->nMyPnts-1].xyz[i];

#ifdef MY_DEBUG
  printf (" last vertex %f %f %f \n",d3pt[0], d3pt[1], d3pt[2]);
#endif

/*---------------------------------------------------------------*/

  /*  raceway section, interface with ROUTE        */
  iend[0] = 0;
  iend[1] = 1;

  status =
  om$send(msg = message VRGeneric.VRGetNumberOfCpts (&retmsg, &nnncp,
                       &me->ModuleInfo),
     targetid = me->ConnId.objid,
     targetos = me->ConnId.osnum);
  as$status();

  status =
  om$send(msg = message VRGeneric.VRGetCptGeom
                      (&retmsg, iend[0], &dEcoord[0], &dEvec[0], NULL,
                       &me->ModuleInfo),
     targetid = me->ConnId.objid,
     targetos = me->ConnId.osnum);
  as$status();

  if (nnncp == 1)
  {
    dEcoord[3] = dEcoord[0];
    dEcoord[4] = dEcoord[1];
    dEcoord[5] = dEcoord[2];
  }
  else
  {
    status =
    om$send(msg = message VRGeneric.VRGetCptGeom
                        (&retmsg, iend[1], &dEcoord[3], &dEvec[3], NULL,
                         &me->ModuleInfo),
       targetid = me->ConnId.objid,
       targetos = me->ConnId.osnum);
    as$status();
  }

  dP1 = BSdistptpt (&rc, d3pt, (IGRdouble *) &dEcoord[0]);
  dP2 = BSdistptpt (&rc, d3pt, (IGRdouble *) &dEcoord[3]);

#ifdef MY_DEBUG
  printf ("raceway entry %d %f %f %f\n",
                      iend[0],dEcoord[0],dEcoord[1],dEcoord[2]);
  printf ("raceway entry %d %f %f %f\n",
                      iend[1],dEcoord[3],dEcoord[4],dEcoord[5]);
  printf ("distances %f %f\n",dP1,dP2);
#endif

  if (dP1 > dP2)
  {
    for( i = 0; i < 3; i++ )
    {
      me->dRWC[i] = dEcoord[i+3];
      me->dRWV[i] = dEvec[i+3];
    }
    me->ICbeg = iend[1];
    me->ICend = iend[0];
  }
  else
  {
    for( i = 0; i < 3; i++ )
    {
      me->dRWC[i] = dEcoord[i];
      me->dRWV[i] = dEvec[i];
    }
    me->ICbeg = iend[0];
    me->ICend = iend[1];
  }


#ifdef MY_DEBUG
   printf (" enter raceway from %d to %d\n",me->ICbeg,me->ICend);
#endif

  status =
  VR$Tracer (p_msg      = &retmsg,
             p_comp     = &me->ConnId,
             numout     = &me->nRWtr,
             Tracetab   = &me->RWTrac,
             p_Branched = &bBRANCH,
             p_mdenv    = &me->ModuleInfo);

  /* update section data   */

#ifdef MY_DEBUG
    printf (" finish preceding string\n");
#endif

  if (bBRANCH)
  {    /*   it branches, get next pick before fill   */
     _put_response( resp = VCL_LINK_NO_PATH);
     *sts = VCL_LINK_NO_PATH;
#ifdef MY_DEBUG
    printf (" branch found, get endpoint\n");
#endif

  }
  else
  {
    status =
    om$send (msg = message VCCmdPC.VCRWfill (sts),
        targetid = my_id);
  }

  quit:
  return OM_S_SUCCESS;
}

/*     raceway other end     */

method VCGetARW ( long * sts)
{
  int                 status;
  IGRlong             retmsg;
  IGRint              i;
  IGRboolean          bBRANCH;
  IGRboolean          bPATH;
  IGRshort            nConEnd;

  struct GRid         OtherEnd;
  struct VR_tracerec *LTrac;

#ifdef MY_DEBUG
  printf ("get raceway second pick\n");
#endif

  me->ret = VC_RTC_ALLOK;
  LTrac   = me->RWTrac;

  /*A ----- Get located object ----- */
  OtherEnd = me->event1.located_object[0].located_obj;

  for (i=0; i<me->nRWtr; i++)
  {
    if (OtherEnd.objid == LTrac[i].Comp.objid) goto ALLOK;
  }

  _put_response( resp = VC_RTC_ERROR);
  *sts = VC_RTC_ERROR;
  goto quit;

  ALLOK:

  me->nRWtr = 0;
  _FREE (me->RWTrac);

#ifdef MY_DEBUG
  printf ("regenerate trace\n");
#endif

  bPATH = TRUE;
  nConEnd = 1;

  status =
  VR$Tracer (p_msg      = &retmsg,
             b_path     = bPATH,
             p_comp     = &me->ConnId,
             numends    = nConEnd,
             p_ends     = &OtherEnd,
             numout     = &me->nRWtr,
             Tracetab   = &me->RWTrac,
             p_Branched = &bBRANCH,
             p_mdenv    = &me->ModuleInfo);

  status =
  om$send (msg = message VCCmdPC.VCRWfill (sts),
      targetid = my_id);

  quit:
  me->nRWtr = 0;
  _FREE (me->RWTrac);
  return OM_S_SUCCESS;
}

method VCRWfill ( long * sts)
{
  IGRint              status;
  IGRlong             retmsg;
  double              dSelOff = 0;
  double              dSelOn  = 1;
  int                 i;
  IGRshort            iend[2];
  IGRdouble           d3pt[3];
  IGRdouble           dP1, dP2;
  IGRdouble           dEcoord[6];
  BSrc                rc;
  IGRint              nnncp;
  IGRshort            nDIG;
  IGRdouble           dDUMM[3];
  struct GRid         Ext;
  struct GRid         AssRW;
  struct GRid         disp_info;
  enum GRdpmode       dpmode;
  struct VR_tracerec *LTrac;

  me->ret = VC_RTC_ALLOK;
  LTrac   = me->RWTrac;
  dDUMM[0] = dDUMM[1] = dDUMM[2] = 0.0;

  GRfindmod (&disp_info);
  dpmode = GRhd;

  /*    fill sections with RW comps   */

  for (i=0; i<me->nRWtr; i++)
  {
    /*A ---- If required, change it into an associative root ------ */

    status =
    as$make_source( go_grid      = LTrac[i].Comp,
                    mod_env      = &me->event1.located_object[0].module_info,
                    as_os        = me->ModuleInfo.md_id.osnum,
                    as_grid      = &AssRW);
    as$status();

#ifdef MY_DEBUG
    printf (" TRACE.. <%d %d> and <%d %d> ends %d %d\n",
                      LTrac[i].Corr.objid, LTrac[i].Corr.osnum,
                      LTrac[i].Comp.objid, LTrac[i].Comp.osnum,
                       LTrac[i].nCPfrom, LTrac[i].nCPto);
#endif

    /*    highlight trace    */

    if (LTrac[i].Corr.objid != NULL_OBJID)
    {  /*   correction fields may be empty   */
      status =
      om$send (msg = message GRgraphics.GRdisplay
                                 (&retmsg, &me->ModuleInfo.md_env.matrix_type,
                                  me->ModuleInfo.md_env.matrix,
                                  &dpmode, &disp_info),
          targetid = LTrac[i].Corr.objid,
          targetos = LTrac[i].Corr.osnum,
          senderid = NULL_OBJID);
      as$status ();
    }

    status =
    om$send (msg = message GRgraphics.GRdisplay
                                 (&retmsg, &me->ModuleInfo.md_env.matrix_type,
                                  me->ModuleInfo.md_env.matrix,
                                  &dpmode, &disp_info),
        targetid = LTrac[i].Comp.objid,
        targetos = LTrac[i].Comp.osnum,
        senderid = NULL_OBJID);
    as$status ();

    if (i == 0)
    {
      nDIG = VC_digit (me->dRWV, dDUMM);

      status =
      om$send (msg = message VCCmdPC.VCMLAddPath
                         (VCC_RWAY_PARENT, me->nLdig, me->dRWC, me->dRWC,
                          LTrac[i].nCPfrom, LTrac[i].nCPto, nDIG, &AssRW),
      targetid = my_id);
    }
    else
    {
      status =
      om$send (msg = message VCCmdPC.VCMLAddNode
                         (VCC_RWAY_PARENT, me->dRWC, me->dRWC,
                          LTrac[i].nCPfrom, LTrac[i].nCPto, &AssRW),
      targetid = my_id);
    }
  }

  /*    find the raceway exit     */

  Ext = LTrac[me->nRWtr - 1].Comp;

  iend[0] = 0;
  iend[1] = 1;

  status =
  om$send(msg = message VRGeneric.VRGetNumberOfCpts (&retmsg, &nnncp,
                       &me->ModuleInfo),
     targetid = Ext.objid,
     targetos = Ext.osnum);
  as$status();

  status =
  om$send(msg = message VRGeneric.VRGetCptGeom
                      (&retmsg, iend[0], &dEcoord[0], NULL, NULL,
                       &me->ModuleInfo),
     targetid = Ext.objid,
     targetos = Ext.osnum);
  as$status();

  if (nnncp == 1)
  {
    dEcoord[3] = dEcoord[0];
    dEcoord[4] = dEcoord[1];
    dEcoord[5] = dEcoord[2];
  }
  else
  {
    status =
    om$send(msg = message VRGeneric.VRGetCptGeom
                        (&retmsg, iend[1], &dEcoord[3], NULL, NULL,
                         &me->ModuleInfo),
       targetid = Ext.objid,
       targetos = Ext.osnum);
    as$status();
  }

  dP1 = BSdistptpt (&rc, d3pt, (IGRdouble *) &dEcoord[0]);
  dP2 = BSdistptpt (&rc, d3pt, (IGRdouble *) &dEcoord[3]);

#ifdef MY_DEBUG
  printf ("raceway exit %d %f %f %f\n",
                      iend[0],dEcoord[0],dEcoord[1],dEcoord[2]);
  printf ("raceway exit %d %f %f %f\n",
                      iend[1],dEcoord[3],dEcoord[4],dEcoord[5]);
  printf ("distances %f %f\n",dP1,dP2);
#endif

  /*   force start of a new string at exit     */

  if (dP1 > dP2)
  {
    status =
    om$send (msg = message VCCmdPC.VCMLAddStrP (&dEcoord[0]),
        targetid = my_id);
  }
  else
  {
    status =
    om$send (msg = message VCCmdPC.VCMLAddStrP (&dEcoord[3]),
        targetid = my_id);
  }

#ifdef MY_DEBUG
  printf (" raceway set\n");
#endif

/* Raceways do one-shot attach   */

  FIg_set_value ( me->pCtlAtt, VCPCAB_ATTACH, dSelOff );
  FIg_set_value ( me->pCtlAtt, VCPCAB_DIG, dSelOn );

  _put_response( resp = VCL_LINK_FREE_POINT );
  *sts = VCL_LINK_FREE_POINT;

  quit:
  return OM_S_SUCCESS;
}

end implementation VCCmdPC;
