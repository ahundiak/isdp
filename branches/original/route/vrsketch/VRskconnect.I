/* $Id: VRskconnect.I,v 1.6 2002/04/10 20:33:30 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / VRskconnect.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRskconnect.I,v $
 *	Revision 1.6  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.5  2001/11/08 03:44:31  anand
 *	JTS TR MP 5557
 *	
 *	Revision 1.4  2001/03/08 23:23:04  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.3  2001/02/20 01:17:20  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 19:54:23  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/03  15:38:16  pinnacle
# Created: route/vrsketch/VRskconnect.I by aharihar for Service Pack
#
# Revision 1.2  1998/12/01  14:26:50  pinnacle
# Replaced: vrsketch/VRskconnect.I for: TR 179802027 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/03/06  08:39:18  pinnacle
# Replaced: vrsketch/VRskconnect.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/05/16  19:46:42  pinnacle
# Replaced: vrsketch/VRskconnect.I for:  by hverstee for route240
#
# Revision 1.3  1996/01/19  15:10:10  pinnacle
# Replaced: vrsketch/VRskconnect.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	03/06/98	Alwin	Modified this method to prevent the crash.
 *				The workflow issue this TR179800775, will be
 *				addressed later.
 *	Dec 01 1998	Anand	Verify flow network reports error for a
 *				workflow described in TR.
 *				Basically, the dependent planes are not getting
 *				connected to the control segment as its parents
 *				for the particular workflow.
 *	Nov 07 2001	Anand	Ensure correct me->next_pt for Nozzles and
 *				Comps. Earlier, cpt coordinates were being
 *				passed, so Cnrl Seg would stop short at cpt
 *				rather than go all the way till ref.
 *      04/08/02        law     TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
/****************************************************************************
/*
/* This file contains method to connect two networks
/* 
/* CHANGE HISTORY:  
/*	momo	14-12-1990	: Design date
/*	Manyam	23 June 1993	: Fix for the problem while sketching from a
/*				  Nozzle to a dangle which are collinear
/*				  Cause : Dependent planes are not created and
/*				  attached to the segment.
/*
/*  
/*  ==========================================================================
/*  Starting point		        -----------     End point     CF no
/*  ==========================================================================
/*
/*  FREE_SPACE : No previous segment	----------- 	Nozzle		1
/*  FREE_SPACE : No previous segment    ----------- 	Dangling	2
/*  FREE_SPACE : No previous segment    ----------- 	Pipe		1
/*  FREE_SPACE : No previous segment    ----------- 	Elbow		1
/*  FREE_SPACE : No previous segment    ----------- 	C-Comp		1
/*  FREE_SPACE : No previous segment    ----------- 	Comp Free Cpt	1
/*
/*  FREE_SPACE : previous segment	----------- 	Nozzle		2
/*  FREE_SPACE : previous segment      	----------- 	Dangling	4
/*  FREE_SPACE : previous segment      	----------- 	Pipe		2
/*  FREE_SPACE : previous segment      	----------- 	Elbow		2
/*  FREE_SPACE : previous segment      	----------- 	C-Comp		2
/*  FREE_SPACE : previous segment      	----------- 	Comp Free Cpt	2
/*
/*  Nozzle     				----------- 	Nozzle		1
/*  Nozzle   				----------- 	Dangling    	1
/*  Nozzle   				----------- 	Pipe		1
/*  Nozzle   				----------- 	Elbow       	1
/*  Nozzle   				----------- 	C-Comp      	1
/*  Nozzle   				----------- 	Comp Free Cpt	1
/*
/*  Dangling 				----------- 	Nozzle      	2
/*  Dangling 				----------- 	Dangling    	4
/*  Dangling 				----------- 	Pipe		2
/*  Dangling 				----------- 	Elbow       	2
/*  Dangling 				----------- 	C-Comp      	2
/*  Dangling 				----------- 	Comp Free Cpt	2
/*
/*  Pipe     				----------- 	Nozzle		1
/*  Pipe     				----------- 	Dangling	2
/*  Pipe     				----------- 	Pipe    	1
/*  Pipe     				----------- 	Elbow		1
/*  Pipe     				----------- 	C-Comp		1
/*  Pipe     				----------- 	Comp Free Cpt	1
/*
/*  Elbow    				----------- 	Nozzle		1
/*  Elbow    				----------- 	Dangling	2
/*  Elbow	   			----------- 	Pipe		1
/*  Elbow    				----------- 	Elbow		1
/*  Elbow    				----------- 	C-Comp		1
/*  Elbow    				----------- 	Comp Free Cpt	1
/*
/*  C-Comp				-----------	Nozzle		1
/*  C-Comp				-----------	Dangling	2
/*  C-Comp				-----------	Pipe		1
/*  C-Comp				-----------	Elbow		1
/*  C-Comp				-----------	C-Comp		1
/*  C-Comp				-----------	Comp Free Cpt	1
/*
/*  Comp Free Cpt			-----------	Nozzle		1
/*  Comp Free Cpt			-----------	Dangling	2
/*  Comp Free Cpt			-----------	Pipe		1
/*  Comp Free Cpt			-----------	Elbow		1
/*  Comp Free Cpt			-----------	C-Comp		1
/*  Comp Free Cpt			-----------	Comp Free Cpt	1
/*
/*  Exemple :
/*  =========
/*
/*   - Dangling --- Dangling :
/*
/*                           S1                S2
/*   1- configuration :   --------D1      D2--------     ==> Merge
/*                       
/*                                    S3
/*      RESULT            ==========================
/*
/*                           S1
/*   2- configuration :   --------D1          D2         ==> extend  S1
/*                                             |         ==> delete  D1
/*                                             |S2       ==> replace D2 by El
/*                                             |
/*
/*                                  S1
/*      RESULT            =====================E
/*                                             |
/*                                             |S2
/*                                             |
/*
/*
/*                                             S2
/*   3- configuration         D1          D2--------     ==> extend  S2
/*                            |                          ==> delete  D2
/*                            |S1                        ==> replace D1 by El
/*                            |
/*                           
/*                                    S2
/*      RESULT                E====================
/*                            |
/*                            |
/*                            |
/*
/*  4- configuration          D1              D2         ==> create new segment 
/*                            |                |         ==> replace D1 by El1
/*                            |S1              |S2       ==> replace D2 by El2
/*                            |                |
/*                               
/*                                   S3
/*     RESULT                 E1==============E2
/*                            |                |
/*                            |S1              |S2
/*                            |                |
/*
/**/

class implementation VRsketch;

#include <malloc.h> 
#include <math.h> 

#include "OMmacros.h"
#include "OMprimitives.h"
#include "dpdef.h"
#include "VRcordef.h"
#include "bstypes.h"
#include "nddef.h"
#include "VRclsymbf.h"
#include "VRclsymb.h"
#include "csmacros.h"
#include "ndmacros.h"
#include "asbox.h"
#include "asmacros.h"
#include "VRprivmacros.h"
#include "bsparameters.h"
#include "VRpriv_attr.h"
#include "VRcsdef.h"
#include "AS_status.h"

#include "vrtools_pto.h"
#include "bsdotp.h"
#include "bscollin.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsnorvec.h"
#include "maidmx.h"
#include "vrdbgmacros.h"
#include "VRsketchdef.h"
#include "VRMath.h"

%safe
#include "VX_FIproto.h"
%endsafe

#undef MY_DEBUG

from	GRgraphics      import 	GRdelete, GRconstruct;
from	NDnode		import	NDget_objects, NDdisplay, NDdelete, NDconnect;
from	VRCnrlSeg	import	VRGetTopo, VRget_terminators;
from	VRGeneric	import	VRGetSupports, VRGetIndex, VRConnect,
    				VRGetOrigCoor;
