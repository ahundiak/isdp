/* $Id: VRplcmpbycod.I,v 1.5 2002/04/10 20:33:30 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / VRplcmpbycod.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRplcmpbycod.I,v $
 *	Revision 1.5  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.4  2001/10/02 19:44:37  louis
 *	tr5470-for insert component, move the segment ends to the component origin
 *	
 *	Revision 1.3  2001/02/20 01:17:18  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 19:54:21  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  13:49:20  pinnacle
# Created: route/vrsketch/VRplcmpbycod.I by lawaddel for Service Pack
#
# Revision 1.12  2000/02/21  20:52:56  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.11  2000/01/03  23:04:52  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.10  1999/10/22  15:51:58  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.9  1999/06/15  21:52:46  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.8  1999/05/05  22:22:26  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.7  1999/05/04  13:49:36  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by sbilla for route
#
# Revision 1.6  1999/04/29  20:41:58  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.3  1998/11/06  22:46:16  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/07  20:36:08  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/07/14  15:55:42  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.2  1997/07/10  21:56:48  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/05/21  20:11:04  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/19  15:09:58  pinnacle
# Replaced: vrsketch/VRplcmpbycod.I for:  by r240_int for route240
#
 *
 * History:
 *
 *				Fix FIfld_set_value calls - extra args
 *      07/10/97	law     Add 2 way to inserts for TR179701343
 *      10/07/97        law     CR179308634 - Livelookup of piping parts
 *      09/28/98        Alwin   TR179801414 - The _r values for the Raceway
 *                              components are not passed on to the network
 *                              properly.
 *      11/01/98        law     tr179801939 - Tier processing errors - redesign
 *      04/19/99        law     CR179900491 - Dynamic depth - variable tier
 *                              for each tier.
 * 
 *      05/04/99    Reddy       Doble value comparision corrected
 *      05/15/99        law     tr179900669 - fitting to fitting components fix
 *      09/19/99        LAW     TR17900780/781- rway cleanup
 *      11/08/99	law	tr179900934 - ftf regression kludge - hardcoded 
 *				a local value of active_cpt to 1. The original
 *				global value was probably hardcoded in the
 *				VRsketch.sl module.
 *      02/21/00        law     tr179900985 - HVAC transition fixes
 *      05/23/00        law     tr179901422 - locate comp placement off a dangle
 *                              modified to get matrix from dangle.
 *      10/01/01	law     tr5470-the segment split does not line up with
 *                              the new component origin on an insert
 *      04/08/02        law     TR5649-standardize tolerance with VRGetTol
  *************************************************************************/

 class implementation VRsketch;

%safe
#include <math.h>
%endsafe

#include <stdio.h>

#include "nddef.h"
#include "igrdef.h"
#include "go.h"
#include "VRcordef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "igewindow.h"
#include "AS_status.h"
#include "VRpriv_attr.h"
#include "FI.h"
#include "VRco.h"
#include "ndmacros.h"
#include "VRprivmacros.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRact_params.h"
#include "VRmacros.h"
#include "VRmsg.h"
#include "VRparamdef.h"
#include "VRcsdef.h"
#include "VRPid.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "VRcptmacros.h"
#include "VRMath.h"
#include "VRRwDimen.h"    /*** Added for CR179900491 ***/
#include "VRdef.h"        /*** Added for TR179900985 ***/
#include "vrtools_pto.h"
#include "bscrossp.h"
#include        "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG
#define NO_PREV_SEG	68
#define STOP		20

extern GRclassid OPP_VRConcComp_class_id;
/* #define MY_DEBUG */

from	GRgraphics	import	GRdisplay, GRdelete;
from 	NDnode		import	NDchg_state, NDdelete, NDdisplay, ASreturn_go;
from	ACrg_collect	import	ACadd_list_attribute;
from	VRGeneric	import	VRGetNumberOfCpts, VRGetSupOnCpt, VRGetCptGeom,	VRGetSupports,VRGetOrigCoor,
			      VRGetCorrections, VRGetMatrix, VRSelectCptByGeom;
from	VRCnrlSeg	import	VRGetTopo;
from	ACncpx		import	ACgive_structure;

/*********************************************************************************************
/*
/* this method is called to erase the status form
/*
/**/

method VRSkEraseStatusForm( IGRlong *sts )
{
  *sts = MSSUCC;

  /* erase insert form */
  me->form_requested = 0;
  FIf_erase( me->status_display_form_ptr );

  return OM_S_SUCCESS;
} 

/*********************************************************************************************
/*
/* this method is called to get component code from the event
/*
/**/

method VRSkGetCmpCode( IGRlong *sts )
{
  IGRshort	RetFlag;
  IGRlong	retcode;      
  IGRlong	status;       

  *sts = MSSUCC;

  /* Added for CR179308634 - livelookup of piping parts from database */
  if (me->proc_livelook)
  {
        me->SketchMode	= VR_MANUAL;
        me->ListIds[0]	= me->ActParamId;
        return OM_S_SUCCESS;
  }

  if( me->SketchMode == VR_AUTOMATIQUE && me->FirstType != IS_PIPE 
				       && me->FirstType != IS_DANGLING
				       && me->FirstType != FREE_SPACE )
  {
	ex$message( 	field   = ERROR_FIELD,
            		in_buff = "Cannot place component !" );

	om$send( msg      = message VRsketch.VRSkPopupStatusField( &retcode ),
		 targetid = my_id );

	*sts = MSFAIL;
 	return OM_S_SUCCESS;		
  }

  status = VRGetAABBCC( &retcode, &me->event1, me->CmpAABBCCcode, &RetFlag );
  as$status( action = RET_STATUS );

  /*"CmpAABBCCcode = %s\n", me->CmpAABBCCcode */
  
  me->SketchMode = VR_MANUAL;
  me->ListIds[0] = me->ActParamId;

  /* Transition processing added for tr179900985 */
  if(me->Product == VR_HVAC)
  {
     IGRint locshape_code;
     IGRshort bIsTransition;
     IGRint locproduct;

     locproduct = VR_HVAC;
     status = VRGetShapeFrmCompCode (  me->CmpAABBCCcode,
                                          &bIsTransition,
                                          &locshape_code,
                                            locproduct );
     if(bIsTransition)
     {
        if(locshape_code == VR_CIRC_CORN)
        {
           if(me->shape_gadget == HV_C_SHAPE)
               me->shape_gadget = HV_RS_SHAPE;
           else
               me->shape_gadget = HV_C_SHAPE;
        }
        else if(locshape_code == VR_RECT_CIRC)
        {
           if(me->shape_gadget == HV_R_SHAPE)
               me->shape_gadget = HV_C_SHAPE;
           else
               me->shape_gadget = HV_R_SHAPE;
        }
        else if(locshape_code == VR_RECT_OVAL)
        {
           if(me->shape_gadget == HV_R_SHAPE)
               me->shape_gadget = HV_O_SHAPE;
           else
               me->shape_gadget = HV_R_SHAPE;
        }
        else if(locshape_code == VR_RECT_CORN)
        {
           if(me->shape_gadget == HV_R_SHAPE)
               me->shape_gadget = HV_RS_SHAPE;
           else
               me->shape_gadget = HV_R_SHAPE;
        }
        else if(locshape_code == VR_OVAL_CORN)
        {
           if(me->shape_gadget == HV_O_SHAPE)
               me->shape_gadget = HV_RS_SHAPE;
           else
               me->shape_gadget = HV_O_SHAPE;
        }
        else if(locshape_code == VR_OVAL_CIRC)
        {
           if(me->shape_gadget == HV_O_SHAPE)
               me->shape_gadget = HV_C_SHAPE;
           else
               me->shape_gadget = HV_O_SHAPE;
        }
     }
  }
  return OM_S_SUCCESS;
}

