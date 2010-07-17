class implementation VLabstract;

/*
	Marc FOURNIER (COC Shipbuilding, Paris)		23-Mar-1995

	This file contains functions called by the vl$macros() defined in
	<vlforkmacros.h> include file.

	The prototype include file <vlPjunction.h> generated from this file
	isn't included in the generic <vlprototype.h> include file because
	the functions defined are only called by <vlforkmacros.h> that
	includes <vlPjunction.h>.
*/

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"grdpbmacros.h"
#include	"grmacros.h"
#include	"asmacros.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"expression.h"
#include	"expmacros.h"

#include	"vlmiscmacros.h"
#include	"vljunction.h"

extern	GRclassid	OPP_ACrg_collect_class_id;
extern	GRclassid	OPP_VLjunction_class_id;

from	ACrg_collect	import	ACset_list_attribute;
from	VLjunction	import	ACget_named_attribute, VLreturn_graphic;

/* ========================================================================== */
IGRint	VLcreateLoftJunction (		IGRlong		*msg,
				struct	GRobj_env	*graphic,
				struct	GRobj_env	*collect,
				struct	ACrg_coll	*attr,
					IGRint		number,
				struct	GRobj_env	*measure,
				struct	GRmd_env	*Env,
				struct	GRid		*occ_id		)
{
	IGRint		i, sts=OM_S_SUCCESS;
	IGRlong		siz, ret;
struct	GRmd_env	loc_env;
struct	GRid		template[MACRO_JU_TEMP], col_id, loc_id;

	/* Initialize */
	*msg = MSFAIL;
	if (!Env)	gr$get_module_env ( msg    = msg,
                                            sizbuf = &siz,
                                            buffer = &loc_env,
                                            nret   = &ret );
        else            loc_env = *Env;
	if (occ_id) {	occ_id->objid = NULL_OBJID;
			occ_id->osnum = loc_env.md_id.osnum;	}
	for ( i=0; i<MACRO_JU_TEMP; i++ ) {
		template[i].objid = NULL_OBJID;
		template[i].osnum = loc_env.md_id.osnum;
	}

	/* Set <graphic> template in array */
	as$make_source ( go_grid = graphic->obj_id,
			 mod_env = &graphic->mod_env,
			 as_grid = &template[IDX_JU_GRA] );

	/* Create <collect> template (if needed) */
	if ( (!collect) || (collect->obj_id.objid == NULL_OBJID) ) {

		*msg = MSFAIL;
		if ((!attr) || (!number))	goto wrapup;

		/* Construct collection object */
		col_id.objid = NULL_OBJID;
		col_id.osnum = loc_env.md_id.osnum;
		om$construct ( classid = OPP_ACrg_collect_class_id,
			       osnum   = col_id.osnum,
			       p_objid = &col_id.objid );

		/* Set value in collection object */
		sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
					( msg, number, attr),
				senderid = NULL_OBJID,
				targetid = col_id.objid,
				targetos = col_id.osnum );
	        as$status ( sts    = sts,
			    msg    = "ACrg_collect.ACset_list_attribute",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Set <collect> template in array */
		as$make_source ( go_grid = col_id,
				 mod_env = &loc_env,
				 as_grid = &template[IDX_JU_COL] );

		/* Set output id (if needed) */
		if (collect) {	collect->obj_id  = template[IDX_JU_COL];
				collect->mod_env = loc_env;	}
		
	}
	else {	/* Set <collect> template in array */
		as$make_source ( go_grid = collect->obj_id,
				 mod_env = &collect->mod_env,
				 as_grid = &template[IDX_JU_COL] );
	}

	/* Create <measure> template (if needed) */
	if ( (!measure) || (measure->obj_id.objid == NULL_OBJID) ) {

		/* Create a expression */
		sts = exp$create ( exp_syntax = "measure",
                                   p_exp_id   = &template[IDX_JU_MEA].objid,
                                   osnum      = loc_env.md_id.osnum,
                                   p_osnum    = &template[IDX_JU_MEA].osnum,
                                   type_rq    = EXP_TEXT );
                if (sts != EXP_S_SUCCESS)    goto wrapup;
	}
	else {	/* Set <measure> template in array */
		as$make_source ( go_grid = measure->obj_id,
				 mod_env = &measure->mod_env,
				 as_grid = &template[IDX_JU_MEA] );
	}