from 	VRNozzle	import	VRGetRefId;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRskconnect( IGRlong *sts )
{
  IGRboolean	UpdateSegLen;	/* needed switch			     */
  IGRboolean	FirstConnect;	/* TRUE : if the first located component has */
				/* free connect point                        */
  IGRboolean	SecondConnect;  /* TRUE : if the second located component    */
				/* has free connect point                    */
  IGRshort	placement_type; /* used to place correction cmp   	     */
  IGRshort	act_param_change;
				/* to know if user has changed    	     */
				/* the active parameters          	     */
  IGRshort	FittingType;	/* needed to update corrections		     */
  IGRshort	ElbowIndex;	/* located elbow index 			     */
  IGRshort	ConnCase=-1;    /* connect case				     */
  IGRint 	i;      	/* loop index                                */
  IGRint 	SegIndex;      	/* index needed to create segment            */
  IGRint	CmpType=0;   	/* Cmp Item name                             */
  IGRint 	ParentNum=0; 	/* Cmp number of parents                     */
  IGRint 	NextIndex; 	/* used to know which will be                */
				/* moved if extend                           */
  IGRint        mode_batch;	/* mode batch                                */
  IGRint        FirstIndex;	/* plane index                               */
  IGRint 	nb_father; 	/* used by get_planes message                */
  IGRint 	nb_children;
				/* used by get_objects message               */
  BSrc	 	bsretcode;      /* math func return code                     */
  IGRboolean	bAligned=FALSE; /* what case : extend or not                 */
  IGRint	NewPlIndex;
  IGRshort	DangIndex;      /* dangling index                            */
  IGRshort	DummyFlag=0;	/* dangling begining index                   */
  IGRshort	FirstPlaceType=VR_NEW_COMP;
  IGRshort	SecondPlaceType=VR_NEW_COMP;
  IGRshort	CmpIndex[3];	/* index of component to place               */
  IGRlong	retcode;        /* return code                               */
  IGRlong 	status;         /* return code                               */
  IGRdouble	CmpAngle;       /* component angle                           */
  IGRdouble	CmpPt[6];       /* connection points coordinates             */
  IGRdouble	SegEndPt[6];	/* end points of CS to create                */
  IGRdouble	OrientSection[6];
				/* used by HVAC to orient section            */
  IGRdouble	*p_OrientSection;
				/* used by HVAC to orient section            */
  IGRdouble	section_matrix[9];
				/* section matrix                            */
  IGRmatrix	matrix;         /* matrix needed by GRxform                  */
  IGRboolean	flag=FALSE;     /* used by def_planes function               */
  IGRint	ConcFlag=0;
  IGRint	Flag;
  struct 	GRid 		CorId;          /**/
  struct 	GRid 		FirstPrevId; 
  struct GRid 	CnrlSegId;      /* GRid of the CnrlSeg to create             */
  struct GRid 	NewEndSegmentId;
				/* return by split function                  */
  struct GRid 	NewStartSegmentId;
				/* return by split function                  */
  struct GRid 	ElbowEndSecSegId;
  struct GRid 	ElbowStartSecSegId;
  struct GRid	CmpSegId;       /* component segment's GRid                  */
  struct GRid 	StartDepPlanesId[3];
  struct GRid 	EndDepPlanesId[3];
				/* planes created to connect to nozzle or to */
				/* component with free cpt inter OS	     */
  struct GRid	SrcPlanesId[8];
				/* list of initial planes                    */
  struct GRid	NewPlanesId[16];/* planes parent of CnrlSeg                  */
  struct GRid	CmpParentsList[VR_MAX_CPTS];
				/* Compponent topology Templates             */
				/* GRid list                                 */
  struct GRid	ActParamId;     /* used to place TEE                         */
  struct GRid	BufParamId;     /* used to place TEE                         */
  struct GRid	ConParamId; 
  struct GRid	ConUserParamId; 
  struct GRid 	CmpToConnectId;
  struct GRid	TempId[4];

  SetProc( Md VRskconnect ); Begin 

  *sts = MSSUCC;

  /*"FirstType = %d ... SecondType = %d\n", me->FirstType, me->SecondType */

  /* init variables */
  CmpAngle                = 0.0;	/* angle needed to orient component */
  p_OrientSection         = NULL; 	/* section used in HVAC and Raceway */
  CnrlSegId.objid         = NULL_OBJID;
  NewEndSegmentId.objid   = NULL_OBJID;
  NewStartSegmentId.objid = NULL_OBJID;  

  for( i = 0; i<3; i++ )
  {
    StartDepPlanesId[i].objid = NULL_OBJID;
    EndDepPlanesId[i].objid   = NULL_OBJID;
  }

  /* initialization needed if the located components are in a ref. file */
  for( i=0; i<8; i++ ) SrcPlanesId[i].objid = NULL_OBJID;

  FirstConnect  =    me->FirstType == IS_NOZZLE
    || me->FirstType == IS_CONC_COMP
    || me->FirstType == IS_COMP_TO_CONNECT
    || me->FirstType == IS_DANGLING_TO_CONNECT;

  SecondConnect =    me->SecondType == IS_NOZZLE
    || me->SecondType == IS_CONC_COMP
    || me->SecondType == IS_COMP_TO_CONNECT;

#ifdef MY_DEBUG
  printf ("VRSKCONNECT FirstType = %d SecondType = %d Extend=%d\n",
	  me->FirstType, me->SecondType, me->extend);
#endif

  /* In this method the system can place new segment ==> we need symbology */

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

  /* we need later to execute the batch queu if the batch mode is not differ */
  nd$mod_batch( request    = ND_GET,
		p_ret_mode = &mode_batch );

  /*| retreive user attribut from the located object */
  status = VR$GetCmpAttributes( 	p_retmsg	= &retcode,
					Product		= me->Product,
					p_ComponentId	= &me->SecondLocatedElemId,
					p_SysParamId	= &ConParamId,
					p_UserParamId	= &ConUserParamId,
					p_MdEnv		= &me->SecondLocatedElemMdEnv );
  as$status( action = GOTO_VALUE, value = wrapup );
  as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );  

  /*^ VRprint_user_attr( &ConParamId ); */
  /*^ VRprint_user_attr( &ConUserParamId ); */

  /* get first elbow information ( supports and attributes ) if to start user was located an
  /* elbow
  /**/
  if( me->FirstType == IS_ELBOW )
  {
    status = om$send( msg      = message VRsketch.VRSkGetElbowPrevSeg
		      ( &retcode, &me->FirstLocatedElemId, &me->prev_seg_id,
			&ElbowStartSecSegId
		      ),
		      targetid = my_id );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );  

    /*"prev_seg = %d\n", me->prev_seg_id.objid */

    status = VRSkGetAttrFromCmp
      ( me->Product, &me->ActParamId, &me->BufParamId, &me->UsrParamId,
	&me->FirstLocatedElemId, &ElbowStartSecSegId, &me->prev_seg_id, &me->ModuleInfo
      );
    as$status( action = RET_STATUS );
  }
  else
  {
    /* Get active parameters */
    status = VR$GetAttributes( 	p_retmsg	= &retcode,
				Product		= me->Product,
				p_SysParamId	= &me->ActParamId,
				p_UserParamId	= &me->UsrParamId,
				p_MdEnv		= &me->ModuleInfo );
    as$status( action = GOTO_VALUE, value = wrapup );
  }

  /* get needed information from end located component */
  switch( me->SecondType )
  {
    case IS_DANGLING :
      __DBGpr_com("Second locate is dangle");  
      if( me->SecondLocatedElemMdEnv.md_id.osnum != me->ModuleInfo.md_id.osnum )
      {
	ex$message( field   = ERROR_FIELD, in_buff = "No yet implemented!" );
	*sts = MSFAIL;
	End
	  return OM_S_SUCCESS;
      }

      /*| get the dangling parent segment's id */
      status = om$send(msg      = message VRGeneric.VRGetSupports
		       ( &retcode, 1, &CmpSegId, &nb_father ),
		       targetid = me->SecondLocatedElemId.objid,
		       targetos = me->SecondLocatedElemId.osnum );
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );      
      __DBGpr_obj("segid parent of dangling",CmpSegId);
      /*| get dangling support's planes needed to share network planes */
      status = om$send( msg      = message NDnode.NDget_objects
			( ND_ROOT, &SrcPlanesId[4], 4, NULL, 0,
			  OM_K_MAXINT, &nb_father
			),
			targetid = CmpSegId.objid, 
			targetos = CmpSegId.osnum);
      as$status( action = GOTO_VALUE, value = wrapup );
      __DBGpr_obj(" SrcPlanesId -0",SrcPlanesId[4]);
      __DBGpr_obj(" SrcPlanesId -1",SrcPlanesId[5]);
      __DBGpr_obj(" SrcPlanesId -2",SrcPlanesId[6]);

      __DBGpr_com(" Get dangling component index");
      /* this index is needed to replace the dangling by the elbow and to call share planes 
      /* function
      /**/
      status = om$send( msg      = message VRGeneric.VRGetIndex
			( &retcode, &CmpSegId, &DangIndex ),
			targetid = me->SecondLocatedElemId.objid,
			targetos = me->SecondLocatedElemId.osnum);
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );      

      if( DangIndex == 0 )
      {
	DummyFlag = BEGIN_OF_SEG;
	NextIndex = 4; /* index of first plane */
	__DBGpr_com("DummyFlag is BEGIN_OF_SEG and NextIndex = 4");
      }
      else
      {
	NextIndex = 7; /* index of end plane */
	DummyFlag = END_OF_SEG;
	__DBGpr_com("DummyFlag is END_OF_SEG and NextIndex = 7");
      }

      /* get segment terminator points to know if is it an extend */  
      status = om$send( msg      = message VRCnrlSeg.VRget_terminators
			( &retcode, &nb_children, &me->ModuleInfo,
			  CmpPt, NULL 
			),
			targetid = CmpSegId.objid,
			targetos = CmpSegId.osnum);
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );      

      /********* This was here for 262 ************/
      {
		bAligned = BScollin ( &bsretcode,
				&CmpPt[0], me->first_pt,&CmpPt[3]);
      }

      /* see if merge */
      if( me->FirstType == IS_DANGLING && bAligned )
      {
	IGRdouble	PrevVect[3], ConnVect[3];

	status = om$send( msg      = message VRCnrlSeg.VRGetTopo
			  ( &retcode, PrevVect, NULL, NULL, NULL, NULL, 
			    &me->ModuleInfo
			  ),
			  targetid = me->prev_seg_id.objid,
			  targetos = me->prev_seg_id.osnum);
	as$status( action = GOTO_VALUE, value = wrapup );
	as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );      

	BSmkvec( &bsretcode, ConnVect, &CmpPt[0], &CmpPt[3] );
	BSnorvec( &bsretcode, ConnVect );
	__DBGpr_com("Getting 1st to 4th point");
	__DBGpr_vec("4th pt",&CmpPt[3]);
	__DBGpr_vec("ConnVect", ConnVect);
	if( ( 1 - fabs( BSdotp( &bsretcode, PrevVect, ConnVect ) ) ) < VRGetTol(VR_DOTPROD_TOL) )
	{
	  me->extend = TRUE;
	}
      }

      break;

    case IS_PIPE :

      /*| Located object is a pipe */

      {
	IGRvector 	TmpVect;

	/* connect with zero distance ==> we need to set me->extend to TRUE for later */
	BSmkvec( &bsretcode, TmpVect, me->first_pt, me->next_pt );
	if( BSlenvec( &bsretcode, TmpVect ) < VRGetTol(VR_LENGTH_TOL) ) me->extend = TRUE;
      }

      /* get pipe support ( segment to split ) */
      status = VRSkGetPipeVirtualSupportInfo
	( &me->SecondLocatedElemId, me->next_pt, &me->ModuleInfo, &CmpSegId, NULL, NULL );
      as$status( action = GOTO_VALUE, value = wrapup );

      /* split the segment */
      status = VR$SplitSegment( p_retmsg		= &retcode,
				p_SegmentToSplitId	= &CmpSegId,
				p_SplitPoint		= me->next_pt,
				p_MdEnv			= &me->ModuleInfo,
				p_NewSegmentId		= &NewEndSegmentId );
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

      /*| get planes */
      status = om$send( msg      = message NDnode.NDget_objects
			( ND_ROOT, &SrcPlanesId[4], 4, NULL, 0, OM_K_MAXINT, 
			  &nb_father
			),
			targetid = CmpSegId.objid, 
			targetos = CmpSegId.osnum);
      as$status( action = GOTO_VALUE, value = wrapup );
      __DBGpr_obj(" SrcPlanesId -0",SrcPlanesId[4]);
      __DBGpr_obj(" SrcPlanesId -1",SrcPlanesId[5]);
      __DBGpr_obj(" SrcPlanesId -2",SrcPlanesId[6]);

      NextIndex = 7;
      DummyFlag = END_OF_SEG;

      break;

    case IS_ELBOW :

      /*| Second Located object is an elbow */

      /* get primary and secondary supports of the elbow */
      status = om$send( msg      = message VRsketch.VRSkGetElbowPrevSeg
			( &retcode, &me->SecondLocatedElemId, &CmpSegId, 
			  &ElbowEndSecSegId
			),
			targetid = my_id );
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

      /*"CmpSegId      = %d\n", CmpSegId.objid      */
      /*"ElbowEndSecSegId = %d\n", ElbowEndSecSegId.objid */

      /*| get planes from the secondary to share network planes later */
      status = om$send( msg      = message NDnode.NDget_objects
			( ND_ROOT, &SrcPlanesId[4], 4, NULL, 0,
			  OM_K_MAXINT, &nb_father
			),
			targetid = ElbowEndSecSegId.objid, 
			targetos = ElbowEndSecSegId.osnum);
      as$status( action = GOTO_VALUE, value = wrapup );
      __DBGpr_obj(" SrcPlanesId -0",SrcPlanesId[4]);
      __DBGpr_obj(" SrcPlanesId -1",SrcPlanesId[5]);
      __DBGpr_obj(" SrcPlanesId -2",SrcPlanesId[6]);

      /* get elbow index needed to place the Tee and to call share planes function */
      status = om$send( msg      = message VRGeneric.VRGetIndex
			( &retcode, &ElbowEndSecSegId, &DangIndex ),
			targetid = me->SecondLocatedElemId.objid,
			targetos = me->SecondLocatedElemId.osnum);
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

      if( ! DangIndex )
      {
	NextIndex = 4;
	DummyFlag = BEGIN_OF_SEG;
      }
      else              
      {
	__DBGpr_com("defining NextIndex = 7");
	NextIndex = 7;
	DummyFlag = END_OF_SEG;  
      }

      break;

    case IS_CONC_COMP :
    case IS_COMP_TO_CONNECT:
    case IS_NOZZLE:
      __DBGpr_com(" end located component is a nozzle");
      /*| Connect component */
      status = VRGetCompPlanes
	( &retcode, &me->SecondLocatedElemId, me->SecondCptNum, NULL, 
	  &me->SecondLocatedElemMdEnv,&me->ModuleInfo,&SrcPlanesId[4],
	  EndDepPlanesId );
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

      __DBGpr_objlist("EndDepPlanesId",3,EndDepPlanesId);

      __DBGpr_obj(" prev_seg_id", me->prev_seg_id );

      /* Below lines added by Anand for TR 179802027 */

      if( me->SecondType == IS_NOZZLE		&&
	  me->prev_seg_id.objid != NULL_OBJID	&&
	  me->extend )
      {
	/* Above if condition holds true for the workflow mentioned in TR desc
	   as well as the more generic case of all sketches from a piping
	   component to a nozzle (that lie in the same line) thru the locate
	   of the sketch command. If the condition holds, connect the
	   dependent plane to the control segment.	- Anand (Nov '98) */

	status = 
	  om$send( msg      = message NDnode.NDconnect( 
						       3, EndDepPlanesId, NULL_GRID, ND_NEW ),
		   targetid = me->prev_seg_id.objid,
		   targetos = me->prev_seg_id.osnum );
	as$status( action = RET_STATUS );

	__DBGpr_obj(" End Dep. Planes connected to prev_seg_id", me->prev_seg_id );
      }

      /* Above lines added by Anand for TR 179802027 */

      /*| needed later to call share planes function */
      NextIndex = 4;
      SrcPlanesId[7].objid = NULL_OBJID;
      break;

    default : 
      NextIndex = 0;
      break;
  }
  __DBGpr_objlist("VRsketch.VRskcontodan:SrcPlanesId[4-8]",4,&SrcPlanesId[4]);

  if( me->prev_seg_id.objid == NULL_OBJID )
  {
    __DBGpr_int("Is Aligned?", bAligned );

    if( bAligned )
    {
      if( FirstConnect )
      {
	__DBGpr_com("A first component can be : nozzle, VRConcComp or free cpts component the second component is a dangling");

	/*A erase and delete the dangling */
	status =
	  om$send( msg	= message NDnode.NDdisplay( 
						   0, GRbehe, &me->ModuleInfo ),
		   targetid = me->SecondLocatedElemId.objid, 
		   targetos = me->SecondLocatedElemId.osnum);
	as$status();

	status = 
	  om$send( msg	= message NDnode.NDdelete(
						  &me->ModuleInfo ),
		   targetid = me->SecondLocatedElemId.objid, 
		   targetos = me->SecondLocatedElemId.osnum);
	as$status( action = RET_STATUS );

	/*A make ASsource object as required for the first 
	  component located					*/
	status = 
	  VR$MakeSource( 	p_msg		= &retcode,
				p_ComponentId	= &me->FirstLocatedElemId,
				nCpNum		= me->FirstCptNum,
				p_CompMdEnv 	= &me->FirstLocatedElemMdEnv,
				p_MdEnv		= &me->ModuleInfo,
				p_ConnectorId 	= &CmpToConnectId );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	__DBGpr_obj("CmpToConnectId",CmpToConnectId); 

	if( CmpToConnectId.osnum != me->FirstLocatedElemId.osnum ||
	    me->FirstType == IS_NOZZLE )

	{

	  __DBGpr_com(" Ref. file or Nozzle");

	  /*A GetCompPlanes function create the dependent planes and
	    call VRMakeConstrains function to constrain the dependent
	    planes and given SrcPlanesId. This process needs to be
	    done for both nozzles and inter OS routing : Manyam	*/
	  __DBGpr_obj("Setting SrcPlanesId[0] to NextIndex",SrcPlanesId[NextIndex]);
	  SrcPlanesId[0] = SrcPlanesId[NextIndex]; /* fst or end plane */
	  SrcPlanesId[1] = SrcPlanesId[5];
	  SrcPlanesId[2] = SrcPlanesId[6];


	  status = VRGetCompPlanes(
				   &retcode, &me->FirstLocatedElemId, me->FirstCptNum,
				   NULL, &me->FirstLocatedElemMdEnv, &me->ModuleInfo,
				   SrcPlanesId, TempId );
	  as$status( action = RET_STATUS );
	  as$status( sts = retcode, action = RET_STATUS );

	  __DBGpr_obj(" PlanesId -0",TempId[0]);
	  __DBGpr_obj(" PlanesId -1",TempId[1]);
	  __DBGpr_obj(" PlanesId -2",TempId[2]);

	  /*"CompPl = %d %d %d\n", TempId[0].objid, TempId[1].objid, TempId[2].objid */

	  /*A connect the dependent plane to the dangling segment */
	  status = 
	    om$send( msg      = message NDnode.NDconnect( 
							 3, TempId, NULL_GRID, ND_NEW ),
		     targetid = CmpSegId.objid,
		     targetos = CmpSegId.osnum );
	  as$status( action = RET_STATUS );

	  __DBGpr_obj(" CmpSegId",CmpSegId);

	  /*A In case of a Nozzle, it needs to be connected to the
	    the segment  : Manyam : Fix for Yarrow's benchmark	*/
	  if ( me->FirstType == IS_NOZZLE )
	    TempId[0] = CmpSegId;
	  else	TempId[3] = CmpSegId;

	}
	else TempId[0] = CmpSegId; 

	status = 
	  om$send( msg      = message VRGeneric.VRConnect(
							  &retcode, TempId, 0, me->FirstCptNum,
							  &me->ModuleInfo ),
		   targetid = CmpToConnectId.objid, 
		   targetos = CmpToConnectId.osnum);
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
      }

      /*A calculate the xform matrix and apply it to the right planes */
      MAidmx( &bsretcode, matrix );
      __DBGpr_com("plane being moved from first_pt to next_pt");
      matrix[3]  = me->first_pt[0] - me->next_pt[0];
      matrix[7]  = me->first_pt[1] - me->next_pt[1];
      matrix[11] = me->first_pt[2] - me->next_pt[2];

      __DBGpr_obj("VRskxform called with",SrcPlanesId[NextIndex]);
      status = 
	VRskxform( &retcode, matrix, &SrcPlanesId[NextIndex], &me->ModuleInfo );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      status = 
	VR$ComputeCorrection( 	p_retmsg	= &retcode,
				p_SegmentId	= &CmpSegId,
				p_MdEnv		= &me->ModuleInfo );
      as$status();
      as$status( sts = retcode );

      End
	return(OM_S_SUCCESS);
    }
    else
    {
      __DBGpr_com(" no previous segment and not aligned with end component");

      /* update SegEndPt to call def_planes */
      for(i=0; i<3; i++ )
      {
	SegEndPt[i]   = me->first_pt[i];
	SegEndPt[i+3] = me->next_pt[i];
      }

      __DBGpr_int("FirstType ", me->FirstType);

      switch( me->FirstType )
      {
	case IS_NOZZLE :
	case IS_CONC_COMP :
	case IS_COMP_TO_CONNECT :
	case IS_DANGLING_TO_CONNECT :
	  status = VRGetCompPlanes
	    ( &retcode, &me->FirstLocatedElemId, me->FirstCptNum, NULL, 
	      &me->FirstLocatedElemMdEnv, &me->ModuleInfo, SrcPlanesId,
	      StartDepPlanesId );
	  as$status( action = RET_STATUS );
	  as$status( sts = retcode, action = RET_STATUS );

	  /*"CompPl = %d %d %d\n", SrcPlanesId[0].objid,SrcPlanesId[1].objid,SrcPlanesId[2].objid */

	  __DBGpr_obj(" SrcPlanesId[NextIndex] first plane (4)", SrcPlanesId[NextIndex]);
	  Flag = VR_PLANES_PLANES;
	  ConcFlag = 1;
	  SrcPlanesId[3] = SrcPlanesId[NextIndex]; /* fst or end plane */
	  SrcPlanesId[4] = SrcPlanesId[5];
	  SrcPlanesId[5] = SrcPlanesId[6];
	  break;

	default :
	  /*| start from Free Space */
	  Flag = VR_NO_TOPO_PLANES;
	  SrcPlanesId[0] = SrcPlanesId[NextIndex]; /* fst or end plane */
	  SrcPlanesId[1] = SrcPlanesId[5];
	  SrcPlanesId[2] = SrcPlanesId[6];
      }

      switch( me->SecondType )
      {
	case IS_NOZZLE :
	case IS_COMP_TO_CONNECT:
	case IS_CONC_COMP :
	  flag = TRUE;
	  ConcFlag = 2;
      }

      status = VR$DefineSegPlanes(	p_retmsg	= &retcode,
					TopoFlag	= Flag,
					p_InPutPlanes	= SrcPlanesId,
					p_SegmentPt0	= &SegEndPt[0],
					p_SegmentPt1	= &SegEndPt[3],
					SharePlanes	= flag,
					InPutPlanesType	= ConcFlag,
					p_MdEnv		= &me->ModuleInfo,
					p_OutPutPlanes	= NewPlanesId );
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

      __DBGpr_int("TopoFlag ",Flag);
      if( Flag == 5 )
      {
	NewPlIndex = 6;
	/*| update the connection ==> change connection to update the graph */
	status = VRskUpdateConnection( SrcPlanesId, NewPlanesId, 6 );
	as$status( action = GOTO_VALUE, value = wrapup );
      }
      else NewPlIndex = 0;

#ifdef vdsDEBUG
      printf("CnrlSeg planes = \t\t%d %d %d %d\n", NewPlanesId[NewPlIndex].objid,
	     NewPlanesId[NewPlIndex+1].objid,
	     NewPlanesId[NewPlIndex+2].objid,
	     NewPlanesId[NewPlIndex+3].objid );
#endif

      SegIndex = NewPlIndex+4;

      if( StartDepPlanesId[0].objid != NULL_OBJID )
      {
	/*| StartDepPlanesId to add */

	NewPlanesId[SegIndex]   = StartDepPlanesId[0];
	NewPlanesId[SegIndex+1] = StartDepPlanesId[1];
	NewPlanesId[SegIndex+2] = StartDepPlanesId[2];

	/*"New segment planes = %d\n", NewPlanesId[SegIndex].objid */   
	/*"New segment planes = %d\n", NewPlanesId[SegIndex+1].objid */   
	/*"New segment planes = %d\n", NewPlanesId[SegIndex+2].objid */   

	me->assoc_list.num_parents += VR_NB_DEP_PLANES;

	SegIndex += 3;
      }

      if( EndDepPlanesId[0].objid != NULL_OBJID )
      {
	/*| EndDepPlanesId to add */

	NewPlanesId[SegIndex]   = EndDepPlanesId[0];
	NewPlanesId[SegIndex+1] = EndDepPlanesId[1];
	NewPlanesId[SegIndex+2] = EndDepPlanesId[2];

	/*"New segment planes = %d\n", NewPlanesId[SegIndex].objid */   
	/*"New segment planes = %d\n", NewPlanesId[SegIndex+1].objid */   
	/*"New segment planes = %d\n", NewPlanesId[SegIndex+2].objid */   

	me->assoc_list.num_parents += VR_NB_DEP_PLANES;
      }

      __DBGpr_com(" creation of the prevseg");
      me->assoc_list.parents = &NewPlanesId[NewPlIndex];
      me->prev_seg_id.osnum = me->ModuleInfo.md_id.osnum;
      status = om$construct(classname = "VRCnrlSeg", 
			    p_objid   = &me->prev_seg_id.objid, 
			    osnum     = me->prev_seg_id.osnum,
			    msg       = message GRgraphics.GRconstruct( &me->const_list ) );
      as$status( action = GOTO_VALUE, value = wrapup );

      __DBGpr_obj("CS id ", me->prev_seg_id);

      status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleInfo ),
			targetid = me->prev_seg_id.objid, 
			targetos = me->prev_seg_id.osnum);
      as$status();

