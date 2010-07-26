/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation ACmodel;

#include "AS_status.h"

#include "asbox.h"
#include "grownerdef.h"
#include "asmacros.h"
#include "grerr.h"
#include "nddef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "exmacros.h"

#define AS_DEBUG

#define AC_ATTRIB_REF	0x8

extern	GRclassid	OPP_ACheader_class_id;
extern	GRclassid	OPP_expression_class_id;
extern	GRclassid	OPP_text_exp_class_id;

from	ACcpx_defn	import	ACgive_name;
from	expression	import	create;
from	ACheader	import	ACshow_data;
from	ACrg_collect	import	ACget_named_attribute;
from	ACrg_collect	import	ACget_attribute_at_index;
from	ACrg_collect	import	ACget_prop_mgr;


/* ************** MSG ACsame_temp_values () ***************************	*/

method ACsame_temp_values( IGRlong *rc; IGRint nb_temp; 
			struct GRid *temp_list; struct GRmd_env *mod_env )
{
IGRlong			msg, sts;
OMuint			nb_md_temp;
struct	ret_struct	model_desc, head_desc;
struct	ret_struct	str;
IGRdouble		eps;
IGRint			i;
struct	GRid		md_temp;
IGRdouble		fabs();
struct	ACrg_coll	att;
IGRint			int_msg;

IGRint			j;
IGRshort		box_prop;



	/*| initialization */
	*rc = TRUE;

	/*| get number of parents */
	sts = om$get_channel_count(	objid 	= my_id,
					p_chanselect = &ND_father,
					count	= &nb_md_temp );
	as$status( sts = sts, msg = "Error in mc get_channel_count" );
	/*" nb_md_temp : %d\n", nb_md_temp */
	if( nb_md_temp != nb_temp ){
		/*| bad number of templates between model and header */
		*rc	= FALSE;
		return	OM_S_SUCCESS;
	}

