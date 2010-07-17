/* $Id: VRskmerge.I,v 1.6 2002/04/10 20:33:30 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / VRskmerge.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRskmerge.I,v $
 *	Revision 1.6  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.5  2001/12/05 15:44:41  louis
 *	tr5901-dep_planes getting deleted
 *	
 *	Revision 1.4  2001/03/22 16:51:56  louis
 *	TR4725 - large number of changes related to planes selected for the new segment when connecting two networks. Also added recomputation for planes and components. Removed unused code in duplicate plane fuctionality.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:11  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/19  15:10:42  pinnacle
# Replaced: vrsketch/VRskmerge.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	03/08/01	law	TR4725	Split networks will not reconnect.
 *      03/13/01	law	TR4725  Adjusted for offsets in 1 axis.
 *      03/21/01        law     TR4725  Major modifications for CCOMP planes processing
 *      12/04/01        law     TR5901-checking all planes deleted dep planes
 *      04/08/02        law     TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 This file contains method to merge two align segments to one segment.
 These two segments will be deleted and new segment created. To share planes,
 VRdef_planes function will be called with dangling-dangling option.


 CHANGE HISTORY:  momo 06-1991 : Design date

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

class implementation VRsketch;


#include <malloc.h> 
#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "dpdef.h"
#include "nddef.h"
#include "VRcsdef.h"
#include "VRclsymbf.h"
#include "VRclsymb.h"
#include "csmacros.h"
#include "ndmacros.h"
#include "asbox.h"
#include "asmacros.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#include "bsdotp.h"
#include "VDmem.h"
#include "vrdbgmacros.h"
#include "VDchn.h"
#include "VRMath.h"
extern GRclassid OPP_VRConcComp_class_id;
extern GRclassid OPP_VRComponent_class_id;
extern GRclassid OPP_VRplane_class_id;
extern GRclassid OPP_VRCnrlSeg_class_id;

#define AS_DEBUG	1

from	GRgraphics	import	GRdelete,
				GRconstruct;
from	GRvg		import	GRdetplane;
from	NDnode		import	NDdisplay,
				NDs_compute_node,
				ASreturn_go,
				NDget_objects,
				NDchange_connect,
				NDdelete;
from	VRCnrlSeg	import	VRGetTopo,
				VRChgSegState,
				VRget_terminators;
from	VRGeneric	import	VRGetSupports,
				VRChgSupport,
				VRGetIndex,
				VRGetCptOnSup,
				VRGetOrientationDef;
from 	VRNozzle	import	VRGetRefId;
from	VRplane		import	VRget_plane_state,
				VRchg_plane_state;



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRskChgSupport( msg, CmpId, Orient, Index, PrevSeg, NewSeg, md_env )

IGRlong				*msg;
struct		GRid		*CmpId;
IGRdouble			*Orient;
IGRshort			*Index;
struct		GRid		*PrevSeg;
struct		GRid		*NewSeg;
struct		GRmd_env	*md_env;

/*.VRskChgSupport */
{
  BSrc			bsretcode;
  IGRlong		status;
  IGRvector		NewSegVector, PrevSegVector;
  SetProc( Fn VRskChgSupport ); Begin
  /*"Orient = %f\n", (*Orient) */
  /*"Index  = %d\n", (*Index)  */

  status = om$send( msg      = message VRCnrlSeg.VRGetTopo
                               ( msg, NewSegVector, NULL, NULL, NULL, NULL, md_env ),
                    senderid = NULL_OBJID,
                    targetid = NewSeg->objid,
                    targetos = NewSeg->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = *msg, action = RET_STATUS );

  status = om$send( msg      = message VRCnrlSeg.VRGetTopo
                               ( msg, PrevSegVector, NULL, NULL, NULL, NULL, md_env ),
                    senderid = NULL_OBJID,
                    targetid = PrevSeg->objid,
                    targetos = PrevSeg->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = *msg, action = RET_STATUS );

  (*Orient) *= BSdotp( &bsretcode, NewSegVector, PrevSegVector );

  /*"Orient = %f\n", *Orient */

  status = om$send( msg      = message VRGeneric.VRChgSupport
                               ( msg, *Orient, *Index, PrevSeg, NewSeg ),
                    senderid = NULL_OBJID,
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = *msg, action = RET_STATUS );

  End
  return OM_S_SUCCESS;

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRskmerge( IGRlong *sts )
{
  IGRshort			ConnPlaneIndex, PrevPlaneIndex, PrimIndex, SecIndex;
  IGRshort			PrevIndex, ConnIndex;
  IGRint			NbCmp;
  IGRint 			i;      /* loop index                     */
  IGRint 			nb_father; /* used by get_planes message     */
  IGRint 			cn_type = ND_COMP;
  IGRlong			retcode;   /* return code                    */
  IGRlong 			status;    /* return code                    */
  IGRdouble			PrimOrient, SecOrient, PrevOrient, ConnOrient;
  IGRdouble			CmpPt[6], SegEndPt[6];
  IGRboolean			CreateCorrection;
  struct	GRid		PsegId, SsegId, NewPrevCmp, NewConnCmp, CmpId[2];
  struct	GRid		NewPrevSegId, NewConnSegId;
  struct 	GRid 		CnrlSegId;/* GRid of the CnrlSeg to create  */
  struct	GRid		CmpSegId;  /* component segment's GRid       */
  struct	GRid		SrcPlanesId[8];
                                           /* list of initial planes         */
  struct	GRid		NewPlanesId[10];
                                           /* planes parent of CnrlSeg       */
  struct	GRid		context[4];/* context GRid needs by          */
                                           /* GRconstruct message            */
  struct	GRid		common_planes[2];
  GRclassid	myClassId;
  IGRshort	cmpcpt[2];
  IGRint SEGCPTINDEX;
  IGRint	mode;
  IGRint segbegplnndx, segendplnndx;
 
  SetProc(vrsketch-VRskmerge ); Begin
  *sts = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  __DBGpr_com("Identify the components hooked to the corrections at both ends of new segment");
  __DBGpr_obj("prevsegid",me->prev_seg_id);
  /*"prevsegid = %d\n", me->prev_seg_id.objid */

  /* previous segment is the current one or the support of the first located
  /* dangling
  /**/
  common_planes[0].objid = NULL_OBJID;
  common_planes[1].objid = NULL_OBJID;
  cmpcpt[0] = cmpcpt[1] = -1;

  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               ( &retcode, &NbCmp, &me->ModuleInfo, CmpPt, CmpId ),
                    targetid = me->prev_seg_id.objid,
                    targetos = me->prev_seg_id.osnum);
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

#ifdef vdsDEBUG
      for(i=0; i<NbCmp; i++) printf("CmpId[%d] = %d\n", i, CmpId[i].objid );
#endif

  if( me->FirstType != FREE_SPACE )
  {
    /*| FIRST COMPONENT IS DANGLING /*
    /* me->FirstLocatedElemId.objid is its objid */

    /* witch component of the first old segment will be connected to the new
    /* segment and on witch point. ( start point of the new segment )
    /**/

    if( CmpId[0].objid == me->FirstLocatedElemId.objid )
    {
      __DBGpr_com("located dangling is at index 0 on the previous segment");
      NewPrevCmp = CmpId[1];
      SegEndPt[0] = CmpPt[3]; SegEndPt[1] = CmpPt[4]; SegEndPt[2] = CmpPt[5];
    } 
    else
    {
      __DBGpr_com("located dangling is at index 1 on the previous segment");
      NewPrevCmp = CmpId[0];
      SegEndPt[0] = CmpPt[0]; SegEndPt[1] = CmpPt[1]; SegEndPt[2] = CmpPt[2];
    }
  }
  else
  {
    /*| FREE SPACE */
    NewPrevCmp = CmpId[0];
    SegEndPt[0] = CmpPt[0]; SegEndPt[1] = CmpPt[1]; SegEndPt[2] = CmpPt[2];
  }
      __DBGpr_obj("NewPrevCmp",NewPrevCmp);
      __DBGpr_vec("SegEndPt",SegEndPt);

  /* to call VRdef_planes function with dangling-dangling option we need 
  /* to get slave and master planes.
  /**/

  __DBGpr_com("Get info about topology of components at both ends");
  /* get topology of new previous component */
  status = om$send( msg      = message VRGeneric.VRGetOrientationDef
                               ( &retcode, &PsegId, &PrimIndex, &PrimOrient, &SsegId,
                                 &SecIndex, &SecOrient ),
                    targetid = NewPrevCmp.objid,
                    targetos = NewPrevCmp.osnum );
  if( me->prev_seg_id.objid == PsegId.objid )
  {
    NewPrevSegId   = SsegId;
    PrevOrient     = PrimOrient;

    if( SsegId.objid == NULL_OBJID )
    {
      /* previous component doesn't have a secondary segment : inline component,
      /* dangling, nozzle or constrain component
      /**/

      /* slave planes will be kept from the primary segment. the needed
      /* terminate plane depond of the position of the previous component on
      /* this segment 
      /**/

      if( PrimIndex ) PrevPlaneIndex = 3; /* end component ==> index = 1   */
      else            PrevPlaneIndex = 0; /* begin component ==> index = 0 */
    }
    else
    {
      /* previous component has a secondary segment : elbow, tee */

      /* slave planes will be kept from the secondary segment. the needed
      /* terminate plane depond of the position of the previous component on
      /* this segment 
      /**/

      if( SecIndex ) PrevPlaneIndex = 3;
      else           PrevPlaneIndex = 0;
    }
  }
  else
  {
    /* previous segment is not the primary segment */

    if( SsegId.objid != NULL_OBJID )
    {
      /* the compoent has a secondary segment ==> slave planes will be kept
      /* from the primary segment
      /**/

      NewPrevSegId = PsegId;
      if( PrimIndex ) PrevPlaneIndex = 3;
      else            PrevPlaneIndex = 0;
    }
    else
    {
      /* Inline component ==> has two supports but not a secondary */
      NewPrevSegId.objid = NULL_OBJID;
      PrevPlaneIndex     = 0;
    }

    PrevOrient = SecOrient; 
  }

  PrevIndex = 0; /* index of the previous component on the new segment */

  /*"PrevIndex = %d ... PrevOrient = %d\n", PrevIndex, PrevOrient */
  /*"NewPrevSegId = %d\n", NewPrevSegId.objid */

  __DBGpr_com(" get end dangling support");
  status = om$send(msg      = message VRGeneric.VRGetSupports
                              ( &retcode, 1, &CmpSegId, &nb_father ),
                   targetid = me->SecondLocatedElemId.objid,
                   targetos = me->SecondLocatedElemId.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /* do like the start dangling */
  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               ( &retcode, &NbCmp, &me->ModuleInfo, CmpPt, CmpId ),
                    targetid = CmpSegId.objid,
                    targetos = CmpSegId.osnum);
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( CmpId[0].objid == me->SecondLocatedElemId.objid )
  {
    SEGCPTINDEX = 1;

    __DBGpr_com("CmpId[0].objid == me->SecondLocatedElemId.objid");
    NewConnCmp    = CmpId[1]; 
    SegEndPt[3] = CmpPt[3]; SegEndPt[4] = CmpPt[4]; SegEndPt[5] = CmpPt[5];
  }
  else
  {
    SEGCPTINDEX = 0;
    __DBGpr_com("CmpId[0].objid != me->SecondLocatedElemId.objid");
    NewConnCmp = CmpId[0];
    SegEndPt[3] = CmpPt[0]; SegEndPt[4] = CmpPt[1]; SegEndPt[5] = CmpPt[2];
  }
  __DBGpr_com("**********************************************************");
  __DBGpr_vec("last SegEndPt",&SegEndPt[3]);
  __DBGpr_obj("NewConnCmp",NewConnCmp); 
  /*"NewconnCmp = %d\n", NewConnCmp.objid */

  status = om$send( msg      = message VRGeneric.VRGetOrientationDef
                               ( &retcode, &PsegId, &PrimIndex, &PrimOrient, &SsegId,
                                 &SecIndex, &SecOrient ),
                    targetid = NewConnCmp.objid,
                    targetos = NewConnCmp.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"PsegId = %d ... SsegId = %d\n", PsegId.objid, SsegId.objid */
      
  if( CmpSegId.objid == PsegId.objid )
  {
    __DBGpr_obj("CmpSegId.objid == PsegId.objid",PsegId);
    NewConnSegId   = SsegId;
    ConnOrient     = PrimOrient;
    if( SsegId.objid == NULL_OBJID )
    {
      if( PrimIndex ) ConnPlaneIndex = 7;
      else            ConnPlaneIndex = 4;
      __DBGpr_int("SsegId.objid == NULL_OBJID and ConnPlaneIndex is",ConnPlaneIndex);
    }
    else
    {
      if( SecIndex ) ConnPlaneIndex = 7;
      else           ConnPlaneIndex = 4;

      __DBGpr_int("SsegId.objid",SsegId.objid);
      __DBGpr_int(" and ConnPlaneIndex is",ConnPlaneIndex);
    }
  }
  else
  {
    __DBGpr_obj("CmpSegId",CmpSegId);
    __DBGpr_obj("PsegId",PsegId);
    if( SsegId.objid != NULL_OBJID )
    {
      __DBGpr_obj("NewConnSegId = PsegId and SsegId is ",SsegId);
      NewConnSegId   = PsegId;
      if( PrimIndex ) ConnPlaneIndex = 7;
      else            ConnPlaneIndex = 4;
      __DBGpr_int(" and ConnPlaneIndex is",ConnPlaneIndex);

    }
    else
    {
      __DBGpr_com("SsegId.objid == NULL_OBJID");
      NewConnSegId.objid = NULL_OBJID;
      ConnPlaneIndex     = 4;
    }

    ConnOrient     = SecOrient;
  }

  ConnIndex = 1;
  __DBGpr_com("---------------Get the planes for the old segments-------------------");

  /*"ConnIndex = %d ... ConnOrient = %d\n", ConnIndex, ConnOrient */
  /*"NewConnSegId = %d\n", NewConnSegId.objid */

  /* get slave planes from new previous segment if exist or from the old one */
  if( NewPrevSegId.objid != NULL_OBJID )
  {
    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_ROOT, SrcPlanesId, 4, NULL, 0, OM_K_MAXINT, &nb_father ),
                      targetid = NewPrevSegId.objid, 
                      targetos = NewPrevSegId.osnum);
    as$status( action = RET_STATUS );
    __DBGpr_obj("Getting planes from NewPrevSegId which is",NewPrevSegId);
  }
  else
  {
    IGRint nbplanes;
    struct GRobj_env locobjenv;
    locobjenv.obj_id = me->prev_seg_id;
    locobjenv.mod_env = me->ModuleInfo;
    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_ROOT, SrcPlanesId, 4, NULL, 0, OM_K_MAXINT, &nb_father ),
                      targetid = me->prev_seg_id.objid, 
                      targetos = me->prev_seg_id.osnum);
    as$status( action = RET_STATUS );
    vdchn$GetList( objOE = &locobjenv,
                        objID = &me->prev_seg_id,
			chnIDx= VDCHN_IDX_PARENT,
			maxCnt= OM_K_MAXINT,
			chnName = VDCHN_NAME_FATHER,
			cnt = &nbplanes,
			FltrClsId = OPP_VRplane_class_id,
                        outIDs = SrcPlanesId);
    __DBGpr_obj("Getting planes from prev_seg_id which is",me->prev_seg_id);
}

