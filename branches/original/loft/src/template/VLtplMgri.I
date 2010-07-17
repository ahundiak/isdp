class implementation VLtplMgr;

#include	"vlprototype.h"
#include	"AS_status.h"
#include	"ACattrib.h"
#include	"nddef.h"
#include	"grmacros.h"
#include	"bsparameters.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"asmacros.h"
#include	"asbox.h"
#include	"msdef.h"
#include	"msmacros.h"

#include	"vsmiscmacros.h"
#include	"vsplatedef.h"

#include	"vlglobals.h"
#include	"vlplatejig.h"
#include	"vlmiscmacros.h"
#include	"vlmsg.h"

#include	"matypemx.h"

from	ACrg_collect	import	ACget_named_attribute, AClist_attribute,
				ACset_list_attribute;
from	expression	import	NDgive_value;

extern	GRclassid	OPP_GRgencs_class_id;
extern	GRclassid	OPP_VLtplBox_class_id;
extern	GRclassid	OPP_VLtplObj_class_id;
extern	GRclassid	OPP_VLtplSpi_class_id;

extern	void		qsort();
extern	IGRint		VLsortRang();
extern  IGRboolean 	VLverifyIntersect();

/*	#define	TRACE		*/
/*	#define	TRACE_MEMORY	*/

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{

		IGRint		i, j, ncap, ref=-1, I=0, idx, spine_tpl=0;
		IGRlong		sts, size=sizeof(struct GRid);
		IGRshort	type;
	struct	ACrg_coll	attr, mbox[NUM_TB_ATTR];
		VLpltTplArg	arg;
		IGRint		spi_idx=0;
		IGRdouble	Axis[3], grd_dist=0.0;
	struct	GRobj_env	VSplate, RFplane, RIBcsys, SPIcsys;
		IGRchar		side[DI_PATH_MAX];
		IGRdouble	Bx_rngi=0.0,By_rngi=0.0,Bx_rngo=0.0,By_rngo=0.0;
		IGRdouble	Bw_maxi=0.0,Bw_maxo=0.0;
		IGRdouble	Rx_rngi=0.0,Ry_rngi=0.0;
		IGRdouble	Rw_maxi=0.0,Rw_maxo=0.0;
		IGRdouble	u[2], v[2], page_h=0., page_w=0.;
		IGRint		Bp_numi=0,Bp_numo=0,Rp_numi=0,Rp_numo=0;
	struct	GRid		*Tlist, TmpId, LK;
	struct	GRid		Tbox[MACRO_TB_TEMP];
	struct	VLsortTpl	*Sort;
	struct	GRid		foot, *Feet, *lp3d;
		IGRmatrix	PRJmat;
#ifdef TRACE
		IGRpoint	spt, ept;
#endif

#ifdef TRACE
printf("\t>>> Enter in VLtplMgri.ACconstruct_feet\n");
#endif

	/* Initialize */
	*fcount = (MACRO_TM_FFEET + MACRO_TM_VFEET);
	for ( i=0; i<*fcount; i++) {
		feet_list[i].objid = NULL_OBJID;
		feet_list[i].osnum = md_env->md_id.osnum;
	}
	Tlist = NULL;
	Tlist = om$calloc ( num = MACRO_TO_TEMP, structure = struct GRid );
	for ( i=0; i<MACRO_TO_TEMP; i++) {
		Tlist[i].objid = NULL_OBJID;
		Tlist[i].osnum = md_env->md_id.osnum;
	}
	Tlist[IDX_TO_PLAT] = list[IDX_TM_PLAT];
	Sort = NULL;
	Feet = NULL;
	lp3d = NULL;
	arg.dst = arg.xt1 = arg.xt2 = arg.sca = arg.mid = 0.0;
	arg.inv = arg.axe = arg.prj = 0;
	arg.xpl = arg.ypl = arg.len = arg.rad = arg.wid = arg.siz = 0.0;
	arg.ful = 1;
	arg.cnt[0] = arg.cnt[1] = arg.cnt[2] = 0.0;
	arg.nrm[0] = arg.nrm[1] = arg.nrm[2] = 0.0;

	strcpy ( mbox[IDX_TB_PGH].name, NAM_TB_PGH);
	strcpy ( mbox[IDX_TB_PGW].name, NAM_TB_PGW);
	strcpy ( mbox[IDX_TB_PGF].name, NAM_TB_PGF);
	strcpy ( mbox[IDX_TB_PGT].name, NAM_TB_PGT);
	mbox[IDX_TB_PGH].desc.type = AC_ATTRIB_DOUBLE;
	mbox[IDX_TB_PGW].desc.type = AC_ATTRIB_DOUBLE;
	mbox[IDX_TB_PGF].desc.type = AC_ATTRIB_DOUBLE;
	mbox[IDX_TB_PGT].desc.type = AC_ATTRIB_DOUBLE;
	mbox[IDX_TB_PGH].desc.value.att_exp = 0.0;
	mbox[IDX_TB_PGW].desc.value.att_exp = 0.0;
	mbox[IDX_TB_PGF].desc.value.att_exp = 0.0;
	mbox[IDX_TB_PGT].desc.value.att_exp = 0.0;

	/* Evaluate regular template projection flag */
	sts = vl$return_foot ( msg     = msg,
			       objId   = &list[IDX_TM_R_CS],
			       objEnv  = md_env,
			       footId  = &RIBcsys.obj_id,
			       footEnv = &RIBcsys.mod_env );
       	as$status ( sts    = sts,
                    msg    = "vl$return_foot(R_CS)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if (vs$is_ancestry_valid ( object  = &RIBcsys.obj_id,
				   classid = OPP_GRgencs_class_id ) )
		arg.prj = PROJECT_ON;
	else	arg.prj = PROJECT_OF;

	/* Evaluate spine template projection flag */
	sts = vl$return_foot ( msg     = msg,
			       objId   = &list[IDX_TM_B_CS],
			       objEnv  = md_env,
			       footId  = &SPIcsys.obj_id,
			       footEnv = &SPIcsys.mod_env );
       	as$status ( sts    = sts,
                    msg    = "vl$return_foot(B_CS)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if (vs$is_ancestry_valid ( object  = &SPIcsys.obj_id,
				   classid = OPP_GRgencs_class_id ) )
		spi_idx = PROJECT_ON;
	else	spi_idx = PROJECT_OF;

	/* Retrieve spine template flag */
	strcpy ( attr.name, NAM_TM_SPIN);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(SPIN)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        spine_tpl = (IGRint) attr.desc.value.att_exp;

	/* Retrieve full/hollow flag */
	strcpy ( attr.name, NAM_TM_FULL);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(FULL)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        arg.ful = (IGRint) attr.desc.value.att_exp;

	/* Because of false specification */
	if (arg.ful != -1)	arg.ful = 1;

	/* Retrieve hollow length */
	strcpy ( attr.name, NAM_TM_HLEN);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(HLEN)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        arg.len = attr.desc.value.att_exp;

	/* Retrieve hollow radius */
	strcpy ( attr.name, NAM_TM_HRAD);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(HRAD)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        arg.rad = attr.desc.value.att_exp;

	/* Retrieve hollow width */
	strcpy ( attr.name, NAM_TM_HWID);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(HWID)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        arg.wid = attr.desc.value.att_exp;

	/* Retrieve text size */
	strcpy ( attr.name, NAM_TM_TXSZ);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(TXSZ)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        arg.siz = attr.desc.value.att_exp;

	/* Retrieve ship axis value */
	strcpy ( attr.name, NAM_TM_AXIS);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(AXIS)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        arg.axe = (IGRint) attr.desc.value.att_exp;
	Axis[0]   = Axis[1] = Axis[2] = 0.0;
        switch (arg.axe) {
                case IDX_AX1:   Axis[0] = 1.0;
                                break;
                case IDX_AX2:   Axis[1] = 1.0;
                                break;
                case IDX_AX3:   Axis[2] = 1.0;
                                break;
                default:        printf( "No Ship axis retrieved\n");
        }

	/* Retrieve located VS plate */
	sts = vl$return_foot ( msg     = msg,
			       objId   = &list[IDX_TM_PLAT],
			       objEnv  = md_env,
			       footId  = &VSplate.obj_id,
			       footEnv = &VSplate.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(PLAT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve normal inversion */
	strcpy ( attr.name, NAM_TM_INV);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(INV)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        arg.inv = (IGRint) attr.desc.value.att_exp;
	if (arg.inv != INVNORM_OF)	arg.inv = INVNORM_ON;
	if (arg.inv == INVNORM_ON)	strcpy ( side, VS_K_plTopSfPath);
	else				strcpy ( side, VS_K_plBotSfPath);

	/* Compute control line */
	sts = VLbuildCntrLine ( msg, 1, &VSplate, Axis, IDX_J3,
				side, NULL, md_env, &LK, NULL);
       	as$status ( sts    = sts,
                    msg    = "VLbuildCntrLine()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	as$make_source( go_grid = LK,
 			mod_env = md_env,
 			as_os   = md_env->md_id.osnum,
			as_grid = &feet_list[IDX_TM_CTRL]);
	Tlist[IDX_TO_CTRL] = feet_list[IDX_TM_CTRL];
#ifdef TRACE
	VLendpts ( msg, &feet_list[IDX_TM_CTRL], md_env, spt, ept);
	printf( "LK from [%g,%g,%g] to [%g,%g,%g], vec = [%g,%g,%g]\n",
		spt[0], spt[1], spt[2], ept[0], ept[1], ept[2],
		ept[0]-spt[0],  ept[1]-spt[1],  ept[2]-spt[2] );
#endif

	/* Retrieve real ground distance */
	strcpy ( attr.name, NAM_TM_GRD);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(GRD)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        grd_dist = attr.desc.value.att_exp;

	sts = VLevalPltCenterNormalDistance ( &VSplate,
					      1,
					      side,
					      IDX_J3,
					      INVNORM_OF,
					      TRUE,
					      arg.cnt,
					      arg.nrm,
					      &arg.dst,
					      msg );
        as$status ( sts    = sts,
                    msg    = "VLevalPltCenterNormalDistance()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	arg.dst += grd_dist;

	sts = exp$create ( exp_value = arg.dst,
                           p_exp_id  = &feet_list[IDX_TM_REAL].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_REAL].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(REAL)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if ( (arg.prj == PROJECT_ON) || (spi_idx == PROJECT_ON) ) {

		strcpy ( attr.name, NAM_TM_PGH);
        	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        	targetid = list[IDX_TM_ATTR].objid,
                        	targetos = list[IDX_TM_ATTR].osnum );
        	as$status ( sts    = sts,
                    	    msg    = "ACrg_collect.ACget_named_attribute(PGH)",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
        	page_h = attr.desc.value.att_exp;

		strcpy ( attr.name, NAM_TM_PGW);
        	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        	targetid = list[IDX_TM_ATTR].objid,
                        	targetos = list[IDX_TM_ATTR].osnum );
        	as$status ( sts    = sts,
                    	    msg    = "ACrg_collect.ACget_named_attribute(PGW)",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
        	page_w = attr.desc.value.att_exp;
	}

	/* Evaluate Page Number */
	strcpy ( attr.name, NAM_TM_BPNI);
       	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                       	targetid = list[IDX_TM_ATTR].objid,
                       	targetos = list[IDX_TM_ATTR].osnum );
       	as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(BPNI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        Bp_numi = Bp_numo = (IGRint) attr.desc.value.att_exp;

	/* Evaluate Width Max */
	strcpy ( attr.name, NAM_TM_BWMI);
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                       	targetid = list[IDX_TM_ATTR].objid,
                       	targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(BWMI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        Bw_maxi = Bw_maxo = attr.desc.value.att_exp;

	/* Evaluate X place */
	strcpy ( attr.name, NAM_TM_BXRI);
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                       	targetid = list[IDX_TM_ATTR].objid,
                       	targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(BXRI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        Bx_rngi = Bx_rngo = attr.desc.value.att_exp;

	/* Evaluate Y place */
	strcpy ( attr.name, NAM_TM_BYRI);
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                       	targetid = list[IDX_TM_ATTR].objid,
                       	targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(BYRI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        By_rngi = By_rngo = attr.desc.value.att_exp;

	/* Evaluate Page Number */
	strcpy ( attr.name, NAM_TM_RPNI);
       	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                       	targetid = list[IDX_TM_ATTR].objid,
                       	targetos = list[IDX_TM_ATTR].osnum );
       	as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(RPNI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        Rp_numi = (IGRint) attr.desc.value.att_exp;

	/* Evaluate Width Max */
	strcpy ( attr.name, NAM_TM_RWMI);
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                       	targetid = list[IDX_TM_ATTR].objid,
                       	targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(RWMI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        Rw_maxi = attr.desc.value.att_exp;

	/* Evaluate X place */
	strcpy ( attr.name, NAM_TM_RXRI);
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                       	targetid = list[IDX_TM_ATTR].objid,
                       	targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(RXRI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        Rx_rngi = attr.desc.value.att_exp;

	/* Evaluate Y place */
	strcpy ( attr.name, NAM_TM_RYRI);
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                       	targetid = list[IDX_TM_ATTR].objid,
                       	targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(_RYRI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        Ry_rngi = attr.desc.value.att_exp;

	/* Retrieve reference plane|frame */
	for ( i=MACRO_TM_FTEMP; i<count; i++) {
		sts = vl$return_foot ( msg     = msg,
				       objId   = &list[i],
				       objEnv  = md_env,
				       footId  = &RFplane.obj_id,
				       footEnv = &RFplane.mod_env );
        	as$status ( sts    = sts,
                    	    msg    = "vl$return_foot",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		if (VLverifyIntersect ( &VSplate, &RFplane, md_env, msg))
			{	ref = i;	i = count;	}
        	as$status ( sts    = (*msg),
                    	    msg    = "VLverifyIntersect()",
                    	    test   = (!(0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = middle );
	}
	if (ref == -1)	goto wrapup;
	else { 		/* Set reference plane */
			Tlist[IDX_TO_PLAN] = list[ref];	}

	strcpy ( attr.name, NAM_TM_EXT1);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(EXT1)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	arg.xt1 = attr.desc.value.att_exp;

	strcpy ( attr.name, NAM_TM_EXT2);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(EXT2)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	arg.xt2 = attr.desc.value.att_exp;

	strcpy ( attr.name, NAM_TM_SCAL);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(SCAL)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	arg.sca = attr.desc.value.att_exp;

	strcpy ( attr.name, NAM_TM_MID);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(MID)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	arg.mid = attr.desc.value.att_exp;

	strcpy ( attr.name, NAM_TM_AXIS);
        sts = om$send ( msg      = message ACrg_collect.ACget_named_attribute
                                        	( msg, &attr),
                        targetid = list[IDX_TM_ATTR].objid,
                        targetos = list[IDX_TM_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(AXIS)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	arg.axe = attr.desc.value.att_exp;

	/* *****	CREATION OF EXTREMITY TEMPLATE(S)	***** */

	Tlist[IDX_TO_CSYS] = list[IDX_TM_R_CS];

	sts = VLverifyExtremity ( &VSplate, &RFplane, md_env, &ncap, u, v, msg);
        as$status ( sts    = sts,
                    msg    = "VLverifyExtremity()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = middle );

/*  Modification for 179702411    

	for ( i=0; i<ncap; i++) {

		arg.sta = VAL_TO_EXT;
		arg.upr = u[i];
		arg.vpr = v[i];
		sts = VLtplObj_set_attr ( &Tlist[IDX_TO_ATTR], &arg, msg);

	Create EXTREMITY TEMPLATE occurence 
 #ifdef TRACE
printf("\n");
printf("macro_name : <%s>, template number = %d\n",MACRO_TO_DEF,MACRO_TO_TEMP);
for (j=0;j<MACRO_TO_TEMP;j++)
printf("E%d template[%2d] : (%d|%d)\n", I, j, Tlist[j].osnum, Tlist[j].objid);
#endif

		sts = vl$placeLoftMacro ( msg      = msg,
					  classid  = OPP_VLtplObj_class_id,
					  MacName  = MACRO_TO_DEF,
					  number   = MACRO_TO_TEMP,
					  template = Tlist,
					  Env      = md_env,
					  ChgState = FALSE,
					  occ_id   = &TmpId );
	       	as$status ( sts    = sts,
	              	    msg    = "vl$placeLoftMacro(EXTREMITY)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		if (TmpId.objid != NULL_OBJID) {
			feet_list[MACRO_TM_FFEET+I] = TmpId;
#ifdef TRACE
printf( "E feet_list[%d] : (%d|%d)\n", MACRO_TM_FFEET+I,
feet_list[MACRO_TM_FFEET+I].osnum, feet_list[MACRO_TM_FFEET+I].objid);
#endif
			I++;
		}
	}
*/
/*  End modifiction  179702411  */

middle:
	/* *****	CREATION OF MIDDLE TEMPLATE(S)	***** */
	for ( i=MACRO_TM_FTEMP; i<count; i++) {
		sts = vl$return_foot ( msg     = msg,
				       objId   = &list[i],
				       objEnv  = md_env,
				       footId  = &RFplane.obj_id,
				       footEnv = &RFplane.mod_env );
        	as$status ( sts    = sts,
                    	    msg    = "vl$return_foot",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		if (VLverifyIntersect ( &VSplate, &RFplane, md_env, msg)) {

			Tlist[IDX_TO_PLAN] = list[i];

			arg.sta = VAL_TO_MID;
			arg.upr = -1.0;
			arg.vpr = -1.0;
			sts = VLtplObj_set_attr ( &Tlist[IDX_TO_ATTR],
						  &arg, msg);

			/* Create MIDDLE TEMPLATE occurence */
#ifdef TRACE
printf("\n");
printf("macro_name : <%s>, template number = %d\n",MACRO_TO_DEF,MACRO_TO_TEMP);
for (j=0;j<MACRO_TO_TEMP;j++)
printf("M%d template[%2d] : (%d|%d)\n", I, j, Tlist[j].osnum, Tlist[j].objid);
#endif

			sts =
			vl$placeLoftMacro ( msg      = msg,
					    classid  = OPP_VLtplObj_class_id,
					    MacName  = MACRO_TO_DEF,
					    number   = MACRO_TO_TEMP,
					    template = Tlist,
					    Env      = md_env,
					    ChgState = FALSE,
					    occ_id   = &TmpId );
		       	as$status ( sts    = sts,
		              	    msg    = "vl$placeLoftMacro(MIDDLE)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
			if (TmpId.objid != NULL_OBJID) {
				feet_list[MACRO_TM_FFEET+I] = TmpId;
#ifdef TRACE
printf( "M feet_list[%d] : (%d|%d)\n", MACRO_TM_FFEET+I,
feet_list[MACRO_TM_FFEET+I].osnum, feet_list[MACRO_TM_FFEET+I].objid);
#endif
				I++;
			}
		}

        	as$status ( sts    = (*msg),
                    	    msg    = "VLverifyIntersect()",
                    	    test   = (!(0x00000001 & (*msg))) );
	}

	/* Move to root all the template objects */
	for ( i=MACRO_TM_FFEET; i<MACRO_TM_FFEET+I; i++) {
		sts = om$send ( msg = message NDnode.NDmove_to_root
					( msg, &feet_list[i], md_env ),
				targetid = feet_list[i].objid,
				targetos = feet_list[i].osnum);
       		as$status ( sts    = sts,
               	    	    msg    = "NDnode.NDmove_to_root(REGULAR)",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                   	    value  = wrapup );
	}
	*fcount = MACRO_TM_FFEET + I;

	/* *****	CREATION OF SPINE TEMPLATE	***** */

	if (spine_tpl) {

		Tlist[IDX_TO_CSYS] = list[IDX_TM_B_CS];

		arg.sta = VAL_TO_SPI;
		arg.upr = -1.0;
		arg.vpr = -1.0;
		sts = VLtplObj_set_attr ( &Tlist[IDX_TO_ATTR], &arg, msg);

		if (I) {
			idx = (MACRO_TM_FFEET + I) * size;
			Tlist = (struct GRid *) om$realloc (
							ptr  = (IGRchar *)Tlist,
							size = idx );
			for ( i=0; i<I; i++)
				as$make_source (
					go_grid = feet_list[MACRO_TM_FFEET+i],
 					mod_env = md_env,
 					as_os   = md_env->md_id.osnum,
					as_grid = &Tlist[MACRO_TO_TEMP+i] );
		}

		sts = vl$placeLoftMacro ( msg      = msg,
					  classid  = OPP_VLtplSpi_class_id,
					  MacName  = MACRO_TS_DEF,
					  number   = MACRO_TO_TEMP + I,
					  template = Tlist,
					  Env      = md_env,
					  ChgState = FALSE,
					  occ_id   = &TmpId );
	       	as$status ( sts    = sts,
	              	    msg    = "vl$placeLoftMacro(SPINE)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		if (TmpId.objid != NULL_OBJID) {
			sts = om$send ( msg = message NDnode.NDmove_to_root
					( msg, &feet_list[IDX_TM_TSPI], md_env),
					targetid = TmpId.objid,
					targetos = TmpId.osnum );
       			as$status ( sts    = sts,
	               	    	    msg    = "NDnode.NDmove_to_root(SPINE)",
	                    	    test   = (!(sts & 0x00000001 & (*msg))),
	                    	    action = GOTO_VALUE,
	                   	    value  = wrapup );
		}
	}

	if (I > 0)	lp3d = om$calloc ( num = I, structure = struct GRid);

	for ( i=0; i<I; i++) {

		lp3d[i].objid = NULL_OBJID;
		lp3d[i].osnum = md_env->md_id.osnum;

		/* Get 3D lp line */
		sts = vl$return_foot ( msg     = msg,
                                       objId   = &feet_list[MACRO_TM_FFEET+i],
				       objEnv  = md_env,
                                       name    = NAM_TO_LP3D,
                                       footId  = &lp3d[i] );
                as$status ( sts    = sts,
                            msg    = "vl$return_foot(LP3D)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
	}

	if (arg.prj == PROJECT_ON) {

#ifdef TRACE_MEMORY
printf( "om$calloc (%d,<struct VLsortTpl>)\n", I);
#endif
		Sort = om$calloc ( num = I, structure = struct VLsortTpl );

#ifdef TRACE_MEMORY
printf( "om$calloc (%d,<struct GRid>)\n", I);
#endif
		Feet = om$calloc ( num = I, structure = struct GRid );

		/* Store template objects useful data */
		for ( i=0; i<I; i++) {

			/* Store feet ID */
			Feet[i] = feet_list[MACRO_TM_FFEET+i];

			/* Store index */
			Sort[i].idx = i;

			/* Retrieve Y range */
			sts = vl$return_foot ( msg     = msg,
					       name    = NAM_TO_YRNG,
					       objId   = &Feet[i],
					       footId  = &foot );
        		as$status ( sts    = sts,
                    	    	    msg    = "vl$return_foot(YRNG)",
                    	    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			/* Store Y range */
			sts = om$send ( msg = message expression.NDgive_value
							(&Sort[i].y),
					targetid = foot.objid,
					targetos = foot.osnum );
        		as$status ( sts    = sts,
                    	    	    msg    = "expression.NDgive_value(YRNG)",
                    	    	    test   = (!(sts & 0x00000001)),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );
		}

		/* Sort template objects by decreasing Y range */
		qsort ( Sort, I, sizeof(struct  VLsortTpl), 
						(int (*)())VLsortRang );

		/* Put sorting result in feet_list array */
		for ( i=0; i<I; i++)
			feet_list[MACRO_TM_FFEET+i] = Feet[Sort[i].idx];

		/* Recompute ranges */
		Rp_numo = Rp_numi;
		Rw_maxo = Rw_maxi;
		arg.xpl = Rx_rngi;
		arg.ypl = Ry_rngi + (page_h / 1000);

		for ( i=MACRO_TM_FFEET; i<MACRO_TM_FFEET+I; i++) {

			/* Prepare xform matrix */
			for ( j=0; j<16; j++)	PRJmat[j] = 0.0;
			PRJmat[0] = PRJmat[5] = PRJmat[10] = PRJmat[15] = 1.0;
			PRJmat[3] = arg.xpl;
			PRJmat[7] = arg.ypl;
			MAtypemx ( msg, PRJmat, &type);

			/* Apply GRxform */
			sts = om$send ( msg = message GRgraphics.GRxform
							( msg,
							  md_env,
							  &type,
							  PRJmat,
							  &feet_list[i].objid ),
					targetid = feet_list[i].objid,
					targetos = feet_list[i].osnum );
       			as$status ( sts    = sts,
                	    	    msg    = "GRgraphics.GRxform",
	                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			/* Update X & Y ranges */
			sts = VLupdateXyRange ( &feet_list[i], md_env, 
						page_h, page_w,
						&Rp_numo, &Rw_maxo,
					     	&arg.xpl, &arg.ypl,
						msg );
       			as$status ( sts    = sts,
               	    	    	    msg    = "VLupdateXyRange(REGULAR)",
                    	    	    test   = (!(sts&0x00000001&(*msg))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );
		}

		/* Set the rib coordinate system */
		Tbox[IDX_TB_CSYS] = list[IDX_TM_R_CS];

		/* Build parameter box for orthogonal box(es) manager */
		Tbox[IDX_TB_ATTR].objid = NULL_OBJID;
		Tbox[IDX_TB_ATTR].osnum = md_env->md_id.osnum;
		om$construct ( classid = OPP_ACrg_collect_class_id,
			       osnum   = Tbox[IDX_TB_ATTR].osnum,
			       p_objid = &Tbox[IDX_TB_ATTR].objid );
		mbox[IDX_TB_PGH].desc.value.att_exp = page_h;
		mbox[IDX_TB_PGW].desc.value.att_exp = page_w;
		mbox[IDX_TB_PGF].desc.value.att_exp = (IGRdouble) Rp_numi;
		mbox[IDX_TB_PGT].desc.value.att_exp = (IGRdouble) Rp_numo;
		if (arg.ful == -1)
			mbox[IDX_TB_PGT].desc.value.att_exp += 1.0;
		sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
					( msg, NUM_TB_ATTR, mbox),
				targetid = Tbox[IDX_TB_ATTR].objid,
				targetos = Tbox[IDX_TB_ATTR].osnum);
		as$status ( sts    = sts,
			    msg    = "ACrg_collect.ACset_list_attribute",
			    test   = (!(sts&0x00000001&(*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		sts = vl$placeLoftMacro ( msg      = msg,
					  classid  = OPP_VLtplBox_class_id,
					  MacName  = MACRO_TB_DEF,
					  number   = MACRO_TB_TEMP,
					  template = Tbox,
					  Env      = md_env,
					  ChgState = FALSE,
					  occ_id   = &TmpId );
	       	as$status ( sts    = sts,
	              	    msg    = "vl$placeLoftMacro(RIB BOX)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		if (TmpId.objid != NULL_OBJID) {
			sts = om$send ( msg = message NDnode.NDmove_to_root
				( msg, &feet_list[IDX_TM_RBOX], md_env ),
					targetid = TmpId.objid,
					targetos = TmpId.osnum );
       			as$status ( sts    = sts,
	               	    	    msg    = "NDnode.NDmove_to_root(RIB BOX)",
	                    	    test   = (!(sts & 0x00000001 & (*msg))),
	                    	    action = GOTO_VALUE,
	                   	    value  = wrapup );
		}
	}

	if (  (spi_idx == PROJECT_ON)
	   && (feet_list[IDX_TM_TSPI].objid != NULL_OBJID) ) {

		/* Recompute ranges */
		Bp_numo = Bp_numi;
		Bw_maxo = Bw_maxi;
		Bx_rngo = Bx_rngi;
		By_rngo = By_rngi + (page_h / 1000);

		/* Prepare xform matrix */
		for ( j=0; j<16; j++)	PRJmat[j] = 0.0;
		PRJmat[0] = PRJmat[5] = PRJmat[10] = PRJmat[15] = 1.0;
		PRJmat[3] = Bx_rngo;
		PRJmat[7] = By_rngo;
		MAtypemx ( msg, PRJmat, &type);

		/* Apply GRxform */
		sts = om$send ( msg = message GRgraphics.GRxform
					( msg,
					  md_env,
					  &type,
					  PRJmat,
					  &feet_list[IDX_TM_TSPI].objid ),
				targetid = feet_list[IDX_TM_TSPI].objid,
				targetos = feet_list[IDX_TM_TSPI].osnum );
       		as$status ( sts    = sts,
               	    	    msg    = "GRgraphics.GRxform",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		/* Update X & Y ranges */
		sts = VLupdateXyRange ( &feet_list[IDX_TM_TSPI], md_env,
					page_h, page_w, &Bp_numo, &Bw_maxo,
				     	&Bx_rngo, &By_rngo, msg );
       		as$status ( sts    = sts,
               	    	    msg    = "VLupdateXyRange(SPINE)",
                    	    test   = (!(sts&0x00000001&(*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		/* Set the spine coordinate system */
		Tbox[IDX_TB_CSYS] = list[IDX_TM_B_CS];

		/* Build parameter box for orthogonal box(es) manager */
		Tbox[IDX_TB_ATTR].objid = NULL_OBJID;
		Tbox[IDX_TB_ATTR].osnum = md_env->md_id.osnum;
		om$construct ( classid = OPP_ACrg_collect_class_id,
			       osnum   = Tbox[IDX_TB_ATTR].osnum,
			       p_objid = &Tbox[IDX_TB_ATTR].objid );
		mbox[IDX_TB_PGH].desc.value.att_exp = page_h;
		mbox[IDX_TB_PGW].desc.value.att_exp = page_w;
		mbox[IDX_TB_PGF].desc.value.att_exp = (IGRdouble) Bp_numi;
		mbox[IDX_TB_PGT].desc.value.att_exp = (IGRdouble) Bp_numo;
		if (arg.ful == -1)
			mbox[IDX_TB_PGT].desc.value.att_exp += 1.0;
		sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
					( msg, NUM_TB_ATTR, mbox),
				targetid = Tbox[IDX_TB_ATTR].objid,
				targetos = Tbox[IDX_TB_ATTR].osnum);
		as$status ( sts    = sts,
			    msg    = "ACrg_collect.ACset_list_attribute",
			    test   = (!(sts&0x00000001&(*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		sts = vl$placeLoftMacro ( msg      = msg,
					  classid  = OPP_VLtplBox_class_id,
					  MacName  = MACRO_TB_DEF,
					  number   = MACRO_TB_TEMP,
					  template = Tbox,
					  Env      = md_env,
					  ChgState = FALSE,
					  occ_id   = &TmpId );
	       	as$status ( sts    = sts,
	              	    msg    = "vl$placeLoftMacro(SPINE BOX)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		if (TmpId.objid != NULL_OBJID) {
			sts = om$send ( msg = message NDnode.NDmove_to_root
				( msg, &feet_list[IDX_TM_SBOX], md_env ),
					targetid = TmpId.objid,
					targetos = TmpId.osnum );
       			as$status ( sts    = sts,
	               	    	    msg    = "NDnode.NDmove_to_root(SPINE BOX)",
	                    	    test   = (!(sts & 0x00000001 & (*msg))),
	                    	    action = GOTO_VALUE,
	                   	    value  = wrapup );
		}
	}


	/* Create Page Number expressions */
	sts = exp$create ( exp_value = (IGRdouble) Rp_numo,
                           p_exp_id  = &feet_list[IDX_TM_RPNO].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_RPNO].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(RPNO)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = exp$create ( exp_value = (IGRdouble) Bp_numo,
                           p_exp_id  = &feet_list[IDX_TM_BPNO].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_BPNO].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(BPNO)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create Width Max expressions */
	sts = exp$create ( exp_value = Rw_maxo,
                           p_exp_id  = &feet_list[IDX_TM_RWMO].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_RWMO].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(RWMO)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = exp$create ( exp_value = Bw_maxo,
                           p_exp_id  = &feet_list[IDX_TM_BWMO].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_BWMO].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(BWMO)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create X place expressions */
	sts = exp$create ( exp_value = arg.xpl,
                           p_exp_id  = &feet_list[IDX_TM_RXRO].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_RXRO].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(RXRO)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = exp$create ( exp_value = Bx_rngo,
                           p_exp_id  = &feet_list[IDX_TM_BXRO].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_BXRO].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(BXRO)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create Y place expressions */
	sts = exp$create ( exp_value = arg.ypl,
                           p_exp_id  = &feet_list[IDX_TM_RYRO].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_RYRO].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(RYRO)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = exp$create ( exp_value = By_rngo,
                           p_exp_id  = &feet_list[IDX_TM_BYRO].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_TM_BYRO].osnum );
        as$status ( sts    = sts,
                    msg    = "exp$create(BYRO)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );
wrapup:
	/* Delete 3D lp line */
	if (lp3d) {

		for ( i=0; i<I; i++) {
			if (lp3d[i].objid != NULL_OBJID) {
/*
				sts = gr$delete_object ( msg       = msg,
                                           	 	 md_env    = md_env,
                                           	 	 object_id = &lp3d[i] );
	                	as$status ( sts    = sts,
	                            	    msg    = "gr$delete_object()",
	                            	    test   = (!(sts & 0x00000001)),
	                            	    action = GOTO_VALUE,
	                            	    value  = wrapup );
*/
				lp3d[i].objid = NULL_OBJID;
			}
		}

		om$dealloc (ptr = lp3d);	lp3d = NULL;
	}

	/* Delete all feet if no intersection SMframe|VSplate
	   This will cause the VLtplMgr to be deleted.
	*/
	if (ref == -1) {
		for ( i=0; i<*fcount; i++) {
			if (feet_list[i].objid != NULL_OBJID) {
				sts = gr$delete_object (
						msg       = msg,
                                           	md_env    = md_env,
                                           	object_id = &feet_list[i] );
	                	as$status ( sts    = sts,
	                            	    msg    = "gr$delete_object()",
	                            	    test   = (!(sts & 0x00000001)),
	                            	    action = GOTO_VALUE,
	                            	    value  = wrapup );
				feet_list[i].objid = NULL_OBJID;
			}
		}
		*fcount = 0;
		ex$message (msgnumb = VL_E_NULL_FRAME_PLATE_INTER);
	}

	if (Feet) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Feet)\n");
#endif
		om$dealloc(ptr = Feet);
		Feet = NULL;
	}

	if (Sort) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Sort)\n");
#endif
		om$dealloc(ptr = Sort);
		Sort = NULL;
	}
#ifdef TRACE
printf( "\n");
for ( i=0; i<count; i++) {
	om$get_classname ( osnum     = list[i].osnum,
                           objid     = list[i].objid,
                           classname = side );
	printf( "VLtplMgr : template %2d is (%d|%d)\t<%s>\n",
		i, list[i].osnum, list[i].objid, side );
}
printf( "\n");
for ( i=0; i<*fcount; i++) {
	om$get_classname ( osnum     = feet_list[i].osnum,
                           objid     = feet_list[i].objid,
                           classname = side );
	printf( "\tVLtplMgr : foot %2d is (%d|%d)\t<%s>\n",
		i, feet_list[i].osnum, feet_list[i].objid, side );
}
printf( "\n");
printf("\t<<< Exit from VLtplMgri.ACconstruct_feet\n");
#endif

	return(sts);
}
/* ========================================================================== */

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjPlateTempMgr;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/


end implementation VLtplMgr;
