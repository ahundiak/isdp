/* $Id: VRCompMod.I,v 1.5 2002/05/28 19:17:48 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcomponent / VRCompMod.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCompMod.I,v $
 *	Revision 1.5  2002/05/28 19:17:48  louis
 *	TR5888-component flipping on replace
 *	
 *	Revision 1.4  2001/03/08 23:37:54  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.3  2001/02/20 01:12:41  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 15:37:59  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  17:25:34  pinnacle
# Created: route/vrcomponent/VRCompMod.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/18  19:56:06  pinnacle
# Replaced: vrcomponent/VRCompMod.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/06/06  17:38:22  pinnacle
# Replaced: vrcomponent/VRCompMod.I for:  by hverstee for route240
#
# Revision 1.4  1996/05/29  18:39:30  pinnacle
# Replaced: vrcomponent/VRCompMod.I for:  by ashankar for route240
#
# Revision 1.3  1996/04/25  22:22:22  pinnacle
# Replaced: vrcomponent/VRCompMod.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/16  21:47:18  pinnacle
# Replaced: vrcomponent/VRCompMod.I for:  by r240_int for route240
#
 *
 * History:
	09-DEC-91	Bruno	1.4.3.14	
				- VRInitInstances method has been removed.
				- VRSetInstances now does the ACset_db_info 
									method.
 *	01/16/96  	tlb	Add prototypes
 *      03/08/01   law          dbg prints
 *      05/28/02        law     TR5888 - minor modifications related to
 *                              primary/secondary segment processing
 *************************************************************************/

class implementation VRComponent;

#include <math.h>

#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACcheckin.h"
#include "VDScheckdef.h"
#include "ACdb_info.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "VRMath.h"
#include "bserr.h"
#include "bs_values.h"
#include "acrepdef.h"
#include "VRPid.h"
#include "vrdbgmacros.h"

extern	GRclassid	OPP_VRPiping_class_id;
extern	GRclassid	OPP_VRHvac_class_id;

#define AS_DEBUG	1
extern IGRdouble VRcompute_angle();

from	VRCnrlSeg	import	VRGetTopo;

/***********************************************************************/

method VRSetInstance ( IGRlong	*msg; struct VRGenInfo *Instance )