/*********************************************************************************************
/*
/* this method is called to get replace active pocket menu by EMS one.
/*
/**/

method VRSkActiveEmsPocket( IGRlong *sts )
{
  if( me->ChangePocket )
  {
  	/*| add EMS pocket menu */
	vd$pkt_menu( );

	me->ChangePocket = FALSE;
  }

  return OM_S_SUCCESS;
} 

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method VRSkGetNeededInfo

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRSkSetCmpInstance( IGRlong *sts )
{
  IGRlong			retcode = MSSUCC;
  IGRint	  		status  = OM_S_SUCCESS, NbTopoParents;

  SetProc( VRsketch_VRSkSetCmpInstance ); Begin
  /*| Get user component attributes collection and copy it */
  status = VR$GetAttributes( 	p_retmsg	= &retcode,
			     	Product		= me->Product,
			     	CloneFlag	= TRUE,
			     	p_UserParamId	= &me->ListIds[1],
				p_MdEnv		= &me->ModuleInfo );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*| Update CmpStr */
  NbTopoParents = 1;

  if (me->FirstType == IS_ELBOW || me->FirstType == IS_PIPE)
  	NbTopoParents = 2;
 
  if ( me->prev_seg_id.objid == NULL_OBJID )
  	  NbTopoParents = 0;

  status = VR$SetCompInstanceInfo(	p_msg		= &retcode,
					CmpStatus	= VR_FORCED,
					CmpAABBCC_Code	= me->CmpAABBCCcode,
					CmpNumber	= me->CmpNumber,
					NbTopoParents	= NbTopoParents,
					CmpOption	= me->CmpOption,
					MdEnvOsnum	= me->ModuleInfo.md_id.osnum,
					p_CmpGenInfo	= &me->CmpStr );
  as$status();

  me->CmpStr.Attr.Comp.Orientation.nPriIndex = -1;
  me->CmpStr.Attr.Comp.Orientation.nSecIndex = -1;

  /*"system param id = %d\n", me->ListIds[0].objid */
  /*"user param id   = %d\n", me->ListIds[1].objid */

  strcpy( me->CmpAABBCCcode, me->CmpStr.szAABBCC);
  strcpy( me->CmpNumber, me->CmpStr.szNumber);
  strcpy( me->CmpNotes, me->CmpStr.szNotes);
  me->CmpNoMtoFlag = me->CmpStr.cNoMtoFlg;
  me->CmpStatus	   = me->CmpStr.nStatus;
  
  me->Symb.display_attr	= me->ActiveDisplay;
  me->Symb.level	= me->ActiveLevel;

  me->SysParamId.objid =  me->ListIds[0].objid;
  me->SysParamId.osnum =  me->ListIds[0].osnum;
  me->UsrParamId.objid =  me->ListIds[1].objid;
  me->UsrParamId.osnum =  me->ListIds[1].osnum;

  me->bI_Need_Pick = TRUE;

  End
  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method VRSkInitCmpOrient

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRSkInitCmpOrient( IGRlong *sts )
{
  IGRlong			retcode = MSSUCC;
  IGRint	  		status=OM_S_SUCCESS;
  IGRint	  		i, NbCor, NbSupport;
  IGRdouble			Zvector[3];
  IGRdouble			dPoint[3], dNormal[3];
  struct	GRid		CmpCorsId[VR_MAX_CPTS], CmpSegsId[VR_MAX_CPTS];
  struct        GRid            GraphicId;
  struct 	IGRplane	Yplane;
  enum 		GRdpmode 	mode;
  union 	VRparam_attr	Param, Param1;
  IGRboolean			InverseXaxis=FALSE;
  IGRint	  		CmpFunction;

  SetProc( VRsketch_VRSkInitCmpOrient ); Begin
  *sts    = MSSUCC;

  __DBGpr_obj("prev_seg_id ", me->prev_seg_id);

  GraphicId.objid = me->CmpId.objid;
  GraphicId.osnum = me->CmpId.osnum;

  __DBGpr_obj("GraphicId or new component ", GraphicId);

  if( me->prev_seg_id.objid == NULL_OBJID )
  {
	*sts = NO_PREV_SEG;

	status = VR$GetMatrix(  p_msg           = &retcode,
                               	p_ComponentId   = &GraphicId,
                               	p_Matrix        = me->CmpMatrix,
                               	p_MdEnv         = &me->ModuleInfo );
	as$status();

	me->CmpMatrix[3]  = me->first_pt[0];
	me->CmpMatrix[7]  = me->first_pt[1];
	me->CmpMatrix[11] = me->first_pt[2];
  }
  else
  {
        /*** TR179901422 *** Following same context as replace-component for the dangle *****/
  	if( me->FirstType == IS_ELBOW || me->FirstType == IS_DANGLING)
  	{
           me->CmpOrientation[0] = 1; /* Dont know if needed yet??? */
  		status = VR$GetMatrix(  p_msg           = &retcode,
                          		p_ComponentId   = &me->FirstLocatedElemId,
                          		p_Matrix        = me->CmpMatrix,
                          		p_MdEnv         = &me->ModuleInfo );
  		as$status();
  	}
  	else
  	{	
  		me->CmpOrientation[0] = ( me->CmpPosition != BEGIN_OF_SEG ) ? 1 : -1;

		status = VR$GetMatrix(  p_msg           = &retcode,
                                	p_ComponentId   = &GraphicId,
                                	p_Matrix        = me->CmpMatrix,
                                	p_MdEnv         = &me->ModuleInfo );
		as$status();

		/* -- Initialise special matrix for orientation -- */

        	Yplane.point  = dPoint;
		Yplane.normal = dNormal;

		status = om$send( msg      = message VRCnrlSeg.VRGetTopo
						( &retcode, me->PrevSegAxis, NULL, &Yplane,
						  NULL, NULL, &me->ModuleInfo ),
		    	  	  targetid = me->prev_seg_id.objid,
		    	  	  targetos = me->prev_seg_id.osnum );
  		as$status();

  		/* -- Initialise graphics matrix for the orientation matrix -- */
  		BScrossp ( &retcode, me->PrevSegAxis, Yplane.normal, Zvector );

		for( i=0; i<3; i++ )
		{
			me->CmpMatrix[i*4]     = me->PrevSegAxis[i] * me->CmpOrientation[0];
			me->CmpMatrix[(4*i)+1] = Yplane.normal[i];
			me->CmpMatrix[(i*4)+2] = Zvector[i];
			me->CmpMatrix[(i*4)+3] = me->first_pt[i];
  		}

  		me->CmpMatrix[12] = me->CmpMatrix[13] = me->CmpMatrix[14] = 0.0;
  		me->CmpMatrix[15] = 1;

		/*"X = %f %f %f \n",me->PrevSegAxis[0],me->PrevSegAxis[1],me->PrevSegAxis[2]*/
	}
__DBGpr_mat("CmpMatrix",me->CmpMatrix);
  }

  /*| update drawing */

  if( me->FirstLocatedElemId.objid != NULL_OBJID )
  {
	/*| undisplay old component its correction and display the supports */
	status = om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, &me->ModuleInfo ),
			  targetid = me->FirstLocatedElemId.objid,
			  targetos = me->FirstLocatedElemId.osnum );
	as$status();

	if( me->FirstType == IS_PIPE )
	{
		/*| located object is a pipe */
		NbSupport = 1;
		CmpSegsId[0] = me->prev_seg_id;
	}
	else
        {
    		/* get correction to undisplay */
    		status = om$send( msg      = message VRGeneric.VRGetCorrections
                	                                ( &retcode, VR_MAX_CPTS, CmpCorsId, &NbCor ),
  	              	  	  targetid = me->FirstLocatedElemId.objid, 
	              	  	  targetos = me->FirstLocatedElemId.osnum );
    		as$status( action = RET_STATUS );

		/*"NbCor = %d\n", NbCor */

		for( i=0; i<NbCor; i++ )
 		{
    			status = om$send( msg      = message NDnode.NDdisplay
                        	                 	( 0, GRbehe, &me->ModuleInfo ),
                      		  	  targetid = CmpCorsId[i].objid, 
                      		  	  targetos = CmpCorsId[i].osnum  );
    			as$status();
		}

  		status = om$send( msg      = message VRGeneric.VRGetSupports
          		          		( &retcode, VR_MAX_CPTS, CmpSegsId, &NbSupport ),
  	             	  	  targetid = me->FirstLocatedElemId.objid, 
	              	  	  targetos = me->FirstLocatedElemId.osnum );
    		as$status( action = RET_STATUS );
	}

	/*"NbSupports = %d\n", NbSupport */
 
	for( i=0; i<NbSupport; i++ )
	{
   		status = om$send( msg      = message NDnode.NDdisplay
								( 0, GRbd, &me->ModuleInfo ),
                    	  	  targetid = CmpSegsId[i].objid, 
                      	  	  targetos = CmpSegsId[i].osnum );
   		as$status();
	}
  }

  status =
  VRGetCompFunction( me->Product, &me->CmpId, &CmpFunction, &Param, &me->ModuleInfo );
  as$status();

  /*C Fix for eccentric redducer problem : Manyam : 23june 94	*/
  if( CmpFunction != IS_UNDEFINED && me->CmpFunction != IS_ECCREDUCER )
  {
	/* get dimension parameters from active system collection */
  	status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
				     		Product		  = me->Product,
						p_SysCollectionId = &me->BufParamId,
						p_DimAttributes   = &Param1,
						p_MdEnv		  = &me->ModuleInfo );
	as$status();

	if( me->Product == VR_PIPING )
  	{
		/*"param1 GD = %f\n", Param1.piping_attr.G_diameter */
		/*"param  GD = %f\n", Param.piping_attr.G_diameter  */

	     /*BILLA  Double value comparison problem */
             if( ( fabs( Param.piping_attr.R_diameter - 
			 Param1.piping_attr.G_diameter ) < VRGetTol(VR_DIST_TOL) )  &&  
		 ( fabs( Param.piping_attr.G_diameter - 
			 Param.piping_attr.R_diameter ) > VRGetTol(VR_DIST_TOL) ) )

		{
			/*| Inverse X axis */
        		me->CmpOrientation[0] = -1 * me->CmpOrientation[0];
			InverseXaxis = TRUE;
		}
  	}
	else 
  	{
		if( Param1.hvac_attr.G_width > Param.hvac_attr.G_width ||
                          (fabs(Param1.hvac_attr.G_width -
                          Param.hvac_attr.G_width) < VRGetTol(VR_DIST_TOL)) &&
                         Param1.hvac_attr.G_depth > Param.hvac_attr.G_depth  )
        	{
			/*| HVAC or CABLING reducer case */
			me->CmpOrientation[0] = -1 * me->CmpOrientation[0];
			InverseXaxis = TRUE;
        	}
  	}

  	/*"CmpOrientation = %d\n", me->CmpOrientation[0] */

  	if( InverseXaxis )
  	{
		me->CmpMatrix[0] *= -1;
		me->CmpMatrix[4] *= -1;
		me->CmpMatrix[8] *= -1;
		
		me->CmpMatrix[2]  *= -1;
		me->CmpMatrix[6]  *= -1;
		me->CmpMatrix[10] *= -1;
  	}
  }
