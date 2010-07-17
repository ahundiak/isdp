/* $Id: VRGenOver.I,v 1.4 2002/06/11 20:40:40 ramarao Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrgeneric / VRGenOver.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRGenOver.I,v $
 *	Revision 1.4  2002/06/11 20:40:40  ramarao
 *	Fixed TR# 6448
 *	
 *	Revision 1.3  2001/02/20 01:14:06  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 20:44:15  anand
 *	SP merge
 *	
# Revision 1.2  2000/06/16  19:02:28  pinnacle
# Replaced: route/vrgeneric/VRGenOver.I for:  by lawaddel for Service Pack
#
# Revision 1.1  2000/05/23  23:17:30  pinnacle
# Created: route/vrgeneric/VRGenOver.I by lawaddel for Service Pack
#
# Revision 1.4  1998/06/02  12:30:40  pinnacle
# tr179801102
#
# Revision 1.3  1998/05/22  19:14:42  pinnacle
# TR179801102
#
# Revision 1.2  1998/05/21  19:38:12  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by kddinov for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.6  1998/04/08  14:53:32  pinnacle
# Smart Attributes
#
# Revision 1.5  1998/02/04  14:32:40  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by kddinov for route
#
# Revision 1.4  1998/01/28  15:54:52  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by azuurhou for route
#
# Revision 1.3  1997/10/24  18:52:38  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by apazhani for route
#
# Revision 1.4  1997/10/23  14:56:18  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by apazhani for route
#
# Revision 1.3  1997/02/18  20:10:52  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by hverstee for route
#
# Revision 1.2  1996/07/25  19:38:12  pinnacle
# (No comment)
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.8  1996/04/29  13:29:02  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by ashankar for route240
#
# Revision 1.7  1996/04/11  22:50:14  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by ashankar for route240
#
# Revision 1.6  1996/04/04  17:13:06  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by hverstee for route240
#
# Revision 1.5  1996/01/17  00:01:40  pinnacle
# Replaced: vrgeneric/VRGenOver.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/16/96	tlb	Add protoypes
 *	10/23/97        Alwin   Commented few lines in ACgive_structure 
 *                              i.e  footname VD_N_NO_MTO_FLAG_AN is avaialble
 *                              in collector and moreover the instance variable
 *                              didn't have the value. Alwin for TR179701824
 *	10/24/97        Alwin   UnCommented those lines in ACgive_structure. 
 *                              B'cas above behaviour is observed only in the 
 *                              case of the Equipment. So, I'll takecare of this
 *                              at the Equipment level.
 *	01/28/97	adz	Exec_batch for GRxform method.
 *      04/08/98        ah      Smart Attribute Support, ACgive_struct now passes
 *                              control to VDSroot vice ACncpx
 *
 *	05/22/98	KDD	TR179801102 Core dump fix for corrupted file.
 *      06/02/98        ah      TR179801102 Removed warning message from above fix
 *************************************************************************/
class implementation VRGeneric;

/* HISTORY

   Name		| Date	  | Reason
   -------------------------------------------------------------------------
   Mallik	| 19-1-95 | Commenting the method NDdrawing_copy_geom 
		|	  | implemented for Yarrow Bench Mark.
   Mallik	| 15-3-95 | TR # 179524611
		|	  | GRgetsiblings makes a call to ASget_as_owner()
		|         | even though one of the neighbours returned is NULL.
   Manyam	| 9-6-95  | Avoid accessing the DB for comp code while
		|	  | displaying object info during locate. Modified
		|	  | GRgetobjinfo.
   -------------------------------------------------------------------------
*/

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <string.h>
#include <stdlib.h>
#include "asbox.h"
#include "acrepdef.h"
#include "VRDbParamDef.h"
#include "VDDbtbldef.h"		/* Generic attributes names definition */
#include "VRparamdef.h"		/* I/ROUTE attributes names definition */
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRPid.h"
#include "VRdef.h"
#include "VDmem.h"
#include "vrtools_pto.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"
#include "vdreporterr.h"

#define AS_DEBUG 1

extern  GRclassid       OPP_VRNozzle_class_id;
/*                        OPP_VRConnect_class_id;	*/

from	VRProduct	import VRGetProduct;
from	ACpretend	import ACfind_parent;
/***********************************************************************/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)

