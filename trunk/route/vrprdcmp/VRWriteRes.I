/* $Id: VRWriteRes.I,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRWriteRes.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRWriteRes.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
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
# Revision 1.3  1996/01/17  19:31:10  pinnacle
# Replaced: vrprdcmp/VRWriteRes.I for:  by r240_int for route240
#
# Revision 1.2  1995/12/17  18:10:10  pinnacle
# Replaced: ./vrprdcmp/VRWriteRes.I for:  by azuurhou for route240
#
 *
 * History:
 *	01/17/96    tlb		Add prototypes
 *
 ***************************************************************************/

class implementation VRHComp;

#include	<stdio.h>
#include	<stdlib.h>
%safe
#include	<math.h>
%endsafe
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"parametric.h"
#include	"VRcompdef.h"
#include	"vrparameters.h"
#include	"VRDbStruct.h"

#include	"vrpdu_pto.h"
#include	"vrprdcmp_pto.h"

#define	VR_PRE_DROP_CAL	1

/*TBD
	Extend the function VRGetVelPre to support metric units(
	find out the formula in metric units from mike )

	What is my formula for total pre in metric units ( both for
	static and dynamic ) ?

DONE	Format the output in a proper way

FUTURE :
	Implementation of friction factor and loss coefficients(
	main and branch coefficients ) needed( now the assumption
	is that it is stored in one of the collections ).

	How about defining a method for predrop calculation on the
	component itself( make use of ACgive_structure and support
	this )?

 	Now the branch and main loss coefficients are only supported
	for comps which have upto 3 cpts( TEEs )
NOTE :	
	make sure the velocity is the upstream velocity
	report to the file ( with the format )
	
			given by	Requiredgiven by	Required
status			system			system	
			IMPERIAL		METRIC
Done	Flowrate	ft3/min		same	m3/min		same
Done	EquiDiam	in		same	mm		same
	Velocity	fps		fpm	mps		mpm
	Vel.Pre		-		in	-		mm of water
	( NOTE : during the calculation of the Vel Pre the fluid is assumed
	as Air . this can be enchanced by getting the fluid from the comp
	and fetching corresponding specific density )
	Length		in		ft	mm		mt
	pre loss			in 			mm of water
*/

/**********************************************************************

   Doc: VRHvac.VRWriteAnalRes

   Abstract: This writes the analysis info to the given file for
	a component.

   History:
	24 Mar 94	Manyam	Creation

   Return Status:
	OM_S_SUCCESS	success

***********************************************************************/