#ifdef MY_DEBUG
      printf ("first/secondtype %d %d \n",me->FirstType,me->SecondType);
#endif
      switch( me->FirstType )
      {
	case FREE_SPACE :

	  /*| FREE_SPACE ==> create dangling at the begining of the CS */
	  CmpIndex[0] = 0; /* BEGIN DANGLING */
	  status = VR$PlaceCmpByItemName( 	p_retmsg             	= &retcode,
						Product	   		= me->Product,
						TopoParentsNum    	= 1,
						p_TopoParentsList 	= &me->prev_seg_id,
						p_CmpIndexOnTopo  	= CmpIndex,
						p_CmpAngle        	= &CmpAngle,
						p_MdEnv       		= &me->ModuleInfo,
						p_ActParamId      	= &me->ActParamId,
						p_UserParamId     	= &me->UsrParamId,
						p_CmpCstList      	= &me->cmp_const_list );
	  as$status( action = GOTO_VALUE, value = wrapup );
	  as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );
	  break;

	case IS_NOZZLE : 
	case IS_CONC_COMP :
	case IS_COMP_TO_CONNECT:
	case IS_DANGLING_TO_CONNECT : 
	  /*| connect to conc comp */
	  status = VR$MakeSource( p_msg		= &retcode,
				  p_ComponentId	= &me->FirstLocatedElemId,
				  nCpNum	= me->FirstCptNum,
				  p_CompMdEnv	= &me->FirstLocatedElemMdEnv,
				  p_MdEnv	= &me->ModuleInfo,
				  p_ConnectorId = &CmpToConnectId );
	  as$status( action =  GOTO_VALUE, value = wrapup );
	  as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

	  if( CmpToConnectId.osnum != me->FirstLocatedElemId.osnum )
	  {
	    TempId[0] = StartDepPlanesId[0];
	    TempId[1] = StartDepPlanesId[1];
	    TempId[2] = StartDepPlanesId[2];
	    TempId[3] = me->prev_seg_id;
	  }
	  else TempId[0] = me->prev_seg_id;

	  status = om$send( msg      = message VRGeneric.VRConnect
			    ( &retcode, TempId, 0, me->FirstCptNum,
			      &me->ModuleInfo
			    ),
			    targetid = CmpToConnectId.objid, 
			    targetos = CmpToConnectId.osnum);
	  as$status( action =  GOTO_VALUE, value = wrapup );
	  as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );
	  break;

	default : as$status( sts = OM_E_ABORT, msg = "First Point not valid" );
		  goto wrapup;
      }

      /* add new segment to the buffer */
      if( me->num_of_seg >= MAX_SEG )
	om$vla_set_dimension( varray = me->seg_GRid, size  = me->num_of_seg+1 );
      me->seg_GRid[me->num_of_seg] = me->prev_seg_id;
      me->num_of_seg += 1;
    }
  }
  else
  {
    __DBGpr_com(" there is a previous segment");

    /* me->extend is for first point, extend is for end point */
    /*"extend = %d .. me->extend = %d\n", bAligned, me->extend */
    __DBGpr_int(" Aligned?",bAligned);
    __DBGpr_int(" extend?",me->extend);

    /* determine connect configuration */
    if( bAligned && me->extend   ) ConnCase = 0;
    else if( bAligned && !me->extend  ) ConnCase = 1;
    else if( !bAligned && me->extend  ) ConnCase = 2;
    else if( !bAligned && !me->extend ) ConnCase = 3;

    /* See example given at beginning: ConnCase = 0 ==> 1- configuration
     *                                 ConnCase = 1 ==> 3- configuration
     *                                 ConnCase = 2 ==> 2- configuration
     *                                 ConnCase = 3 ==> 4- configuration
     */
    __DBGpr_int(" ConnCase", ConnCase);
    __DBGpr_int(" First component type", me->FirstType);
    __DBGpr_int(" Second component type", me->SecondType);

    /* get all needed information to share planes and replace components */
    switch( me->FirstType )
    {
      case IS_PIPE :
	/*| start from pipe ==> split segment */
	status = VR$SplitSegment( p_retmsg		= &retcode,
				  p_SegmentToSplitId	= &me->prev_seg_id,
				  p_SplitPoint		= me->first_pt,
				  p_MdEnv		= &me->ModuleInfo,
				  p_NewSegmentId	= &NewStartSegmentId );
	as$status( action = GOTO_VALUE, value = wrapup );
	as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

	FirstPrevId = me->prev_seg_id; /* needed to display correction */
	break;

      case IS_ELBOW :
	/* get FirstIndex value */
	status = om$send( msg      = message VRGeneric.VRGetIndex
			  ( &retcode, &ElbowStartSecSegId, &ElbowIndex ),
			  targetid = me->FirstLocatedElemId.objid,
			  targetos = me->FirstLocatedElemId.osnum);
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	if( ! ElbowIndex ) FirstIndex = 0;
	break;

      default : break;
    }

    if( ConnCase == 0 )
    {
      VRis_change_param( me->Product, &me->ActParamId, &ConParamId, me->twist_orient, 
			 me->twist_save, &act_param_change, &placement_type, &me->ModuleInfo
		       );
      /*"act_param_change = %d\n", act_param_change */
      /*"placement_type   = %d\n", placement_type   */

      if( ! act_param_change )
      {   
	__DBGpr_com("VRskmerge called here");
	status = om$send( msg      = message VRsketch.VRskmerge( &retcode ),
			  targetid = my_id );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
	End
	  return OM_S_SUCCESS;
      }
    }

    if( me->FirstType == IS_ELBOW )
    {
      /* get previous segment's planes */
      status = om$send( msg = message NDnode.NDget_objects
			( ND_ROOT, SrcPlanesId, 4, NULL, 0, OM_K_MAXINT, &nb_father ),
			targetid = ElbowStartSecSegId.objid, 
			targetos = ElbowStartSecSegId.osnum);
      as$status( action = RET_STATUS );
    }
    else
    {
      __DBGpr_obj("Getting planes for",me->prev_seg_id);
      /* get previous segment's source planes */
      status = om$send( msg = message NDnode.NDget_objects
			( ND_ROOT, SrcPlanesId, 4, NULL, 0, OM_K_MAXINT, &nb_father ),
			targetid = me->prev_seg_id.objid, 
			targetos = me->prev_seg_id.osnum);
      as$status( action = GOTO_VALUE, value = wrapup );
    }

    __DBGpr_objlist("SrcPlanes before messing up", 8, SrcPlanesId);

    FirstIndex = 3; /* initialization needed later to share planes network */
    if( me->FirstType == IS_DANGLING && me->CmpPosition == BEGIN_OF_SEG )
      FirstIndex = 0;

    /* update src list to call def_planes */
    SrcPlanesId[0] = SrcPlanesId[FirstIndex];
    __DBGpr_int(" first index",FirstIndex); 
    __DBGpr_int(" next index",NextIndex); 

    __DBGpr_obj("4th plane being set to",SrcPlanesId[NextIndex]);
    SrcPlanesId[3] = SrcPlanesId[NextIndex]; /* fst or end plane */
    SrcPlanesId[4] = SrcPlanesId[5];
    SrcPlanesId[5] = SrcPlanesId[6];

    __DBGpr_objlist(" Input Planes for DefineSegPlanes", 8, SrcPlanesId );

    /* update SegEndPt to call def_planes */
    __DBGpr_vec("first SegEndPt",me->first_pt);
    __DBGpr_vec("second SegEndPt",me->next_pt);
    for(i=0; i<3; i++ )
    {
      SegEndPt[i]   = me->first_pt[i];

      if( me->SecondType != IS_NOZZLE &&
	  me->SecondType !=IS_COMP_TO_CONNECT )
      /* See comment in switch statement somewhere below. - Anand */
	  SegEndPt[i+3] = me->next_pt[i];
    }

    /* case 5 : dangling --> dangling */
    /* in this case we give to def_planes function the three end planes  */
    /* of the previous segment and of the dangling parent's segment      */
    /* def_planes returns :                                              */
    /* - planes of the previous segment whose can be changed             */
    /* - the end plane of dangling parant's segment whose can be changed */
    /*   too and the four planes of the current CnrlSeg                  */

    switch( me->SecondType )
    {
      case IS_NOZZLE:
      case IS_COMP_TO_CONNECT:
	  /* Overwrite Segment end point for Nozzle and component. me->next_pt
	   * stores the cpt location, whereas for components (COMP_TO_CONNECT)
	   * and nozzles (NOZZLE) with a non-zero cp_offset, the connect point
	   * should not be the end point of the segment.	- Anand */
	  status =
	  om$send( msg = message VRGeneric.VRGetOrigCoor( &retcode, me->next_pt,
							  &(me->ModuleInfo) ),
			    targetid = me->SecondLocatedElemId.objid,
			    targetos = me->SecondLocatedElemId.osnum );
	  __DBGpr_vec(" Overwrote me->next_pt for 2nd comp", me->next_pt );
	  SegEndPt[3] = me->next_pt[0];
	  SegEndPt[4] = me->next_pt[1];
	  SegEndPt[5] = me->next_pt[2];

      case IS_CONC_COMP:

	  if( ConnCase != 2 )
	      ConcFlag = 1;
	  else
	      ConcFlag = 0;
	  break;

      default : ConcFlag = 0;
    }
    __DBGpr_com("DefineSegPlanes called here");
    status = VR$DefineSegPlanes(	p_retmsg	= &retcode,
					TopoFlag	= VR_PLANES_PLANES,
					p_InPutPlanes	= SrcPlanesId,
					p_SegmentPt0	= &SegEndPt[0],
					p_SegmentPt1	= &SegEndPt[3],
					SharePlanes	= flag,
					InPutPlanesType	= ConcFlag,
					p_MdEnv		= &me->ModuleInfo,
					p_OutPutPlanes	= NewPlanesId );
    as$status( action = GOTO_VALUE, value = wrapup );
    as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

#ifdef vdsDEBUG
    for( i=0; i<6; i++ )
      printf("\tsrc planes[%d] = %d ; \t NewPlanesId[%d] = %d\n",
	     i, SrcPlanesId[i].objid, i, NewPlanesId[i].objid );
#endif

    __DBGpr_com("VRskUpdateConnection called here");
    /*| update the connection ==> change connection to update the graph */
    status = VRskUpdateConnection( SrcPlanesId, NewPlanesId, 6);
    as$status( action = GOTO_VALUE, value = wrapup );

    /* get needed information to replace components */
    if( me->FirstType == IS_DANGLING || me->FirstType == IS_ELBOW )
    {
      FirstPlaceType = VR_OLD_COMP;
    }
    __DBGpr_int("ConnCase",ConnCase);
    if( ConnCase == 3 )
    {    
      /*^
	for( i=6; i<10; i++ ) 
	printf("VRsketch.VRskcontodan : \t CS pl[%d] = %d\n",
	i-6, NewPlanesId[i].objid );
       */

      if( EndDepPlanesId[0].objid != NULL_OBJID )
      {
	NewPlanesId[10] = EndDepPlanesId[0];
	NewPlanesId[11] = EndDepPlanesId[1];
	NewPlanesId[12] = EndDepPlanesId[2];

	/*"New segment planes 4 = %d\n", NewPlanesId[10].objid */   
	/*"New segment planes 5 = %d\n", NewPlanesId[11].objid */   
	/*"New segment planes 6 = %d\n", NewPlanesId[12].objid */   

	me->assoc_list.num_parents += VR_NB_DEP_PLANES;
      }

      /*| creation of the CnrlSeg */
      me->assoc_list.parents = &NewPlanesId[6];
      CnrlSegId.osnum = me->ModuleInfo.md_id.osnum;
      status = om$construct(classname = "VRCnrlSeg", 
			    p_objid   = &CnrlSegId.objid, 
			    osnum     = CnrlSegId.osnum,
			    msg       = message GRgraphics.GRconstruct( &me->const_list ) );
      as$status( action = GOTO_VALUE, value = wrapup );
      __DBGpr_obj(" new CS id ", CnrlSegId );

      status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleInfo ),
			targetid = CnrlSegId.objid, 
			targetos = CnrlSegId.osnum);
      as$status();

      /*| add the new segment in the buffer */
      if( me->num_of_seg >= MAX_SEG )
	om$vla_set_dimension( varray = me->seg_GRid, size  = me->num_of_seg+1 );
      me->seg_GRid[me->num_of_seg] = CnrlSegId;
      me->num_of_seg += 1;
    }
    else if( ConnCase == 1 ) CnrlSegId = CmpSegId;

    if( ConnCase == 3 || ConnCase == 1 )
    {
      /*| Place elbow or Tee between CnrlSeg( new segment ) and PrevSeg( previous segment ) */

      if( me->Product == VR_PIPING )
      {
	p_OrientSection = NULL;

	if( ConnCase == 3 ) { ActParamId = me->ActParamId; BufParamId = me->ActParamId; }
	else                { ActParamId = ConParamId;     BufParamId = ConParamId;     }
      }
      else
      {
	/* HVAC or Raceway ==> update section matrix */
	status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_InPutSection	= me->section_matrix,
					p_StartPt	= me->first_pt,
					p_EndPt		= me->next_pt,
					p_OutPutSection	= section_matrix );
	as$status( action = GOTO_VALUE, value = wrapup );
	as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

	if( me->twist_orient )
	{
	  OrientSection[0] = me->section_matrix[6];
	  OrientSection[1] = me->section_matrix[7];
	  OrientSection[2] = me->section_matrix[8];
	  OrientSection[3] = section_matrix[6];
	  OrientSection[4] = section_matrix[7];
	  OrientSection[5] = section_matrix[8];
	}
	else
	{
	  OrientSection[0] = me->section_matrix[3];
	  OrientSection[1] = me->section_matrix[4];
	  OrientSection[2] = me->section_matrix[5];
	  OrientSection[3] = section_matrix[3];
	  OrientSection[4] = section_matrix[4];
	  OrientSection[5] = section_matrix[5];
	}

#ifdef MY_DEBUG
	printf (" orientsection %f %f %f - %f %f %f\n",
		OrientSection[0], OrientSection[1], OrientSection[2],
		OrientSection[3], OrientSection[4], OrientSection[5]);
#endif

	p_OrientSection = OrientSection;

	/* update attributes */
	if( me->FirstType == IS_PIPE || me->FirstType == IS_ELBOW )
	{
	  ActParamId = me->ActParamId;
	  if( ConnCase == 3 ) BufParamId = me->BufParamId;
	  else                BufParamId = ConParamId;
	}
	else
	{
	  BufParamId = me->BufParamId;
	  if( ConnCase == 3 ) ActParamId = me->ActParamId;
	  else                ActParamId = ConParamId;
	}

	/*| update twist and section orientation */
	for( i=0; i<9; i++ ) me->section_matrix[i] = section_matrix[i];
      }

      /* set ==> CmpType        : component to place type
      /*     ==> ParentNum      : component to place supports number 
      /*     ==> CmpIndex[]     : component to place index on its supports
      /*     ==> CmpParentsList : component to place supports GRid list
      /*     ==>                : component to place orientation
      /**/

      __DBGpr_int("me->FirstType",me->FirstType);
      switch( me->FirstType )
      {
	case IS_PIPE :

	  /*| first elem is a PIPE */

	  CmpType = VR_TEE; ParentNum = 3; CmpIndex[0] = 1; CmpIndex[2] = 0;

	  CmpParentsList[0] = me->prev_seg_id;
	  CmpParentsList[1] = CnrlSegId;
	  CmpParentsList[2] = NewStartSegmentId;

	  if( DummyFlag == BEGIN_OF_SEG || ConnCase == 3 ) CmpIndex[1] = 0;
	  else
	  {
	    CmpIndex[1] = 1;
	    me->CmpOrientation[1] = -1;
	  }

	  break;

	case IS_ELBOW :

	  /*| first elem is an ELBOW */

	  CmpType = VR_TEE; ParentNum = 3; 

	  CmpParentsList[0] = me->prev_seg_id;
	  CmpParentsList[1] = ElbowStartSecSegId;
	  CmpParentsList[2] = CnrlSegId;

	  status = om$send( msg      = message VRGeneric.VRGetIndex
			    ( &retcode, &me->prev_seg_id, &CmpIndex[0] ),
			    targetid = me->FirstLocatedElemId.objid,
			    targetos = me->FirstLocatedElemId.osnum);
	  as$status( action = RET_STATUS );
	  as$status( sts = retcode, action = RET_STATUS );

	  if( DummyFlag == BEGIN_OF_SEG || ConnCase == 3 ) CmpIndex[2] = 0;
	  else                                             CmpIndex[2] = 1;
	  CmpIndex[1] = ElbowIndex;

	  break;

	default :

	  __DBGpr_com(" first elem is a dangling or free space");

	  CmpType = VR_ELBOW; ParentNum = 2;

	  CmpParentsList[0] = me->prev_seg_id; CmpParentsList[1] = CnrlSegId;

	  if( me->FirstType == IS_DANGLING )
	  {
	    if( me->CmpPosition == BEGIN_OF_SEG )
	    {
	      CmpIndex[0] = 0;
	      me->CmpOrientation[0] = -1;
	    }
	    else CmpIndex[0] = 1;
	  }
	  else CmpIndex[0] = 1;

	  if( DummyFlag == BEGIN_OF_SEG || ConnCase == 3 ) CmpIndex[1] = 0;
	  else { CmpIndex[1] = 1; me->CmpOrientation[1] = -1; }
	  __DBGpr_int("CmpIndex0",CmpIndex[0]);
	  __DBGpr_int("CmpIndex1",CmpIndex[1]);

	  break;
      }

      if( ConnCase == 1 )
      {
	if( me->FirstType == FREE_SPACE )
	{
	  /*| replace the dangling by an elbow */
	  me->FirstLocatedElemId = me->SecondLocatedElemId;
	  FirstPlaceType = VR_OLD_COMP;
	}
	else if( me->FirstType == IS_PIPE )
	{
	  /*| replace the dangling by a tee */
	  me->FirstLocatedElemId = me->SecondLocatedElemId;
	  FirstPlaceType = VR_OLD_COMP;
	}
	else
	{
#ifdef MY_DEBUG
	  printf ("delete dangle at end \n");
#endif
	  /*| Delete end dangling */
	  status = om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, &me->ModuleInfo ),
			    targetid = me->SecondLocatedElemId.objid, 
			    targetos = me->SecondLocatedElemId.osnum);
	  as$status();

	  status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
			    targetid = me->SecondLocatedElemId.objid, 
			    targetos = me->SecondLocatedElemId.osnum);
	  as$status( action = RET_STATUS );
	}
      }

