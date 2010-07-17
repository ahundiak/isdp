/* $Id: VRassoc_over.I,v 1.6 2002/04/10 18:13:07 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection / VRassoc_over.I
 *
 * Description:
 *     	This file contains the method to addapte two connect
 *			points by adding correction components.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRassoc_over.I,v $
 *	Revision 1.6  2002/04/10 18:13:07  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.5  2001/09/21 21:15:06  anand
 *	JTS TR MP 5468
 *	
 *	Revision 1.4  2001/03/08 23:44:40  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.3  2001/02/20 01:13:24  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 16:06:04  anand
 *	SP merge
 *	
# Revision 1.1  2000/11/28  21:41:56  pinnacle
# Created: route/vrcorrection/VRassoc_over.I by lawaddel for Service Pack
#
# Revision 1.5  1999/08/20  08:44:10  pinnacle
# TR179900761 - Obtain the flow_value from the Parent and set it to the
# correction instance data
#
# Revision 1.4  1998/11/13  21:47:16  pinnacle
# 'TR179802346'.
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/02/11  04:41:14  pinnacle
# Replaced: vrcorrection/VRassoc_over.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/05/23  14:02:08  pinnacle
# Replaced: vrcorrection/VRassoc_over.I for:  by apazhani for route
#
# Revision 1.3  1997/02/24  00:12:58  pinnacle
# Replaced: vrcorrection/VRassoc_over.I for:  by kddinov for route
#
# Revision 1.2  1996/07/29  19:49:42  pinnacle
# Replaced: vrcorrection/VRassoc_over.I for:  by r241_int for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/05/02  21:51:40  pinnacle
# Replaced: vrcorrection/VRassoc_over.I for:  by ashankar for route240
#
# Revision 1.5  1996/05/02  21:33:36  pinnacle
# Replaced: vrcorrection/VRassoc_over.I for:  by ashankar for route240
#
# Revision 1.4  1996/01/16  23:26:42  pinnacle
# Replaced: vrcorrection/VRassoc_over.I for:  by r240_int for route240
#
 *
 * History:
 *	11/20/90     momo    	creation
 *	08/09/94    Manyam	 Removed the check for PIPE's existance
 *				 before sending the "VRUpdateFlowArrow" in
 *				 ND_compute_node method. This is 
 *				 required because we display the flow 
 *				 arrow irrespective of whether the corr-
 *				 ection has a PIPE or not
 *
 *	06/14/95     Manyam	 Modified the method ND_compute_node() in
 *				 the following way. set the flag 
 *				 "VR_UPDATE_PIPE" in my_state when the 
 *				 representation is changed from pid to 
 *				 something else. This lets the pipe
 *				 dimension to be updated to the correct
 *				 value. This needs to be tested well for
 *				 stability.Fix for TR#179307982
 *	01/15/96     tlb	Add VX_FIproto.h, prototypes
 *	07/29/96     Henk	TR 179602436 - Propagate size changes 
 *				for PID pipe sketching
 *      May/23/97    Alwin      Modified ASconstruct_go method, to provide
 *                              different option code facility for pipes.
 *      Feb/10/98    Alwin      Modified NDcompute_node method, to set the
 *                              "my_CmpCptIndex" Instance variable. TR179800043
 *      Oct/23/98    Alwin      Made a check for PID rep for TR179801744
 *      Oct/29/98    Alwin      TR179802111, modified the NDmake_source
 *      Nov/13/98    Alwin      TR179802347, Commented few lines
 *      Aug/20/99    Alwin      TR179900761, Set the default flow value to the
 *			        correction component. Mainly this is important
 *				in the case of correction connected to 
 *                              Reference files.
 *      Nov/20/00    law        TR-MP4140 - Expand option-code to 80 chars
 *      03/08/01   law          dbg prints
 *	Sep 21 01	Anand 	JTS TR MP 5468
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
class implementation VRCorrection;


#include <string.h>
#include <math.h>

#include "OMlimits.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VRcompdef.h"
#include "ACheader.h"
#include "VRmacros.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "VRPid.h"
#include "VRMath.h"
#include "acrepdef.h"
#include "AS_status.h"

#include "gocmacros.h"
#include "maidmx.h"
#include "vrtools_pto.h"
#include "vrcorrec_pto.h"
#include "bsparameters.h"

#include "VRstructs.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "vrdbgmacros.h"
#include "vrparameters.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG	1
#define	NbMaxChildren	2

#define VR_NE_(a,b)  (fabs((a)-(b))>VRGetTol(VR_DEFAULT_TOL))

from	ACncpx		import	ACget_rep, ACget_NV_rep;
from 	VRGeneric	import	VRSetStatus, VRGetInstance, VRSetInstance, 
				VRNotifyLengthModif, VRGetNextOnCpt,
				VRGetCorOnCpt, VRGetStatus, VRGetConnDesc;
from	ACpretend	import	ACpconnect;
from	ACpretendin	import	ACiconnect;

extern 	struct	GRid	NULL_GRID;
extern	OM_S_CHANSELECT	AS_to_comp;  /* address of to_components channel */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace( struct 	GRas 		*assoc_list; 
                struct 	GRmd_env 	*md_env;
		IGRchar 		*go_cnst_lis )
{
  IGRlong			status  = OM_S_SUCCESS;
  IGRlong			retcode = OM_S_SUCCESS;

	SetProc( Md VRCorrection-NDplace ); Begin 

  __DBGpr_int( " Num of parents ", assoc_list->num_parents );

  if( assoc_list->num_parents != 2 ) 
  {
    as$status( msg = "VRcsplace.place invalid parents count" );
		End
    return(OM_W_ABORT);
  }

  /*^
      printf("my parent = %d %d\n", assoc_list->parents[0].objid, 
                                    assoc_list->parents[1].objid  );
  */

  /*| set my instances */

  /* at the place I need to get my parents connect points and create all
  /* my components
  /**/

  me->my_state = VR_UPDATE_PIPE | VR_UPDATE_CON;
  if( *(assoc_list->as_attr) ) me->my_state |= VR_FIT_TO_FIT;

  /*"my_state = %x\n", me->my_state */

  me->my_NbCorCmp        = 0;

/* KDD   Construction default is VR_FLOW_OUT */
  me->FlowDirection      = (IGRshort) VR_FLOW_OUT;

	/* added by alwin TR179900761 */
	{
		 /* Obtain the flow value from a Non-VRCptIn parent and set it to the
		 Correction Component instance data */

		 IGRint i, direct_index = -1;
		 struct ret_struct AttrStr;
		 struct VRCorrection_common   attr;

		 for( i=0; i<assoc_list->num_parents; i++ )
		 {
				 GRclassid Classid;
				 extern GRclassid OPP_VRCptIn_class_id;

				 status = om$get_classid ( objid = assoc_list->parents[i].objid,
																	 osnum = assoc_list->parents[i].osnum,
																	 p_classid = &Classid );

				 if( Classid == OPP_VRCptIn_class_id ) continue;

				 /* Get the flow value from parent, which is not a VRCptIn object */
				 AttrStr.var.root_pm_st.value = 0.0;
				 status = om$send ( msg = message VRGeneric.ACgive_structure( 
																			(int*) &retcode, &direct_index,
																			VR_N_FLOW_RATE_DB, &AttrStr, md_env ),
												targetid = assoc_list->parents[i].objid,
												targetos = assoc_list->parents[i].osnum );
				 as$status();

				 __DBGpr_dbl( " Flow Value ", AttrStr.var.root_pm_st.value );

				 /* set it to the instance variable */
					me->FlowValue = AttrStr.var.root_pm_st.value; 
		 }
	}
  /* added by alwin TR179900761 */

  /*| connect myself to my parents */

  status = om$send( msg      = message NDnode.NDconnect
                              	( assoc_list->num_parents, assoc_list->parents, NULL_GRID, ND_NEW ),
		    targetid = my_id);
  as$status( action = RET_STATUS );

  status = om$send( msg      = message NDnode.NDcompute_node
				( &retcode, 0, assoc_list->num_parents, assoc_list->parents, md_env ),
		    targetid = my_id);
  as$status( action = RET_STATUS );

	End
  return(OM_S_SUCCESS);
}