#ifdef vdsDEBUG
     for(i=0; i<4; i++ )
       printf("prev src_pl[%d] = %d\n", i, SrcPlanesId[i].objid );
#endif

  __DBGpr_int("PrevPlaneIndex", PrevPlaneIndex);
  __DBGpr_obj("SrcPlanesId[0] = SrcPlanesId[PrevPlaneIndex]",SrcPlanesId[0]);
  SrcPlanesId[0] = SrcPlanesId[PrevPlaneIndex];

  /* get master planes from the new connecting segment if exist or from the
  /* end dangling one
  **/

  if( NewConnSegId.objid != NULL_OBJID )
  {
    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_ROOT,&SrcPlanesId[4],4,NULL,0,OM_K_MAXINT,&nb_father ),
                      targetid = NewConnSegId.objid, 
                      targetos = NewConnSegId.osnum);
    as$status( action = RET_STATUS );
  }
  else
  {
    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_ROOT,&SrcPlanesId[4],4,NULL,0,OM_K_MAXINT,&nb_father ),
                      targetid = CmpSegId.objid, 
                      targetos = CmpSegId.osnum);
    as$status( action = RET_STATUS );
  }
  __DBGpr_com("------- Select the planes for the new segment -----------");

#ifdef vdsDEBUG
     for(i=4; i<8; i++ )
       printf("prev src_pl[%d] = %d\n", i, SrcPlanesId[i].objid );