{
  IGRshort    i,ii;
  IGRint      status;
  IGRlong     retmsg;

  SetProc( VRComponent_VRSetInstance ); Begin
  *msg = MSSUCC;

  /*"---- %s ----\n",me->szAABBCC */

  /* -- Init super class instance -- */
  status =
  om$send ( msg = message VRGeneric.VRSetInstance (msg, Instance),
       mode     = OM_e_wrt_message,
       targetid = my_id );

  /*" newAABBCC = %s\n",me->szAABBCC */
  /*" newItem   = %d\n", Instance->Attr.Comp.Desc.nItemNum*/

  /* -- Store component index on segments -- */
  for ( i=0; i<me->nNbTopo; i++ ) 
  {
    ii = Instance->Attr.Comp.nIndex[i];

    status =
    om$send (msg = message VRComponent.VRSetMEIX (&retmsg, i, ii),
        targetid = my_id);
  }

  /* -- Store component description -- */
  me->Desc  = Instance->Attr.Comp.Desc;

  /* -- Store component orientation -- */
  me->Orientation = Instance->Attr.Comp.Orientation;

  /* -- Set status for checkin -- */

  {
    struct ACdb_info  DbInfo;
    GRclassid    MyClassId;

    om$get_classid (objid = my_id,
                    osnum = OM_Gw_current_OS,
                p_classid = &MyClassId );

    if ( om$is_ancestry_valid
        ( subclassid   = MyClassId,
          superclassid = OPP_VRPiping_class_id )
                                                       == OM_S_SUCCESS )
    {
      /*| -- PIPING object -- */
      if ( bVR_IS_PID(me->xform_chan)  )
        DbInfo.quantity = PID_PIPING_OBJ;
      else
        DbInfo.quantity = PIPING_OBJ;
    }
    else
    if ( om$is_ancestry_valid
        ( subclassid   = MyClassId,
          superclassid = OPP_VRHvac_class_id )
                                                        == OM_S_SUCCESS )
    {
      /*| -- HVAC object -- */
      if ( bVR_IS_PID(me->xform_chan)  )
        DbInfo.quantity = SCH_HVAC_OBJ;
      else
        DbInfo.quantity = HVAC_OBJ;
    }
    else
    {
      /*| -- RWAY object -- */
      DbInfo.quantity = RWAY_OBJ;
    }
    status = om$send(msg = message ACdb_info.ACset_db_info  ( &retmsg, &DbInfo),
                targetid = my_id);
    as$status();

  }/* end set db_info */

  if ( Instance->Attr.Comp.Desc.nItemNum == VR_DANGLING )
  {
    /* ---------------------------------------- */
    /* -- If dangling : override orientation -- */
    /* ---------------------------------------- */
    /*| Set DANGLING instances */

    /* -- Set status to BUILT_IN component -- */

    status =
    om$send ( msg = message VRGeneric.VRSetStatus 
                               (msg,   (IGRshort)VR_BUILT_IN | VR_SYSTEM,
                                       (IGRshort)VR_BUILT_IN | VR_SYSTEM),
         targetid = my_id );

    /* -- set dangling's orientation -- */

    i = me->Orientation.nPriIndex-me->nNbAttr;

    status =
    om$send (msg = message VRComponent.VRGetMEIX (&retmsg, i, &ii),
        targetid = my_id);

    if ( ii)
      me->Orientation.dPrimary = 1.0;
    else
      me->Orientation.dPrimary =-1.0;

    me->Orientation.nSecIndex =  -1;

    me->nJustif = VR_CENTER_JUST;
  }/* end dangling special orientation treatment */

  End
  return ( OM_S_SUCCESS );

}/* end VRSetInstance */

/***********************************************************************/

method VRSetCode ( IGRlong *msg; IGRchar *szAABBCC )