	for( i=0; i<nb_md_temp; i++ ) {

		sts = om$get_objid_at_index(
					objid		= my_id,
					osnum		= OM_Gw_current_OS,	
					p_chanselect	= &ND_father,
					index 		= i,
					objidaddr	= &md_temp.objid,
					osnumaddr	= &md_temp.osnum );
		as$status( sts = sts, msg = "Error in mc get_objid_at_index" );

		sts = om$send(	msg	 = message NDnode.NDgive_structure(
						&msg,
						&model_desc,
						mod_env ),
				targetid = md_temp.objid,
				targetos = md_temp.osnum );
		as$status( sts = sts, msg = "Error in msg NDgive_structure" );

		/*| get template structure for header */
		sts = as$any_give_structure( 	go_grid	= temp_list[i],
						inst	= &head_desc,
						mod_env	= mod_env );
		as$status( sts = sts, msg = "Error in mc any_give_structure", 
				action = RET_STATUS );

		if( model_desc.type != head_desc.type && 
					model_desc.type != gen_rg_collect ){
			/* " model type %d is not equal to header type %d\n", model_desc.type, head_desc.type */
			*rc	= FALSE;
			goto	wrapup;
		}

		switch( model_desc.type ) {

		case ref_generic :
			/*| ref */
			break;

		case double_type :
			eps =	fabs( model_desc.var.root_pm_st.value - 
					head_desc.var.root_pm_st.value );
			/*" eps : %f\n", eps */

			if( eps > fabs( (model_desc.var.root_pm_st.value + 1) 
						* 0.000001 )) {

				/*" expression %d different : model %f; header %f\n", i, model_desc.var.root_pm_st.value, head_desc.var.root_pm_st.value */
				/*| BAD model */
				*rc	= FALSE;
				goto	wrapup;
			}
			break;

		case text_type :
			if( strcmp( model_desc.var.text_st.text_string, 
					head_desc.var.text_st.text_string )){
				/*" text %d different : model %s; header %s\n", i, model_desc.var.text_st.text_string, head_desc.var.text_st.text_string */
				/*| BAD model */
				*rc	= FALSE;
				goto	wrapup;
			}
			break;

		case gen_rg_collect :	/*| gen_rg_collect */

			sts = om$send(	msg	 = message ACrg_collect.ACget_prop_mgr
							( &box_prop ),
					targetid = md_temp.objid,
					targetos = md_temp.osnum );
			as$status( sts = sts );
			/*" box_prop (x) : %x\n", box_prop */

			if( box_prop & AC_BOX_CACHE ){

				/*| box cache */
				if( md_temp.objid == temp_list[i].objid ){

					/*| box cache is share */
					break;
				}
			}

			msg	= ~0;
			for( j=0; (msg & 1); j++ ){

				sts = om$send(	msg	 = message 
					ACrg_collect.ACget_attribute_at_index( 
								&msg,
								j,
								&att ),
						targetid = md_temp.objid,
						targetos = md_temp.osnum );
				as$status( sts = sts );
				if( ! (msg&1))	break;

				if( att.desc.type & AC_ATTRIB_REF ){
					/*" att[%d] : %s is a ref \n", j, att.name */
					continue;
				}

				sts = om$send(	msg	 = message NDmacro.ACgive_structure(
								&int_msg,
								NULL,
								att.name,
								&str,
								mod_env ),
						targetid = temp_list[i].objid,
						targetos = temp_list[i].osnum );
				as$status( sts = sts );
				if( ! (int_msg&1)){
					/*" model template %s is not header template\n", att.name */
					/*| BAD model */
					*rc	= FALSE;
					goto	wrapup;
				}

				/*| compare att and str value */

				if( (att.desc.type & AC_ATTRIB_DOUBLE) &&
						(str.type & double_type) ){

					eps =	fabs( att.desc.value.att_exp - 
							str.var.root_pm_st.value );
					/*" eps : %f\n", eps */

					if( eps > 0.01 ) {
						/*" expression %s different : model %f; header %f\n", att.name , att.desc.value.att_exp, str.var.root_pm_st.value */
						/*| BAD model */
						*rc	= FALSE;
						goto	wrapup;
					}

				} else if( (att.desc.type & AC_ATTRIB_TEXT) &&
						(str.type & text_type) ){

					  if( strcmp( att.desc.value.att_txt, 
						str.var.text_st.text_string )){
			
						/*" text %s different : model %s; header %s\n", att.name, model_desc.var.text_st.text_string, head_desc.var.text_st.text_string */
						/*| BAD model */
						*rc	= FALSE;
						goto	wrapup;
					  }

				  } else {
					/*" can not compare attribute %s\n", att.name */
					/*| BAD model */
					*rc	= FALSE;
					goto	wrapup;
				    }

			}/*end for*/
			break;

		default :

			/*" not valid template type %d for model\n", model_desc.type */
			*rc	= FALSE;
			goto	wrapup;

		}/*end case*/
	}/*end for*/

wrapup	:


return	OM_S_SUCCESS;
}

/* ************ MSG GRlocate_owner () ******************************	*/

method GRlocate_owner( IGRlong *rc; struct GRlc_cvl *cvl;
			struct GRlc_path *path; IGRint	*path_position )
{

	/*| **** msg GRlocate_owner an ACmodel **** */

return	GR_I_NO_RESPONSE;
}

/* ************** MSG ACdisconnect_head () ****************************	*/

method ACdisconnect_head( IGRlong *rc; struct GRid *header; 
						struct GRmd_env *md_env )

{
IGRlong		sts;