#endif
  status = VRGetPlane_at_seg_end(CmpSegId,&SegEndPt[3],&SrcPlanesId[4],&segendplnndx);
  __DBGpr_obj("plane at second end of new segment",SrcPlanesId[4+segendplnndx]);
  status = VRGetPlane_at_seg_end(me->prev_seg_id,&SegEndPt[0],&SrcPlanesId[0],&segbegplnndx);
  __DBGpr_obj("plane at first end of new segment",SrcPlanesId[segbegplnndx]);
  SrcPlanesId[0] = SrcPlanesId[segbegplnndx];
  SrcPlanesId[3] = SrcPlanesId[segendplnndx+4];
  SrcPlanesId[4] = SrcPlanesId[5];
  SrcPlanesId[5] = SrcPlanesId[6];

#ifdef vdsDEBUG
  __DBGpr_com("First 6 planes for input to DefineSegPlanes");
     for(i=0; i<6; i++ )
       printf("prev src_pl[%d] = %d\n", i, SrcPlanesId[i].objid );
#endif

  /* case 5 : dangling --> dangling */
  /* in this case we give to def_planes function the three end planes  */
  /* of the previous segment and of the dangling parent's segment      */
  /* def_planes returns :                                              */
  /* - planes of the previous segment whose can be changed             */
  /* - the end plane of dangling parant's segment whose can be changed */
  /*   too and the four planes of the current CnrlSeg                  */

  status = VR$DefineSegPlanes(	p_retmsg	= &retcode,
				TopoFlag	= VR_PLANES_PLANES,
				p_InPutPlanes	= SrcPlanesId,
				p_SegmentPt0	= &SegEndPt[0],
				p_SegmentPt1	= &SegEndPt[3],
				p_MdEnv		= &me->ModuleInfo,
				p_OutPutPlanes	= NewPlanesId );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
   
