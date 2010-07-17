/***********************************************************************
     CLASS  NAME: 	VRCptIn

     METHOD NAMES: 	All methods accessing the connected objects.

     Abstract:
		

     CHANGE HISTORY:

	* 09-DEC-91	1.4.3.14	
		Bruno
		- Creation.

***********************************************************************/

class implementation VRCptIn;

#include "nddef.h"
#include "ndmacros.h"

#define AS_DEBUG	1


extern	struct GRid	NULL_GRID;

/**************************************************************************/

method VRGetIndex ( IGRlong *msg; struct GRid *SegmentId; IGRshort *CompIndex)

{
	IGRint 			status;
	IGRuint			TempIndex;
	OM_S_CHANSELECT		father;

*msg = MSSUCC;
father.type = OM_e_name;
father.u_sel.name = "father";

	/* -- Verify that the segment is my template -- */

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &father,
			objid		= SegmentId->objid,
			indexaddr	= &TempIndex  );
	if (!(status&1))
	{
		/*| ERROR -> UNKNOWN SEGMENT */
		return (status);
	}

	/* -- get index on segment from my list of indexes -- */

	/*" My index on segment is %d\n",me->nIndex*/

	*CompIndex = me->nIndex;

return ( OM_S_SUCCESS );

}/* end VRGetIndex */

/**************************************************************************/

method VRConnect(IGRlong 		*msg;
		  struct GRid		*TempId;
		  IGRshort		nIndex;
		  IGRshort		nCptNum;
		  struct GRmd_env	*md_env  )
{

	IGRint		status;
	struct GRid	MyId;

*msg 	= MSFAIL;
status 	= OM_E_ABORT;

/* in TempId we will have the segment and the dependent planes too */

/* -- KLUDGE : SHOULD CHECK ON THE ALIGNMENT OF CPT AND SEGMENT -- */
if ( me->nIndex < 0 )
{
	/* ------------------------------- */
	/* -- Connect via assoc channel -- */
	/* ------------------------------- */

  	status = om$send( msg      = message NDnode.NDconnect( 4, TempId, NULL_GRID,ND_NEW ),
		    	  targetid = my_id);
  	as$status( action = RET_STATUS );

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

	om$send( msg      = message NDnode.NDnotify_connect( MyId ),
		 targetid = TempId[0].objid,
		 targetos = TempId[0].osnum );

	/* ---------------------- */
	/* -- Update instances -- */
	/* ---------------------- */

	*msg		 = MSSUCC;
	me->nIndex	 = nIndex;
	me->nNbTopo	 = 1;
	status		 = OM_S_SUCCESS;

}/* end connection proceeded */

return ( status );

}/* end VRConnect */


/***********************************************************************/

method VRChgSupport ( IGRlong *msg ; IGRdouble MyNewOrient;
                      IGRshort MyNewIndex; struct GRid *OldSupportId;
                      struct GRid *NewSupportId )
{
	IGRint 			status;

*msg = MSSUCC;

	status = om$send( mode     = OM_e_wrt_message,
       			  msg      = message NDnodein.NDchange_connect
                                     ( 1, OldSupportId, NewSupportId ),
	                  targetid = my_id );
	as$status( action = RET_STATUS );

	/* -- get specified template index -- */

	me->nIndex = MyNewIndex;

        /*"My New Index is %d\n", me->nIndex */
        
return ( OM_S_SUCCESS );

}/* end VRChgSupport */

/**************************************************************************/

method VRGetCptOnSup ( IGRlong *msg ; struct GRid *SegId; IGRshort *nCpNum;
			struct GRmd_env *md_env)
{
	/* ---------- METHOD:      VRGetCptOnSup ---------- */

	IGRint			status;
	IGRuint			TempIndex;
	OM_S_CHANSELECT		father;


/* -- Verify arguments -- */
if ( !SegId || !nCpNum )
{
	/*| ERROR -> NULL Pointer given */
	*msg = MSFAIL;
	return ( OM_E_INVARG );
}

*msg = MSSUCC;


	/* -- Verify that the segment is my template -- */

	father.type = OM_e_name;
	father.u_sel.name = "father";

	status =
	om$get_index ( 	object_c 	= me,
			p_chanselect	= &father,
			objid		= SegId->objid,
			indexaddr	= &TempIndex  );
	if (!(status&1))
	{
		/* -- If it is not , return Error -- */

		/*| ERROR -> UNKNOWN SEGMENT */
		printf (" KLUDGE : WAIT TO SEE IF WE NEED THIS VRGetCptOnSup\n");
		return (status);
	}

	/* -- if it is , return my Cp num -- */
	*nCpNum = me->nCpNum;


return OM_S_SUCCESS;

}/* end VRGetCptOnSup */

/**************************************************************************/

method VRGetSupOnCpt ( IGRlong *msg ; IGRshort nCpNum; struct GRid *SegId;
			struct GRmd_env *md_env)

{
	IGRint status;

	/* ---------- METHOD:      VRGetSupOnCpt ---------- */

/* -- Verify arguments -- */
if ( !SegId )
{
	/*| ERROR -> NULL Pointer given */
	*msg = MSFAIL;
	return ( OM_E_INVARG );
}

*msg = MSSUCC;


	if ( nCpNum == me->nCpNum )
	{
		IGRint		NbSupports;

		/* -- Return my segment template if it exists -- */

		status =om$send(
	       		msg      = message VRGeneric.VRGetSupports
                                     ( msg, 1, SegId, &NbSupports ),
		                  targetid = my_id );
	}/* end return my support */
	else
	{
		printf (" KLUDGE : WAIT TO SEE IF WE NEED THIS VRGetSupOnCpt\n");
		return OM_E_ABORT;
	}/* end query my component */

return OM_S_SUCCESS;

}/* end VRGetSupOnCpt */

/***********************************************************************/

method  VRDisconnect(	IGRlong 		*msg;
			struct 	GRid		*SegId;
			struct 	GRmd_env	*md_env  )
{
	IGRint		i, NbTemps, status;
	GRclassid	obj_classid;
	struct	GRid	*buffer;

        extern GRclassid OPP_VRDepPlane_class_id;

	*msg = MSFAIL;

	/*| -- Disconnect the segment -- */

	status= om$send (
		msg 	 = message NDnode.NDdisconnect ( 1, SegId ),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/* delete my DepPlanes parents */
	status = om$send( msg      = message NDnode.NDget_objects
				     ( ND_ROOT | ND_IN_BUF, NULL, 0,
				       &buffer, 0, OM_K_MAXINT,
				       &NbTemps
				     ),
			  targetid = my_id );
	as$status();

	for(i=0; i<NbTemps; i++)
	{
		/*"buffer[%d] = %d\n", i, buffer[i].objid */

  		om$get_classid( objid     = buffer[i].objid,
		   		osnum     = buffer[i].osnum,
                    		p_classid = &obj_classid );

   		if(om$is_ancestry_valid( subclassid   = obj_classid,
                            		 superclassid = OPP_VRDepPlane_class_id) == OM_S_SUCCESS)
		{
			/*| it's a VRDetPlane */
  			nd$wait_batch( 	type       = GR_DELETED,
                 			l_object   = &buffer[i],
                 			nb_obj     = 1 );
			as$status();
		}
  	}

	/* Delete myself */
	status = om$send( msg      = message GRgraphics.GRdelete( msg, md_env ),
	  	  	  targetid = my_id );
	as$status();

	*msg = MSSUCC;

	return OM_S_SUCCESS;

}/* end VRDisconnect */


end implementation VRCptIn;