method VRWriteAnalRes(
	IGRlong		*msg;		/* I/O - return status	*/
	IGRchar		cAnalType;	/* I   - Analysis type	*/
	FILE		*pFile;		/* I   - file ptr	*/
	IGRshort	nCptNum		/* I   - Cpt Num at which to report
					this is useful only in case of comps
					which has got more than 2 cpts. This
					helps in deciding whether to access
					the main coefficient or brach coe-
					fficient*/ 
						
)
{
	IGRint			status = OM_S_SUCCESS, SzOfEnv, NbBytes;
	IGRlong			retmsg;
	struct	GRmd_env	LocalEnv, *MyEnv=NULL;
	IGRdouble		VRGetVelPre();

	/*A initialization */	
	*msg = MSSUCC;

	if ( !pFile )
		return	OM_E_INVARG;

	SzOfEnv = sizeof( struct GRmd_env );
	gr$get_module_env( 
		msg    = &retmsg,
		sizbuf = &SzOfEnv,
		buffer = &LocalEnv,
		nret   = &NbBytes );

	if ( retmsg == MSSUCC )
		MyEnv = &LocalEnv;

	switch( (int)cAnalType )
	{
	  case	VR_PRE_DROP_CAL:
	  {
	    IGRint			FootIndex = -1;
	    struct	ret_struct	AttrSt;
	    struct	GRid		MyId;
	    IGRdouble			dFlowRate;

	    MyId.objid	= my_id;
	    MyId.osnum  = OM_Gw_current_OS;

	    FootIndex=-1;
	    status = 
	    om$send ( msg = message ACncpx.ACgive_structure(
		(IGRint *)&retmsg, &FootIndex, 
			VR_N_FLOW_RATE_DB, &AttrSt, MyEnv ),
		targetid = my_id );
	    as$status ( action = RET_STATUS );

	    dFlowRate = AttrSt.var.root_pm_st.value;

	    /*C check whether i am a duct or not */
	    if ( me->Desc.nItemNum == VR_PIPE && 
		me->Status & VR_CORRECTION )
	    {
		IGRdouble	dFriFactor, dWidth, dDepth, dEquiDiam;
		IGRdouble	dLength, dVelocity, dFriPreDrop, dVelPre;
		IGRint		Shape;

		/*C get the friction factor */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&retmsg, &FootIndex, 
				VR_N_FRICTION_FACT_DB, &AttrSt, MyEnv ),
		targetid = my_id );
		as$status ( action = RET_STATUS );
		dFriFactor = (IGRdouble) AttrSt.var.root_pm_st.value;

		/*C get the length of the component */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&retmsg, &FootIndex, 
				VR_N_DUCT_LNG_DB, &AttrSt, MyEnv ),
		targetid = my_id );
		as$status ( action = RET_STATUS );
		
		switch( VRenq_proj_units() )
		{
		  case VR_METRIC_UNITS:
		  case VR_MIXED_UNITS:
		  /*C system gives in mm */
		  dLength = AttrSt.var.root_pm_st.value/1000;
		  break;

		  case VR_IMPERIAL_UNITS:
		  /*C system gives in in */
		  dLength = AttrSt.var.root_pm_st.value/12;
		  break;
		}

		/*C get the shape of the section */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&retmsg, &FootIndex, 
				VR_N_SHAPE_IN, &AttrSt, MyEnv ),
		targetid = my_id );
		as$status ( action = RET_STATUS );
		Shape = (IGRint) AttrSt.var.root_pm_st.value;

		/*C get the width of the section */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&retmsg, &FootIndex, 
				VR_N_WIDTH1_DB, &AttrSt, MyEnv ),
		targetid = my_id );
		as$status ( action = RET_STATUS );
		dWidth = (IGRdouble) AttrSt.var.root_pm_st.value;

		/*C get the depth of the section */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&retmsg, &FootIndex, 
				VR_N_DEPTH1_DB, &AttrSt, MyEnv ),
		targetid = my_id );
		as$status ( action = RET_STATUS );
		dDepth = (IGRdouble) AttrSt.var.root_pm_st.value;
			
		/*C get the equivalent dia */
		status =
		VREquiDiam( Shape, dWidth, dDepth, &dEquiDiam );

		/*C calculate the velocity pressure( dependent on the
		    fluid, units ) */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&retmsg, &FootIndex, 
				VR_N_MAX_VELOC_DB, &AttrSt, MyEnv ),
		targetid = my_id );
		as$status ( action = RET_STATUS );

		/*C system gives pre sec : convert it to min */
		dVelocity = (AttrSt.var.root_pm_st.value)*60;

		dVelPre	= VRGetVelPre( dVelocity );

		/*C calculate the frictional predrop */
		dFriPreDrop =
		( ( (12*dFriFactor*dLength)/dEquiDiam ) * dVelPre );

		/*C report the results to the file */
		fprintf( pFile,
		"%-8s %-15s %-8s %-10G %-10G %-10G %-10s %-10G %-10s %-10G\n",
		"",me->szNumber, me->szAABBCC, dFlowRate, dEquiDiam, dVelocity,
		"", dLength, "", dFriPreDrop);

	    } else {
		/*C calculate the dynamic pressure */

		IGRdouble	dLossCoeft, dVelPre, dDynPreLoss,
				dVelocity;
		IGRchar		*cFootName=NULL;
		
		/*C get the fitting loss coefficient */
		if ( nCptNum > 1 )
		  cFootName = VR_N_BRANCH_COEFT_DB;
		else cFootName = VR_N_LOSS_COEFT_DB;
 
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&retmsg, &FootIndex, 
				cFootName, &AttrSt, MyEnv ),
		targetid = my_id );
		as$status ( action = RET_STATUS );
		dLossCoeft = (IGRdouble) AttrSt.var.root_pm_st.value;

		/*C calculate the velocity pressure */
		FootIndex=-1;
		status = 
		om$send ( msg = message ACncpx.ACgive_structure(
			(IGRint *)&retmsg, &FootIndex, 
				VR_N_MAX_VELOC_DB, &AttrSt, MyEnv ),
		targetid = my_id );
		as$status ( action = RET_STATUS );
		
		dVelocity = (AttrSt.var.root_pm_st.value)*60;

		/*C this is for imperial units and air as the fluid*/
		dVelPre	= VRGetVelPre( dVelocity );
		
		/*C calculate the dyn pre loss */
		dDynPreLoss = dLossCoeft * dVelPre;

		/*C report the info to the file */
		fprintf( pFile,
		"%-8s %-15s %-8s %-10G %-10s %-10G %-10G %-10s %-10G %-10G\n",
		"", me->szNumber, me->szAABBCC, dFlowRate, "", dVelocity,
		dVelPre, "", dLossCoeft, dDynPreLoss );

		
	    }
	  }		
	  break;

	  default:
		/*C for future use */		
	  break;
	}

	return	OM_S_SUCCESS;
}

end implementation VRHComp;