{

  IGRint		status;
	IGRlong		retmsg;
	
        SetProc( VRComponent_VRSetCode ); Begin
	*msg = MSSUCC;

		/*"---- %s ----\n",me->szAABBCC */

	status =
	om$send ( msg = message VRGeneric.VRSetCode
			(msg, szAABBCC),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	as$status ( action = RET_STATUS );

	if ( me->Desc.nItemNum != 0 )
	{
		/*| Set status to VR_FORCED */
		status =
		om$send ( msg = message VRGeneric.VRSetStatus 
				(&retmsg, (IGRshort)VR_FORCED,
					  (IGRshort)VR_FORCED),
			targetid = my_id );
		as$status ();

	}
	/*" Component new aabbcc code = %s\n",me->szAABBCC*/

        End
	return ( OM_S_SUCCESS );

}/* end VRSetCode */

/***********************************************************************/

method VRReplace( struct GRas 	*asso_lis;
		struct GRmd_env *md_env;
		IGRchar 	*go_cnst_lis)
{
	IGRint			status;
	OM_p_CHANSELECT		to_father,to_children;
        SetProc( VRComponent_VRReplace ); Begin

		/*"---- %s ----\n",me->szAABBCC */

	/* -- Disconnect all of my templates -- */

	status = NDget_channel( &to_father , &to_children );
	as$status(action = RET_STATUS);

	status =
	om$send( msg = message Root.wild_disconnect (*to_father),
		targetid = my_id);
	as$status(action = RET_STATUS);

	/* -- KLUDGE : reset nbattr and graphicsid . This method should
			not be called ... */

	me->nNbAttr = 0; /* to perform a full reconnection in the NDplace */
	((struct VRGenInfo *) asso_lis->as_attr)->GraphicsId.objid = NULL_OBJID;

	/* -- Call the NDplace message -- */

	status =
	om$send( msg = message VRGeneric.NDplace
			( asso_lis, md_env, go_cnst_lis),
		targetid = my_id);
	as$status(action = RET_STATUS);

	status =
	om$send( msg = message NDnode.NDchange_node
				( md_env ),
		targetid = my_id);
	as$status(action = RET_STATUS);

End
return ( OM_S_SUCCESS );

}/* end VRReplace */


/***********************************************************************/

method VRChgSupport ( IGRlong *msg ; IGRdouble MyNewOrient;
                      IGRshort MyNewIndex; struct GRid *OldSupportId;
                      struct GRid *NewSupportId )
{
	IGRint 			status;
	IGRuint			TempIndex;
	IGRshort 		ii;

        SetProc( VRComponent_VRChgSupport ); Begin
*msg = MSSUCC;

		/*"---- %s ----\n",me->szAABBCC */
        __DBGpr_com("calling NDnodein.NDchange_connect from OldSupportId,NewSupportId");
        __DBGpr_obj("OldSupportId",*OldSupportId);
        __DBGpr_obj("NewSupportId",*NewSupportId);
	status = om$send( mode     = OM_e_wrt_message,
       			  msg      = message NDnodein.NDchange_connect
                                     ( 1, OldSupportId, NewSupportId ),
	                  targetid = my_id );
	as$status( action = RET_STATUS );
        __DBGpr_obj("NewSupportId after NDchange_connect",*NewSupportId);

	/* -- get specified template index -- */

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &ND_father,
			objid		= NewSupportId->objid,
			indexaddr	= &TempIndex  );
	as$status ( action = RET_STATUS );

        __DBGpr_int("My New TempIndex ", TempIndex);

	ii = TempIndex - me->nNbAttr;

        __DBGpr_int("index sent to VRSetMEIX",ii);
	status =
	om$send (msg = message VRComponent.VRSetMEIX (msg, ii, MyNewIndex),
            targetid = my_id);

        __DBGpr_int("MyNewIndex",MyNewIndex);
	if( TempIndex == me->Orientation.nPriIndex )
        {
		me->Orientation.dPrimary = MyNewOrient;
		__DBGpr_dbl("My New Primary orient", me->Orientation.dPrimary);
        } 
        else if( TempIndex == me->Orientation.nSecIndex )
        {
		me->Orientation.dSecondary = MyNewOrient;
		__DBGpr_dbl("My New Secondary orient",me->Orientation.dPrimary);
        }

End
return ( OM_S_SUCCESS );

}/* end VRChgSupport */

/***********************************************************************/

method  VRConnect(IGRlong 		*msg;
		  struct GRid		*SegId;
		  IGRshort		nIndex;
		  IGRshort		nCptNum;
		  struct GRmd_env	*md_env  )
{
	/* ------- VRConnect ------- */

	IGRdouble	dOldMatrix[16], dNewSegOrie[3], dOldSegOrie[3];
	IGRdouble	dXaxis[3],dYaxis[3], dXOrie, dYOrie;
	IGRlong		retmsg, ConIndex;
	IGRint		status;
	IGRshort	nXIndex, nYIndex;
	IGRboolean	bNewMatDef=FALSE;

        extern IGRint  VRSelectOrie();
		/*"---- %s ----\n",me->szAABBCC */

        SetProc( VRComponent_VRConnect ); Begin
  *msg = MSFAIL;


  /* -- Set connection index -- */
  ConIndex = me->nNbAttr + me->nNbTopo; /* connect new segment at the end */

  /* -- Save actual matrix -- */

  status= om$send (
  msg 	 = message VRGeneric.VRGetMatrix ( &retmsg, 0, NULL, dOldMatrix, md_env ),
  targetid = my_id );
  as$status ( action = RET_STATUS );

  dXaxis[0] = dOldMatrix[0]; dXaxis[1] = dOldMatrix[4]; dXaxis[2] = dOldMatrix[8];
  dYaxis[0] = dOldMatrix[1]; dYaxis[1] = dOldMatrix[5]; dYaxis[2] = dOldMatrix[9];

