/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation ACmodel_mgr;

#include "msdef.h"
#include "madef.h"
#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"
#include "OMerrordef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "parametric.h"
#include "csdef.h"
#include "grcoordsys.h"

#include "macro.h"
#include "acmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#define	AS_DEBUG

#define	MBREF	"model_bref"

#define AC_ATTRIB_REF	0x8


from	ACmodel		import	ACsame_temp_values;
from	NDnode		import	NDgive_structure;
from	NDnode		import	NDchg_state;
from	NDnode		import	NDget_objects;
from	expression	import	create;
from	ACdiowner	import	ACcreate;
from	ACrg_collect	import	AClist_attribute;
from	ACcpx_defn	import	ACgive_temp_desc;
from	ACcpx		import	find_macro;
from	ACcpx		import	ACfind_exp_temp_struct;
from	ACcpx		import	ACfind_temp_struct;
from	ACncpx		import	ACmplace_from_def;
from	ACncpx		import	ACget_NV_rep;
from	GRgraphics	import	GRconstruct;
from	ACmacro_defn	import	ACgive_upscan;
from	NDmacro		import	ACgive_structure;
from	ACrg_collect	import	ACadd_list_attribute;
from	ACrg_collect	import	ACshow_data;
from	ACrg_collect	import	ACget_prop_mgr;
from    GRconnector     import GRrigidconn;
from	ci_macro	import	init;

extern	GRclassid OPP_ACmodel_class_id;
extern	GRclassid OPP_expression_class_id;
extern	GRclassid OPP_text_exp_class_id;
extern	GRclassid OPP_GRgencs_class_id;
extern	GRclassid OPP_ACrg_collect_class_id;
extern	GRclassid OPP_ACci_model_class_id;
extern	GRclassid OPP_ci_mac_def_class_id;

extern	int DItranslate();
extern	int DIadd_name();

/* *************** MSG ACreturn_model() *******************************	*/

method ACreturn_model( IGRlong *rc; IGRint prop; IGRchar rep; IGRchar *mac_def_name;
			IGRint nb_temp; struct GRid *temp; struct GRid *def_occ;
			struct GRmd_env *mod_env;
			struct GRid *model_id )

{
IGRlong			sts, msg;

OMuint			nb_model;
IGRint			i;
struct	GRid		*my_temp;
IGRchar			exp_val[80];
struct	ret_struct	temp_str;
IGRlong			ACget_model_base_ref();
IGRint			int_msg;
IGRshort		sh_msg;
IGRint			j;
struct	GRid		def_id;
IGRint			def_nb_temp;
struct	sup		*dup;
IGRint			def_prop;
IGRint			tmp_nb;
struct	stemp		*temp_desc;
struct	ret_struct	str;
struct	ACrg_coll	att;
IGRshort		box_prop;
GRclassid		sender_class;


	/*| initialization */
	*rc 		= OM_S_SUCCESS;
	my_temp		= NULL;
	nb_model	= 0;
	exp_val[0] 	= '\0';
	model_id->objid	= NULL_OBJID;
	model_id->osnum = OM_Gw_current_OS;

	/*| look list of value to all model attach */
	sts = om$get_channel_count(	objid 	= my_id,
					p_chanselect = &AS_to_comp,
					count	= &nb_model );
	as$status( sts = sts, msg = "Error in mc get_channel_count" );
	/*" nb_model : %d\n", nb_model */

	for( i=0; i<nb_model; i++ ){

		msg = TRUE;
		sts = om$send(	msg	 = message ACmodel.ACsame_temp_values(
						&msg,
						nb_temp,
						temp,
						mod_env ),
				p_chanselect = &AS_to_comp,
				from	= i,
				to	= i );
		as$status( sts = sts, msg = "Error in msg ACsame_exp_list" );
		if( msg == TRUE ) {

			/*" get occ id from index : %d\n", i */
			sts = om$get_objid_at_index(
					objid		= my_id,
					osnum		= OM_Gw_current_OS,	
					p_chanselect	= &AS_to_comp,
					index 		= i,
					objidaddr	= &model_id->objid,
					osnumaddr	= &model_id->osnum );
			as$status( sts = sts, msg = "Error in mc get_objid_at_index" );
			/*" model_id : id/os = (%d/%d)\n", model_id->objid, model_id->osnum */
			return	OM_S_SUCCESS;
		}

	}/*end for*/

