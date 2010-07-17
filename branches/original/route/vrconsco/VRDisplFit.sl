/* $Id: VRDisplFit.sl,v 1.4 2002/04/02 17:22:19 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconsco/VRDisplFit.sl
 *
 * Description:
 *	Display Components Fitting to Fitting command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRDisplFit.sl,v $
 *	Revision 1.4  2002/04/02 17:22:19  anand
 *	SP -> Pload changes.
 *	
 *	Revision 1.3  2001/05/29 15:21:04  anand
 *	Service pack complained of message keys for products besides Route at
 *	product startup. Replaced message keys for this file with the
 *	hard-coded Command name taken from $ROUTE/config/english/messages/src
 *	
 *	Revision 1.2  2001/05/23 00:34:49  anand
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:47  cvs
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
# Revision 1.4  1996/03/04  20:55:58  pinnacle
# Replaced: vrconsco/VRDisplFit.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/17  00:24:00  pinnacle
# Replaced: vrconsco/VRDisplFit.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:20:58  pinnacle
# Replaced: vrconsco/VRDisplFit.sl for:  by r240_int for route240
#
 *
 * History:
 *	12/06/95	tlb		Remove VRcmd.h, 
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	May 22 '01	Anand	Added call to VRDisplay_FitToFitting (a
 *				function that displays all the FTF constraints
 *				in the design file) in VRGetCorrection (wakeup
 *				state).
 *
 *************************************************************************/

command_string	     VRC_M_DspFtToFt,0,VRDsFTFtCn
/* Service pack complained about message keys in product other than Route
command_string	     "Display Fitting to Fitting Constraints",0,VRDsFTFtCn
 */
class		     VRDisplFit
super_class	     VDB_LOCATE
product_name	     "$ROUTE_PATH"
command_table	     "route.cmd"

specification

instance {
	IGRint			NumOfLocatedObjects ;
	IGRint			NumOfDisplayPoint ;
	IGRint			NumOfPoint ;
	struct GRid		*LocatedObjects ;
	variable struct GRid    ListCorrection[0] ;
	variable double		ListPoint[0] ;
}

implementation

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrdef.h"
#include "nddef.h"
#include "VRcordef.h"
#include "VRdimdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "AS_status.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG

#define VR_K_NoObjLoc		0x01
#define VR_K_ACT_SUCCESS	0x02
#define VR_K_NoDisplay		0x04

from VRGeneric		import	VRGetCptGeom,
				VRGetCorrections;
from VRCorrection	import	VRget_state,
				VRGetCptIndex ;

state_table

#include "VRmsg.h"

#define VR_K_NoObjLoc		0x01
#define VR_K_ACT_SUCCESS	0x02
#define VR_K_NoDisplay		0x04

#define Fit_To_Fit		1

state start
	message_key		VR_M_DspFtToFt
	prompt_key		VR_P_IdComps
	locate_class		"VRGeneric"
	accept_key		VR_P_AccReject
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA or
		   EX_OBJID		do VRGetObjects( &me->ret )
						on RETURN_CODE = "VR_K_NoObjLoc"
						do status_key VR_E_NoObjLoc
								state .
					do VRGetCorrection( &me->ret, Fit_To_Fit )
						on RETURN_CODE = "VR_K_NoDisplay"
						do status_key VR_E_NoFtToFtCpt
								state .
						on RETURN_CODE != "VR_K_ACT_SUCCESS"
								state haveError
								state .

state haveError
	status_key		GR_E_ErrEncCmdRst
		on ELSE 		do remove_located_object
								state start
							
at init 	do init_cmd
at wakeup       do VRGetCorrection( &me->ret, Fit_To_Fit )
at delete	do remove_located_object
		do erase_point

