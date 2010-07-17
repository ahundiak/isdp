/* $Id: VRConnect.I,v 1.3 2001/02/20 01:17:35 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrtools / VRConnect.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRConnect.I,v $
 *  Revision 1.3  2001/02/20 01:17:35  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/16 20:09:10  anand
 *  SP merge
 *
# Revision 1.1  2000/05/24  01:30:56  pinnacle
# Created: route/vrtools/VRConnect.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/05/15  21:11:22  pinnacle
# Replaced: vrtools/VRConnect.I for:  by hverstee for route240
#
# Revision 1.3  1996/05/10  13:57:20  pinnacle
# Replaced: vrtools/VRConnect.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/18  00:30:02  pinnacle
# Replaced: vrtools/VRConnect.I for:  by r240_int for route240
#
 *
 * History:
  01/17/96   tlb  Add prototypes
 *
 *************************************************************************/
class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include <stdio.h>
#include "VRcompdef.h"
#include "parametric.h"
#include "VRmacros.h"
#include "VRcsdef.h"
#include "VRcordef.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "AS_status.h"
#include "vrconcco_pto.h"
#include        "vrdbgmacros.h"

#define AS_DEBUG

from GRgraphics import  GRdelete;
from NDnode     import  NDdisplay;
from NDnode     import  NDs_compute_node;
from VRGeneric  import  VRGetCptGeom;
from VRGeneric  import  VRConnect;
from VRGeneric  import  VRGetOrigCoor;
from VRGeneric  import  VRGetPlanes;
from VRCnrlSeg  import  VRget_planes;
from VRCnrlSeg  import  VRget_terminators;
from VRConcComp import  VRAddPlanes;
from VRplane    import  VRpostabsg;
from VRplane    import  NDgive_structure;


/**************************************************************************/
IGRint VRConnect (IGRlong    *msg,
          struct  GRid       *CmpId,
                  IGRshort   *nCptNum,
                  IGRint      NbCpts,
          struct  GRid       *SegmentIds,
                  IGRint      NbSeg,
                  IGRshort   *nIndex,
          struct  GRmd_env   *md_env)


