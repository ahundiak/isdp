/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation ACheader;

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

extern	GRclassid	OPP_ACcpx_class_id;
extern	GRclassid	OPP_ACheader_class_id;

struct	ACShandl_info
{
	IGRint			(*user_func)();
	IGRchar			*user_info;
};

struct	ACSdyn_info
{
	struct	GRid		feet_id;
	struct	GRid		header;
	struct	GRlc_info	obj_loc;
	struct	GRid		clone;
};



/* ***************** declaration of global var ***** */

struct	ACSdyn_info	ACSdyn_tf_foot_info;

%safe
IGRint			ACSloc_symb	= 0;
struct GRid		ACSinitial_context = { 0, (OM_S_OBJID)-1 },
			ACSinitial_symbol  = { 0, (OM_S_OBJID)-1 };
struct GRmd_env		ACScreate_mod;
%endsafe


/* ******************* FCT ACheader_handl () **************************	*/
/* create a tf_foot during locate (and before accept/reject by user) 	*/

IGRint ACheader_handl( act_parms, new_entry, locate_args, action )

struct	ACShandl_info	*act_parms;    /* Parameters for the selection criteria    */
struct	GRlc_info	*new_entry;    /* Information for the graphic object       */
struct	LC_action_args	*locate_args; /* quelque chose 		      */
IGRchar			*action;