  __DBGpr_mat("oldmatrix",dOldMatrix);
  /* ------------------------------------------------- */
  /* -- Try to set either primary or secondary axis -- */
  /* ------------------------------------------------- */

  /* get new segment orientation */

  status= om$send(
	msg = message VRCnrlSeg.VRGetTopo
	(&retmsg, dNewSegOrie, NULL, NULL, NULL, NULL, md_env ),
  targetid = SegId->objid,
  targetos = SegId->osnum );
  as$status ( action = RET_STATUS );

  /*" Xaxis : %f, %f, %f\n",dXaxis[0], dXaxis[1], dXaxis[2] */
  /*" Yaxis : %f, %f, %f\n",dYaxis[0], dYaxis[1], dYaxis[2] */
  /*" Seg   : %f, %f, %f\n",dNewSegOrie[0], dNewSegOrie[1], dNewSegOrie[2] */
if(me->Orientation.nPriIndex < 0 && me->Orientation.nSecIndex < 0)
  me->Orientation.nSecIndex = me->Orientation.nPriIndex = -1;

  VRSelectOrie ( 	1, dNewSegOrie,
			dXaxis, dYaxis, NULL,
			&nXIndex,
			&nYIndex,
			NULL,
			&dXOrie,
			&dYOrie,
			NULL,
			md_env );
  if ( nXIndex != -1 && me->Orientation.nPriIndex < 0 )
  {
        __DBGpr_int("nPriIndex less than 0",me->Orientation.nPriIndex);
        __DBGpr_int("nSecIndex value",me->Orientation.nSecIndex);
	bNewMatDef = TRUE;
	me->Orientation.nPriIndex = ConIndex;
        __DBGpr_int("nPriIndex value reset",ConIndex);
	me->Orientation.dPrimary  = dXOrie;
	/*"Primary axis defined : End = %d, Orientation = %f\n",nIndex,dXOrie */

  }/* end primary axis fixed */
  else if ( nYIndex != -1 && me->Orientation.nSecIndex == -1)
//  if ( nYIndex != -1 && me->Orientation.nSecIndex < 0 )what intent here?
  {
        __DBGpr_int("nSecIndex less than 0",me->Orientation.nSecIndex);
	bNewMatDef = TRUE;
	me->Orientation.nSecIndex   = ConIndex;
	me->Orientation.dSecondary  = dYOrie;
        __DBGpr_int("nSecIndex value reset",ConIndex);
	/*"Secondary axis defined : End = %d, Orientation = %f\n",nIndex,dYOrie */ 

  }/* end secondary axis fixed */


  /* ------------------------------------ */
  /* -- Manage Bend sweep if necessary -- */
  /* ------------------------------------ */