/*****************************************************************************/

method NDcompute_node( IGRlong			*msg;
                       IGRint			cn_type;
                       IGRint			count;
                       struct	GRid		list[];
                       struct	GRmd_env	*md_env )
{
  IGRboolean				UpdateSeg=FALSE, InsertPipe=TRUE,
				        ChanRep = FALSE;
  IGRshort				CmpCptIndex[2], OldState, ProductName,
					PipePos=0, StatusValue, StatusValue1;
  IGRint				Rep, Rep1, i;
  IGRlong 				status, retcode, size, ChanPos = 0;
  struct 	GRid			params_list[2];
  struct 	GRid			ActParamId[2], UserParamId[2];
  struct 	GRid 			PipeId, CmpId[2];
  struct	GRas			assoc_list;
  struct	VRGenInfo		CmpStr;
  struct	GRsymbology		Symbology;
  union		VRparam_attr		FatherParams[2], PipeParams;
  struct	GRvg_construct		go_cnst_lis;
  struct	VRPlaceStr		PlaceStr[5];
  IGRboolean				bLoadAttr=TRUE;

  SetProc( Md NDcompute_node ); Begin 

  *msg = MSSUCC;
  status  = OM_S_SUCCESS;
  retcode = OM_S_SUCCESS;

  if( count != my_nbParent ) 
  {
     __DBGpr_com( " Parent count are not same " );
     End
     return OM_S_SUCCESS;
  }

  /* if at least one of my parents are an ERROR component I delete all my
  /* components
  /**/

  status = om$send( msg      = message VRGeneric.VRGetStatus 
					( &retcode, &StatusValue ),
		    targetid = list[0].objid,
		    targetos = list[0].osnum );
  as$status();

  status = om$send( msg      = message VRGeneric.VRGetStatus 
					( &retcode, &StatusValue1 ),
		    targetid = list[1].objid,
		    targetos = list[1].osnum );
  as$status();
  
  if( StatusValue & VR_ERROR || StatusValue1 & VR_ERROR ) goto warup0;

  /* save my actual state before evaluating the new one */
  OldState = me->my_state;
  /*"OldState = %x\n", OldState */

  /* I have to look if a gonna be a PID correction or not
  /* I am a PID correction if at least one of my parents is 
  /**/

  /*| update PID state */
  status = om$send( msg      = message ACncpx.ACget_rep( &Rep ),
                    targetid = list[0].objid, 
                    targetos = list[0].osnum );
  as$status();

  status = om$send( msg      = message ACncpx.ACget_rep( &Rep1 ),
                    targetid = list[1].objid, 
                    targetos = list[1].osnum );
  as$status();

  /* get my product name */
  status = om$send( msg      = message VRCorrection.VRGetProductName( &ProductName ),
   	            targetid = my_id );
  as$status();
  
  /*"ProductName = %d\n", ProductName */

  if( bVR_IS_PID( Rep ) || bVR_IS_PID( Rep1 ) )
  {
	/*| ============ PID CORRECTION ================== */

	me->my_state |= VR_COR_PID_REP;

  	if( !( OldState & VR_COR_PID_REP ) ) ChanRep = TRUE;
  }
  else
  {
	/*| ============ 3D CORRECTION ================== */	

	me->my_state &= ~VR_COR_PID_REP;


  	if( OldState & VR_COR_PID_REP ) 
	{
		ChanRep = TRUE;

		/*C Fix for TR#179307982	*/
		me->my_state |= VR_UPDATE_PIPE;
	}	
  }

  if( ChanRep )
  {
        /* if I change representation I have to rebuild all my components */
  	status = om$send( msg          = message NDnode.NDdelete
    						      ( md_env ),
                    	  p_chanselect = &AS_to_comp );
  	as$status( action = RET_STATUS );

/*    NOTE .. TR179602436   preserve PID flag...
  	me->my_state = VR_UPDATE_PIPE | VR_UPDATE_CON;
  replaced by ...  */
        me->my_state |= (VR_UPDATE_PIPE | VR_UPDATE_CON);
  	OldState = 0;
	me->my_NbCorCmp =0;
  }

