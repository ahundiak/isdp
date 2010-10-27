/* $Id: headloc.I,v 1.2 2001/01/18 19:09:10 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / headloc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: headloc.I,v $
 *	Revision 1.2  2001/01/18 19:09:10  ramarao
 *	Merged Service Pack Files to 262 pload.
 *	
# Revision 1.2  2000/10/12  21:17:52  pinnacle
# Replaced: vds/vdassoc/headloc.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/10/12  21:13:28  pinnacle
# Created: vds/vdassoc/headloc.I by jpulapar for Service Pack
#
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
 *	10/12/00        Jayadev         TR179902079
 * -------------------------------------------------------------------*/

/*
	Fix memory fault we recall the last located objects with locate
	components properties on. 	the 2 june 93 MF & LLC
*/

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


/* ************ MSG GRlocate () ***************************************	*/

method GRlocate( struct	GRlc_cvl *cvl; OM_p_KEY_DESC range_key )

{
IGRlong		msg, sts;
IGRint		nb_feet = 0;
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
extern	struct GRmd_env	ACScreate_mod;
extern	IGRint		ACheader_handl();

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

	// TR179902079 - Locate was failing because of bad macro
        // donot abort - carry on with the rest of locate

	if(nb_feet == 0){
		sts =  OM_S_SUCCESS;
		goto wrapup;
	}

	feet_list = (struct GRid *) malloc( sizeof( struct GRid ) * nb_feet );
	if( feet_list == NULL ){
		printf(" Error not enougth memory to allocate feet_list\n");
		//return	OM_E_ABORT;
		sts =	OM_E_ABORT;
		goto wrapup;
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

end implementation ACheader;