	/*| ***************** CREATE A NEW MODEL *********************	*/

	/*" get info from macro def name : %s\n", mac_def_name */
	def_id.objid	= NULL_OBJID;
	sts = ac$find_macro_defn(	action		= ACfind_load,
					macro_name	= mac_def_name,
					p_macro_defn_id	= &def_id );
        if( ( ! (sts&1) || def_id.objid == NULL_OBJID) && nb_model ){

		sts = om$send(	msg	 = message ACcpx.find_macro(&def_id),
				p_chanselect = &AS_to_comp,
				from	= 0,
				to	= 0 );
	}
	as$status( sts = sts );
	/*" def_id : id/os = (%d/%d)\n", def_id.objid, def_id.osnum */
	if( def_id.objid == NULL_OBJID ){
		printf(" macro definition %s not found \n", mac_def_name );
		*rc	= MSFAIL;
		return	OM_W_ABORT;
	}

	/*| get nb of upscan */
	sts = om$send(	msg	 = message ACmacro_defn.ACgive_upscan(
					&def_nb_temp,
					&def_prop,
					&dup ),
			targetid = def_id.objid,
			targetos = def_id.osnum );
	as$status( sts = sts );
	if( def_nb_temp != nb_temp ){

		printf(" Error not enought template to create a model \n");
		*rc	= MSFAIL;
		return	OM_W_ABORT;
	}

	/*| get template description */
	sts = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc(
					&tmp_nb,
					&temp_desc ),
			targetid = def_id.objid,
			targetos = def_id.osnum );
	as$status( sts = sts );

	/*" allocate model template : %d\n", def_nb_temp */
	my_temp = (struct GRid *) om$malloc (
				size = sizeof(struct GRid) * def_nb_temp );
	if( my_temp == NULL ){
		printf(" not enought memory to allocate my_temp \n");
		*rc	= MSFAIL;
		return	OM_W_ABORT;
	}

	/*| create template of model */
	for( i=0; i<def_nb_temp; i++ ){

		// get info from template of header
		sts = om$send(	msg	 = message NDnode.NDgive_structure(
						&msg,
						&temp_str,
						mod_env ),
				targetid = temp[i].objid,
				targetos = temp[i].osnum );
		as$status( sts = sts, msg = "Error in msg NDgive_structure" );
		/*" temp_str.type : %d\n", temp_str.type */

		my_temp[i].objid = NULL_OBJID;
		my_temp[i].osnum = OM_Gw_current_OS;

		switch( temp_str.type ) {

		case double_type :

			/*" temp[%d] is an expression : %f\n", i, temp_str.var.root_pm_st.value */

			sts = om$construct(	classid	= OPP_expression_class_id,
						p_objid = &my_temp[i].objid );
			as$status( sts = sts, msg = "Error in mc construct" );
			/*" my_temp[%d]: id/os = (%d/%d)\n", i, my_temp[i].objid, my_temp[i].osnum */

			sprintf( exp_val, "%f", temp_str.var.root_pm_st.value );
			/*" exp_val : %s\n", exp_val */
			sts = om$send(	msg 	 = message expression.create
							( "", exp_val, &sh_msg ),
					targetid = my_temp[i].objid );
			as$status( sts = sts );
			break;

		case text_type :

			/*" temp[%d] is a text expression : %s\n", i, temp_str.var.text_st.text_string */
			sts = om$construct(	classid	= OPP_text_exp_class_id,
						p_objid = &my_temp[i].objid );
			as$status( sts = sts );
			/*" my_temp[%d]: id/os = (%d/%d)\n", i, my_temp[i].objid, my_temp[i].osnum */

			sts = om$send(	msg 	 = message expression.create( 
							"", 
							temp_str.var.text_st.text_string, 
							&sh_msg ),
					targetid = my_temp[i].objid );
			as$status( sts = sts, msg = "Error in msg expression create" );
			break;
			
		case ref_generic :

			/*" temp[%d] is a referential \n", i */
			/*| get id of model_bref */
			sts = ACget_model_base_ref( &my_temp[i], mod_env );
			as$status( sts = sts );
			/*" my_temp[%d]: id/os = (%d/%d)\n", i, my_temp[i].objid, my_temp[i].osnum */
			break;

		case gen_rg_collect :

			/*| test if ACrg_collect is CACHE */
			sts = om$send(	msg	 = message ACrg_collect.ACget_prop_mgr
							( &box_prop ),
					targetid = temp[i].objid,
					targetos = temp[i].osnum );
			as$status( sts = sts );
			/*" box_prop (x) : %x\n", box_prop */

			if( box_prop & AC_BOX_CACHE ){

				/*" temp[%d] : id/os = (%d/%d) is a box cache\n", i, temp[i].objid, temp[i].osnum */
				my_temp[i] = temp[i];
				break;
			}

		case macro_generic :

			/*| create an ACrg_collection */
			sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
						p_objid = &my_temp[i].objid );
			as$status( sts = sts, msg = "Error in mc construct" );
			/*" my_temp[%d]: id/os = (%d/%d)\n", i, my_temp[i].objid, my_temp[i].osnum */

			for( j=0; j<tmp_nb; j++ )
			  if( temp_desc[j].back == i )
			    if( temp_desc[j].type & ref_generic ){

				strcpy( att.name, temp_desc[j].name );
				att.desc.type	= AC_ATTRIB_REF;
				att.desc.value.att_exp = (IGRdouble) MAIDMX;

				/*| add ref */
				sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute(
								&msg,
								1,
								&att ),
						targetid = my_temp[i].objid,
						targetos = my_temp[i].osnum );
				as$status( sts = sts );
				as$status( sts = msg );

			    } else if( temp_desc[j].type & parameter_generic ){

				/*| get value of expression */
				sts = om$send(	msg	 = message NDmacro.ACgive_structure(
								&int_msg,
								NULL,
								temp_desc[j].name,
								&str,
								mod_env ),
						targetid = temp[i].objid,
						targetos = temp[i].osnum );
				as$status( sts = sts );
				if( ! (int_msg&1)){

					printf(" Error attrib %s do not existe in %d temp\n", temp_desc[j].name, i );
					*rc	= MSFAIL;
					goto	wrapup;
				}

				/*| add a new attribute in collection */
				strcpy( att.name, temp_desc[j].name );
				if( str.type & double_type ){
					att.desc.type = AC_ATTRIB_DOUBLE;
					att.desc.value.att_exp = 
						str.var.root_pm_st.value;

				} else if( str.type & text_type ){

					att.desc.type = AC_ATTRIB_TEXT;
					strcpy( att.desc.value.att_txt,
						str.var.text_st.text_string );
				  } else {
					printf(" Error on type \n");
					*rc	= MSFAIL;
					goto	wrapup;
				    }

				/*| add value */
				sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute(
								&msg,
								1,
								&att ),
						targetid = my_temp[i].objid,
						targetos = my_temp[i].osnum );
				as$status( sts = sts );
				as$status( sts = msg );

			    }/*end else if exp*/