  /* I have to prepare the associative and geometric construction lists and
  /* the generic component info structure to build or update my components
  /**/

  /*"parent 0 = %d %d\n", list[0].objid, list[0].osnum */

/* START:KLUDGE */
  {
	GRclassid 		ObjClassId;
	extern GRclassid	OPP_VRNozzle_class_id;

	om$get_classid( objid = list[0].objid,
			osnum = list[0].osnum,
       			p_classid = &ObjClassId );
	
	if(  om$is_ancestry_valid( subclassid   = ObjClassId,
		  superclassid = OPP_VRNozzle_class_id) == OM_S_SUCCESS )
		bLoadAttr = FALSE;
  }
/* END : KLUDGE */  

/* START : KLUDGE */  

	if( bLoadAttr )
	{
		status = om$send( msg      = message GRvg.GRgetsymb
                                            ( &retcode, &Symbology ),
                    targetid = list[0].objid,
                    targetos = list[0].osnum );
	} else {
		status = om$send( msg      = message GRvg.GRgetsymb
                                            ( &retcode, &Symbology ),
                    targetid = list[1].objid,
                    targetos = list[1].osnum );
	}
/* END:KLUDGE */

  /*"Symbology:level  = %d\n", Symbology.level               */
  /*"Symbology:color  = %d\n", Symbology.display_attr.color  */
  /*"Symbology:wieght = %d\n", Symbology.display_attr.weight */
  /*"Symbology:style  = %d\n", Symbology.display_attr.style  */

  VRGetConstructionList
  ( &retcode, md_env, NULL, &Symbology, NULL, NULL, &go_cnst_lis );

  /*| update assoc construction list */
  assoc_list.as_attr     = ( IGRchar * ) &CmpStr;
  assoc_list.num_parents = 2;
  assoc_list.parents     = params_list; /* I will have my ACrg_collect
					/* component attributes
					/**/

  /*| update component structure info */
  status = VR$SetCompInstanceInfo(	p_msg		  = &retcode,
         				CmpStatus	  = VR_CORRECTION,
         				NbTopoParents     = 0,    
         				p_CmpGenInfo	  = &CmpStr
			         );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  CmpStr.GraphicsId.objid                 = NULL_OBJID;
  CmpStr.Attr.Comp.nIndex[0]              = 0;
  CmpStr.Attr.Comp.Orientation.nPriIndex  = -1;
  CmpStr.Attr.Comp.Orientation.nSecIndex  = -1;
  CmpStr.Attr.Comp.Orientation.dSecondary = 0;

  /* get my father 0 system, user paramters and system dimension paramters */
  status = 
  om$send( msg      = message VRCorrection.VRGetTempAttr
			       ( &retcode,&list[0],&ActParamId[0],&UserParamId[0], 
		                 &FatherParams[0], md_env
			       ),
		    targetid = my_id );
  as$status();

  /*| get pipe dimension */

  /* In piping the pipe should keep its dimension if it exist if not the pipe
  /* will have my father 0 parameters
  /**/

  PipeId.objid = NULL_OBJID;

  if( OldState & VR_STRAIGHT )
  {
      /* I have a pipe ==> I get it */
      status = om$send( msg      = message VRCorrection.VRGetCorCmpId
                                   ( &retcode, "PIPE", -1, -1, NULL, &PipeId ),
                        targetid = my_id );
      as$status( action = GOTO_VALUE, value = warup0 );
      as$status( sts = retcode, action = GOTO_VALUE, value = warup0 );
  }

  if( !( me->my_state & VR_UPDATE_CON  && me->my_state & VR_UPDATE_PIPE )
						 && ( OldState & VR_STRAIGHT ) )
  { 
      /* get the pipe dimension attributes :
      /* see VRparam_attr union in VRpriv_attr.h file
      /**/

      /*"PipeId = %d\n", PipeId.objid */
      status = VR$GetDimensionAttributes(	p_retmsg     	= &retcode,
                               		 	Product       	= ProductName,
	                                	p_ComponentId 	= &PipeId,
        	                                p_DimAttributes	= &PipeParams,
                	                        p_MdEnv     	= md_env );
      as$status( action = GOTO_VALUE, value = warup0 );
      as$status( sts = retcode, action = GOTO_VALUE, value = warup0 );
  }
  else
  {
      PipeParams = FatherParams[0];
  }

