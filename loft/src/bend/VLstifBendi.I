class implementation VLstifBend;

#include	"vlprototype.h"
#include	"AS_status.h"
#include	"nddef.h"
#include	"grmacros.h"
#include	"bsparameters.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"asmacros.h"

#include	"vsmiscmacros.h"
#include	"vspart.h"
#include	"vsdpb.h"
#include	"vssectiondef.h"
#include	"vsbeam.h"
#include	"vsbeamdef.h"
#include	"vsbeammacros.h"

#include	"vlstifbend.h"
#include	"vlmsg.h"

extern	GRclassid	OPP_VSbeam_class_id;

/*	#define	TRACE	*/

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{

		IGRint		sts=OM_S_SUCCESS, i;
		IGRmatrix	RefMat;
	struct	ret_struct	str;
	struct	GRobj_env	GoTemp, BaseSrf;
		IGRchar		srfName[DI_PATH_MAX];
	struct	GRvg_construct	cst;

#ifdef TRACE
printf("\t>>> Enter in VLstifBendi.ACconstruct_feet\n");
#endif

	/* Initialize */
	*fcount = MACRO_SB_FFEET;
	for ( i=0; i<*fcount; i++) {
		feet_list[i].objid = NULL_OBJID;
		feet_list[i].osnum = md_env->md_id.osnum;
	}
	VLinitCnst (&cst);

	/* Get the coordinate system matrix */
	sts = om$send ( msg = message NDnode.NDgive_structure 
						( msg, &str, md_env),
			targetid = list[IDX_SBT_CSYS].objid,
			targetos = list[IDX_SBT_CSYS].osnum );
	as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(CSYS)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	memcpy ( (IGRchar *)RefMat, (IGRchar *) str.var.ref_st.t,
                 (IGRint) sizeof(IGRmatrix) );

	/* Get the footname of the surface */
	sts = om$send ( msg = message NDnode.NDgive_structure 
						( msg, &str, md_env),
			targetid = list[IDX_SBT_SIDX].objid,
			targetos = list[IDX_SBT_SIDX].osnum );
	as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(SIDX)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve the support surface */
	sts = om$send ( msg = message NDmacro.ACreturn_foot (
					msg,
					"",
					&GoTemp.obj_id,
					&GoTemp.mod_env.md_env.matrix_type,
					GoTemp.mod_env.md_env.matrix ),
			targetid = list[IDX_SBT_BSRF].objid,
			targetos = list[IDX_SBT_BSRF].osnum );
	as$status ( sts    = sts,
                    msg    = "NDmacro.ACreturn_foot(BSRF)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	GoTemp.mod_env.md_id.osnum = GoTemp.obj_id.osnum;
	GoTemp.mod_env.md_id.objid = md_env->md_id.objid;

	if ( (vs$is_ancestry_valid ( object  = &GoTemp.obj_id,
				     classid = OPP_VSbeam_class_id ) ) ) {

		srfName[0] = '\0';
		sprintf ( srfName, "%s:%s:%s", VS_K_bmGrCmpName, VS_K_bmBody,
			  str.var.text_st.text_string );

		sts = om$send ( msg = message NDmacro.ACreturn_foot (
					msg,
					srfName,
					&BaseSrf.obj_id,
					&BaseSrf.mod_env.md_env.matrix_type,
					BaseSrf.mod_env.md_env.matrix ),
				targetid = GoTemp.obj_id.objid,
				targetos = GoTemp.obj_id.osnum );
		as$status ( sts    = sts,
	                    msg    = "NDmacro.ACreturn_foot(base surface)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		BaseSrf.mod_env = GoTemp.mod_env;

/*		BaseSrf.mod_env.md_id.osnum = BaseSrf.obj_id.osnum;
		BaseSrf.mod_env.md_id.objid = md_env->md_id.objid;  */
	}
	else	goto wrapup;

	/* Call computation function */
	sts = VLcreStifBend ( &GoTemp, &BaseSrf, &cst, RefMat,
			      str.var.text_st.text_string,
                              fcount, feet_list, msg );
        if (!(sts & 0x00000001 & (*msg)))
          goto wrapup;

wrapup:

#ifdef TRACE
printf("\t<<< Exit from VLstifBendi.ACconstruct_feet\n");
#endif

	return(sts);
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjInvBendLine;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLstifBend;