{

	IGRchar			string[50];
	IGRchar			szAABBCC[50];
	IGRint			status;
	IGRlong			retmsg;
	IGRint			FootIndex=-1;
	struct ret_struct	AttrRst;

        SetProc( VRGeneric_GRgetobjinfo ); Begin
	*msg = MSSUCC;
	
	/* -- component type (11 characters) -- */
	status = 
	om$send ( msg = message VRProduct.VRGetProduct ( NULL, string ),
		targetid = my_id);
	if ( !(status&1) )	string[0]=0;
	else			strcat ( string, "/ " );

	if ( me->Status & VR_ERROR )
	 {
		/*| ERROR COMPONENT */
		strcat(string,"Error: ");
	 }

	/* -- should start by C(omponent) or I(nstrument) -- */
	/* -- add entity code (12 characters) -- */
	szAABBCC[0] = '\0';
	if ( !strlen(me->szAABBCC) )
	{
		status = 
		om$send( msg = message VRGeneric.VRGetCode( msg, szAABBCC ),
				targetid = my_id );
		
		if( !strlen(szAABBCC) )
			strcat(string," No Code? ");
		else
		{
			strcat( string, szAABBCC );
			strcat(string," ");
		}
	}
	else
	{
		strcat( string, me->szAABBCC );
		strcat(string," ");
	}

	/* -- add line number -- */
	status = 
	om$send ( msg = message VRGeneric.ACgive_structure
			( (IGRint *) &retmsg, &FootIndex, VR_N_SEQ_NUMBER_AN,
				  &AttrRst, NULL ),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	if ( retmsg&1 )
	{
		/*" Line sequence number : %s\n",AttrRst.var.text_st.text_string*/
		strcat (string, AttrRst.var.text_st.text_string );
	}

	/* -- add NVrepresentation (4 characters) -- */

	switch ( (IGRint) (me->xform_chan&AC_VDS_REP) )
	{
	case AC_2D_REP:	/*| representation : INTERNAL_2D */
		strcat ( string, " ($2D)" );
		break;
	case AC_3D_REP:	/*| representation :  INTERNAL_3D */
		strcat ( string, " ($3D)" );
		break;
	case AC_ENV_REP:/*| representation :  ENVELOPE */
		strcat ( string, " ($Env)" );
		break;
	default : 		/*| ERROR : representation not found */

		break;
	}

	/*" Description : %d characters\n",strlen(string)*/
	/*"             : %s \n"          ,string*/

	string[31] = '\0';

	strcpy ( info->type,string );
/*  End  */
  return(OM_S_SUCCESS);

}/* end GRgetobjinfo */


/*
--------------------------------------------------------------------------
*
* GRcopy
*
*
---------------------------------------------------------------------------
*/

method GRcopy(IGRlong *msg;
 		 struct GRmd_env *fr_env,*to_env; GRobjid *newobjid)

{
	IGRint		status;
	IGRlong		retmsg;
        IGRshort	Status;
	struct	GRid	newid;

        SetProc( VRGeneric_GRcopy ); Begin
	status = 
	om$send (msg = message VRGeneric.VRGetStatus( &retmsg, &Status ),
		targetid = my_id );
	as$status ( action = RET_STATUS );

        if( Status & VR_CORRECTION )
        {
		/* I receive this message from the Correction object */
		/* which will also copy my templates ( collections ) */
		/* so I have to get immediately copied */


		/* Make shure the macro definition is edited */
		if(to_env->md_id.osnum != fr_env->md_id.osnum )
		{
			status = 
			om$send ( msg = message VRGeneric.VRGetMacro
					( &retmsg,
					NULL,
					NULL,
					NULL,
					NULL,
					(IGRint *)NULL,
					(IGRchar ***) NULL,
					(struct ret_struct **)NULL,
					fr_env ),
				targetid = my_id);
			as$status ( action = RET_STATUS );
		}

		status = 
		om$send (msg = message ACncpx.NDcopy
        	      		(msg,0,fr_env,to_env,&newid),
			mode = OM_e_wrt_message,
			targetid = my_id );
		as$status ( action = RET_STATUS );

		/*" Copy Id :<%d,%d>\n",newid.objid,newid.osnum*/

        	*newobjid = newid.objid;
        }
        else
        {
		status = 
		om$send (msg = message ACncpx.GRcopy
				(msg,fr_env,to_env,newobjid),
			mode = OM_e_wrt_message,
			targetid = my_id );
		as$status ( action = RET_STATUS );
        }

*msg=MSSUCC;

End
return OM_S_SUCCESS;

}/* end GRcopy */


/*
--------------------------------------------------------------------------
*
* NDcopy
*
*
---------------------------------------------------------------------------
*/

method NDcopy(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid)

{
	IGRint		status;
	IGRlong		retmsg;

SetProc( VRGeneric_NDcopy ); Begin
*msg=MSSUCC;

	/*" ---- %s ----\n",me->szAABBCC */

	/* Make shure the macro definition is edited */
	if( to_env->md_id.osnum != fr_env->md_id.osnum )
	{
		status = 
		om$send ( msg = message VRGeneric.VRGetMacro
				( &retmsg,
				NULL,
				NULL,
				NULL,
				NULL,
				(IGRint *)NULL,
				(IGRchar ***) NULL,
				(struct ret_struct **)NULL,
				fr_env ),
			targetid = my_id);
		as$status ( action = RET_STATUS );
	}

	status = 
	om$send (msg = message ACncpx.NDcopy
			(msg,cp_type,fr_env,to_env,newobjid),
		mode = OM_e_wrt_message,
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/*" Copy Id :<%d,%d>\n",newobjid->objid,newobjid->osnum*/

	status = 
	om$send (msg = message VRGeneric.VRSetStatus
			(&retmsg,(IGRshort)VR_CLONE ,(IGRshort)VR_CLONE),
		targetid = newobjid->objid,
		targetos = newobjid->osnum );
	as$status ( action = RET_STATUS );

End
return ( OM_S_SUCCESS );

}/* end NDcopy */

/*
--------------------------------------------------------------------------
*
* NDdelete
*
*
---------------------------------------------------------------------------
*/

method NDdelete(struct GRmd_env *md_env)
{
	IGRint 			status;
	OM_p_CHANSELECT 	to_father,to_children;
	struct GRid 		my_grid;

        SetProc( VRGeneric_NDdelete ); Begin
	if( !IF_NULL_OBJID(md_env->md_id.objid) )
	{
		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

		/*A update the database ( for comp tag id management )
	    	    change the id to -1 before deletion and diconnecting
	    	    from the parents */
		if( bVR_IS_PID(me->xform_chan) )
		{
			struct ret_struct	ParamAttr;
			IGRint 			FootIndex = -1, retstatus;
			IGRchar			SysName[20];
			IGRint			Original=0;
			IGRint			TagNum, Cat, Behavior;

			/*A get the old cmp id */
			FootIndex = -1;
			status = 
			om$send( msg      = message 
				ACncpx.ACgive_structure( &retstatus, 
					&FootIndex, 
					VD_N_AUTO_ID_AN,
					&ParamAttr, 
					md_env),
				targetid = my_id);
			as$status();	

			TagNum =
			(int) atoi(ParamAttr.var.text_st.text_string);

			/*A get the behavior */
			FootIndex = -1;
			status = 
			om$send( msg      = message 
				ACncpx.ACgive_structure( &retstatus, 
					&FootIndex, 
					VD_N_BEHAVIOUR_IN,
					&ParamAttr, 
					md_env),
				targetid = my_id);
			as$status();	

			Behavior = (int)ParamAttr.var.root_pm_st.value;

			/*H( hard coded ) */
			/*A check whether original or referenced */
			FootIndex = -1;
			status = 
			om$send( msg      = message 
				ACncpx.ACgive_structure( &retstatus, 
					&FootIndex, 
					VD_N_ORIGINAL_AN,
					&ParamAttr, 
					md_env),
				targetid = my_id);
			as$status();	

			Original = (int) ParamAttr.var.root_pm_st.value;
/*H */
			/*A report only if i manage tag num , don't report
			   even if i manage line seq num ( it is shared 
			   by num of components */
			if ( Original && TagNum != -1 && Behavior == 2 )
			{
			  /*A get the category */
			  FootIndex = -1;
			  status = 
			  om$send( msg      = message 
				ACncpx.ACgive_structure( &retstatus, 
					&FootIndex, 
					VD_N_ID_CATEGORY_IN,
					&ParamAttr, 
					md_env),
				targetid = my_id);
			  as$status();	

			  Cat = (int) ParamAttr.var.root_pm_st.value;

			  /*A get the system name */
			  FootIndex = -1;
			  status = 
			  om$send( msg      = message 
				ACncpx.ACgive_structure( &retstatus, 
					&FootIndex, 
					VD_N_SYSTEM_NAME_AN,
					&ParamAttr, 
					md_env),
				targetid = my_id);
			  as$status();	
			  strcpy(SysName, ParamAttr.var.text_st.text_string);

			  retstatus =
			  VDModifyID( SysName, Cat, TagNum, -1 );
			}

		}/* end P&ID processing */

		status = 
		NDget_channel( &to_father, &to_children );
		as$status(action = RET_STATUS);

		status = 
		om$send(msg = message NDnode.NDnotify_disconnect(my_grid),
			p_chanselect = to_father);
		status = 
		om$send(msg = message Root.wild_disconnect(*to_father),
				targetid = my_id);
		as$status(action = RET_STATUS);
	}

	status = 
	om$send(msg = message VDSroot.NDdelete(md_env),
			mode = OM_e_wrt_message,
			targetid = my_id);
	as$status(action = RET_STATUS);

        End
	return(status);

}/* end NDdelete */

/*
--------------------------------------------------------------------------
*
* GRget_siblings
*
*
---------------------------------------------------------------------------
*/
/*\
Name
   GRget_siblings

Description
   This method obtains all siblings of this owner object. Sibling is
   a losely defined term and currently, can be interpreted by the
   owner for a particular application.

   *msg           IGRlong              completion code 
   opts           unsigned IGRshort    Options (currently none supported).
   *num_siblings  IGRint	       output number of siblings
   **siblings     struct GRid          output siblings (will be malloced
                                       or "buff" used if large enough)
   num_buff       IGRint               number of GRid in "buff" being supplied
                                       to be used for output memory
                                       for "siblings"
   *buff          struct GRid          the buffer

Return Values
   MSSUCC  if successful
   MSFAIL  if failure
\*/
method GRget_siblings (IGRlong *msg; IGRushort opts;
                        IGRint *num_siblings; struct GRid **siblings;
                        IGRint num_buff; struct GRid *buff)
{
	IGRint 		status;
	register IGRint	i;
	IGRlong 	retmsg;
        IGRint          NbCpts=0;
	IGRint		NbNei=0,NbHangers=0;
	struct GRid	*pSibIds,OwnerId;
	struct GRmd_env	md_env;
	IGRboolean	bIAmConnector=FALSE;

        SetProc( VRGeneric_GRget_siblings ); Begin
	*msg = MSSUCC;
	*num_siblings=0;

	{/* get module env  and number of cpts */
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

                status =
                om$send ( msg = message VRGeneric.VRGetNumberOfCpts
                                       ( &retmsg, &NbCpts, &md_env ),
                     targetid = my_id);
	}/* end get module env */

	/* ------------------------------ */
	/* -- get number of neighbours -- */
	/* ------------------------------ */
	status =
	om$send ( msg = message VRGeneric.VRGetNeighbors
			( msg, 0, NbCpts, &NbNei, NULL, NULL, &md_env ),
		targetid = my_id );
	as$status ();

        /*" %d neighbors found \n",NbNei */

	/* ---------------------------- */
	/* -- get number of supports -- */
	/* ---------------------------- */

	status =
	om$send ( msg = message VRGeneric.VRGetHangers
			( msg, 0 , NULL, &NbHangers,NULL,&md_env ),
		targetid = my_id );
	as$status ();

	/*" %d hangers found \n",NbHangers */

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
	/*A Compute total number of sibblings */

	*num_siblings = NbNei + NbHangers;

	/*Kludge : if I am a Nozzle or a connector, my equipment
		   must also be returned */
	/*	   This method should be overriden in the nozzle/connector
		   class itself */
	{
		GRclassid MyClassId;

		/*C Get my class */
		om$get_classid (objid = my_id,
				p_classid = &MyClassId );

/*	I/ROUTE 2.3.2 build
		if ( 	om$is_ancestry_valid
				( subclassid   = MyClassId,
				  superclassid = OPP_VRConnect_class_id )
		     == OM_S_SUCCESS 			 ||		
*/
		if (	om$is_ancestry_valid
				( subclassid   = MyClassId,
				  superclassid = OPP_VRNozzle_class_id )
		     == OM_S_SUCCESS)
		{

			/*C If I am VRNozzle or VRConnect : I have one more
			    sibling : my equipment */
			*num_siblings += 1;
			bIAmConnector = TRUE;
		}

	}/* end of kludge for connectors */

	if ( *num_siblings > num_buff ) 
	{
		/*| buffer has to be allocated */

		*siblings = NULL;
		*siblings = _MALLOC (*num_siblings , struct GRid);
		if ( !(*siblings) )
                {
                  End
                  return OM_E_NODYNMEM;
                }                  
		pSibIds = *siblings;
	}
	else
	{
		/*| No malloc needed */
		*siblings = buff;
	}


	/* ------------------- */
	/* -- get neighbors -- */
	/* ------------------- */
	status =
	om$send ( msg = message VRGeneric.VRGetNeighbors
			( msg, 0, NbCpts, &NbNei, *siblings, NULL, &md_env ),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/* -- get neighbors' owners -- */
	for (i=0; i<NbNei; i++)
	{
		/* Fix for TR # 1795246. Check if the Siblings Id is NULL. 
		 * This fix is for supressing the error messages in 
		 * ASsupport.I
		 */
		if( (*siblings)[i].objid == NULL_OBJID ) continue;
		
		ASget_as_owner ( &(*siblings)[i],&OwnerId); 

		if ( OwnerId.objid != NULL_OBJID ) (*siblings)[i] = OwnerId;
	}
	/* ------------------ */
	/* -- get supports -- */
	/* ------------------ */
	status =
	om$send ( msg = message VRGeneric.VRGetHangers
		( msg, NbHangers, &(*siblings)[NbNei], &NbHangers,NULL,&md_env ),
		targetid = my_id );
	as$status ( action = RET_STATUS );


	/* ---------------------- */
	/* -- return Equipment -- */
	/* ---------------------- */

	if ( bIAmConnector )
	{
		struct GRid     Loc_Id;
		struct GRid     Eqp_Id;
		GRclassid	ParentClassId;

		Loc_Id.objid = NULL_OBJID;
		Loc_Id.osnum = OM_Gw_current_OS;
		Eqp_Id.objid = NULL_OBJID;
		Eqp_Id.osnum = OM_Gw_current_OS;


		/*A     find parent id      */

		status =
		om$get_objid_at_index ( object          = me,
					p_chanselect    = &ND_father,
					index           = (IGRint) me->nNbAttr,
					objidaddr       = &Loc_Id.objid,
					osnumaddr       = &Loc_Id.osnum);
		if ( !(status&1) )
                {
                  End
                  return status;
                }

		om$get_classid (objid = Loc_Id.objid,
				osnum = Loc_Id.osnum,
				p_classid = &ParentClassId );

		if ( 	om$is_ancestry_valid
				( subclassid   = ParentClassId,
				  superclassid = OPP_ACpretend_class_id )
		     == OM_S_SUCCESS)
		{
			IGRint		count;

			status =
			om$send(msg = message NDnode.NDget_objects
				(ND_ROOT, &(*siblings)[(*num_siblings)-1], 1, NULL,0, 0, &count),
				targetid = Loc_Id.objid,
				targetos = Loc_Id.osnum);
			as$status( action = RET_STATUS );

		}/* end of pretend */
		else
		{
		       (*siblings)[(*num_siblings)-1] = Loc_Id;

		}/* end direct connection */

	}/* end of kludge treatment for nozzles & connectors */

End
return OM_S_SUCCESS;

}/* end GRget_siblings */

method ACreturn_foot(IGRlong *msg;char *footname;     
		struct GRid *foot_obj;IGRshort *mat_type;IGRdouble *matrix)
{
	IGRint	status,i;

/*        SetProc( VRGeneric_ACreturn_foot ); Begin */
	*msg = MSSUCC;

	status =
	om$send ( msg = message ACncpx.ACreturn_foot
			( msg, footname, foot_obj, mat_type, matrix),
		mode = OM_e_wrt_message,
		targetid = my_id );
	if ( !(*msg & 1 & status) )
	{
		OM_S_CHANSELECT chansel;

		chansel.type       = OM_e_name;
		chansel.u_sel.name = "father";

		for ( i=0; (i<me->nNbAttr) && !(status & *msg & 1); i++ )
		{
			status=
			om$send ( msg = message NDmacro.ACreturn_foot
				( msg, footname, foot_obj, mat_type, matrix),
			p_chanselect= &chansel,
			from	    = i,
			to	    = i);
		/*" Collection %d : status = %d, msg = %d\n",i, status, *msg */

		}/* end loop on collections */

	}/* end send it back to collections templates */

/* End  */
return (status);

}/* end ACreturn_foot */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*              KLUDGE: override     method NDget_objects                             
/*
/*  DESCRIPTION: While in dynamics, avoid returning the list of children
/*		to avoid copy of ROUTE network.
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method NDget_objects(int type;struct GRid *list;int size;struct GRid **buffer;
		       int ifrom,ito,*count)
{
	IGRint			status;
	extern IGRboolean 	dynamics_in_progress;

/*        SetProc( VRGeneric_NDget_objects ); Begin */
	if (type & ND_CHILDREN)
	{
		/*| Children queried */

		if ( dynamics_in_progress )
		{
			 /*| No children returned */
			*count=0;
/*                        End  */
			return OM_S_SUCCESS;
		}

	}/* end dynamics managment */

	/*| Normal behaviour */
	status =
	om$send ( msg = message ACncpx.NDget_objects
			( type, list, size, buffer, ifrom, ito, count ),
		  mode = OM_e_wrt_message,
		  targetid = my_id );
/*        End  */
	return status;

}/* end NDget_objects */



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*              override     method GRxform                            
/*
/*  DESCRIPTION: A component is allowed to move if is not attached to any topology.
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method GRxform(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid )
{

	IGRint	status;

        SetProc( VRGeneric_GRxform ); Begin
	*msg = MSSUCC;
	if (!me->nNbTopo)
	{
		OM_S_CHANSELECT		chansel;

		chansel.type       = OM_e_name;
		chansel.u_sel.name = "GRcmpowner.to_components";

		/*| No topological attachement to a network */
		/* -- Send xform to the graphics -- */

		status =
		om$send ( msg = message GRgraphics.GRxform
				( msg, md_env, matrix_type, matrix, newobjid ),
		     p_chanselect = &chansel);

		status =
		om$send( msg = message NDnode.NDchange_node ( md_env ),
			targetid = my_id);
		as$status(action = RET_STATUS);

		/**
                  status =
                  om$send( msg = message NDnode.NDchange_node ( md_env ),
                          targetid = my_id);
                  as$status(action = RET_STATUS);
		 **/

                /*
                 * execute foot to recompute dependencies of foot
                 */
                {

                  struct GRid   obj ;

                  obj.objid = my_id;
                  obj.osnum = OM_Gw_current_OS;
                  nd$wait_batch(type    = GR_GEOM_POSTED,
                                nb_obj  = 1,
                                l_object= &obj );
                  nd$exec_batch();
                 }

		*newobjid = my_id;
	}
	else
	{
		/*| Normal behaviour */
		status =
		om$send ( msg = message ACncpx.GRxform
				( msg, md_env, matrix_type, matrix, newobjid ),
			  mode = OM_e_wrt_message,
			  targetid = my_id );

	}/* end Normal behaviour */

        End
	return status;

}/* end GRxform */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*              override     method    ACgive_structure                         
/*
/*  DESCRIPTION: An attribute belonging to the templates should be returned
/*		as if it were prt of the component.
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method ACgive_structure(int *msg; int *direct_index; char *Ofootname;
                        struct ret_struct *p_rs;
			struct GRmd_env *md_env)

{
	IGRint			status=OM_S_SUCCESS,i;
	IGRlong			retmsg;
	IGRchar			footname[100];
	/* Needed at differente places */
	struct ret_struct	ParamAttr;
	IGRint 			FootIndex = -1;