__DBGpr_mat("CmpMatrix",me->CmpMatrix);
__DBGpr_int("CptNum",(int)me->CptNum);
  VR$OrientComp( p_retmsg = &retcode,
                 p_CmpId  = &GraphicId,
     		 Justif   = me->CptNum,
                 Matrix   = me->CmpMatrix,
                 p_MdEnv  = &me->ModuleInfo,
              );

  mode = GRbd;
  status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &retcode, &me->ModuleInfo.md_env.matrix_type,
				 me->ModuleInfo.md_env.matrix, &mode, &me->ModuleInfo.md_id ),
		    targetid = me->CmpId.objid,
		    targetos = me->CmpId.osnum );
  as$status();
  
  End
  return OM_S_SUCCESS;
}

/*****************************************************************************/
method VRGetReturnCode( IGRlong *sts )
{
  IGRboolean	ERROR_DETECTED=FALSE;
  IGRboolean	ValidTopo;

  SetProc( VRsketch_VRGetReturnCode ); Begin
  *sts       = MSSUCC;

  /*| test the topology befor testing if the return codes */

    VRCheckCompTopo( &me->EvalCompTopo, &me->CmpId, &me->ModuleInfo );
    /*"CompTopo = %d\n", me->EvalCompTopo */

  switch( me->FirstType )
  {
/* added VR_2_WAYS_TOPO for inserting valves law/nay 7/10/97 */
	case IS_PIPE :
		ValidTopo = me->EvalCompTopo == VR_INLINE_TOPO 
			 || me->EvalCompTopo == VR_3_WAYS_TOPO
			 || me->EvalCompTopo == VR_2_WAYS_TOPO
			 || me->EvalCompTopo == VR_OLET_TOPO
		       	 || me->EvalCompTopo == VR_4_WAYS_TOPO;
		if( ! ValidTopo )
		{
    			ex$message( 	field   = ERROR_FIELD,
	        			in_buff = "Topology not valid !");

			ERROR_DETECTED = TRUE;
		}
		else if( me->EvalCompTopo == VR_INLINE_TOPO ) me->PlaceDangling = FALSE; /* EndLineRoute will be called */
		
		break;

	case IS_ELBOW:

		ValidTopo = me->EvalCompTopo == VR_2_WAYS_TOPO || me->EvalCompTopo == VR_3_WAYS_TOPO
							       || me->EvalCompTopo == VR_4_WAYS_TOPO;
		if( ! ValidTopo )
		{
    			ex$message( 	field   = ERROR_FIELD,
	        			in_buff = "Topology not valid !");

			ERROR_DETECTED = TRUE;
		}
		
	default : break;
  }

  if( me->CmpType == VR_CONSTR_COMPONENT_TYPE )
  {
	me->my_ret = IS_CONC_COMP;
	me->CptNum = ( IGRshort ) VRSkGetJustif( me->Product, &me->ListIds[0], &me->ModuleInfo );
	if( me->EvalCompTopo == VR_ECCENTRIC_TOPO ) me->CmpFunction = IS_ECCREDUCER;
  }
  else
  {
	if( me->EvalCompTopo == VR_CLOSURE_TOPO ) me->my_ret = IS_ENDLINE_COMP;
	else
        {
           if( me->CmpFunction == IS_TEE && me->FirstType == IS_ELBOW ) me->my_ret = IS_NO_ORIENT;
           else 				  			me->my_ret = IS_COMP_TO_CONNECT;
	}
  }

  End
  return OM_S_SUCCESS;
}

