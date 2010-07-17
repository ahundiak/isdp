/* $Id: VRNozzMod.I,v 1.3 2001/11/08 03:44:30 anand Exp $ */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrnozzle/VRNozzMod.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRNozzMod.I,v $
 *  Revision 1.3  2001/11/08 03:44:30  anand
 *  JTS TR MP 5557
 *
 *  Revision 1.2  2001/01/11 16:10:14  anand
 *  SP Merge
 *
# Revision 1.1  2000/07/10  19:05:34  pinnacle
# Created: route/vrnozzle/VRNozzMod.I by apazhani for Service Pack
#
 *
 * History:
 * 07/10/00     Alwin           Set DB information for Raceway Nozzle.
 * 11/07/01	Anand		JTS TR MP5557
 *
 *************************************************************************/

class implementation VRNozzle;

#include "VDScheckdef.h"
#include "ACcheckin.h"
#include "ACdb_info.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "VRcsdef.h"
#include "VRPid.h"

#include "VDchn.h"
#include "vrdbgmacros.h"

from	VRCnrlSeg	import	VRchg_state;

extern	GRclassid	OPP_VRPiping_class_id;
extern	GRclassid	OPP_VRHvac_class_id;

#define AS_DEBUG	1

/**********************************************************************/

method VRSetInstance ( IGRlong	*msg; struct VRGenInfo *Instance )

