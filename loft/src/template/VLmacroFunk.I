class implementation VLabstract;

#include	<stdio.h>
#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"AS_status.h"
#include	"ACattrib.h"
#include	"msdef.h"
#include	"grmacros.h"
#include	"cotxmacros.h"
#include	"bsparameters.h"
#include	"bserr.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"asbox.h"
#include	"vsmiscmacros.h"

#include	"vlcntrline.h"
#include	"vlplatejig.h"
#include	"vlmiscmacros.h"

#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bslenvec.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"
#include	"bsproj1.h"
#include	"bssfeval.h"
#include	"bsxln.h"
#include	"bsxlnpl.h"
#include	"bsxtractpar.h"

#include	"mamulmx.h"
#include	"matypemx.h"

from	ACrg_collect	import	ACcreate,AClist_attribute,ACset_list_attribute;
from	GRcurve		import	GRrevparm;
from	GRlinear	import	GRgetpolyline;
from	GRtext		import	GRgettxattr;
from	VLctrLine	import	VLcreate;

extern  GRclassid       OPP_ACrg_collect_class_id;
extern  GRclassid       OPP_GR3dpoint_class_id;
extern  GRclassid       OPP_VLctrLine_class_id;
extern  GRclassid       OPP_VLtplObj_class_id;

extern	IGRchar		*strrchr();
extern	IGRdouble	fabs();

/*	#define	TRACE	*/
/*	#define	TRACE_MEMORY	*/

