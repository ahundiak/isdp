/* $Id: VDhdr_loc.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / VDhdr_loc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDhdr_loc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation VDrelat_hdr;

#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grerr.h"
#include "exdef.h"
#include "grsymdef.h"
#include "bserr.h"

#include "exdef.h"
#include "exmacros.h"

#define	AS_DEBUG

#define	ACS_CMP_LEAVE		0x3
#define	ACS_NO_VALID_PATH	'\007'

struct	ACSrel_handl_info
{
	IGRint			(*user_func)();
	IGRchar			*user_info;
	struct	GRid		escape_mac;
};

struct	ACSdyn_info
{
	struct	GRid		feet_id;
	struct	GRid		header;
	struct	GRlc_info	obj_loc;
	struct	GRid		clone;
};

/* ******************* FCT ACrel_header_handl () **************************	*/
/* create a tf_foot during locate (and before accept/reject by user) 	*/

IGRint ACrel_header_handl( act_parms, new_entry, locate_args, action )

struct	ACSrel_handl_info	*act_parms;    /* Parameters for the selection criteria    */
struct	GRlc_info	*new_entry;    /* Information for the graphic object       */
struct	LC_action_args	*locate_args; /* quelque chose 		      */
IGRchar			*action;

/*.ACrel_header_handl*/
{
extern	struct	ACSdyn_info	ACSdyn_tf_foot_info;

IGRlong		sts;

	/*| initialization */
	sts = OM_I_STOP_SENDING;

	/*" loc obj : id/os = (%d/%d)\n", new_entry->located_obj.objid, new_entry->located_obj.osnum */
	/*" escape_mac : %d/%d\n", act_parms->escape_mac.objid, act_parms->escape_mac.osnum */

	if( new_entry->located_obj.objid == act_parms->escape_mac.objid &&
		new_entry->located_obj.osnum == act_parms->escape_mac.osnum ){

		/*| reject gr_model */
		return	GR_I_NO_RESPONSE;
	}

	/*" md_os %d \n", new_entry->module_info.md_id.osnum */
	/*^pr_mat("loc_obj_mat",4,4,new_entry->module_info.md_env.matrix);*/

	/*| set global variable */	
	ACSdyn_tf_foot_info.obj_loc = *new_entry;

	/*" user hand : %d\n", act_parms->user_func */
	if( act_parms->user_func != NULL ){

		/*| action_handler user */
		sts = act_parms->user_func(	act_parms->user_info,
						new_entry,
						locate_args,
						action );
	}

return	sts;
}

/* ************ MSG GRlocate () ***************************************	*/

method GRlocate( struct	GRlc_cvl *cvl; OM_p_KEY_DESC range_key )