/* SetProc( VRGeneric_ACgive_structure ); Begin */
*msg=MSSUCC;

		/*"---- %s ----\n",me->szAABBCC */

/*A KLUDGE : treate width_g width_r .... as width_1, width_2 ... */

if ( !(strcmp ( Ofootname, "width_g")) )
{	/*| width_g -- width_1 */
	strcpy ( footname, VR_N_WIDTH1_DB);
}
else
if ( !(strcmp ( Ofootname, "width_r")) )
{	/*| width_r -- width_2 */
	strcpy ( footname, VR_N_WIDTH2_DB);
}
else
if ( !(strcmp ( Ofootname, "depth_g")) )
{	/*| depth_g -- depth_1 */
	strcpy ( footname, VR_N_DEPTH1_DB);
}
else
if ( !(strcmp ( Ofootname, "depth_r")) )
{	/*| depth_r -- depth_2 */
	strcpy ( footname, VR_N_DEPTH2_DB);
}
else
if ( !(strcmp ( Ofootname, "cs")) )
{	/*| depth_r -- depth_2 */
	strcpy ( footname, VR_N_REF_CS);
}
else
{	/*| keep foot name */
	strcpy ( footname, Ofootname);
}

/* END KLUDGE */

/*A Return known feet : ref, ...*/