	/* Place VLjunction macro */
	loc_id.objid = NULL_OBJID;
	loc_id.osnum = loc_env.md_id.osnum;
        sts = vl$placeLoftMacro ( msg        = msg,
                                  classid    = OPP_VLjunction_class_id,
                                  MacName    = MACRO_JU_DEF,
                                  number     = MACRO_JU_TEMP,
                                  template   = template,
                                  Env        = &loc_env,
				  dpmode     = GRbe,
                                  ChgState   = FALSE,
                                  occ_id     = &loc_id );
        as$status ( sts    = sts,
		    msg    = "vl$placeLoftMacro(VLjunction)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Move to root VLjunction macro */
        sts = om$send ( msg = message NDnode.NDmove_to_root
						( msg, &loc_id, &loc_env),
			senderid = NULL_OBJID,
                        targetid = loc_id.objid,
                        targetos = loc_id.osnum );
        as$status ( sts    = sts,
		    msg    = "NDnode.NDmove_to_root",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* If VLjunction object id wanted */
	if (occ_id)	*occ_id = loc_id;

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint	VLgetLoftJunctionGeom (		IGRlong		*msg,
				struct	GRid		*objId,
				struct	GRmd_env	*objEnv,
				struct	GRid		*footId,
				struct	GRmd_env	*footEnv,
					IGRint		option,
					OM_S_OBJID	MyStupidId,
					IGRchar		**Geometry	)
{
	IGRint		sts=OM_S_SUCCESS;
struct	GRobj_env	Foot;

	/* Initialize */
	Foot.obj_id.objid = NULL_OBJID;

	/* Get <graphic> foot */
	sts = om$send ( msg = message VLjunction.VLreturn_graphic
					( msg, objEnv, &Foot),
			senderid = NULL_OBJID,
			targetid = objId->objid,
			targetos = objId->osnum );
        as$status ( sts    = sts,
		    msg    = "VLjunction.VLreturn_graphic)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Exit if no geometry wanted */
	if (!Geometry)	goto wrapup;

	/* Get geometry */
	switch (option) {

		case 0:
		case 1:	sts = VLgetGeometry ( &Foot, (IGRboolean) option,
					      MyStupidId, Geometry, msg );
		        as$status ( sts    = sts,
				    msg    = "VLgetGeometry()",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
			break;

		case 2:	sts = VLgetExGeometry ( &Foot, MyStupidId,
						Geometry, msg );
		        as$status ( sts    = sts,
				    msg    = "VLgetExGeometry()",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
			break;

		default:	*msg = MSFAIL;
printf( "VLgetLoftJunctionGeom() : unknown <option> = %d\n", option);
	}

wrapup:
	if (footId)	*footId  = Foot.obj_id;
	if (footEnv)	*footEnv = Foot.mod_env;
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint	VLgetLoftJunctionAttr (		IGRlong		*msg,
				struct	GRid		*objId,
					IGRchar		*name,
					IGRdouble	*value,
					IGRchar		*text	)
{
	IGRint		sts=OM_S_SUCCESS;
struct	ACrg_coll	attr;

	/* Initialize */
	if (value)	*value = 0.0;
	if (text)	text[0] = '\0';

	/* Exit if no other output wanted */
	if ( (!name) || ( (!value) && (!text) ) )	goto wrapup;

	/* Get named attribute */
	strcpy ( attr.name, name);
	sts = om$send ( msg = message VLjunction.ACget_named_attribute
					( msg, &attr),
			senderid = NULL_OBJID,
			targetid = objId->objid,
			targetos = objId->osnum );
        as$status ( sts    = sts,
		    msg    = "VLjunction.ACget_named_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if	( (attr.desc.type == AC_ATTRIB_DOUBLE) && (value) )
		*value = attr.desc.value.att_exp;
	else if ( (attr.desc.type == AC_ATTRIB_TEXT) && (text) )
		strcpy ( text, attr.desc.value.att_txt);
	else {	printf( "No attribute returned\n");
		*msg = MSFAIL;	}

wrapup:
	return (sts);
}
/* ========================================================================== */

end implementation VLabstract;
