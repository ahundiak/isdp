class implementation VLpcText;

#include "nddef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vlsdldef.h"
#include "vlpcdef.h"
#include "vlmsg.h"

from	ACrg_collect	import	ACget_named_attribute;

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
        /*
         * layout:      Occurence Name - Design File.
         */

	strcpy( info->type, "Profile Card ( Text )" );

        *msg = MSSUCC;

        return(OM_S_SUCCESS);
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */

        *msg    = MSSUCC ;

	myDef->info             = VL_I_ObjProfileCards ;

        sts     = OM_S_SUCCESS ;

        return sts ;
}

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
long			sts;
struct	GRobj_env	Support, Cs;
extern	long		VLcomputeTxtPC();
struct	GRid		Cartouche;
struct	GRid		AsCs;
int			count;
struct	ACrg_coll	attr;
char			cmd[DI_PATH_MAX * 2];
long			loc_msg;
struct	GRid		txtCol;

	/* Initialization */
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					VLPC_ATTRIBUTES_BOX,
					&txtCol,
					NULL, NULL ),
			targetid = my_id );
	if( sts & loc_msg & 1 ){
		strcpy( attr.name, VLSDL_FILE_PATH );
		sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
						( &loc_msg, &attr ),
				targetid = txtCol.objid,
				targetos = txtCol.osnum );
		if( sts & loc_msg & 1 ){

			sprintf( cmd, "rm %s", attr.desc.value.att_txt );
			system( cmd );
		}
	}

	// Stiffner
	sts = om$send(	msg	= message NDmacro.ACreturn_foot( msg, "",
					&Support.obj_id,
					&Support.mod_env.md_env.matrix_type,
					Support.mod_env.md_env.matrix ),
			targetid = list[0].objid,
			targetos = list[0].osnum );
	if( ! (sts & *msg & 1)){ *msg = ND_COMP_FAIL; return OM_W_ABORT; }
	Support.mod_env.md_id	= md_env->md_id;

	// Cartouche
	sts = om$send(	msg	= message NDmacro.ACreturn_foot( msg, "",
					&Cartouche,
					NULL, NULL ),
			targetid = list[1].objid,
			targetos = list[1].osnum );
	if( ! (sts & *msg & 1)){ *msg = ND_COMP_FAIL; return OM_W_ABORT; }

	sts = om$send(	msg	 = message NDnode.NDget_objects(
					ND_ROOT,
					&AsCs,
					1,
					NULL,
					0, 0, &count ),
			targetid = Cartouche.objid,
			targetos = Cartouche.osnum );

	sts = om$send(	msg	 = message NDnode.ASreturn_go(
						&Cs.obj_id,
						&Cs.mod_env.md_env.matrix_type,
						Cs.mod_env.md_env.matrix ),
			targetid = AsCs.objid,
			targetos = AsCs.osnum );
	if( ! (sts & 1)){ *msg = ND_COMP_FAIL; return OM_W_ABORT; }

	Cs.mod_env.md_id.osnum	= Cs.obj_id.osnum;
	Cs.mod_env.md_id.objid	= md_env->md_id.objid;

	*msg = 
	VLcomputeTxtPC( &Cs, &Cartouche, &Support,
						fcount, feet_list, md_env );
	if( ! (*msg & 1)){ *msg = ND_COMP_FAIL; return OM_W_ABORT; }

	*msg	= ND_COMP_SUCC;

return	OM_S_SUCCESS;
}

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
long			sts;
struct	ACrg_coll	attr;
char			cmd[DI_PATH_MAX * 2];
long			loc_msg;
struct	GRid		txtCol;

	// delete ASCII file.
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					VLPC_ATTRIBUTES_BOX,
					&txtCol,
					NULL, NULL ),
			targetid = my_id );
	if( sts & loc_msg & 1 ){
		strcpy( attr.name, VLSDL_FILE_PATH );
		sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
						( &loc_msg, &attr ),
				targetid = txtCol.objid,
				targetos = txtCol.osnum );
		if( sts & loc_msg & 1 ){

			sprintf( cmd, "rm %s", attr.desc.value.att_txt );
			system( cmd );
		}
	}

	sts = om$send(	msg	 = message VLpcAbst.GRdelete( msg, md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );

return	sts;
}



end implementation VLpcText;