  if( me->my_state & VR_UPDATE_CON )
  {
    /*| update connection */

    UpdateSeg = TRUE; /* we add this flag to know if I have to update the
		      /* segment supporting me. we add this flag because my
		      /* can be changed when I have only to Xform my components
		      /* and I find out that I don't have a pipe so at the
		      /* next compute I need to update my connection
		      /**/

    /* get my father 1 system, user and dimension attributes */
    status = om$send( msg      = message VRCorrection.VRGetTempAttr
    			         ( &retcode, &list[1], &ActParamId[1],
			           &UserParamId[1], &FatherParams[1], md_env
				 ),
		      targetid = my_id );
    as$status();

/*KLUDGE*/
    if( !bLoadAttr )
	PipeParams = FatherParams[1];
/*KLUDGE*/

    /* evaluate my state and set on my VR_CmpStrList */
    /* PipeParams, Father?Params are I/O. in Input they are my Father and my 
    /* pipe dimension attributes taken from my Father system collection and
    /* if the pipe exist from the pipe system collection. These dimension can
    /* be seted in the Evaluate with the dimension values at my parents connect
    /* points.
    /**/

      /*   initial pipe create gives wrong size in PID when
           reducing DOWN... (TR179602436)

           So, just for PID correct the sizes.....                     */
      /*   for non_PID keep the old code (set pipe to father0)   */

    if (!( OldState & VR_STRAIGHT ))     /*  only new compute   */
    if (me->my_state & VR_COR_PID_REP)   /*  only PID           */
    {
       if (VR_NE_ (FatherParams[0].piping_attr.G_diameter,
                   FatherParams[0].piping_attr.R_diameter))
       {  /*  Father 0 is a size change, take father 1... */
          PipeParams = FatherParams[1];
       }
    }

    status = om$send( msg      = message VRCorrection.VREvaluate
                                 ( &retcode, count, list, md_env, &PipeParams,
                                   &FatherParams[0], &FatherParams[1],
  				   PlaceStr ),
                      targetid = my_id );
    as$status( action = GOTO_VALUE, value = warup0 );

    if( retcode == MSFAIL ) goto warup0;

    /* if I have some compoents to place ( pipe not included ) I call the
    /* build method. All this method arguments are Input arguments.
    /**/

    if( me->my_state & VR_COR_BUILD || OldState & VR_COR_BUILD )
    {    
	status = om$send( msg      = message VRCorrection.VRBuild
				     ( &retcode, OldState, &PipeParams,
				       FatherParams, ActParamId, UserParamId, 
				       ( IGRchar * )&go_cnst_lis, &assoc_list, 
				       PlaceStr, md_env
				     ),
			  targetid = my_id );
	as$status();
    }

    /* if the product is Piping I know that I have to maintain my pipe
    /* dimension
    /**/

    if( ProductName == VR_PIPING ) me->my_state &= ~VR_UPDATE_PIPE;

    me->my_state &= ~VR_UPDATE_CON;
  }
  else
  {	
	/* It's only a GRxform. I gonna move all my components */
	/*| update correction */	
	status = om$send( msg      = message VRCorrection.VRUpdate
			     		     ( count, list, PlaceStr, md_env ), 
			  targetid = my_id );
      	as$status( action = GOTO_VALUE, value = warup0 );
  }

  /* at this stage, I have rebuild or updated all my component ( pipe no
  /* included. my_state, my_cmpStrList and my_NbCorCmp are updated
  /* I have now to worry about the straight
  /**/

  /*| Straight traitement */

  /*"NbComp = %d\n", me->my_NbCorCmp */

  /* if I am FtF ==> no straight */

  if( ! ( me->my_state & VR_FIT_TO_FIT ) )
  {
	/* I update my StrCmpList if neccessay */
	size = om$dimension_of( varray = me->my_StrCmpList );
    	/*"size of NewStrCmpList = %ld\n", size */

    	if( me->my_NbCorCmp+1 > size ) om$vla_set_dimension
					( varray = me->my_StrCmpList,
                          		  size   = me->my_NbCorCmp+1 );

	/* update the pipe real positon. it has to be the number of compnents
        /* close to my father 0
	/**/

	for( i=0; i<me->my_NbCorCmp; i++ )
		if( ! me->my_StrCmpList[i].CmpFatherIndex ) PipePos++;

	/* for the same reason than before I update my StrCmpList by adding
        /* straight information before looking if I can or not insert it
        /**/

  	strcpy( me->my_StrCmpList[me->my_NbCorCmp].CmpName, "PIPE" );
  	me->my_StrCmpList[me->my_NbCorCmp].CmpFatherIndex    = 0;
  	me->my_StrCmpList[me->my_NbCorCmp].CmpRealPos        = PipePos;
  	me->my_StrCmpList[me->my_NbCorCmp].CmpJustification  = VR_CENTER_JUST;

	/* get my pipe virtual templates : it's just the neighbors of the
        /* pipe.
        /**/

	status = om$send( msg      = message VRCorrection.VRGetPipeTempId
                                     ( &retcode, me->my_NbCorCmp,
				       md_env, CmpId, CmpCptIndex
				     ),
        	          targetid = my_id );
	as$status( action = GOTO_VALUE, value = warup0 );
	as$status( sts = retcode, action = GOTO_VALUE, value = warup0 );

	InsertPipe = VRInsertValid( CmpCptIndex, CmpId, md_env ) ;
	
	if( !InsertPipe )
	{
	      	/*| overlap */
		me->my_state |= VR_UPDATE_CON;
		me->my_state |= VR_UPDATE_PIPE;
	}
	else
	{
		/* The pipe can be inserted at the ChanPos */

		ChanPos = me->my_NbCorCmp;
		/*"Pipe ChanPos = %d\n", ChanPos */

    		me->my_state |= VR_STRAIGHT;
    		me->my_NbCorCmp++;

		/* the CmpRealPos is the logical position of my component so if
        	/* I have to place two flanges, two reducers and a pipe the
		/* different real postion will be :
	        /* for the Flange close my fahter 0 = 0
	        /* for the Reducer close Flange0    = 1
		/* for The pipe                     = 2
        	/* for the Flange close my father 1 = 3
        	/* for the Reducer close Flange 1   = 4
		/* at this moment after the Build or the Update I have for this
		/* ex. for the Flange close my fahter 0 = 0
        	/* for the Reducer close Flange0    = 1
        	/* for the Flange close my father 1 = 2
        	/* for the Reducer close Flange 1   = 3
        	/* so if I have to insert a pipe I need to increment Flange1
		/* and Reduce1 real position. I do this before looking if I can
	        /* Insert a pipe or not because I need the right position of
		/* all these components and the pipe one before calling 
		/* VRGetPipeTempId and VRInsertValid
                /**/

    		/*| Update RealPos list */
    		for( i=0; i<me->my_NbCorCmp; i++ )
    		{
			if( me->my_StrCmpList[i].CmpFatherIndex && 
	     			( me->my_StrCmpList[i].CmpRealPos >= 
				     me->my_StrCmpList[ChanPos].CmpRealPos ) )
			{
              			me->my_StrCmpList[i].CmpRealPos += 1;
				/*"Cmp %d New RealPos = %d\n", i, me->my_StrCmpList[i].CmpRealPos */ 
			}
		}

		/* update my generic component info structure */

    		CmpStr.nJustif   		      = VR_CENTER_JUST;
    		CmpStr.Attr.Comp.Desc.nItemNum        = VR_PIPE;
    		CmpStr.Attr.Comp.Orientation.dPrimary = 1;

		if( me->my_state & VR_COR_PID_REP ) CmpStr.cRep = VR_V_PID_REP;
        	else
		{
  			status = om$send( msg      = message ACncpx.ACget_NV_rep
                     	       	             	     ( ( IGRuchar * ) &CmpStr.cRep ),
                    	  	  	  targetid = list[0].objid, 
                    	  	  	  targetos = list[0].osnum );
  			as$status();
		}

/*START : KLUDGE*/
		/* construct or update the straight */
		if ( bLoadAttr )
		{
    			params_list[0] = ActParamId[0];
			params_list[1] = UserParamId[0];
		} else {
    			params_list[0] = ActParamId[1];
			params_list[1] = UserParamId[1];
		}
/*END : KLUDGE */
  		assoc_list.go_attr     = ( IGRchar * ) &ChanPos;

   		status = om$send( msg      = message VRCorrection.VREvalComponent
                                     	     ( &retcode, VR_STRAIGHT, &PipeParams, 
 				               &PipeParams, ( IGRchar * )&go_cnst_lis,
  				               &assoc_list, md_env, &PipeId ),
                                  targetid = my_id );
    		as$status( action = GOTO_VALUE, value = warup0 );
	}
  }