#ifdef MY_DEBUG
      printf ("place comp 1 \n");
#endif

      CmpAngle = 0.0;
      status = VR$PlaceCmpByItemName( 	p_retmsg             	= &retcode,
					PlacementTime     	= FirstPlaceType,
					Product	   		= me->Product,
					TopoParentsNum    	= ParentNum,
					p_TopoParentsList 	= CmpParentsList,
					CmpItemName		= CmpType,
					p_CmpIndexOnTopo  	= CmpIndex,
					p_RelCmpOrient    	= me->CmpOrientation,
					p_CmpAngle        	= &CmpAngle,
					p_CmpOrientSection	= p_OrientSection,
					p_OldCmpId		= &me->FirstLocatedElemId,
					p_MdEnv       		= &me->ModuleInfo,
					p_ActParamId      	= &ActParamId,
					p_BufParamId		= &BufParamId,
					p_UserParamId     	= &me->UsrParamId,
					p_CmpCstList      	= &me->cmp_const_list );
      as$status( action = GOTO_VALUE, value = wrapup );
      as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

      /* compute correction */
      switch( me->FirstType )
      {
	case FREE_SPACE :
	  /*| Rebuild the previous segment */
	  status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
						p_SegmentId	= &me->prev_seg_id,
						p_MdEnv		= &me->ModuleInfo );
	  as$status();
	  as$status( sts = retcode );
	  break;

	case IS_PIPE :
	  /*| first component is a pipe ==> rebuild corrections */
	  status = VRUpdateGraph
	    ( &retcode, me->Product, &UpdateSegLen, &me->prev_seg_id,
	      &me->FirstLocatedElemId, -1, -1, &me->ModuleInfo
	    );
	  as$status( action = RET_STATUS );
	  as$status( sts = retcode, action = RET_STATUS );

	  /* if UpdateSegLen ==> placed component is a TEE ==> update constrains */
	  if( UpdateSegLen ) VRUpdateSegLength
	    ( &retcode, &me->prev_seg_id, &NewStartSegmentId,&me->ModuleInfo );
	  else
	  {
	    /* placed component is an olet ==> constrains does not change */
	    status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleInfo ),
			      targetid = me->FirstLocatedElemId.objid,
			      targetos = me->FirstLocatedElemId.osnum );
	    as$status();
	  }
	  break;

	case IS_ELBOW :
	  /*| first component is an elbow  */

	  if( ConnCase == 1 )
	  {
	    status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
						p_SegmentId	= &CnrlSegId,
						p_MdEnv		= &me->ModuleInfo );
	    as$status();
	    as$status( sts = retcode );
	  }
	  break;

	case IS_DANGLING :
	  __DBGpr_com(" me->FirstType is still dangling");
	  if( ConnCase == 1 )
	  {
	    status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
						p_SegmentId	= &CnrlSegId,
						p_MdEnv		= &me->ModuleInfo );
	    as$status();
	    as$status( sts = retcode );

	    status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
						p_SegmentId	= &me->prev_seg_id,
						p_MdEnv		= &me->ModuleInfo );
	    as$status();
	    as$status( sts = retcode );
	  }

	  break;

	default : break;

      }

      if( ConnCase == 3 ) me->prev_seg_id = CnrlSegId;
      else
      {
	/*| End of connect */
	End
	  return OM_S_SUCCESS;
      }
    }
  }

  /* delete the first located dangling if we start from dangling and not extend */
  if( me->FirstType == IS_DANGLING && ( bAligned || me->extend ) )
  {
#ifdef MY_DEBUG
    printf ("delete first dangle\n");
#endif

    status = om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, &me->ModuleInfo ),
		      targetid = me->FirstLocatedElemId.objid, 
		      targetos = me->FirstLocatedElemId.osnum);
    as$status();

    status = om$send ( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
		       targetid = me->FirstLocatedElemId.objid,
		       targetos = me->FirstLocatedElemId.osnum );
    as$status( action = GOTO_VALUE, value = wrapup );
  }

  if(	me->SecondType == IS_DANGLING ||
	me->SecondType == IS_PIPE ||
	me->SecondType == IS_ELBOW)
  {
    switch( me->SecondType )
    {
      case IS_DANGLING :

#ifdef MY_DEBUG
	printf (" second is dangle \n");
#endif

	/* set ==> section orientation
	/*     ==> component type
	/*     ==> component support number
	/**/
	p_OrientSection = NULL;

	if( ConnCase == 0 ) CmpType = placement_type;
	else                CmpType = VR_ELBOW;

	ParentNum = 2;

	/*| replace the second dangling by an elbow */
	SecondPlaceType = VR_OLD_COMP;

	/* set elbow orientation */
	if( ConnCase == 3 ) me->CmpOrientation[0] = 1;
	if( DummyFlag == BEGIN_OF_SEG ) me->CmpOrientation[1] =  1;
	else                            me->CmpOrientation[1] = -1;
	/*"CmpOrientation = %d %d\n", me->CmpOrientation[0], me->CmpOrientation[1] */

	/* set component support GRid list */
	CmpParentsList[0] = me->prev_seg_id;  CmpParentsList[1] = CmpSegId;

	/* set elbow index on its supports */
	if( me->FirstType == IS_DANGLING && ( bAligned || me->extend ) )
	{
	  if( me->CmpPosition == BEGIN_OF_SEG ) CmpIndex[0] = 0;
	  else                                  CmpIndex[0] = 1;
	}
	else CmpIndex[0] = 1;

	CmpIndex[1] = DangIndex;

	/* set elbow attributes */ 
	if( me->Product == VR_PIPING )
	{
	  if( ConnCase == 0 )
	  {
	    ActParamId = ConParamId;
	    BufParamId = me->ActParamId;
	  }
	  else
	  {
	    ActParamId = ConParamId;
	    BufParamId = ConParamId;
	  }
	}
	else
	{
	  /* in HVAC and Raceway elbow can be reducing elbow ==> get attributes from cpts */

	  /*    why use this routine that can flip the line over ?
		get the attributes directly....................

		TR # 179601884

		status = VRSkGetAttrToConnect
		( me->Product, &ActParamId, NULL, &me->SecondLocatedElemId,
		&CmpSegId, &BufParamId, &me->prev_seg_id, &me->ModuleInfo );
		as$status( action = RET_STATUS );

		...........................................*/

	  status = VRSkGetAttrFromCmp
	    ( me->Product, &ActParamId, &BufParamId, NULL,
	      &me->SecondLocatedElemId, &CmpSegId, NULL,
	      &me->ModuleInfo );
	  as$status( action = RET_STATUS );
	}
#ifdef MY_DEBUG
	printf (" set to replace second dangle with el\n");
#endif
	break;

      case IS_PIPE :

	if( me->Product != VR_PIPING )
	{
	  IGRmatrix CmpMatrix;

	  /* get orientation section */
	  status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
						p_ComponentId	= &me->SecondLocatedElemId,
						p_OutPutSection	= CmpMatrix,
						p_MdEnv		= &me->ModuleInfo );
	  as$status( action = RET_STATUS );
	  as$status( sts = retcode, action = RET_STATUS );

	  OrientSection[0] = CmpMatrix[3];
	  OrientSection[1] = CmpMatrix[4];
	  OrientSection[2] = CmpMatrix[5];

	  if( me->twist_orient )
	  {
	    OrientSection[3] = me->section_matrix[6];
	    OrientSection[4] = me->section_matrix[7];
	    OrientSection[5] = me->section_matrix[8];
	  }
	  else 
	  {
	    OrientSection[3] = me->section_matrix[3];
	    OrientSection[4] = me->section_matrix[4];
	    OrientSection[5] = me->section_matrix[5];
	  }

#ifdef MY_DEBUG
	  printf (" orient_s_again %f %f %f - %f %f %f\n",
		  OrientSection[0], OrientSection[1], OrientSection[2],
		  OrientSection[3], OrientSection[4], OrientSection[5]);
#endif

	  p_OrientSection = OrientSection;
	}

	/* set ==> component type
	/*     ==> component supports  number
	/*     ==> component supports GRid list
	/*     ==> component index on ite supports
	/*     ==> component orientation on its supports
	/**/

	CmpType = VR_TEE; ParentNum = 3;

	CmpParentsList[0] = CmpSegId;
	CmpParentsList[1] = me->prev_seg_id;
	CmpParentsList[2] = NewEndSegmentId;

	CmpIndex[0] = 1;
	CmpIndex[1] = 1;
	CmpIndex[2] = 0;

	if( me->FirstType == IS_DANGLING && ( bAligned || me->extend ) )
	{
	  if( me->CmpPosition == BEGIN_OF_SEG )
	  {
	    CmpIndex[1] = 0;
	    me->CmpOrientation[1] = 1;
	  }
	  else
	  {
	    CmpIndex[1] = 1;
	    me->CmpOrientation[1] = -1;
	  }
	}
	else me->CmpOrientation[1] = -1;

	/* set attributes */
	ActParamId = me->ActParamId;
	BufParamId = ConParamId;

	break;

      case IS_ELBOW :
	/* dangling is going to be replaced */ 
	SecondPlaceType  = VR_OLD_COMP;

	/* set ==> component type
	/*     ==> component supports  number
	/*     ==> component supports GRid list
	/*     ==> component index on ite supports
	/*     ==> component orientation on its supports
	/**/

	p_OrientSection = NULL; CmpType = VR_TEE; ParentNum = 3;

	CmpParentsList[0] = CmpSegId;
	CmpParentsList[1] = ElbowEndSecSegId;
	CmpParentsList[2] = me->prev_seg_id;

	if( me->Product == VR_HVAC || me->Product == VR_RWAY )
	{
	  status = VRSkGetAttrFromCmp
	    ( me->Product, &ActParamId, &BufParamId, NULL,
	      &me->SecondLocatedElemId, &ElbowEndSecSegId, &CmpSegId, 
	      &me->ModuleInfo );
	  as$status( action = RET_STATUS );
	}
	else
	{
	  ActParamId = ConParamId;
	  BufParamId = ConParamId;
	}

	status = om$send( msg      = message VRGeneric.VRGetIndex
			  ( &retcode, &CmpSegId, &CmpIndex[0] ),
			  targetid = me->SecondLocatedElemId.objid,
			  targetos = me->SecondLocatedElemId.osnum);
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	CmpIndex[1] = DangIndex;
	CmpIndex[2] = 1;

	if( CmpIndex[0] ) me->CmpOrientation[0] = -1;
	if( CmpIndex[1] ) me->CmpOrientation[1] = -1;

	if( me->FirstType == IS_DANGLING && me->extend )
	{
	  if( me->CmpPosition == BEGIN_OF_SEG ) CmpIndex[2] = 0;
	  else                                  CmpIndex[2] = 1;
	}

	break;

      default : p_OrientSection = NULL;
		break;
    }

    CmpAngle = 0.0;

    /*^ VRprint_user_attr( &ActParamId ); */
    /*^ VRprint_user_attr( &BufParamId ); */

    /* place new component */