/*** If components are a CCOMP we need the cpt index of original connection ***/
  cmpcpt[0] = -1;
  cmpcpt[1] = -1;
  if(me->prev_seg_id.objid != NULL_OBJID && NewPrevCmp.objid != NULL_OBJID)
  {
     om$get_classid (objid = NewPrevCmp.objid,
                     osnum = NewPrevCmp.osnum ,
                 p_classid = &myClassId );
     if ( om$is_ancestry_valid
            ( subclassid   = myClassId,
              superclassid = OPP_VRConcComp_class_id )
                                                    == OM_S_SUCCESS )
     {
          status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                    ( &retcode, &me->prev_seg_id, &cmpcpt[0], &me->ModuleInfo ),
                    targetid = NewPrevCmp.objid,
                    targetos = NewPrevCmp.osnum );
     }
  }
  if(CmpSegId.objid != NULL_OBJID && NewConnCmp.objid != NULL_OBJID)
  {
     om$get_classid (objid = NewConnCmp.objid,
                     osnum = NewConnCmp.osnum ,
                 p_classid = &myClassId );
     if ( om$is_ancestry_valid
            ( subclassid   = myClassId,
              superclassid = OPP_VRConcComp_class_id )
                                                    == OM_S_SUCCESS )
     {
          status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                          ( &retcode, &CmpSegId, &cmpcpt[1], &me->ModuleInfo ),
                    targetid = NewConnCmp.objid,
                    targetos = NewConnCmp.osnum );
     }
  }
  __DBGpr_int("previous comp cpt if a CCOMP",cmpcpt[0]);
  __DBGpr_int("Connected comp cpt if a CCOMP",cmpcpt[1]);
#ifdef vdsDEBUG
     for( i=0; i<10; i++ )
       printf("VRsketch.VRskcontodan : \t NewPlanesId[%d] = %d\n", i, NewPlanesId[i].objid );
#endif
  common_planes[0] = NewPlanesId[7];
  common_planes[1] = NewPlanesId[8];
  
  /*| update the connection */
  __DBGpr_com("calling VRskUpdateConnection");
  status = VRskUpdateConnection( SrcPlanesId, NewPlanesId, 3);
  as$status();

  /*| creation of the CnrlSeg */
  me->assoc_list.as_attr = (char *)&me->Product;
  me->assoc_list.parents = &NewPlanesId[6];
  me->assoc_list.context = context;
  for(i=0; i<4; i++ ) context[i].objid = NULL_OBJID;

  /* Get Line Route Symbology */
  {
    struct	GRid		SymbId;    /* Symbology object GRid          */
  
    SymbId.osnum = me->ModuleInfo.md_id.osnum;
    VR$symbology( return_code = &retcode,
                  symb_id     = &SymbId,
                  symb        = &me->LineSymbology );
  }
  
  /* update level to construct the line route and components */
  me->const_list.level = me->LineSymbology.level;

  /*"Symbology:level  = %d\n", me->const_list.level           */
  /*"Symbology:color  = %d\n", me->const_list.display->color  */
  /*"Symbology:wieght = %d\n", me->const_list.display->weight */
  /*"Symbology:style  = %d\n", me->const_list.display->style  */

  __DBGpr_com("Construct and connect the new control segment");
  CnrlSegId.osnum = me->ModuleInfo.md_id.osnum;
  status = om$construct(classname = "VRCnrlSeg", 
                        p_objid   = &CnrlSegId.objid, 
                        osnum     = CnrlSegId.osnum,
                        msg       = message GRgraphics.GRconstruct(&me->const_list));
  as$status( action = RET_STATUS );
  __DBGpr_obj("CONSTRUCTED CONTROL SEG",CnrlSegId);
  /*"CS id %d %d\n", CnrlSegId.objid, CnrlSegId.osnum */

  status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleInfo ),
                    targetid = CnrlSegId.objid, 
                    targetos = CnrlSegId.osnum);
  as$status();

  /*| update instance data */

  me->seg_GRid[me->num_of_seg-1] = CnrlSegId;

  status = VRskChgSupport
           ( &retcode, &NewPrevCmp, &PrevOrient, &PrevIndex, &me->prev_seg_id, &CnrlSegId,
            &me->ModuleInfo
           );
  as$status( action = RET_STATUS );
  __DBGpr_com("Calling VRskChgSupport for NewConnCmp and CnrlSegId");

  status = VRskChgSupport
           ( &retcode, &NewConnCmp, &ConnOrient, &ConnIndex, &CmpSegId, &CnrlSegId,
             &me->ModuleInfo 
           );
  as$status( action = RET_STATUS );

  __DBGpr_obj("Delete prev_seg_id",me->prev_seg_id);
  status = om$send( msg      = message GRgraphics.GRdelete( &retcode, &me->ModuleInfo ),
                    targetid = me->prev_seg_id.objid,
                    targetos = me->prev_seg_id.osnum );
  as$status( action = RET_STATUS );

  __DBGpr_obj("Delete CmpSegId",CmpSegId);
  status = om$send( msg      = message GRgraphics.GRdelete( &retcode, &me->ModuleInfo ),
                    targetid = CmpSegId.objid,
                    targetos = CmpSegId.osnum );
  as$status( action = RET_STATUS );

  CreateCorrection = TRUE;