{

	IGRint	status;

*msg = MSSUCC;

	/* -- Init super class instance -- */
	status =
	om$send ( msg = message VRGeneric.VRSetInstance
			(msg, Instance),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	as$status ();

	/* -- Set status for checkin -- */

	{
		IGRlong			retmsg;
		struct ACdb_info	DbInfo;
		GRclassid		MyClassId;

		om$get_classid (objid = my_id,
				osnum = OM_Gw_current_OS,
				p_classid = &MyClassId );

		if ( om$is_ancestry_valid
				( subclassid   = MyClassId,
				  superclassid = OPP_VRPiping_class_id )
		     == OM_S_SUCCESS )
		{
			/*| -- PIPING object -- */
			if ( bVR_IS_PID(me->xform_chan) )
				DbInfo.quantity = PID_PIPENOZ_OBJ;
			else	DbInfo.quantity = PIPE_NOZZ_OBJ;
		}
		else if ( om$is_ancestry_valid
				( subclassid   = MyClassId,
				  superclassid = OPP_VRHvac_class_id ) 
		     == OM_S_SUCCESS )
		{
			/*| -- HVAC object -- */
			if ( bVR_IS_PID(me->xform_chan) )
				DbInfo.quantity = SCH_HVNOZ_OBJ;
			else	DbInfo.quantity = HVAC_NOZZ_OBJ;
		}
		else 
		{
			// Raceways don't have PID nozzle. CABLE Terminals are
			// used instead. Alwin CR179901003
			DbInfo.quantity = VD_CKIN_RWAY_NOZZ_OBJ;
		}

		status = om$send(msg = message ACdb_info.ACset_db_info
						( &retmsg, &DbInfo),
			targetid = my_id);
		as$status();


	}

	me->nIndex[0] = 0;
	me->nNbTopo   = 0;

	me->dSecAngle = Instance->Attr.Nozz.dSecAngle;

return ( OM_S_SUCCESS );

}/* end VRSetInstance */

/**********************************************************************/

method VRConnect(IGRlong 		*msg;
		  struct GRid		*SegId;
		  IGRshort		nIndex;
		  IGRshort		nCptNum;
		  struct GRmd_env	*md_env  )
{

	IGRint		status;
	OM_p_CHANSELECT	ToFather,ToChildren;
	struct GRid	MyId;

*msg 	= MSFAIL;
status 	= OM_E_ABORT;

if ( me->nNbTopo < me->nNbCpts )
{
	/* ------------------------------- */
	/* -- Connect via assoc channel -- */
	/* ------------------------------- */

	status = NDget_channel( &ToFather, &ToChildren );
	as$status(action = RET_STATUS);

	status =
	om$send( msg = message Root.connect
				(*ToFather,OM_K_MAXINT,SegId->objid,SegId->osnum,
				 *ToChildren, OM_K_MAXINT ),
		targetid = my_id);
	as$status(action = RET_STATUS);

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

	om$send( msg = message NDnode.NDnotify_connect
				( MyId ),
		targetid = SegId->objid,
		targetos = SegId->osnum );

	/* ---------------------- */
	/* -- Update instances -- */
	/* ---------------------- */

	*msg		 = MSSUCC;
	me->nIndex[0]	 = nIndex;
	me->nNbTopo 	+= 1;
	status		 = OM_S_SUCCESS;

}/* end connection proceeded */

return ( status );

}/* end VRConnect */

/**********************************************************************/

method VRDisconnect(	IGRlong 		*msg;
			struct GRid		*SegId;
			struct GRmd_env	*md_env  )
{
	IGRint			i, NbChilds, status, NbCor=0;
	GRclassid		obj_classid;
	struct		GRid	*buffer, RefId, MyId, CorId;

	extern GRclassid 	OPP_VRDepPlane_class_id;

	*msg 	= MSFAIL;

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

	/*A to make the connection we created some dependent planes
	   depending upon the component referential. At the time of 
	   disconnection delete these dependent planes */

	/*A get the nozzle referential */
	status = om$send( msg      = message VRNozzle.VRGetRefId
				     			( msg, &RefId ),
			  targetid = my_id );
	as$status();

	/*A get the dependent planes */
	status = om$send( msg      = message NDnode.NDget_objects
				     ( ND_CHILDREN | ND_IN_BUF, NULL, 0,
				       &buffer, 0, OM_K_MAXINT, &NbChilds ),
			  targetid = RefId.objid,
			  targetos = RefId.osnum );
	as$status();

	/*A delete the dependent planes */
	for(i=0; i<NbChilds; i++)
	{
		/*"buffer[%d] = %d\n", i, buffer[i].objid */

 		om$get_classid( objid     = buffer[i].objid,
		  		osnum     = buffer[i].osnum,
                    		p_classid = &obj_classid );

 		if(om$is_ancestry_valid( subclassid   = obj_classid,
		   superclassid = OPP_VRDepPlane_class_id) == OM_S_SUCCESS)
		{
			/*C it's a VRDepPlane */
  			nd$wait_batch( 	type       = GR_DELETED,
                 			l_object   = &buffer[i],
                 			nb_obj     = 1 );
		}
	}

	/*A disconnect the parent segment from me */
	status = om$send( msg      = message NDnode.NDdisconnect( 1, SegId ),
		 	  targetid = my_id);
	as$status(action = RET_STATUS);

	/*A get the corrections connected to me */
	status = om$send( msg      = message VRGeneric.VRGetCorrections
					           ( msg, 1, &CorId, &NbCor ),
		          targetid = my_id );
	as$status(action = RET_STATUS);

	/*C check for the Nb of Corrections : Manyam */

	/*A disconnect the corrections if there are any */
	if ( NbCor )
	{
		status = om$send( msg      = message 
				NDnode.NDdisconnect( 1, &MyId ),
			targetid = CorId.objid,
			targetos = CorId.osnum );
		as$status(action = RET_STATUS);
	}

	/*A Update instances */
	me->nNbTopo 	-= 1;

	*msg = MSSUCC;
	return ( OM_S_SUCCESS );

}/* end VRConnect */

/***********************************************************************/

method VRChgSupport ( IGRlong *msg ; IGRdouble MyNewOrient;
                      IGRshort MyNewIndex; struct GRid *OldSupportId;
                      struct GRid *NewSupportId )
{
	IGRint 			status;
	IGRuint			TempIndex;
	IGRint			i, NbDepPln=0;
	struct GRid		RefId, DepPlaneIds[3];
	OM_S_CHANSELECT		NDfather_channel, NDchild_channel;
	extern GRclassid	OPP_VRDepPlane_class_id;
	extern struct GRid	NULL_GRID;
	struct GRmd_env		CurMdEnv;

	SetProc(VRChgSupport); Begin

	__DBGpr_me();
	__DBGpr_obj(" Old CSeg", *OldSupportId );
	__DBGpr_obj(" New CSeg", *NewSupportId );

	status = om$make_chanselect(channame     ="NDfather.father",
				    p_chanselect = &NDfather_channel );
	as$status(action = RET_STATUS);

	status = om$make_chanselect(channame     ="NDchildren.children",
				    p_chanselect = &NDchild_channel );
	as$status(action = RET_STATUS);

	status = om$send( mode     = OM_e_wrt_message,
       			  msg      = message NDnodein.NDchange_connect
                                     ( 1, OldSupportId, NewSupportId ),
	                  targetid = my_id );
	as$status( action = RET_STATUS );

	/* -- get specified template index -- */

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &NDfather_channel,
			objid		= NewSupportId->objid,
			indexaddr	= &TempIndex  );
	as$status ( action = RET_STATUS );

        __DBGpr_int("Index of New seg on my father's channel", TempIndex );

	/* -- Compute segment index -- */

	TempIndex = TempIndex - me->nNbAttr - 1 ;
        /*" This is my %dth segment\n", TempIndex */

	/* -- Update my array of position on my segments -- */

	me->nIndex[TempIndex] = MyNewIndex;
        __DBGpr_int("Index of Seg among my templates", TempIndex);
	__DBGpr_int("My position on the new segment", me->nIndex[TempIndex]);

	/* Below lines added by Anand for JTS TR MP5557 */
	status = om$send( msg	   = message VRNozzle.VRGetRefId( msg,
								  &RefId ),
			  targetid = my_id );
	__DBGpr_obj(" Coord Sys Ref ID of Nozzle", RefId);

	status = vdchn$GetList( objID	= &RefId,
				chnIDx	= VDCHN_IDX_CHILDREN,
				maxCnt	= 3,
				cnt	= &NbDepPln,
				outIDs	= DepPlaneIds,
				FltrClsId	= OPP_VRDepPlane_class_id );
	__DBGpr_objlist(" Dependent planes", NbDepPln, DepPlaneIds );

	/* NDdisconnect for VRDepPlanes has been overridden, and this also
	 * deletes the DepPlanes! So use Root.disconnect instead. */
	__DBGpr_objlist("Disconnecting Dep Plane from me", 3, DepPlaneIds);
	for( i=0 ; i<3 ; i++ )
	{
	    status = om$send( msg      = message Root.disconnect(
							  NDfather_channel,
							  DepPlaneIds[i].objid,
							  DepPlaneIds[i].osnum,
							  NDchild_channel
								),
			      senderid = NULL_OBJID,
			      targetid = OldSupportId->objid,
			      targetos = OldSupportId->osnum );
	    as$status( action = RET_STATUS );
	}
	__DBGpr_objlist("Disconnected Dep Plane from me", 3, DepPlaneIds);

	status = om$send( msg = message NDnode.NDconnect( 3, DepPlaneIds,
							  NULL_GRID, ND_ADD ),
			  senderid = NULL_OBJID,
			  targetid = NewSupportId->objid,
			  targetos = NewSupportId->osnum );
	as$status( action = RET_STATUS );

	/* The control segment will always be in design file (for VRChgSupport
	 * to be called). So it is okay go get the Module environment for the
	 * design file (although the nozzle might be in reference file). */
	gr$get_module_env( msg = msg,
			   sizbuf = sizeof(struct GRmd_env),
			   buffer = &CurMdEnv );

	status = om$send( msg = message NDnode.NDs_compute_node( msg, 0,
								 &CurMdEnv ),
			  targetid = NewSupportId->objid,
			  targetos = NewSupportId->osnum );
	/* Above lines added by Anand for JTS TR MP5557 */

	End
	return ( OM_S_SUCCESS );
}/* end VRChgSupport */

/***********************************************************************/

method VRSetSoftConnection ( IGRlong *msg )
{
  IGRlong	status;
  IGRint	NbSup, i;
  struct  GRid	SupIds[VR_MAX_CPTS];

  status =
  om$send( msg	    = message VRGeneric.VRGetSupports(	msg, VR_MAX_CPTS, 
							SupIds, &NbSup),
	   targetid = my_id );
  as$status( action = RET_STATUS );

  for (i=0; i<NbSup; i=i+1)
  {
	status =
	om$send( msg = message VRCnrlSeg.VRchg_state(	VR_MAINTAIN_CONNECT,
							~VR_MAINTAIN_CONNECT),
		 targetid = SupIds[i].objid,
		 targetos = SupIds[i].osnum);
	as$status( action = RET_STATUS );
  }

  return ( OM_S_SUCCESS );

}/* end VRSetSoftConnection  */
/***********************************************************************/

end implementation VRNozzle;