/*****************************************************************************/

method VRPlaceCmp( IGRlong *sts )
{
  IGRlong			retcode;
  IGRint	  		i, status = OM_S_SUCCESS;
  IGRshort			nIndex[VR_MAX_CPTS];
  IGRshort			nCptNum[VR_MAX_CPTS];
  enum 		GRdpmode 	mode;

  SetProc( VRsketch_VRPlaceCmp ); Begin
  *sts       = MSSUCC;
 
  for( i=0; i<VR_MAX_CPTS; i++ )	nIndex[i] = -1;

  nCptNum[0] = me->CptNum;

  if( me->FirstType == IS_DANGLING || me->FirstType == IS_ELBOW  )
  {
	/*| call reconnect macro */
	if( (me->CmpType & VR_CONSTR_COMPONENT_TYPE) && nCptNum[0] == -1 ) 
		nCptNum[0] = 0;

	status = VRReConnect(	&retcode, &me->FirstLocatedElemId, &me->CmpId,
				nCptNum, me->CmpNbCpts, 0, NULL,
				&me->ModuleInfo );
	as$status();

	if( status & 1 & retcode )
	{	
		/*| -- Delete Component component replaced -- */
        	status = 
		om$send( msg 	    = message GRgraphics.GRdelete( &retcode, 
							   &me->ModuleInfo),
			senderid = NULL_OBJID,
			targetid = me->FirstLocatedElemId.objid,
			targetos = me->FirstLocatedElemId.osnum);
		as$status();
	}
  }
  else
  {
 	if( me->FirstType == IS_PIPE )
	{
           IGRshort mycptno;
           IGRdouble dOrig[3];
           GRclassid myClassId;

     	   me->ListIds[me->CmpStr.nNbAttr] = me->prev_seg_id;

           om$get_classid (objid = me->CmpId.objid,
                           osnum = me->CmpId.osnum ,
                       p_classid = &myClassId );

           /* This test should be unnecessary */
           if ( om$is_ancestry_valid
                  ( subclassid   = myClassId,
                    superclassid = OPP_VRConcComp_class_id )
                                                    != OM_S_SUCCESS )
           {
           /* TR5470 the segment break has to be moved to the new ref */
           /* of the inserted component                               */
              status =
                om$send( msg = message VRGeneric.VRGetOrigCoor( &retcode,
                         me->first_pt, &me->ModuleInfo),
                      senderid = NULL_OBJID,
                      targetid = me->CmpId.objid,
                      targetos = me->CmpId.osnum);

              __DBGpr_vec("New split point",me->first_pt);
           }

	   /*| split segment */
	   status =
		VR$SplitSegment( p_retmsg		= &retcode,
				 p_SegmentToSplitId	= &me->ListIds[me->CmpStr.nNbAttr],
				 p_SplitPoint		= me->first_pt,
				 p_MdEnv		= &me->ModuleInfo,
				 p_NewSegmentId	= &me->ListIds[me->CmpStr.nNbAttr+1] );
  	   as$status( action = RET_STATUS );
	   as$status( sts = retcode, action = RET_STATUS );
	   nIndex[0]  = 1;
	   nIndex[1]  = 0;
	   nCptNum[1] = me->CptNum;

  	} else {
		/*A set cmp's support information */
		me->ListIds[me->CmpStr.nNbAttr] = me->prev_seg_id;
		
		/*A set cmp's index on the support */
		nIndex[0] = 1;
	}

  	mode = GRbe;
  	status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &retcode, &me->ModuleInfo.md_env.matrix_type,
				 me->ModuleInfo.md_env.matrix, &mode, &me->ModuleInfo.md_id ),
		    targetid = me->CmpId.objid,
		    targetos = me->CmpId.osnum );
  	as$status();

	status = VRConnect( &retcode, &me->CmpId, nCptNum, me->CmpNbCpts, 
			    &me->ListIds[me->CmpStr.nNbAttr],
			    me->CmpStr.nNbTopo, nIndex, &me->ModuleInfo);
	if( ! ( status & 1 & retcode ) )
	{
		*sts = MSFAIL;
		as$status();
	}
  }

  me->CmpAngle  	= 0.0;
  me->CmpOrientation[0]	= 1;

  End
  return OM_S_SUCCESS;
}