  if ( !bNewMatDef && me->Orientation.nSecIndex == -1 )
  {
	IGRdouble 	dZaxis[3], dAngle, dTmpAngle;
	IGRdouble	dOrg[3], dTransformed[3];
	BSrc		rc;
	struct GRid	PrimSegId;
	IGRint			Index=-1;
	struct ret_struct	AttrSt;

	dOrg[0] = dOrg[1] = dOrg[2] = 0.0;

	/* -- Segment might fixe the Y axis rotated by the bend sweep -- */

	/* -- Get Bend sweep value -- */

	status =
	om$send (msg = message VRComponent.ACgive_structure
				( (IGRint *)&retmsg, &Index,
				 VR_N_BEND_ANG_DB, &AttrSt, md_env ),
				targetid = my_id );
	if ( ! ( status & 1 & retmsg ) )
	{
           IGRshort   nSysTyp;

	   dAngle = 0.0;

           /* recalculating this bend sweep angle will corrupt
              ALL NON ELBOW components, so make sure we do this
              ONLY FOR ELBOWS                                       */
           status =
	   om$send (msg = message VRGeneric.VRGetSysType
                                                (&retmsg, &nSysTyp),
	       targetid = my_id );
           if (nSysTyp == VR_ELBOW)
           {
		status =
		om$send (msg = message VRComponent.VRGetOrientationDef
				( &retmsg, &PrimSegId,
				 NULL, NULL, NULL, NULL, NULL ),
				targetid = my_id );
		as$status();

  		status= om$send(
			msg = message VRCnrlSeg.VRGetTopo
			(&retmsg, dOldSegOrie, NULL, NULL, NULL, NULL, md_env ),
  		targetid = PrimSegId.objid,
  		targetos = PrimSegId.osnum );
  		as$status ();

		BScrossp ( &rc, dOldSegOrie, dNewSegOrie, dTransformed );
		if( rc != BSSUCC )
		{
			dAngle = 0.0;
		}
		else
		{
			dTmpAngle = VRcompute_angle( dOldSegOrie, dNewSegOrie,
                                                     dTransformed );
			dTmpAngle = dTmpAngle/ M_PI*180.0;
			dAngle = dTmpAngle -90.0;
		}
           }
	}
	else
{
	 dAngle = AttrSt.var.root_pm_st.value - 90.0;
}
	/*" Bend angle =%lf\n",dAngle */

	/* convert angle to radians */
	dAngle = dAngle /180.0 * M_PI;

	/* -- Rotate the X and Y axis around the Z axis by (Bend_Sweep - 90) -- */

	dZaxis[0] = dOldMatrix[2]; dZaxis[1] = dOldMatrix[6]; dZaxis[2] = dOldMatrix[10];

	{
		IGRboolean BooleanVar;

 		BooleanVar = TRUE;
		BSroto ( &rc,dOrg,dZaxis,&BooleanVar,
			 &dAngle,dYaxis,dYaxis );
		if ( rc != BSSUCC )
		{/*| ERROR -> Y axis not ROTATED */}

		BSroto ( &rc,dOrg,dZaxis,&BooleanVar,
		 	 &dAngle,dXaxis,dXaxis );
		if ( rc != BSSUCC )
		{/*| ERROR -> X axis not ROTATED */}

		/*" new Xaxis : %f, %f, %f\n",dXaxis[0], dXaxis[1], dXaxis[2] */
		/*" new Yaxis : %f, %f, %f\n",dYaxis[0], dYaxis[1], dYaxis[2] */
	}

	/* -- See if segment matches new Y axis -- */

	VRSelectOrie ( 	1, dNewSegOrie,
			NULL, dYaxis, NULL,
			NULL,
			&nYIndex,
			NULL,
			NULL,
			&dYOrie,
			NULL,
			md_env );

	if ( nYIndex != -1 )
	{
		bNewMatDef = TRUE;
		me->Orientation.nSecIndex   = ConIndex;
		me->Orientation.dSecondary  = dYOrie;
		/*"Secondary axis defined (Bend): End = %d, Orientation = %f\n",nIndex,dYOrie */

	}/* end secondary axis fixed */

  } /* end try to fixe the secondary axis with bend sweep */


  /* ------------------------ */
  /* -- Perform connection -- */
  /* ------------------------ */

  /*" Connect <%d,%d> at index %d \n", SegId->objid, SegId->osnum, ConIndex */