/* ************************************************************************** */
IGRlong	VLtplObj_ret_attr
(
struct	GRid		*lst,
	VLpltTplArg	*arg,
	IGRlong		*msg
)
{		
	IGRint		sts=OM_S_SUCCESS, num;
struct	ACrg_coll	att[NUM_TO_ATTR];


	/* Retrieve : <param_box> */
	sts = om$send ( msg = message ACrg_collect.AClist_attribute
					( msg, NUM_TO_ATTR, att, &num),
			senderid = NULL_OBJID,
			targetid = lst->objid,
			targetos = lst->osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.AClist_attribute",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Fill structure with <param_box> values */
	if (IDX_TO_GRD < num)
		arg->dst    = att[IDX_TO_GRD].desc.value.att_exp;

	if (IDX_TO_EXT1 < num)
		arg->xt1    = att[IDX_TO_EXT1].desc.value.att_exp;

	if (IDX_TO_EXT2 < num)
		arg->xt2    = att[IDX_TO_EXT2].desc.value.att_exp;

	if (IDX_TO_INV < num)
		arg->inv    = (IGRint) att[IDX_TO_INV].desc.value.att_exp;

	if (IDX_TO_PROJ < num)
		arg->prj    = (IGRint) att[IDX_TO_PROJ].desc.value.att_exp;

	if (IDX_TO_SCAL < num)
		arg->sca    = att[IDX_TO_SCAL].desc.value.att_exp;

	if (IDX_TO_MID < num)
		arg->mid    = att[IDX_TO_MID].desc.value.att_exp;

	if (IDX_TO_AXIS < num)
		arg->axe    = (IGRint) att[IDX_TO_AXIS].desc.value.att_exp;

	if (IDX_TO_XVAL < num)
		arg->xpl    = att[IDX_TO_XVAL].desc.value.att_exp;

	if (IDX_TO_YVAL < num)
		arg->ypl    = att[IDX_TO_YVAL].desc.value.att_exp;

	if (IDX_TO_STAT < num)
		arg->sta    = (IGRint) att[IDX_TO_STAT].desc.value.att_exp;

	if (IDX_TO_FULL < num)
		arg->ful    = (IGRint) att[IDX_TO_FULL].desc.value.att_exp;

	if (IDX_TO_HLEN < num)
		arg->len    = att[IDX_TO_HLEN].desc.value.att_exp;

	if (IDX_TO_HRAD < num)
		arg->rad    = att[IDX_TO_HRAD].desc.value.att_exp;

	if (IDX_TO_HWID < num)
		arg->wid    = att[IDX_TO_HWID].desc.value.att_exp;

	if (IDX_TO_UPAR < num)
		arg->upr    = att[IDX_TO_UPAR].desc.value.att_exp;

	if (IDX_TO_VPAR < num)
		arg->vpr    = att[IDX_TO_VPAR].desc.value.att_exp;

	if (IDX_TO_TXSZ < num)
		arg->siz    = att[IDX_TO_TXSZ].desc.value.att_exp;

	if (IDX_TO_XCNT < num)
		arg->cnt[0] = att[IDX_TO_XCNT].desc.value.att_exp;
	else	arg->cnt[0] = 0.0;

	if (IDX_TO_YCNT < num)
		arg->cnt[1] = att[IDX_TO_YCNT].desc.value.att_exp;
	else	arg->cnt[1] = 0.0;

	if (IDX_TO_ZCNT < num)
		arg->cnt[2] = att[IDX_TO_ZCNT].desc.value.att_exp;
	else	arg->cnt[2] = 0.0;

	if (IDX_TO_XNRM < num)
		arg->nrm[0] = att[IDX_TO_XNRM].desc.value.att_exp;
	else	arg->cnt[0] = 0.0;

	if (IDX_TO_YNRM < num)
		arg->nrm[1] = att[IDX_TO_YNRM].desc.value.att_exp;
	else	arg->cnt[1] = 0.0;

	if (IDX_TO_ZNRM < num)
		arg->nrm[2] = att[IDX_TO_ZNRM].desc.value.att_exp;
	else	arg->cnt[2] = 0.0;

wrapup:
	return (sts);
}
/* ************************************************************************** */
IGRlong	VLtplObj_set_attr
(
struct	GRid		*lst,
	VLpltTplArg	*arg,
	IGRlong		*msg
)
{		
		IGRint		sts=OM_S_SUCCESS, i;
	struct	ACrg_coll	att[NUM_TO_ATTR];
	
	/* Create parameter box : names */
	strcpy ( att[IDX_TO_GRD].name,   NAM_TO_GRD );
	strcpy ( att[IDX_TO_EXT1].name,  NAM_TO_EXT1 );
	strcpy ( att[IDX_TO_EXT2].name,  NAM_TO_EXT2 );
	strcpy ( att[IDX_TO_INV].name,   NAM_TO_INV );
	strcpy ( att[IDX_TO_PROJ].name,  NAM_TO_PROJ );
	strcpy ( att[IDX_TO_SCAL].name,  NAM_TO_SCAL );
	strcpy ( att[IDX_TO_MID].name,   NAM_TO_MID );
	strcpy ( att[IDX_TO_AXIS].name,  NAM_TO_AXIS );
	strcpy ( att[IDX_TO_XVAL].name,  NAM_TO_XVAL );
	strcpy ( att[IDX_TO_YVAL].name,  NAM_TO_YVAL );
	strcpy ( att[IDX_TO_STAT].name,  NAM_TO_STAT );
	strcpy ( att[IDX_TO_FULL].name,  NAM_TO_FULL );
	strcpy ( att[IDX_TO_HLEN].name,  NAM_TO_HLEN );
	strcpy ( att[IDX_TO_HRAD].name,  NAM_TO_HRAD );
	strcpy ( att[IDX_TO_HWID].name,  NAM_TO_HWID );
	strcpy ( att[IDX_TO_UPAR].name,  NAM_TO_UPAR );
	strcpy ( att[IDX_TO_VPAR].name,  NAM_TO_VPAR );
	strcpy ( att[IDX_TO_TXSZ].name,  NAM_TO_TXSZ );
	strcpy ( att[IDX_TO_XCNT].name,  NAM_TO_XCNT );
	strcpy ( att[IDX_TO_YCNT].name,  NAM_TO_YCNT );
	strcpy ( att[IDX_TO_ZCNT].name,  NAM_TO_ZCNT );
	strcpy ( att[IDX_TO_XNRM].name,  NAM_TO_XNRM );
	strcpy ( att[IDX_TO_YNRM].name,  NAM_TO_YNRM );
	strcpy ( att[IDX_TO_ZNRM].name,  NAM_TO_ZNRM );
	
	/* Create parameter box : names */
	for ( i=0; i<NUM_TO_ATTR; i++) 	att[i].desc.type = AC_ATTRIB_DOUBLE;
	
	/* Create parameter box : values */
	att[IDX_TO_GRD].desc.value.att_exp  = arg->dst;
	att[IDX_TO_EXT1].desc.value.att_exp = arg->xt1;
	att[IDX_TO_EXT2].desc.value.att_exp = arg->xt2;
	att[IDX_TO_INV].desc.value.att_exp  = (IGRdouble) arg->inv;
	att[IDX_TO_PROJ].desc.value.att_exp = (IGRdouble) arg->prj;
	att[IDX_TO_SCAL].desc.value.att_exp = arg->sca;
	att[IDX_TO_MID].desc.value.att_exp  = arg->mid;
	att[IDX_TO_AXIS].desc.value.att_exp = (IGRdouble) arg->axe;
	att[IDX_TO_XVAL].desc.value.att_exp = arg->xpl;
	att[IDX_TO_YVAL].desc.value.att_exp = arg->ypl;
	att[IDX_TO_STAT].desc.value.att_exp = (IGRdouble) arg->sta;
	att[IDX_TO_FULL].desc.value.att_exp = (IGRdouble) arg->ful;
	att[IDX_TO_HLEN].desc.value.att_exp = arg->len;
	att[IDX_TO_HRAD].desc.value.att_exp = arg->rad;
	att[IDX_TO_HWID].desc.value.att_exp = arg->wid;
	att[IDX_TO_UPAR].desc.value.att_exp = arg->upr;
	att[IDX_TO_VPAR].desc.value.att_exp = arg->vpr;
	att[IDX_TO_TXSZ].desc.value.att_exp = arg->siz;
	att[IDX_TO_XCNT].desc.value.att_exp = arg->cnt[0];
	att[IDX_TO_YCNT].desc.value.att_exp = arg->cnt[1];
	att[IDX_TO_ZCNT].desc.value.att_exp = arg->cnt[2];
	att[IDX_TO_XNRM].desc.value.att_exp = arg->nrm[0];
	att[IDX_TO_YNRM].desc.value.att_exp = arg->nrm[1];
	att[IDX_TO_ZNRM].desc.value.att_exp = arg->nrm[2];

	/* Create parameter box : construct */
	om$construct ( classid = OPP_ACrg_collect_class_id,
		       osnum   = lst->osnum,
		       p_objid = &lst->objid );

	/* Create parameter box : setting */
	sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
					( msg, NUM_TO_ATTR, att),
			senderid = NULL_OBJID,
			targetid = lst->objid,
			targetos = lst->osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACset_list_attribute",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */
IGRlong VLconstCntrLine ( msg, num, plt, Axis, side, norm, Env, Kline)

		IGRlong		*msg;	/*O	Return code	*/
		IGRint		num;	/*I	VSplates number	*/
	struct	GRobj_env	*plt;	/*I	VSplates array	*/
		IGRdouble	*Axis;	/*I	Ship axis	*/
		IGRchar		*side;	/*I	VS plate side	*/
		IGRdouble	*norm;	/*I	for bottom jigs	*/
	struct	GRmd_env	*Env;	/*I	Module info	*/
	struct	GRid		*Kline;	/*O	1st control line*/

{

		IGRint		sts=MSFAIL, flag=0;
		IGRchar		axis;
	struct	GRid		dummy;
		IGRvector	vec;
		IGRpoint	spt, ept;
		BSrc		rc;

	/* Initialize */
	Kline->osnum = Env->md_id.osnum;
	Kline->objid = NULL_OBJID;

	/* Get ship axis */
        if      (Axis[0] == 1.0)        axis = 'x';
        else if (Axis[1] == 1.0)        axis = 'y';
        else if (Axis[2] == 1.0)        axis = 'z';
        else                            goto wrapup;

	/* Construct VLctrLine macro */
	sts = om$construct ( classid = OPP_VLctrLine_class_id,
			     osnum   = Kline->osnum,
			     p_objid = &Kline->objid );

	/* Create VLctrLine macro */
        if (num > 1)	flag = 1;
        sts = om$send ( msg = message VLctrLine.VLcreate
                                ( msg, axis, side, flag, num, plt, norm, Env),
                        senderid = NULL_OBJID,
                        targetid = Kline->objid,
                        targetos = Kline->osnum );
        as$status ( sts    = sts,
                    msg    = "VLctrLine.VLcreate",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Move to root VLctrLine macro */
        sts = om$send ( msg = message NDnode.NDmove_to_root (msg,&dummy,Env),
                        senderid = NULL_OBJID,
                        targetid = Kline->objid,
                        targetos = Kline->osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDmove_to_root",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*Kline = dummy;

	/* Extract curve foot */
	sts = vl$return_foot ( msg    = msg,
			       name   = NAM_CL_CV,
			       objId  = Kline,
			       footId = &dummy );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(NAM_CL_CV)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Reorient control line */
	sts = VLendpts ( msg, &dummy, Env, spt, ept);
       	as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	sts = VLvector ( msg, spt, ept, 1.0, 1.0, TRUE, vec);
       	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (BSdotp ( &rc, vec, Axis) < 0) {
		sts = om$send ( msg = message GRcurve.GRrevparm ( msg, Env),
				senderid = NULL_OBJID,
				targetid = dummy.objid,
				targetos = dummy.osnum );
       		as$status ( sts    = sts,
                   	    msg    = "GRcurve.GRrevparm",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}
	
wrapup:
	return (sts);
}
/* ************************************************************************** */
IGRlong	VLbuildCntrLine ( msg, num, plt, Axis, type, side, norm, Env, LK1, LK2)

		IGRlong		*msg;	/*O	Return code	*/
		IGRint		num;	/*I	VSplates number	*/
	struct	GRobj_env	*plt;	/*I	VSplates array	*/
		IGRdouble	*Axis;	/*I	Ship axis	*/
		IGRint		type;	/*I	Plate-jig type	*/
		IGRchar		*side;	/*I	VS plate side	*/
		IGRdouble	*norm;	/*I	for bottom jigs	*/
	struct	GRmd_env	*Env;	/*I	Module info	*/
	struct	GRid		*LK1;	/*O	1st control line*/
	struct	GRid		*LK2;	/*O	2nd control line*/

{

		IGRlong		loc_msg=1;
		IGRint		sts=MSFAIL, idx, nprt=0, nstb=0, i;
		IGRdouble	pln[6];
	struct	GRvg_construct	cst;
	struct	GRid		Pln;
	struct	GRobj_env	Plt, Srf, Sup, *prt, *stb, *Icv, *Ocv, *Rcv;
		IGRshort	zero=0, one=1;
		IGRdouble	bTol, cTol, dTol, prod;
		IGRshort	*inv, *Inv;
		IGRboolean	adj, clo;
	struct	GRlc_info	*ent;
		IGRpoint	spt, ept;
		IGRvector	dir, Xvec, Zvec;
		BSrc		rc;
	struct	GRid		Tline, Fline, Tvect, Fvect;
	struct	IGRpolyline	geom;

	/* Initialize */
	LK1->osnum = Pln.osnum = Env->md_id.osnum;
	LK1->objid = Pln.objid = NULL_OBJID;
	if (LK2) 	*LK2 = *LK1;
	Fline = Fvect = Pln;
	VLinitCnst (&cst);
	cst.env_info = Env;
	prt = NULL;
	stb = NULL;
	Icv = NULL;
	Ocv = NULL;
	Rcv = NULL;
	inv = NULL;
	Inv = NULL;
	BSxtractpar ( msg, BSTOLBASIS,  &bTol);
	BSxtractpar ( msg, BSTOLCHRDHT, &cTol);
	dTol = 5 * cTol;
	ent = NULL;
	Xvec[0] = 1.0;	Xvec[1] = Xvec[2] = 0.0;
	Zvec[0] = Zvec[1] =  0.0; Zvec[2] = 1.0;

	if (type != IDX_J4) {
		if (LK2) {
			sts = exp$create ( exp_name   = NULL,
                     	     	   	   exp_syntax = "plug_lk2",
                     	     	   	   osnum      = Env->md_id.osnum,
                     	     	   	   p_exp_id   = &LK2->objid,
                     	     	   	   p_osnum    = &LK2->osnum,
                     	     	   	   type_rq    = EXP_TEXT );
			if (sts != EXP_SUCCESS)	goto wrapup;
		}
	}

	/* Sort port side from startboard VS plates */
	switch (type) {
		case IDX_J3:
			break;

		case IDX_J4:
			sts = VLsortPortVSplates ( num, plt, side, Env,
						   &nprt, &prt, &nstb, &stb,
						   msg );
			as$status ( sts    = sts,
    	    		    	    msg    = "VLsortPortVSplates()",
    	    		    	    test   = (!(sts & 0x00000001 & (*msg))),
    	    		    	    action = GOTO_VALUE,
    	    		    	    value  = wrapup );
			break;

		case IDX_J5:
			sts = VLsortPortVSplates ( num, plt, side, Env,
						   &nprt, &prt, NULL, NULL,
						   msg );
			as$status ( sts    = sts,
    	    		    	    msg    = "VLsortPortVSplates()",
    	    		    	    test   = (!(sts & 0x00000001 & (*msg))),
    	    		    	    action = GOTO_VALUE,
    	    		    	    value  = wrapup );
			break;

		default:
			printf( "Unknown template-jig type <%d> ...\n", type);
			goto wrapup;
	}

	/* Case of cylindrical double bottom */
	if (type == IDX_J5) {
#ifdef TRACE
printf( "\tCylindrical Double Bottom case ...\n\n");
#endif

		sts = VLconstCntrLine ( msg, nprt, prt, Axis, side, norm, Env,
					LK1);
		as$status ( sts    = sts,
		    	    msg    = "VLconstCntrLine(PRT)",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );

		/* Extract FALSE line */
		sts = vl$return_foot ( msg    = msg,
				       name   = NAM_CL_CV,
				       objId  = LK1,
				       footId = &Fline );
        	as$status ( sts    = sts,
                    	    msg    = "vl$return_foot(NAM_CL_CV)",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		/* Extract FALSE vector */
		sts = vl$return_foot ( msg    = msg,
				       name   = NAM_CL_VECT,
				       objId  = LK1,
				       footId = &Fvect );
        	as$status ( sts    = sts,
                    	    msg    = "vl$return_foot(NAM_CL_VECT)",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		pln[0] = pln[2] = pln[3] = pln[5] = 0.0;
		pln[1] = cTol;
		pln[4] = 1.0;
		sts = VLcreatePlane ( &pln[0], &pln[3], Env, &cst, &Pln, msg);
		as$status ( sts    = sts,
		    	    msg    = "VLcreatePlane()",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );
#ifdef TRACE
printf( "VLcreatePlane ([%g,%g,%g],[%g,%g,%g]) : (%d|%d)\n",
	pln[0], pln[1], pln[2], pln[3], pln[4], pln[5], Pln.osnum, Pln.objid);
#endif

#ifdef TRACE_MEMORY
printf( "Icv = om$calloc (%d,<struct GRobj_env>)\n", nprt);
#endif
		Icv = om$calloc ( num = nprt, structure = struct GRobj_env );

		idx = 0;
		for ( i=0; i<nprt; i++) {
			sts = vl$return_foot ( msg     = msg,
					       objId   = &prt[i].obj_id,
					       objEnv  = Env,
					       footId  = &Plt.obj_id,
					       footEnv = &Plt.mod_env );
			as$status ( sts    = sts,
	    	    	    	    msg    = "vl$return_foot",
	    	    	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    	    	    action = GOTO_VALUE,
	    	    	    	    value  = wrapup );

			sts = VLextractVSplateSurface (
				msg, &Plt.obj_id, &Plt.mod_env, side,
				&Srf.obj_id, &Srf.mod_env,
				(struct IGRbsp_surface **) NULL );
			as$status ( sts    = sts,
		    	    	    msg    = "VLextractVSplateSurface()",
		    	    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    	    action = GOTO_VALUE,
		    	    	    value  = wrapup );

			Sup.obj_id.osnum = Env->md_id.osnum;
			Sup.obj_id.objid = NULL_OBJID;
			Sup.mod_env      = *Env;
			sts = gr$copy_object ( msg	    = msg,
					       object_id    = &Srf.obj_id,
					       md_env	    = &Srf.mod_env,
					       new_env	    = &Sup.mod_env,
					       new_id	    = &Sup.obj_id,
					       display_flag = 0 );
			as$status ( sts    = sts,
		    	    	    msg    = "gr$copy_object()",
		    	    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    	    action = GOTO_VALUE,
		    	    	    value  = wrapup );
#ifdef TRACE
printf( "i=%d, plt : (%d|%d), srf : (%d|%d), sup : (%d|%d)\n",
	i, prt[i].obj_id.osnum, prt[i].obj_id.objid,
	Srf.obj_id.osnum, Srf.obj_id.objid, Sup.obj_id.osnum, Sup.obj_id.objid);
#endif

			Icv[idx].mod_env = *Env;
			sts = VLcreateInter ( msg, &Sup.obj_id, &Sup.mod_env,
						one, &Pln, Env, zero,
						&Icv[idx].obj_id,
						&Icv[idx].mod_env );
			
#ifdef TRACE
printf( "Icv[%d] : (%d|%d)\n", idx,Icv[idx].obj_id.osnum,Icv[idx].obj_id.objid);
#endif

			if (sts & 1 & (*msg))	idx++;

			sts = gr$delete_object ( msg       = msg,
				   	 	 md_env    = &Sup.mod_env,
				   	 	 object_id = &Sup.obj_id )
			as$status ( sts    = sts,
		    	    	    msg    = "gr$delete_object(copy surface)",
		    	    	    test   = (!(sts & 0x00000001 & (*msg))) );
		}
		if (idx == 0)	{
printf( "No intersection found between VSplates and plane Y=0\n");
			goto wrapup; }

#ifdef TRACE_MEMORY
printf( "Ocv = om$calloc (%d,<struct GRobj_env>)\n", idx);
#endif
		Ocv = om$calloc ( num = idx, structure = struct GRobj_env );

#ifdef TRACE_MEMORY
printf( "Rcv = om$calloc (%d,<struct GRobj_env>)\n", idx);
#endif
		Rcv = om$calloc ( num = idx, structure = struct GRobj_env );

#ifdef TRACE_MEMORY
printf( "inv = om$calloc (%d,<IGRshort>)\n", idx);
#endif
		inv = om$calloc ( num = idx, structure = IGRshort );

#ifdef TRACE_MEMORY
printf( "Inv = om$calloc (%d,<IGRshort>)\n", idx);
#endif
		Inv = om$calloc ( num = idx, structure = IGRshort );

		OrderCrv ( Icv, idx, dTol, bTol, Ocv, inv, &adj, &clo, msg);
		if (*msg != BSSUCC) { printf( "Error in OrderCrv() : %d\n",
				      *msg); *msg = MSFAIL; goto wrapup; }
#ifdef TRACE
for ( i=0; i<idx; i++)
printf( "Icv[%d] : (%d|%d)\tOcv[%d] : (%d|%d)\tinv[%d] = %d\n",
	i, Icv[i].obj_id.osnum, Icv[i].obj_id.objid,
	i, Ocv[i].obj_id.osnum, Ocv[i].obj_id.objid, i, inv[i] );
#endif

		sts = VLendpts(msg, &Ocv[0].obj_id, &Ocv[0].mod_env, spt, ept);
		as$status ( sts    = sts,
		    	    msg    = "VLendpts",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );
		for ( i=0; i<3; i++)	dir[i] = ept[i] - spt[i];
		BSnorvec ( &rc, dir);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		
		/* Reorient control line */
		prod = BSdotp ( &rc, dir, Xvec);
		prod *= inv[0];
		if (prod >= 0.0) {
			for ( i=0; i<idx; i++) { Rcv[i] = Ocv[idx-1-i];
						 Inv[i] = inv[idx-1-i] * -1; }
		}
		else {
			for ( i=0; i<idx; i++) { Rcv[i] = Ocv[i];
						 Inv[i] = inv[i]; }
		}

#ifdef TRACE_MEMORY
printf( "ent = om$calloc (%d,<struct GRlc_info>)\n", idx);
#endif
		ent = om$calloc ( num = idx, structure = struct GRlc_info );

		for ( i=0; i<idx; i++) { ent[i].module_info = Rcv[i].mod_env;
					 ent[i].located_obj = Rcv[i].obj_id; }

		/* Build TRUE line */
		BuildCrv ( 3, Rcv, idx, Inv, adj, clo, ent, &cst, &Tline, msg);
		if (*msg != BSSUCC) { printf( "Error in BuildCrv() : %d\n",
				      *msg); *msg = MSFAIL; goto wrapup; }
		else	*msg = MSSUCC;
#ifdef TRACE
printf( "Control Line is (%d|%d) from %d intersections\n",
	Tline.osnum, Tline.objid, idx);
#endif

		/* Build TRUE vector */
		cst.geometry    = (IGRchar *) &geom;
		geom.num_points = (IGRlong) 1;
		geom.points	= (IGRdouble *) Zvec;
		Tvect.objid	= NULL_OBJID;
		Tvect.osnum	= Env->md_id.osnum;
		sts = om$construct ( classid = OPP_GR3dpoint_class_id,
				     osnum   = Tvect.osnum,
				     p_objid = &Tvect.objid,
				     msg     = message GRgraphics.GRaltconstruct
								(&cst) );
		*msg = *(cst.msg);
        	as$status ( sts    = sts,
                    	    msg    = "om$construct(OPP_GR3dpoint_class_id)",
                    	    test   = (!(sts & 0x00000001 & (*msg))) );

		/* Disconnect FALSE line */
		sts = om$send ( msg = message Root.disconnect ( AS_to_owner,
								LK1->objid,
								LK1->osnum,
								AS_to_comp ),
				senderid = NULL_OBJID,
				targetid = Fline.objid,
				targetos = Fline.osnum );
		as$status ( sts    = sts,
		    	    msg    = "Root.disconnect(Fline)",
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );

		/* Disconnect FALSE vector */
		sts = om$send ( msg = message Root.disconnect ( AS_to_owner,
								LK1->objid,
								LK1->osnum,
								AS_to_comp ),
				senderid = NULL_OBJID,
				targetid = Fvect.objid,
				targetos = Fvect.osnum );
		as$status ( sts    = sts,
		    	    msg    = "Root.disconnect(Fvect)",
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );

		/* Connect TRUE line */
		sts = om$send ( msg = message Root.connect ( AS_to_owner,
							     IDX_CL_CV,
							     LK1->objid,
							     LK1->osnum,
							     AS_to_comp,
							     OM_K_MAXINT ),
				senderid = NULL_OBJID,
				targetid = Tline.objid,
				targetos = Tline.osnum );
		as$status ( sts    = sts,
		    	    msg    = "Root.connect(Tline)",
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );

		/* Connect TRUE vector */
		sts = om$send ( msg = message Root.connect ( AS_to_owner,
							     IDX_CL_VECT,
							     LK1->objid,
							     LK1->osnum,
							     AS_to_comp,
							     OM_K_MAXINT ),
				senderid = NULL_OBJID,
				targetid = Tvect.objid,
				targetos = Tvect.osnum );
		as$status ( sts    = sts,
		    	    msg    = "Root.connect(Tvect)",
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );
	}

	/* Case of wall/shell plates */
	else if (type == IDX_J3) {

		sts = VLconstCntrLine ( msg, num, plt, Axis, side, norm, Env,
					LK1);
		as$status ( sts    = sts,
		    	    msg    = "VLconstCntrLine()",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );
	}

	/* Case of flat double bottom */
	else if (type == IDX_J4) {

		if (nprt) {
			sts = VLconstCntrLine ( msg, nprt, prt, Axis, side,
						norm, Env, LK1);
			as$status ( sts    = sts,
			    	    msg    = "VLconstCntrLine(PRT)",
			    	    test   = (!(sts & 0x00000001 & (*msg))),
			    	    action = GOTO_VALUE,
			    	    value  = wrapup );
		}
		else {	sts = exp$create ( exp_syntax = "plug_lk1",
					   osnum      = Env->md_id.osnum,
					   p_exp_id   = &LK1->objid,
					   p_osnum    = &LK1->osnum,
					   type_rq    = EXP_TEXT );
			as$status ( sts    = sts,
			    	    msg    = "exp$create(PRT)",
			    	    test   = (!(sts & 0x00000001 & (*msg))),
			    	    action = GOTO_VALUE,
			    	    value  = wrapup );
		}

		if (nstb) {
			sts = VLconstCntrLine ( msg, nstb, stb, Axis, side,
						norm, Env, LK2);
			as$status ( sts    = sts,
			    	    msg    = "VLconstCntrLine(STB)",
			    	    test   = (!(sts & 0x00000001 & (*msg))),
			    	    action = GOTO_VALUE,
			    	    value  = wrapup );
		}
		else {	sts = exp$create ( exp_syntax = "plug_lk2",
					   osnum      = Env->md_id.osnum,
					   p_exp_id   = &LK2->objid,
					   p_osnum    = &LK2->osnum,
					   type_rq    = EXP_TEXT );
			as$status ( sts    = sts,
			    	    msg    = "exp$create(STB)",
			    	    test   = (!(sts & 0x00000001 & (*msg))),
			    	    action = GOTO_VALUE,
			    	    value  = wrapup );
		}
	}

wrapup:
	/* Delete plane (if needed) */
	if (Pln.objid != NULL_OBJID) {
		sts = gr$delete_object ( msg       = &loc_msg,
				   	 md_env    = Env,
				   	 object_id = &Pln )
		as$status ( sts    = sts,
		    	    msg    = "gr$delete_object(plane)",
		    	    test   = (!(sts & 0x00000001 & loc_msg)) );
	}

	/* Delete FALSE line (if needed) */
	if (Fline.objid != NULL_OBJID) {
		sts = gr$delete_object ( msg       = &loc_msg,
				   	 md_env    = Env,
				   	 object_id = &Fline )
		as$status ( sts    = sts,
		    	    msg    = "gr$delete_object(FALSE line)",
		    	    test   = (!(sts & 0x00000001 & loc_msg)) );
	}

	/* Delete FALSE vector (if needed) */
	if (Fvect.objid != NULL_OBJID) {
		sts = gr$delete_object ( msg       = &loc_msg,
				   	 md_env    = Env,
				   	 object_id = &Fvect )
		as$status ( sts    = sts,
		    	    msg    = "gr$delete_object(FALSE vector)",
		    	    test   = (!(sts & 0x00000001 & loc_msg)) );
	}

	/* Deallocate memory */
	if (ent) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = ent)\n");
#endif
		om$dealloc (ptr = ent);
		ent = NULL;
	}
	if (Inv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Inv)\n");
#endif
		om$dealloc (ptr = Inv);
		Inv = NULL;
	}
	if (inv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = inv)\n");
#endif
		om$dealloc (ptr = inv);
		inv = NULL;
	}
	if (Rcv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Rcv)\n");
#endif
		om$dealloc (ptr = Rcv);
		Rcv = NULL;
	}
	if (Ocv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Ocv)\n");
#endif
		om$dealloc (ptr = Ocv);
		Ocv = NULL;
	}
	if (Icv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Icv)\n");
#endif
		om$dealloc (ptr = Icv);
		Icv = NULL;
	}
	if (stb) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = stb)\n");
