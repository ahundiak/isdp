class implementation VLjunction;

#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"AS_status.h"
#include	"grmacros.h"
#include	"ACrg_collect.h"

#include	"vlmiscmacros.h"
#include	"vljunction.h"
#include        "VDmsg.h"
#include        "vlmsg.h"

extern OMuword	OPP_nci_macro_class_id,
		OPP_VLpinjig_class_id;

/* ========================================================================== */
method ACconstruct_feet (               IGRlong         *msg;
                                        IGRint          cn_type;
                                        IGRint          count;
                         struct         GRid            list[];
                         struct         GRmd_env        *md_env;
                                        IGRint          *fcount;
                         struct         GRid            *feet_list )
{

	IGRint		sts=OM_S_SUCCESS;

	/* Initialize */
	*msg    = MSSUCC;
	*fcount = 0;

	/* <graphic> foot */
	sts = vl$return_foot ( msg    = msg,
			       objId  = &list[IDX_JU_GRA],
			       objEnv = md_env,
			       footId = &feet_list[IDX_JU_GRA] );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(graphic)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	(*fcount)++;

	/* <collect> foot */
	sts = vl$return_foot ( msg    = msg,
			       objId  = &list[IDX_JU_COL],
			       objEnv = md_env,
			       footId = &feet_list[IDX_JU_COL] );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(collect)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	(*fcount)++;

	/* <measure> foot */
	sts = vl$return_foot ( msg    = msg,
			       objId  = &list[IDX_JU_MEA],
			       objEnv = md_env,
			       footId = &feet_list[IDX_JU_MEA] );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(measure)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	VLreturn_graphic (		IGRlong		*msg;
				struct	GRmd_env	*Env;
				struct	GRobj_env	*graphic	)
{
	IGRint	sts=OM_S_SUCCESS;

	/* Initialize */
	graphic->obj_id.objid = NULL_OBJID;

	/* Get <graphic> foot */
	sts = om$send ( msg = message NDmacro.ACreturn_foot (
					msg,
					NAM_JU_GRA,
					&graphic->obj_id,
					&graphic->mod_env.md_env.matrix_type,
					graphic->mod_env.md_env.matrix ),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "ACreturn_foot(graphic)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Complete info (if possible) */
	graphic->mod_env.md_id.osnum = graphic->obj_id.osnum;
	if (Env)	graphic->mod_env.md_id.objid = Env->md_id.objid;

wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	VLreturn_collect (		IGRlong		*msg;
				struct	GRid		*collect	)
{
	IGRint	sts=OM_S_SUCCESS;

	/* Initialize */
	collect->objid = NULL_OBJID;

	/* Get <collect> foot */
	sts = om$send ( msg = message NDmacro.ACreturn_foot
				( msg, NAM_JU_COL, collect, NULL, NULL),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "ACreturn_foot(collect)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACshow_data (		IGRlong		*msg	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACshow_data (msg),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACshow_data",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 AClist_attribute (		IGRlong		*msg;
					IGRint		list_len;
				struct	ACrg_coll	*list_att;
					IGRint		*nb_attr	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.AClist_attribute
				( msg, list_len, list_att, nb_attr ),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACget_named_attribute (	IGRlong		*msg;
				struct	ACrg_coll	*attrib	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, attrib ),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACget_named_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACget_attribute_at_index (		IGRlong		*msg;
						IGRint		index;
					struct	ACrg_coll	*attrib	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACget_attribute_at_index
					( msg, index, attrib ),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACget_attribute_at_index",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACadd_list_attribute (		IGRlong		*msg;
					IGRint		list_len;
				struct	ACrg_coll	*list_att	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACadd_list_attribute
				( msg, list_len, list_att),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACadd_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACmod_list_attribute (		IGRlong		*msg;
					IGRint		list_len;
				struct	ACrg_coll	*list_att	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACmod_list_attribute
				( msg, list_len, list_att),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACmod_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACset_list_attribute (		IGRlong		*msg;
					IGRint		list_len;
				struct	ACrg_coll	*list_att	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
				( msg, list_len, list_att),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACset_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACget_prop_mgr (	IGRshort	*prop_mgr	)
{
	IGRint	sts=OM_S_SUCCESS;
	IGRlong	msg;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect (&msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & msg)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACget_prop_mgr (prop_mgr),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACget_prop_mgr",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACchg_prop_mgr (	IGRshort	mask;
				IGRshort	prop_mgr	)
{
	IGRint	sts=OM_S_SUCCESS;
	IGRlong	msg;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect (&msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & msg)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACchg_prop_mgr
					( mask, prop_mgr),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACchg_prop_mgr",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACadd_attribute_by_type (	IGRlong		*msg;
					IGRint		type;
					IGRchar		*name;
					IGRchar		*syntax	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACadd_attribute_by_type
					( msg, type, name, syntax ),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACadd_attribute_by_type",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACrem_attribute (	IGRlong		*msg;
				IGRchar		*name	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACrem_attribute
					( msg, name ),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACrem_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACrem_att_at_index (	IGRlong		*msg;
				IGRint		index	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACrem_att_at_index
					( msg, index ),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACrem_att_at_index",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	 ACmod_attribute (	IGRlong		*msg;
				IGRchar		*name;
				IGRchar		*syntax	)
{
	IGRint	sts=OM_S_SUCCESS;
struct	GRid	foot;

	/* Get <collect> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_collect ( msg, &foot),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Send message to <collect> foot */
	sts = om$send ( msg = message ACrg_collect.ACmod_attribute
					( msg, name, syntax ),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACmod_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	return(sts);
}
/* ========================================================================== */


method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        IGRlong            	sts ;   	/* OM return code       */
        OM_S_CHANSELECT         Cselect;
        IGRuint                 Ccount;
        OM_S_OBJECT_LINKAGE     *Clist=NULL;
	GRclassid		cid;

        myDef->info  = VD_I_ObjRoot ;
        myDef->type  = 0 ;

        om$make_chanselect ( channame     = "GRconnector.to_owners",
                             p_chanselect = &Cselect );

     	om$get_channel_count( osnum 	   = OM_Gw_current_OS,
                              objid 	   = my_id,
                              p_chanselect = &Cselect,
                              count 	   = &Ccount);

	if ( Ccount != 1 )	goto quit;

        Clist = om$calloc ( num       = Ccount,
                            structure = OM_S_OBJECT_LINKAGE );

        om$get_channel_objects ( osnum        = OM_Gw_current_OS,
                                 objid        = my_id,
                                 p_chanselect = &Cselect,
                                 list         = Clist,
                                 size         = Ccount,
                                 count        = &Ccount );

        om$get_classid( osnum     = Clist[0].osnum,
                        objid     = Clist[0].S_objid,
                        p_classid = &cid);

        if( om$is_ancestry_valid( superclassid = OPP_nci_macro_class_id,
                                  subclassid   = cid  ) == OM_S_SUCCESS )
	{
        	myDef->info             = VL_I_Obj3DEdgeAtt;
        	myDef->type             = 0 ;
	}
        else if( om$is_ancestry_valid( superclassid = OPP_VLpinjig_class_id,
                                   subclassid   = cid  ) == OM_S_SUCCESS )
        {
                myDef->info             = VL_I_ObjPinJig;
                myDef->type             = 0 ;
        }

quit :
        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */

end implementation VLjunction;