  {
	OM_p_CHANSELECT	ToFather,ToChildren;
	struct GRid	MyId;

	status = NDget_channel( &ToFather, &ToChildren );
	as$status(action = RET_STATUS);

	status = om$send( msg = message Root.connect
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

        status =
        om$send (msg = message VRComponent.VRSetMEIX
                                           (msg, me->nNbTopo, nIndex),
            targetid = my_id);

	me->nNbTopo 		+= 1;
  }/* end connection */

  /* ------------------------ */
  /* -- Set rotation angle -- */
  /* ------------------------ */



  if ( 	bNewMatDef && 
	(( me->Orientation.nPriIndex == -1 ) ||
	 ( me->Orientation.nSecIndex == -1 )))
  {
	struct IGRplane	Ortho;
	IGRdouble	dPoint [3];
	IGRdouble	dNormal [3];
        __DBGpr_int("nPriIndex",me->Orientation.nPriIndex);
        __DBGpr_int("nSecIndex",me->Orientation.nSecIndex);

	Ortho.point = dPoint;
	Ortho.normal = dNormal;

	/* -- If Matrix has a new definition and only one axis is defined : -- */

	/*| Recompute rotation angle */

	/* -- Get axis from planes -- */

	status =
	om$send ( msg = message VRCnrlSeg.VRGetTopo
		( &retmsg, NULL, NULL, &Ortho, NULL, NULL, md_env ),
	targetid = SegId->objid,
	targetos = SegId->osnum );
	as$status ( action = RET_STATUS );

	if ( me->Orientation.nPriIndex == -1 )
	{
		/* -- if primary is not defined : set primary angle -- */
		/* dXaxis/Normal_Ortho */
		me->Orientation.dPrimary = VRcompute_angle(dNormal, dXaxis, dYaxis);
                __DBGpr_dbl("Angle stored on primary",me->Orientation.dPrimary);
		/* " X rotated of %f radian\n", me->Orientation.dPrimary */

	}/* end set primary angle */
	else
	{
		/* -- else set secondary angle -- */
		/* dYaxis/Normal_Ortho */
		me->Orientation.dSecondary = VRcompute_angle(dNormal, dYaxis, dXaxis);
                __DBGpr_dbl("Angle stored on dSecondary",me->Orientation.dSecondary);
		/*" Y rotated of %f radian\n", me->Orientation.dSecondary */

	}/* end set secondary angle */

  }/* end compute angle */


  End
  return OM_S_SUCCESS ;

}/* end VRConnect */

/***********************************************************************/

method  VRDisconnect(	IGRlong 		*msg;
			  struct GRid		*SegId;
			  struct GRmd_env	*md_env  )
{
	/* ------- VRDisconnect ------- */

	IGRint		status;
	IGRshort	i, cmp_systype;
	IGRshort        ii,jj;
	IGRlong		retmsg;
	IGRuint		SegIndex;
	IGRdouble	dBendSweep=0.0;
        int             intseg;
        SetProc( VRComponent_VRDisconnect ); Begin
*msg = MSFAIL;

		/*"---- %s ----\n",me->szAABBCC */

	/*| -- Get Segment's index -- */

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &ND_father,
			objid		= SegId->objid,
			indexaddr	= &SegIndex  );
	as$status ( action = RET_STATUS );

        /*"Disconnect Seg at xIndex is %d\n", SegIndex */

	/* -- If Topology was defining the bend sweep : save it -- */
	if ( 	me->Orientation.nPriIndex >= 0 &&
		me->Orientation.nSecIndex >= 0  )
	{
		IGRint			intmsg;
		IGRint			Index=-1;
		struct ret_struct 	AttrSt;

		/* -- We had both primary and secondary -- */
		/*| get bend sweep */
		status =
		om$send (msg = message VRComponent.ACgive_structure
				( &intmsg, &Index,
				 VR_N_BEND_ANG_DB, &AttrSt, md_env ),
			targetid = my_id );
		if ( (status&1&intmsg) )
			dBendSweep = AttrSt.var.root_pm_st.value;
		/*" Bend saved = %f\n", dBendSweep */
	}

	/*| -- Disconnect the segment -- */