#ifdef MY_DEBUG
    printf (" place second\n");
    if (p_OrientSection)
      printf (" orient_set??? %f %f %f - %f %f %f\n",
	      OrientSection[0], OrientSection[1], OrientSection[2],
	      OrientSection[3], OrientSection[4], OrientSection[5]);
    else printf ("no section set\n");
#endif

    /* If the Component which we are going to place has Missing Parameters then
       get the Missing Parameter Id and allow the control to go back to Sketch
       Command wherein user can specify/change the values of the Missing
       Parameters Currently it mayn't proceed further in placing this component,
       which  has Missing Params. So, presently the crash will be prevented and
       rest will be worked later. Alwin for TR179800775 */

    status = VR$PlaceCmpByItemName(
				   p_retmsg            = &retcode,
				   PlacementTime     	= SecondPlaceType,
				   Product	   	= me->Product,
				   TopoParentsNum    	= ParentNum,
				   p_TopoParentsList 	= CmpParentsList,
				   CmpItemName		= CmpType,
				   p_CmpIndexOnTopo  	= CmpIndex,
				   p_RelCmpOrient    	= me->CmpOrientation,
				   p_CmpAngle        	= &CmpAngle,
				   p_CmpOrientSection	= p_OrientSection,
				   p_OldCmpId		= &me->SecondLocatedElemId,
				   p_MdEnv       	= &me->ModuleInfo,
				   p_ActParamId      	= &ActParamId,
				   p_BufParamId	= &BufParamId,
				   p_UserParamId     	= &ConUserParamId,
				   p_CmpCstList      	= &me->cmp_const_list, 
				   /* added to prevent the crash. Alwin */
				   p_MissParamId	= &me->MissParamId
				  );
    if( retcode == ADDITIONAL_PARAMS ) goto wrapup;

    if ( !(status&1) ) goto wrapup;
    as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );
  }
  else if( SecondConnect )
  {
    /* second component is a nozzle or a C-Comp ==> connect segment to it */
    status = VR$MakeSource( p_msg		= &retcode,
			    p_ComponentId	= &me->SecondLocatedElemId,
			    nCpNum	= me->SecondCptNum,
			    p_CompMdEnv	= &me->SecondLocatedElemMdEnv,
			    p_MdEnv	= &me->ModuleInfo,
			    p_ConnectorId = &CmpToConnectId );
    as$status( action =  RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    if( CmpToConnectId.osnum != me->SecondLocatedElemId.osnum )
    {
      TempId[0] = EndDepPlanesId[0];
      TempId[1] = EndDepPlanesId[1];
      TempId[2] = EndDepPlanesId[2];
      TempId[3] = me->prev_seg_id;
    }
    else TempId[0] = me->prev_seg_id;

    status = om$send( msg      = message VRGeneric.VRConnect
		      ( &retcode, TempId, 1, me->SecondCptNum, &me->ModuleInfo ),
		      targetid = CmpToConnectId.objid, 
		      targetos = CmpToConnectId.osnum);
    as$status( action =  RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }

  /* Update segment length and compute correction */
  if( me->SecondType == IS_PIPE )
  {
    /*| compute correction */

    status = VRUpdateGraph
      ( &retcode, me->Product, &UpdateSegLen, &CmpSegId, &me->SecondLocatedElemId, 
	-1, -1, &me->ModuleInfo
      );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    if( UpdateSegLen ) VRUpdateSegLength
      ( &retcode,&CmpSegId,&NewEndSegmentId,&me->ModuleInfo );
    else
    {
      status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleInfo ),
			targetid = me->SecondLocatedElemId.objid,
			targetos = me->SecondLocatedElemId.osnum );
      as$status();
    }
  }

  /*| Compute correction on the previous segment */
  status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
					p_SegmentId	= &me->prev_seg_id,
					p_MdEnv		= &me->ModuleInfo,
					p_CorId		= &CorId );
  as$status();
  as$status( sts = retcode );

  /*| Update Segment to mis overlap or get fitting to fitting */
  status = VRChangeSegLength( 0, FALSE, &me->prev_seg_id, &me->ModuleInfo );
  as$status( action = RET_STATUS );

  if( ConnCase == 0 )
  {
    status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleInfo ),
		      targetid = CorId.objid,
		      targetos = CorId.osnum );
    as$status();
  }

  if( me->SecondType == IS_ELBOW )
  {
    status = VRGetCorrectionType
      ( &retcode, &me->SecondLocatedElemId, &CmpSegId, &FittingType, &me->SecondLocatedElemMdEnv );
    as$status();

    if( CmpIndex[0] ) DummyFlag = 1;
    else              DummyFlag = -1;

    if( FittingType ) FittingType = VR_UNKNOWN;
  }    
  else FittingType = FALSE;

  if( !SecondConnect )
  {
    status = VRChangeSegLength( DummyFlag, FittingType, &CmpSegId, &me->ModuleInfo );
    as$status( action = RET_STATUS );
  }

  if( me->SecondType == IS_ELBOW )
  {
    status = VRGetCorrectionType
      ( &retcode, &me->SecondLocatedElemId, &ElbowEndSecSegId, &FittingType,
	&me->SecondLocatedElemMdEnv
      );
    as$status( action = GOTO_VALUE, value  = wrapup );

    if( FittingType )
    {
      /* To update previous segment */
      if( CmpIndex[2] ) DummyFlag = 1;
      else              DummyFlag = -1;

      status = VRChangeSegLength( DummyFlag, VR_UNKNOWN, &ElbowEndSecSegId, &me->ModuleInfo );
      as$status( action = GOTO_VALUE, value  = wrapup );
    }
  }
  else if( me->SecondType == IS_PIPE )
  {
    status = VRChangeSegLength( -DummyFlag, FALSE, &NewEndSegmentId, &me->ModuleInfo );
    as$status( action = RET_STATUS );
  }

  if( mode_batch != ND_DEFER ) nd$exec_batch();

  if( me->SecondType == IS_PIPE && !UpdateSegLen )
  {
    /*| display corrections */
    VRDisplayCorrection( &NewEndSegmentId, &me->SecondLocatedElemId, &me->SecondLocatedElemMdEnv );
    VRDisplayCorrection( &CmpSegId, &me->SecondLocatedElemId, &me->SecondLocatedElemMdEnv );
  }

  End
    return(OM_S_SUCCESS);


  /*====== ERROR TREATEMENT ======*/

