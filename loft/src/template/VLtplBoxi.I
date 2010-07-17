class implementation VLtplBox;

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

#include	"vlmiscmacros.h"
#include	"vltemplate.h"

from	ACrg_collect	import	ACget_named_attribute;

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
	IGRlong		sts;
struct	ACrg_coll	attr;
	IGRdouble	hei=0.0, wid=0.0;
	IGRint		i, frP=0, toP=0;
struct	GRobj_env	Cs;
struct	GRvg_construct	cst;

	/* Initialize */
	*fcount = 0;
	Cs.obj_id  = list[IDX_TB_CSYS];
	Cs.mod_env = *md_env;
	VLinitCnst (&cst);
	cst.env_info = md_env;

	/* Retrieve page height */
	strcpy ( attr.name, NAM_TB_PGH);
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
						( msg, &attr),
			targetid = list[IDX_TB_ATTR].objid,
			targetos = list[IDX_TB_ATTR].osnum);
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(HEIGHT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (attr.desc.type == AC_ATTRIB_DOUBLE)
		hei = attr.desc.value.att_exp;
	else {	printf( "<%s> parameter is not a double\n", NAM_TB_PGH);
		*msg = MSFAIL;	}

	/* Retrieve page width */
	strcpy ( attr.name, NAM_TB_PGW);
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
						( msg, &attr),
			targetid = list[IDX_TB_ATTR].objid,
			targetos = list[IDX_TB_ATTR].osnum);
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(WIDTH)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (attr.desc.type == AC_ATTRIB_DOUBLE)
		wid = attr.desc.value.att_exp;
	else {	printf( "<%s> parameter is not a double\n", NAM_TB_PGW);
		*msg = MSFAIL;	}

	/* Retrieve from page number */
	strcpy ( attr.name, NAM_TB_PGF);
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
						( msg, &attr),
			targetid = list[IDX_TB_ATTR].objid,
			targetos = list[IDX_TB_ATTR].osnum);
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(FROM PAGE)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (attr.desc.type == AC_ATTRIB_DOUBLE)
		frP = (IGRint) attr.desc.value.att_exp;
	else {	printf( "<%s> parameter is not a double\n", NAM_TB_PGF);
		*msg = MSFAIL;	}

	/* Retrieve to page number */
	strcpy ( attr.name, NAM_TB_PGT);
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
						( msg, &attr),
			targetid = list[IDX_TB_ATTR].objid,
			targetos = list[IDX_TB_ATTR].osnum);
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute(FROM PAGE)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (attr.desc.type == AC_ATTRIB_DOUBLE)
		toP = (IGRint) attr.desc.value.att_exp;
	else {	printf( "<%s> parameter is not a double\n", NAM_TB_PGT);
		*msg = MSFAIL;	}

	/* Check values */
#ifdef TRACE
printf( "VLtplBox.ACconstruct_feet : from=%d\tto=%d\n", frP, toP);
#endif
	if ( (hei <= 0.0) || (wid <= 0.0) || (frP < 0) || (toP <= frP) )
		goto wrapup;

	/* Create orthogonal boxes */
	for ( i=frP; i<toP; i++) {
		feet_list[*fcount].objid = NULL_OBJID;
		feet_list[*fcount].osnum = md_env->md_id.osnum;
		sts = VLdrawFrame ( &Cs, &cst, hei, wid, i,
				    &feet_list[*fcount], msg );
		as$status ( sts    = sts,
	                    msg    = "VLdrawFrame()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		(*fcount)++;
	}

wrapup:
	return(sts);
}
/* ========================================================================== */

end implementation VLtplBox;