  if( !( me->my_state & VR_STRAIGHT ) && OldState & VR_STRAIGHT )
  {
  	/*"delete PIPE %d\n", PipeId.objid */
   	status = om$send( msg      = message NDnode.NDdelete( md_env ),
       	                  targetid = PipeId.objid,
		          targetos = PipeId.osnum );
        as$status( action = GOTO_VALUE, value = warup0 );
       	as$status( sts = retcode, action = GOTO_VALUE, value = warup0 );
  }

  if( UpdateSeg )
  {
	  /* added by alwin --- for TR179800043 */
  
	  /*In the case of PID, the Component Indices are not getting their
	  values properly. So, we ought to set it correctly by calling the
	  following Method. Which will ensure that it gets the right Segment
	  for modification of Line Segment. */
  
	  if( me->my_state & VR_COR_PID_REP ) //added for TR179801744
	  {
	      status = om$send ( msg = message VRGeneric.VRGetConnDesc 
			    ( &retcode, &list[1], &me->my_CmpCptIndex[0],
			    &me->my_CmpCptIndex[1], md_env ),
		    targetid = list[0].objid,
		    targetos = list[0].osnum );
	      as$status( action = GOTO_VALUE, value = warup0 );
	      as$status( sts = retcode, action = GOTO_VALUE, value = warup0 );
	  }
  
	  __DBGpr_int( " Component's Index ", me->my_CmpCptIndex[0] );
  
	  /* added by alwin --- for TR179800043 */

	  /* update the segment minimum length */

	  /* Do this for both the parents. For section 16 components, the two
	   * parents of a correction are the parents of two different segments!
	   * This results in a small redundancy for more 'common-place'
	   * corrections where number of Control Segments equals number of
	   * Corrections, but I guess that is okay!	- Anand for TR 5468 */
	  for( i=0; i<count; i++ )
	  {
	      status =
	      om$send( msg      = message VRGeneric.VRNotifyLengthModif
						       ( &retcode,
							 me->my_CmpCptIndex[i],
							 md_env ),
		       targetid = list[i].objid,
		       targetos = list[i].osnum );
	  }

	  /*** Commenting this for TR179802347...as in the case of Reference
	  Objects ( especially Nozzle ), it doesn't find the actual Line Segment
	  as result the return status is non=success value and hence it doesn't
	  proceed further in constructing the correction components. I find no
	  no harm in commenting these lines.  This is done temporarily after the
	  PLOAD detail investigation will be done on this issue. Alwin

	  as$status( action = GOTO_VALUE, value = warup0 );
	  as$status( sts = retcode, action = GOTO_VALUE, value = warup0 );

	  ***/
  }

  /*A update the flow arrow */
  if( me->my_state & VR_DISP_FLOW )
  {
	/*A Correction don't need to check for PIPE's existance to 
	update the flow arrow : Manyam				*/

	status =
	om$send( msg      = message VRCorrection.VRUpdateFlowArrow(
			&retcode, count, list, &Symbology,
			md_env ),
		targetid = my_id );

	/*A if not successfull, reset my status */
	if (!(status&1)) me->my_state &= ~VR_DISP_FLOW;

  }/* end update flow symbol */

  /*| update my instance array */
  size = om$dimension_of( varray = me->my_StrCmpList );
  /*"size of NewStrCmpList = %ld\n", size */

  if( me->my_NbCorCmp < size ) om$vla_set_dimension( varray = me->my_StrCmpList,
                                 		     size   = me->my_NbCorCmp );

  /*^
      status = om$send( msg      = message VRCorrection.VRShowInstance(),
                        targetid = my_id );
  */

  /* notify objects which are directly connected to me */
  GR_NOTIFY_LISTENERS( &retcode, &status, GR_GEOM_MODIFIED);

  End
  return OM_S_SUCCESS;

warup0 :

  /*| problem detected */
  status = om$send( msg          = message NDnode.NDdelete(md_env),
                    p_chanselect = &AS_to_comp );
  as$status( action = RET_STATUS );

  me->my_state &= VR_COR_REBUILD;
  me->my_NbCorCmp = 0;

  __DBGpr_com( " Something went wrong " );
  End
  return OM_S_SUCCESS;
}

/*********************************************************/