#endif
		om$dealloc (ptr = stb);
		stb = NULL;
	}
	if (prt) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = prt)\n");
#endif
		om$dealloc (ptr = prt);
		prt = NULL;
	}

	return (sts);
}
/* ************************************************************************** */
IGRlong	VLsortPortVSplates ( nplt, plt, side, Env, nprt, prt, nstb, stb, msg)

		IGRint		nplt;	/*I	VSplates number		  */
	struct	GRobj_env	*plt;	/*IO	VSplates array		  */
		IGRchar		*side;	/*I	VS plate side		  */
	struct	GRmd_env	*Env;	/*I	Module info	*/
		IGRint		*nprt;	/*O	Port VSplates number	  */
	struct	GRobj_env	**prt;	/*O	Port VSplates array	  */
		IGRint		*nstb;	/*O	Starboard VSplates number */
	struct	GRobj_env	**stb;	/*O	Starboard VSplates array  */
		IGRlong		*msg;	/*O	Return code		  */

{
		IGRint		i, sts=MSFAIL;
	struct	GRobj_env	Plt, Srf;
	struct	IGRbsp_surface	*sf;
		BSrc		rc;
		IGRpoint	pnt[1];
		IGRdouble	cTol, Ipnt[4], Opnt[4];
		IGRboolean	prt_flag=FALSE, stb_flag=FALSE;
		IGRshort	four=4, one=1;
		IGRmatrix	mat;

	/* Initialization */
	sf    = NULL;
	if (prt) {
		prt_flag = TRUE; *prt = NULL; *nprt = 0;
#ifdef TRACE_MEMORY
printf( "*prt = om$calloc (%d,<struct GRobj_env>)\n", nplt);
#endif
		*prt = om$calloc ( num = nplt, structure = struct GRobj_env );
	}
	if (stb) {
		stb_flag = TRUE; *stb = NULL; *nstb = 0;
#ifdef TRACE_MEMORY
printf( "*stb = om$calloc (%d,<struct GRobj_env>)\n", nplt);
#endif
		*stb = om$calloc ( num = nplt, structure = struct GRobj_env );
	}
	if ( (!prt_flag) && (!stb_flag) )	goto wrapup;
	BSxtractpar ( msg, BSTOLCHRDHT, &cTol);
	cTol  *= -1.0;

	/* Extract VSplate support surface */
	for ( i=0; i<nplt; i++) {
		sts = vl$return_foot ( msg     = msg,
				       objId   = &plt[i].obj_id,
				       objEnv  = Env,
				       footId  = &Plt.obj_id,
				       footEnv = &Plt.mod_env );
		as$status ( sts    = sts,
	    	    	    msg    = "vl$return_foot",
	    	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    	    action = GOTO_VALUE,
	    	    	    value  = wrapup );

		if (sf)	{
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = sf)\n");
#endif
			om$dealloc (ptr = sf);
			sf = NULL;
		}
		sts = VLextractVSplateSurface ( msg,
						   &Plt.obj_id,
						   &Plt.mod_env,
						   side,
						   &Srf.obj_id,
						   &Srf.mod_env,
						   &sf );
		as$status ( sts    = sts,
	    	    	    msg    = "VLextractVSplateSurface()",
	    	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    	    action = GOTO_VALUE,
	    	    	    value  = wrapup );
		dblcpy ( mat, Plt.mod_env.md_env.matrix, 16);
		
		BSsfeval ( sf, 0.5, 0.5, 0, pnt, &rc);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		dblcpy ( Ipnt, pnt[0], 3);	Ipnt[3] = 1.0;
		MAmulmx ( msg, &four, &four, &one, mat, Ipnt, Opnt);
		if (Opnt[1] < cTol) {
			if (stb_flag) { (*stb)[*nstb] = plt[i]; (*nstb)++; }
		}
		else { 	if (prt_flag) { (*prt)[*nprt] = plt[i]; (*nprt)++; }
		}
	}