	/*| disconnect model and header */
	sts = om$send(	msg	 = message Root.disconnect(
					AS_to_owner,
					header->objid,
					header->osnum,
					AS_to_comp ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg disconnect" );

return	OM_S_SUCCESS;
}

/* ************** MSG AChead_place () *********************************	*/

method AChead_place( IGRlong *rc; IGRshort temp_prop; struct GRid *ref_id;
			struct GRid *header; struct GRmd_env *mod_env )

{
IGRlong			sts, msg;
struct	ret_struct	temp_desc;
IGRchar			*def_name;
struct	GRid		def;
IGRint			i;
unsigned char		rep;
IGRchar			exp_val[80];
IGRint			int_msg;
IGRshort		sh_msg;
struct	GRid		*temp_list;
OMuint			nb_max_temp;
IGRint			real_temp;
struct	GRsymbology	symb;
IGRshort		hd_prop;


	/*| initialization */
	*rc		= OM_S_SUCCESS;
	temp_list	= NULL;
	header->objid	= NULL_OBJID;
	header->osnum	= OM_Gw_current_OS;

	/*| construct header */
	sts = om$construct(	classid	= OPP_ACheader_class_id,
				p_objid	= &header->objid );
	as$status( sts = sts );
	/*" header : id/os = (%d/%d)\n", header->objid, header->osnum */

	sts = om$get_channel_count(	objid 	= my_id,
					p_chanselect = &ND_father,
					count	= &nb_max_temp );
	as$status( sts = sts, msg = "Error in mc get_channel_count" );
	/*" nb_max_temp : %d\n", nb_max_temp */

	temp_list = (struct GRid *) om$malloc(	
				size = sizeof( struct GRid ) * nb_max_temp );
	if( temp_list == NULL ){

		printf("Error not enougth memory to allocate temp_list \n");
		*rc	= OM_E_ABORT;
		goto	wrapup;		
	}


	for( i=0, real_temp=0; i<nb_max_temp; i++ ){
	
		sts = om$send(	msg	 =  message ACcpx.ACfind_exp_temp_struct( 
						&int_msg, 
						i, 
						&temp_desc, 
						mod_env ),
				targetid = my_id );
		as$status( sts = sts, msg = "Error in msg ACfind_exp_temp_struct" );

		temp_list[real_temp].objid	= NULL_OBJID;
		temp_list[real_temp].osnum	= OM_Gw_current_OS;

		switch( temp_desc.type ){

		case double_type :
			sts = om$construct( classid = OPP_expression_class_id,
					    p_objid = &temp_list[real_temp].objid );
			as$status( sts = sts );

			sprintf( exp_val, "%f", temp_desc.var.root_pm_st.value );

			sts = om$send(	msg	 = message expression.create( 
							"", 
							exp_val,
							&sh_msg ),
					targetid = temp_list[real_temp].objid );
			as$status( sts = sts );

			sts = om$send(	msg	 = message NDnode.NDchg_state
						( ND_SUP_ONLY , ND_SUP_ONLY ),
					targetid = temp_list[real_temp].objid );
			as$status( sts = sts );
			real_temp++;
			break;

		case text_type :
			sts = om$construct( classid = OPP_text_exp_class_id,
					    p_objid = &temp_list[real_temp].objid );
			as$status( sts = sts );

			sts = om$send(	msg	 = message expression.create( 
							"", 
							temp_desc.var.text_st.text_string, 
							&sh_msg ),
					targetid = temp_list[real_temp].objid );
			as$status( sts = sts );

			sts = om$send(	msg	 = message NDnode.NDchg_state
						( ND_SUP_ONLY , ND_SUP_ONLY ),
					targetid = temp_list[real_temp].objid );
			as$status( sts = sts );
			real_temp++;
			break;

		case ref_generic :
			temp_list[real_temp] = *ref_id;
			real_temp++;
			break;

		default :
			printf(" unkown type : %d\n", temp_desc.type );
			continue;

		}/*end switch*/

	}/*end for*/

	/*| connect construct temp */
	/*" real_temp : %d\n", real_temp */
	for( i=0; i<real_temp; i++ )
		as$make_source(	go_grid	= temp_list[i],
				as_grid	= &temp_list[i] );

	sts = om$send(	msg	 = message NDnode.NDconnect(
					real_temp,
					temp_list,
					NULL_GRID,
					ND_NEW ),
			targetid = header->objid );
	as$status( sts = sts );

	/*| get name of mac def */
	sts = om$send(	msg	 = message ACcpx.find_macro( &def ),
			targetid = my_id );
	as$status( sts = sts );

	sts = om$send(	msg	 = message ACcpx_defn.ACgive_name
					( &def_name ),
			targetid = def.objid,
			targetos = def.osnum );
	as$status( sts = sts );
	/*" def_name : %s\n", def_name */

	/*| attach header and macro def */
	sts = om$send(	msg	 = message ACncpx.ACattach
					( &int_msg, def_name ),
			targetid = header->objid );
	as$status( sts = sts );

	/*| set representation */
	sts = om$send(	msg	 = message ACncpx.ACget_NV_rep( &rep ),
			targetid = my_id );
	as$status( sts = sts );

	sts = om$send(	msg	 = message ACncpx.ACput_NV_rep( rep ),
			targetid = header->objid );
	as$status( sts = sts );

	/*| connect header and model */
	sts = om$send(	msg	 = message Root.connect(
					AS_to_owner,
					0,
					header->objid,
					header->osnum,
					AS_to_comp,
					OM_K_MAXINT ),
			targetid = my_id );
	as$status( sts = sts );

	/*| compute node */
	sts = om$send(	msg	 = message ACncpx.NDcompute_node(
					&msg,
					ND_COMP,
					real_temp,
					temp_list,
					mod_env ),
			targetid = header->objid );
	as$status( sts = sts );

	sts = om$send(	msg	 = message GRgraphics.GRaddwrng
					( &msg, mod_env ),
			targetid = header->objid );
	as$status( sts = sts );

	/*| init symbologie */
	sts = om$send(	msg	 = message GRvg.GRgetsymb
					( &msg, &symb ),
			targetid = my_id );
	as$status( sts = sts );

	sts = om$send(	msg	 = message GRvg.GRputsymb
					( &msg, &symb ),
			targetid = header->objid );
	as$status( sts = sts );

	hd_prop	= 0;
	sts = om$send(	msg	 = message GRowner.GRchg_owner_properties
					( &msg, 1, &hd_prop ),
			targetid = header->objid );
	as$status( sts = sts );

wrapup :

	/*| free memory */
	if( temp_list != NULL )		free( temp_list );

return	OM_S_SUCCESS;
}


/* ********************* FCT ACScmp_attr () ***************************	*/

ACScmp_attr( attr1, attr2 )

struct	ACrg_coll	*attr1;
struct	ACrg_coll	*attr2;

/*.ACScmp_attr*/
{

IGRint		ret_fct;
IGRdouble	fabs();
IGRdouble	eps;


	/*| initialization */
	ret_fct	= FALSE;

	if( attr1->desc.type == attr2->desc.type ){

		switch( attr1->desc.type ) {

		case AC_ATTRIB_DOUBLE :

			eps = fabs( attr1->desc.value.att_exp -
					attr2->desc.value.att_exp );

			if( eps < 0.01 )	ret_fct	= TRUE;
			break;

		case AC_ATTRIB_TEXT :

			if( ! strcmp( attr1->desc.value.att_txt,
						attr2->desc.value.att_txt ) ) 
			ret_fct	= TRUE;		
			break;

		default :
			/*" %d unkown case \n", attr1->desc.type */
			ret_fct	= FALSE;
		}
	}

return	ret_fct;
}

/* ************************* NDdelete () ******************************	*/

method NDdelete( struct GRmd_env *md_env )
{
IGRlong			sts;
struct	GRid		my_grid;
OM_S_CHANSELECT		*to_father, *to_children ;


	sts = om$send(	msg	 = message ACconst.NDdelete( md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );

	/*| send myself notify_disconnect because i am not in rtree */
	NDget_channel(&to_father,&to_children);

	my_grid.objid	= my_id;
	my_grid.osnum	= OM_Gw_current_OS;

	sts = om$send(	msg	 = message NDnode.NDnotify_disconnect
					( my_grid ),
			p_chanselect = to_father );
	as$status( sts = sts );

return	sts;
}

/* *********************** MSG NDsleep () *****************************	*/

method NDsleep( struct GRmd_env *md_env )
{
IGRlong		sts;
OMuint		nb_head;
OM_S_OBJID 	md_id;

	/*| send normal sleep */
	sts = om$send(	msg	 = message ACconst.NDsleep( md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );

	/*| look number of connected header */
	nb_head = 0;
	sts = om$get_channel_count(	objid 	= my_id,
					p_chanselect = &AS_to_owner,
					count	= &nb_head );
	as$status( sts = sts, msg = "Error in mc get_channel_count" );
	/*" nb_head : %d\n", nb_head */

	if( nb_head < 2 ){

		/* | kill model because no header connect */
		md_id = md_env->md_id.objid;
		md_env->md_id.objid = NULL_OBJID; /* because out of R-Tree  */
		sts = om$send(	msg	 = message ACconst.NDdelete( md_env ),
				targetid = my_id );
		md_env->md_id.objid = md_id;
		as$status( sts = sts, msg = "Error in msg NDdelete" );
	}

return	sts;
}

end implementation ACmodel;