/*.ACheader_handl*/
{
extern	struct	ACSdyn_info	ACSdyn_tf_foot_info;

IGRlong		sts;

	/*| initialization */
	sts = OM_I_STOP_SENDING;

	/*" loc obj : id/os = (%d/%d)\n", new_entry->located_obj.objid, new_entry->located_obj.osnum */
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


/* ****************** ACScreate_dyn_tf_foot () ************************	*/

ACScreate_dyn_tf_foot( loc_obj, tf_foot )

struct	GRid	*loc_obj;
struct	GRid	*tf_foot;

/*.ACScreate_dyn_tf_foot*/
{
IGRlong		sts;
extern struct	ACSdyn_info	ACSdyn_tf_foot_info;

	sts = ACScreate_tf_foot( loc_obj, tf_foot, &ACSdyn_tf_foot_info );

return	sts;
}


/* **************** ACSset_tf_foot_symb () ****************************	*/

ACSset_tf_foot_symb( header, tf_foot )

struct	GRid	*header;
struct	GRid	*tf_foot;

/*.ACSset_tf_foot_symb*/
{
IGRlong			sts,msg;
struct	GRsymbology	symb;
IGRshort		owner_prop;


	sts = om$send(	msg	 = message GRvg.GRgetsymb( &msg, &symb ),
			targetid = header->objid,
			targetos = header->osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );

	/*| put head level */
	sts = om$send(	msg	 = message GRvg.GRchglevel( &msg, &symb.level ),
			targetid = tf_foot->objid,
			targetos = tf_foot->osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );

	/*| get owner properties */
	sts = om$send(	msg	 = message GRowner.GRget_owner_properties
					( &msg, &owner_prop ),
			targetid = header->objid,
			targetos = header->osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );
	/*" owner_prop : %d\n", owner_prop */

	if( owner_prop & GR_SYM_DISPLAY_ATTR ){

		if( owner_prop & GR_SYM_COLOR ){

			/*| chg color */
			sts = om$send(	msg	 = message GRvg.GRchgcolor(
							&msg,
							0,
							&symb.display_attr.color ),
					targetid = tf_foot->objid,
					targetos = tf_foot->osnum,
					senderid = NULL_OBJID );
			as$status( sts = sts );
		}

		if( owner_prop & GR_SYM_WEIGHT ){

			/*| chg weight */
			sts = om$send(	msg	 = message GRvg.GRchgweight(
							&msg,
							&symb.display_attr.weight ),
					targetid = tf_foot->objid,
					targetos = tf_foot->osnum,
					senderid = NULL_OBJID );
			as$status( sts = sts );
		}

		if( owner_prop & GR_SYM_STYLE ){

			/*| chg style */
			sts = om$send(	msg	 = message GRvg.GRchgstyle(
							&msg,
							&symb.display_attr.style ),
					targetid = tf_foot->objid,
					targetos = tf_foot->osnum,
					senderid = NULL_OBJID );
			as$status( sts = sts );
		}
	}/*end chg display*/


return	OM_S_SUCCESS;
}

/* ******************* ACSget_part_path () ****************************	*/

ACSget_part_path( loc_foot, model )

struct	tf_foot		*loc_foot;
struct	GRid		*model;

/*.ACSget_part_path*/
{
IGRlong			sts, msg;
struct  GRid		as_own;
IGRchar                 tmp_path[path_MAX_CHAR];
IGRboolean		work_path;
struct  GRid		obj_base;
IGRint                  acs_save;
extern	IGRint		ACSloc_symb;
IGRboolean		path_created;
int			cr_ptr;

	/*| initialization */
	work_path	= TRUE;
	path_created	= FALSE;
	obj_base	= loc_foot->foot;
	as_own		= obj_base;
	cr_ptr		= 0;

	while( work_path ){

		/*" get_owner of obj_base : id/os = (%d/%d)\n", obj_base.objid, obj_base.osnum */
		as_own.objid	= NULL_OBJID;
//		ASget_as_owner( &obj_base, &as_own );
		ASget_mac_owner( &obj_base, &as_own, &cr_ptr );
//		printf(" as_own   : id/os = (%d/%d)\n", as_own.objid, as_own.osnum );

		if( as_own.objid == NULL_OBJID || 
				as_own.osnum != loc_foot->tf_id.osnum )	break;
		else {

			tmp_path[0] = '\0';
			sts = om$send(	msg	 = message ACcpx.ACgive_path(
							(IGRint *) &msg,
							&obj_base,
							tmp_path ),
					targetid = as_own.objid,
					targetos = as_own.osnum,
					senderid = NULL_OBJID );
			as$status( sts = sts );
			/*" tmp_path : %s\n", tmp_path */
		}

		if( tmp_path[0] == '\0' ) {

			work_path	= FALSE;
			path_created	= FALSE;

		} else {

			/*| store path */
			if( loc_foot->tf_name[0] == '\0' )
				strcpy( loc_foot->tf_name, tmp_path );

			else {

				sprintf( tmp_path, "%s:%s", tmp_path, 
							loc_foot->tf_name );
				strcpy( loc_foot->tf_name, tmp_path );
			}

			/*| set new value for while */
			obj_base	= as_own;
			path_created	= TRUE;
			/*" loc_foot->tf_name : %s\n", loc_foot->tf_name */

		  }
	}/*end while*/

	/*" path loc_foot->tf_name : %s\n", loc_foot->tf_name */

	if( ! path_created || as_own.osnum != loc_foot->tf_id.osnum ){
	
		/*| attach tf_id to a source with no path */
		loc_foot->tf_name[0] = ACS_NO_VALID_PATH;
		loc_foot->tf_name[1] = '\0';

		/*| construct attach a source */
		acs_save = ACSloc_symb;
		ACSloc_symb	= 0;
		as$make_source( go_grid	= loc_foot->tf_id,
				as_grid	= &loc_foot->foot,
				as_os   = loc_foot->tf_id.osnum );
		ACSloc_symb = acs_save;

		/*" transform support only as_grid : id/os = (%d/%d) \n", loc_foot->foot.objid, loc_foot->foot.osnum */
		sts = om$send(	msg	= message NDnode.NDchg_state
				( ND_DEL_NO_CH | ND_DONT_MVRT | ND_WAIT_DEL, 
				  ND_DEL_NO_CH | ND_DONT_MVRT | ND_WAIT_DEL),
				targetid = loc_foot->foot.objid,
				targetos = loc_foot->foot.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );
	}

return	OM_S_SUCCESS;
}

/* ****************** ACScreate_tf_foot () ****************************	*/

ACScreate_tf_foot( loc_obj, tf_foot, dyn_info )

struct	GRid		*loc_obj;
struct	GRid		*tf_foot;
struct	ACSdyn_info	*dyn_info;

/*.ACScreate_tf_foot*/
{
IGRlong			sts, msg;
struct	tf_foot		loc_foot;
struct	GRmd_env	loc_env;
IGRboolean		work_path;

struct	GRid		model;


	/*" loc_obj    : id/os = (%d/%d)\n", loc_obj->objid, loc_obj->osnum */
	/*" rel_select : id/os = (%d/%d)\n", dyn_info->obj_loc.located_obj.objid, dyn_info->obj_loc.located_obj.osnum*/

	if( loc_obj->objid != dyn_info->obj_loc.located_obj.objid ){

		/*" not valid object to create a tf_foot \n"*/
		*tf_foot	= *loc_obj;
		return	OM_S_SUCCESS;

	} else if( dyn_info->clone.objid != NULL_OBJID ){

		/*"clone exist : id/os = (%d/%d)\n",dyn_info->clone.objid, dyn_info->clone.osnum*/
		*tf_foot = dyn_info->clone;
		return	OM_S_SUCCESS;
	  }

	/*| initialization */
	work_path = TRUE;
	loc_foot.tf_id.osnum	= dyn_info->header.osnum;
	loc_foot.tf_id.objid	= NULL_OBJID;
	loc_foot.foot		= *loc_obj;
	loc_foot.tf_name[0]	= '\0';
	ex$get_cur_mod(id = &loc_env.md_id.objid,
		       osnum = &loc_env.md_id.osnum);

	loc_env.md_id.objid 	= NULL_OBJID;
	loc_env.md_id.osnum	= dyn_info->header.osnum; 
	MAidmx( &msg, loc_env.md_env.matrix );
	loc_env.md_env.matrix_type	= MAIDMX;

	/*" copy foot create a tf_foot in os %d\n", loc_env.md_id.osnum */
	sts = om$send(	msg	 = message GRgraphics.GRcopy(
					&msg,
					&ACScreate_mod,
					&loc_env,
					&loc_foot.tf_id.objid ),
			targetid = loc_foot.foot.objid,
			targetos = loc_foot.foot.osnum,
			senderid = NULL_OBJID );
	loc_foot.tf_id.osnum = loc_env.md_id.osnum;
	as$status( sts = sts );       
	/*" tf_id : id/os = (%d/%d)\n", loc_foot.tf_id.objid, loc_foot.tf_id.osnum */

	/*| use color and symbologie of header */
	ACSset_tf_foot_symb( &dyn_info->header, &loc_foot.tf_id );

	/*| create path between tf_id and header */
/*^
	printf(" loc_foot description av path \n");
	printf(" tf_if : id/os = (%d/%d)\n", 
				loc_foot.tf_id.objid, loc_foot.tf_id.osnum );
	printf(" foot  : id/os = (%d/%d)\n", 
				loc_foot.foot.objid, loc_foot.foot.osnum );
	printf(" name  : %s\n", loc_foot.tf_name );

	printf(" feet_id : id/os = (%d/%d)\n", 
			dyn_info->feet_id.objid, dyn_info->feet_id.osnum );
*/

	/*| generate path between base_obj and model */

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = dyn_info->header.objid,
			targetos = dyn_info->header.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );
	/*" model : id/os = (%d/%d)\n", model.objid, model.osnum */

	ACSget_part_path( &loc_foot, &model );
	/*" loc_foot.tf_name : %s\n", loc_foot.tf_name */

	if( loc_foot.tf_name[0] != ACS_NO_VALID_PATH ){

		/*| connect tf_foot to header */
		sts = om$send(	msg	 = message Root.connect(
						AS_to_owner,
						OM_K_MAXINT,
						dyn_info->header.objid,
						dyn_info->header.osnum,
						AS_to_comp,
						OM_K_MAXINT ),
				targetid = loc_foot.tf_id.objid,
				targetos = loc_foot.tf_id.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts, msg = "Error in connect to header" );

		loc_foot.foot = dyn_info->header;
	}

	/*| store tf_foot */
	sts = om$send(	msg	 = message ACheader.ACstore_tf_foot
					( &msg, &loc_foot ),
			targetid = dyn_info->header.objid,
			targetos = dyn_info->header.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );

	/*| change located object */
	dyn_info->clone = loc_foot.tf_id;
	*tf_foot = loc_foot.tf_id;

/*^
	printf(" tf_foot creer : id/os = (%d/%d)\n", 
					tf_foot->objid, tf_foot->osnum );
	printf(" loc_foot description \n");
	printf(" tf_if : id/os = (%d/%d)\n", 
				loc_foot.tf_id.objid, loc_foot.tf_id.osnum );
	printf(" foot  : id/os = (%d/%d)\n", 
				loc_foot.foot.objid, loc_foot.foot.osnum );
	printf(" name  : %s\n", loc_foot.tf_name );
*/

return	OM_S_SUCCESS;
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

struct	ACShandl_info	my_act_ptr;

extern	IGRint			ACSloc_symb;
extern	struct	ACSdyn_info	ACSdyn_tf_foot_info;

struct	tf_foot			my_tf_foot;
struct	ACSdyn_info		dyn_info;
struct	GRlc_info		*loc_info;
struct	GRid			my_grid;
struct	GRid			model;

extern	struct GRid	ACSinitial_context;
extern	struct GRid	ACSinitial_symbol;

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
	if( ( cvl->attributes.type == GR_rp_loc ) ||
		( cvl->attributes.type == GR_cv_loc ) ||
		( cvl->attributes.type == GR_crit_loc ) ){
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
	sts = om$send(	msg	 = message GRowner.GRget_context(
					&msg,
					&cvl->module,
					&my_cvl.module ),
			targetid = my_id );
	as$status( sts = sts );
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
		 struct GRmd_env ACStmp_mod;
		 ACStmp_mod = ACScreate_mod;
		 sts = om$send(msg	 = message GRowner.GRget_context(
								&msg,
								&ACStmp_mod,
								&ACScreate_mod),
			      targetid = my_id );
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
/* MOD LU */
		my_cvl.action_handler	= ACheader_handl;
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

/* *************** MSG GRlocate_processing () *************************	*/

method GRlocate_processing(IGRlong *ret_msg; struct GRlc_cvl *cvl;
				struct GRlc_path *path; 
				IGRint *path_position, *owner_elig, *comp_elig )
{

IGRlong		sts;

	sts = om$send(	msg	= message GRvg.GRlocate_processing(
					ret_msg,
					cvl,
					path,
					path_position,
					owner_elig,
					comp_elig ),
			mode 	 = OM_e_wrt_message,
			targetid = my_id );
/*^	as$status( sts = sts ); */

return	sts;
}

end implementation ACheader;