/*****************************************************************************/

method VRSkUpdateNetWork( IGRlong *sts )
{
  enum 		GRdpmode 	mode;
  IGRlong			msg;
  IGRint	  		status = OM_S_SUCCESS;
  IGRboolean			dummy=FALSE;
  IGRshort			CorType=0;
  struct	GRid		CorId;

  SetProc( VRsketch_VRSkUpdateNetWork ); Begin
  *sts       = MSSUCC;

  if ( me->prev_seg_id.objid == NULL_OBJID )
  {
	mode = GRbd;
  	status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &msg, &me->ModuleInfo.md_env.matrix_type,
				 me->ModuleInfo.md_env.matrix, &mode, &me->ModuleInfo.md_id ),
		    targetid = me->CmpId.objid, 
		    targetos = me->CmpId.osnum );
  	as$status();
        End
	return OM_S_SUCCESS;
  }

  dummy = me->FirstType == IS_ELBOW || me->FirstType == IS_DANGLING;

  if( !dummy )
  {
  	/*| compute correction */

  	if( me->next_pt_free ) CorType = 1;

  	status = VR$ComputeCorrection( 	p_retmsg	= &msg,
         				CorType		= CorType,
	 				p_SegmentId	= &me->ListIds[me->CmpStr.nNbAttr],
	 				p_MdEnv		= &me->ModuleInfo,
					p_CorId		= &CorId );
  	as$status();
  	as$status( sts = msg );

  	/*| update segment length */
  	status = VRChangeSegLength
           		( END_OF_SEG, CorType, &me->ListIds[me->CmpStr.nNbAttr], &me->ModuleInfo );
  	as$status( action = RET_STATUS );

	status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleInfo ),
			  targetid = CorId.objid,
			  targetos = CorId.osnum );

  	if( me->ListIds[me->CmpStr.nNbAttr+1].objid != NULL_OBJID && 
							me->EvalCompTopo != VR_OLET_TOPO )
  	{
		/* a pipe has been located to place a TEE */
  		status = VR$ComputeCorrection( 	p_retmsg	= &msg,
						CorType		= VR_UNKNOWN,
	 					p_SegmentId	= &me->ListIds[me->CmpStr.nNbAttr+1],
	 					p_MdEnv		= &me->ModuleInfo );
  		as$status();
  		as$status( sts = msg );
  
		/*| update segment length */
  		status = VRChangeSegLength
                 	 ( END_OF_SEG, FALSE, &me->ListIds[me->CmpStr.nNbAttr+1], &me->ModuleInfo );
  		as$status( action = RET_STATUS );
 	 }
  }

  /*"CmpId = %d \n",me->CmpId.objid*/
  mode = GRbd;
  status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &msg, &me->ModuleInfo.md_env.matrix_type,
				 me->ModuleInfo.md_env.matrix, &mode, &me->ModuleInfo.md_id ),
		    targetid = me->CmpId.objid, 
		    targetos = me->CmpId.osnum );
  as$status();

  /* added to not recompute correction if ENDLIN component is placed */
  me->prev_seg_id.objid = NULL_OBJID;

  End
  return OM_S_SUCCESS;

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRskrestart( IGRlong *sts )

{
  struct	GRid	SegId, NewActParamId;
  IGRdouble		CptCoord[3];
  IGRlong		status, retcode;
  IGRint		i, NumOfCpts;
  IGRint		FreeCpts = 0;
IGRdouble Cpts0[3];

  SetProc( VRsketch_VRskrestart ); Begin
  if( me->CmpType == VR_CONSTR_COMPONENT_TYPE ) me->FirstType = IS_CONC_COMP;
  else
  {
	if( me->EvalCompTopo == VR_CLOSURE_TOPO ) me->FirstType = IS_ENDLINE_COMP;
	else 	  			          me->FirstType = IS_COMP_TO_CONNECT;
  }

  /*"FirstType = %d\n", me->FirstType */
  me->FirstLocatedElemId = me->CmpId;
  /*"FirstLocatedElemId = %d\n", me->FirstLocatedElemId.objid */

  status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
        			                 ( &retcode, &NumOfCpts, &me->ModuleInfo ),
		    targetid = me->CmpId.objid,
		    targetos = me->CmpId.osnum );
  as$status( action = RET_STATUS );

  /*"CptNum = %d\n", NumOfCpts */

  for( i=0; i<NumOfCpts; i++ )
  {
    	status = om$send( msg      = message VRGeneric.VRGetSupOnCpt
                                             ( &retcode, i, &SegId, &me->ModuleInfo ),
                      	  targetid = me->CmpId.objid,
                      	  targetos = me->CmpId.osnum ) ;
    	as$status( action = RET_STATUS ) ;

   	if( SegId.objid == NULL_OBJID )
	{
		FreeCpts++;
      		me->FirstCptNum = i;
  	}
  }

  /*"FreeCpts = %d \n",FreeCpts*/

  if( FreeCpts == 0 )
  {
  	/*| No free connect point */
	*sts = MSFAIL;
        End
	return OM_S_SUCCESS;
  }
   
  if(  FreeCpts > 1 )
  {
    *sts = VR_NEED_CPT;
    End
    return OM_S_SUCCESS;
  }

  /*" me->FirstCptNum = %d\n", me->FirstCptNum*/

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
     		               ( &retcode, me->FirstCptNum, CptCoord, NULL, NULL, &me->ModuleInfo ),
    		    targetid = me->CmpId.objid,
		    targetos = me->CmpId.osnum );
  as$status( action = RET_STATUS );

  status = VRGetCompInfo
          	 ( me->Product, &me->CmpId, me->FirstType, CptCoord, &me->ModuleInfo,
             	   &me->FirstCptNum, me->first_pt, me->ImpDirForDyn, NULL, &me->ActParamId,
             	   &NewActParamId
           	 );                   
  as$status( action = RET_STATUS );

  /* Tier processing added for tr179801939 */
