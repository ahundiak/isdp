/* $Id: VRSetDelFit.sl,v 1.5 2002/04/10 18:09:07 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconsco/VRSetDelFit.sl
 *
 * Description:
 *	Set Fitting to Fitting Constrains" 
 *	Delete Fitting to Fitting Constrains" commands.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRSetDelFit.sl,v $
 *	Revision 1.5  2002/04/10 18:09:07  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.3  2001/05/29 15:21:04  anand
 *	Service pack complained of message keys for products besides Route at product
 *	startup. Replaced message keys for this file with the hard-coded Command name
 *	taken from $ROUTE/config/english/messages/src
 *	
 *	Revision 1.2  2001/05/23 00:34:49  anand
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/05/05  12:40:10  pinnacle
# Replaced: vrconsco/VRSetDelFit.sl for:  by sbilla for route
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
# Revision 1.5  1996/03/05  22:24:24  pinnacle
# Replaced: vrconsco/VRSetDelFit.sl for:  by hverstee for route240
#
# Revision 1.4  1996/03/04  20:55:16  pinnacle
# Replaced: vrconsco/VRSetDelFit.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  21:54:34  pinnacle
# Replaced: vrconsco/VRSetDelFit.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:21:18  pinnacle
# Replaced: vrconsco/VRSetDelFit.sl for:  by r240_int for route240
#
 *
 * History:
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      05/04/99    Reddy       Doble value comparision corrected
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

/* Service pack complained about message keys in product other than Route
command_string       VRC_M_SetFtToFt,0,VRPlFTFtCn
synonym		     VRC_M_DelFtToFt,1,VRRmFTFtCn
 */
command_string       "Set Fitting to Fitting Constraints",0,VRPlFTFtCn
synonym		     "Delete Fitting to Fitting Constraints",1,VRRmFTFtCn
class                VRSetDelFit
super_class          VRDisplFit
product_name         "$ROUTE_PATH"
command_table	     "route.cmd"

implementation

#include <math.h>
#include "igrdef.h"
#include "igrtypedef.h"
#include "bstypes.h"
#include "nddef.h"
#include "VRcordef.h"
#include "VRcsdef.h"
#include "vrconsdef.h"
#include "VRdimdef.h"
#include "VRMath.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "AS_status.h"
#include "VRcptmacros.h"
#include "bsmkvec.h"
#include "bslenvec.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG

#define VR_K_ACT_SUCCESS  	0x02
#define VR_K_NoPoints		0x08

#define Fit_To_Fit		0
#define No_Fit_To_Fit		1

from NDnode		import	NDdisplay,
				NDget_objects ;
from VRGeneric		import	VRGetTopo,
				VRGetCptGeom,
				VRGetCorOnCpt,
				VRGetSupOnCpt,
				VRGetCorrections ;
from VRCnrlSeg		import	VRSegConstrainsType;
from VRCorrection	import	VRget_state,
				VRGetCptIndex,
				VRChgCorInstance ;

state_table

#include "VRmsg.h"
#include "grmessage.h"

#define VR_K_NoObjLoc		0x01
#define VR_K_ACT_SUCCESS  	0x02
#define VR_K_NoDisplay		0x04
#define VR_K_NoPoints		0x08

#define Fit_To_Fit		0
#define No_Fit_To_Fit		1

state main
	on CMD_TYPE = 0	do message_key	VR_M_SetFtToFt		state start
	on CMD_TYPE = 1	do message_key	VR_M_DelFtToFt		state start
	
state start
	prompt_key		VR_P_IdComps
	locate_class		"VRComponent, VRConcComp, VRNozzle"
   	accept_key		VR_P_AccReject
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA or 
		   EX_OBJID		
		   		on CMD_TYPE = 0
					do VRGetObjects( &me->ret ) 
		   				on RETURN_CODE = "VR_K_NoObjLoc"
		   				do status_key VR_E_NoObjLoc
		   						state .
		   			do VRGetCorrection( &me->ret, Fit_To_Fit )
						on RETURN_CODE = "VR_K_NoDisplay"
						do status_key VR_E_CptFtToFt
								state .
						on RETURN_CODE != "VR_K_ACT_SUCCESS"
								state haveError
								state Change_Cor
		   		on CMD_TYPE = 1
					do VRGetObjects( &me->ret ) 
		   				on RETURN_CODE = "VR_K_NoObjLoc"
		   				do status_key VR_E_NoObjLoc
		   						state .
					do VRGetCorrection( &me->ret, No_Fit_To_Fit )
						on RETURN_CODE = "VR_K_NoDisplay"
						do status_key VR_E_NoFtToFtCpt
								state .
						on RETURN_CODE != "VR_K_ACT_SUCCESS"
								state haveError
								state Change_Cor
				state Change_Cor

