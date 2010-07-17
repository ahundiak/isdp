/*f <VLbookFunk.I> contains a set of functions used for loftbook preparation. */

class implementation VLabstract;

#include	<stdio.h>
#include	<math.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"ACattrib.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "grmacros.h"
#include        "exdef.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "bserr.h"
#include        "bsconic.h"
#include        "asmacros.h"
#include        "expression.h"
#include        "expmacros.h"

#include        "vsmiscmacros.h"
#include        "vsioproto.h"

#include        "vlbook.h"
#include        "vlbookdef.h"
#include        "vlconnect.h"
#include        "vlmsg.h"
#include        "vlmiscmacros.h"

#include	"bscveval.h"
#include	"bspl_cv_int.h"
#include	"bspl_pl.h"
#include	"bspj_pt_sf.h"
#include	"bspl_cv_int.h"
#include	"bsxtractpar.h"

from	expression	import	give_syntax;
from	SMInfPlane	import	SMgive_rel_position;
from	SMframe		import	SMgive_rel_position;

extern	GRclassid	OPP_SMInfPlane_class_id;
extern	GRclassid	OPP_SMframe_class_id;
extern	GRclassid	OPP_VLconnect_class_id;

/*	#define	TRACE	*/
/*	#define	INTER	*/

/* ========================================================================== */
IGRlong	VLcreateDirectory ( struct	GRid	*check,
					IGRchar	usr[],
					IGRchar	name[]	)
{
		IGRlong		ret;
		IGRchar		path[DI_PATH_MAX];

	/* Initialize */
	path[0] = '\0';
	sprintf ( path, "%s:%s", usr, name);

	/* Check if directory exists */
	check->objid = NULL_OBJID;
	ret = di$translate ( objname = path,
			     p_objid = &check->objid );

	if (check->objid == NULL_OBJID) {
		ret = di$mkdir ( dirname = path,
				 osnum   = check->osnum );
		if (ret != DIR_S_SUCCESS) {
                	di$report_error ( sts     = ret,
	                                  comment = "\tdi$mkdir()");
                	return (ret);	}
	}
	else if (ret != DIR_S_SUCCESS) {
                di$report_error ( sts     = ret,
                                  comment = "\tdi$translate()");
                return (ret);	}

	return (ret);
}
/* ========================================================================== */
IGRlong	VLgenerateDirectories (	struct	GRmd_env	*Env,
					IGRchar		usr[]	)
{
		IGRint		sts=OM_S_SUCCESS;
		IGRlong		ret;
		IGRchar		path[DI_PATH_MAX];
	struct	GRid		check;

	/* Initialize */
	usr[0] = '\0';

	/* Retrieve current osnum absolute path */
        ret = di$give_pathname ( osnum    = Env->md_id.osnum,
                                 pathname = path );
        if (ret != DIR_S_SUCCESS) {
                di$report_error ( sts     = ret,
                                  comment = "\tdi$give_pathname()");
                sts = MSFAIL; goto wrapup; }

	/* Check if the user directory exist */
	sprintf ( usr, "%s:usr", path);
	check.objid = NULL_OBJID;
	check.osnum = Env->md_id.osnum;
	ret = di$translate ( objname = usr,
			     p_objid = &check.objid );
	if (ret != DIR_S_SUCCESS) {
                di$report_error ( sts     = ret,
                                  comment = "\tdi$translate()");
                sts = MSFAIL; goto wrapup; }

	/* Create <aft> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_AFT);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(AFT)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <baseline> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_BSL);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(BSL)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <butt> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_BUT);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(BUT)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <buttock> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_BTK);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(BTK)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <centerline> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_CTL);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(CTL)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <deck> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_DCK);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(DCK)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <flat-of-bottom> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_FOB);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(FOB)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <flat-of-side> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_FOS);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(FOS)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <frame> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_FRM);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(FRM)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <fwd> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_FWD);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(FWD)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <hull> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_HUL);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(HUL)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <knuckle> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_KNK);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(KNK)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <longitudinal> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_LON);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(LON)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <mid> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_MID);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(MID)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <ori> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_ORI);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(ORI)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <seam> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_SEA);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(SEA)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <station> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_STA);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(STA)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <stem> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_STM);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(STM)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <stern> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_STN);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(STN)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <tangent> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_TGT);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(TGT)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <waterline> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_WTL);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(WTL)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create <infinite plane> directory */
	sts = VLcreateDirectory ( &check, usr, VL_BOOK_DIR_PLA);
	as$status ( sts	   = sts,
		    msg	   = "VLcreateDirectory(WTL)",
		    test   = sts != DIR_S_SUCCESS,
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Success completion */
	sts = OM_S_SUCCESS;

wrapup :
	return (sts);
}
/* ========================================================================== */
IGRlong	VLgetRealBookData (		IGRchar		*path,
				struct	GRmd_env	*Env,
				struct	GRobj_env	*Real	)
{
		IGRint		sts=OM_S_SUCCESS, suc;
		IGRlong		ret;
	struct	GRid		macro, templ;

	/* Initialize */
	Real->obj_id.objid = NULL_OBJID;
	
	/* Translate name in EMS directories */
	ret = di$translate ( objname = path,
			     p_objid = &macro.objid,
			     p_osnum = &macro.osnum );
	if (ret != DIR_S_SUCCESS) 	return	MSFAIL;

	/* Retrieve template of the macro */
	sts = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
                                        ( &suc, IDX_VCT_OBJ, &templ ),
                        senderid = NULL_OBJID,
                        targetid = macro.objid,
                        targetos = macro.osnum );
        as$status ( sts    = sts,
                    msg    = "ACfind_exp_temp_obj",
                    test   = (!(sts & 0x00000001 & suc)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve real data (thru reference file) */
	sts = vl$return_foot ( msg     = &ret,
			       objId   = &templ,
			       objEnv  = Env,
			       footId  = &Real->obj_id,
			       footEnv = &Real->mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot()",
                    test   = (!(sts & 0x00000001 & ret)),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
wrapup:
	return (sts);
}
/* ========================================================================== */
IGRboolean VLcheckInDirectory (	struct	GRid		*Elem,
				struct	GRmd_env	*Env,
					IGRchar		*path,
					IGRchar		*name	)
{
		IGRint		i, sts=OM_S_SUCCESS;
		IGRchar		root[DI_PATH_MAX], tent[DI_PATH_MAX];
	struct	GRobj_env	Real;

	/* Construct root name */
	root[0] = '\0';
	sprintf ( root, "%s:%s", path, name);

	/* 1000 first tentatives */
	for ( i=0; i<1000; i++) {

		tent[0] = '\0';
		if (i<100)	sprintf ( tent, "%s_%02d", root, i);
		else		sprintf ( tent, "%s_%03d", root, i);

		sts = VLgetRealBookData ( tent, Env, &Real);
		if (sts & 1) {
			if (  (Elem->objid == Real.obj_id.objid)
			   && (Elem->osnum == Real.obj_id.osnum) )
				return FALSE;
		}
		else	break;
	}

	return TRUE;
}
/* ========================================================================== */
IGRchar *VLindexToChapterName (IGRint	idx)
{
	switch (idx) {
		case VL_BOOK_IDX_A:	return (VL_BOOK_TIT_A);
		case VL_BOOK_IDX_B:	return (VL_BOOK_TIT_B);
		case VL_BOOK_IDX_C:	return (VL_BOOK_TIT_C);
		case VL_BOOK_IDX_D:	return (VL_BOOK_TIT_D);
		case VL_BOOK_IDX_E:	return (VL_BOOK_TIT_E);
		case VL_BOOK_IDX_F:	return (VL_BOOK_TIT_F);
		case VL_BOOK_IDX_G:	return (VL_BOOK_TIT_G);
		case VL_BOOK_IDX_H:	return (VL_BOOK_TIT_H);
		case VL_BOOK_IDX_I:	return (VL_BOOK_TIT_I);
		case VL_BOOK_IDX_J:	return (VL_BOOK_TIT_J);
		case VL_BOOK_IDX_K:	return (VL_BOOK_TIT_K);
		case VL_BOOK_IDX_L:	return (VL_BOOK_TIT_L);
		case VL_BOOK_IDX_M:	return (VL_BOOK_TIT_M);
		case VL_BOOK_IDX_N:	return (VL_BOOK_TIT_N);
		case VL_BOOK_IDX_O:	return (VL_BOOK_TIT_O);
		case VL_BOOK_IDX_P:	return (VL_BOOK_TIT_P);
		case VL_BOOK_IDX_Q:	return (VL_BOOK_TIT_Q);
		case VL_BOOK_IDX_R:	return (VL_BOOK_TIT_R);
		case VL_BOOK_IDX_S:	return (VL_BOOK_TIT_S);
		case VL_BOOK_IDX_T:	return (VL_BOOK_TIT_T);
		case VL_BOOK_IDX_U:	return (VL_BOOK_TIT_U);
		default:		return ("");
	}
}
/* ========================================================================== */
IGRchar *VLindexToDirName (IGRint	idx)
{
	switch (idx) {
		case VL_BOOK_IDX_AFT:	return (VL_BOOK_DIR_AFT);
		case VL_BOOK_IDX_BSL:	return (VL_BOOK_DIR_BSL);
		case VL_BOOK_IDX_CTL:	return (VL_BOOK_DIR_CTL);
		case VL_BOOK_IDX_FWD:	return (VL_BOOK_DIR_FWD);
		case VL_BOOK_IDX_HUL:	return (VL_BOOK_DIR_HUL);
		case VL_BOOK_IDX_MID:	return (VL_BOOK_DIR_MID);
		case VL_BOOK_IDX_ORI:	return (VL_BOOK_DIR_ORI);
		case VL_BOOK_IDX_BUT:	return (VL_BOOK_DIR_BUT);
		case VL_BOOK_IDX_BTK:	return (VL_BOOK_DIR_BTK);
		case VL_BOOK_IDX_DCK:	return (VL_BOOK_DIR_DCK);
		case VL_BOOK_IDX_FOB:	return (VL_BOOK_DIR_FOB);
		case VL_BOOK_IDX_FOS:	return (VL_BOOK_DIR_FOS);
		case VL_BOOK_IDX_FRM:	return (VL_BOOK_DIR_FRM);
		case VL_BOOK_IDX_KNK:	return (VL_BOOK_DIR_KNK);
		case VL_BOOK_IDX_LON:	return (VL_BOOK_DIR_LON);
		case VL_BOOK_IDX_SEA:	return (VL_BOOK_DIR_SEA);
		case VL_BOOK_IDX_STA:	return (VL_BOOK_DIR_STA);
		case VL_BOOK_IDX_STM:	return (VL_BOOK_DIR_STM);
		case VL_BOOK_IDX_STN:	return (VL_BOOK_DIR_STN);
		case VL_BOOK_IDX_TGT:	return (VL_BOOK_DIR_TGT);
		case VL_BOOK_IDX_WTL:	return (VL_BOOK_DIR_WTL);
		default:		return ("");
	}
}
/* ========================================================================== */
IGRlong	VLgetElemInDirectory (		IGRint		idx,
					IGRchar		usr[],
				struct	GRmd_env	*Env,
					IGRint		*num,
					IGRchar		**mac,
					IGRchar		**nam	)
{
		IGRint		i, sts=MSFAIL, array=0;
		IGRlong		msg;
		IGRchar		name[DI_PATH_MAX], path[DI_PATH_MAX];
		IGRchar		rexp[DI_PATH_MAX];
	struct	GRid		expr;
	struct	ret_struct	str;

	/* Initialize */
	*num = 0;
	if (idx == -1)	goto wrapup;
	if ( (mac) && (nam) )	array = 1;
	if (array) {	*mac = NULL;	*nam = NULL;	}
	name[0] = path[0] = rexp[0] = '\0';

	/* Macros occurence in directory */
	sprintf ( rexp, "%s:%s:*", usr, VLindexToDirName(idx) );
	di$start_ls ( regexp = rexp, ptr = num, options = OPT_LEVEL );
	if (!(*num))	goto wrapup;
	if (array) {
		*mac = om$calloc ( num = 100 * (*num), structure = IGRchar );
		*nam = om$calloc ( num = 100 * (*num), structure = IGRchar );

		for ( i=0; i<*num; i++) {

		di$fetch_ls ( line = path, index  = i );
		di$split ( pathname = path, name = &(*mac)[100*i] );
		sprintf ( name, "%s:%s", path, NAM_VCF_NAM);
		expr.objid = NULL_OBJID;
		expr.osnum = Env->md_id.osnum;
		msg = di$translate ( objname = name,
				     p_objid = &expr.objid,
			             p_osnum = &expr.osnum );
		if (msg != DIR_S_SUCCESS) 	return	MSFAIL;

		sts = om$send ( msg = message NDnode.NDgive_structure
					( &msg, &str, Env),
				senderid = NULL_OBJID,
				targetid = expr.objid,
				targetos = expr.osnum );
	        as$status ( sts    = sts,
	                    msg    = "NDmacro.NDgive_structure",
	                    test   = (!(sts & 0x00000001 & msg)),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		strcpy ( &(*nam)[100*i], str.var.text_st.text_string );
		}
	}
wrapup:
	return (sts);
}
/* ========================================================================== */
void	VLputElemInMultiField (		IGRint		idx,
					IGRchar		*usr,
				struct	GRmd_env	*Env,
					IGRchar		*form_ptr,
					IGRint		label	)
{
		IGRint	i, num;
		IGRchar	*mac, *nam;

	if (idx == -1)	return;

	/* Retrieve existing elements in directory */
	VLgetElemInDirectory ( idx, usr, Env, &num, &mac, &nam);

	/* Put these elements in multifield */
	FIfld_set_num_rows ( form_ptr, label, num);
	for ( i=0; i<num; i++) {
		FIfld_set_text ( form_ptr, label, i, 0, &mac[100*i], FALSE);
		FIfld_set_text ( form_ptr, label, i, 1, &nam[100*i], FALSE);
	}
	if (mac) { om$dealloc(ptr=mac); mac = NULL; }
	if (nam) { om$dealloc(ptr=nam); nam = NULL; }
}
/* ========================================================================== */
void	VLrenameInDir (	IGRint	idx, IGRchar	usr[]	)
{
		IGRint	num=0, i;
		IGRchar	root[DI_PATH_MAX], rexp[DI_PATH_MAX];
		IGRchar	old[DI_PATH_MAX], new[DI_PATH_MAX];

	if (idx == -1)	return;

	/* Find elements in directory */
	strcpy ( root, VLindexToDirName(idx) );
	sprintf ( rexp, "%s:%s:*", usr, root );
	di$start_ls ( regexp = rexp, ptr = &num, options = OPT_LEVEL );
	if (!num)	return;
	for ( i=0; i<num; i++) {
		di$fetch_ls ( line = old, index  = i );
		if (i<100)	sprintf ( new, "%s:%s:%s_%02d",
					  usr, root, root, i);
		else		sprintf ( new, "%s:%s:%s_%03d",
					  usr, root, root, i);
		di$rename ( oldname = old, newname = new );
	}
}
/* ========================================================================== */
void	VLdelElemInMultiField (		IGRint		idx,
					IGRchar		usr[],
				struct	GRmd_env	*Env,
					IGRchar		*form_ptr,
					IGRint		label	)
{
		IGRint		sts;
		IGRlong		msg;
        struct  GRid   		elem;
		IGRchar		path[DI_PATH_MAX];
	struct	GRobj_env	Real;

	VLgetElemInMultiField (	idx, usr, Env, form_ptr, label,
				&elem, path, &msg );
	if (msg == MSSUCC) {

		VLgetRealBookData ( path, Env, &Real );

                /* for TR179801009 */
		// if (Env->md_id.osnum == Real.mod_env.md_id.osnum)
                //        gr$delete_object ( msg          = &msg,
                //                           md_env       = &Real.mod_env,
                //                           object_id    = &Real.obj_id);

		sts = gr$delete_object ( msg          = &msg,
				         md_env       = Env,
				         object_id    = &elem,
				         display_flag = 0 );
	        as$status ( sts    = sts,
	                    msg    = "gr$delete_object()",
	                    test   = (!(sts & 0x00000001)),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		nd$exec_batch();
	}

wrapup:
	return;
}
/* ========================================================================== */
void	VLdisplayReal (		IGRint		idx,
				IGRchar		usr[],
			struct	GRmd_env	*Env,
				IGRchar		*form_ptr,
				IGRint		label,
			enum	GRdpmode	dpmode	)
{
		IGRint		i, num, sel=0;
		IGRchar		*mac, *nam, path[DI_PATH_MAX];
	struct	GRobj_env	elem;

	/* Retrieve existing elements in directory */
	VLgetElemInDirectory ( idx, usr, Env, &num, &mac, &nam);
	if (!num)	goto wrapup;

	for ( i=0; i<num; i++) {
		FIfld_get_select ( form_ptr, label, i, 0, &sel );
		if (sel == 1)	break;
	}
	if (!sel)	goto wrapup;
	else {	path[0] = '\0';
		sprintf ( path, "%s:%s:%s",
			  usr, VLindexToDirName(idx), &mac[100*i] );
		VLgetRealBookData ( path, Env, &elem);
		gr$display_object ( object_id = &elem.obj_id,
				    md_env    = &elem.mod_env,
				    mode      = dpmode );
	}

wrapup:
	if (mac) { om$dealloc(ptr=mac); mac = NULL; }
	if (nam) { om$dealloc(ptr=nam); nam = NULL; }
}
/* ========================================================================== */
void	VLverifyInDir (	IGRint chapter, IGRchar usr[],	IGRlong	*msg	)
{
	IGRint		num1=0, num2=0;
	IGRchar		exp1[DI_PATH_MAX], exp2[DI_PATH_MAX];;

	/* Initialize */
	exp1[0] = exp2[0] = '\0';
	*msg = VL_E_NO_BOOK_DATA;

	/* Treat separatly each chapter */
	switch (chapter) {
		case VL_BOOK_IDX_A:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_STA);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_B:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_C:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_STA);
			break;
		case VL_BOOK_IDX_D:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_BTK);
			break;
		case VL_BOOK_IDX_E:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_STM);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_F:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_STN);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_G:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_FOS);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			break;
		case VL_BOOK_IDX_H:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_FOS);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_I:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_FOB);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			break;
		case VL_BOOK_IDX_J:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_FOB);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_K:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_KNK);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_L:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_KNK);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			break;
		case VL_BOOK_IDX_M:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_KNK);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_BTK);
			break;
		case VL_BOOK_IDX_N:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_TGT);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_O:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_TGT);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			break;
		case VL_BOOK_IDX_P:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_TGT);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_BTK);
			break;
		case VL_BOOK_IDX_Q:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_DCK);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_R:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_DCK);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			break;
		case VL_BOOK_IDX_S:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_SEA);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		case VL_BOOK_IDX_T:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_BUT);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_WTL);
			break;
		case VL_BOOK_IDX_U:
			sprintf ( exp1, "%s:%s:*", usr, VL_BOOK_DIR_LON);
			sprintf ( exp2, "%s:%s:*", usr, VL_BOOK_DIR_FRM);
			break;
		default:
			printf( "Unknown chapter <%d>\n", chapter);
			return;
	}

	/* Are both directories not empty ? */
	di$ls ( regexp = exp1, ptr = &num1 );
	di$ls ( regexp = exp2, ptr = &num2 );
	if ( (num1) && (num2) )	*msg = VL_S_SUCCESS;
}
/* ========================================================================== */
void	VLgetLoftBookHeader (	VLlbHead	*Header	)
{
	Header->staS[0] = Header->rptS[0] = Header->endS[0] = '\0';
	Header->idxA = Header->idxB = -1;
	Header->plnA = Header->plnB = TRUE;
	Header->looA = TRUE;
	Header->looB = TRUE;

	switch (Header->chap) {
		case VL_BOOK_IDX_A:
			strcpy ( Header->staS, VL_S_BOOK_A_STA);
			strcpy ( Header->rptS, VL_S_BOOK_A_RPT);
			strcpy ( Header->endS, VL_S_BOOK_A_END);
			Header->idxA = VL_BOOK_IDX_STA;
			Header->looA = FALSE;
			Header->idxB = VL_BOOK_IDX_FRM;
			break;
		case VL_BOOK_IDX_B:
			strcpy ( Header->staS, VL_S_BOOK_B_STA);
			strcpy ( Header->rptS, VL_S_BOOK_B_RPT);
			strcpy ( Header->endS, VL_S_BOOK_B_END);
			Header->idxA = VL_BOOK_IDX_WTL;
			Header->looA = FALSE;
			Header->idxB = VL_BOOK_IDX_FRM;
			break;
		case VL_BOOK_IDX_C:
			strcpy ( Header->staS, VL_S_BOOK_C_STA);
			strcpy ( Header->rptS, VL_S_BOOK_C_RPT);
			strcpy ( Header->endS, VL_S_BOOK_C_END);
			Header->idxA = VL_BOOK_IDX_WTL;
			Header->looA = FALSE;
			Header->idxB = VL_BOOK_IDX_STA;
			break;
		case VL_BOOK_IDX_D:
			strcpy ( Header->staS, VL_S_BOOK_D_STA);
			strcpy ( Header->rptS, VL_S_BOOK_D_RPT);
			strcpy ( Header->endS, VL_S_BOOK_D_END);
			Header->idxA = VL_BOOK_IDX_WTL;
			Header->looA = FALSE;
			Header->idxB = VL_BOOK_IDX_BTK;
			break;
		case VL_BOOK_IDX_E:
			strcpy ( Header->staS, VL_S_BOOK_E_STA);
			strcpy ( Header->rptS, VL_S_BOOK_E_RPT);
			strcpy ( Header->endS, VL_S_BOOK_E_END);
			Header->idxA = VL_BOOK_IDX_STM;
			Header->plnA = FALSE;
			Header->idxB = VL_BOOK_IDX_FRM;
			break;
		case VL_BOOK_IDX_F:
			strcpy ( Header->staS, VL_S_BOOK_F_STA);
			strcpy ( Header->rptS, VL_S_BOOK_F_RPT);
			strcpy ( Header->endS, VL_S_BOOK_F_END);
			Header->idxA = VL_BOOK_IDX_STN;
			Header->plnA = FALSE;
			Header->idxB = VL_BOOK_IDX_FRM;
			break;
		case VL_BOOK_IDX_G:
			strcpy ( Header->staS, VL_S_BOOK_G_STA);
			strcpy ( Header->rptS, VL_S_BOOK_G_RPT);
			strcpy ( Header->endS, VL_S_BOOK_G_END);
			Header->idxA = VL_BOOK_IDX_FOS;
			Header->plnA = FALSE;
			Header->idxB = VL_BOOK_IDX_WTL;
			break;
		case VL_BOOK_IDX_H:
			strcpy ( Header->staS, VL_S_BOOK_H_STA);
			strcpy ( Header->rptS, VL_S_BOOK_H_RPT);
			strcpy ( Header->endS, VL_S_BOOK_H_END);
			Header->idxA = VL_BOOK_IDX_FOS;
			Header->idxB = VL_BOOK_IDX_FRM;
			break;
		case VL_BOOK_IDX_I:
			strcpy ( Header->staS, VL_S_BOOK_I_STA);
			strcpy ( Header->rptS, VL_S_BOOK_I_RPT);
			strcpy ( Header->endS, VL_S_BOOK_I_END);
			Header->idxA = VL_BOOK_IDX_FOB;
			Header->idxB = VL_BOOK_IDX_FRM;
			break;
		case VL_BOOK_IDX_J:
			strcpy ( Header->staS, VL_S_BOOK_J_STA);
			strcpy ( Header->rptS, VL_S_BOOK_J_RPT);
			strcpy ( Header->endS, VL_S_BOOK_J_END);
			Header->idxA = VL_BOOK_IDX_FOB;
			Header->plnA = FALSE;
			Header->idxB = VL_BOOK_IDX_BTK;
			break;
		case VL_BOOK_IDX_K:
			strcpy ( Header->staS, VL_S_BOOK_K_STA);
			strcpy ( Header->rptS, VL_S_BOOK_K_RPT);
			strcpy ( Header->endS, VL_S_BOOK_K_END);
			Header->idxA = VL_BOOK_IDX_KNK;
			Header->idxB = VL_BOOK_IDX_FRM;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_L:
			strcpy ( Header->staS, VL_S_BOOK_L_STA);
			strcpy ( Header->rptS, VL_S_BOOK_L_RPT);
			strcpy ( Header->endS, VL_S_BOOK_L_END);
			Header->idxA = VL_BOOK_IDX_KNK;
			Header->idxB = VL_BOOK_IDX_WTL;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_M:
			strcpy ( Header->staS, VL_S_BOOK_M_STA);
			strcpy ( Header->rptS, VL_S_BOOK_M_RPT);
			strcpy ( Header->endS, VL_S_BOOK_M_END);
			Header->idxA = VL_BOOK_IDX_KNK;
			Header->idxB = VL_BOOK_IDX_BTK;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_N:
			strcpy ( Header->staS, VL_S_BOOK_N_STA);
			strcpy ( Header->rptS, VL_S_BOOK_N_RPT);
			strcpy ( Header->endS, VL_S_BOOK_N_END);
			Header->idxA = VL_BOOK_IDX_TGT;
			Header->idxB = VL_BOOK_IDX_FRM;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_O:
			strcpy ( Header->staS, VL_S_BOOK_O_STA);
			strcpy ( Header->rptS, VL_S_BOOK_O_RPT);
			strcpy ( Header->endS, VL_S_BOOK_O_END);
			Header->idxA = VL_BOOK_IDX_TGT;
			Header->idxB = VL_BOOK_IDX_WTL;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_P:
			strcpy ( Header->staS, VL_S_BOOK_P_STA);
			strcpy ( Header->rptS, VL_S_BOOK_P_RPT);
			strcpy ( Header->endS, VL_S_BOOK_P_END);
			Header->idxA = VL_BOOK_IDX_TGT;
			Header->idxB = VL_BOOK_IDX_BTK;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_Q:
			strcpy ( Header->staS, VL_S_BOOK_Q_STA);
			strcpy ( Header->rptS, VL_S_BOOK_Q_RPT);
			strcpy ( Header->endS, VL_S_BOOK_Q_END);
			Header->idxA = VL_BOOK_IDX_DCK;
			Header->idxB = VL_BOOK_IDX_FRM;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_R:
			strcpy ( Header->staS, VL_S_BOOK_R_STA);
			strcpy ( Header->rptS, VL_S_BOOK_R_RPT);
			strcpy ( Header->endS, VL_S_BOOK_R_END);
			Header->idxA = VL_BOOK_IDX_DCK;
			Header->idxB = VL_BOOK_IDX_WTL;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_S:
			strcpy ( Header->staS, VL_S_BOOK_S_STA);
			strcpy ( Header->rptS, VL_S_BOOK_S_RPT);
			strcpy ( Header->endS, VL_S_BOOK_S_END);
			Header->idxA = VL_BOOK_IDX_SEA;
			Header->idxB = VL_BOOK_IDX_FRM;
			Header->plnA = FALSE;
			break;
		case VL_BOOK_IDX_T:
			strcpy ( Header->staS, VL_S_BOOK_T_STA);
			strcpy ( Header->rptS, VL_S_BOOK_T_RPT);
			strcpy ( Header->endS, VL_S_BOOK_T_END);
			Header->idxA = VL_BOOK_IDX_BUT;
			Header->idxB = VL_BOOK_IDX_WTL;
			break;
		case VL_BOOK_IDX_U:
			strcpy ( Header->staS, VL_S_BOOK_U_STA);
			strcpy ( Header->rptS, VL_S_BOOK_U_RPT);
			strcpy ( Header->endS, VL_S_BOOK_U_END);
			Header->idxA = VL_BOOK_IDX_LON;
			Header->idxB = VL_BOOK_IDX_FRM;
			Header->plnA = FALSE;
			break;
	}
}
/* ========================================================================== */
IGRint	VLgetElemPlane ( 		IGRchar         usr[],
					IGRchar		nam[],
					IGRint		idx,
				struct	GRmd_env	*Env,
				struct	IGRplane	*plane,
					IGRlong		*msg	)
{
		IGRint		sts;
		IGRchar		path[DI_PATH_MAX];
	struct	GRobj_env	Real;
		
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s", usr, VLindexToDirName(idx), nam );
	VLgetRealBookData ( path, Env, &Real );

	plane->normal[0] = plane->normal[1] = plane->normal[2] = 0.0;
	sts = om$send ( msg = message GRvg.GRdetplane (
				msg,
				&Real.mod_env.md_env.matrix_type,
				Real.mod_env.md_env.matrix,
				plane ),
			senderid = NULL_OBJID,
			targetid = Real.obj_id.objid,
			targetos = Real.obj_id.osnum );

	return (sts);
}
/* ========================================================================== */
IGRint	VLgetElemGeom ( 		IGRchar         usr[],
					IGRchar		nam[],
					IGRint		idx,
				struct	GRmd_env	*Env,
					IGRchar		**elem,
					IGRlong		*msg	)
{
		IGRint		sts;
		IGRchar		path[DI_PATH_MAX];
	struct	GRobj_env	Real;
		
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s", usr, VLindexToDirName(idx), nam );
	VLgetRealBookData ( path, Env, &Real );

	sts = VLgetGeometry ( &Real, FALSE, NULL_OBJID, elem, msg);
        as$status ( sts    = sts,
                    msg    = "VLgetGeometry()",
                    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
wrapup:
	return (sts);
}
/* ========================================================================== */
IGRint	VLgetLoftBookData (		IGRchar		usr[],
				struct	GRmd_env	*Env,
					VLlbData	*data,
					IGRlong		*msg	)
{
		IGRint		sts=OM_S_SUCCESS, i, j, numA=0, numB=0, next;
		IGRchar		*macA, *macB, *namA, *namB;
	struct	IGRplane	*plnA, *plnB;
		IGRpoint	*pntA, *pntB, spt, ept;
		IGRvector	*nrmA, *nrmB;
		IGRboolean	*errB;
	struct	IGRbsp_surface	*hull;
	struct	IGRbsp_curve	*curv;
	struct	GRobj_env	Real;
		IGRchar		path[DI_PATH_MAX];
		BSrc		rc;

	/* Initialize */
	data->elem = NULL;
	curv = NULL;
	hull = NULL;
	macA = macB = namA = namB = NULL;
	plnA = plnB = NULL;
	pntA = pntB = NULL;
	nrmA = nrmB = NULL;
	errB = NULL;
		
	/* Retrieve Aft Perpendicular (X) */
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s_00", usr, VL_BOOK_DIR_AFT, VL_BOOK_DIR_AFT );
	VLgetRealBookData ( path, Env, &Real );
	sts = VLgiveSMposition ( &Real.obj_id, &data->orig[0], msg);
        as$status ( sts    = sts,
                    msg    = "VLgiveSMposition()",
                    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
		
	/* Retrieve Baseline (Y) */
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s_00", usr, VL_BOOK_DIR_BSL, VL_BOOK_DIR_BSL );
	VLgetRealBookData ( path, Env, &Real );
	sts = VLgiveSMposition ( &Real.obj_id, &data->orig[1], msg);
        as$status ( sts    = sts,
                    msg    = "VLgiveSMposition()",
                    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
		
	/* Retrieve Centerline (Z) */
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s_00", usr, VL_BOOK_DIR_CTL, VL_BOOK_DIR_CTL );
	VLgetRealBookData ( path, Env, &Real );
	sts = VLgiveSMposition ( &Real.obj_id, &data->orig[2], msg);
        as$status ( sts    = sts,
                    msg    = "VLgiveSMposition()",
                    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve hull surface */
	if (data->head.chap != VL_BOOK_IDX_A) {
		sts = VLgetElemGeom ( usr, "hul_00", VL_BOOK_IDX_HUL, Env,
				      (IGRchar **)&hull, msg );
	        as$status ( sts    = sts,
	                    msg    = "VLgetElemGeom()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Retrieve directory <A> info */
	VLgetElemInDirectory ( data->head.idxA, usr, Env, &numA, &macA, &namA);
	if (!numA)	goto wrapup;
	plnA = om$calloc ( num	= numA, structure = struct IGRplane );
	pntA = om$calloc ( num	= numA, structure = IGRpoint );
	nrmA = om$calloc ( num	= numA, structure = IGRvector );

	/* Retrieve directory <A> support planes */
	for ( i=0; i<numA; i++) {
		pntA[i][0] = pntA[i][1] = pntA[i][2] = 0.0;
		nrmA[i][0] = nrmA[i][1] = nrmA[i][2] = 0.0;
		plnA[i].point  = pntA[i];
		plnA[i].normal = nrmA[i];
		if (data->head.plnA) {
			sts = VLgetElemPlane
				( usr, &macA[100*i], data->head.idxA, Env,
				  &plnA[i], msg );
		}
#ifdef TRACE
printf( "<%s> %d, [%g,%g,%g]\t[%g,%g,%g]\n", &macA[100*i], i,
	plnA[i].point[0], plnA[i].point[1], plnA[i].point[2],
	plnA[i].normal[0], plnA[i].normal[1], plnA[i].normal[2] );
#endif
	}

	/* Retrieve directory <B> info */
	VLgetElemInDirectory ( data->head.idxB, usr, Env, &numB, &macB, &namB);
	if (!numB)	goto wrapup;
	plnB = om$calloc ( num = numB, structure = struct IGRplane );
	pntB = om$calloc ( num = numB, structure = IGRpoint );
	nrmB = om$calloc ( num = numB, structure = IGRvector );
	errB = om$calloc ( num = numB, structure = IGRboolean );

	/* Retrieve directory <B> support planes */
	for ( i=0; i<numB; i++) {
		pntB[i][0] = pntB[i][1] = pntB[i][2] = 0.0;
		nrmB[i][0] = nrmB[i][1] = nrmB[i][2] = 0.0;
		plnB[i].point  = pntB[i];
		plnB[i].normal = nrmB[i];
		if (data->head.plnB) {
			sts = VLgetElemPlane
				( usr, &macB[100*i], data->head.idxB, Env,
				  &plnB[i], msg );
			if (!(sts & 0x00000001 & (*msg)))	errB[i] = TRUE;
			else					errB[i] = FALSE;
		}
#ifdef TRACE
printf( "<%s> %d, [%g,%g,%g]\t[%g,%g,%g]\n", &macB[100*i], i,
	plnB[i].point[0], plnB[i].point[1], plnB[i].point[2],
	plnB[i].normal[0], plnB[i].normal[1], plnB[i].normal[2] );
#endif
	}

	/* Allocate memory for data structure */
	data->elem = om$calloc ( num = numA * numB, structure = VLlbElem );

	/* Fill data structure with basics */
	data->numA = numA;
	data->numB = numB;

	/* Fill data structure */
if (data->head.chap == VL_BOOK_IDX_A) {
	for ( i=0; i<numA; i++) {
		for ( j=0; j<numB; j++) {

			strcpy ( data->elem[j+i*numB].namA, &namA[100*i] );
			strcpy ( data->elem[j+i*numB].macA, &macA[100*i] );
			dblcpy ( data->elem[j+i*numB].pntA, plnA[i].point,  3 );
			dblcpy ( data->elem[j+i*numB].nrmA, plnA[i].normal, 3 );

			strcpy ( data->elem[j+i*numB].namB, &namB[100*j] );
			strcpy ( data->elem[j+i*numB].macB, &macB[100*j] );
			dblcpy ( data->elem[j+i*numB].pntB, plnB[j].point,  3 );
			dblcpy ( data->elem[j+i*numB].nrmB, plnB[j].normal, 3 );

	/* In this peculiar case, the distances between displacement stations
	   and frames are stored in the first "intersection" point */

			data->elem[j+i*numB].nint = 1;
			data->elem[j+i*numB].Pint[0][0]
			= fabs ( data->elem[j+i*numB].pntA[0]
			       - data->elem[j+i*numB].pntB[0] );
			data->elem[j+i*numB].Pint[0][1]
			= fabs ( data->elem[j+i*numB].pntA[1]
			       - data->elem[j+i*numB].pntB[1] );
			data->elem[j+i*numB].Pint[0][2]
			= fabs ( data->elem[j+i*numB].pntA[2]
			       - data->elem[j+i*numB].pntB[2] );
		}
	}
}
else {	for ( i=0; i<numA; i++) {

		if (curv) {	om$dealloc (ptr = curv); curv = NULL;	}
		sts = VLgetElemGeom ( usr, &macA[100*i], data->head.idxA, Env,
				      (IGRchar **)&curv, msg );
	        as$status ( sts    = sts,
	                    msg    = "VLgetElemGeom()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		next = 0;
		BScveval ( curv, 0.0, 0, &spt, &rc);
		if (rc == BSSUCC) 	next++;
		else {	spt[0] = spt[1] = spt[2] = 0.0;	}
		BScveval ( curv, 1.0, 0, &ept, &rc);
		if (rc == BSSUCC) 	next++;
		else {	ept[0] = ept[1] = ept[2] = 0.0;	}

		for ( j=0; j<numB; j++) {

			strcpy ( data->elem[j+i*numB].namA, &namA[100*i] );
			strcpy ( data->elem[j+i*numB].macA, &macA[100*i] );
			dblcpy ( data->elem[j+i*numB].pntA, plnA[i].point,  3 );
			dblcpy ( data->elem[j+i*numB].nrmA, plnA[i].normal, 3 );

			strcpy ( data->elem[j+i*numB].namB, &namB[100*j] );
			strcpy ( data->elem[j+i*numB].macB, &macB[100*j] );
			dblcpy ( data->elem[j+i*numB].pntB, plnB[j].point,  3 );
			dblcpy ( data->elem[j+i*numB].nrmB, plnB[j].normal, 3 );

			data->elem[j+i*numB].next = next;
			dblcpy ( data->elem[j+i*numB].Pext[0], spt, 3 );
			dblcpy ( data->elem[j+i*numB].Pext[1], ept, 3 );

			if (errB[j] == FALSE) {
				sts = VLintPlPlSf ( curv,
						    &plnA[i],
						    &plnB[j],
						    hull,
						    &data->elem[j+i*numB].nint,
					    	    data->elem[j+i*numB].Pint,
						    msg );
				if (!(sts & 0x00000001 & (*msg))) {
					sts = OM_S_SUCCESS;
					*msg = MSSUCC;
				}
			}
			else {	sts = VLintCrvPln ( curv,
						    &plnB[j], 
						    &data->elem[j+i*numB].nint,
						    data->elem[j+i*numB].Pint,
						    msg );
				if (!(sts & 0x00000001 & (*msg))) {
					sts = OM_S_SUCCESS;
					*msg = MSSUCC;
				}
			}
		}
	}
}

wrapup:
	if (hull) {	om$dealloc (ptr = hull);	hull = NULL;	}
	if (curv) {	om$dealloc (ptr = curv);	curv = NULL;	}

	if (macA) {	om$dealloc (ptr = macA);	macA = NULL;	}
	if (namA) {	om$dealloc (ptr = namA);	namA = NULL;	}
	if (plnA) {	om$dealloc (ptr = plnA);	plnA = NULL;	}
	if (pntA) {	om$dealloc (ptr = pntA);	pntA = NULL;	}
	if (nrmA) {	om$dealloc (ptr = nrmA);	nrmA = NULL;	}

	if (macB) {	om$dealloc (ptr = macB);	macB = NULL;	}
	if (namB) {	om$dealloc (ptr = namB);	namB = NULL;	}
	if (plnB) {	om$dealloc (ptr = plnB);	plnB = NULL;	}
	if (pntB) {	om$dealloc (ptr = pntB);	pntB = NULL;	}
	if (nrmB) {	om$dealloc (ptr = nrmB);	nrmB = NULL;	}
	if (errB) {	om$dealloc (ptr = errB);	errB = NULL;	}

	return (sts);
}
/* ========================================================================== */
IGRint VLintCrvPln (	struct	IGRbsp_curve	*Crv,
			struct	IGRplane	*Pln,
				IGRint		*numSol,
				IGRpoint	*ptSol,
				IGRlong		*msg	)
{
		IGRint		nint=0, nseg=0, i, sts=MSFAIL;
		IGRdouble	*p, *u, *a, *b;

	/* Initialize */
	*numSol = 0;
	p = u = a = b = NULL;

	/* Exit if no geometry */
	if (!Crv) {	*msg = MSFAIL;	goto wrapup;	}

	/* Allocate memory */
	p = om$calloc ( num = 3 * Crv->num_poles, structure = IGRdouble );
	u = om$calloc ( num = Crv->num_poles, structure = IGRdouble );
	a = om$calloc ( num = Crv->num_poles, structure = IGRdouble );
	b = om$calloc ( num = Crv->num_poles, structure = IGRdouble );

	/* Intersect curve with plane */
	if ( ! BSpl_cv_int ( msg, Crv, Pln->point, Pln->normal,
		      	     &nint, p, u, &nseg, a, b ) )	goto wrapup;
	else	sts = OM_S_SUCCESS;
	if (*msg == BSSUCC)	*msg = OM_S_SUCCESS;
	else {			*msg = MSFAIL;	goto wrapup;	}
#ifdef INTER
for ( i=0; i<nint; i++)
printf( "BSpl_cv_int(%d) : [%g,%g,%g]\tu = %g\n",
	i, p[3*i+0], p[3*i+1], p[3*i+2], u[i] );
#endif
	/* Store values */
	if (nint > 4)	nint = 4;
	*numSol = nint;
	for ( i=0; i<*numSol; i++)	dblcpy ( ptSol[i], &p[3*i], 3);

wrapup:
	if (a) {	om$dealloc (ptr = a);	a = NULL;	}
	if (b) {	om$dealloc (ptr = b);	b = NULL;	}
	if (u) {	om$dealloc (ptr = u);	u = NULL;	}
	if (p) {	om$dealloc (ptr = p);	p = NULL;	}
	return (sts);
}
/* ========================================================================== */
IGRint VLintPlPlSf
(
struct	IGRbsp_curve	*Crv,		/*I curve BS geometry		*/
struct	IGRplane	*Pln,		/*I curve plane (can be NULL)	*/
struct	IGRplane	*Frm,		/*I frame plane			*/
struct	IGRbsp_surface	*Srf,		/*I hull BS geometry 		*/
	IGRint		*numSol,	/*O number of intersections	*/
	IGRpoint	*ptSol, 	/*O points of intersections	*/
	IGRlong		*msg		/*O completion code		*/
)

/*d This function evalutes up to 4 intersections between an infinite line
and a surface. The infinite line is defined as the intersection of two
planes. One plane will represent a planar curve, the second a frame or and
other flat curve.

/*h	10/08/94 : JLL creation date
	07/09/94 : MF enhancement and standardization	*/

{

	IGRint		sts=OM_S_SUCCESS, flag, i;
	IGRdouble	*u, *v; 
	IGRpoint	*p, pnt;
	IGRlong		npnt;
	IGRvector	vec;

	/* Initialize */
	*numSol = 0;
	u = v = NULL;
	p = NULL;

	/* Exit if no geometry */
	if (!Crv) {	*msg = MSFAIL;	goto wrapup;	}

	/* Intersect curve and plane if curve not planar */
	if ( (!Pln) || (  (Pln->normal[0] == 0.0)
		       && (Pln->normal[1] == 0.0)
		       && (Pln->normal[2] == 0.0) ) ) {
		sts = VLintCrvPln ( Crv, Frm, numSol, ptSol, msg);
		goto wrapup;
	}

	/* Intersect the two infinite planes to get a point and direction */
	BSnorvec ( msg, Pln->normal);
	BSnorvec ( msg, Frm->normal);
	BSpl_pl ( Pln->point, Pln->normal, Frm->point, Frm->normal,
		  &flag, pnt, vec, msg  );
       	if( (*msg != BSSUCC) || (flag != BSCINTERSECTING) )
		{	*msg = MSFAIL; goto wrapup;     }

	/* Project point on hull surface */
  	BSpj_pt_sf ( Srf, pnt, vec, &npnt, &p, &u, &v, msg );
#ifdef INTER
for ( i=0; i<npnt; i++)
printf( "BSpj_pt_sf (%d) : [%g,%g,%g]\tu = %g\tv = %g\n",
	i, p[i][0], p[i][1], p[i][2], u[i], v[i] );
#endif
  	if ( (*msg != BSSUCC) || (!npnt) )
		sts = VLintCrvPln ( Crv, Frm, numSol, ptSol, msg);
	else {	if (npnt > 4)	npnt = 4;
		*numSol = (IGRint) npnt;
		for ( i=0; i<*numSol; i++)	dblcpy ( ptSol[i], p[i], 3);
		*msg = MSSUCC;
	}

wrapup:
	/* Deallocate memory */
	if (p) {	om$dealloc(ptr=p);	p = NULL; }
	if (u) {	om$dealloc(ptr=u);	u = NULL; }
	if (v) {	om$dealloc(ptr=v);	v = NULL; }

	return(sts);
}
/* ========================================================================== */
void    VLextractFormat (       IGRchar Iformat[],
                                IGRint  max,
                                IGRint  Oindex[],
                                VStktxt Oformat[]       )
{
        IGRint          i, j, num=0, len=0, Sidx=0, Clen=0, pos[101];
        IGRboolean      fnd_flag=FALSE, sta_flag=FALSE, end_flag=FALSE;

        /* Initialize */
        for ( i=0; i<100; i++) {        Oindex[i] = VS_string;
                                        strcpy ( Oformat[i], "%s");     }
        len = strlen (Iformat);
        for ( i=0; i<len; i++)
                if (Iformat[i] == '%') {
                        pos[num] = i;
                        num++;
                        if (num > max)  return;
                }
        pos[num] = len;

        /* Scan for format substring in Iformat */
        for ( i=0; i<num; i++) {

                if (i == 0)     sta_flag = TRUE;
                else            sta_flag = FALSE;
                if (i == num-1) end_flag = TRUE;
                else            end_flag = FALSE;

                for ( j=pos[i]+1; j<pos[i+1]; j++) {

                        fnd_flag = FALSE;
                        switch (Iformat[j]) {

                                case 'd' :
                                case 'o' :
                                case 'i' :
                                case 'u' :
                                case 'x' :
                                case 'X' :
                                        Oindex[i] = VS_int;
                                        fnd_flag = TRUE;
                                        break;
                                case 'e' :
                                case 'f' :
                                case 'g' :
                                case 'E' :
                                case 'G' :
                                        Oindex[i] = VS_double;
                                        fnd_flag = TRUE;
                                        break;
                                case 's' :
                                case 'c'  :
                                case 'n'  :
                                case 'p'  :
                                        Oindex[i] = VS_string;
                                        fnd_flag = TRUE;
                                        break;
                        }
                        if (fnd_flag == TRUE) {
                                if 	(end_flag) {
                                        strcpy ( Oformat[i], &Iformat[Sidx]);
                                        return;
                                }
                                else if (sta_flag) {
                                        strcpy ( Oformat[i], &Iformat[Sidx]);
                                        Sidx = j + 1;
                                        Oformat[i][Sidx] = '\0';
                                        j = len;
                                }
                                else {	Clen = j - Sidx + 1;
                                        strncpy ( Oformat[i],
                                                  &Iformat[Sidx], Clen);
                                        Oformat[i][Clen] = '\0';
                                        Sidx = j + 1;
                                        j = len;
                                }
                        }
                }
        }
}
/* ========================================================================== */
IGRint	VLsortCrossing (	VLlbCross	a[],
				VLlbCross	b[]	)
{
	return ( (a->val == b->val) ? 0 : (a->val < b->val) ? -1 : 1);
}
/* ========================================================================== */
void	VLfillCrossAttr (	struct	ACrg_coll	attr[]	)
{
	/* Build ACrg_collection : name */
        strcpy ( attr[VL_BC_NUMB_IDX].name, VL_BC_NUMB_NAM);
        strcpy ( attr[VL_BC_VAL0_IDX].name, VL_BC_VAL0_NAM);
        strcpy ( attr[VL_BC_VAL1_IDX].name, VL_BC_VAL1_NAM);
        strcpy ( attr[VL_BC_VAL2_IDX].name, VL_BC_VAL2_NAM);
        strcpy ( attr[VL_BC_VAL3_IDX].name, VL_BC_VAL3_NAM);
        strcpy ( attr[VL_BC_LST0_IDX].name, VL_BC_LST0_NAM);
        strcpy ( attr[VL_BC_LST1_IDX].name, VL_BC_LST1_NAM);
        strcpy ( attr[VL_BC_LST2_IDX].name, VL_BC_LST2_NAM);
        strcpy ( attr[VL_BC_LST3_IDX].name, VL_BC_LST3_NAM);

	/* Build ACrg_collection : type */
	attr[VL_BC_NUMB_IDX].desc.type = AC_ATTRIB_DOUBLE;
	attr[VL_BC_VAL0_IDX].desc.type = AC_ATTRIB_DOUBLE;
	attr[VL_BC_VAL1_IDX].desc.type = AC_ATTRIB_DOUBLE;
	attr[VL_BC_VAL2_IDX].desc.type = AC_ATTRIB_DOUBLE;
	attr[VL_BC_VAL3_IDX].desc.type = AC_ATTRIB_DOUBLE;
	attr[VL_BC_LST0_IDX].desc.type = AC_ATTRIB_TEXT;
	attr[VL_BC_LST1_IDX].desc.type = AC_ATTRIB_TEXT;
	attr[VL_BC_LST2_IDX].desc.type = AC_ATTRIB_TEXT;
	attr[VL_BC_LST3_IDX].desc.type = AC_ATTRIB_TEXT;

	/* Initialize ACrg_collection */
	attr[VL_BC_NUMB_IDX].desc.value.att_exp    = 0.0;
	attr[VL_BC_VAL0_IDX].desc.value.att_exp    = 0.0;
	attr[VL_BC_VAL1_IDX].desc.value.att_exp    = 0.0;
	attr[VL_BC_VAL2_IDX].desc.value.att_exp    = 0.0;
	attr[VL_BC_VAL3_IDX].desc.value.att_exp    = 0.0;
	attr[VL_BC_LST0_IDX].desc.value.att_txt[0] = '\0';
	attr[VL_BC_LST1_IDX].desc.value.att_txt[0] = '\0';
	attr[VL_BC_LST2_IDX].desc.value.att_txt[0] = '\0';
	attr[VL_BC_LST3_IDX].desc.value.att_txt[0] = '\0';
}
/* ========================================================================== */
void	VLelimInChtTol (	IGRint		*number,
				VLlbCross	*cross,
				IGRint		name	)
{
	IGRint		num;
	IGRdouble	tol;
	BSrc		rc;

	switch (*number) {

		case 4:	num = 2;
			VLelimInChtTol ( &num, &cross[2], name);
			if (num != 2)	(*number)--;
			num = 2;
			VLelimInChtTol ( &num, &cross[1], name);
			if (num != 2)	(*number)--;
			num = 2;
			VLelimInChtTol ( &num, &cross[0], name);
			if (num != 2)	(*number)--;
			break;

		case 3:	num = 2;
			VLelimInChtTol ( &num, &cross[1], name);
			if (num != 2)	(*number)--;
			num = 2;
			VLelimInChtTol ( &num, &cross[0], name);
			if (num != 2)	(*number)--;
			break;

		case 2:	BSxtractpar ( &rc, name, &tol);
			if (fabs(cross[0].val - cross[1].val) < tol)
				(*number)--;
			break;

		case 1:
		case 0:
		default:
			break;
	}
}
/* ========================================================================== */
IGRint	VLdecodeAxis (	const	VSdrwArgLst	*argl	)
{
	IGRint	axis=-1;

	if (argl->arg.type == VS_string) {

		switch (argl->arg._sval[0]) {

			case 'x':
			case 'X':	axis = 0;	break;
			case 'y':
			case 'Y':	axis = 1;	break;
			case 'z':
			case 'Z':	axis = 2;	break;
		}
	}

	return (axis);
}
/* ========================================================================== */
IGRint	VLgiveSMposition (	struct	GRid		*Plane,
					IGRdouble	*value,
					IGRlong		*msg	)
{
	IGRint		sts=MSFAIL;

	/*
		I build this stupid function because SMframe and SMInfPlane
		are classes defining the same message SMgive_rel_position.
		No inheritance between SMframe and SMInfPlane dont allows this
		SMgive_rel_position message to be sent to an object which can
		be indiffently an occurence of these two classes. Strange
		behavior for an OOL programmation !
	*/

	/* Initialize */
	*value = 0.0;
	*msg   = MSFAIL;

	if 	(vs$is_ancestry_valid ( object = Plane,
					classid = OPP_SMframe_class_id ) ) {
		sts = om$send ( msg = message SMframe.SMgive_rel_position
						( msg, value ),
				senderid = NULL_OBJID,
				targetid = Plane->objid,
				targetos = Plane->osnum );
        	as$status ( sts    = sts,
	                    msg    = "SMframe.SMgive_rel_position",
	                    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}
	else if	(vs$is_ancestry_valid ( object = Plane,
					classid = OPP_SMInfPlane_class_id ) ) {
		sts = om$send ( msg = message SMInfPlane.SMgive_rel_position
						( msg, value ),
				senderid = NULL_OBJID,
				targetid = Plane->objid,
				targetos = Plane->osnum );
        	as$status ( sts    = sts,
	                    msg    = "SMInfPlane.SMgive_rel_position",
	                    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ========================================================================== */
void	VLgetElemInMultiField (		IGRint		idx,
					IGRchar		usr[],
				struct	GRmd_env	*Env,
					IGRchar		*form_ptr,
					IGRint		label,
				struct	GRid		*Elem,
					IGRchar		Path[],
					IGRlong		*msg	)
{
		IGRint  i, num, sel=0;
                IGRchar *mac, *nam;

	/* Initialize */
	Elem->objid = NULL_OBJID;
	Elem->osnum = Env->md_id.osnum;
	*msg = MSFAIL;

	/* No directory selected */
	if (idx == -1)	return;

	/* Retrieve existing elements in directory */
        VLgetElemInDirectory ( idx, usr, Env, &num, &mac, &nam);
        if (!num)       goto wrapup;

	for ( i=0; i<num; i++) {
                FIfld_get_select ( form_ptr, label, i, 0, &sel );
                if (sel == 1)   break;
        }
        if (!sel)       goto wrapup;
        else {  Path[0] = '\0';
                sprintf ( Path, "%s:%s:%s",
                          usr, VLindexToDirName(idx), &mac[100*i] );
                *msg = di$translate ( objname = Path,
                                      p_objid = &Elem->objid,
                                      p_osnum = &Elem->osnum );
                if (*msg != DIR_S_SUCCESS) {
			Elem->objid = NULL_OBJID;
			Elem->osnum = Env->md_id.osnum;
			*msg = MSFAIL;
		}
		else	*msg = MSSUCC;
	}

wrapup:
        if (mac) { om$dealloc(ptr=mac); mac = NULL; }
        if (nam) { om$dealloc(ptr=nam); nam = NULL; }
}
/* ========================================================================== */
void	VLputqueueElemInMultiField (	IGRint		idx,
					IGRchar		usr[],
				struct	GRmd_env	*Env,
					IGRchar		*form_ptr,
					IGRint		label	)
{
		IGRlong		msg;
        struct  GRid    	elem;
		IGRchar		path[DI_PATH_MAX];
	struct	GRobj_env	real;

	VLgetElemInMultiField (	idx, usr, Env, form_ptr, label,
				&elem, path, &msg );
	if (msg == MSSUCC) {
		VLgetRealBookData ( path, Env, &real);
		VSputObjectToQueue ( &msg, real.obj_id.objid, real.obj_id.osnum,
				     &real.mod_env, BACK );
	}
}
/* ========================================================================== */
void	VLdeleteAllMultiField (		IGRint		idx,
					IGRchar		usr[],
				struct	GRmd_env	*Env	)
{
		IGRint  	i, num;
                IGRchar 	*mac, *nam, path[DI_PATH_MAX];
	struct	GRid		elem;
		IGRlong		msg;
	struct	GRobj_env	Real;

	/* No directory selected */
	if (idx == -1)	return;

	/* Retrieve existing elements in directory */
        VLgetElemInDirectory ( idx, usr, Env, &num, &mac, &nam);
        if (!num)       goto wrapup;

	for ( i=0; i<num; i++) {
        	path[0] = '\0';
                sprintf ( path, "%s:%s:%s",
                          usr, VLindexToDirName(idx), &mac[100*i] );
                msg = di$translate ( objname = path,
                                     p_objid = &elem.objid,
                                     p_osnum = &elem.osnum );
                if (msg == DIR_S_SUCCESS) {

			VLgetRealBookData ( path, Env, &Real );
		
			
                	/* for TR179801009 */
			// if (Env->md_id.osnum == Real.mod_env.md_id.osnum)
		        //		gr$delete_object ( msg          = &msg,
		        //		           md_env       = &Real.mod_env,
		        //		           object_id    = &Real.obj_id);

			gr$delete_object ( msg          = &msg,
				           md_env       = Env,
				           object_id    = &elem,
				           display_flag = 0 );
		}
		nd$exec_batch();
	}

wrapup:
        if (mac) { om$dealloc(ptr=mac); mac = NULL; }
        if (nam) { om$dealloc(ptr=nam); nam = NULL; }
}
/* ========================================================================== */
IGRint	VLcreateDispStations (		IGRint		idx,
					IGRchar		usr[],
				struct	GRmd_env	*Env,
					IGRint		type,
					IGRchar		*form_ptr	)
{
		IGRint		sts=MSFAIL, err=0, num=0, i, suc;
		IGRlong		msg;
		IGRchar		path[DI_PATH_MAX], name[DI_PATH_MAX];
	struct	GRobj_env	Pln[4];
		IGRdouble	val[4], lbp=0.0, mul[24], pos[24];
		IGRboolean	AftFwd;
	struct	GRid		dummy, tpl[7], pln_id, con_id;

	/* Initialize */
	for ( i=0; i<7; i++) {	tpl[i].objid = NULL_OBJID;
				tpl[i].osnum = Env->md_id.osnum;	}
	strcpy ( name, VLindexToDirName(idx) );
		
	/* Retrieve Aft Perpendicular */
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s_00", usr, VL_BOOK_DIR_AFT, VL_BOOK_DIR_AFT );
	sts = VLgetRealBookData ( path, Env, &Pln[err] );
        as$status ( sts    = sts,
                    msg    = "VLgetRealBookData(AFT)",
                    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	sts = VLgiveSMposition ( &Pln[err].obj_id, &val[err], &msg);
        as$status ( sts    = sts,
                    msg    = "VLgiveSMposition(AFT)",
                    test   = (!(sts & 0x00000001 & msg)),
		    action = GOTO_VALUE,
		    value  = wrapup );
#ifdef TRACE
printf( "AFT : (%d|%d)\tat position %g\n",
	Pln[err].obj_id.osnum, Pln[err].obj_id.objid, val[err] );
#endif	
	/* Retrieve Forward Perpendicular */
	err++;
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s_00", usr, VL_BOOK_DIR_FWD, VL_BOOK_DIR_FWD );
	sts = VLgetRealBookData ( path, Env, &Pln[err] );
        as$status ( sts    = sts,
                    msg    = "VLgetRealBookData(FWD)",
                    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	sts = VLgiveSMposition ( &Pln[err].obj_id, &val[err], &msg);
        as$status ( sts    = sts,
                    msg    = "VLgiveSMposition(FWD)",
                    test   = (!(sts & 0x00000001 & msg)),
		    action = GOTO_VALUE,
		    value  = wrapup );
#ifdef TRACE
printf( "FWD : (%d|%d)\tat position %g\n",
	Pln[err].obj_id.osnum, Pln[err].obj_id.objid, val[err] );
#endif	
	/* Retrieve Midships Perpendicular */
	err++;
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s_00", usr, VL_BOOK_DIR_MID, VL_BOOK_DIR_MID );
	sts = VLgetRealBookData ( path, Env, &Pln[err] );
        as$status ( sts    = sts,
                    msg    = "VLgetRealBookData(MID)",
                    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	sts = VLgiveSMposition ( &Pln[err].obj_id, &val[err], &msg);
        as$status ( sts    = sts,
                    msg    = "VLgiveSMposition(MID)",
                    test   = (!(sts & 0x00000001 & msg)),
		    action = GOTO_VALUE,
		    value  = wrapup );
#ifdef TRACE
printf( "MID : (%d|%d)\tat position %g\n",
	Pln[err].obj_id.osnum, Pln[err].obj_id.objid, val[err] );
#endif	
	/* Retrieve Origin Perpendicular */
	err++;
	path[0] = '\0';
	sprintf ( path, "%s:%s:%s_00", usr, VL_BOOK_DIR_ORI, VL_BOOK_DIR_ORI );
	sts = VLgetRealBookData ( path, Env, &Pln[err] );
        as$status ( sts    = sts,
                    msg    = "VLgetRealBookData(ORI)",
                    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	sts = VLgiveSMposition ( &Pln[err].obj_id, &val[err], &msg);
        as$status ( sts    = sts,
                    msg    = "VLgiveSMposition(ORI)",
                    test   = (!(sts & 0x00000001 & msg)),
		    action = GOTO_VALUE,
		    value  = wrapup );
#ifdef TRACE
printf( "ORI : (%d|%d)\tat position %g\n",
	Pln[err].obj_id.osnum, Pln[err].obj_id.objid, val[err] );
#endif
	/* Determine orientation */
	err++;
	if	(  (Pln[3].obj_id.objid == Pln[0].obj_id.objid)
		&& (Pln[3].obj_id.osnum == Pln[0].obj_id.osnum) )
	{	AftFwd = TRUE;	lbp = val[1] - val[3];	}
	else if	(  (Pln[3].obj_id.objid == Pln[1].obj_id.objid)
		&& (Pln[3].obj_id.osnum == Pln[1].obj_id.osnum) )
	{	AftFwd = FALSE;	lbp = val[0] - val[3];	}
	else {	sts = MSFAIL; 	goto wrapup;	}

	/* Set displacement stations X values */
	err++;
	if (type == 1) {
		num = 23;
		mul[0]  =  0.00;
		mul[1]  =  0.25;
		mul[2]  =  0.50;
		mul[3]  =  0.75;
		mul[4]  =  1.00;
		mul[5]  =  1.50;
		mul[6]  =  2.00;
		mul[7]  =  2.50;
		mul[8]  =  3.00;
		mul[9]  =  3.50;
		mul[10] =  4.00;
		mul[11] =  5.00;
		mul[12] =  6.00;
		mul[13] =  6.50;
		mul[14] =  7.00;
		mul[15] =  7.50;
		mul[16] =  8.00;
		mul[17] =  8.50;
		mul[18] =  9.00;
		mul[19] =  9.25;
		mul[20] =  9.50;
		mul[21] =  9.75;
		mul[22] = 10.00;
	}
	else {	num = 21;
		for ( i=0; i<num; i++)	mul[i] = i / 2.0;
	}
	for ( i=0; i<num; i++)	pos[i] = val[3] + mul[i] * lbp / 10.0;
#ifdef TRACE
for ( i=0; i<num; i++)	printf( "pos[%2d] = %g\n", i, pos[i]);
#endif

	/* Retrieve coordinate system (template) */
	err++;
	sts = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
                                        ( &suc, 0, &dummy ),
                        senderid = NULL_OBJID,
                        targetid = Pln[3].obj_id.objid,
                        targetos = Pln[3].obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "ACfind_exp_temp_obj",
                    test   = (!(sts & 0x00000001 & suc)),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Retrieve coordinate system (object) */
	sts = om$send ( msg = message NDnode.ASreturn_go (
					&tpl[0],
					&Pln[3].mod_env.md_env.matrix_type,
					Pln[3].mod_env.md_env.matrix ),
                        senderid = NULL_OBJID,
                        targetid = dummy.objid,
                        targetos = dummy.osnum );
        as$status ( sts    = sts,
                    msg    = "ASreturn_go",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Make source on coordinate system */
	as$make_source ( go_grid = tpl[0],
			 mod_env = &Pln[3].mod_env,
			 as_os   = Env->md_id.osnum,
			 as_grid = &tpl[0] );

	/* Create expression <axe> */
	sts = exp$create ( exp_syntax = "x",
			   osnum      = Env->md_id.osnum,
			   p_exp_id   = &tpl[1].objid,
			   p_osnum    = &tpl[1].osnum,
			   type_rq    = EXP_TEXT );
        as$status ( sts    = sts,
                    msg    = "exp$create(<axe>)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create expression <plane_size> */
	sts = exp$create ( exp_value = -2.0,
                           p_exp_id  = &tpl[3].objid,
                           osnum     = Env->md_id.osnum,
                           p_osnum   = &tpl[3].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(<plane_size>))",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create expression <reverse> */
	sts = exp$create ( exp_value = 0.0,
                           p_exp_id  = &tpl[5].objid,
                           osnum     = Env->md_id.osnum,
                           p_osnum   = &tpl[5].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(<reverse>))",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create expression <justif> */
	sts = exp$create ( exp_syntax = "CC",
			   osnum      = Env->md_id.osnum,
			   p_exp_id   = &tpl[6].objid,
			   p_osnum    = &tpl[6].osnum,
			   type_rq    = EXP_TEXT );
        as$status ( sts    = sts,
                    msg    = "exp$create(<justif>)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create infinite planes */
	err++;
	for ( i=0; i<num; i++) {

		/* Create expression <dist_on_axe> */
		sts = exp$create ( exp_value = pos[i],
	                           p_exp_id  = &tpl[2].objid,
	                           osnum     = Env->md_id.osnum,
	                           p_osnum   = &tpl[2].osnum );
	        as$status ( sts    = sts,
	                    msg    = "exp$create(<dist_on_axe>))",
	                    test   = (sts != EXP_S_SUCCESS),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Create expression <text> */
		path[0] = '\0';
		sprintf ( path, "%4.2f", mul[i]);
		sts = exp$create ( exp_syntax = path,
				   osnum      = Env->md_id.osnum,
				   p_exp_id   = &tpl[4].objid,
				   p_osnum    = &tpl[4].osnum,
				   type_rq    = EXP_TEXT );
	        as$status ( sts    = sts,
	                    msg    = "exp$create(<text>)",
	                    test   = (sts != EXP_S_SUCCESS),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Contruct and place the <SMInfPlane> object */
		sts = vl$placeLoftMacro ( msg	   = &msg,
					  classid  = OPP_SMInfPlane_class_id,
					  MacName  = "SMInfPlane",
					  number   = 7,
					  template = tpl,
					  Env      = Env,
					  ChgState = FALSE,
					  occ_id   = &pln_id );
	        as$status ( sts    = sts,
	                    msg    = "vl$placeLoftMacro(SMInfPlane)",
	                    test   = (!(sts & 0x00000001 & msg)),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		path[0] = '\0';
		sprintf ( path, "%s:%s:%4.2f", usr, VL_BOOK_DIR_PLA, mul[i] );
        	sts = om$send ( msg = message GRgraphics.GRchgname
                                        ( &msg, Env, path),
				senderid = NULL_OBJID,
				targetid = pln_id.objid,
				targetos = pln_id.osnum );
	        as$status ( sts    = sts,
	                    msg    = "GRgraphics.GRchgname(<SMInfPlane>)",
	                    test   = (!(sts & 0x00000001 & msg)),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
#ifdef TRACE
printf( "<SMInfPlane> %2d is (%d|%d) called <%s>\n",
	i, pln_id.osnum, pln_id.objid, path );
#endif
		/* Force display of <SMInfPlane> */
		gr$display_object ( object_id = &pln_id, md_env = Env);

		/* Contruct and place the <VLconnect> object */
		sts = vl$placeLoftMacro ( msg	   = &msg,
					  classid  = OPP_VLconnect_class_id,
					  MacName  = MACRO_VC_DEF,
					  number   = MACRO_VC_TEMP,
					  template = &pln_id,
					  Env      = Env,
					  ChgState = FALSE,
					  occ_id   = &con_id );
	        as$status ( sts    = sts,
	                    msg    = "vl$placeLoftMacro(VLconnect)",
	                    test   = (!(sts & 0x00000001 & msg)),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Give name to the <VLconnect> object */
		path[0] = '\0';
		sprintf ( path, "%s:%s:%s_%02d", usr, name, name, i );
        	sts = om$send ( msg = message GRgraphics.GRchgname
                                        ( &msg, Env, path),
				senderid = NULL_OBJID,
				targetid = con_id.objid,
				targetos = con_id.osnum );
	        as$status ( sts    = sts,
	                    msg    = "GRgraphics.GRchgname(<VLconnect>)",
	                    test   = (!(sts & 0x00000001 & msg)),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
#ifdef TRACE
printf( "<VLconnect>  %2d is (%d|%d) called <%s>\n",
	i, con_id.osnum, con_id.objid, path );
#endif
	}

	/* Successful completion */
	err++;

wrapup:
	switch (err) {
		case 0:	strcpy ( path, "Aft Perpendicular not defined");
			break;
		case 1:	strcpy ( path, "Forward Perpendicular not defined");
			break;
		case 2:	strcpy ( path, "Midships Perpendicular not defined");
			break;
		case 3:	strcpy ( path, "Origin Perpendicular not defined");
			break;
		case 4:	strcpy ( path, "Origin must be Aft or Forward");
			break;
		case 5:	strcpy ( path,
				 "Midships must be between Aft and Forward");
			break;
		case 6:	strcpy ( path, "Cannot find coordinate system");
			break;
		case 7: path[0] = '\0';
			sprintf ( path, "Cannot create station %d", i);
			break;
		default:	strcpy ( path, " ");
	}
	FIg_set_text ( form_ptr, VL_PREP_BOOK_MSG, path );

	return (sts);
}
/* ========================================================================== */
void	VLnearestDispStation (	VLlbData	Dat[],
				IGRchar		nam[],
				IGRdouble	*dst	)
{
	VLlbElem	*Ele;
	IGRint		i, numA, curA=0, numB, curB, idx;

	/* Initialize */
	strcpy ( nam, "-");
	*dst   = -1.0;

	/* Get data elements */
	if (!Dat)	return;
	else		Ele = (VLlbElem *) Dat->elem;

	/* Get loop boudaries */
	numA = Dat->numA;	if (numA < 0)	return;
	numB = Dat->numB;	if (numB < 0)	return;
	curB = Dat->curB;	if (curB < 0)	return;

	/* Find the displacement station nearer to frame */
	*dst = 1000000.0;
	for ( i=0; i<numA; i++) {
		idx = i * numB + curB;
		if (Ele[idx].Pint[0][0] < *dst) {
			*dst = Ele[idx].Pint[0][0];
			curA = i;
			if (*dst == 0.0)	i = numA;
		}
	}

	/* Verify if this station isn't closer to another frame */
	for ( i=0; i<numB; i++) {
		idx = curA * numB + i;
		if (Ele[idx].Pint[0][0] < *dst) {
			*dst = -1.0;
			return;
		}
	}

	/* Get name of the nearest displacement station */
	idx = curA * numB + curB;
	if (Ele[idx].namA != '\0')	strcpy ( nam, Ele[idx].namA);

	return;
}
/* ========================================================================== */
	
end implementation VLabstract;