/*^
			sts = om$send(	msg	 = message ACrg_collect.ACshow_data
							( &msg ),
					targetid = my_temp[i].objid,
					targetos = my_temp[i].osnum );
			as$status( sts = sts );
*/
			break;

		default :
			printf(" this type %d for template is not valid for an ACmodel \n", 
					temp_str.type );
			*rc	= MSFAIL;
			goto	wrapup;
		}

		/* Transform it to support only */
		sts = om$send(	msg 	 = message NDnode.NDchg_state
						( ND_SUP_ONLY , ND_SUP_ONLY ),
				targetid = my_temp[i].objid,
				targetos = my_temp[i].osnum );
		as$status( sts = sts );

	}/*end build model temp*/

/*^
	for( i=0; i<def_nb_temp; i++ )
		printf(" my_temp[%d] : id/os = (%d/%d)\n", i, my_temp[i].objid, my_temp[i].osnum );
*/

	/*| construct new model */

	/*| detect type of model to construct */

	/* def_id */
	sts = om$get_classid(	osnum		= def_id.osnum,
				objid		= def_id.objid, 
				p_classid	= &sender_class );
	as$status( sts = sts );

	if( om$is_ancestry_valid(	
			subclassid	= sender_class,
			superclassid	= OPP_ci_mac_def_class_id )
						     == OM_S_SUCCESS ){

		sts = om$construct(	classid	= OPP_ACci_model_class_id,
					p_objid = &model_id->objid );
		as$status( sts = sts, msg = "Error in mc construct" );
		/*" model_id : id/os = (%d/%d)\n", model_id->objid, model_id->osnum */

		sts = om$send(	msg	 = message ci_macro.init(
						&int_msg,
						prop,
						mac_def_name,
						def_nb_temp,
						my_temp,
						NULL,
						mod_env ),
				targetid = model_id->objid,
				targetos = model_id->osnum );
		as$status( sts = sts );
		as$status( sts = msg );
		if( ! (sts&1))	{ *rc = MSFAIL; goto wrapup; }
	
	} else {

		sts = om$construct(	classid	= OPP_ACmodel_class_id,
					p_objid = &model_id->objid );
		as$status( sts = sts, msg = "Error in mc construct" );
		/*" model_id : id/os = (%d/%d)\n", model_id->objid, model_id->osnum */

		/*| place an occurence of macro defn */
		sts = om$send(	msg	 = message ACncpx.ACmplace_from_def(
						&int_msg,
						prop,
						0,
						mac_def_name,
						def_nb_temp,
						my_temp,
						def_occ,
						mod_env ),
				targetid = model_id->objid,
				targetos = model_id->osnum );
		as$status( sts = sts );
		as$status( sts = msg );
		if( ! (sts&1))	{ *rc = MSFAIL; goto wrapup; }
	  }

	/*| connect model and model_mgr */
      {
       struct GRid my_grid;
       long index = 0;

        my_grid.objid = my_id;
        my_grid.osnum = OM_Gw_current_OS;
        sts = om$send( msg = message GRconnector.GRrigidconn( &msg, &my_grid,
                       &index ),
                    targetid = model_id->objid,
                    targetos = model_id->osnum );
       }

        as$status( sts = sts );

	if( ! (sts&1))	{ *rc = MSFAIL; goto wrapup; }