/*.VRConnect */
{
  IGRlong    status;
  IGRint     i;
  GRclassid  CompClassId;

  extern     GRclassid       OPP_VRComponent_class_id;

  SetProc( Func_VRConnect ); Begin
  /*"md_env = %d %d\n", md_env->md_id.objid, md_env->md_id.osnum */
  /*"NbSeg  = %d\n",NbSeg*/

  /* we need to distinguish constrained components */
  status = om$get_classid (objid     = CmpId->objid,
                           osnum     = CmpId->osnum,
                           p_classid = &CompClassId);
  as$status();

  /* --- For Constrain Components create planes ---- */
  if( om$is_ancestry_valid(   
             subclassid   = CompClassId,
             superclassid = OPP_VRComponent_class_id) != OM_S_SUCCESS )
  {
    IGRint          NbTemp=0;
    IGRint          NbPlanes;
    IGRshort        IndexTable[3*(VR_MAX_CPTS-1)];
    struct  GRid    TempList[3*VR_MAX_CPTS];
    struct  GRid    PlaneIds[3*VR_MAX_CPTS];

    /*| --- Initialize TempList --- */
    for ( i=0; i<3*VR_MAX_CPTS; i++ )  TempList[i].objid = NULL_OBJID;

    __DBGpr_com("For Constrain Components create planes");
    /*| --- Get Planes Ids --- */
    for( i=0; i<NbSeg; i++ )
    {
      status = 
      om$send( msg = message VRCnrlSeg.VRget_planes( msg,
                             &TempList[nCptNum[i]*3],
                             &TempList[nCptNum[i]*3+1],
                             nIndex[i] ? NULL : &TempList[nCptNum[i]*3+2],
                             nIndex[i] ? &TempList[nCptNum[i]*3+2] : NULL),
          targetid = SegmentIds[i].objid,
          targetos = SegmentIds[i].osnum,
          senderid = NULL_OBJID );
      as$status ( action = RET_STATUS );
    }

    status = 
    om$send( msg = message VRGeneric.VRGetPlanes
                           (msg, 3*NbCpts, PlaneIds, &NbPlanes, md_env),
        targetid = CmpId->objid,
        targetos = CmpId->osnum,
        senderid = NULL_OBJID );
    as$status ( action = RET_STATUS );

    if( NbPlanes < 3*NbCpts )
    {
      /*| Build Temp */
      status = VRBuildTemp( msg, CmpId, 3*NbCpts, TempList, 3*(NbCpts-1),
                            IndexTable, md_env, &NbTemp );
      as$status( action = RET_STATUS );

      status =
     om$send ( msg = message VRConcComp.VRAddPlanes 
                              (msg, 3*NbCpts, TempList, IndexTable, md_env ),
          targetid = CmpId->objid,
          targetos = CmpId->osnum,
          senderid = NULL_OBJID );
      as$status ( action = RET_STATUS );
    }
  }
  else
  {
    /*| --- If Replace and cpt different than -1 --- */
    if( nCptNum[0] != -1 && NbSeg == 1 )
    {
      IGRdouble           dOrig[3];
      struct  GRid        TerminalId;
      struct  ret_struct  ret_str;

      __DBGpr_com("Replace and cpt different than -1");
      /*| ----- Get Origin coordinates */
      status = 
      om$send( msg = message VRGeneric.VRGetOrigCoor( msg, dOrig, md_env),
          senderid = NULL_OBJID,
          targetid = CmpId->objid,
          targetos = CmpId->osnum);
      as$status();

      /*| -- Get Plane on segment to move it to -1 Comp coords -- */
      status = 
      om$send ( msg = message VRCnrlSeg.VRget_planes
                                              (msg, NULL, NULL,
                                              nIndex[0] ? NULL : &TerminalId,
                                              nIndex[0] ? &TerminalId : NULL),
            targetid = SegmentIds[0].objid,
            targetos = SegmentIds[0].osnum,
            senderid = NULL_OBJID );
      as$status ();

      /*| -- Fill ret_str for VRpostabsg -- */
      status = 
      om$send ( msg = message VRplane.NDgive_structure( msg, &ret_str, md_env),
           targetid = TerminalId.objid,
           targetos = TerminalId.osnum,
           senderid = NULL_OBJID );
      as$status ();

      ret_str.var.ref_st.t[2]  = ret_str.var.ref_st.t[3];
      ret_str.var.ref_st.t[6]  = ret_str.var.ref_st.t[4];
      ret_str.var.ref_st.t[10] = ret_str.var.ref_st.t[5];
      ret_str.var.ref_st.t[3]  = dOrig[0];
      ret_str.var.ref_st.t[7]  = dOrig[1];
      ret_str.var.ref_st.t[11] = dOrig[2];
__DBGpr_mat("ret_str for VRpostabsg",ret_str.var.ref_st.t);
      /*| -- Move plane to -1 component cpt coordinates -- */
      status = 
      om$send ( msg = message VRplane.VRpostabsg( msg, md_env, &ret_str ),
           senderid = NULL_OBJID,
           targetid = TerminalId.objid,
           targetos = TerminalId.osnum);
      as$status();

      /*| -- Compute Segment with new plane -- */
      status = 
      om$send ( msg = message NDnode.NDs_compute_node( msg, 0, md_env ),
           senderid = NULL_OBJID,
           targetid = SegmentIds[0].objid,
           targetos = SegmentIds[0].osnum);
      as$status();
    }
  }

  /*| -- Connect Component -- */
  for( i=0; i<NbSeg; i++)
  {
    /*"nIndex[%d] = %d \n",i,nIndex[i]*/
    /*"SegmentIds[%d] = %d \n",i,SegmentIds[i].objid*/

    status = 
    om$send ( msg = message VRGeneric.VRConnect
                              ( msg, &SegmentIds[i], nIndex[i], 0, md_env ),
         senderid = NULL_OBJID,
         targetid = CmpId->objid,
         targetos = CmpId->osnum);
    as$status( action = RET_STATUS );
  }

  End
  return OM_S_SUCCESS;
 
}
end implementation Root;