/******** trap removed for TR179900780 ****/
/*  if(me->Product == VR_RWAY && me->shape_gadget == RW_R_SHAPE) */
  if(me->Product == VR_RWAY)
  {
     /* Modified for CR179900491 */
     /** Do not seem to have a form here, so use a local cptdata block */
          {
           struct VRRwCptDetails cptdata[10];
           IGRint nTmp;
           /**** Additional shape processing tr179900780 *****/
           /*************************************************/
           IGRint int_conv;
           nTmp = (IGRint) me->FirstCptNum;
/*           __DBGpr_com("VRskrestart-call VRRw_loc_dimen_fields"); */

           if(me->shape_gadget == RW_C_SHAPE)
             int_conv = VR_CIRC;
           else if(me->shape_gadget == RW_R_SHAPE)
             int_conv = VR_RECT;
           else if(me->shape_gadget == RW_O_SHAPE)
             int_conv = VR_OVAL;
           else if(me->shape_gadget == RW_E_SHAPE)
             int_conv = VR_ELLIPSE;
           else if(me->shape_gadget == RW_RS_SHAPE)
             int_conv = VR_CORNER;
           /**** Using global cptdata-tr179900780 ****/
           status = VRRw_loc_dimen_fields(&me->ModuleInfo,
                                   me->CmpId,
                                   NULL, nTmp,
                                   NULL,
                                   int_conv, me->RWcptdata,
                                   &NewActParamId );
          }
           /*************************************************/
  }
  me->NbOfImpDirection = 1;
  /*"impdir = %f %f %f\n", me->ImpDirForDyn[0], me->ImpDirForDyn[1], me->ImpDirForDyn[2] */

  if( me->Product != VR_PIPING )
  {
  	status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_ComponentId	= &me->CmpId,
					CmpCptNum	= me->FirstCptNum,
					p_OutPutSection	= me->section_matrix,
					p_MdEnv		= &me->ModuleInfo );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );
  }

  me->ActParamId = NewActParamId;
  me->BufParamId = me->ActParamId;
  
  VR$active_params( operation    = VR_REPLACE,
                    VRproduct    = me->Product,
                    update_flag  = VR_UPDATE,
                    act_param_id = &me->ActParamId,
      	            status       = retcode );
  /* modified for CR179900491 */
/*  __DBGpr_com("Call6 for VRSkUpdateForm"); */
  status = VRSkUpdateForm( me->Product, me->form_ptr, &me->shape_gadget, 
			   &me->ActParamId, me->CmpAABBCCcode, 
			   &me->active_cpt, me->RWcptdata,
			   &me->ModuleInfo, VR_AUTOMATIQUE );
