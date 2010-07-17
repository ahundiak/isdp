/*
     CLASS  NAME: VRHanger
     METHOD NAMES: 


***********************************************************************/

class implementation VRHanger;

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRparamdef.h"
#include "VDmem.h"

#define AS_DEBUG

/**********************************************************************/

method ACgive_structure(int *msg; int *direct_index; char *footname;
                        struct ret_struct *p_rs;
			struct GRmd_env *md_env)

  {
	IGRint			status=OM_S_SUCCESS;
	IGRlong			retmsg;
	IGRint			BSmkvec();
	IGRdouble		BSlenvec();

*msg=MSSUCC;

		/*"---- %s ----\n",me->szAABBCC */


/*" Footname= %s \n", footname  */
 

if ( !(strcmp (footname, VR_N_REF_CS)) )
{
	p_rs->type= ref_generic;
	status = om$send ( msg = message VRGeneric.VRGetMatrix
					( &retmsg,0,NULL,
					  p_rs->var.ref_st.t, md_env ),
			targetid = my_id);
	as$status ();
}   

else if ( !(strcmp (footname, VR_N_LOC_PT)) )
{
	p_rs->type= point_generic;
	status =
	om$send (msg      = message VRGeneric.VRGetOrigCoor
			( &retmsg, p_rs->var.point_st.pt, md_env) ,
		targetid = my_id );
	as$status(action = RET_STATUS);
}
else if ( 	!(strcmp (footname,VR_N_SYST_NAME_AN ))  ||
		!(strcmp (footname,VR_N_FLUID_CODE_AN )) ||
		!(strcmp (footname,VR_N_SEQ_NUMBER_AN )) ||
		!(strcmp (footname,VR_N_CLASS_AN )) ||
		!(strcmp (footname,VR_N_UNIT_AN )) 	 ||
		!(strcmp (footname,VR_N_ZONE_AN )) 	 ||
		!(strcmp (footname,VR_N_WEIGHT_GRP_IN )) ||
		!(strcmp (footname,VR_N_CHG_REQ_NUM_IN ))      )
{
	/*| Get These feet from the component */
	{
		/* -- Get Component Id -- */
		struct GRid		CompId,TempId;
		struct GRmd_env		LocEnv;
		OM_S_CHANSELECT 	father;

		/*| Get Component from channel */

		father.type = OM_e_name;
		father.u_sel.name = "father";

		status =
		om$get_objid_at_index (	object	= me,
				p_chanselect	= &father,
				index 		= 0,
				objidaddr	= &TempId.objid,
				osnumaddr	= &TempId.osnum);
		as$status ( action = RET_STATUS );

		/* -- Return the template component id -- */
		/*|  get Component's id - using ACreturn_foot */
		status=
		om$send (msg = message NDmacro.ACreturn_foot
				(&retmsg,
				"",
				&CompId,
				&LocEnv.md_env.matrix_type,
				LocEnv.md_env.matrix),
			targetid = TempId.objid,
			targetos = TempId.osnum);
		/*"Neigh (os,id) = (%d,%d)\n",CompId.osnum,CompId.objid */
		as$status ( action = RET_STATUS );

		status=
		om$send (msg = message ACncpx.ACgive_structure 
				(msg, direct_index, footname, p_rs, md_env),
			targetid = CompId.objid,
			targetos = CompId.osnum);
		/*" status = %d, msg = %d\n", status, *msg */


	}

}
else if ( !(strcmp (footname,VR_N_TAG_NUMBER_AN )) )
{
	p_rs->type= text_type;
	strcpy(p_rs->var.text_st.text_string, me->VRSupAttr.szTagNumber );
}
else if ( !(strcmp (footname,VR_N_SUPP_SIZE_DB )) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = me->VRSupAttr.dSize;
}
else if ( !(strcmp (footname,VR_N_SUPP_TYPE_IN )) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = (IGRdouble) me->VRSupAttr.Type;
}
else if ( !(strcmp (footname,VR_N_DETAIL_NUM_AN )) )
{
	p_rs->type= text_type;
	strcpy(p_rs->var.text_st.text_string, me->VRSupAttr.szDetailNumber );
}
else if ( !(strcmp (footname,VR_N_WEIGHT_DB )) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value = me->VRSupAttr.dWeight;
}
else if ( !(strcmp (footname,VR_N_COMP_NOTE_AN )) )
{
	p_rs->type= text_type;
	strcpy(p_rs->var.text_st.text_string, me->VRSupAttr.szRemarks );
}
else if ( !(strcmp (footname,VR_N_CONSTR_STAT_AN )) )
{
	p_rs->type= text_type;
	sprintf ( p_rs->var.text_st.text_string,"%d",
			me->VRSupAttr.ConstrStatus);
}
else if ( !(strcmp (footname,VR_N_APPRV_STAT_AN )) )
{
	p_rs->type= text_type;
	sprintf ( p_rs->var.text_st.text_string,"%d",
			me->VRSupAttr.ApprvStatus);
}
else if ( !(strcmp (footname,VR_N_NO_MTO_AN )) )
{
	p_rs->type= text_type;
	p_rs->var.text_st.text_string[0] = me->VRSupAttr.cNoMtoFlag;
	p_rs->var.text_st.text_string[1] = '\0';

}
else
{
	/*| Try OM_e_wrt_message */
	/* 4-98 KDD Smart Attribute correction SA_ Let VDSroot handle it */ 
	status=
	om$send (msg = message VDSroot.ACgive_structure 
				(msg, direct_index, footname, p_rs, md_env),
			mode = OM_e_wrt_message,
			targetid = my_id);
	/*" status = %d, msg = %d\n", status, *msg */

}/* end try OM_e_wrt_message */


return ( status );

}/* end method ACgive_structure */