method NDcopy( IGRlong *msg; int cp_type; struct GRmd_env *obj_dsenv, *new_dsenv;
               struct GRid *newobjid
             )
{
  IGRint		i, j, Count, NewCount, NbParam;
  IGRlong 		retcode, status;
  struct	GRid	CorCmpList[MAX_CorCmp], NewCorCmpList[MAX_CorCmp];
  struct	GRid	NewParam, ParamParents[20];

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  status = om$send( mode     = OM_e_wrt_message,
                    msg      = message ASnode.NDcopy
                                      ( &retcode, cp_type, obj_dsenv, new_dsenv, newobjid ),
                   targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  newobjid->osnum = new_dsenv->md_id.osnum; 
  /*"copied object: %d, %d\n", newobjid->objid, newobjid->osnum */

  status = om$send( msg      = message GRowner.GRget_components
                               ( &retcode, obj_dsenv, CorCmpList, MAX_CorCmp, &Count, 0,
                                 OM_K_MAXINT
                               ), 
                    targetid = my_id );
  as$status( action = RET_STATUS );

  status = om$send( msg      = message GRowner.GRget_components
                               ( &retcode, new_dsenv, NewCorCmpList, MAX_CorCmp, &NewCount, 0,
                                 OM_K_MAXINT
                               ), 
                    targetid = newobjid->objid,
                    targetos = newobjid->osnum );
  as$status( action = RET_STATUS );

  /*"Count = %d .. NewCount = %d\n", Count, NewCount */

  /*^
      printf("VRCorrection.VRassoc_over ===========================\n");
      for( i=0; i<NewCount; i++ )
      {
        printf("NewCorCmpList[%d] = %d\n", i, NewCorCmpList[i].objid );

        status = om$send( msg      = message NDnode.NDget_objects
                                     ( ND_ROOT, ParamParents, 2, NULL, 0, OM_K_MAXINT, &NbParam ),
                          targetid = NewCorCmpList[i].objid,
                          targetos = NewCorCmpList[i].osnum );
        as$status( action = RET_STATUS );

        printf("New NbParam = %d\n", NbParam );

        for(j=0;j<NbParam;j++) printf("ParList[%d] = %d\n", j, ParamParents[j].objid );
      }
      printf("VRCorrection.VRassoc_over ===========================\n");
  */

  for( i=0; i<Count; i++ )
  {
    /*"CorCmpList[%d] = %d\n", i, CorCmpList[i].objid */
    
    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_ROOT, ParamParents, 2, NULL, 0, OM_K_MAXINT, &NbParam ),
                      targetid = CorCmpList[i].objid,
                      targetos = CorCmpList[i].osnum );
    as$status( action = RET_STATUS );

    /*"NbParam = %d\n", NbParam */

    for( j=0; j<NbParam; j++ )
    {
      /*"ParamParents[%d] = %d\n", j, ParamParents[j].objid */

      status = om$send( msg      = message NDnode.NDcopy
                                   ( &retcode, cp_type, obj_dsenv, new_dsenv, &NewParam ),
                        targetid = ParamParents[j].objid,
                        targetos = ParamParents[j].osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      NewParam.osnum = new_dsenv->md_id.osnum; 
      /*"copied Param  %d, %d\n", NewParam.objid, NewParam.osnum */

      status = om$send( msg      = message NDnode.NDconnect
                                           ( 1, &NewParam, NULL_GRID, ND_NEW ),
 	     	        targetid = NewCorCmpList[i].objid,
                        targetos = NewCorCmpList[i].osnum );
      as$status( action = RET_STATUS );
    }
  } 

  return (OM_S_SUCCESS);
}

/*********************************************************/