/* "Footname= %s \n", footname  */
 
if ( !(strcmp (footname, VR_N_COMP_CODE_AN)) )
{
	p_rs->type= text_type;
	status = om$send 
	( msg = message VRGeneric.VRGetCode
		( &retmsg, p_rs->var.text_st.text_string ),
	targetid = my_id );
}
else if ( !(strcmp (footname, VD_N_TAG_NUMBER_AN)) )
{
	p_rs->type= text_type;
	strcpy (p_rs->var.text_st.text_string, me->szNumber);
}
else if ( !(strcmp (footname, VD_N_COMP_NOTE_AN)) )
{
	p_rs->type= text_type;
	strcpy (p_rs->var.text_st.text_string, me->szNotes);
}
else if ( !(strcmp (footname, VD_N_NO_MTO_FLAG_AN )) )
{
	p_rs->type= text_type;
	p_rs->var.text_st.text_string[0]= me->cNoMtoFlg;
	p_rs->var.text_st.text_string[1]= '\0';
}   
else if ( !(strcmp (footname, VD_N_ERR_CMP_FLAG_AN)) )
{
	p_rs->type= text_type;
	if(me->Status&VR_ERROR) p_rs->var.text_st.text_string[0] = 'Y';
	else			p_rs->var.text_st.text_string[0] = 'N';
	p_rs->var.text_st.text_string[1] = '\0';
}
else  if ( !(strcmp (footname, VR_N_REF_CS)) )
{
	p_rs->type= ref_generic;

	if ( me->Status&VR_EVALUATE )
	{
		/*| No Topologic templates -> Return identity matrix */
		MAidmx ( &retmsg, p_rs->var.ref_st.t );

	}/* end return dummy matrix */
	else
	{

		status =
		om$send ( msg = message VRGeneric.VRGetMatrix
					( &retmsg,0,NULL,
					  p_rs->var.ref_st.t, md_env ),
			targetid = my_id);
		as$status ();
	}/* end return referential */

	if ( bVR_IS_PID(me->xform_chan) && !(me->Status&VR_CORRECTION) )
	{

		/* -- Get scale factor -- */

		status=
		om$send ( msg 	= message ACncpx.ACgive_structure 
			(msg, &FootIndex, VD_N_SCH_SCALE_DB, &ParamAttr, md_env),
			targetid= my_id);
		if ( ! ( status&(*msg)&1 ) )
		{
			*msg = MSSUCC;
			status = OM_S_SUCCESS;
			ParamAttr.var.root_pm_st.value=1;
			/*printf ("PID scale not found\n"); */

		}

		/*"Rescale to %f\n", ParamAttr.var.root_pm_st.value  */

		/* -- Scale matrix (x,y,z) -- */
		for (i=0; i<3; i++)
		{
		p_rs->var.ref_st.t[i]   *= ParamAttr.var.root_pm_st.value;
		p_rs->var.ref_st.t[i+4] *= ParamAttr.var.root_pm_st.value;
		p_rs->var.ref_st.t[i+8] *= ParamAttr.var.root_pm_st.value;
		}
	}/* end scale referencial */

}
else if( (me->Status & VR_GR_DEPENDANT) && 
	!(strcmp (footname, VD_N_SCH_SCALE_DB)) )
{
	OM_S_CHANSELECT chansel;
	struct GRid	TempId;

	/*A For graphics dependant objects (e.g. schematics connectors)
	    Get scale from the template */

	chansel.type       = OM_e_name;
	chansel.u_sel.name = "father";

	/*C Template is supposed to be the first one after the attributes */
	status =
	om$send (msg = message ACpretend.ACfind_parent
                                 (&TempId, NULL, NULL),
		p_chanselect 	= &chansel,
		from		= me->nNbAttr,
		to		= me->nNbAttr);
	if ( !(status&1) )
	{
		/*C not connected via Pretend */
	status=
	om$send (msg = message ACncpx.ACgive_structure 
			(msg, direct_index, footname, p_rs, md_env),
		p_chanselect 	= &chansel,
		from		= me->nNbAttr,
		to		= me->nNbAttr);
	}
	else
	{
		/*C Got object from the pretend */
	status=
	om$send (msg = message ACncpx.ACgive_structure 
			(msg, direct_index, footname, p_rs, md_env),
		targetid = TempId.objid,
		targetos = TempId.osnum );
	}

}/* end VD_N_SCH_SCALE_DB only for graphic dependancy */
else if ( !(strcmp (footname, VR_N_NB_CONNECT_IN)) )
{
	IGRint	NbCpts;

	p_rs->type= double_type;

	/*C Get number of connection points */
	status =
	om$send (msg = message VRGeneric.VRGetNumberOfCpts
			(&retmsg, &NbCpts, md_env),
		targetid = my_id );
	if ( !(status&1) || (retmsg != MSSUCC) ) 
	{
		/* Failure ? */
		p_rs->var.root_pm_st.value= 0;
	}
	else
	{
		p_rs->var.root_pm_st.value= NbCpts;
	}
	
}/* end VR_N_NB_CONNECT_IN */
else if ( !(strcmp (footname, VR_N_LOC_PT)) )
{
	p_rs->type= point_generic;
	status =
	om$send (msg      = message VRGeneric.VRGetOrigCoor
			( &retmsg, p_rs->var.point_st.pt, md_env) ,
		targetid = my_id );
	as$status(action = RET_STATUS);

}
else if ( !(strcmp (footname, VD_N_AUTO_ID_AN)) )
{
	IGRint			Behavior=0;
	IGRdouble		Id;
	IGRchar			*sEnd=NULL;

	/*A get the behaviour type for this entity */
	status =
	om$send (msg      = message VRGeneric.VRGetCatBehavior(
			&retmsg, NULL, &Behavior),
		targetid = my_id );
	as$status();

	p_rs->type= text_type;
	if ( Behavior == 0 )		/* no management required */
	{ 
		/*A no id management is required */
		strcpy( p_rs->var.text_st.text_string, "-1" );
		/* p_rs->var.root_pm_st.value= -1;	*/
	} else if (  Behavior == 1 )	/* manage line seq num */
	{
		/*A get the line seq number */
		status = 
		om$send( msg      = 
			message ACncpx.ACgive_structure( msg, 
				&FootIndex,
				VR_N_SEQ_NUMBER_AN,
				&ParamAttr, 
				md_env),
			targetid = my_id);
		as$status();
		if ( ! (status & 1 & *msg ) )
                {
                  /*End */
                  return status;
                }

		strcpy( p_rs->var.text_st.text_string, 
			 ParamAttr.var.text_st.text_string);

		Id = strtod (ParamAttr.var.text_st.text_string, &sEnd);
		if ( strlen (sEnd) )
			/*A return ERROR */
			strcpy( p_rs->var.text_st.text_string, "-1" );

	} else if ( Behavior == 2 )	/* manage tag num */
	{
		/*A return the tag number */
		Id = strtod (me->szNumber, &sEnd);
		if ( strlen (sEnd) )
			/*A return ERROR */
			strcpy( p_rs->var.text_st.text_string, "-1" );
		else
			/*A return the tag number*/
			strcpy( p_rs->var.text_st.text_string, me->szNumber );
	}
}

