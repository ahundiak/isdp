/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation ACheader;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "exmacros.h"

#include "nddef.h"
#include "ndmacros.h"

#define	AS_DEBUG

from	ACcpx_defn	import	ACgive_name;

extern	GRclassid	OPP_ACmodel_mgr_class_id;
extern	GRclassid	OPP_ACheader_class_id;
extern	GRclassid	OPP_ACmodel_class_id;

/* ***************** MSG ACshow_data () *******************************	*/

method ACshow_data ( IGRlong	*msg )

{
IGRint		i;

	/*| initialization */
	*msg = TRUE;

	printf(" hdr origin : X= %f, Y= %f, Z= %f\n", 
				me->origin[0], me->origin[1], me->origin[2] );

	for( i=0; i<3; i++ )
		printf(" matrix row [%d] : %f, %f, %f\n", i, 
						me->matrix[(i*3)],
						me->matrix[(i*3)+1], 
						me->matrix[(i*3)+2] );

	/*| symbologie properties */

return	OM_S_SUCCESS;
}

/* ************ MSG ACget_share_feet_list () ************************* */

method ACget_share_feet_list( 	IGRlong *rc; IGRint size_list; 
				struct GRid *feet_list; IGRint	*count_feet )
{
IGRlong			sts, msg;
OM_S_OBJECT_LINKAGE	*md_feet;
OMuint			count;
struct	GRid		cur_model;
IGRint			i;


	/*| initialization */
	*rc		= OM_S_SUCCESS;
	md_feet		= NULL;
	*count_feet	= 0;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf("Warning no model connected\n");
		*rc = OM_E_ABORT;
		goto	wrapup;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

	/*| find number of feet */
	sts = om$get_channel_count(	objid 		= cur_model.objid,
					p_chanselect 	= &AS_to_comp,
					count		= (OMuint *)count_feet );
	as$status( sts = sts, msg = "Error in mc get_channel_count" );
	/*" count_feet : %d\n", *count_feet */

	if( feet_list != NULL && size_list > 0 ){

		md_feet = ( OM_S_OBJECT_LINKAGE * ) om$malloc(
			size = sizeof( OM_S_OBJECT_LINKAGE ) * size_list );
		if( md_feet == NULL ){
			printf(" not enought memory to allocate md_feet\n");
			*rc = OM_E_ABORT;
			goto	wrapup;
		}

		sts = om$get_channel_objects(	objid		= cur_model.objid,
						p_chanselect	= &AS_to_comp,
						list		= md_feet,
						size		= size_list,
 						count		= &count, );
		as$status( sts = sts, msg = "Error in mc get_channel_objects" );

		for( i=0; i<size_list; i++ ) {

			feet_list[i].objid = md_feet[i].S_objid;
			feet_list[i].osnum = md_feet[i].osnum;
		}
	}/*end feet_list*/

wrapup :

	/*| free memory */
	if( md_feet != NULL )	om$dealloc( ptr = md_feet );

return	OM_S_SUCCESS;
}


/* *********** MSG ACfind_model () ************************************	*/

method	ACfind_model( IGRlong *rc; struct GRid *model )

{

IGRlong		sts;

OMuword		cid;


	/*| initialization */
	*rc		= OM_E_ABORT;
	model->objid	= NULL_OBJID;

	/*| get model */
	sts = om$get_objid_at_index(	object		= me,
					p_chanselect	= &AS_to_comp,
					index		= 0,
					objidaddr	= &model->objid,
					osnumaddr	= &model->osnum );
	as$status( sts = sts, msg = "Error in mc get_objid_at_index" );

	if( model->objid == NULL_OBJID )	goto	wrapup;

	sts = om$get_classid(	objid	= model->objid,
				osnum	= model->osnum,
				p_classid = &cid );
	as$status( sts = sts );

	if( om$is_ancestry_valid(	subclassid	= cid,
					superclassid	= OPP_ACmodel_class_id ) 
		== OM_S_SUCCESS )

		*rc	= OM_S_SUCCESS;

	else 	model->objid	= NULL_OBJID;

wrapup :
	;

	/*" model : id/os = (%d/%d)\n", model->objid, model->osnum */

return	OM_S_SUCCESS;
}

/* ************* MSG ACget_model_mgr () *******************************	*/

method ACget_model_mgr( IGRlong *rc; struct GRid *model_mgr )