method NDdelete( struct	GRmd_env	*md_env )
{
  IGRlong		retcode, status; /* return code			*/
  struct	GRid	my_grid;	 /* my GRid			*/

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /*"my_NbCorCmp = %d\n", me->my_NbCorCmp */

  if( me->my_NbCorCmp )
  {
    /*| Change component status */
    status = om$send( msg      = message VRGeneric.VRSetStatus
                                 ( &retcode, ( IGRshort ) VR_DUMB_DEL,
                                   ( IGRshort ) VR_DUMB_DEL ),
                      p_chanselect = &AS_to_comp,
                      from         = 0,
                      to           = me->my_NbCorCmp-1 );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }

  status = om$send( mode     = OM_e_wrt_message,
                    msg      = message ASnode.NDdelete( md_env ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  return(OM_S_SUCCESS);

}

/*****************************************************************************/

method NDmove_to_root( IGRlong			*msg;
		       struct	GRid		*src_grid;
		       struct	GRmd_env	*md_env )
{
  IGRint		Index;
  IGRint		NbFather;                /* used by NDget_objects     */
  IGRint		wait_index[my_nbParent]; /* used by is_waiting macro  */
  IGRlong		status;		         /* return code       	      */
  IGRlong		retcode;	         /* return code       	      */
  struct	GRid	my_grid; 
  struct	GRid	FatherId[my_nbParent];   /* List of my parents GRid   */


  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  NDis_waiting( GR_DELETED, 0, &my_grid, wait_index, NULL, NULL, 1 );

  if( wait_index[0] != -1 )
  {
    /*| I am in the delete list */

    me->my_CmpCptIndex[0] = -1;
    me->my_CmpCptIndex[1] = -1;

    return(OM_S_SUCCESS);
  }

  status = om$send( msg      = message NDnode.NDget_objects
                                       ( ND_ROOT, FatherId, my_nbParent, NULL,
                                         0, OM_K_MAXINT, &NbFather
                                       ),
                    targetid = my_id );

  NDis_waiting( GR_DELETED, 0, FatherId, wait_index, NULL, NULL, NbFather );

  /*^
      IGRint i;

      printf("I have %d father\n", NbFather );

      for( i=0; i<NbFather; i++ )
      {
        printf("I have father(%d) = %d\n", i, FatherId[i].objid );
        printf("wait_index[%d]    = %d\n", i, wait_index[i] );
      }
  */

  if(NbFather != my_nbParent || ( wait_index[0] != -1 && wait_index[1] != -1 ) )
  {
  	/*| I put myself in the delete queue */

  	status = VRDeleteObjects( 1, &my_grid, md_env );
    	as$status();

    	me->my_CmpCptIndex[0] = -1;
    	me->my_CmpCptIndex[1] = -1;

    	return OM_S_SUCCESS;
  }

  /*| whose parent will be kept*/

  if( wait_index[0] != -1 ) 
  {
    Index = 0;
    me->my_CmpCptIndex[0] = me->my_CmpCptIndex[1];
  }
  else Index = 1;

  /*"parent %d will be deleted\n", FatherId[Index].objid */
  /*"parent %d will be kept\n", FatherId[1-Index].objid */

  /*| Merge Correction */

  status = om$send( msg      = message VRCorrection.VRMergeCorrection
                               ( &retcode, &FatherId[Index], md_env ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  return(OM_S_SUCCESS);

}



method ACgive_path( int *suc; struct GRid *go_obj; char *footname )
{
 OMuint index;
 IGRint status;

 *suc = MSFAIL;
 status= om$get_index(objid_c       = my_id,
                      osnum_c       = OM_Gw_current_OS,
                      p_chanselect  = &AS_to_comp,
                      objid         = go_obj->objid,
                      osnum2        = go_obj->osnum,
                      indexaddr     = &index);
 as$status(action = RET_STATUS);

 strcpy( footname, me->my_StrCmpList[index].CmpName );

 *suc = MSSUCC;

 return OM_S_SUCCESS;

}

/*============================================================================*/

method NDmake_source( IGRlong *msg; struct GRid *located_obj, *context;
                      char *path; GRspacenum as_osnum; struct GRid *PretendId )
{
  IGRchar		CorCmpName[path_MAX_CHAR];
  IGRlong 		status, retcode;
  struct 	GRid 	my_grid;	


  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  if( located_obj->objid == my_id )
  {
    status = om$send( mode     = OM_e_wrt_message,
                      msg      = message NDnode.NDmake_source
                                         ( &retcode, located_obj, context,
                                           path, as_osnum, PretendId
                                         ),
    		      targetid = my_id );
    as$status( action = RET_STATUS );
  }
  else
  {
    status = om$send( msg      = message ASnode.ACgive_path
                                 ( (IGRint *)&retcode,located_obj,CorCmpName ),
                      targetid = my_id );
    as$status( action = RET_STATUS);
    as$status( sts = retcode, action = RET_STATUS);

    /*" create the pretend with down_scan %s\n", CorCmpName */

    if( context->objid == NULL_OBJID )
    {
      if(path[0]!=0)
      {
        strcat( CorCmpName, ":" );
        strcat( CorCmpName, path );
      }

      /*"CorCmpName = %s\n", CorCmpName */

      status = om$send( msg = message ASnode.ACconnect_pretend
				( (IGRint *)&retcode, CorCmpName, PretendId ),
                        targetid = my_id );
    }
    else
    {
      /* TR179802111. path is added for the ACprentedin case. */
      if(path[0]!=0)
      {
        strcat( CorCmpName, ":" );
        strcat( CorCmpName, path );
      }

	 status = om$send( msg = message ASnode.ACconnect_pretendin
				 ( (IGRint *)&retcode, CorCmpName, PretendId, context ),
                           targetid = my_id );
    }

    as$status( action = RET_STATUS);
    as$status( sts = retcode, action = RET_STATUS);

    /*" return %d %d\n",PretendId->objid,PretendId->osnum */
  }

  return OM_S_SUCCESS;

}


/*****************************************************************************/

method ACreturn_foot( IGRlong			*msg;
		      IGRchar			*footname;
		      struct	GRid		*foot_obj;
		      IGRshort			*mat_type;
		      IGRdouble			*matrix )
{
  IGRchar		*chpos;
  IGRlong   		retcode, status;
  struct	GRid	CorCmpId;
  

  if( ! footname ) return OM_E_INVARG;

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

	/*"down scan %s footname\n", footname */
 
	/* Bruno : code taken from ACncpxi.I */

	if( 0 == footname[0])
	{
		foot_obj->osnum = OM_Gw_current_OS;
		foot_obj->objid = my_id;
		*msg = MSSUCC;
		if(mat_type) *mat_type = MAIDMX;
		if(matrix) MAidmx(&retcode,matrix);
		return OM_S_SUCCESS;
	}
 

	/* Divide string */
	if( chpos = strchr( footname,':' ) ) *chpos = '\0';

	status =
	om$send( msg      = message VRCorrection.VRGetCorCmpId
				( &retcode, footname, -1, -1,
				  NULL, &CorCmpId ),
		targetid = my_id );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
 
	/*"foot <%d %d>\n", CorCmpId.objid, CorCmpId.osnum */

	/* restore string */
	if( chpos ) *chpos = ':';

	/* No corresponding component */
	if ( CorCmpId.objid == NULL_OBJID )
	{
		*msg = 0;
		 return OM_S_SUCCESS;
	}

	if( chpos )
	{
		/* Go into component */

		status =
		om$send( msg      = message NDmacro.ACreturn_foot
				( &retcode, chpos+1, foot_obj,
				  mat_type, matrix ),
	     	  	      targetid = CorCmpId.objid,
	   	  	      targetos = CorCmpId.osnum );
		as$status( action = RET_STATUS );
		as$status( sts = retcode, action = RET_STATUS );
	}
	else
	{
		/* Return component id */
		if(mat_type) *mat_type = MAIDMX;
		if(matrix) MAidmx(&retcode,matrix);

		*foot_obj = CorCmpId;
	}

  return OM_S_SUCCESS;

}

/*****************************************************************************/

method ASpossible_parent( IGRint ifrom, 
				 ito, 
				 *geom_code, 
				 *option_code,
      		                 *index_track, 
				 *index_ref, 
				 *index_plan, 
				 *nb_return, 
				 *nb_tot )
{
  IGRint i, j;

  /* set total number of parents */

  *nb_tot = 4;

  if( ifrom < 0 ) ifrom = 0;

  if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }

  if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
  
  *nb_return = ito - ifrom + 1;

  /* set the type of each parent */
 
  for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  {
    switch( i )
    {
      case 0 : 
      {
        geom_code[j]   = debug_type;
        option_code[j] = 1; /* obligatory */
        break;
      }

      case 1 : 
      {
        geom_code[j]   = debug_type;
        option_code[j] = 1;/* obligatory */
        break;
      }
    } /*  end switch  */
  }

  /*  track point or ref or plane : used for normal associtaive object */

  *index_ref   = -1;
  *index_track = -1;
  *index_plan  = -1;

  return(OM_S_SUCCESS);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASconstruct_go( struct GRas *asso_lis; struct GRmd_env *md_env;
		       IGRchar *go_cnst_lis; GRclassid go_classid;
		       IGRboolean altconstruct )
{
  IGRshort              Product;
  IGRlong 		status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid	my_grid;
  struct     VRGenInfo  *backup;

  SetProc( Md ASconstruct_go ); Begin 

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  asso_lis->go_objid.osnum = md_env->md_id.osnum;
  status = om$construct( classid = go_classid,
                         p_objid = &asso_lis->go_objid.objid, 
                         osnum   = asso_lis->go_objid.osnum   );
  as$status( action = RET_STATUS );

  /*"conn. my component %d to myself %d at the index %d\n", asso_lis->go_objid.objid, my_grid.objid, (IGRlong)(*asso_lis->go_attr) */
  status = om$send( msg      = message GRconnector.GRrigidconn
                               ( &retcode, &my_grid, (IGRlong * )asso_lis->go_attr ),
                    targetid = asso_lis->go_objid.objid,
                    targetos = asso_lis->go_objid.osnum );
  as$status( action = RET_STATUS );
  
  /* added by alwin for CR179300978 */
  /* Get the Product Name */
  status = om$send ( msg = message VRCorrection.VRGetProductName(
                                     &Product ),
                             targetid = my_id );
 
  if( ( me->my_state & VR_STRAIGHT ) && ( Product == VR_PIPING ) )
  {
      IGRchar pathname[OM_K_MAXOSNAME_LEN];
      struct GRid ExpressionId;
 
      /* Get the Current Working Directory */
      status = di$pwd( dirname = pathname );
 
      /* Setting it to the HOME directory i.e ":filename:usr" */
      status = di$cd( dirname = DIR_G_home_name );
 
      /* Get the ExpressionId if it is already created in the
         Directory Subsystem */
      status = di$translate(
                       objname = "piping_option_code",
                       p_objid = &ExpressionId.objid,
                       p_osnum = &ExpressionId.osnum );
 
      /* Re-Setting it to the PWD directory  */
      status = di$cd( dirname = pathname );
 
      /*** TR-MP4140 expand option-code to 80 characters                ***/
      /*** Also attempting to prevent crashes from non-numeric decoding ***/
      if( ExpressionId.objid != NULL_OBJID )
      {
         IGRint nOption_code=0;
         IGRchar opt_code[81], p_error[100];
         struct ret_struct ExprSt;
 
         status =
         om$send ( msg = message NDnode.NDgive_structure(
                              &retcode, &ExprSt, md_env ),
                senderid = NULL_OBJID,
                targetid = ExpressionId.objid,
                targetos = ExpressionId.osnum );
         as$status ();
 
         strcpy( opt_code, ExprSt.var.text_st.text_string );
 
         backup = ( struct VRGenInfo *) asso_lis->as_attr;
         /*** TR-MP4140 attempting to prevent crash from bad optcode ***/ 
         status = vd$get_alias(   p_msg  = &retcode,
                                product  = PIPING,
                                   type  = 400,
                                i_lname  = opt_code,
                                 o_code  = &nOption_code,
                                p_error  = p_error );
         if ( status != OM_S_SUCCESS )
         {
            int nochar,isanmbr,ii;
            nochar = strlen(opt_code);
            isanmbr = 1;
            if(nochar == 0) isanmbr = 0;
            for(ii=0; ii<nochar;ii++)
              if(!(isdigit(opt_code[ii]))) isanmbr = 0;     
            if(isanmbr)
            {
              nOption_code = atoi(opt_code);
              /*** only called to verify opt_code is numeric entry ***/
              status = vd$get_alias(   p_msg  = &retcode,
                                product  = PIPING,
                                   type  = 400,
                                o_lname  = opt_code,
                                 i_code  = nOption_code,
                                p_error  = p_error );
              if ( status != OM_S_SUCCESS )
              {
                 printf("optioncode %s from directory has no description in Db\n",opt_code);
              }
            } 
            else
            {
               printf("option-code %s from directory is not in Db\n",opt_code);
               nOption_code = 0;
            }
         }
         backup->nOption = nOption_code;
      }
 
  }
  /* END - added by alwin for CR179300978 */

  status = om$send( msg      = message NDnode.NDplace
                                       ( asso_lis, md_env, go_cnst_lis ),
                    targetid = asso_lis->go_objid.objid,
                    targetos = asso_lis->go_objid.osnum );
  as$status( action = RET_STATUS );
 
  backup = NULL;
  End
  return(OM_S_SUCCESS);

}

/*****************************************************************************/

method NDdisconnect(int nb_root; struct GRid *root )
{
  IGRboolean	delete_myself=FALSE;
  IGRint	status=OM_S_SUCCESS;

  if( nb_root < 0 || nb_root > 2 ) return OM_E_INVARG;

  if( ! nb_root || nb_root == 2 ) 
  {
	/*| disconnect all my parents */
	delete_myself = TRUE;
  }
  else
  {
	IGRint		nb_par;
	struct	GRid	list[2];

	/*| nb_root should be equal to 1 */

	/*"nb_root = %d\n", nb_root */

        status = om$send( msg      = message NDnode.NDget_objects
                                     ( ND_ROOT, list, 2, NULL, 0, OM_K_MAXINT, &nb_par ),
                          targetid = my_id );
        as$status( action = RET_STATUS );

	if( nb_par < 1 )
	{
		/*| no parents */
		delete_myself = TRUE;
	}
	else if( nb_par == 1 )
	{
	   /*| I have one parent */

	   if( root->objid == list[0].objid && root->osnum == list[0].osnum )
	   {
		   /*| I disconnect from my last parent */
		   delete_myself = TRUE;
	   }
	   else return OM_E_INVARG;
	}
  }
  
  if( delete_myself )
  {
	struct	GRid	MyId;

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

  	nd$wait_batch( 	type       = GR_DELETED,
                 	l_object   = &MyId,
            		nb_obj     = 1 );
  }
  else
  {	
       	status = om$send( mode     = OM_e_wrt_message,
			  msg      = message ASnode.NDdisconnect
 						   ( nb_root, root ),
                          targetid = my_id );
       	as$status( action = RET_STATUS );
  }

  return OM_S_SUCCESS;

}

end implementation VRCorrection;