else if ( !(strcmp (footname, VD_N_ID_CATEGORY_IN )) )
{
	IGRlong		retmsg;
	IGRint		Category;

	p_rs->type= double_type;

	/*A get the category */
	status =
	om$send (msg      = message VRGeneric.VRGetCatBehavior(
			&retmsg, &Category, NULL),
		targetid = my_id );
	as$status();

	p_rs->var.root_pm_st.value = (double)Category;
}

else if ( !(strcmp (footname, VD_N_BEHAVIOUR_IN )) )
{
	IGRlong		retmsg;
	IGRint		Behavior;

	p_rs->type= double_type;
	/*A get the behavior from the tables */
	status =
	om$send (msg      = message VRGeneric.VRGetCatBehavior(
			&retmsg, NULL, &Behavior),
		targetid = my_id );
	as$status();

	p_rs->var.root_pm_st.value = (double)Behavior;
}
else if ( !(strcmp (footname, "functional_id" )) )
{
	IGRchar	szTmp[10];

	p_rs->type= text_type;
	p_rs->var.text_st.text_string[0] = 0;

	status=
	om$send( msg      = 
	message ACncpx.ACgive_structure( msg, 
		&FootIndex,
		VD_N_SYSTEM_NAME_AN,
		&ParamAttr, 
		md_env),
	targetid = my_id);
	if ( (status & 1 & *msg ) )
		strcpy ( p_rs->var.text_st.text_string,
			ParamAttr.var.text_st.text_string );

	/*C Add the category */
	status=
	om$send( msg      = 
	message ACncpx.ACgive_structure( msg, 
		&FootIndex,
		VD_N_ID_CATEGORY_IN,
		&ParamAttr, 
		md_env),
	targetid = my_id);
	if ( (status & 1 & *msg ) )
	{
		sprintf (szTmp, "%d",(IGRint)ParamAttr.var.root_pm_st.value);
		strcat ( p_rs->var.text_st.text_string, szTmp);
	}
	/*C Add the tag number */
	status=
	om$send( msg      = 
	message ACncpx.ACgive_structure( msg, 
		&FootIndex,
		VD_N_TAG_NUMBER_AN,
		&ParamAttr, 
		md_env),
	targetid = my_id);
	if ( (status & 1 & *msg ) )
		strcat ( p_rs->var.text_st.text_string,
			ParamAttr.var.text_st.text_string );


}/* end of functional_id */
else
{
	/*A If not found in the "known feet" :
	Redirect the message to the collections templates */

	OM_S_CHANSELECT chansel;
	IGRint		NbRoots = 0;
	struct GRid     *buffer = NULL;

	chansel.type       = OM_e_name;
	chansel.u_sel.name = "father";

/*-----------------
* KDD May '98. TR179801102. Core dump. Object has no parents. Corrupted file.
* ah  06/02/98 Sometimes it's ok, transient equipment sometimes get here
*              without collectors during move operations
-----------------*/

        status = om$send( msg     = message NDnode.NDget_objects( 
					ND_ROOT | ND_IN_BUF, NULL, 0, &buffer, 
					0, OM_K_MAXINT, &NbRoots),
                        targetid = my_id);

	if ( NbRoots < me->nNbAttr ) { 
#if 0
	   char 	text[256];

	   sprintf(text,"ERROR: Route Component [%d,%d] is missing parent collectors.",
				my_id, OM_Gw_current_OS);

	   vd$report_error( mode = 1, error = text);
#endif

	   /* ---------------------------------------------------
	    * 06/02/98 ah
	    * Note that this needs to return success even though
	    * nothing was found otherwise predefined attributes such
	    * as flow_rate will cause an infinite loop
	    *
	    * Returning an empty text string seems safest
	    * Unknown might be better
	    */
	   p_rs->type= text_type;
	   *p_rs->var.text_st.text_string = 0;
	   
	   status = OM_S_SUCCESS;
	   goto wrapup;
	}

	/*| Try in ATTRIBUTES collections */
	for ( i=0, status=0; (i<me->nNbAttr) && 
				(status != OM_S_SUCCESS || !(*msg & 1)); i++ )
	{
		status=
		om$send (msg = message ACncpx.ACgive_structure 
				(msg, direct_index, footname, p_rs, md_env),
			p_chanselect= &chansel,
			from	    = i,
			to	    = i);
		/*" Collection %d : status = %d, msg = %d\n",i, status, *msg */

	}

	if ( !(me->Status & VR_EVALUATE) && (status != OM_S_SUCCESS || !(*msg & 1)) )
	{
		/*A If not found in the templates : try the ACncpx feet management */
	        /* 04/08/98 Pass to VDSroot instead, ah */
		status=
		om$send (msg = message VDSroot.ACgive_structure 
				(msg, direct_index, footname, p_rs, md_env),
			mode = OM_e_wrt_message,
			targetid = my_id);
		/*" status = %d, msg = %d\n", status, *msg */

		if ( !(status & *msg & 1) )
		{
			/* Try in DB Collection */

		}/* end try in DB attributes */

	}/* end try OM_e_wrt_message */
}