/***** Moved for tr4725 
  status = om$send( msg      = message VRCnrlSeg.VRChgSegState( VR_UPDATE_COR, VR_UNKNOWN ),
                    targetid = CnrlSegId.objid,
                    targetos = CnrlSegId.osnum );
  as$status( action = RET_STATUS );
***************/     
  nd$wait_batch( type       = GR_GEOM_POSTED,
                 l_object   = &CnrlSegId,
               	 l_obj_info = &cn_type,
               	 nb_obj     = 1 );

  status = om$send( msg      = message NDnode.NDs_compute_node( &retcode, 0, &me->ModuleInfo ),
                    targetid = CnrlSegId.objid,
                    targetos = CnrlSegId.osnum );
  as$status( action = RET_STATUS );
#ifdef vdsDEBUG
{
IGRshort tstcpt;
          status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                    ( &retcode, &CnrlSegId, &tstcpt, &me->ModuleInfo ),
                    targetid = NewPrevCmp.objid,
                    targetos = NewPrevCmp.osnum );
printf("--------------------- testing cpt connect -------------------------\n");
printf("Cptndx connection of NewPrevCmp %d to %d is cpt %d\n",NewPrevCmp.objid,CnrlSegId.objid,tstcpt);
}
#endif
__DBGpr_com("Test for duplicate planes adjacent to the connect and replace them");
{
    struct GRid complist[2];
    IGRshort CptIndex;
    IGRint icmp,jpln;

  /******* Check for duplicate planes due to legacy splits ******/
  if(common_planes[0].objid != NULL_OBJID && common_planes[1].objid != NULL_OBJID)
  {

    __DBGpr_com("*************** Checking for duplicate planes **************");
    complist[0] = NewPrevCmp;
    complist[1] = NewConnCmp;

    for(icmp=0; icmp<2; icmp++)
    {
       __DBGpr_obj("check duplicate planes related to",complist[icmp]);
       __DBGpr_int("If a CCOMP the cpt connected to new segment",cmpcpt[icmp]);
       for(jpln=0; jpln<2; jpln++)
       {
          VRReplaceDupPlanes(common_planes[jpln], complist[icmp], cmpcpt[icmp]);
       }
    }

  }
    for(icmp=0; icmp<2; icmp++)
    {
       nd$wait_batch( type       = GR_GEOM_POSTED,
                      l_object   = &complist[icmp],
                      l_obj_info = &cn_type,
                      nb_obj     = 1 );
    }
  status = om$send( msg      = message VRCnrlSeg.VRChgSegState( VR_UPDATE_COR, VR_UNKNOWN ),
                    targetid = CnrlSegId.objid,
                    targetos = CnrlSegId.osnum );
  as$status( action = RET_STATUS );
  /** TR4725-- mostly for CCOMP connects to corrections. **/
    for(jpln=0; jpln<2; jpln++)
    {
       nd$wait_batch( type       = GR_GEOM_POSTED,
                      l_object   = &common_planes[jpln],
                      l_obj_info = &cn_type,
                      nb_obj     = 1 );
    }
}
  nd$mod_batch( request = ND_INQ, p_ret_mode = &mode );
  if( mode != ND_DEFER ) nd$exec_batch();

  return(OM_S_SUCCESS);

}  
/*** Added for TR4725 for duplicate planes ***/
int VRGetPlane_at_seg_end(segobj,segendxyz,planeobj_array,plane_end_ndx)
struct GRid segobj;
IGRdouble *segendxyz;
struct GRid *planeobj_array;
IGRint *plane_end_ndx;
{
  IGRdouble pt1[3],pt2[3];
  IGRlong retcode, status;
  IGRint ii, iii;
  BSrc rc;
  IGRmatrix matrix;
  IGRdouble      normal[12];      /* parent planes normal     */
  IGRdouble      points[12];      /* parent planes point      */
  IGRdouble     segvec[3];
  struct GRid   go_planes[4];
  struct IGRplane plane_info[4];
  IGRshort matrix_type;
  SetProc( Fn VRGetPlane_at_seg_end ); Begin


  /* get planes structure */
  __DBGpr_com("*****************************************************************************");
  __DBGpr_com("Call VRGetTopo to get plane info structure contents");
  for( ii = 0; ii<4; ii++ )
  {

    plane_info[ii].point  = &points[3*ii];
    plane_info[ii].normal = &normal[3*ii];

    __DBGpr_obj("planeobj_array[ii]",planeobj_array[ii]);
    __DBGpr_com("Calling NDnode.ASreturn_go");
    status = om$send( msg      = message NDnode.ASreturn_go
                                         ( &go_planes[ii], &matrix_type, matrix ),
                      senderid = NULL_OBJID,
                      targetid = planeobj_array[ii].objid,
                      targetos = planeobj_array[ii].osnum );
    as$status( action = RET_STATUS );

    __DBGpr_obj("graphic parent obj", go_planes[ii]);
    __DBGpr_com("Calling GRdetplane");
    status = om$send( msg      = message  GRvg.GRdetplane
                                 ( &retcode, &matrix_type, matrix, &plane_info[ii] ),
                      senderid = NULL_OBJID,
                      targetid = go_planes[ii].objid,
                      targetos = go_planes[ii].osnum );
    as$status( action = RET_STATUS );

  }

  for (ii = 0; ii< 4; ii++)
  {
    __DBGpr_vec("plane point",plane_info[ii].point );
    __DBGpr_vec("plane normal",plane_info[ii].normal );
  }
  __DBGpr_com("Call VRget_segment_geom to coordinate the planes with the seg end points");
  status =
  VRget_segment_geom( &retcode, plane_info, pt1, pt2 );

  __DBGpr_vec("pt1 end point",pt1);
  __DBGpr_vec("pt2 end point",pt2);

  if((fabs(pt1[0] - segendxyz[0]) < VRGetTol(VR_DIST_TOL)) &&
     (fabs(pt1[1] - segendxyz[1]) < VRGetTol(VR_DIST_TOL)) &&
     (fabs(pt1[2] - segendxyz[2]) < VRGetTol(VR_DIST_TOL)))
  {
    __DBGpr_com("pt1 is the selected point");
    *plane_end_ndx = 0;
  }
  else
  {
    __DBGpr_com("pt2 is the selected point");
    *plane_end_ndx = 3;
  }
  End
  return(OM_S_SUCCESS);
}
/*** Added for TR4725 for duplicate planes ***/
/******** VRGetPlaneInfo **********/