wrapup :
	/*| free memory */
	if( my_temp  != NULL )	om$dealloc( ptr = my_temp );

	if( ! (*rc & 1))	return	OM_W_ABORT;

return	OM_S_SUCCESS;
}


/* ************ FCT ACget_model_base_ref () ***************************	*/

IGRlong	ACget_model_base_ref( ref, md_env ) 

struct 	GRid 		*ref; 
struct 	GRmd_env	*md_env; 

/*.ACget_model_base_ref*/
{

IGRint			i;
IGRlong			msg, sts;   
struct	IGRlbsys  	ref_parameters;
struct	GRvg_construct	cnst_list;
struct	GRcs_construct	cs_args;
struct 	GRid		rref; 
struct	IGRdisplay  	dis;
IGRchar			ref_path[DI_PATH_MAX];
OM_S_OBJID 		md_id;

	/*| initialization */
	ref->osnum = md_env->md_id.osnum;
	rref.osnum = md_env->md_id.osnum;

	di$give_pathname( osnum = ref->osnum, pathname = ref_path );
	/*" ref_path : %s\n", ref_path */
 
	if( !( di$translate(	objname	= MBREF,
				path	= ref_path,
				osnum	= ref->osnum,
				p_objid	= &ref->objid ) & SUCC ) ) {
 
		/*| building refernetial */

		MAidmx( &msg, ref_parameters.matrix );
		for( i=0; i<3; i++ ){

			ref_parameters.diag_pt1[i]=0;
			ref_parameters.diag_pt2[i]=0;
		}

/* 		dis.rgb_value		= 0; - no longer needed -pcw 06/10/91 */
		dis.weight 		= 0;
		dis.style		= 0;
		dis.color		= 1;
		cnst_list.display	= &dis;

		cs_args.desc 		= NULL;
		cs_args.flag 		= CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;

		cnst_list.level		= 1;
		cnst_list.name 		= 0;
		cnst_list.msg 		= &msg;
		cnst_list.env_info	= md_env;
		cnst_list.newflag	= FALSE;           
		cnst_list.geometry	= (IGRchar *) &ref_parameters;
		cnst_list.class_attr	= (IGRchar *) &cs_args; 
		cnst_list.properties	= 0;

		sts = om$construct(	classid	= OPP_GRgencs_class_id,
					p_objid	= &rref.objid,
					osnum	= rref.osnum );
		as$status( sts = sts, msg = "Error in mc construct" );
		/*" rref : id/os = (%d/%d)\n", rref.objid, rref.osnum */

		md_id = md_env->md_id.objid;
		md_env->md_id.objid = NULL_OBJID;
		sts = om$send(	msg	 = message GRgraphics.GRconstruct
						( &cnst_list ),
				targetid = rref.objid,
				targetos = rref.osnum,
				senderid = NULL_OBJID );
		md_env->md_id.objid = md_id;
		as$status( sts = sts, msg = "Error in msg GRconstruct" );

		as$make_source( go_grid = rref, as_grid = ref );
		di$add_name(	objname = "MBREF",
				path	= ref_path,
				osnum	= ref->osnum,
				objid	= ref->objid );

	}/*end dont exist*/

return	OM_S_SUCCESS;
}