method GRget_siblings (IGRlong *msg; IGRushort opts;
                        IGRint *num_siblings; struct GRid **siblings;
                        IGRint num_buff; struct GRid *buff)
{
	IGRint 			status;
	IGRlong 		retmsg;
	IGRint			NbNei;
	struct GRid		*pSibIds;
	struct GRmd_env		md_env;
	struct GRid		CompId;

	*msg = MSSUCC;
	*num_siblings=0;

	{/* get module env */
		IGRlong			NumberOfBytes;  /* number of bytes            */
		IGRlong			BytesReceived;   /* number of received bytes  */
		NumberOfBytes = sizeof( struct GRmd_env );
		status = gr$get_model_env( 	msg    = &retmsg,
						sizbuf = &NumberOfBytes,
						buffer = &md_env,
						nret   = &BytesReceived );
		as$status( action = RET_STATUS );
		as$status( sts = retmsg, action = RET_STATUS );
		/*"module_info = %d %d\n", md_env.md_id.objid, md_env.md_id.osnum */
	}/* end get module env */


#ifdef IF_PROBLEM_IN_THE_FUTURE

	/* ------------------ */
	/* -- get siblings -- */
	/* ------------------ */

	status =
	om$send ( msg = message ACncpx.GRget_siblings
			( msg, opts, num_siblings, siblings, num_buff,&SibIds),
		mode = OM_e_wrt_message,
		targetid = my_id );
	as$status ();
	if ( *num_siblings  > num_buff ) 
	{
		/* buffer has been allocated */
	}

	/* -- */
#endif

	*num_siblings = 1;

	if ( *num_siblings > num_buff ) 
	{
		/*| buffer has to be allocated */

		*siblings = NULL;
		*siblings = _MALLOC (*num_siblings, struct GRid);

		if ( !(*siblings) ) return OM_E_NODYNMEM;

		pSibIds = *siblings;
	}
	else
	{
		/*| No malloc needed */
		pSibIds = buff;
	}


	/* --------------------- */
	/* -- get my neighbor -- */
	/* --------------------- */

	status =
	om$send ( msg = message VRGeneric.VRGetNeighbors
				(msg,0,VR_MAX_CPTS,&NbNei,pSibIds,NULL, &md_env ),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/*| Get neighbor Owner */

	ASget_as_owner ( pSibIds, &CompId );

	if ( CompId.objid != NULL_OBJID ) pSibIds[0] = CompId;

return OM_S_SUCCESS;

}/* end GRget_siblings */

end implementation VRHanger;