/* Given the plane objid, return the point/normal of the plane */
/* Note that it is the callers responsibility to provide space for the return arguments */
IGRint VRGetPlaneInfo (planeobj,plane_info)
struct GRid planeobj;
struct IGRplane *plane_info;
{
IGRlong status, retcode;
IGRmatrix matrix;
struct GRid   go_planes;
  IGRshort matrix_type;

    status = om$send( msg      = message NDnode.ASreturn_go
                                         ( &go_planes, &matrix_type, matrix),
                      senderid = NULL_OBJID,
                      targetid = planeobj.objid,
                      targetos = planeobj.osnum );
    as$status( action = RET_STATUS );

    __DBGpr_obj("input graphic parent obj", go_planes);

    status = om$send( msg      = message  GRvg.GRdetplane
                                 ( &retcode, &matrix_type, matrix, plane_info),
                      senderid = NULL_OBJID,
                      targetid = go_planes.objid,
                      targetos = go_planes.osnum );

    __DBGpr_vec("plane point",plane_info->point );
    __DBGpr_vec("plane normal",plane_info->normal );

return(OM_S_SUCCESS);
}

/*** Added for TR4725 for duplicate planes ***/
/********* VRGetPlanesforComps */
/* Give the Component objid, return a list of plane objids and the count */
/* If a CCOMP, will return 3 planes for a cpt. */
/* If a COMP, will return 3 planes for each line segment */
IGRint VRGetPlanesforComps(Cmp, cptindex, rtnplane_obj, nb_planes)
struct GRid Cmp;
IGRshort cptindex;
struct GRid **rtnplane_obj;
IGRint *nb_planes;

