/* $Id: VRcompute.I,v 1.5 2002/05/03 13:51:20 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrgeneric / VRcompute.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcompute.I,v $
 *	Revision 1.5  2002/05/03 13:51:20  louis
 *	TR5959 pload cleanup for symbolization
 *	
 *	Revision 1.3  2001/02/20 01:14:13  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 20:44:24  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  23:18:40  pinnacle
# Created: route/vrgeneric/VRcompute.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/07/17  19:09:38  pinnacle
# Replaced: vrgeneric/VRcompute.I for:  by r250_int for route
#
# Revision 1.7  1997/07/07  21:49:08  pinnacle
# Replaced: vrgeneric/VRcompute.I for:  by yzhu for route
#
# Revision 1.6  1997/03/05  18:14:18  pinnacle
# Replaced: vrgeneric/VRcompute.I for:  by hverstee for route
#
# Revision 1.5  1997/03/01  06:50:56  pinnacle
# Replaced: vrgeneric/VRcompute.I for:  by apazhani for route
#
# Revision 1.4  1997/02/18  20:11:58  pinnacle
# Replaced: vrgeneric/VRcompute.I for:  by hverstee for route
#
# Revision 1.3  1996/08/06  17:20:48  pinnacle
# Replaced: vrgeneric/VRcompute.I for:  by r241_int for route
#
# Revision 1.2  1996/07/25  19:38:52  pinnacle
# (No comment)
#
# Revision 1.1  1996/04/24  23:57:24  pinnacle
# Created: vrgeneric/VRcompute.I by msmanem for pmeroute
#
# Revision 1.2  1996/01/17  00:02:04  pinnacle
# Replaced: vrgeneric/VRcompute.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add protoypes
 *	07/07/97	yzhu    use VDsetAttDrSymb function	
 *      05/03/02        law     tr5959 pload cleanup of symbology
 *************************************************************************/
class implementation VRGeneric;

/*
--------------------------------------------------------------------------
*
* NDcompute_node for Generic Occurrence
*
*
---------------------------------------------------------------------------
*/

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "nddef.h"
#include "acrepdef.h"
#include "VDmem.h"
#include "VRmacros.h"
#include "VRPid.h"
#include "vrtools_pto.h"

#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"
#include "vddgndef.h"
#include "v_drw.h"



#define AS_DEBUG 1

extern GRclassid	OPP_ACheader_class_id;
extern GRclassid	OPP_ACconst_class_id;

from 	VRCorrection	import	VRNotifyModif;


method ACchange_feet( IGRint Nbfeet;
                      struct GRid *FeetList;
                      struct GRmd_env *md_env )
{
    struct GRid MyId;
    IGRint status;

    SetProc( VRGeneric_ACchange_feet ); Begin
    /* call ACchange_feet of super class */
    status =
      om$send( msg = message ACncpx.ACchange_feet(Nbfeet, FeetList, md_env ),
          mode     = OM_e_wrt_message,
          targetid = my_id );

    /* -- set symbology -- */
    MyId.objid = my_id;
    MyId.osnum = OM_Gw_current_OS;
    VRsetsymb( md_env, MyId );

End
return OM_S_SUCCESS;

}/* end of ACchange_feet */

/* oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo */
method VRNotifyCorrections( IGRlong *msg;IGRint NotifyFlag )
{
	/* ---------------------------- */
	/* -- Notify all corrections -- */
	/* ---------------------------- */

	IGRint		NbCorrections=0,status;
	IGRint		i;
	IGRlong		retmsg;

	struct GRid    *CorIds;

        SetProc( VRGeneric_VRNotifyCorrections ); Begin
	*msg = MSSUCC;

	status =
	om$send( msg = message VRGeneric.VRGetCorrections
		( &retmsg, 0, NULL, &NbCorrections ),
		targetid = my_id);

        NbCorrections++;
        CorIds = _MALLOC (NbCorrections, struct GRid);

	status =
	om$send( msg = message VRGeneric.VRGetCorrections
		( &retmsg, NbCorrections, CorIds, &NbCorrections ),
		targetid = my_id);
	as$status(action = RET_STATUS);

	for (i=0;i<NbCorrections; i++)
	{
		status =
		om$send( msg = message VRCorrection.VRNotifyModif
				( &retmsg ),
			targetid = CorIds[i].objid,
			targetos = CorIds[i].osnum);
		as$status(action = RET_STATUS);
	}/* end loop on corrections */

        _FREE (CorIds);

End
return OM_S_SUCCESS;

}/* end of VRNotifyCorrections */

/* oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo */

method NDupdate(int *msg, cn_type, count;
		   struct GRid *parents;
		   int * parent_state;
		   struct GRid *context,*new_objid;
		   struct GRmd_env *md_env)
{

	IGRint	status,i;
	IGRlong	retmsg;
	SetProc (VRGeneric.NDupdate ); Begin

	status = 
	om$send (msg = message VRGeneric.VRSetStatus
			(&retmsg,(IGRshort)(VR_XFORM_ONLY) ,
			     (IGRshort)(~VR_XFORM_ONLY)),
	targetid = my_id);

	/* -- Check whether parents attributes have changed -- */

	for (i=0; i<me->nNbAttr && !bVR_IS_PID(me->xform_chan) ; i++)
	{
		if (parent_state[i] != ND_COMP_SAME )
		{
			/* -- Attr have changed => notify corrections -- */
			status =
			om$send (msg = message VRGeneric.VRNotifyCorrections 
				( &retmsg, 0 ),
				targetid = my_id );

			status = 
			om$send (msg = message VRGeneric.VRSetStatus
					( &retmsg,(IGRshort)(VR_XFORM_ONLY) ,
					     (IGRshort)(VR_XFORM_ONLY)),
			targetid = my_id);
		
			break;
		}

	}/* end loop on parent_state */

	/* -- Go back to normal process -- */

	status =
	om$send (msg = message VDSroot.NDupdate 
			( msg, cn_type, count, parents, parent_state,
			  context, new_objid, md_env ),
		targetid = my_id,
		mode     = OM_e_wrt_message );

	End
	return status;

}/* end of NDupdate */

/* oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo */

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *fcount; struct GRid  *feet_list)
{
	IGRlong			retmsg;
	IGRint			status,cnt_pts;
	extern IGRboolean 	dynamics_in_progress;
	IGRshort		nType;
	IGRchar			AcRep, szMacroName[80];
	struct GRid		TempList[2], hdr;
	struct GRsymbology      Symbology;
        struct GRid             collId; /* for symbology collector */
        VD_drwOutputData        *output = NULL;

        SetProc ( ACconstruct_feet -- VRcompute.I ); Begin

	/*" ---- %s ----\n",me->szAABBCC */

	*msg = MSSUCC;

	/* One graphic will be built */
	*fcount	=1;
/*^
	if ( me->Status & VR_XFORM_ONLY )
	{
		printf ("<%s> : GEOM COMPUTE\n", me->szAABBCC );
	}
	else
	{
		printf ("<%s> : FULL COMPUTE\n", me->szAABBCC );
	}
*/
	/* -- Check whether I am a clone for dynamics or not -- */
	if ( me->Status & VR_CLONE )
	{
		if (  dynamics_in_progress )
		{
			/*| TEMPORARY CLONE*/
			status = 
			om$send (msg = message VRGeneric.VRSetStatus
				(&retmsg,(IGRshort)(VR_DUMB_DEL) ,
					 (IGRshort)(VR_DUMB_DEL)),
			targetid = my_id);
			as$status ();
		}
		/* -- reset clone status -- */
		status = 
		om$send (msg = message VRGeneric.VRSetStatus
			(&retmsg,(IGRshort)(VR_CLONE ) ,
				 (IGRshort)(!VR_CLONE)),
		targetid = my_id);
		as$status ();
	}

	if ( me->Status & VR_ERROR )
	{
		/* -- reset error status -- */
		status = 
		om$send (msg = message VRGeneric.VRSetStatus
			(&retmsg,(IGRshort)(VR_ERROR ) ,
				 (IGRshort)(!VR_ERROR)),
		targetid = my_id);
		as$status ();
	}

	/* ---------------------------------- */
	/* -- Get graphics characteristics -- */
	/* ---------------------------------- */

	TempList[0].objid = my_id;
	TempList[0].osnum = OM_Gw_current_OS;

	feet_list[0].osnum = OM_Gw_current_OS;

	status = 
	om$send ( msg = message VRGeneric.VRGetMacro
			( &retmsg,
			szMacroName,
			&AcRep,
			&nType,
			&TempList[1],
			(IGRint *)NULL,
			(IGRchar ***) NULL,
			(struct ret_struct **)NULL,
			md_env ),
		targetid = my_id);
	if ( !(retmsg&1) || !(status&1) ) goto VR_BUILD_ERROR;


	/* -------------------- */
	/* -- Build Graphics -- */
	/* -------------------- */

	/* -- Select macro class based on component type -- */
	if ( nType == 1 )
	{
		/*| Place pipe as a macro */

	 	status =
		om$construct( 	classid = OPP_ACconst_class_id,
				p_objid = &feet_list[0].objid, 
				osnum 	= feet_list[0].osnum );
	}
	else
	{
		/*| Place component as a symbol */

	 	status =
		om$construct( 	classid = OPP_ACheader_class_id,
				p_objid = &feet_list[0].objid, 
				osnum 	= feet_list[0].osnum );
	}
	if ( !(status & 1) )
	{
		/*| ERROR -> ACheader no created */
		goto VR_BUILD_ERROR;
	}

	/* -- Adjust instances size if needed -- */

	status =VRnum_cpts(szMacroName, &cnt_pts);
	if ( !(status & 1) )
	{
		printf(" -----> Macro : %s not found\n",szMacroName);
		goto VR_DEL_AND_BUILD_ERROR;
	}

	me->nNbCpts = cnt_pts;


	status=
	om$send ( msg = message ACncpx.ACmplace ( 
			(IGRint *)&retmsg,
			AChdr_noprotect|AChdr_nodisplay,
			AcRep,
			szMacroName,
			(TempList[1].objid == NULL_OBJID) ? 1 : 2,
			TempList,
			md_env),
		targetid = feet_list[0].objid,
		targetos = feet_list[0].osnum);
	if ( !(retmsg&1) || !(status&1) )
	 {
		/*| ERROR -> NO GRAPHIC BUILT */
		printf(" -----> Macro : %s Cannot be placed\n",szMacroName);
		goto VR_DEL_AND_BUILD_ERROR;
	 }

	status=
	om$send ( msg = message NDnode.NDmove_to_root ( 
			&retmsg,&feet_list[0],md_env),
		targetid = feet_list[0].objid,
		targetos = feet_list[0].osnum);
	as$status ( action = RET_STATUS );
        __DBGpr_int("Justification",(int) me->nJustif);
	if ( me->nJustif != VR_CENTER_JUST )
	{
		IGRdouble	dRefMatrix[16];
		IGRshort	nTmpType;

		/* Get orientation matrix from graphics */
		status =
		om$send ( msg = message GRowner.GRget_matrix ( msg,
				        &md_env->md_env.matrix_type,
				        md_env->md_env.matrix,
				        &nTmpType,
				        dRefMatrix ),
			targetid = feet_list[0].objid,
			targetos = feet_list[0].osnum );
		as$status(action = RET_STATUS);
                __DBGpr_obj("feet_list0",feet_list[0]);
                __DBGpr_mat("dRefMatrix",dRefMatrix);
		/*| Reajust graphics based on justification */

		/*" X = %f, %f, %f\n",dRefMatrix[0],dRefMatrix[4],dRefMatrix[8] */
		/*" Y = %f, %f, %f\n",dRefMatrix[1],dRefMatrix[5],dRefMatrix[9] */

		status =
		VR$OrientComp(	p_retmsg 	= &retmsg,
				p_CmpId 	= &feet_list[0],
				Justif 		= me->nJustif,
				Matrix 		= dRefMatrix,
				Angle 		= 0.0,
				p_MdEnv 	= md_env);
		as$status();

	} /* end justification treatment */

        /* TR5959 cleanup-delete symbolgy in construct_feet */
End
return OM_S_SUCCESS;

	/* ------------------------------ */
	/* -- ERROR Graphics treatment -- */
	/* ------------------------------ */

VR_DEL_AND_BUILD_ERROR:

	/*| An ERROR occurse after having placed the macro occurrence*/
	/* -- Delete the macro occurrence before placing the error graphics */

	status=
	om$send ( msg = message NDnode.NDdelete ( md_env ),
		targetid = feet_list[0].objid,
		targetos = feet_list[0].osnum);
	as$status ( );

VR_BUILD_ERROR:
{
	/*| Get Error graphic */

	/* -- Set status to VR_ERROR -- */
	status = 
	om$send ( msg = message VRGeneric.VRSetStatus
				( &retmsg, VR_ERROR, VR_ERROR ),
		targetid = my_id);
	as$status ();

	/* -- Set Dynamicaly Connect points coordinates -- */

	me->nNbCpts = me->nNbTopo;


	/* -- Build error graphics -- */
	status = 
	om$send ( msg = message VRGeneric.VRGetErrGraphic
				( &retmsg, NULL, feet_list,
				md_env ),
		targetid = my_id);
	as$status ( action = RET_STATUS );

}/* end build error graphic */


	/*" Error graphic id = %d, %d\n",feet_list[0].objid, feet_list[0].osnum */

End
return ( OM_S_SUCCESS );

}/* end of ACconstruct_feet */

end implementation VRGeneric;
