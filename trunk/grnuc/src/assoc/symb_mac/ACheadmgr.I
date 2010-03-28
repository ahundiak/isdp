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
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grerr.h"
#include "exmacros.h"

#define	AS_DEBUG

#define	MAX_NB_MOD	5

#define	CHG_PATH	"constructs_lib"
#define	NEW_PATH	"models_lib"

from	ACcpx_defn	import	ACgive_name;

extern	GRclassid	OPP_ACmodel_mgr_class_id;


/* ************* MSG ACget_model_mgr () *******************************	*/

method ACget_model_mgr( IGRlong *rc; struct GRid *model_mgr )

{
IGRlong		sts, msg;
IGRint		index;
IGRint		new_beg;
IGRchar		my_dir[PATH_MAX];
IGRint		i;
struct	GRid	dir_id;
struct	GRid	mac_def;
IGRchar		*mac_name;
IGRchar		head_path[PATH_MAX];
IGRchar		mac_path[PATH_MAX];
IGRchar		mgr_path[PATH_MAX];

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