/*  __DBGpr_com("back from VRSkUpdateForm"); */
  as$status();

  me->prev_pt[0] = me->first_pt[0];
  me->prev_pt[1] = me->first_pt[1];
  me->prev_pt[2] = me->first_pt[2];

  me->CmpId.objid = NULL_OBJID;

  /*C While in fitting to fitting type of sketch mode, when we place a
      component by using the status display form, the component gets
      placed initially at the data-pnt given by user. But since it is 
      a "FTF" type, the component is moved during recomputation( corre-
      ction gets deleted ). We need to update the prev_pt and first_pt
      in order to display proper dynamics : Fix : Manyam */

  if ( me->next_pt_free ) /*C if fitting to fitting type */
  {
	IGRint		BatchMode;
	IGRdouble	d6EndPts[6];

	/*A get the batch mode */
	nd$mod_batch( request    = ND_GET,
		p_ret_mode = &BatchMode );

	/*A execute the batch */
	if( BatchMode != ND_DEFER )
		nd$exec_batch();

	/*A get end points of the last created segment to update 
	  prev and first points */
	status = 
	VRskgetendpt( &retcode, FALSE, d6EndPts, 
		&me->seg_GRid[me->num_of_seg-1], &me->ModuleInfo );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );
        /*** Added for tr179900669 */
        /*** modified for tr179900934 hardcode cpt to 1 ***/
        {
           IGRlong retmsg;
           IGRint loccpt;
           loccpt = 1;
           status=
                om$send ( msg = message VRGeneric.VRGetCptGeom
                              (&retmsg, (IGRshort) loccpt, Cpts0,
                                              NULL, NULL, &me->ModuleInfo ),
                        senderid = NULL_OBJID,
                        targetid = me->FirstLocatedElemId.objid,
                        targetos = me->FirstLocatedElemId.osnum);

           as$status ( action = RET_STATUS );

        }

	/*A update the prev and first pnts */
    	for( i=0; i<3; i++)
        {
/*           me->first_pt[i] = d6EndPts[i+3]; Modified for tr179900669 */
           me->prev_pt[i] = d6EndPts[i];
           me->first_pt[i] = Cpts0[i];
        }

  } /* next_pt_free */

  End
  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method VRSkPopupStatusField

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRSkPopupStatusField( IGRlong *sts )
{
  *sts = MSSUCC;

  switch( me->Product )
  {
    	case VR_PIPING  : 
		FIg_set_state_off( me->status_display_form_ptr, FI_CANCEL         );
    		FIg_set_state_off( me->status_display_form_ptr, P_REDUCER_BUTTON  );
    		FIg_set_state_off( me->status_display_form_ptr, VALVE_BUTTON      );
    		FIg_set_state_off( me->status_display_form_ptr, ENDPIPE_BUTTON    );
    		FIg_set_state_off( me->status_display_form_ptr, FLANGE_BUTTON     );
    		FIg_set_state_off( me->status_display_form_ptr, P_ELBOW_BUTTON    );
    		FIg_set_state_off( me->status_display_form_ptr, P_TEE_BUTTON      );
		FIg_set_state_off( me->status_display_form_ptr, CONNECTOR         );
    		FIg_set_state_off( me->status_display_form_ptr, SPECIALITY        );
    		FIg_set_state_off( me->status_display_form_ptr, INSTRUMENT        );
    		FIg_set_state_off( me->status_display_form_ptr, P_USER            );
		break;

    	case VR_HVAC:
		FIg_set_state_off( me->status_display_form_ptr, FI_CANCEL         );
		FIg_set_state_off( me->status_display_form_ptr, H_OFFSET_BUTTON   );
    		FIg_set_state_off( me->status_display_form_ptr, ENDDUCT_BUTTON    );
    		FIg_set_state_off( me->status_display_form_ptr, H_REDUCER_BUTTON  );
    		FIg_set_state_off( me->status_display_form_ptr, TRANSITION_BUTTON );
    		FIg_set_state_off( me->status_display_form_ptr, H_ELBOW_BUTTON    );
    		FIg_set_state_off( me->status_display_form_ptr, H_TEE_BUTTON      );
		FIg_set_state_off( me->status_display_form_ptr, DEVICE_BUTTON     );
    		FIg_set_state_off( me->status_display_form_ptr, TERMINATION       );
    		FIg_set_state_off( me->status_display_form_ptr, H_USER 	          );
                break;

    case VR_RWAY :
		FIg_set_state_off( me->status_display_form_ptr, FI_CANCEL         );
		FIg_set_state_off( me->status_display_form_ptr, R_ELBOW_BUTTON    );
    		FIg_set_state_off( me->status_display_form_ptr, R_TEE_BUTTON      );
		FIg_set_state_off( me->status_display_form_ptr, R_REDUCER_BUTTON  );
		FIg_set_state_off( me->status_display_form_ptr, R_OFFSET_BUTTON   );
    		FIg_set_state_off( me->status_display_form_ptr, R_USER            );
		break;
  }

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method VRSkGetCptInfo

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRSkGetCptInfo( IGRlong *sts )
{
  struct	GRid		NewActParamId;
  IGRlong			status, retcode;

  SetProc( VRsketch_VRSkGetCptInfo ); Begin
  *sts = MSSUCC;

  {
    struct	GRid	Win;
    double		dDataPoint[3], dMinDist, dCptCoord[3];
    short		nCptNum;

    dDataPoint[0] = me->event1.event.button.x;
    dDataPoint[1] = me->event1.event.button.y;
    dDataPoint[2] = me->event1.event.button.z;

    Win.objid = me->event1.event.button.objid; 
    Win.osnum = me->event1.event.button.osnum; 

    /* --get the closest free connect point of the component-- */
    dMinDist = VR$SelectClosestCpt( p_Component= &me->CmpId,
			    	    p_Window   = &Win,
			    	    p_DataPoint= dDataPoint,
			    	    p_Cpt      = &nCptNum,
				    p_CptCoord = dCptCoord,
			    	    p_Mdenv    = &me->ModuleInfo);

    /* -- update the event1 button -- */
    if ( nCptNum != -1 ) 
    {
      me->event1.event.button.x = dCptCoord[0];
      me->event1.event.button.y = dCptCoord[1];
      me->event1.event.button.z = dCptCoord[2];
    }
  }

  /*| get component info : cpt number, cpt direction, .. */
  status = VRGetCompInfo
           ( me->Product, &me->CmpId, me->FirstType, &me->event1.event.button.x, &me->ModuleInfo,
             &me->FirstCptNum, me->first_pt, me->ImpDirForDyn, NULL, &me->ActParamId,
             &NewActParamId
           );                   
  as$status( action = RET_STATUS );

  me->NbOfImpDirection = 1;

  /* if HVAC or RaceWay get cpt section matrix */
  if( me->Product != VR_PIPING )
  {
        __DBGpr_com("Calling ModifyHvacSection to build section matrix");
  	status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_ComponentId	= &me->CmpId,
					CmpCptNum	= me->FirstCptNum,
					p_OutPutSection	= me->section_matrix,
					p_MdEnv		= &me->ModuleInfo );
        __DBGpr_vec("section_matrix0",me->section_matrix);
        __DBGpr_vec("section_matrix1",&me->section_matrix[3]);
        __DBGpr_vec("section_matrix2",&me->section_matrix[6]);
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
  }
  /***** Tier processing for tr179801939 *****/
if( (me->Product == VR_RWAY) && (me->shape_gadget == RW_R_SHAPE ))
  {
     /* Modified for CR179900491 */
     /** Do not seem to have a form here, so use a local cptdata block */
          {
           struct VRRwCptDetails cptdata[10];
           IGRint nTmp;
           nTmp = (IGRint) me->FirstCptNum;
/*           __DBGpr_com(L"VRSkGetCptInfo-call VRRw_loc_dimen_fields"); */
           status = VRRw_loc_dimen_fields(&me->ModuleInfo,
                                   me->CmpId,
                                   NULL, nTmp,
                                   NULL,
                                   VR_RECT, cptdata,
                                   &NewActParamId );
          }
 

  }
  

  me->ActParamId = NewActParamId;
  me->BufParamId = me->ActParamId;

  VR$active_params( operation    = VR_REPLACE,
                    VRproduct    = me->Product,
                    update_flag  = VR_UPDATE,
                    act_param_id = &me->ActParamId,
      	            status       = retcode );
  /* Call to VRSkUpdateForm modified for CR179900491 */
/*  __DBGpr_com("Call7 for VRSkUpdateForm"); */
  status = VRSkUpdateForm( me->Product, me->form_ptr, &me->shape_gadget, 
			   &me->ActParamId, me->CmpAABBCCcode,
			   &me->active_cpt, me->RWcptdata,
			   &me->ModuleInfo, VR_AUTOMATIQUE );
/*  __DBGpr_com("back from VRSkUpdateForm"); */
  as$status();

  me->prev_pt[0]  = me->first_pt[0];
  me->prev_pt[1]  = me->first_pt[1];
  me->prev_pt[2]  = me->first_pt[2];

  End
  return OM_S_SUCCESS;

}

/*****************************************************************************/