wrapup:

  if( me->FirstType == FREE_SPACE ) *sts = MSFAIL;

  if( CnrlSegId.objid != NULL_OBJID )
  {
    status = om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, &me->ModuleInfo ),
		      targetid = CnrlSegId.objid, 
		      targetos = CnrlSegId.osnum);
    as$status( action = RET_STATUS );

    status = om$send( msg      = message GRgraphics.GRdelete( &retcode, &me->ModuleInfo),
		      targetid = CnrlSegId.objid, 
		      targetos = CnrlSegId.osnum);
    as$status( action = RET_STATUS );
  }

  if( NewStartSegmentId.objid != NULL_OBJID )
  {
    struct GRid	SegList[2];

    SegList[0] = me->prev_seg_id;
    SegList[1] = NewStartSegmentId; 

    status = VR$MergeSegments(	p_retmsg	= &retcode,
				p_SegmentsId	= SegList,
				p_MdEnv		= &me->ModuleInfo );
    as$status();  	
    as$status( sts = retcode, action = RET_STATUS );  	
  }

  if( NewEndSegmentId.objid != NULL_OBJID )
  {
    struct GRid	SegList[2];

    SegList[0] = CmpSegId;
    SegList[1] = NewEndSegmentId; 

    status = VR$MergeSegments(	p_retmsg	= &retcode,
				p_SegmentsId	= SegList,
				p_MdEnv		= &me->ModuleInfo );
    as$status();  	
    as$status( sts = retcode, action = RET_STATUS );  	
  }

  __DBGpr_com( " Something went wrong " );
  End
    return(OM_S_SUCCESS);

}  

end implementation VRsketch;