{
IGRlong		sts;
IGRint		index;
IGRint		new_beg;
IGRchar		my_dir[DI_PATH_MAX];
struct	GRid	dir_id;
struct	GRid	mac_def;
IGRchar		*mac_name;
IGRchar		head_path[DI_PATH_MAX];
IGRchar		mac_path[DI_PATH_MAX];
IGRchar		mgr_path[DI_PATH_MAX];


	sts = om$send(	msg	 = message ACcpx.find_macro( &mac_def ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg find_macro", action = RET_STATUS );
	/*" mac_def : id/os = (%d/%d)\n", mac_def.objid, mac_def.osnum */

	/*" header : id/os = (%d/%d)\n", my_id, OM_Gw_current_OS */

	/*| get macro def name */
	sts = om$send(	msg	 = message ACcpx_defn.ACgive_name
						( &mac_name ),
			targetid = mac_def.objid, 
			targetos = mac_def.osnum );
	as$status( sts = sts, msg = "Error in msg ACgive_name" );
	/*" mac_name : %s\n", mac_name */

	if( mac_def.osnum == OM_Gw_current_OS ){

		/*" macro def and header in same os : %d\n", mac_def.osnum */

		sts = di$give_pathname(	osnum		= OM_Gw_current_OS,
					pathname	= head_path );
		as$status( sts = sts, msg = "Error in mc give_pathname" );
		/*" head_path : %s\n", head_path */

		sprintf( mgr_path, "%s:models:%s", head_path, mac_name );
		/*" mgr_path : %s\n", mgr_path */

	} else {

		/*" macro def os %d and header os %d is not same \n", mac_def.osnum, OM_Gw_current_OS */

		sts = di$give_pathname(	osnum		= OM_Gw_current_OS,
					pathname	= head_path );
		as$status( sts = sts, msg = "Error in mc give_pathname" );
		/*" head_path : %s\n", head_path */

		sts = di$give_pathname(	osnum		= mac_def.osnum,
					pathname	= mac_path );
		as$status( sts = sts, msg = "Error in mc give_pathname" );
		/*" mac_path : %s\n", mac_path */
		
		/*" find %s in mac_path\n", CHG_PATH */
		index = ACSlocate_pattern( CHG_PATH, mac_path );
		if( index != -1 )
			sprintf( mgr_path, "%s:%s%s:constructs:%s", 
					head_path, 
					NEW_PATH, 
					&mac_path[index + strlen( CHG_PATH )],
					mac_name );

		else	sprintf( mgr_path, "%s%s:models:%s",
					head_path,
					mac_path,
					mac_name );

		/*" mgr_path : %s\n", mgr_path */
	}

	/*" mgr_path : %s, find model_mgr GRid \n", mgr_path */
	model_mgr->objid = NULL_OBJID;
	sts = di$translate(	objname	= mgr_path,
				osnum	= OM_Gw_current_OS,
				p_objid	= &model_mgr->objid,
				p_osnum	= &model_mgr->osnum );
/*	as$status( sts = sts, msg = "Error in mc translate" ); */
	/*" model_mgr : id/os = (%d/%d)\n", model_mgr->objid, model_mgr->osnum */

	/* sts == DIR_W_NAME_NOT_FOUND */
	if( !(sts&1)){

		/*| create directory and model_mgr associed to the definition */

		sts = get_dir(	mgr_path,
				0, 
				strlen(mgr_path), 
				&new_beg, 
				my_dir );
		as$status( sts = sts, msg = "Error in fct get_dir" );
 
		while( my_dir[0] != '\0' ) {

			dir_id.objid = NULL_OBJID;
			dir_id.osnum = OM_Gw_current_OS;

			sts = ACtran_or_make( OM_Gw_current_OS, 
						my_dir, &dir_id );
			as$status( sts = sts, msg = "Error in fct ACtran_or_make" );

			sts = get_dir(	mgr_path, 
					new_beg, 
					strlen(mgr_path), 
					&new_beg, 
					my_dir );
			as$status( sts = sts, msg = "Error in fct get_dir" );
		}

		/*| construction of model_mgr */
		model_mgr->objid = NULL_OBJID;
		model_mgr->osnum = OM_Gw_current_OS;
		sts = om$construct(	classid	= OPP_ACmodel_mgr_class_id,
					p_objid = &model_mgr->objid );
		as$status( sts = sts, msg = "Error in mc construct" );
		/*" model_mgr : id/os = (%d/%d)\n", model_mgr->objid, model_mgr->osnum */

		/*| add name of model_mgr in directory */
		sts = di$add_name(	objname	= mgr_path,
					objid	= model_mgr->objid,
					osnum 	= model_mgr->osnum );
		as$status( sts = sts, msg = "Error in mc add_name" );
		if( sts == DIR_W_NAME_NOT_FOUND )
			printf(" pb with dir \n");
	}
	/*" model_mgr : id/os = (%d/%d)\n", model_mgr->objid, model_mgr->osnum */

return OM_S_SUCCESS;
}

end implementation ACheader;