{
  struct GRid *plane_obj;
  GRclassid myClassId;
  struct GRid CmpSegId[10], *parent_ara;
  IGRint plane_cnt, nb_fathers, ipln, iseg;
  IGRlong status;

  __DBGpr_int("cptindex passed to VRGetPlanesforComps",cptindex);
  __DBGpr_obj("comp passed to VRGetPlanesforComps",Cmp);

  plane_cnt = 0;

  om$get_classid (objid = Cmp.objid,
                  osnum = Cmp.osnum ,
              p_classid = &myClassId );
  if ( om$is_ancestry_valid
         ( subclassid   = myClassId,
           superclassid = OPP_VRConcComp_class_id )
                                                    == OM_S_SUCCESS )
  {

     __DBGpr_obj("Found is a CCOMP\n",Cmp);
     /*"-> Process component : %d\n",Cmp.objid*/
     status = om$send
                 ( msg      = message NDnode.NDget_objects
                                        ( ND_ROOT,NULL,0,
                                          NULL, 0, OM_K_MAXINT,
                                          &nb_fathers ),
                              senderid = NULL_OBJID,
                              targetid = Cmp.objid,
                              targetos = Cmp.osnum );
     /*"\tNumber of parents : %d\n", nb_fathers*/
     if(nb_fathers)
     {
        parent_ara=(struct GRid *) _MALLOC(nb_fathers, struct GRid );

        status = om$send ( msg = message NDnode.NDget_objects
                          ( ND_ROOT, parent_ara,
                            nb_fathers, NULL, 0,
                            OM_K_MAXINT, &nb_fathers ),
                      senderid = NULL_OBJID,
                      targetid = Cmp.objid,
                      targetos = Cmp.osnum );

        __DBGpr_obj("Getting planes of CCOMP",Cmp);
        plane_cnt = 0;
        for(ipln=0;ipln<nb_fathers;ipln++)
        {
           /*| See if parent is a plane */
           status = om$get_classid(objid=parent_ara[ipln].objid,
                                   osnum=parent_ara[ipln].osnum,
                               p_classid=&myClassId);
           if( myClassId == OPP_VRplane_class_id ) plane_cnt++;
        }
        if(plane_cnt)
        {
           IGRint tempcnt;
           struct GRid *temp_obj;
           tempcnt = 0;
           /**** only get the three planes for our cpt ***/
           temp_obj=(struct GRid *) _MALLOC(plane_cnt, struct GRid );
           plane_obj=(struct GRid *) _MALLOC(3, struct GRid );
           for(ipln=0;ipln<nb_fathers;ipln++)
           {
              /*| See if parent is a plane */
              status = om$get_classid(objid=parent_ara[ipln].objid,
                                osnum=parent_ara[ipln].osnum,
                            p_classid=&myClassId);
              if( myClassId == OPP_VRplane_class_id )
              {
                 __DBGpr_obj("plane parent of CCOMP",parent_ara[ipln]);
                 temp_obj[tempcnt] = parent_ara[ipln];
                 tempcnt++;
              }
           }
           for(ipln=0;ipln<3;ipln++)
           {
              plane_obj[ipln] = temp_obj[cptindex*3 + ipln];
              __DBGpr_obj("plane for ccomp",plane_obj[ipln]);
           }
           plane_cnt = 3;
           _FREE (temp_obj);
        }
        _FREE (parent_ara);
     }
  }
  else if ( om$is_ancestry_valid
         ( subclassid   = myClassId,
           superclassid = OPP_VRComponent_class_id )
                                                    == OM_S_SUCCESS )
  {
     struct GRid CmpSegId[10];
     struct GRid tmpplnlst[40];
     IGRint nb_segs,status;
     IGRlong retcode;

    __DBGpr_obj("Getting segs for Comp",Cmp);
     status = om$send(msg      = message VRGeneric.VRGetSupports
                              ( &retcode, 10, CmpSegId, &nb_segs ),
                   senderid = NULL_OBJID,
                   targetid = Cmp.objid,
                   targetos = Cmp.osnum );
     as$status( action = RET_STATUS );
     as$status( sts = retcode, action = RET_STATUS );
     /* Each segment has 4 planes */
     plane_cnt = 0;
     for( iseg = 0; iseg<nb_segs; iseg++)
     {
        IGRint jpln;
        /*** Get the planes for the segment ***/
        __DBGpr_obj("Segment on comp",CmpSegId[iseg]);
        status = om$send
                 ( msg      = message NDnode.NDget_objects
                                        ( ND_ROOT,NULL,0,
                                          NULL, 0, OM_K_MAXINT,
                                          &nb_fathers ),
                              senderid = NULL_OBJID,
                              targetid = CmpSegId[iseg].objid,
                              targetos = CmpSegId[iseg].osnum );
        __DBGpr_int("Number of seg parents", nb_fathers);

        parent_ara=(struct GRid *) _MALLOC(nb_fathers, struct GRid );

        status = om$send ( msg = message NDnode.NDget_objects
                          ( ND_ROOT, parent_ara,
                            nb_fathers, NULL, 0,
                            OM_K_MAXINT, &nb_fathers ),
                      senderid = NULL_OBJID,
                      targetid = CmpSegId[iseg].objid,
                      targetos = CmpSegId[iseg].osnum );

        __DBGpr_obj("Accumulating unique planes for segment",CmpSegId[iseg]);
        for(ipln = 0; ipln<nb_fathers; ipln++)
        {
           if(plane_cnt < 1)
           {
               __DBGpr_obj("first plane",parent_ara[ipln]);
               tmpplnlst[0] = parent_ara[ipln];
               plane_cnt++;
           }
           else
           {
              IGRint not_found;
              not_found = 1;
              for(jpln = 0; (jpln < plane_cnt) && not_found; jpln++)
              {
                 if((parent_ara[ipln].objid == tmpplnlst[jpln].objid) &&
                    (parent_ara[ipln].osnum == tmpplnlst[jpln].osnum))
                   not_found = 0;
              }
              if(not_found)
              {
                 __DBGpr_obj("Another plane",parent_ara[ipln]);
                 tmpplnlst[plane_cnt] = parent_ara[ipln];
                 plane_cnt++;
              }
           }
        } /*** Process all parents ***/
        _FREE (parent_ara);
     } /*** process segs ***/
     if(plane_cnt)
     {
        plane_obj = _MALLOC(plane_cnt, struct GRid);
        for(ipln=0; ipln<plane_cnt; ipln++)
        {
           plane_obj[ipln] = tmpplnlst[ipln];
        }
     }
     else
        plane_obj = NULL;
  } /* End is a COMP */
  *nb_planes = plane_cnt;
  *rtnplane_obj = plane_obj;
  return (OM_S_SUCCESS);
}