/*----------------------------------------------------------------------------*/
action init_cmd {

	me->NumOfLocatedObjects = 0 ;
	me->LocatedObjects	= NULL ;
	me->NumOfDisplayPoint	= 0 ;
	me->NumOfPoint		= 0 ;

} /* init_cmd */
/*----------------------------------------------------------------------------*/
action remove_located_object {

	if( me->NumOfLocatedObjects  ) {
		ASend_fence() ;

		me->NumOfLocatedObjects = 0 ;
		me->LocatedObjects	= NULL ;
		me->NumOfDisplayPoint	= 0 ;
		me->NumOfPoint		= 0 ;
	}

    // Call to erase_hilite put in by Anand (to erase all FTF constraint
    // indicators when command exists).
    dp$erase_hilite( msg = sts ) ;

} /* remove_located_object */
/*----------------------------------------------------------------------------*/
action VRGetObjects {

	
	/*
	 * Remove last components located.
	 */
	om$send( msg      = message VRDisplFit.remove_located_object( sts ),
		 targetid = my_id ) ;
	
	ASstart_fence( me->event1.located_object[0].located_obj,
		       me->ModuleInfo.md_id.osnum,
		       &me->NumOfLocatedObjects,
		       &me->LocatedObjects,
		       me->response,
		       me->response_data ) ;

	if( !me->NumOfLocatedObjects ) {
		*sts = VR_K_NoObjLoc ;
		goto quit ;
	} else	*sts = MSSUCC ;

	/*
	   {IGRint i ;
	      for( i=0; i<me->NumOfLocatedObjects; i++ )
			printf("LocatedObjects[%d] : [%d,%d]\n",
				i,
				me->LocatedObjects[i].osnum,
				me->LocatedObjects[i].objid ) ;
            }
	*/

} /* VRGetObjects */
/*----------------------------------------------------------------------------*/
action VRGetCorrection( IGRint		*sts ;
			IGRint		type_correction ) {

	IGRint			i,
				j,
				l,
				size,
				state,
				NbCor ;
	IGRlong 		retcode ;
	IGRboolean		CorType,
				Continue,
				HaveDispBuffer = FALSE ;
	struct	GRid		CorIds[VR_MAX_CPTS] ;
	IGRshort		Index ;
	IGRdouble		DispPt[3] ;
	struct IGRpointset	pointset ;
	struct DPele_header	DispBuffer ;

	/* Below function declaration added by Anand */
	extern int		VRDisplay_FitToFitting(struct GRmd_env *);

	me->NumOfDisplayPoint = 0 ;
	me->NumOfPoint	      = 0 ;
	
	dp$erase_hilite( msg = &retcode ) ;

	/* Below call added by Anand */
	status = VRDisplay_FitToFitting(&me->ModuleInfo);

	status = om$vla_set_dimension( varray = me->ListCorrection,
				       size   = 0 ) ;

	status = om$vla_set_dimension( varray = me->ListPoint,
				       size   = 0 ) ;

	as$status( action = RET_STATUS ) ;

	for( i=0; i<me->NumOfLocatedObjects; i++ )  {

		/*"->Process component : [%d,%d]\n", me->LocatedObjects[i].osnum, me->LocatedObjects[i].objid*/

		status = om$send( msg	   = message VRGeneric.VRGetCorrections(
								    &retcode,
								    VR_MAX_CPTS,
								    CorIds,
								    &NbCor ),
				  targetid = me->LocatedObjects[i].objid,
				  targetos = me->LocatedObjects[i].osnum ) ;

		as$status( action = RET_STATUS ) ;
		as$status( action = RET_STATUS, sts = retcode ) ;

		/*"Number of correction : %d\n", NbCor*/
		
		Continue = FALSE ;

		for( j=0; j<NbCor; j++ ) {

			size = om$dimension_of( varray = me->ListCorrection ) ;

			for( l=0; l<size; l++ ) 
				if( CorIds[j].objid == me->ListCorrection[l].objid ) {
			     			Continue = TRUE ;
			     			break ;
			     	} else 		Continue = FALSE ;
			     	
			if( Continue ) continue ;
			
			size = om$dimension_of( varray = me->ListCorrection ) ;

			status = om$vla_set_dimension(	varray	= me->ListCorrection,
							size	= size + 1 ) ;

			as$status( action = RET_STATUS ) ;
							
			me->ListCorrection[size] = CorIds[j] ;

			/*"Correction n'%d : [%d,%d]\n", j, CorIds[j].osnum, CorIds[j].objid*/

			status = om$send( msg	   =
					  message VRCorrection.VRget_state(
								     &state ),
					  targetid = CorIds[j].objid,
					  targetos = CorIds[j].osnum ) ;

			as$status( action = RET_STATUS ) ;
			as$status( action = RET_STATUS, sts = retcode ) ;

			if( state & VR_FIT_TO_FIT ) CorType = TRUE;
			else			    CorType = FALSE;

			/*"Correction type : %d\n", CorType*/

			if( CorType == type_correction ) {

				HaveDispBuffer = TRUE ;

				me->NumOfDisplayPoint++ ;

				status = om$send( msg	   =
						  message VRCorrection.VRGetCptIndex(
								  &retcode,
								  &me->LocatedObjects[i],
								  &Index ),
						  targetid = CorIds[j].objid,
						  targetos = CorIds[j].osnum ) ;

				as$status( action = RET_STATUS ) ;
				as$status( action = RET_STATUS, sts = retcode );

				/*"Correction point : %d\n", Index*/

				status = om$send( msg	   =
						  message VRGeneric.VRGetCptGeom(
							      &retcode,
							      Index,
							      DispPt,
							      NULL,
							      NULL,
							      &me->ModuleInfo ),
						  targetid = me->LocatedObjects[i].objid,
						  targetos = me->LocatedObjects[i].osnum ) ;

				as$status( action = RET_STATUS ) ;
				as$status( action = RET_STATUS, sts = retcode );

				/*"Disp Pt = %f %f %f\n", DispPt[0], DispPt[1], DispPt[2] */

				pointset.num_points = 1 ;
				pointset.points     = DispPt ;

				me->ActiveDisplay.weight = 5;

				dp$build_dis_buffer( buffer	 = &DispBuffer,
						     type	 = IGRPS,
						     display_att = &me->ActiveDisplay,
						     geometry	 = &pointset ) ;

				dp$display(  msg     = &retcode,
					     buffer  = &DispBuffer,
					     mode    = GRhd ) ;
					     
				size = om$dimension_of( varray = me->ListPoint ) ;

				status = om$vla_set_dimension(	varray	= me->ListPoint,
								size	= size + 3 ) ;
				
				as$status( action = RET_STATUS ) ;
				
				me->ListPoint[size]   = DispPt[0] ;
				me->ListPoint[size+1] = DispPt[1] ;
				me->ListPoint[size+2] = DispPt[2] ;

			}
		}
	}
	
	/*"Number of display points : %d\n", me->NumOfDisplayPoint*/
	
	me->NumOfPoint = me->NumOfDisplayPoint ;

	*sts = HaveDispBuffer ? VR_K_ACT_SUCCESS : VR_K_NoDisplay ;

} /* VRGetCorrection */
/*----------------------------------------------------------------------------*/
action erase_point {

	dp$erase_hilite( msg = sts ) ;

} /* erase_point */
/*----------------------------------------------------------------------------*/