{
IGRlong		msg, sts;
IGRint		nb_feet;
struct	GRid	*feet_list;
IGRint		i;

struct	GRlc_cvl	my_cvl;

struct	GRid		*loc_obj;
struct	GRid		tf_foot;
IGRint			loc_resp;
OM_S_OBJID		*cmp_list;
IGRint			list_len;
IGRint			nb_cmp;
IGRint			j;
IGRint			resp;

struct	ACSrel_handl_info	my_act_ptr;

extern	IGRint			ACSloc_symb;
extern	struct	ACSdyn_info	ACSdyn_tf_foot_info;

struct	tf_foot			my_tf_foot;
struct	ACSdyn_info		dyn_info;
struct	GRlc_info		*loc_info;
struct	GRid			my_grid;
struct	GRid			model;

extern	struct GRid	ACSinitial_context;
extern	struct GRid	ACSinitial_symbol;

extern	struct	GRmd_env	ACScreate_mod;
extern	IGRint			ACrel_header_handl();

IGRlong	ACSget_abs_matrix();
struct	GRid		my_as;

	/*| initialization */
	feet_list	= NULL;
	cmp_list	= NULL;
	my_grid.objid	= my_id;
	my_grid.osnum	= OM_Gw_current_OS;

	/*| send locate for this level */
	sts = om$send(	msg	 = message GRvg.GRlocate(
					cvl,
					range_key ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg GRlocate" );

	/*| check action to perform after header locate */
	if( sts == OM_I_STOP_SENDING ){
		/*" accepte locate of header : id/os = (%d/%d)\n", my_id, OM_Gw_current_OS */
		return	sts;
	}

	if( ! (cvl->attributes.obj_attr.owner_action & 1) ){
		/*| do not locate rigid */
		/*" locate owner_action : %d\n", cvl->attributes.obj_attr.owner_action */
		return	sts;
	}

	if( cvl->msg == GR_I_OUTSIDE_TOL || cvl->msg == MSFAIL ){
		/*| no cmp is acceptable */
		return	sts;
	}

	/*" cvl->attributes.type : %d\n", cvl->attributes.type */
	if(	( cvl->attributes.type == GR_rp_loc ) ||
		( cvl->attributes.type == GR_cv_loc ) ||
		( cvl->attributes.type == GR_crit_loc ) ||
		( cvl->attributes.type == GR_nam_loc ) ){
		/*| my component are not eligible for prims locate */
		return sts; 
         }

	/* ********** Copy mode and HEADER IS NOT ACCEPT ********** */

	/*| initialization */
	my_cvl		= *cvl;

	sts = om$send(	msg	 = message ACheader.ACget_share_feet_list(
					&msg,
					0,
					NULL,
					&nb_feet ),
			targetid = my_id );
	as$status( sts = sts );
	/*" nb feet : %d\n", nb_feet */

	feet_list = (struct GRid *) malloc( sizeof( struct GRid ) * nb_feet );
	if( feet_list == NULL ){
		printf(" Error not enougth memory to allocate feet_list\n");
		return	OM_E_ABORT;
	}

	sts = om$send(	msg	 = message ACheader.ACget_share_feet_list(
					&msg,
					nb_feet,
					feet_list,
					&nb_feet ),
			targetid = my_id );
	as$status( sts = sts );

/*^	pr_mat(" locate matrix", 4, 4, cvl->module.md_env.matrix); */

	sts = ACSget_abs_matrix( my_grid, my_cvl.module.md_env.matrix );
	as$status( sts = sts );
	MAtypemx( &msg, my_cvl.module.md_env.matrix, 
				&my_cvl.module.md_env.matrix_type );

/*^	pr_mat(" my locate matrix", 4, 4, my_cvl.module.md_env.matrix); */

	loc_info	= &my_cvl.locate_args->loc_select_args->
						acc_event1->located_object[0];
	loc_obj		= &loc_info->located_obj;

	list_len	= 20;
	cmp_list = (OM_S_OBJID *) malloc( sizeof( OM_S_OBJID ) * list_len );
	if( cmp_list == NULL ){
		printf(" Error not enougth memory to allocate cmp_list\n");
		sts	= OM_E_ABORT;
		goto	wrapup;
	}

	ACset_disthruref();


	/*| find leave and locate */
	for( i=0; i<nb_feet; i++ ) {

		loc_obj->objid = NULL_OBJID;
		loc_obj->osnum = OM_Gw_current_OS;

		cmp_list[0] = feet_list[i].objid;


		/*| set global data for make_source */
		if(!ACSloc_symb)
		 {
		  ACSinitial_symbol.objid = my_id;
		  ACSinitial_symbol.osnum = OM_Gw_current_OS;
 		  sts = GRfindcontext( &msg, &cvl->module.md_env.matrix_type,
                     		   cvl->module.md_env.matrix, &OM_Gw_current_OS,
							  &ACSinitial_context );
 		  if(sts != OM_S_SUCCESS || msg != MSSUCC )
				         ACSinitial_context.objid = NULL_OBJID;
		  ACScreate_mod.md_env.matrix_type = MAIDMX;
		  MAidmx(&msg,ACScreate_mod.md_env.matrix);
		  ACScreate_mod.md_id.objid = NULL_OBJID;
		  ACScreate_mod.md_id.osnum = OM_Gw_current_OS;
		  
		  ACSloc_symb = 1;
		 }
	
	        {

		sts = ACSget_abs_matrix( my_grid, ACScreate_mod.md_env.matrix );
		as$status( sts = sts );
		MAtypemx( &msg, ACScreate_mod.md_env.matrix, 
					&ACScreate_mod.md_env.matrix_type );

                }
		ACSdyn_tf_foot_info.feet_id		= feet_list[i];
		ACSdyn_tf_foot_info.header.objid	= my_id;
		ACSdyn_tf_foot_info.header.osnum	= OM_Gw_current_OS;
		ACSdyn_tf_foot_info.clone.objid		= NULL_OBJID;
		ACSdyn_tf_foot_info.obj_loc.module_info	= my_cvl.module;
		ACSdyn_tf_foot_info.obj_loc.located_obj.objid	= NULL_OBJID;

		/*| init handler */
		my_act_ptr.user_func	= my_cvl.action_handler;
		my_act_ptr.user_info 	= my_cvl.act_parms;

		my_as.objid = NULL_OBJID;
		ASget_as_owner( &feet_list[i], &my_as );
		my_act_ptr.escape_mac	= my_as;
		my_cvl.action_handler	= ACrel_header_handl;
		my_cvl.act_parms	= (IGRchar *)&my_act_ptr;

		nb_cmp	= 1;

		for( j=0; j<nb_cmp; j++ ){

			/*| find locatable object */
			resp = ACSget_cmp_leave(	OM_Gw_current_OS,
							j,
							&list_len,
							&cmp_list,
							&nb_cmp );
			if( ! resp ){
				sts 	= OM_E_ABORT;
				goto	wrapup;
			}

			if( resp == ACS_CMP_LEAVE ){

				/*" locate leave : id = %d\n", cmp_list[j] */
				/*" locate feet[%d] : id/os = (%d/%d)\n", i, feet_list[i].objid, feet_list[i].osnum */
				sts = om$send(	msg	 = 
					message GRgraphics.GRlocate(
							&my_cvl,
							range_key ),
					targetid = cmp_list[j] );
				/* as$status( sts = sts ); */

				if( sts == OM_I_STOP_SENDING )	break;
			}

		}/*end locate leave*/

		/*| Restore context */
		if((ACSinitial_symbol.objid == my_id) &&
		   (ACSinitial_symbol.osnum == OM_Gw_current_OS)) ACSloc_symb=0;
		my_cvl.action_handler	= my_act_ptr.user_func;
		my_cvl.act_parms	= my_act_ptr.user_info;

		loc_resp = *my_cvl.locate_args->loc_select_args->response;
		/*" ++++++ feet response = %d\n", loc_resp */

		if( loc_resp != DATA && loc_resp != RESET ){

			/*| exist of current locate */
			goto	wrapup;
		}

		if( sts != OM_I_STOP_SENDING )	continue;
/*^
		printf("\n LOCATE ACCEPTED\n");
		printf(" loc_obj : id/os = (%d/%d)\n", loc_obj->objid, loc_obj->osnum );
		printf(" OK feet[%d] : id/os = (%d/%d) is ok \n", i, feet_list[i].objid, feet_list[i].osnum );
*/

		/*| is tf_create */
		if( ACSdyn_tf_foot_info.clone.objid == NULL_OBJID ){

			/*| creation of the tf_foot */
			dyn_info.feet_id 	= feet_list[i];
			dyn_info.header.objid	= my_id;
			dyn_info.header.osnum	= OM_Gw_current_OS;
			dyn_info.clone.objid	= NULL_OBJID;
			dyn_info.obj_loc	= *loc_info;

			tf_foot.objid	= NULL_OBJID;
			sts = ACScreate_tf_foot( loc_obj, &tf_foot, &dyn_info );
			as$status( sts = sts );

			/*" tf_foot : id/os = (%d/%d)\n", tf_foot.objid, tf_foot.osnum*/

			/*| modif locate value */
			loc_info->located_obj	= dyn_info.clone;

			loc_info->module_info.md_id.osnum = tf_foot.osnum;
			loc_info->module_info.md_id.objid = NULL_OBJID;

			loc_info->module_info.md_env.matrix_type = MAIDMX;
			MAidmx( &msg, loc_info->module_info.md_env.matrix );

			ACSdyn_tf_foot_info.clone = dyn_info.clone;

		} else {
                        *loc_obj        = ACSdyn_tf_foot_info.clone;

			/*" loc_obj : id/os = (%d/%d)\n", loc_obj->objid, loc_obj->osnum */

			my_tf_foot.tf_id = *loc_obj;
			sts = om$send(	msg	 = message ACheader.ACget_name_of_tf_foot
							( &msg, &my_tf_foot ),
					targetid = my_id );
			as$status( sts = sts );

                      if( ACSinitial_symbol.objid != my_id &&
				my_tf_foot.tf_name[0] != ACS_NO_VALID_PATH ){

			/*| disconnect tf_id of last header */
			sts = om$send(	msg	= message Root.disconnect(
							AS_to_comp,
							my_tf_foot.tf_id.objid,
							my_tf_foot.tf_id.osnum,
							AS_to_owner ),
					targetid = my_tf_foot.foot.objid,
					targetos = my_tf_foot.foot.osnum );
			as$status( sts = sts );

			/*| modif symb of tf_foot */
			ACSset_tf_foot_symb( &my_grid, &my_tf_foot.tf_id );

			sts = om$send(	msg	 = message ACheader.ACfind_model
							( &msg, &model ),
					targetid = my_id );
			as$status( sts = sts );
			/*" model : id/os = (%d/%d)\n", model.objid, model.osnum */

			/*| get path */
			ACSget_part_path( &my_tf_foot, &model );
			/*" new path : %s\n", my_tf_foot.tf_name */

			if( my_tf_foot.tf_name[0] != ACS_NO_VALID_PATH ){

				/*| connect tf_foot to header */
				sts = om$send(	msg	 = message Root.connect(
							AS_to_owner,
							OM_K_MAXINT,
							my_id,
							OM_Gw_current_OS,
							AS_to_comp,
							OM_K_MAXINT ),
						targetid = my_tf_foot.tf_id.objid,
						targetos = my_tf_foot.tf_id.osnum );
				as$status( sts = sts, msg = "Error in connect to header" );

				my_tf_foot.foot.objid	= my_id;
				my_tf_foot.foot.osnum	= OM_Gw_current_OS;

			}

			/*| store tf_foot */
			sts = om$send(	msg	 = message ACheader.ACstore_tf_foot
							( &msg, &my_tf_foot ),
					targetid = my_id );
			as$status( sts = sts );

		  }
		 }

		/* Change matrix if necessary */
		/* to be able to create correct pretendin object */
		if(  (ACSdyn_tf_foot_info.clone.objid != NULL_OBJID)
		   &&(ACSinitial_context.objid        != NULL_OBJID)
		   &&(ACSinitial_symbol.objid 	      == my_id     )
		   &&(ACSinitial_symbol.osnum	      == OM_Gw_current_OS))
		  {
		   int iz;
		   loc_info->module_info.md_env.matrix_type
					       = cvl->module.md_env.matrix_type;
		   for(iz=0;iz<16;iz++)
		     loc_info->module_info.md_env.matrix[iz]
						= cvl->module.md_env.matrix[iz];
		  }
		sts = OM_I_STOP_SENDING;
		goto	wrapup;

	}/*end for feet*/

wrapup : 
	ACreset_disthruref();

	/*| free memory */
	if( feet_list != NULL )		free( feet_list );
	if( cmp_list != NULL )		free( cmp_list );

return	sts;
}

/* ***************** FCT ACSget_abs_matrix () *************************	*/

IGRlong	ACSget_abs_matrix( my_grid, abs_mat )

struct	GRid	my_grid;
IGRdouble	*abs_mat;

{
IGRlong		sts, msg;
struct	GRid	model;
IGRshort	id_type;
IGRdouble	id_mat[16];
IGRshort	new_type;
IGRdouble	new_mat[16];
IGRdouble	tmp_mat[16];
IGRshort	four;
IGRint		i;


	four	= 4;
	id_type	= MAIDMX;
	MAidmx( &msg, id_mat );

	sts = om$send(	msg	 = message GRowner.GRget_matrix(
					&msg,
					&id_type,
					id_mat,
					&new_type,
					new_mat ),
			targetid = my_grid.objid,
			targetos = my_grid.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );
	/*" my_grid : %d/%d, new_type : %d\n", my_grid.objid, my_grid.osnum, new_type */

	if( new_type != MAIDMX ){

		MAmulmx( &msg, &four, &four, &four, 
						abs_mat, new_mat, tmp_mat );
		for( i=0; i<16; i++ )	abs_mat[i] = tmp_mat[i];

		/*| get model */
		sts = om$send(	msg	 = message ACheader.ACfind_model
						( &msg, &model ),
				targetid = my_grid.objid,
				targetos = my_grid.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts, action = RET_STATUS );
		as$status( sts = msg, action = RET_STATUS );

		/*" model : %d/%d\n", model.objid, model.osnum */
		ACSget_abs_matrix( model, abs_mat );
	} 

return	OM_S_SUCCESS;
}

end implementation VDrelat_hdr;

