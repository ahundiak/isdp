
/* $Id: VRCCompOver.I,v 1.5 2001/03/22 16:58:10 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconccomp / VRCCompOver.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCCompOver.I,v $
 *	Revision 1.5  2001/03/22 16:58:10  louis
 *	TR4725 - Disabled Plane orientation test because it was flipping the CCOMP component when the new segment was reverse of the old one.
 *	
 *	Revision 1.3  2001/02/20 01:12:52  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 15:49:55  anand
 *	SP merge
 *	
# Revision 1.5  2000/12/10  18:37:02  pinnacle
# Replaced: route/vrconccomp/VRCCompOver.I for:  by aharihar for Service Pack
#
# Revision 1.4  2000/12/08  20:44:02  pinnacle
# Replaced: route/vrconccomp/VRCCompOver.I for:  by aharihar for Service Pack
#
# Revision 1.3  2000/12/07  15:19:04  pinnacle
# Replaced: route/vrconccomp/VRCCompOver.I for:  by aharihar for Service Pack
#
# Revision 1.2  2000/05/11  22:57:24  pinnacle
# Replaced: route/vrconccomp/VRCCompOver.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/04/18  13:47:46  pinnacle
# Created for SPX
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/04  21:09:50  pinnacle
# Replaced: vrconccomp/VRCCompOver.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/07/24  19:10:36  pinnacle
# Replaced: vrconccomp/VRCCompOver.I for:  by lawaddel for route
#
# Revision 1.3  1997/04/10  13:03:14  pinnacle
# Replaced: vrconccomp/VRCCompOver.I for:  by hverstee for route
#
# Revision 1.2  1997/02/18  20:00:30  pinnacle
# Replaced: vrconccomp/VRCCompOver.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/05  00:02:40  pinnacle
# Replaced: vrconccomp/VRCCompOver.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/16  21:52:12  pinnacle
# Replaced: vrconccomp/VRCCompOver.I for:  by r240_int for route240
#
 *
 * History:
	09-DEC-91  Bruno	1.4.3.14	
				- VRInitInstances method has been removed.
				- VRSetInstances now does the ACset_db_info 
									method.
 *	01/16/96   tlb		Add prototypes
 *      07/24/97   law          TR179701284- Correct drawing scale area
 *      04/17/2000 Alwin        TR179901406. Added attributes for DynaPipe 
 *				Extraction.
 *      05/11/2000 Alwin        TR179901406. Added two more attributes for 
 *				DynaPipe 
 *     Dec  7 2k   Anand        JTS TR 4214 - dp_comp_ref_pnt
 *      03/08/01   law          dbg prints
 *	03/21/01   law          commented out plane flipping code for tr4725
 *
 *************************************************************************/

class implementation VRConcComp;

#include "vrparameters.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "VRdef.h"
#include "emsmass.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "VDScheckdef.h"
#include "ACcheckin.h"
#include "ACdb_info.h"
#include "acrepdef.h"
#include "VRPid.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "vrflow_pto.h"
#include "vrcompon_pto.h"
#include "vrtools_pto.h"
#include "bsdotp.h"
#include <string.h>
#include <stdlib.h>

extern	GRclassid	OPP_VRPiping_class_id;
extern	GRclassid	OPP_VRHvac_class_id;

from	GRlinear	import	GRgetpolyline;
from	EMSsurface	import	EMareaprop;
from 	EMSmassprop	import	EMset_density,
				EMinitialize,
				EMset_type,
				EMmpdelete;


#define AS_DEBUG	1
/*
#define MY_DEBUG	1
*/
/***********************************************************************/

method ACgive_structure(int *msg; int *direct_index; char *footname;
                        struct ret_struct *p_rs;
			struct GRmd_env *md_env)

{
	IGRint			status=OM_S_SUCCESS,i;
	IGRlong			retmsg;
	IGRint			BSmkvec();
	IGRdouble		BSlenvec();
	struct GRid		*pObjects;

	SetProc( VRCComp_ACgive_structure ); Begin

*msg=MSSUCC;
pObjects = NULL ;

