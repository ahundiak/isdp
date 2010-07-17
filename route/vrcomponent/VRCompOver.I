/* $Id: VRCompOver.I,v 1.6 2002/06/14 18:32:56 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcomponent / VRCompOver.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCompOver.I,v $
 *	Revision 1.6  2002/06/14 18:32:56  louis
 *	Bend_sweep fix
 *	
 *	Revision 1.5  2002/03/19 23:25:00  louis
 *	TR5982 - bendsweep corrections
 *	
 *	Revision 1.4  2001/02/27 19:25:27  ad
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/02/20 01:12:43  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 15:36:39  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *
 *
# Revision 1.6  2000/12/14  16:11:54  pinnacle
# Replaced: route/vrcomponent/VRCompOver.I for:  by aharihar for Service Pack
#
# Revision 1.5  2000/12/10  18:37:12  pinnacle
# Replaced: route/vrcomponent/VRCompOver.I for:  by aharihar for Service Pack
#
# Revision 1.4  2000/12/08  20:43:52  pinnacle
# Replaced: route/vrcomponent/VRCompOver.I for:  by aharihar for Service Pack
#
# Revision 1.3  2000/12/07  15:15:02  pinnacle
# Replaced: route/vrcomponent/VRCompOver.I for:  by aharihar for Service Pack
#
# Revision 1.2  2000/11/07  16:55:52  pinnacle
# Replaced: route/vrcomponent/VRCompOver.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/05/23  17:26:10  pinnacle
# Created: route/vrcomponent/VRCompOver.I by lawaddel for Service Pack
#
# Revision 1.7  2000/04/04  19:42:54  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by apazhani for route
#
# Revision 1.6  2000/04/03  22:04:58  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by apazhani for route
#
# Revision 1.5  1999/06/14  20:52:58  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by lawaddel for route
#
# Revision 1.3  1999/06/01  15:50:36  pinnacle
# dynapipe
#
# Revision 1.2  1999/06/01  12:46:58  pinnacle
# Modified the file for DynaPipe to add the additional attributes
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/04  21:10:42  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.5  1997/07/24  19:19:32  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by lawaddel for route
#
# Revision 1.4  1997/07/14  15:52:28  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by lawaddel for route
#
# Revision 1.3  1997/07/10  19:28:46  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/04/04  22:36:20  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by r240_int for route240
#
# Revision 1.5  1996/03/19  18:12:28  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by msmanem for route240
#
# Revision 1.4  1996/01/16  21:47:22  pinnacle
# Replaced: vrcomponent/VRCompOver.I for:  by r240_int for route240
#
 *
 * History:
	29-DEC-91	Bruno 	1.4.5.12
					- Override VRGetPlanesOnCpt
	31-Mar-94	Manyam	02.03.00.03
					- Override NDdelete
        22-Dec-95     Henk	02.04.00.13
                			- Override ACgive_db_structure for post
	19-Mar-96     Mallik	02.04.00.16
					- Disabled computation of Pressure drop.
					TR # 179601121
  	01/16/96  	tlb	Add prototypes
  	07/10/97	law	Initialize bend_sweep for TR179701251 and
                                correct failures for TR179701343.
 *      07/24/97   law          TR179701284- Correct drawing scale area
 *      06/01/99   Alwin        Exposed few attributes specific for DynaPipe
 *				requirements. DP_conn_pnt_count, DP_comp_angle,
 *				DP_conn_pnt_NN_xyx.
 *      06/11/99   law          Added dp_comp_ref_pnt for Dynapipe
 *      04/03/00   Alwin        Added one more attribute for dynapipe 
 *				alternative solution to find comp_angle. 
 *				As per users request. TR179900960
 *	12/7/2k	   Anand	JTS TR 4214 - dp_comp_ref_pnt
 *      03/13/02   Ad Zuurhout  tr5982-bend_sweep not computing correctly
 *      6/14/02    law		Last resort computation of bend_sweep using
 *				cpt and ref locations.
 *************************************************************************/

