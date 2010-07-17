class implementation VLpcView;

#include "AS_status.h"
#include "nddef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vlmsg.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
        /*
         * layout:      Occurence Name - Design File.
         */

	strcpy( info->type, "Profile Card ( Graphic )" );

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

} /* VDgetObjDef */

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
long			sts;
int			suc, count, max_ftcount=*fcount;
struct  GRid		BendLnId;
struct	GRobj_env	Support, Cs, rgPt, Border;
char			ViewName[DI_PATH_MAX];
struct	ret_struct	st;
extern	long		VLcomputeGraphicPC();

	/* Initialization */
	*fcount = 0;

	// Stiffner
	sts = om$send(	msg	= message NDmacro.ACreturn_foot( msg, "",
					&Support.obj_id,
					&Support.mod_env.md_env.matrix_type,
					Support.mod_env.md_env.matrix ),
			targetid = list[0].objid,
			targetos = list[0].osnum );
	Support.mod_env.md_id	= md_env->md_id;

	// Cs
	sts = om$send(	msg	= message NDmacro.ACreturn_foot( msg, "",
					&Cs.obj_id,
					&Cs.mod_env.md_env.matrix_type,
					Cs.mod_env.md_env.matrix ),
			targetid = list[1].objid,
			targetos = list[1].osnum );
	Cs.mod_env.md_id	= md_env->md_id;

	// Get the Border
        sts = om$send(  msg      = message NDnode.NDget_objects(
                                                ND_ROOT,
                                                &Border.obj_id, 1, NULL,
                                                0, 0, &count ),
                                senderid = NULL_OBJID,
                                targetid = list[1].objid,
                                targetos = list[1].osnum );
        Border.mod_env = *md_env;

	// ViewName
	sts = om$send(	msg	= message NDmacro.ACgive_structure( &suc, NULL,
					"", &st, md_env ),
			targetid = list[2].objid,
			targetos = list[2].osnum );
	strcpy( ViewName, st.var.text_st.text_string );

	// get point
	sts = om$send(	msg	= message NDmacro.ACreturn_foot( msg, "",
					&rgPt.obj_id,
					&rgPt.mod_env.md_env.matrix_type,
					rgPt.mod_env.md_env.matrix ),
			targetid = list[3].objid,
			targetos = list[3].osnum );
	rgPt.mod_env.md_id	= md_env->md_id;

	*msg = 
	VLcomputeGraphicPC( &Support, &Cs, ViewName, &rgPt, &Border,
			    max_ftcount, fcount, feet_list, md_env );

	if( !strcmp( ViewName, "side" ) )
	{
	    sts = VLplaceBendLines( msg, &Support, &Border, &BendLnId );
	    if( sts&*msg&1 )
	    {
		feet_list[(*fcount)] = BendLnId;
		(*fcount)++;
	    }
	}

return	OM_S_SUCCESS;
}

end implementation VLpcView;