		/*"---- %s ----\n",me->szAABBCC */

/*" Footname= %s \n", footname  */

if ( !(strcmp (footname, VR_N_OPTION_IN)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value= me->nOption;
}   

else if ( !(strcmp (footname, VR_N_BEND_ANG_DB)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value= 0;
}

else if ( !(strcmp (footname, VR_N_EQUIV_DIA_DB)) )
{
	IGRdouble	dAirFlow=0.0,
			dVeloc=0.0;	/* Parameters to compute the diameter 		*/
	IGRint		TmpIndex=-1;	/* Index of queried foot 			*/

	
	status= om$send (
			msg 	= message ACncpx.ACgive_structure 
				(msg, &TmpIndex, VR_N_FLOW_RATE_DB, p_rs, md_env),
			targetid= my_id);
	if ( ( status&(*msg)&1 ) )	dAirFlow = p_rs->var.root_pm_st.value;

	status=	om$send (
			msg = message ACncpx.ACgive_structure 
				(msg, &TmpIndex, VR_N_MAX_VELOC_DB, p_rs, md_env),
			targetid = my_id);
	if ( ( status&(*msg)&1 ) )	dVeloc = p_rs->var.root_pm_st.value;

	p_rs->type= double_type;

	VREquiDiamFV( dAirFlow, dVeloc, &p_rs->var.root_pm_st.value );

}/* end VR_N_EQUIV_DIA_DB */

#ifdef LES_OLETS_FOUTENT_LA_MERDE

Let the flow come out of the parameter box because of the olets 
else if ( !(strcmp (footname, VR_N_FLOW_RATE_DB)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value= 0.0;
	{
	register IGRint		i;
		IGRint		NbCpts;
		IGRdouble	dFlowRate;
		IGRshort	nFlowDir, nFlowRef;
		/* collect all the flows and return the some of the
		   output flow */
		status=
		om$send ( msg = message VRGeneric.VRGetNumberOfCpts 
				(&retmsg ,&NbCpts, md_env ),
			targetid = my_id);
		as$status ( action = RET_STATUS );

		nFlowRef = 999; /* initialize the type of flow, which will be sumed up,
				   to an unknown value */

		for (i=0; i<NbCpts; i++)
		{
			status=
			om$send ( msg = message VRGeneric.VRGetFlow 
					(&retmsg ,(IGRshort)i, &nFlowDir,
					 &dFlowRate, md_env ),
				targetid = my_id);
			as$status ( action = RET_STATUS );

			/* Initialize type of flow which will be sumed up to the first
			   cpt flow dir */
			if ( nFlowRef == 999 )
			{
				nFlowRef = nFlowDir;
				/*" Flow = sum ( flows(%d) ) \n", nFlowRef */
			} /* end initialize reference type of flow */

			if ( nFlowDir == VR_FLOW_UNKNOWN ) 
			{
				/* if one flow dir is unknown => cannot compute
				   the total flow => take it from the attributes box */

				struct GRid	SysParamId;

				/*| Get Flow From parameters box */

				status = om$send
				(msg = message VRGeneric.VRGetParams(&retmsg,&SysParamId,NULL,NULL),
				targetid = my_id);
				as$status();

				status = om$send
				(msg      = message NDmacro.ACgive_structure
				(msg, direct_index, footname , p_rs, md_env),
				targetid = SysParamId.objid,
				targetos = SysParamId.osnum);
				as$status();

				break;

			} /* end if an unknown flow direction */
			else if (  nFlowDir == nFlowRef ) 
			{
				/* add new flow to the global flow */
				p_rs->var.root_pm_st.value += dFlowRate;
			}

		}/* end loop for getting flows */
	}
}/* end VR_N_FLOW_RATE_DB */

#endif


else if ( !(strcmp (footname, VR_N_FLOW_DIR_IN)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value= 0.0;
}

else if ( !(strcmp (footname, VR_N_FLD_WELD_IN )) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value= 0.0;
}

/* -- SPECIAL FOR HVAC : wait for override in lower classes -- */

else if ( !(strcmp (footname,VR_N_SURF_AREA_DB )) )
{
	IGRdouble		dProps[20], dNullVect[3];
	IGRint			NbObj,ArrayLen;
extern	GRclassid		OPP_EMSsurface_class_id;

	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = 0.0;

	/* Get all graphic object */

	/* Send the surface area computation method to any surface object
	   which is connected on my to_component channel  */

	pObjects = NULL;
	ArrayLen = 10;

	/*| ----------> Malloc	pObjects */
	pObjects = _MALLOC( ArrayLen, struct GRid );
	if( pObjects == NULL )
	{
          printf(" Error not enougth dynamic memory \n");
          return  OM_E_NODYNMEM;
        }


	pObjects[0].objid = my_id;
	pObjects[0].osnum = OM_Gw_current_OS;
	NbObj = 1;

	dProps[11] = dNullVect[0] = dNullVect[1] = dNullVect[2] = 0.0;

	for (i=0; i<NbObj; i++ )
	{

		status = 
		VRGetNodes(&retmsg,i,&ArrayLen,&pObjects,&NbObj,OPP_EMSsurface_class_id );
		if( ! status )
		{
			printf(" Error in fct VRGetNodes\n");
			goto wrapup;
		}

		if( retmsg == MSSUCC )
		{

			/* 1- construct EMSmassprop object */
			struct GRid		MassPropId;
			struct GRvg_construct 	cst;
	        IGRdouble  dscale, dX[3], dY[3], dZ[3]; /* TR179701284 */
		extern	GRclassid		OPP_EMSmassprop_class_id;
		extern OM_S_CHANSELECT 		AS_notification;
			OM_S_CHANSELECT 	to_object;
	        /* TR179701284 - Correct drawing scale length */
	        dX [0]  = md_env->md_env.matrix [0];
	        dX [1]  = md_env->md_env.matrix [4];
	        dX [2]  = md_env->md_env.matrix [8];
	        dY [0]  = md_env->md_env.matrix [1];
	        dY [1]  = md_env->md_env.matrix [5];
	        dY [2]  = md_env->md_env.matrix [9];
	        dZ [0]  = md_env->md_env.matrix [2];
	        dZ [1]  = md_env->md_env.matrix [6];
	        dZ [2]  = md_env->md_env.matrix [10];
	        dscale = (BSlenvec ( &retmsg, dX) +
	                  BSlenvec ( &retmsg, dY) +
	                  BSlenvec ( &retmsg, dZ)) / 3.0;


			/*" Surface : id = %d\n", pObjects[i].objid */

			/*| ---- Create the massprop object ----  */
   
			cst.msg        = &retmsg;
			cst.newflag    = TRUE;
			cst.geometry   = NULL;
			cst.env_info   = md_env;
			cst.class_attr = NULL;
			cst.name       = NULL;
			cst.display    = NULL;
			cst.properties = 0;


			MassPropId.osnum = md_env->md_id.osnum;
   
			status =
			om$construct( 	classid = OPP_EMSmassprop_class_id,
			 		osnum   = MassPropId.osnum,
			 		p_objid = &MassPropId.objid,
			 		msg     = message GRvg.GRconstruct(&cst));

			__CheckRC( status, 1, "GRvg.GRconstruct", wrapup );
			/*"Massprop object : %d, %d\n",MassPropId.objid,MassPropId.osnum */

			/*| Connect the  massprop object to the surface */
			status =
			om$make_chanselect(	channame 	= "EMSmassprop.to_object",
						p_chanselect 	= &to_object);
			__CheckRC( status, 1, "make_chanselect", wrapup );

			status =
			om$send( msg = message Root.connect(	to_object, 
								GRDGNLIMITS_MAX_I,
   								pObjects[i].objid,
   								pObjects[i].osnum,
								AS_notification,
								0),
			targetid = MassPropId.objid,
			targetos = MassPropId.osnum);
			__CheckRC( status, 1, "Root.connect", wrapup );

			/*| Initialize the massprop object */
			status =
			om$send( msg = message EMSmassprop.EMinitialize(&retmsg),
				targetid = MassPropId.objid,
				targetos = MassPropId.osnum);
			__CheckRC( status, retmsg, "EMSmassprop.EMinit", wrapup );

			/*" Set the density to: %lf\n", 1.0 */
			status =
			om$send( msg = message EMSmassprop.EMset_density(&retmsg, 1.0),
				targetid = MassPropId.objid,
				targetos = MassPropId.osnum);
			__CheckRC( status, retmsg, "EMSmassprop.EMset", wrapup );

			/*" Set the operation type: %d\n", AREA_PROPERTIES */
			status =
			om$send( msg = message EMSmassprop.EMset_type
						(&retmsg, AREA_PROPERTIES),
				targetid = MassPropId.objid,
				targetos = MassPropId.osnum);
			__CheckRC( status, retmsg, "EMSmassprop.EMset_type", wrapup );

			/* ---- end construct EMSmassprop ---- */

			/* ---- 2- Get area properties ---- */

			status=
			om$send ( msg = message EMSsurface.EMareaprop
					(&retmsg, (IGRboolean)FALSE,1,md_env,
					(IGRdouble)1.0,dNullVect,dProps),
				targetid = pObjects[i].objid,
				targetos = pObjects[i].osnum );
			CheckRC( status, retmsg );

			/*"Surface area = %f\n",dProps[11] */
			/* TR179701284 - Correct drawing scale length */
			p_rs->var.root_pm_st.value += dProps[11]/dscale/dscale;
			
			/*| ---- Delete the mass prop object ----  */
			status =
			om$send( msg = message EMSmassprop.EMmpdelete(&retmsg, md_env),
				targetid = MassPropId.objid,
				targetos = MassPropId.osnum);
			CheckRC( status, retmsg );
		}

	}/* end loop */

}/* end VR_N_SURF_AREA_DB */

else if ( !(strcmp (footname, VR_N_ADDIT_WEIGHT_DB)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = 0.0;
}

else if ( !(strcmp (footname,VR_N_VELOC_CALC_DB )) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = 0.0;
}

else if ( !(strcmp (footname, VR_N_PRESS_DROP_DB)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = 0.0;
}
  /*These attributes are added for DynaPipe extraction for Avondale. 
  TR179901406 Alwin */
  else if( !strcmp( footname, "dp_comp_angle_pos" ) )
  {

     IGRlong    lngmsg;
     IGRdouble  dCoordCpt0[3], dCoordCenterPt[3];
     IGRdouble  pt_on_wheel[3], distance=1.0;
     IGRmatrix  ref_matrix;
     IGRvector  Y_axis, Y_unitvec;

	 p_rs->type = text_type;
	 p_rs->var.text_st.text_string[0] = '\0';

     /* Get the Component's matrix ( Center Point ) */
     status = om$send( msg = message VRGeneric.VRGetMatrix
                                           ( &lngmsg, 0, NULL, ref_matrix,
                                             md_env ),
                        targetid = my_id);
     as$status( action = RET_STATUS );

     dCoordCenterPt[0] = ref_matrix[3];
     dCoordCenterPt[1] = ref_matrix[7];
     dCoordCenterPt[2] = ref_matrix[11];
     __DBGpr_vec( " Center Point of Component ", dCoordCenterPt );

     Y_axis[0] = ref_matrix[1];
     Y_axis[1] = ref_matrix[5];
     Y_axis[2] = ref_matrix[9];
     MAunitvc( &lngmsg, Y_axis, Y_unitvec );

	 __DBGpr_vec( "  Vector on Y-axis ", Y_axis );
	 __DBGpr_vec( " Unit Vector on Y-axis ", Y_unitvec );
	 distance = 100.0;
     pt_on_wheel[0] = dCoordCenterPt[0]  + Y_unitvec[0]*distance;
     pt_on_wheel[1] = dCoordCenterPt[1]  + Y_unitvec[1]*distance;
     pt_on_wheel[2] = dCoordCenterPt[2]  + Y_unitvec[2]*distance;
     __DBGpr_vec( " Point on Valve's wheel ", pt_on_wheel );

     p_rs->type = text_type;
     p_rs->var.text_st.text_string[0] = '\0';
     sprintf( p_rs->var.text_st.text_string, "%f,%f,%f",
                pt_on_wheel[0], pt_on_wheel[1], pt_on_wheel[2] );
  }
  else if( !strcmp( footname, "dp_comp_ref_pnt" ) )
  {
    struct GRid RefOutID;
    struct GRmd_env FtMdEnv;

    p_rs->type = text_type;
    p_rs->var.text_st.text_string[0] = '\0';

    FtMdEnv = *md_env;
    RefOutID.objid = NULL_OBJID;
    status = om$send( msg = message NDmacro.ACreturn_foot( &retmsg,
							   "graphics:ref_out1",
							   &RefOutID,
						 &FtMdEnv.md_env.matrix_type,
						 FtMdEnv.md_env.matrix ),
		 targetid = my_id );
    as$status();
    __DBGpr_obj(" component's \"ref_out1\" feet's ID", RefOutID );

    if( RefOutID.objid != NULL_OBJID )
    {
	IGRdouble	Coord[3];
	struct IGRpolyline	LineIn;
	IGRint		Action;

	Action = 1;
	LineIn.points = Coord;
	status = om$send( msg      = message GRlinear.GRgetpolyline( &retmsg,
						 &FtMdEnv.md_env.matrix_type,
						 FtMdEnv.md_env.matrix,
						 &Action, &LineIn),
			  targetid = RefOutID.objid,
			  targetos = RefOutID.osnum );
       as$status( action = RET_STATUS );
       __DBGpr_vec(" Coordinates of ref_out1",Coord);

       sprintf( p_rs->var.text_st.text_string, "%f,%f,%f",
						Coord[0], Coord[1], Coord[2] );
    }
    else
    /* If the macro does not have "ref_out1" as its feet, simply get its own
     * matrix.					- Anand for JTS TR 4214 */
    {
	IGRmatrix ref_matrix;

	status = om$send( msg      = message VRGeneric.VRGetMatrix( &retmsg, 0,
								    NULL,
								    ref_matrix,
								    md_env ),
			  targetid = my_id );
	//as$status( action = RET_STATUS );
	if( !retmsg & 1 )
	    __DBGpr_com( " Failed to fetch dp_comp_ref_pnt " );

	sprintf( p_rs->var.text_st.text_string, "%f,%f,%f",
                            ref_matrix[3], ref_matrix[7], ref_matrix[11] );
    }
  }
  else if( !strcmp( footname, "dp_conn_pnt_count" ) )
  {
     /* Find out the Number of Connect points and return that as the output */

	/* Initializing this to 1.0, b'cas no component in ROUTE can have
	a number of connect points less than one. In the case of the dangle
	the following call won't return the proper value and would fail. */

        IGRint NbCpts;

	p_rs->var.root_pm_st.value = NbCpts = 1.0;

	status=
	om$send ( msg = message VRGeneric.VRGetNumberOfCpts 
			( &retmsg, &NbCpts, md_env ),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	p_rs->type = double_type;
	p_rs->var.root_pm_st.value = (IGRdouble)NbCpts;
	__DBGpr_int( " Number of Connect Points ", NbCpts );
  }
  else if( !strncmp( footname, "dp_conn_pnt_", 12 ) )
  {
     IGRint cpt_no;
     IGRdouble	dCoord[3];
     IGRchar temp_string[20], cpt_str[10];

     /* Parse the footname to find out which "connect point" coordindates 
     are being asked for. And accordingly return the coordinates */

     __DBGpr_com(" Get the coordinates of the Comp. Connect pt ");
     strcpy( temp_string, &footname[12] );

     __DBGpr_str(" temp_string 0", temp_string );

     cpt_no = atoi( strtok( temp_string, "_" ) );
     __DBGpr_str(" Connect point string ", strtok( temp_string, "_" ) );
     __DBGpr_int(" Connect Point Number ", cpt_no );

     status = 
     om$send( msg = message VRGeneric.VRGetCptGeom( &retmsg,
					(IGRshort)cpt_no, dCoord, 
					NULL, NULL, md_env ),
		    targetid = my_id );
     as$status ( action = RET_STATUS );

     __DBGpr_vec(" Coord ", dCoord );

     p_rs->type = text_type;
     p_rs->var.text_st.text_string[0] = '\0';
     sprintf( p_rs->var.text_st.text_string, "%f,%f,%f", 
				dCoord[0], dCoord[1], dCoord[2] );
  }
  /*These attributes are added for DynaPipe extraction for Avondale. Alwin */
else
{

	/*A Try generic feet management */
	status=
	om$send (msg = message VRGeneric.ACgive_structure 
			(msg, direct_index, footname, p_rs, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	/*" status = %d, msg = %d\n", status, *msg */

}/* end try OM_e_wrt_message */


wrapup:
	_FREE( pObjects );
	End
	return ( status );

}/* end ACgive_structure */

/***********************************************************************/

method VRSetInstance ( IGRlong	*msg; struct VRGenInfo *Instance )

{
	IGRshort        i, jj;
        IGRlong         retmsg;
	IGRint 		status;

	*msg = MSSUCC;

		/*"---- %s ----\n",me->szAABBCC */

	/* -- Init super class instance -- */
	status =
	om$send ( msg = message VRGeneric.VRSetInstance
			(msg, Instance),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	as$status ();

	/*" newAABBCC = %s\n",me->szAABBCC */

	/* -- Store component index on segments -- */
	for ( i=0; i<me->nNbTopo; i++ ) 
	{
          jj = Instance->Attr.CComp.nIndex[i];

          status =
          om$send (msg = message VRConcComp.VRSetMEIX (&retmsg, i, jj),
              targetid = my_id);
        }

	/* -- Store component orientation angle -- */
/*	me->dAngleToCommon = Instance->Attr.CComp.dAngleToCommon; */

	/* -- Set status for checkin -- */

	{
		struct ACdb_info	DbInfo;
		GRclassid		MyClassId;
		IGRlong			retmsg;

		om$get_classid (objid = my_id,
				osnum = OM_Gw_current_OS,
				p_classid = &MyClassId );

		if ( om$is_ancestry_valid
				( subclassid   = MyClassId,
				  superclassid = OPP_VRPiping_class_id )
		     == OM_S_SUCCESS )
		{
			/*| -- PIPING object -- */
			if ( bVR_IS_PID(me->xform_chan)	)
				DbInfo.quantity = PID_PIPING_OBJ;
			else	DbInfo.quantity = PIPING_OBJ;
		}
		else
		if ( om$is_ancestry_valid
				( subclassid   = MyClassId,
				  superclassid = OPP_VRHvac_class_id )
		     == OM_S_SUCCESS )
		{
			/*| -- HVAC object -- */
			if ( bVR_IS_PID(me->xform_chan)	)
				DbInfo.quantity = SCH_HVAC_OBJ;
			else	DbInfo.quantity = HVAC_OBJ;
		}
		else
		{
			/*| -- RWAY object -- */
			DbInfo.quantity = RWAY_OBJ;
		}
		status = om$send(msg = message ACdb_info.ACset_db_info
						( &retmsg, &DbInfo),
			targetid = my_id);
		as$status();


	}/* end set db_info */

	return ( OM_S_SUCCESS );

}/* end VRSetInstance */

/***********************************************************************/

method VRGetPlanes ( IGRlong *msg;  IGRint ArraySize; 
			struct GRid PlaneIds[]; IGRint *NbPlanes; struct GRmd_env *md_env)

{

	/* -- The supports are the last templates of the list -- */

	IGRint		status, NbRoots,i;
	struct GRid	*buffer;

	*msg = MSSUCC;
		/*"---- %s ----\n",me->szAABBCC */

	status = 
	om$send( msg	 = message NDnode.NDget_objects(
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&NbRoots ),
	           	targetid = my_id);
	as$status( action = RET_STATUS );

	/*" %d templates\n",NbRoots */
	/*" %d planes \n",(NbRoots-me->nNbAttr-me->nNbTopo) */

	*NbPlanes = (NbRoots-me->nNbAttr-me->nNbTopo);

        if ( PlaneIds )
	{
	 for ( i=0; (i<*NbPlanes && i<ArraySize); i++)
		PlaneIds[i]= buffer[me->nNbAttr+i];
	}
	return ( OM_S_SUCCESS );

}/* end VRGetPlanes */

/***********************************************************************/

method VRGetPlanesOnCpt ( IGRlong *msg ; IGRshort nCpNum; struct GRid *PlaneIds;
			struct GRmd_env *md_env)
{
	IGRint 		status, NbPlanes;
	struct GRid	MyPlaneIds[3*VR_MAX_CPTS];

		/*"---- %s ----\n",me->szAABBCC */

	*msg = MSSUCC;

	status=
	om$send ( msg = message VRGeneric.VRGetPlanes ( msg, (3*VR_MAX_CPTS),
					MyPlaneIds, &NbPlanes, md_env),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	if ( (3*nCpNum + 2) > NbPlanes ) return OM_E_INVARG;

	PlaneIds[0] = MyPlaneIds[3*nCpNum    ];
	PlaneIds[1] = MyPlaneIds[3*nCpNum + 1];
	PlaneIds[2] = MyPlaneIds[3*nCpNum + 2];

	/* -- Check whether this connect point is already connected -- */

	/* Get Neighbor on cpt */

	{
		IGRint		NbNeigh=0;
		status =
		om$send ( msg = message VRGeneric.VRGetNeighbors (msg, 
				(IGRint) nCpNum, (IGRint) nCpNum,
				&NbNeigh,NULL,NULL, md_env ),
			targetid = my_id );
		if ( NbNeigh )
		{
			/*| CP ALREADY CONNECTED*/
			*msg = MSFAIL;
		}

	}/* end test on connect point free */

return OM_S_SUCCESS;

}/* end VRGetPlanesOnCpt */

/***********************************************************************/

method VRGetIndex ( IGRlong *msg; struct GRid *SegmentId; IGRshort *CompIndex)

{
	IGRint 			status;
	IGRuint			TempIndex;
        IGRshort                ii;
        IGRint                  NumPlanes;
	OM_S_CHANSELECT		father;

*msg = MSSUCC;
father.type = OM_e_name;
father.u_sel.name = "father";

	/* -- get specified template index -- */

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &father,
			objid		= SegmentId->objid,
			indexaddr	= &TempIndex  );
#ifdef MY_DEBUG
        printf ("GETINDEX for %d, returns index,status %d %d\n", 
                                 SegmentId->objid, TempIndex, status);
        if (!(status & OM_S_SUCCESS)) printf (" ERROR\n");
#endif

	as$status ( action = RET_STATUS );

	/* -- get index on segment from my list of indexes -- */
	/* -- count the real number of planes .....           */
        /* == when deleting plane may already be gone         */

        status =
        om$send (msg = message VRConcComp.VRGetPlanes
                                (msg, 0, NULL, &NumPlanes,
                                 NULL /* md_env superfluous */),
            targetid = my_id);

        ii = TempIndex - me->nNbAttr - (me->nNbCpts*3);

        if ((me->nNbCpts*3) != NumPlanes)
        {

#ifdef MY_DEBUG
          printf (" PLANE DISAPPEARED %d vs $d\n", (me->nNbCpts*3), NumPlanes);
#endif
          ii = TempIndex - me->nNbAttr - NumPlanes;
        }

        status =
        om$send (msg = message VRConcComp.VRGetMEIX (msg, ii, CompIndex),
            targetid = my_id);

return ( OM_S_SUCCESS );

}/* end VRGetIndex */

/***********************************************************************/

method NDmove_to_root ( IGRlong *msg; struct GRid *src_grid;
                        struct GRmd_env *md_env )

{
	IGRlong         retmsg;
	IGRint		status=OM_S_SUCCESS;
	IGRint		NbRoots;
	struct GRid	*buffer,DelTempIds[4*VR_MAX_CPTS+VR_NB_ATTR], MyId;
	IGRint 		wait_index[4*VR_MAX_CPTS + VR_NB_ATTR];
	IGRshort	i,j;
	IGRshort	nPrevTopo;



*msg = MSSUCC;

src_grid->objid = NULL_OBJID;

/* -- GET DELETED IN EVERY CASE -- */

	/* -- Get my templates -- */

	status = 
	om$send( msg	 = message NDnode.NDget_objects(
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&NbRoots ),
		targetid = my_id);
	as$status( );


	/* -- Else count number of templates in delete list -- */

	status =
	NDis_waiting(	GR_DELETED, 
			0, 
			buffer, 
			wait_index,  /* -1 if not waiting */
			NULL, 
			NULL, 
			NbRoots);

	nPrevTopo = me->nNbTopo;

	/* -- Looking for attributes deletion -- */
	for ( i = 0;i<me->nNbAttr; i++)
	{
		if ( wait_index[i] != -1 )
		{
			/*" loosing attr[%d]\n",i*/
			me->nNbAttr -= 1;

		}
	}/* end scanning attributes */

	/* -- Looking for segment deletion -- */
	for ( i = (NbRoots-me->nNbTopo); i<NbRoots; i++)
	{

		if ( wait_index[i] != -1 )
		{
                   IGRshort     ii,jj;

			/*"loosing topo[%d]:<%d,%d>\n",i,buffer[i].objid,buffer[i].osnum*/
			/* store lost template */
			DelTempIds[nPrevTopo-me->nNbTopo] = buffer[i];
			me->nNbTopo -= 1;

			ii = i-(NbRoots-me->nNbTopo);
                        jj = -1;

			status =
			om$send (msg = message VRConcComp.VRSetMEIX
                                                 (&retmsg, ii, jj),
			    targetid = my_id);
		}
	}/* end scanning segments */


	if ( nPrevTopo != me->nNbTopo )
	{
		/*| Compress table of indexes */
		j=0;
		for (i=0; i<nPrevTopo; i++)
		{
                   IGRshort     jj;

                   status =
                   om$send (msg = message VRConcComp.VRGetMEIX
                                                  (&retmsg, i, &jj),
                       targetid = my_id);

			if ( jj != -1 )
			{
                          status =
                          om$send (msg = message VRConcComp.VRSetMEIX
                                                  (&retmsg, j, jj),
                              targetid = my_id);
			  j++;
			}
		}/* end loop on index table */

		/*" Disconnect %d templates\n", (nPrevTopo-me->nNbTopo) */

		status=
		om$send ( msg = message NDnode.NDdisconnect
					( (nPrevTopo-me->nNbTopo), DelTempIds ),
			targetid = my_id );

	}/* end update index list */


	/*" %d Topo left\n",me->nNbTopo */
	/*" %d Attr left\n",me->nNbAttr */


	/* -- Delete via batch : Call VRDeleteObjects function ( 04-02-92 ) -- */
	MyId.objid = my_id; MyId.osnum = OM_Gw_current_OS;

	status = VRDeleteObjects( 1, &MyId, md_env );
	as$status();


return ( OM_S_SUCCESS );

}/* end of NDmove_to_root */

/***********************************************************************/

method NDchange_connect( IGRint nb_root; struct GRid *old, *new )
{
  	BSrc	 			bsretcode;
  	IGRshort			matrix_type;
  	IGRint				i, Index;
	IGRuint				PlaneIndex;
	GRclassid			OldClassId, NewClassId;
  	IGRlong 			retcode=MSSUCC, status=OM_S_SUCCESS;
  	IGRdouble 			Scalar, Point[6], Normal[6];
  	IGRmatrix			matrix;
  	OM_S_CHANSELECT 		father;
  	struct		GRid		go_planes;
  	struct		IGRplane	OldPlane, NewPlane;

	extern		GRclassid	OPP_VRplane_class_id;

	SetProc( VRCComp_NDchange_connect ); Begin
        __DBGpr_obj("old",*old);
        __DBGpr_obj("new",*new);
	father.type = OM_e_name;
	father.u_sel.name = "father";

	OldPlane.point  = Point;
	OldPlane.normal = Normal;
	NewPlane.point  = &Point[3];
	NewPlane.normal = &Normal[3];

	for( i=0; i<nb_root; i++ )
	{
		/*"old[%d] = %d %d\n", i, old[i].objid, old[i].osnum */
		/*"new[%d] = %d %d\n", i, new[i].objid, new[i].osnum */

        	om$get_classid (        osnum 	  = old[i].osnum,
                                	objid 	  = old[i].objid,
                                	p_classid = &OldClassId );

        	om$get_classid (        osnum 	  = new[i].osnum,
                                	objid 	  = new[i].objid,
                                	p_classid = &NewClassId );

		if( OldClassId != NewClassId )
		{
			as$status( sts = OM_E_ABORT, msg = "old and new template should be of the same class" );
			return OM_E_ABORT;
		}

        	if( om$is_ancestry_valid( subclassid      = OldClassId,
                                          superclassid    = OPP_VRplane_class_id ) == OM_S_SUCCESS )
        	{
			status = om$get_index( 	object_c 	= me,
						p_chanselect	= &father,
						objid		= old[i].objid,
						indexaddr	= &PlaneIndex );
			as$status ( action = RET_STATUS );

			/*"PlaneIndex = %d\n", PlaneIndex */

      			status = om$send( msg      = message NDnode.ASreturn_go
                		                     ( &go_planes, &matrix_type, matrix ),
                        		  targetid = old[i].objid,
                        		  targetos = old[i].osnum );
      			as$status( action = RET_STATUS );

	       		/*"go_planes = %d %d\n", go_planes.objid, go_planes.osnum */

      			status = om$send( msg      = message GRvg.GRdetplane
                                   			( &retcode, &matrix_type, matrix, &OldPlane ),
    	 	        	  	  targetid = go_planes.objid,
	  	        	  	  targetos = go_planes.osnum );
      			as$status( action = RET_STATUS );
      			as$status( sts = retcode, action = RET_STATUS );
 
      			status = om$send( msg      = message NDnode.ASreturn_go
                		                     ( &go_planes, &matrix_type, matrix ),
                        		  targetid = new[i].objid,
                        		  targetos = new[i].osnum );
      			as$status( action = RET_STATUS );

	 	        /*"go_planes = %d %d\n", go_planes.objid, go_planes.osnum */
 
      			status = om$send( msg      = message GRvg.GRdetplane
                        	           		( &retcode, &matrix_type, matrix, &NewPlane ),
    	 	        	  	  targetid = go_planes.objid,
	  	        	  	  targetos = go_planes.osnum );
      			as$status( action = RET_STATUS );
      			as$status( sts = retcode, action = RET_STATUS );

			/*"Old_N = %f %f %f\n", Normal[0], Normal[1], Normal[2] */
			/*"New_N = %f %f %f\n", Normal[3], Normal[4], Normal[5] */

			Scalar = BSdotp( &bsretcode, OldPlane.normal, NewPlane.normal );

			/*"Scalar = %f\n", Scalar */

/************ removed for connecting networks for TR4725
 ************ It was flipping CCOMPs when the new segment was opposite in direction to old one
			if( Scalar < 0 ) 
			{
				 Inverse orientation 
				Index = PlaneIndex - me->nNbAttr;
				if (Index == 0)
				me->nOrienToPlanes[Index] *= -1;
				if( Index == 3 * me->nJustif + 1 )
				{
					 Inverse axis 
					me->dAngleToCommon *= -1;
				}
			}
*****************/
		}
	}

  	status = om$send( mode     = OM_e_wrt_message,
                   	  msg      = message ASnode.NDchange_connect( nb_root, old, new ),
 		    	  targetid = my_id );
  	as$status( action = RET_STATUS );

        End
  	return OM_S_SUCCESS;
}

end implementation VRConcComp;