class implementation VRComponent;

#include <string.h>
#include <math.h>
#include "vrparameters.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "bstypes.h"
#include "bserr.h"
#include "VRdef.h"
#include "acrepdef.h"
#include "emsmass.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "vrmacros.h"
#include "vrparameters.h"
#include "VRMath.h"
#include "VRPid.h"
#include "vrflow_pto.h"
#include "vrcompon_pto.h"
#include "vrprdcmp_pto.h"
#include "maunitvc.h"
#include "bsdistptpt.h"

#define M_PI            3.14159265358979323846

#define AS_DEBUG	1

from	GRlinear	import	GRgetpolyline;
from	EMSsurface	import	EMareaprop;
from 	EMSmassprop	import	EMset_density, EMinitialize, EMset_type, EMmpdelete;
from	VRCnrlSeg	import	VRget_planes;
from	VRCorrection	import 	VRNotifyDelete;
from    VRCorrection    import  VRGetPipeCpts;

extern double VRcompute_angle();
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

  SetProc( VRComponent_ACgive_structure ); Begin

  *msg=MSSUCC;
  pObjects = NULL ;

   __DBGpr_str("szAABBCC ----",me->szAABBCC );


   __DBGpr_str(" Footname= ", footname );

if ( !(strcmp (footname, VR_N_OPTION_IN)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value= me->nOption;
}   

else if ( !(strcmp (footname, VR_N_BEND_ANG_DB)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = 0.0;
	
	status =
	om$send (msg = message VRComponent.VRGetAngle
		(&retmsg, &p_rs->var.root_pm_st.value, md_env),
		targetid = my_id );
        /* tr5982-fix compute of bend_sweep */
   	__DBGpr_dbl(" BEND_SWEEP ", p_rs->var.root_pm_st.value );
	if ((!(status&1) || (retmsg != MSSUCC)) ) 
	{

	    /*
	     * Check if information is stored in the Static data 
	     * from the pipingdb collectors.
	     */
	    struct ACrg_coll Param;
	
	    strcpy( Param.name, VR_N_BEND_ANG_DB);
	    Param.desc.value.att_exp = 0.0 ;

	    status =
	    om$send (msg = message VRGeneric.VRGetCompDesc( &retmsg,
					&Param, md_env ),
			targetid = my_id );
   	    __DBGpr_dbl(" BEND_SWEEP CompDesc ", Param.desc.value.att_exp );
   	    __DBGpr_int("  STATTUS ", status );
   	    __DBGpr_int("  RETMSG ", retmsg );

	    if (status&1&retmsg ) {
		p_rs->var.root_pm_st.value = Param.desc.value.att_exp ;
	    }
	    else {
                 /* End tr5982 */
		/*" Cannot compute foot %s \n", VR_N_BEND_ANG_DB */
		OM_S_CHANSELECT chansel;
		register IGRint	i;

		chansel.type       = OM_e_name;
		chansel.u_sel.name = "father";

		/*| Try in ATTRIBUTES collections */
		for ( i=0, status=0; (i<me->nNbAttr) && 
				(status != OM_S_SUCCESS || !(*msg & 1)); i++ )
		{
                        /* law : 10 Jul 97 initialize at the right moment this time. */
			p_rs->var.root_pm_st.value = 0.0;
			status=
			om$send (msg = message ACncpx.ACgive_structure 
				(msg, direct_index, footname, p_rs, md_env),
				p_chanselect= &chansel,
				from	    = i,
				to	    = i);
			/*" Collection %d : status = %d, msg = %d\n",i, status, *msg */
		}
                if(status != OM_S_SUCCESS || !(*msg & 1))
                {
                   IGRdouble tmpangle, refpt[3],CptCoord[3];
                   IGRshort  kshrt, cmp_systype;
                   IGRlong retcode;
                   IGRint NbCpts, jj;
                   IGRdouble compvec[30];
                   IGRvector compvec0,compvec1;
                   IGRvector normal;
                   BSrc  bsretcode;
                   IGRpoint CptCoord0,CptCoord1;
                   status =
                       om$send ( msg = message VRGeneric.VRGetNumberOfCpts(
                                &retcode, &NbCpts,  md_env ),
                            targetid = my_id);

                   status = om$send( msg      = message VRGeneric.VRGetOrigCoor
                              ( &retcode, refpt, md_env),
                            targetid = my_id);
       
                   p_rs->var.root_pm_st.value = 0.0;
                   status = om$send( msg = message VRGeneric.VRGetSysType
                              ( &retcode, &cmp_systype ),
                        targetid = my_id);
                   *msg = MSSUCC;
                   if(cmp_systype != VR_PIPE && NbCpts < 4 && NbCpts > 1)
                   {
                      /* included origin on cpt check */
                      IGRint no_error_flag;
                      no_error_flag = 1;
                      for(kshrt = 0; kshrt < (IGRshort) NbCpts; kshrt++)
                      {
                         status = om$send( msg  = message VRGeneric.VRGetCptGeom
                                 ( &retcode, kshrt, CptCoord, NULL,
                                   NULL, md_env ),
                              targetid = my_id);
                         if(kshrt == 0)
                         {
                            for (jj=0; jj<3; jj++)
                            {
                               compvec0[jj] = refpt[jj] - CptCoord[jj];
                            }
                               if((fabs(compvec0[0]) < VR_LENGTH_TOL) &&
                                  (fabs(compvec0[1]) < VR_LENGTH_TOL) &&
                                  (fabs(compvec0[2]) < VR_LENGTH_TOL))
                                      no_error_flag = 0;
                         }
                         else /* Note that for a TEE,
                                      the third cpt overwrites the 2nd ***/
                         {
                            for (jj=0; jj<3; jj++)
                            {
                               compvec1[jj] = CptCoord[jj] - refpt[jj];
                            }
                               if((fabs(compvec1[0]) < VR_LENGTH_TOL) &&
                                  (fabs(compvec1[1]) < VR_LENGTH_TOL) &&
                                  (fabs(compvec1[2]) < VR_LENGTH_TOL))
                                      no_error_flag = 0;
                         }
                      }
                      if(no_error_flag)
                      {
                         BScrossp ( &bsretcode, compvec0, compvec1, normal);
                         tmpangle = VRcompute_angle(compvec0,compvec1,normal);
                         tmpangle /= M_PI/180.;
                         p_rs->var.root_pm_st.value = tmpangle;
                         *msg = MSSUCC;
                      }
                   }
                }
	    }
	}
} /* end return real angle */

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
	    End
	    return  OM_E_NODYNMEM;
	}


	pObjects[0].objid = my_id;
	pObjects[0].osnum = OM_Gw_current_OS;
	NbObj = 1;

	dProps[11] = dNullVect[0] = dNullVect[1] = dNullVect[2] = 0.0;

	for (i=0; i<NbObj; i++ )
	{

		status = 
		VRGetNodes(	&retmsg,i,&ArrayLen,
				&pObjects,&NbObj,OPP_EMSsurface_class_id );
		__CheckRC( status, 1, "VRGetNodes", wrapup );

		if( retmsg == MSSUCC )
		{

			/* 1- construct EMSmassprop object */
			struct GRid		MassPropId;
			struct GRvg_construct 	cst;
		extern	GRclassid		OPP_EMSmassprop_class_id;
		extern OM_S_CHANSELECT 		AS_notification;
			OM_S_CHANSELECT 	to_object;
	         IGRdouble  dscale, dX[3], dY[3], dZ[3];
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
			om$send( msg = message Root.connect(
						to_object, 
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
			__CheckRC( status, retmsg, "EMSmassprop.EMset_density", wrapup );

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

/*	Disabled Pressure drop computation for now. 03/19/96 
	TR # 179601121

	IGRdouble	dPreDrop;
	struct	GRid	MyId;

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;
*/

	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = 0.0;

	/*A since we can not specify the cpt num at which the 
	predrop	needs to be returned, always return the predrop
	in the main section					*/

/*
	status =
	VRCalPreDrop ( &MyId, -1, &dPreDrop, md_env );
	as$status( action = RET_STATUS );

	p_rs->var.root_pm_st.value = dPreDrop;
*/
  }
  /*These attributes are added for DynaPipe extraction for Avondale. Alwin */
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
  else if( !strcmp( footname, "dp_comp_angle" ) )
  {
     /* return the angle only for FLANGES & VALVES. For the rest of the 
     components return zero as the output and wrong return status */

      IGRint		NumbPar;
      struct GRid	MyId;
      struct ACrg_coll 	AttList;

      MyId.objid = my_id;
      MyId.osnum = OM_Gw_current_OS;

      NumbPar = 1;
      strcpy( AttList.name, VR_N_COMP_TYPE_IN );

      p_rs->type = double_type;
      p_rs->var.root_pm_st.value = 0.0;

      status =
      vr$review_parameters(   pMsg            = &retmsg,
			      pComponent      = &MyId,
			      NbParams        = NumbPar,
			      pList           = &AttList,
			      pMdEnv          = md_env );
      as$status ( action = RET_STATUS );

      if( ( AttList.desc.value.att_exp == VRP_V_VALVE_TYPE ) || 
	  ( AttList.desc.value.att_exp == VRP_V_FLANGE_TYPE ) )
      {
	 /* The component's angle is rotation of the Secondary axis of the
	 component which's is stored in the Component's instance */

	 p_rs->var.root_pm_st.value = me->Orientation.dSecondary * 180.0 /M_PI; 
      }
      __DBGpr_dbl( " Components rotation angle (deg) ", p_rs->var.root_pm_st.value );
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
  /* added to find the comp_angle in an alternative way. Alwin for TR179900960*/
  /* The users requested the coordinates of a point on the wheel spindle axis*/
  else if( !strcmp( footname, "dp_comp_angle_pos" ) )
  {
     IGRint     cpt_no=0;
     IGRlong    lngmsg;
     IGRdouble  dCoordCpt0[3], dCoordCenterPt[3];
     IGRdouble  pt_on_wheel[3], distance=1.0;
     IGRmatrix  ref_matrix;
     IGRvector  Y_axis, Y_unitvec;

     /* Get the Cpt0 Coordinates */
     status =
     om$send( msg = message VRGeneric.VRGetCptGeom( &retmsg,
                    (IGRshort)cpt_no, dCoordCpt0,
                    NULL, NULL, md_env ),
            targetid = my_id );
     as$status ( action = RET_STATUS );
     __DBGpr_vec(" Coord ", dCoordCpt0 );

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

     distance = BSdistptpt( &lngmsg, dCoordCenterPt, dCoordCpt0 );
     __DBGpr_dbl( " Distance btwn Cpt0 and Center ", distance );

	 /* This is because the 'distance' would turn out to be zero for FLANGES,
	 the end result would end up returning 0, 0, 0. This constant is purely
	 arbitrarily, this is just enough to show them its on the Y-axis and in the
	 near vicinity, so its easy for them to verify. Alwin */
	 if( distance < 10.0 ) distance = 25.0; 

     Y_axis[0] = ref_matrix[1];
     Y_axis[1] = ref_matrix[5];
     Y_axis[2] = ref_matrix[9];
     MAunitvc( &lngmsg, Y_axis, Y_unitvec );

     pt_on_wheel[0] = dCoordCenterPt[0] + Y_unitvec[0]*distance;
     pt_on_wheel[1] = dCoordCenterPt[1] + Y_unitvec[1]*distance;
     pt_on_wheel[2] = dCoordCenterPt[2] + Y_unitvec[2]*distance;
     __DBGpr_vec( " Point on Valve's wheel ", pt_on_wheel );

     p_rs->type = text_type;
     p_rs->var.text_st.text_string[0] = '\0';
     sprintf( p_rs->var.text_st.text_string, "%f,%f,%f",
                pt_on_wheel[0], pt_on_wheel[1], pt_on_wheel[2] );
  }
  /* added to find the comp_angle in an alternative way. Alwin for TR179900960*/
  /****** law- Add ref point return for Dynapipe ********/
  else if( !strcmp( footname, "dp_comp_ref_pnt" ))
  {
     IGRlong lngmsg;
     struct GRid RefOutID;
     struct GRmd_env FtMdEnv;

     p_rs->type = text_type;
     p_rs->var.text_st.text_string[0] = '\0';


     FtMdEnv = *md_env;
     RefOutID.objid = NULL_OBJID;
     status= om$send( msg = message NDmacro.ACreturn_foot( &lngmsg,
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
	LineIn.num_points = 1;
	status = om$send( msg      = message GRlinear.GRgetpolyline( &lngmsg,
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
	 /* If the macro does not have "ref_out1" as its feet, simply
	  * get its own matrix.		- Anand for JTS TR 4214 */
     {
	IGRmatrix ref_matrix;

	status = om$send( msg      = message VRGeneric.VRGetMatrix
                                          ( &lngmsg, 0, NULL, ref_matrix,
                                            md_env ),
                          targetid = my_id );
	as$status( action = RET_STATUS );

	sprintf( p_rs->var.text_st.text_string, "%f,%f,%f",
                               ref_matrix[3], ref_matrix[7], ref_matrix[11] );
     }

  }
  /* Dynapipe attribute extraction over. Alwin */
  else {

	/*A Try generic feet management */
	status=
	om$send (msg = message VRGeneric.ACgive_structure 
			(msg, direct_index, footname, p_rs, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	__DBGpr_int(" VRGeneric_status msg ", *msg );
	__DBGpr_int(" VRGeneric_status status ", status );

  }/* end try OM_e_wrt_message */

  wrapup:
	_FREE( pObjects );
	pObjects = NULL ;

	End
	return ( status );

}/* end ACgive_structure */

/***********************************************************************/

method VRGetPlanesOnCpt ( IGRlong *msg ; IGRshort nCpNum; struct GRid *PlaneIds;
			struct GRmd_env *md_env)
{
	IGRlong		retmsg;
	IGRint 		status;
	struct GRid 	SegId;
	IGRshort	nMyIndex;
	IGRint		NbSegs;

        SetProc( VRComponent_VRGetPlanesOnCpt ); Begin

	/*"---- %s ----\n",me->szAABBCC */

	/* -- Initialize returned values -- */

	*msg = MSFAIL;

	PlaneIds[0].objid = PlaneIds[1].objid = PlaneIds[2].objid = NULL_OBJID;

	/*| Get planes from topologic templates */

	/* -- Get one segment -- */
	status = 
	om$send( msg	 = message VRGeneric.VRGetSupports
			(&retmsg, 1, &SegId, &NbSegs),
		targetid = my_id);
	as$status ( action = RET_STATUS );
	if ( NbSegs < 1 ) 
        {
           End
           return OM_S_SUCCESS; /* no topological templates ??? */
        }

	/*" Segment : <%d,%d>\n", SegId.objid, SegId.osnum */

	/* -- Get my index on the support -- */

	status = 
	om$send( msg	 = message VRGeneric.VRGetIndex
			(&retmsg, &SegId, &nMyIndex),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/*" Position %d on this segment\n",nMyIndex */

	/* -- Return its planes -- */

	/* 0 ==> common plane
	/* 1 ==> ortho plane
	/* 2 ==> end plane
	/**/

	status =
	om$send ( msg = message VRCnrlSeg.VRget_planes
			( &retmsg, &PlaneIds[0], &PlaneIds[1],
			(nMyIndex)? NULL : &PlaneIds[2],
			(nMyIndex)? &PlaneIds[2] : NULL),
		targetid = SegId.objid,
		targetos = SegId.osnum );
	as$status ( action = RET_STATUS );

*msg = MSSUCC;

End
return OM_S_SUCCESS;

}/* end VRGetPlanesOnCpt */

/***********************************************************************/

method ACcheckin_candidate ( IGRint CheckinType; IGRint *p_CheckinCandidate )

{
	IGRint status;
        SetProc( VRComponent_ACcheckin_candidate ); Begin

	if ( me->Status & VR_BUILT_IN )
	{
		/* Built In components are not real components */
		*p_CheckinCandidate = FALSE;
		status = OM_S_SUCCESS;
	}
	else
	{
		status=
		om$send ( msg = message ACdb_info.ACcheckin_candidate
					(CheckinType, p_CheckinCandidate),
			mode     = OM_e_wrt_message,
			targetid = my_id);

	}

        End
	return status;

}/* end ACcheckin_candidate */


/***********************************************************************/


method NDdelete(struct GRmd_env *md_env)
{
	IGRint			status=OM_S_SUCCESS;

        SetProc( VRComponent_NDdelete ); Begin

	/* If it is a real delete, notify roots for disconnectection */
   	if(!IF_NULL_OBJID(md_env->md_id.objid))
	{
		IGRlong			retmsg;
		OM_p_CHANSELECT		to_father,to_children;
		struct	GRid		my_grid;

		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

		status = 
		NDget_channel( &to_father, &to_children );
		as$status(action = RET_STATUS);
		
		/*A notify the correction that i am going to be deleted */
		status = 
		om$send(msg = message VRCorrection.VRNotifyDelete(
			&retmsg, 1, &my_grid ),
			p_chanselect = to_children );
	}

	/*A execute the NDdelete of my parent's message	*/
    	status = 
	om$send(msg = message VRGeneric.NDdelete(
				md_env),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
	
	as$status(action = RET_STATUS);
    
        End
	return(status);

}/* end NDdelete */


/* ****************************** NOTICE *********************************** */
/*  override of AC_give_db_structure to adjust correction components         */
/*  matrix to COG coordinates for post   Re:   TR # 179527758                */
/*  **************************** DANGEROUS ********************************* */

method ACgive_db_structure (int         *msg;
                            int         *direct_index;
                            char        *footname;
                     struct ret_struct  *p_rs;
                     struct GRmd_env    *md_env)

{
  IGRint  status;
  SetProc( VRComponent_ACgive_db_structure ); Begin

  /*   do parent first    */

  status=
  om$send (msg = message VRGeneric.ACgive_db_structure
                        (msg, direct_index, footname, p_rs, md_env),
          mode = OM_e_wrt_message,
      targetid = my_id);
  as$status ();

  /*   for the referential matrix of a correction component   */

  if ((strcmp (footname, VR_N_REF_CS) == 0) &&
      ( me->Status & VR_CORRECTION ))
  {
    OM_S_CHANSELECT  chansel;
    struct GRid      MyId;
    IGRlong          retmsg;
    IGRdouble        ddCoord[6];

    /* -- Get endcoordinates from Correction entity -- */

    MyId.objid         = my_id;
    MyId.osnum         = OM_Gw_current_OS;
    chansel.type       = OM_e_name;
    chansel.u_sel.name = "to_owners";

    status =
    om$send (msg = message VRCorrection.VRGetPipeCpts
                                      (&retmsg, md_env, ddCoord),
      p_chanselect= &chansel,
      from        = 0,
      to          = 0);
    as$status ();

    p_rs->var.ref_st.t[3]  = (ddCoord[0] + ddCoord[3]) / 2.0;
    p_rs->var.ref_st.t[7]  = (ddCoord[1] + ddCoord[4]) / 2.0;
    p_rs->var.ref_st.t[11] = (ddCoord[2] + ddCoord[5]) / 2.0;
  }

  End
  return (status);
}

end implementation VRComponent;