wrapup :
	if (sf)	{
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = sf)\n");
#endif
		om$dealloc (ptr = sf);
		sf = NULL;
	}
	return (sts);
}
/* ************************************************************************** */
IGRlong	VLextractSpineTplInfo ( msg, Spine, Spt1, Spt2, Name ) 

		IGRlong		*msg;		/*O Return code		      */
	struct	GRid		*Spine;		/*I Spine template object     */
		IGRpoint	Spt1;		/*O Spine weld point 1	      */
		IGRpoint	Spt2;		/*O Spine weld point 2	      */
		IGRchar		*Name;		/*O Spine template name	      */

{
		IGRint		sts, action=1;
	struct	GRobj_env	dummy;
		IGRshort	text_length=0;
		IGRuchar	*text_string;
	struct	IGRpolyline	poly;

	/* Initialize */
	text_string = NULL;

	/* Allocate memory for weld lines */
	poly.num_points = (IGRlong) 2;
#ifdef TRACE_MEMORY
printf( "poly.points = om$calloc (%d,<IGRdouble>)\n", 3 * poly.num_points);
#endif
        poly.points = om$calloc ( num = 3 * poly.num_points,
                                  structure = IGRdouble );

	/* Get weld point 1 */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_LINE1,
			       objId   = Spine,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(LINE1)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message GRlinear.GRgetpolyline (
					msg,
					&dummy.mod_env.md_env.matrix_type,
					dummy.mod_env.md_env.matrix,
					&action, &poly ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRlinear.GRgetpolyline(LINE1)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	dblcpy ( Spt1, &(poly.points[3]), 3);

	/* Get weld point 2 */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_LINE2,
			       objId   = Spine,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(LINE2)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );


	sts = om$send ( msg = message GRlinear.GRgetpolyline (
					msg,
					&dummy.mod_env.md_env.matrix_type,
					dummy.mod_env.md_env.matrix,
					&action, &poly ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRlinear.GRgetpolyline(LINE1)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	dblcpy ( Spt2, &(poly.points[3]), 3);

	/* Get template name */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_NAME,
			       objId   = Spine,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(NAME)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message GRtext.GRgettxattr ( msg,
							   NULL,
							   &text_length,
							   &text_string ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRtext.GRgettxattr(NAME)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve title */
	co$rm_esc_seqs ( msg 	     = msg,
			 font_num    = (IGRshort)0,
			 font_flags  = (IGRint)0,
			 text_string = text_string,
			 text_length = &text_length );
	strncpy ( Name, text_string, text_length);
	Name[text_length] = '\0';
	
wrapup:
	if (text_string)	{
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = text_string)\n");
#endif
		om$dealloc (ptr = text_string);
		text_string = NULL;
	}

	if (poly.points)	{
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = poly.points)\n");
#endif
		om$dealloc (ptr = poly.points);
		poly.points = NULL;
	}

	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
VLdirectionOrientation (	IGRvector	dir,
				IGRchar		*txt	)
{
	IGRvector	vec, dot;
	BSrc		rc;

	/* X direction */
	vec[0]=1.0; vec[1]=vec[2]=0.0;
	dot[0] = BSdotp ( &rc, dir, vec);

	/* Y direction */
	vec[1]=1.0; vec[0]=vec[2]=0.0;
	dot[1] = BSdotp ( &rc, dir, vec);

	/* Z direction */
	vec[2]=1.0; vec[0]=vec[1]=0.0;
	dot[2] = BSdotp ( &rc, dir, vec);

	/* Absolute values */
	vec[0] = fabs(dot[0]);
	vec[1] = fabs(dot[1]);
	vec[2] = fabs(dot[2]);

	/* Determine direction */
	if ( (vec[0] >= vec[1]) && (vec[0] >= vec[2]) ) {
		if (dot[0] >= 0.0)	strcpy ( txt, "FWD" );
		else			strcpy ( txt, "AFT" );
	}
	else if ( (vec[1] >= vec[0]) && (vec[1] >= vec[2]) ) {
		if (dot[1] >= 0.0)	strcpy ( txt, "PRT" );
		else			strcpy ( txt, "STB" );
	}
	else {
		if (dot[2] >= 0.0)	strcpy ( txt, "TOP" );
		else			strcpy ( txt, "BOT" );
	}

}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLextractTemplateCht ( msg, Template, Spt1, Spt2,
			       Title, Rhei, Rcht, Angle, LeanDir, Shei, Scht )

		IGRlong		*msg;		/*O Return code		      */
	struct	GRid		*Template;	/*I Template object	      */
		IGRpoint	Spt1;		/*I Spine weld point 1	      */
		IGRpoint	Spt2;		/*I Spine weld point 2	      */
		IGRchar		*Title;		/*O Template title	      */
		IGRdouble	*Rhei;		/*O Regular template height   */
		IGRdouble	*Rcht;		/*O Regular template CHT      */
		IGRdouble	*Angle;		/*O Angle LKline CTRLine      */
		IGRchar		*LeanDir; 	/*O Template lean orientation */
		IGRdouble	*Shei;		/*O Spine template height     */
		IGRdouble	*Scht;		/*O Spine template CHT        */

{

		IGRint		sts, action=1;
	struct	GRobj_env	dummy;
		IGRpoint	Wpt1, Wpt2, Lpt1, Lpt2, Inter, p, Wpt3;
	struct	IGRpolyline	poly;
		IGRshort	text_length=0;
		IGRuchar	*text_string;
		BSrc		rc;
		IGRvector	hei, cht, n, q1, q2;
	struct	IGRplane	plane;
		IGRchar		LEAN[3];
	struct	ret_struct	str;

	/* Initialize */
	Title[0]     	= '\0';
	*Rhei  = 0.0;
	*Rcht  = 0.0;
	*Angle = 0.0;
	LeanDir[0]	= '\0';
	*Shei  = 0.0;
	*Scht  = 0.0;
        poly.points  = NULL;
	text_string  = NULL;
	plane.point  = p;
	plane.normal = n;
	LEAN[0]	     = '\0';

	/* Allocate memory for LK line */
	poly.num_points = (IGRlong) 3;
#ifdef TRACE_MEMORY
printf( "poly.points = om$calloc (%d,<IGRdouble>)\n", 3 * poly.num_points);
#endif
        poly.points = om$calloc ( num = 3 * poly.num_points,
                                  structure = IGRdouble );

	/* Get weld point 1 */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_LINE1,
			       objId   = Template,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(LINE1)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message GRlinear.GRgetpolyline (
					msg,
					&dummy.mod_env.md_env.matrix_type,
					dummy.mod_env.md_env.matrix,
					&action, &poly ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRlinear.GRgetpolyline(LINE1)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	dblcpy ( Wpt3, &(poly.points[0]), 3);
	dblcpy ( Wpt1, &(poly.points[3]), 3);

	/* Get weld point 2 */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_LINE2,
			       objId   = Template,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(LINE2)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message GRlinear.GRgetpolyline (
					msg,
					&dummy.mod_env.md_env.matrix_type,
					dummy.mod_env.md_env.matrix,
					&action, &poly ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRlinear.GRgetpolyline(LINE2)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	dblcpy ( Wpt2, &(poly.points[3]), 3);

	/* Get LK line */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_LINE,
			       objId   = Template,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(LINE)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message GRlinear.GRgetpolyline (
					msg,
					&dummy.mod_env.md_env.matrix_type,
					dummy.mod_env.md_env.matrix,
					&action, &poly ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRlinear.GRgetpolyline(LINE)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get LK angle */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_ANGL,
			       objId   = Template,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(ANGL)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message GRtext.GRgettxattr ( msg,
							   NULL,
							   &text_length,
							   &text_string ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRtext.GRgettxattr(ANGL)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve angle */
	co$rm_esc_seqs ( msg 	     = msg,
			 font_num    = (IGRshort)0,
			 font_flags  = (IGRint)0,
			 text_string = text_string,
			 text_length = &text_length );
	text_string[text_length] = '\0';
	sscanf ( (IGRchar *) text_string, "%lf", Angle);

	/* Get template title */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_NAME,
			       objId   = Template,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(NAME)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message GRtext.GRgettxattr ( msg,
							   NULL,
							   &text_length,
							   &text_string ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRtext.GRgettxattr(NAME)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve title */
	co$rm_esc_seqs ( msg 	     = msg,
			 font_num    = (IGRshort)0,
			 font_flags  = (IGRint)0,
			 text_string = text_string,
			 text_length = &text_length );
	strncpy ( Title, text_string, text_length);
	Title[text_length] = '\0';

	/* Get template contour */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TO_CONT,
			       objId   = Template,
			       footId  = &dummy.obj_id,
			       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
	    	    msg    = "vl$return_foot(CONT)",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

	/* Extract template plane */
	sts = om$send ( msg = message GRvg.GRdetplane (
					msg,
					&dummy.mod_env.md_env.matrix_type,
					dummy.mod_env.md_env.matrix,
					&plane ),
			senderid = NULL_OBJID,
			targetid = dummy.obj_id.objid,
			targetos = dummy.obj_id.osnum);
	if (!(sts & 0x00000001 & (*msg))) {

		dblcpy ( plane.point, Wpt3, 3);

		sts = VLvector ( msg, Wpt3, Wpt1, 1.0, 1.0, TRUE, q1);
		as$status ( sts    = sts,
	    	    	    msg    = "VLvector()",
	    	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    	    action = GOTO_VALUE,
	    	    	    value  = wrapup );

		sts = VLvector ( msg, Wpt3, Wpt2, 1.0, 1.0, TRUE, q2);
		as$status ( sts    = sts,
	    	    	    msg    = "VLvector()",
	    	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    	    action = GOTO_VALUE,
	    	    	    value  = wrapup );

		BScrossp ( &rc, q2, q1, plane.normal);
		if (rc != BSSUCC) { *msg = MSFAIL;
			    	    printf( "Error in BScrossp()\n");
			    	    goto wrapup; }

		BSnorvec ( &rc, plane.normal);
		if (rc != BSSUCC) { *msg = MSFAIL;
			    	    printf( "Error in BSnorvec()\n");
			    	    goto wrapup; }
#ifdef TRACE
printf( "Template plane evaluated to [%g,%g,%g] & [%g,%g,%g]\n",
	plane.point[0], plane.point[1], plane.point[2],
	plane.normal[0], plane.normal[1], plane.normal[2] );
#endif
	}

	/* Project the two first LK line points in template plane */
	BSproj1 ( &rc, &poly.points[0], plane.normal, plane.point, Lpt1);
	if (rc != BSSUCC) { *msg = MSFAIL;
			    printf( "Error in BSproj1()\n");
			    goto wrapup; }
	BSproj1 ( &rc, &poly.points[3], plane.normal, plane.point, Lpt2);
	if (rc != BSSUCC) { *msg = MSFAIL;
			    printf( "Error in BSproj1()\n");
			    goto wrapup; }

	/* Compute regular template total height */
	BSmkvec ( &rc, hei, Lpt1, Lpt2);
	if (rc != BSSUCC) { *msg = MSFAIL;
			    printf( "Error in BSmkvec()\n");
			    goto wrapup; }

	*Rhei = BSlenvec ( &rc, hei);
	if (rc != BSSUCC) { *msg = MSFAIL;
			    printf( "Error in BSlenvec()\n");
			    goto wrapup; }

	/* Compute regular template CHT */
	BSxln ( &rc, Wpt1, Wpt2, Lpt1, Lpt2, Inter);
	if (rc != BSSUCC) { *msg = MSFAIL;
			    printf( "Error in BSxln()\n");
			    goto wrapup; }

	BSmkvec ( &rc, cht, Lpt1, Inter);
	if (rc != BSSUCC) { *msg = MSFAIL;
			    printf( "Error in BSmkvec()\n");
			    goto wrapup; }

	*Rcht = BSlenvec ( &rc, cht);
	if (rc != BSSUCC) { *msg = MSFAIL;
			    printf( "Error in BSlenvec()\n");
			    goto wrapup; }

	if ( (Spt1) && (Spt2) ) {

		/* Compute spine template total height */
		*Shei = *Rhei;

		/* Compute spine template CHT */
		BSxlnpl ( &rc, plane.normal, plane.point, Spt1, Spt2, Inter);
		if (rc != BSSUCC) { *msg = MSFAIL;
				    printf( "Error in BSxlnpl()\n");
				    goto wrapup; }

		BSmkvec ( &rc, cht, Lpt1, Inter);
		if (rc != BSSUCC) { *msg = MSFAIL;
				    printf( "Error in BSmkvec()\n");
				    goto wrapup; }

		*Scht = BSlenvec ( &rc, cht);
		if (rc != BSSUCC) { *msg = MSFAIL;
				    printf( "Error in BSlenvec()\n");
				    goto wrapup; }
	}
	/* Get Lean Direction */
	sts = vl$return_foot ( msg     = msg,
		       	       name    = NAM_TO_LEAN,
		       	       objId   = Template,
		       	       footId  = &dummy.obj_id,
		       	       footEnv = &dummy.mod_env );
	as$status ( sts    = sts,
	    	    msg    = "vl$return_foot(LEAN)",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

     	sts = om$send ( msg = message NDnode.NDgive_structure
				( msg, &str, &dummy.mod_env ),
               	        senderid = NULL_OBJID,
               	        targetid = dummy.obj_id.objid,
               	        targetos = dummy.obj_id.osnum );
     	as$status ( sts       = sts,
                    msg    = "NDmacro.NDgive_structure",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	strcpy ( LeanDir, str.var.text_st.text_string );

wrapup:
	if (text_string)	{
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = text_string)\n");
#endif
		om$dealloc (ptr = text_string);
		text_string = NULL;
	}

	if (poly.points)	{
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = poly.points)\n");
#endif
		om$dealloc (ptr = poly.points);
		poly.points = NULL;
	}

	return (sts);
}
/* ************************************************************************** */
IGRlong	VLextractTplFromMgr ( msg, Manager, Fidx, Lidx, Spine)

		IGRlong		*msg;		/*O Return code		      */
	struct	GRid		*Manager;	/*O Template manager	      */
		IGRint		*Fidx;		/*O First tpl object index    */
		IGRint		*Lidx;		/*O Last  tpl object index    */
	struct	GRid		*Spine;		/*O Spine tpl object 	      */

{
		IGRint		sts, number=-1;

	/* Initialize */
	*Fidx = -1;
	*Lidx = -1;
	Spine->objid = NULL_OBJID;

	/* Get Template Manager's number of feet */
	sts = om$send ( msg = message GRowner.GRget_number_components
					( msg, &number),
			senderid = NULL_OBJID,
			targetid = Manager->objid,
			targetos = Manager->osnum );
	as$status ( sts    = sts,
		    msg    = "GRowner.GRget_number_components",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Discard unstandable number of feet */
	if (number < MACRO_TM_FFEET) {
printf( "Big trouble in the Force : get only %d feet on %d expected ...\n",
	number, MACRO_TM_FFEET);
		*msg = MSFAIL;
		goto wrapup;
	}
	else {	*Fidx = MACRO_TM_FFEET;	*Lidx = number;	}

	/* Get Spine Template from Template Manager */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_TM_TSPI,
			       objId   = Manager,
			       footId  = Spine );
	*msg = MSSUCC;
	sts  = MSSUCC;
	if (Spine->objid == NULL_OBJID)	goto wrapup;

	/* Verify Spine Template is really a VLtplObj */
	if ( ! (vs$is_ancestry_valid ( object  = Spine,
				       classid = OPP_VLtplObj_class_id ) ) )
		Spine->objid = NULL_OBJID;
	

wrapup:
	return (sts);
}
/* ************************************************************************** */

end implementation VLabstract;