/* ******************* ACSret_values_list() ***************************	*/

ACSret_values_list( list_obj, list_len, att_list, nb_att, mod_env  )

struct	GRid		*list_obj;
IGRint			list_len;
struct	ACrg_coll	*att_list;
IGRint			*nb_att;
struct	GRmd_env	*mod_env;

/*.ACSret_values_list*/
{

IGRlong			sts, msg;
struct	ret_struct	obj_str;
struct	ret_struct	temp_str;
IGRint			i;
struct	GRid		mac_def;
struct	stemp		*dtemp;
IGRint			tot_temp;
IGRint			int_msg;

	/*| initialization */
	*nb_att	= 0;

	sts = om$send(	msg	 = message NDnode.NDgive_structure(
					&msg,
					&obj_str,
					mod_env ),
			targetid = list_obj->objid,
			targetos = list_obj->osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts, action = RET_STATUS );

	switch(	obj_str.type ){

	case macro_generic :

		/*| macro_generic */

		sts = om$send(	msg	 = message ACcpx.find_macro
							( &mac_def ),
				targetid = list_obj->objid,
				targetos = list_obj->osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts, action = RET_STATUS );
		/*" mac_def : id/os = (%d/%d)\n", mac_def.objid, mac_def.osnum */

		sts = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc
						( &tot_temp, &dtemp ),
				targetid = mac_def.objid,
				targetos = mac_def.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts, msg = "Error in msg ACgive_temp_desc" );

		for( i=0; i<tot_temp; i++ ) {

			sts = om$send(	msg	 =  message ACcpx.ACfind_exp_temp_struct( 
							&int_msg, 
							i,
							&temp_str, 
							mod_env ),
					targetid = list_obj->objid,
					targetos = list_obj->osnum,
					senderid = NULL_OBJID );
			as$status( sts = sts );

			switch( temp_str.type ){

			case double_type :
				if( *nb_att < list_len && att_list != NULL ){

					strcpy( att_list[*nb_att].name, 
								dtemp[i].name );
					att_list[*nb_att].desc.type = 
							AC_ATTRIB_DOUBLE;
					att_list[*nb_att].desc.value.att_exp = 
						temp_str.var.root_pm_st.value;
				}
				*nb_att +=1;
				break;

			case text_type :
				if( *nb_att < list_len && att_list != NULL ){

					strcpy( att_list[*nb_att].name, 
								dtemp[i].name );
					att_list[*nb_att].desc.type = 
								AC_ATTRIB_TEXT;
					strcpy( att_list[*nb_att].desc.value.att_txt,
						temp_str.var.text_st.text_string );
				}
				nb_att++;
				break;

			default :
				/*" %d unkwown type \n", temp_str.type */ 
				break;
			}

		}/*end for temp*/
		break;

	case gen_rg_collect :

		sts = om$send(	msg	= message ACrg_collect.AClist_attribute(
						&msg,
						list_len,
						att_list,
						nb_att ),
				targetid = list_obj->objid,
				targetos = list_obj->osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );
		break;

	default :
		/*" %d unkown type \n", obj_str.type */
		break;
	}

/*^
	printf(" nb_att : %d\n", *nb_att );
	for( i=0; i<list_len; i++ ){

		printf(" attribut : %s, %d", att_list[i].name, 
						att_list[i].desc.type );
		if( att_list[i].desc.type == AC_ATTRIB_DOUBLE )
			printf(", %f\n", att_list[i].desc.value.att_exp );
		if( att_list[i].desc.type == AC_ATTRIB_TEXT )
			printf(", %s\n", att_list[i].desc.value.att_txt );
	}
*/

return	OM_S_SUCCESS;
}

end implementation ACmodel_mgr;