	status= om$send (
		msg 	 = message NDnode.NDdisconnect ( 1, SegId ),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/*| -- Treatment if Segment is used for the matrix computation -- */

	if ( me->Orientation.nPriIndex == SegIndex )
	{
		/*| Primary axis lost */
		if (me->Orientation.nSecIndex >= 0)
		{
			/* -- Save bend sweep in primary -- */
			me->Orientation.nPriIndex = -2;
			me->Orientation.dPrimary = dBendSweep;
                   __DBGpr_dbl("angle stored in primary ",dBendSweep);
			/*" Bend in Primary = %f\n", dBendSweep */
		}
		else
                {
                    	me->Orientation.nPriIndex = -1;
                        __DBGpr_com("nPriIndex reset to -1");
                }

	}/* end primary axis lost */
	else if ( me->Orientation.nSecIndex == SegIndex )
	{
		/*| Secondary axis lost */
		if (me->Orientation.nPriIndex >= 0)
		{
			/* -- Save bend sweep in primary -- */
			me->Orientation.nSecIndex = -2;
			me->Orientation.dSecondary = dBendSweep;
                   __DBGpr_dbl("angle stored in secondary ",dBendSweep);
			/*" Bend in Secondary = %f\n", dBendSweep */
		}
		else
                {
                        me->Orientation.nSecIndex = -1;
                        __DBGpr_com("nSecIndex reset to -1");
                }

	}/* end secondary axis lost */

	/*| -- Update topological instances -- */

		/* Update number of topological templates */

	me->nNbTopo -= 1;

		/* Update position on segments array */

	for ( i=SegIndex; i<(me->nNbTopo-1); i++ )
	{
          ii = i+1;
	  status =
	  om$send (msg = message VRComponent.VRGetMEIX (&retmsg, ii, &jj),
              targetid = my_id);

	  status =
	  om$send (msg = message VRComponent.VRSetMEIX (&retmsg, i, jj),
              targetid = my_id);
	}/* end update index array */

		/* Update orientation instances */
intseg = (int) SegIndex;
	if ( me->Orientation.nPriIndex > intseg )
			me->Orientation.nPriIndex -= 1 ;
	if ( me->Orientation.nSecIndex > intseg )
			me->Orientation.nSecIndex -= 1 ;


*msg = MSSUCC;
End
return OM_S_SUCCESS;

}/* end VRDisconnect */


/***********************************************************************/

method VRSetOrientationDef ( 	IGRlong *msg ; 	struct GRid PrimaryId;
						IGRdouble   *dPrimary;
						struct GRid SecondaryId;
						IGRdouble   *dSecondary)
{
	IGRuint temp;
        SetProc( VRComponent_VRSetOrientationDef ); Begin

*msg = MSSUCC;

	/*" ---- %s ----\n",me->szAABBCC */

	/* ------------------------- */
	/* -- Primary information -- */
	/* ------------------------- */

	if ( PrimaryId.objid != NULL_OBJID ) 
	{
		/*" Primary Segmentid = <%d,%d>\n",PrimaryId.objid,PrimaryId.osnum*/
		om$get_index (object_c	= me,
			   p_chanselect = &ND_father,
			   objid        = PrimaryId.objid,
			   indexaddr 	= &temp );
		/*" Primary segment at index %d\n", me->Orientation.nPriIndex */
		me->Orientation.nPriIndex = (IGRshort)temp;

	}/* end primary Id */

	if (dPrimary)
	{
		me->Orientation.dPrimary = *dPrimary;
		/*" Orientation %f on Primary\n", *dPrimary */

	}/* end  Orientation on primary */

	/* --------------------------- */
	/* -- Secondary information -- */
	/* --------------------------- */

	if ( SecondaryId.objid != NULL_OBJID ) 
	{
		/*" Secondary Segmentid = <%d,%d>\n",SecondaryId.objid,SecondaryId.osnum*/
		om$get_index (object_c	= me,
			   p_chanselect = &ND_father,
			   objid        = SecondaryId.objid,
			   indexaddr 	= &temp );
		me->Orientation.nSecIndex = (IGRshort)temp;
		/*" Secondary segment at index %d\n", me->Orientation.nSecIndex */

	}/* end Secondary Id */

	if (dSecondary)
	{
		me->Orientation.dSecondary = *dSecondary;
		/*" Orientation %f on Secondary\n", *dSecondary */

	}/* end Orientation on Secondary */

        End
	return OM_S_SUCCESS;
}/* end VRSetOrientationDef */

end implementation VRComponent;