wrapup:

/* End */
return ( status );

}/* end ACgive_structure */

method ACgive_db_structure(int *msg,*direct_index;char *footname;
                struct ret_struct *p_rs;struct GRmd_env *md_env)

{
	IGRint	status;

	/*A Try in dynamic attributes */
/*        SetProc( VRGeneric_ACgive_db_structure ); Begin  */
	status=
	om$send (msg = message ACncpx.ACgive_structure 
			(msg, direct_index, footname, p_rs, md_env),
		targetid = my_id);
	/*" status = %d, msg = %d\n", status, *msg */

	/*C Dynamic attribute found */
	if ( (status & *msg & 1) )
        {
/*          End  */
          return status;
        }



	/*A Try in static attributes */
	{
	struct GRid 	StaticId;
	IGRlong		retmsg;
	IGRint		stat1;

	/*C save status of previous call to ACgive_structure */
	stat1=
	om$send (msg = message VRGeneric.VRGetModel
			(&retmsg, &StaticId, md_env),
		targetid = my_id);
	if ( !(stat1&1) )
        {
/*          End  */
          return status;
        }

	status=
	om$send (msg = message ACncpx.ACgive_structure 
			(msg, direct_index, footname, p_rs, md_env),
		targetid = StaticId.objid,
		targetos = StaticId.osnum );
/*        End  */
	return status;

	}/* end look in static attributes */

}/* end ACgive_db_structure */

/*
/* overriden by STRUCT 

method NDdrawing_copy_geom(     struct GRid     *selected_elements ;
				int             nb_elements ;
				struct GRid     **outList ;
				int             *outCount ;
				double          *vector,
						*point ;
				int             *levelMask ;
				struct IGRlbsys *lbsys ;
				struct GRmd_env *from_env,
						*to_env )
{

return OM_S_SUCCESS;


}
*/

end implementation VRGeneric;