method VRSkDisplayOrientTee( IGRlong *sts )
{
  IGRlong			status, retcode;
  IGRint			i;
  IGRdouble			dXAxis[3], dYAxis[3];
  IGRdouble			view_scale, vect_size;
  IGRdouble			Scale=1;
  IGRlong 			which_error, bytes_returned;
  struct 	win_var_list	var_list[2]; 

  *sts = MSSUCC;

  var_list[0].var            = VVOL_VIEWPORT_SCALE;
  var_list[0].var_ptr        = ( char *) &view_scale;  
  var_list[0].num_bytes      = sizeof( IGRdouble );
  var_list[0].bytes_returned = &bytes_returned;
  var_list[1].var 	     = END_PARAM;

  if( me->CmpFunction == IS_TEE && me->FirstType == IS_ELBOW ) return OM_S_SUCCESS;

  /*"window id = %d %d\n",  me->event1.event.button.objid, me->event1.event.button.osnum */

  view_scale = 1;

  dp$inq_set_gragad( msg          = &retcode,
		     osnum        = me->event1.event.button.osnum,
	             gragad_objid = me->event1.event.button.objid,
		     which_error  = &which_error,
	             var_list     = var_list );

  vect_size = 40 / view_scale; /* VECT_SIZE = 40 */

  for (i=0;i<3;i++)
  {
  	if ( bVR_IS_PID_ACTIVE )
  	{  	
  		struct 	ret_struct	ParamAttr;
  		IGRint 			FootIndex = -1, retstatus;

  		status = 
  		om$send( msg      = message ACncpx.ACgive_structure( &retstatus, 
							     &FootIndex,
						       	     VR_N_PID_SCALE_DB, 
						       	     &ParamAttr, 
						       	     &me->ModuleInfo),
	   	 	 targetid = me->CmpId.objid,
	   	 	 targetos = me->CmpId.osnum );
  		Scale = ParamAttr.var.root_pm_st.value;
	}

    	dXAxis[i] = me->first_pt[i] + vect_size * (me->CmpMatrix[i*4] / Scale);
    	dYAxis[i] = me->first_pt[i] + vect_size * (me->CmpMatrix[(i*4)+1] / Scale);
  }

  status = VRDisplayHvacOrientTee ( me->first_pt, dXAxis, dYAxis, 
			   	    &me->ActiveDisplay, &me->ModuleInfo );

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRSKEraseHvacTee( IGRlong *sts )
{
  IGRlong	retcode;

  dp$erase_hilite( msg   = &retcode,
                   osnum = me->ModuleInfo.md_id.osnum );

  return OM_S_SUCCESS;
}


/*****************************************************************************/

method VRSkSwitchFormParams( IGRlong *sts )
{
  	IGRint				row = 0, col = 0;
  	IGRlong				msg, status;
  	IGRdouble			TmpValue;
  	union		VRparam_attr	ParamAttr;


	*sts = MSSUCC;

  	if( me->Product == VR_PIPING ) return OM_S_SUCCESS;

  	status = VR$GetDimensionAttributes( 	p_retmsg	  = &msg,
				     		Product		  = me->Product,
						p_SysCollectionId = &me->ListIds[0],
						p_DimAttributes	  = &ParamAttr, 
						p_MdEnv		  = &me->ModuleInfo );
  	as$status( action = RET_STATUS );
  	as$status( sts = msg, action = RET_STATUS );

	/*^ VRprint_user_attr( &me->ListIds[0] ); */

  	if( ParamAttr.hvac_attr.shape != VR_CIRC )
  	{
    		TmpValue                    = ParamAttr.hvac_attr.G_width;
    		ParamAttr.hvac_attr.G_width = ParamAttr.hvac_attr.G_depth;
    		ParamAttr.hvac_attr.G_depth = TmpValue;
		
		/*"G_W = %f\n", ParamAttr.hvac_attr.G_width */
		/*"G_D = %f\n", ParamAttr.hvac_attr.G_depth */

		FIfld_set_value (me->form_ptr, HV_WIDTH,row,col,
					ParamAttr.hvac_attr.G_width,FALSE);
 		FIfld_set_value (me->form_ptr,HV_DEPTH,row,col,
					ParamAttr.hvac_attr.G_depth,FALSE);

    		TmpValue                    = ParamAttr.hvac_attr.R_width;
    		ParamAttr.hvac_attr.R_width = ParamAttr.hvac_attr.R_depth;
    		ParamAttr.hvac_attr.R_depth = TmpValue;

		/*"R_W = %f\n", ParamAttr.hvac_attr.R_width */
		/*"R_D = %f\n", ParamAttr.hvac_attr.R_depth */

		if( me->Product == VR_HVAC )
		{
			/*| HVAC */

			FIfld_set_value (me->form_ptr,SMALL_HV_WIDTH,row,col,
					ParamAttr.hvac_attr.R_width, FALSE);
		 	FIfld_set_value (me->form_ptr,SMALL_HV_DEPTH,row,col,
					ParamAttr.hvac_attr.R_depth,FALSE);
		}
		else
		{
			FIfld_set_value (me->form_ptr,SMALL_RW_WIDTH,row,col,
					ParamAttr.hvac_attr.R_width,FALSE);
		 	FIfld_set_value (me->form_ptr,SMALL_RW_DEPTH,row,col,
					ParamAttr.hvac_attr.R_depth,FALSE);
		}

		status = VRModifyParameterBox
		 	 ( &msg, me->Product, &ParamAttr, &me->ListIds[0], &me->ListIds[0] );
		as$status();
		as$status( sts = msg );		  
    	}

   	return OM_S_SUCCESS;
}

/*****************************************************************************/

method VRDeleteGraphics( IGRlong *sts )
{
  IGRlong			status;
  IGRlong			retcode;
  enum 		GRdpmode 	mode;


	*sts = MSSUCC;

	if( me->CmpId.objid != NULL_OBJID )
	{
  		mode = GRbe;
 		status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &retcode, &me->ModuleInfo.md_env.matrix_type,
				 me->ModuleInfo.md_env.matrix, &mode, &me->ModuleInfo.md_id ),
		    		  targetid = me->CmpId.objid,
		    		  targetos = me->CmpId.osnum );
  		as$status();

		/*status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
				  targetid = me->CmpId.objid,
				  targetos = me->CmpId.osnum );
		as$status();

		me->CmpId.objid = NULL_OBJID;*/
	}

   	return OM_S_SUCCESS;
}

end implementation VRsketch;
