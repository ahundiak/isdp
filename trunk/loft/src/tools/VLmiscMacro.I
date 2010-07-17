class implementation VLabstract ;

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"grdpbmacros.h"
#include	"grmacros.h"

#include	"vlmiscmacros.h"

/*	#define	TRACE	*/

/* ========================================================================== */
IGRint	VLreturn_foot	(		IGRlong		*msg,
					IGRchar		*name,
				struct	GRid		*objId,
				struct	GRmd_env	*objEnv,
				struct	GRid		*footId,
				struct	GRmd_env	*footEnv	)
{
		IGRint		sts=MSFAIL;
	struct	GRmd_env	env;

	/* Send the famous message */
	sts = om$send ( msg = message NDmacro.ACreturn_foot (
					msg,
					name,
					footId,
					&env.md_env.matrix_type,
					env.md_env.matrix ),
			senderid = NULL_OBJID,
			targetid = objId->objid,
			targetos = objId->osnum );
	if (!(sts & 0x00000001 & (*msg)))	goto wrapup;

	/* Complete foot environ */
	if (footEnv)	footEnv->md_env = env.md_env;
	if ( (footEnv) && (objEnv) ) {
			footEnv->md_id.objid = objEnv->md_id.objid;
			footEnv->md_id.osnum = footId->osnum;
	}

wrapup:
	/* The End */
	return (sts);
}
/* ========================================================================== */
IGRint	VLconstPlaceNameState (		IGRlong		*msg,
					GRclassid	classid,
					IGRint		prop,
					IGRchar		rep,
					IGRchar		*MacName,
					IGRint		number,
				struct	GRid		*template,
				struct	GRmd_env	*Env,
					IGRboolean	ChgState,
					IGRchar		mask,
					IGRchar		state,
					IGRchar		*MatchKey,
					IGRchar		*CobName,
					OM_E_WRT_FLAG	mode,
				struct	GRid		*MatchId,
					IGRchar		*CommonName,
				enum	GRdpmode	dpmode,
					OM_S_OBJID	CobMyId,
				struct	GRid		*occ_id,
				struct	GRsymbology	*occ_symb,
					IGRchar		*occ_path	)
{
	struct	GRmd_env	loc_env;
		IGRlong		siz, ret;
	struct	GRid		loc_id, nul_id;
		IGRint		sts=OM_S_SUCCESS, suc=1;
	struct	GRsymbology	loc_symb;
		IGRchar		loc_path[DI_PATH_MAX], occ_name[DI_PATH_MAX];
		OM_S_MESSAGE	VLmsg;
	struct
	{
			IGRlong		*msg;
			IGRchar		*matchKey;
		struct	GRid		*matchId;
			IGRchar         *common_name;
		struct GRsymbology	*tar_symb;
			IGRchar		*tar_path;
			IGRchar		*occ_name;
		struct GRid		tar_geom;
		enum   GRdpmode		*dpmode;
	} VLsymb_temp;

	/* Initialize */
	if (Env)	gr$get_module_env ( msg    = msg,
					    sizbuf = &siz,
					    buffer = &loc_env,
					    nret   = &ret );
	else		loc_env = *Env;

	/* Construct the <class> macro occurence */
	if (!classid)	goto wrapup;
	loc_id.objid = NULL_OBJID;
	loc_id.osnum = loc_env.md_id.osnum;
	sts = om$construct ( classid = classid,
			     osnum   = loc_id.osnum,
			     p_objid = &loc_id.objid );
	as$status ( sts    = sts,
                    msg    = "om$construct",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Place the <class> macro occurence */
	if (!MacName)	goto wrapup;
	nul_id.objid = NULL_OBJID;
	nul_id.osnum = loc_env.md_id.osnum;
	sts = om$send ( msg = message ACncpx.ACmplace_from_def
		( &suc, prop, rep, MacName, number, template, &nul_id, Env),
			senderid = NULL_OBJID,
			targetid = loc_id.objid,
			targetos = loc_id.osnum  );
	*msg = suc;
	as$status ( sts    = sts,
		    msg    = "ACncpx.ACmplace_from_def",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Delete macro if no physical foot */
	suc = 0;
	sts = om$send ( msg = message GRowner.GRget_number_components
						( msg, &suc),
			senderid = NULL_OBJID,
			targetid = loc_id.objid,
			targetos = loc_id.osnum  );
#ifdef TRACE
printf( "GRget_number_components (%d|%d) returns %d components\n",
	loc_id.osnum, loc_id.objid, suc);
#endif
	as$status ( sts    = sts,
		    msg    = "ACncpx.ACmplace_from_def",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	if (!suc) {
		gr$delete_object ( msg       = msg,
			 	   md_env    = Env,
				   object_id = &loc_id );
		loc_id.objid = NULL_OBJID;
		goto wrapup;
	}

	/* Set state */
	if (ChgState) {
		sts = om$send ( msg = message NDnode.NDchg_state ( mask, state),
				senderid = NULL_OBJID,
	                        targetid = loc_id.objid,
	                        targetos = loc_id.osnum );
	        as$status ( sts    = sts,
			    msg    = "NDnode.NDchg_state",
	                    test   = (!(sts & 0x00000001)),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Name the <class> macro occurence */
	if (MatchKey) {

		loc_path[0] = '\0';

		VLsymb_temp.msg         = msg;
		VLsymb_temp.matchKey    = &MatchKey[0];
		VLsymb_temp.matchId     = MatchId;
		VLsymb_temp.common_name = &CommonName[0];
		VLsymb_temp.tar_symb    = &loc_symb;
		VLsymb_temp.tar_path    = &loc_path[0];
		VLsymb_temp.occ_name    = &occ_name[0];
		VLsymb_temp.tar_geom    = loc_id;
		VLsymb_temp.dpmode      = &dpmode;

		sts = om$make_message ( classname  = CobName,
					methodname = "VLsymbNameDir",
					size       = sizeof (VLsymb_temp),
					p_arglist  = &VLsymb_temp,
					p_msg      = &VLmsg );
		as$status ( sts    = sts,
			    msg    = "om$make_message(VLsymbNameDir)",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );

		sts = om$send ( msg      = &VLmsg,
				mode     = mode,
				senderid = NULL_OBJID,
				targetid = CobMyId );
		as$status ( sts    = sts,
			    msg    = "VLlocateCmd.VLsymbNameDir",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

wrapup:
	if (occ_id)	*occ_id = loc_id;
	if (occ_symb)	*occ_symb = loc_symb;
	if (occ_path)	strcpy ( occ_path, loc_path);
	return (sts);
}
/* ========================================================================== */

end implementation VLabstract;