state Change_Cor

   on CMD_TYPE = 0 do prompt_key 	VR_P_IdPtOrAll		state Chg_Cor
   on CMD_TYPE = 1 do prompt_key 	VR_P_NearOrAll		state Chg_Cor

state Chg_Cor

   filter		get_event

   		on EX_BACK_UP		do erase_point		state start

   		on EX_DATA		do VRchangeCor( &me->ret )
   						on RETURN_CODE = "VR_K_NoPoints"
   								state start
   						on RETURN_CODE != "VR_K_ACT_SUCCESS"
								state haveError
								state .

   		on EX_RJT_MOVEON	do erase_point		state start



state haveError
	status_key 		GR_E_ErrEncCmdRst
		on ELSE 					state start

at init		do init_cmd					
at delete	do remove_located_object
		do erase_point

/*----------------------------------------------------------------------------*/
action wakeup {
	
	IGRint		sts ;
	
	om$send( msg      = message VDB_LOCATE.wakeup( pos ),
		 mode     = OM_e_wrt_message,
		 targetid = my_id ) ;
	
 if (!(me->VDB_terminated))
 {
	switch( me->mytype ) {
		
		case 0 :
			om$send( msg      = message VRDisplFit.VRGetCorrection( 
								   &sts,
								   Fit_To_Fit ),
				 targetid = my_id ) ;
				 
			break ;
			
		case 1 :
			om$send( msg      = message VRDisplFit.VRGetCorrection( 
								&sts, 
								No_Fit_To_Fit ),
				 targetid = my_id ) ;
				 
			break ;
	}
  }
			
} /* wakeup */			
/*----------------------------------------------------------------------------*/
action VRchangeCor {

  	IGRint 			i, 
  				j,
				CptNumb,
  				SegType,
				state,
				Cpt ;
  	IGRlong			retcode ;
  	IGRboolean		CorType,
  				GoodPoint = FALSE,
  				Change = FALSE;
  	IGRdouble		DistanceMin = -1.,
  				Distance,
				CptCoord[3],
				PointCoord[3] ;
  	IGRvector		AcceptPoint;
  	struct	GRid		CmpId, 
				CorId, 
				SegId,
				Win;
	struct IGRpointset	pointset ;
	struct DPele_header	DispBuffer ;
  
  	AcceptPoint[0] = me->event1.event.button.x;
 	AcceptPoint[1] = me->event1.event.button.y;
  	AcceptPoint[2] = me->event1.event.button.z;

  	/*^ 
      		printf("accept pt = %f %f %f\n", AcceptPoint[0],
                                                 AcceptPoint[1],
                                                 AcceptPoint[2] ) ;
  	*/

	Win.objid = me->event1.event.button.objid; 
	Win.osnum = me->event1.event.button.osnum; 

  	for( i=0; i<me->NumOfLocatedObjects; i++ ) {

		Distance = VR$SelectClosestCpt(bFree	= FALSE,
			    		p_Component	= &me->LocatedObjects[i],
			    		p_Window		= &Win,
			    		p_DataPoint	= AcceptPoint,
			    		p_Cpt		= ( IGRshort * )&CptNumb,
			    		p_CptCoord	= CptCoord,
			    		p_Mdenv		= &me->ModuleInfo );

  		for( j=0; j<me->NumOfPoint; j++ )
			/* BILLA Double value comparision */
  			if( (fabs(me->ListPoint[3*j]-CptCoord[0]) < VRGetTol(VR_DIST_TOL)) &&
  			    (fabs(me->ListPoint[3*j+1]-CptCoord[1]) < VRGetTol(VR_DIST_TOL)) &&
  		            (fabs(me->ListPoint[3*j+2]-CptCoord[2]) < VRGetTol(VR_DIST_TOL)) )
			{
				/*| display point */
  				GoodPoint = TRUE ;
  				break ;
  			}
 
		if( GoodPoint )
	    		if( DistanceMin == -1. )
			{
				DistanceMin = Distance ;
				Cpt 	      = CptNumb ;
				CmpId         = me->LocatedObjects[i] ;
				for ( j=0; j<3; j++ )
					PointCoord[j] = CptCoord[j] ;
			}
			else 
			if( Distance < DistanceMin ) {
				DistanceMin = Distance ;
				Cpt	    = CptNumb;
				CmpId       = me->LocatedObjects[i] ;
				for ( j=0; j<3; j++ )
					PointCoord[j] = CptCoord[j] ;
		        }
  	}
  	
  	if( DistanceMin == -1 ) {
  			/*|Not a display point*/
  		    	*sts = VR_K_ACT_SUCCESS ;
  		    	return OM_S_SUCCESS ;
  	}
  		
	/*"Component near point : [%d,%d]\n", CmpId.osnum, CmpId.objid*/

  	/*"Cpt Number where we need to break constrain is #%d\n", Cpt */

  	status = om$send( msg      = message VRGeneric.VRGetCorOnCpt(
                               	                              &retcode, 
                               	                              Cpt, 
                               	                              &CorId, 
						              &me->ModuleInfo ),
                          targetid = CmpId.objid,
                          targetos = CmpId.osnum ) ;
                          
  	as$status( action = RET_STATUS ) ;
  	as$status( action = RET_STATUS, sts = retcode ) ;

	/*"Correction : [%d,%d]\n", CorId.osnum, CorId.objid*/
  
  	status = om$send( msg      = message VRCorrection.VRget_state( 
  								     &state ),
                    	  targetid = CorId.objid,
                    	  targetos = CorId.osnum ) ;

  	as$status( action = RET_STATUS ) ;

	if( state & VR_FIT_TO_FIT ) CorType = TRUE;
	else			    CorType = FALSE;

  	/*"Type of correction %d\n", CorType*/

  	status = om$send( msg      = message VRGeneric.VRGetSupOnCpt(
                               			              &retcode, 
                               			              Cpt, 
                               			              &SegId, 
                                                              &me->ModuleInfo ),
                    	  targetid = CmpId.objid,
                          targetos = CmpId.osnum ) ;
                          
  	as$status( action = RET_STATUS ) ;
  	as$status( action = RET_STATUS, sts = retcode ) ;
  	
        /*"Segment : [%d,%d]\n", SegId.osnum, SegId.objid*/

  	status = om$send( msg      = message VRCnrlSeg.VRSegConstrainsType( VR_GET_TYPE, VR_UNKNOWN, &SegType ),
                          targetid = SegId.objid,	
                          targetos = SegId.osnum ) ;
  	as$status( action = RET_STATUS ) ;
  	as$status( action = RET_STATUS, sts = retcode ) ;

  	/*"type of segment : %d\n", SegType*/

	if( me->mytype == 0 && !CorType ) 
        {

    		CorType = TRUE ;
    		Change  = TRUE ;
	}

	if( me->mytype == 1 && CorType )
        {

    		CorType = FALSE ;
    		Change  = TRUE ;
	}
	
	if( Change ) {
		
    		status = om$send( msg      = message VRCorrection.VRChgCorInstance(
                                                                      &retcode,
                                                                      &CorType,
                                                                      NULL, 
                                                                      NULL ),
                    		  targetid = CorId.objid,
                    		  targetos = CorId.osnum ) ;
                    		  
	    	as$status( action = RET_STATUS ) ;
    		as$status( action = RET_STATUS, sts = retcode ) ;

		if( me->mytype == 0 ) 
	    		status = om$send( msg      = message VRCnrlSeg.VRSegConstrainsType
                                                                  ( VR_UPDATE_TYPE, VR_CNS_PARA | VR_CNS_VAL, NULL ),
        	                          targetid = SegId.objid,
                	                  targetos = SegId.osnum ) ;
                	                  
		
                if( me->mytype == 1 )                  
	    		status = om$send( msg      = message VRCnrlSeg.VRSegConstrainsType( VR_INIT_TYPE, VR_UNKNOWN, NULL ),
        	            		  targetid = SegId.objid,
                	    		  targetos = SegId.osnum ) ;

    		as$status( action = RET_STATUS ) ;

		pointset.num_points = 1 ;
		pointset.points     = PointCoord ;

		me->ActiveDisplay.weight = 5 ;

		dp$build_dis_buffer( buffer	 = &DispBuffer,
				     type	 = IGRPS,
				     display_att = &me->ActiveDisplay,
				     geometry	 = &pointset ) ;

		dp$display(  msg     = &retcode,
			     buffer  = &DispBuffer,
			     mode    = GRhe ) ;
			     
		me->NumOfDisplayPoint-- ;  	
	}
  	
  	*sts = me->NumOfDisplayPoint ? VR_K_ACT_SUCCESS : VR_K_NoPoints ;
  	
} /* VRchangeCor */
/*----------------------------------------------------------------------------*/
action VRchangeAll {

  	IGRint 		i, 
  			j, 
			state,
  			SegType, 
  			NbCor ;
  	IGRshort	CptIndex ;
  	IGRlong		retcode ;
  	IGRboolean	CorType,
  			Change ;
  	struct	GRid	SegId, 
  			CorIds[VR_MAX_CPTS] ;

  	for( i=0; i<me->NumOfLocatedObjects; i++ ) {
  	
  		/*"->Process component : [%d,%d]\n", me->LocatedObjects[i].osnum, me->LocatedObjects[i].objid*/
  	
    		status = om$send( msg      = message VRGeneric.VRGetCorrections(
                                                                    &retcode, 
                                                                    VR_MAX_CPTS,
                                                                    CorIds, 
                                                                    &NbCor ),
                                  targetid = me->LocatedObjects[i].objid,
                                  targetos = me->LocatedObjects[i].osnum ) ;
                                  
    		as$status( action = RET_STATUS ) ;
    		as$status( action = RET_STATUS, sts = retcode ) ;

    		/*"Number of correction : %d\n", NbCor*/
  
    		for( j=0; j<NbCor; j++ ) {
    			
    			/*"Correction : [%d,%d]\n", CorIds[j].osnum, CorIds[j].objid*/
    			
      			status = om$send( msg      = 
      					  message VRCorrection.VRget_state(
      					  			     &state ),
                        		  targetid = CorIds[j].objid,
                                          targetos = CorIds[j].osnum ) ;
                                          
      			as$status( action = RET_STATUS ) ;
      			as$status( action = RET_STATUS, sts = retcode ) ;

			if( state & VR_FIT_TO_FIT ) CorType = TRUE;
			else			    CorType = FALSE;

      			/*"Correction type %d\n", CorType*/

      			if( ( me->mytype == 0 && !CorType ) ||
      			    ( me->mytype == 1 && CorType ) ) {
      				
       				status = om$send( msg      = 
       						  message VRCorrection.VRGetCptIndex(
                                       				 &retcode,
                                       				 &me->LocatedObjects[i],
                                       				 &CptIndex ),
                       				  targetid = CorIds[j].objid,
                            			  targetos = CorIds[j].osnum ) ;
                            				  
          			as$status( action = RET_STATUS ) ;
          			as$status( action = RET_STATUS, sts = retcode ) ;

          			status = om$send( msg      = 
          					  message VRGeneric.VRGetSupOnCpt(
                                              		      &retcode, 
                                               		      CptIndex,
                                                 	      &SegId, 
                                               		      &me->ModuleInfo ),
                            		          targetid = me->LocatedObjects[i].objid,
                            		          targetos = me->LocatedObjects[i].osnum ) ;
                            				  
          			as$status( action = RET_STATUS ) ;
          			as$status( action = RET_STATUS, sts = retcode ) ;

          			status = om$send( msg      = 
          					  message VRCnrlSeg.VRSegConstrainsType( VR_GET_TYPE, VR_UNKNOWN, &SegType ),
                            			  targetid = SegId.objid,
			                          targetos = SegId.osnum ) ;
			                                  
				as$status( action = RET_STATUS ) ;
				
				Change = FALSE ;

				if( me->mytype == 0 && ( SegType & VR_CNS_AFF ) != VR_CNS_VAL )
                                {

            				CorType = TRUE ;
            				Change  = TRUE ;
            			}

				if( me->mytype == 1 && ( SegType & VR_CNS_AFF ) == VR_CNS_VAL )
                                {

            				CorType = FALSE ;
            				Change  = TRUE ;
            			}
            			
				if( Change ) {
					
            				status = om$send( msg      = 
            						  message VRCorrection.VRChgCorInstance(
                                                                      &retcode, 
                                                                      &CorType, 
                                                                      NULL, 
                                                                      NULL ),
                              			          targetid = CorIds[j].objid,
                              				  targetos = CorIds[j].osnum ) ;
                              					  
				        as$status( action = RET_STATUS ) ;
            				as$status( action = RET_STATUS, sts = retcode ) ;

					if( me->mytype == 0 ) 
	       					status = om$send( msg      = 
            							  message VRCnrlSeg.VRSegConstrainsType
									( VR_UPDATE_TYPE, VR_CNS_PARA | VR_CNS_VAL, NULL ),
                             				  	  targetid = SegId.objid,
                                                          	  targetos = SegId.osnum ) ;
                                                          
					if( me->mytype == 1 )
            					status = om$send( msg      = 
            			                                  message VRCnrlSeg.VRSegConstrainsType( VR_INIT_TYPE, VR_UNKNOWN, NULL ),
                              					  targetid = SegId.objid,
                              					  targetos = SegId.osnum );
                                                                  
					as$status( action = RET_STATUS ) ;
        			}
      			}
    		}
  	}
  	
  	dp$erase_hilite( msg = &retcode ) ;
  	
  	*sts = VR_K_ACT_SUCCESS ;
  	
} /* VRchangeAll */
/*----------------------------------------------------------------------------*/