/*** Added for TR4725 for duplicate planes ***/
/********* VRReplaceDupPlanes *****/
/* Given a plane and a list of components, replaces any duplicate planes */
/* Also updates all dependencies of the replaced plane and deletes the duplicate plane */
/* Also checks duplicate planes for constraints and DepPlanes.***/
IGRint VRReplaceDupPlanes(planetotest, compid, cptindex)
struct GRid planetotest;
struct GRid compid;
IGRshort cptindex ;
{
IGRint plane_cnt, differentplanes;
GRclassid myClassId;
struct GRid *plane_obj;
IGRint status;
IGRint cn_type;
IGRint icmp,ipln,jcmp,mod_made;

  SetProc( Fn VRReplaceDupPlanes ); Begin
/*** Process comps in comp_list. For now, may be a COMP, CCOMP, or CNTRL_SEG */
__DBGpr_obj("planetotest",planetotest);
__DBGpr_obj("comptotest",compid);
__DBGpr_int("cptindex on comp",cptindex);
  mod_made = 0;
{
      __DBGpr_obj("Getting planes for comp",compid);
      status = om$get_classid(objid=compid.objid,
                              osnum=compid.osnum,
                          p_classid=&myClassId);
     /*** If a CNTRL_SEG ***/
     if( myClassId == OPP_VRCnrlSeg_class_id )
     {
        __DBGpr_com("comp is a VRCnrlSeg");
        /* Much overkill since is supposed to be 4 planes **/
        status = om$send
                 ( msg      = message NDnode.NDget_objects
                                        ( ND_ROOT,NULL,0,
                                          NULL, 0, OM_K_MAXINT,
                                          &plane_cnt ),
                              senderid = NULL_OBJID,
                              targetid = compid.objid,
                              targetos = compid.osnum );

        plane_obj = _MALLOC(plane_cnt, struct GRid);
        /*** Get a list of parents ***/
        status = om$send ( msg = message NDnode.NDget_objects
                          ( ND_ROOT, plane_obj,
                            plane_cnt, NULL, 0,
                            OM_K_MAXINT, &plane_cnt ),
                              senderid = NULL_OBJID,
                              targetid = compid.objid,
                              targetos = compid.osnum );
        __DBGpr_int("plane_cnt for comp",plane_cnt);
      }
     /*** Else call VRGetPlanesforComps ***/
     else if ( om$is_ancestry_valid
         ( subclassid   = myClassId,
           superclassid = OPP_VRComponent_class_id )
                                                    == OM_S_SUCCESS )
     {
        __DBGpr_obj("object is a VRComponent",compid);
        __DBGpr_com("Calling VRGetPlanesforComps");
        status = VRGetPlanesforComps(compid,cptindex,&plane_obj, &plane_cnt);
     }
     else if ( om$is_ancestry_valid
         ( subclassid   = myClassId,
           superclassid = OPP_VRConcComp_class_id )
                                                    == OM_S_SUCCESS )
     {
        __DBGpr_obj("object is a VRConcComp",compid);
        __DBGpr_com("Calling VRGetPlanesforComps");
        status = VRGetPlanesforComps(compid,cptindex,&plane_obj,
                                      &plane_cnt);
     }
     else
        plane_cnt = 0;

     /*** For the planes in the list ***/
     if(plane_cnt)
     {
        struct IGRplane searchplane,listedplane;
        IGRint old_plane_state;
        IGRint num_com_pl,ind_com_pl;
        struct GRid *p_CsBuffer;
        IGRint nb_children;
        IGRint mode,status;
        IGRdouble searchpt[3],searchnm[3],listedpt[3],listednm[3];

        searchplane.point = &searchpt[0];
        searchplane.normal = &searchnm[0];
        listedplane.point = &listedpt[0];
        listedplane.normal = &listednm[0];

        /*** Get the plane info for the search plane ***/
        __DBGpr_int("number of planes to check",plane_cnt);

        status = VRGetPlaneInfo (planetotest,&searchplane);

        __DBGpr_vec("searchplane.point",searchplane.point);
        __DBGpr_vec("searchplane.normal",searchplane.normal);
        __DBGpr_vec("searchpt loc array",searchpt);
        /** TR5901-checking all planes deleted dep planes-only want 4 planes */
        for(ipln=0; ipln<4; ipln++)
        {
           /*** If the planes are the same skip the plane ***/
           differentplanes = 1;
           __DBGpr_obj("planetotest",planetotest);
           __DBGpr_obj("plane_obj[ipln]",plane_obj[ipln]);
           if((planetotest.objid == plane_obj[ipln].objid) &&
              (planetotest.osnum == plane_obj[ipln].osnum)) differentplanes = 0;

           if(differentplanes)
           {
              IGRlong sts;
              /*** Get the plane info for the listed plane ***/
              __DBGpr_obj("Check for duplicates of searchplane",planetotest);
              __DBGpr_obj("Plane to check if duplicate",plane_obj[ipln]);

              status = VRGetPlaneInfo (plane_obj[ipln],&listedplane);

              __DBGpr_vec("searchplane.point",searchplane.point);
              __DBGpr_vec("searchplane.normal",searchplane.normal);
              __DBGpr_vec("listedplane.point",listedplane.point);
              __DBGpr_vec("listedplane.normal",listedplane.normal);
              /*** Are the planes coplanar ***/
              num_com_pl = 0;
              __DBGpr_com("Calling check_coin");
              check_coin( &sts, 1, &searchplane, &listedplane, &num_com_pl, &ind_com_pl );

              if(num_com_pl)
              {
                 /*** Yes- so the listed plane will be replaced by
                                                          the search plane ***/
                 __DBGpr_obj("Duplicate Plane FOUND",plane_obj[ipln]);
                 status = om$send(msg = message VRplane.VRget_plane_state
                     (&old_plane_state),
                    senderid = NULL_OBJID,
                    targetid = plane_obj[ipln].objid,
                    targetos = plane_obj[ipln].osnum);

                    __DBGpr_int("constraint",old_plane_state);

                 if(old_plane_state)
                 {
/********* Could not get this to work for tr4725
                     __DBGpr_obj("constrained plane",plane_obj[ipln]);
                     __DBGpr_int("constraint",old_plane_state);
                     status = om$send(msg = message VRplane.VRchg_plane_state
                           (old_plane_state,old_plane_state),
                             senderid = NULL_OBJID,
                             targetid = planetotest.objid,
                             targetos = planetotest.osnum);

                     nd$wait_batch( type       = GR_GEOM_POSTED,
                                    l_object   = &planetotest,
                                    l_obj_info = &cn_type,
                                    nb_obj     = 1 );
***********/
                 }


                 /*** No need to check for Dep Plane as the VRconsdist linking
                      object is a child of the construction plane         ***/

                 /*** Get the list of children for the listed plane ***/
                 status =
                 om$send( msg      = message NDnode.NDget_objects
                                        ( ND_CHILDREN|ND_IN_BUF,NULL,0,
                                        &p_CsBuffer,0,OM_K_MAXINT,
                                        &nb_children ),
                          senderid = NULL_OBJID,
                          targetid = plane_obj[ipln].objid,
                          targetos = plane_obj[ipln].osnum );
                 as$status();
                 /*** For each child ***/
                 for(jcmp=0; jcmp<nb_children; jcmp++)
                 {
                    /*** Call NDchange_connect ***/
                    __DBGpr_obj("Child of duplicate plane",p_CsBuffer[jcmp]);
                    status = om$send( msg      = message NDnode.NDchange_connect
                                     ( 1, &plane_obj[ipln], &planetotest ),
                          senderid = NULL_OBJID,
                          targetid = p_CsBuffer[jcmp].objid,
                          targetos = p_CsBuffer[jcmp].osnum);
                    as$status();

                    __DBGpr_obj("Calling wait-batch for", p_CsBuffer[jcmp]);
                    /*** Call wait batch ***/
                    cn_type = ND_COMP;
                    nd$wait_batch( type       = GR_GEOM_POSTED,
                                   nb_obj     = 1,
                                   l_object   = &p_CsBuffer[jcmp],
                                   l_obj_info = &cn_type       );
                    mod_made = 1;
                 }
              }

              /*** Delete the listed plane somehow????**/
           }
        }
     }
  }
  if(mod_made)
  {
     __DBGpr_com("Duplicate planes processed");
  }

  return (OM_S_SUCCESS);
}

end implementation VRsketch;
