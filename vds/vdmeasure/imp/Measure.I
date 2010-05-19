/* $Id: Measure.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdmeasure/imp/Measure.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: Measure.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.4  1997/01/07  13:51:30  pinnacle
# Replaced: vdmeasure/imp/Measure.I for:  by v241_int for vds.241
#
# Revision 1.3  1996/11/16  15:53:42  pinnacle
# Replaced: vdmeasure/imp/Measure.I for:  by v241_int for vds.241
#
# Revision 1.2  1996/11/11  18:29:32  pinnacle
# Replaced: vdmeasure/imp/Measure.I for:  by v241_int for vds.241
#
# Revision 1.1  1996/11/08  21:50:48  pinnacle
# Created: vdmeasure/imp/Measure.I by v241_int for vds.241
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/08/96        mf              creation date.
 *	11/16/96	mf		first revision.
 *	01/07/97	mf		small corrections.
 ***************************************************************************/

class implementation Root;

#include        <stdio.h>
#include        <string.h>
#include        "OMminimum.h"
#include        "OMerrordef.h"
#include        "OMprimitives.h"
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "msdef.h"
#include        "AS_status.h"
#include        "DIdef.h"
#include        "gr.h"
#include        "igrdp.h"
#include        "go.h"
#include        "growner.h"
#include        "exdef.h"
#include        "ex.h"
#include        "griodef.h"
#include        "grio.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "asmacros.h"
#include        "grmacros.h"
#include        "macro.h"
#include        "EMSmsdismac.h"
#include        "dpstruct.h"

#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"

#include	"vdAPImacros.h"
#include	"vdAPIequips.h"
#include	"v_miscmacros.h"
#include	"vdmeasure.h"
#include	"vdmeaprotos.h"

from	EMSplane	import	EMplane;
from	GRcurve		import	GRarclength, GRendpts;
from	GRgraphics	import	GRaltconstruct, GRptproject;
from	GRvg		import	GRdetplane;

extern	GRclassid	OPP_EMSplane_class_id,
			OPP_GR3dlineseg_class_id,
			OPP_GR3dpoint_class_id;

/* ************************************************************************** */
IGRlong	VDminimumDistance (		IGRlong		*msg,
				struct	VDmeasure	*Meas	)
{
	IGRlong		sts=OM_S_SUCCESS;
struct	GRevent		Loc[2];

	/* Initialize */
	*msg = MSSUCC;

	/* Fill 1st event structure */
	Loc[0].event.button.x		= Meas->Ipnt[0];
	Loc[0].event.button.y		= Meas->Ipnt[1];
	Loc[0].event.button.z		= Meas->Ipnt[2];
	Loc[0].event.button.osnum	= Meas->Iwin[0].osnum;
	Loc[0].event.button.objid	= Meas->Iwin[0].objid;

	/* Fill 2nd event structure */
	Loc[1].event.button.x		= Meas->Ipnt[3];
	Loc[1].event.button.y		= Meas->Ipnt[4];
	Loc[1].event.button.z		= Meas->Ipnt[5];
	Loc[1].event.button.osnum	= Meas->Iwin[1].osnum;
	Loc[1].event.button.objid	= Meas->Iwin[1].objid;

	/* Call measure macro */
	sts = ems$meas_mindis_bet_2_eli ( msg	      = msg,
					  first_grid  = Meas->Iobj[0].obj_id,
					  second_grid = Meas->Iobj[1].obj_id,
					  mod_env1    = &Meas->Iobj[0].mod_env,
					  mod_env2    = &Meas->Iobj[1].mod_env,
					  event1      = &Loc[0],
					  event2      = &Loc[1],
					  point1      = &Meas->Opnt[0],
					  point2      = &Meas->Opnt[3],
					  mindist     = &Meas->Odst	);
        as$status ( sts    = sts,
                    msg    = "ems$meas_mindis_bet_2_eli()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDfillPlaneObject (		IGRlong		*msg,
				struct	GRobj_env	*Obj1,
				struct	GRobj_env	*Obj2,
				struct	VDcollector	*Tpl	)
{
	IGRlong		sts=OM_S_SUCCESS;

	/* Set template 0 : <surface> */
	sts = vd$collectorSetRow ( msg	= msg,
				   idx	= 0,
				   Col	= Tpl,
				   Obj	= &Obj1->obj_id,
				   Env	= &Obj1->mod_env );
        as$status ( sts    = sts,
                    msg    = "vd$collectorSetRow(surface)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set template 1 : <plane> */
	sts = vd$collectorSetRow ( msg	= msg,
				   idx	= 1,
				   Col	= Tpl,
				   Obj	= &Obj2->obj_id,
				   Env	= &Obj2->mod_env );
        as$status ( sts    = sts,
                    msg    = "vd$collectorSetRow(plane)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDinterPlanObjects (		IGRlong		*msg,
					IGRint		num,
				struct	GRobj_env	Obj[],
				struct	GRobj_env	*Pln,
				struct	GRobj_env	Mac[]	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i, cnt=0;
struct	VDcollector	*Tpl;

	/* Initialize */
	Tpl = NULL;

	/* Get <int_sf_pl> collector */
	sts = vd$getMacDefCollector ( msg	= msg,
				      MacLib	= "PPMmacro",
				      MacDef	= "int_sf_pl",
				      TplNum	= &cnt,
				      TplCol	= &Tpl );
        as$status ( sts    = sts,
                    msg    = "vd$getMacDefCollector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Loop on objects */
	for ( i=0; i<num; i++ ) {

		/* Fill collector */
		sts = VDfillPlaneObject ( msg, &Obj[i], Pln, Tpl );
        	as$status ( sts    = sts,
	                    msg    = "VDfillPlaneObject()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Place <int_sf_pl> occurence */
		sts = VDplaceMacroOrEquip ( msg,
					    "PPMmacro", "int_sf_pl",
					    NULL, NULL, NULL,
					    cnt, Tpl,
					    0, NULL, VD_OCC_CONS, NULL,
					    VD_LAY_DEF,
					    VD_COL_DEF,
					    VD_WEI_DEF,
					    VD_STY_DEF,
					    VD_ONE_NOT,
					    VD_ALL_NOT,
					    NULL, "",
					    AChdr_nodisplay | AChdr_norange,
					    &Mac[i].obj_id );
	        as$status ( sts    = sts,
	                    msg    = "VDplaceMacroOrEquip(<int_sf_pl>)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

wrapup:
	vd$collectorFree (Col = Tpl);
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDfillSuppObject (		IGRlong		*msg,
				struct	GRobj_env	*Obj1,
				struct	GRobj_env	*Obj2,
				struct	VDcollector	*Tpl	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRdouble	val;

	/* Set template 0 : <element1> */
	sts = vd$collectorSetRow ( msg	= msg,
				   idx	= 0,
				   Col	= Tpl,
				   Obj	= &Obj1->obj_id,
				   Env	= &Obj1->mod_env );
        as$status ( sts    = sts,
                    msg    = "vd$collectorSetRow(element1)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set template 1 : <element2> */
	sts = vd$collectorSetRow ( msg	= msg,
				   idx	= 1,
				   Col	= Tpl,
				   Obj	= &Obj2->obj_id,
				   Env	= &Obj2->mod_env );
        as$status ( sts    = sts,
                    msg    = "vd$collectorSetRow(element2)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set template 2 : <trim1> */
	val = 1.0;
	sts = vd$collectorSetRow ( msg	= msg,
				   idx	= 2,
				   Col	= Tpl,
				   Val	= &val );
        as$status ( sts    = sts,
                    msg    = "vd$collectorSetRow(trim1)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set template 3 : <trim2> */
	val = 1.0;
	sts = vd$collectorSetRow ( msg	= msg,
				   idx	= 3,
				   Col	= Tpl,
				   Val	= &val );
        as$status ( sts    = sts,
                    msg    = "vd$collectorSetRow(trim2)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set template 4 : <approx> */
	val = 0.0;
	sts = vd$collectorSetRow ( msg	= msg,
				   idx	= 4,
				   Col	= Tpl,
				   Val	= &val );
        as$status ( sts    = sts,
                    msg    = "vd$collectorSetRow(approx)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDinterSuppObjects (		IGRlong		*msg,
					IGRint		num,
				struct	GRobj_env	Obj[],
				struct	GRobj_env	*Sup,
				struct	GRobj_env	Mac[]	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i, cnt=0;
struct	VDcollector	*Tpl;

	/* Initialize */
	Tpl = NULL;

	/* Get <int_2_elem> collector */
	sts = vd$getMacDefCollector ( msg	= msg,
				      MacLib	= "PPMmacro",
				      MacDef	= "int_2_elem",
				      TplNum	= &cnt,
				      TplCol	= &Tpl );
        as$status ( sts    = sts,
                    msg    = "vd$getMacDefCollector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Loop on objects */
	for ( i=0; i<num; i++ ) {

		/* Fill collector */
		sts = VDfillSuppObject ( msg, &Obj[i], Sup, Tpl );
        	as$status ( sts    = sts,
	                    msg    = "VDfillSuppObject()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Place <int_2_elem> macro */
		sts = VDplaceMacroOrEquip ( msg,
					    "PPMmacro", "int_2_elem",
					    NULL, NULL, NULL,
					    cnt, Tpl,
					    0, NULL, VD_OCC_CONS, NULL,
					    VD_LAY_DEF,
					    VD_COL_DEF,
					    VD_WEI_DEF,
					    VD_STY_DEF,
					    VD_ONE_NOT,
					    VD_ALL_NOT,
					    NULL, "",
					    AChdr_nodisplay | AChdr_norange,
					    &Mac[i].obj_id );
	        as$status ( sts    = sts,
	                    msg    = "VDplaceMacroOrEquip(<int_2_elem>)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

wrapup:
	vd$collectorFree (Col = Tpl);
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetIntersections (		IGRlong		*msg,
					IGRint		num,
				struct	GRobj_env	Mac[],
				struct	GRobj_env	Int[]	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;

	/* Loop on macros */
	for ( i=0; i<num; i++ ) {
		sts = vd_$return_foot ( msg	= msg,
					name	= "resi0",
					objId	= &Mac[i].obj_id,
					objEnv	= &Mac[i].mod_env,
					footId	= &Int[i].obj_id,
					footEnv	= &Int[i].mod_env );
	        as$status ( sts    = sts,
	                    msg    = "vd_$return_foot()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDprojectPoints (		IGRlong		*msg,
					IGRdouble	*Pnt1,
					IGRdouble	*Pnt2,
				struct	GRobj_env	*Srf,
					IGRdouble	*Prj1,
					IGRdouble	*Prj2	)
{
	IGRlong		sts=OM_S_SUCCESS;
struct	GRparms		parm;
	IGRint		i;

	/* Project 1st point */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Srf->mod_env.md_env.matrix_type,
					Srf->mod_env.md_env.matrix,
					Pnt1,
					Prj1,
					&parm ),
			senderid = NULL_OBJID,
			targetid = Srf->obj_id.objid,
			targetos = Srf->obj_id.osnum );
	if (!(sts & 0x00000001 & (*msg))) {
		for ( i=0; i<3; i++ )	Prj1[i] = Pnt1[i];
	}

	/* Project 2nd point */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Srf->mod_env.md_env.matrix_type,
					Srf->mod_env.md_env.matrix,
					Pnt2,
					Prj2,
					&parm ),
			senderid = NULL_OBJID,
			targetid = Srf->obj_id.objid,
			targetos = Srf->obj_id.osnum );
	if (!(sts & 0x00000001 & (*msg))) {
		for ( i=0; i<3; i++ )	Prj2[i] = Pnt2[i];
	}

	sts  = OM_S_SUCCESS;
	*msg = MSSUCC;

	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDorthoPlan (		IGRlong		*msg,
			struct	GRobj_env	*Srf,
				IGRdouble	*Spt,
				IGRdouble	*Ept,
			struct	GRobj_env	*Pln	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRdouble	Mpt[3], Prj[3], pts[9];
	IGRint		i, suc=1;
struct	GRparms		parm;
struct	GRsymbology	sym;
struct	GRvg_construct	cst;
struct	IGRplane	pln;
	IGRpoint	pnt;
	IGRvector	vec;
	IGRboolean	planar=FALSE;

	/* Build midpoint */
	for ( i=0; i<3; i++ )	Mpt[i] = (Spt[i] + Ept[i]) * 0.5;

	/* Determine planarity of surface */
	pln.point	= pnt;
	pln.normal	= vec;
	sts = om$send ( msg = message GRvg.GRdetplane (
					msg,
					&Srf->mod_env.md_env.matrix_type,
					Srf->mod_env.md_env.matrix,
					&pln ),
			senderid = NULL_OBJID,
			targetid = Srf->obj_id.objid,
			targetos = Srf->obj_id.osnum );
	if (sts & 0x00000001 & (*msg))
		planar	= TRUE;
	else {	sts	= OM_S_SUCCESS;
		*msg	= MSSUCC;
	}

	/* Project midpoint on surface */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Srf->mod_env.md_env.matrix_type,
					Srf->mod_env.md_env.matrix,
					Mpt,
					Prj,
					&parm ),
			senderid = NULL_OBJID,
			targetid = Srf->obj_id.objid,
			targetos = Srf->obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "GRgraphics.GRptproject",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create 3rd point (non-colinear with the two others) */
	if (planar == TRUE) {
		for ( i=0; i<3; i++ )	Prj[i] += pln.normal[i];
	}

	/* Store points */
	for ( i=0; i<3; i++ ) {
		pts[0+i] = Spt[i];
		pts[3+i] = Prj[i];
		pts[6+i] = Ept[i];
	}

	/* Get active symbology */
        ASget_active_symb ( &sym.level, &sym.display_attr );

	/* Fill construction list */
	vd_$fill_cnst_list ( Cnst_list  = cst,
                             Env_info   = &Pln->mod_env,
                             Level      = sym.level,
                             Display    = &sym.display_attr );

	/* Construct plane by 3 points */
	sts = om$construct ( classid = OPP_EMSplane_class_id,
                             osnum   = Pln->obj_id.osnum,
                             p_objid = &Pln->obj_id.objid );
	as$status ( sts    = sts,
                    msg    = "om$construct(EMSplane)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create plane by 3 points */
	sts = om$send ( msg = message EMSplane.EMplane
					( &suc, &cst, (IGRpoint *)pts, 3 ),
			senderid = NULL_OBJID,
			targetid = Pln->obj_id.objid,
			targetos = Pln->obj_id.osnum );
	*msg = suc;
	as$status ( sts    = sts,
                    msg    = "EMSplane.EMplane",
                    test   = (!(sts & 0x00000001 & (*(cst.msg)) & (*msg) )),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetCurveLength (		IGRlong		*msg,
				struct	GRobj_env	*Curv,
					IGRdouble	*Spnt,
					IGRdouble	*Epnt,
					IGRdouble	*Dist	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRdouble	sPnt[3], ePnt[3];
struct	GRparms		sPar, ePar;

	/* Initialize */
	*Dist = 0.0;

	/* Get start point parameter */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Curv->mod_env.md_env.matrix_type,
					Curv->mod_env.md_env.matrix,
					Spnt, sPnt, &sPar ),
			senderid = NULL_OBJID,
			targetid = Curv->obj_id.objid,
			targetos = Curv->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRgraphics.GRptproject",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get end point parameter */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Curv->mod_env.md_env.matrix_type,
					Curv->mod_env.md_env.matrix,
					Epnt, ePnt, &ePar ),
			senderid = NULL_OBJID,
			targetid = Curv->obj_id.objid,
			targetos = Curv->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRgraphics.GRptproject",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
					
	/* Evaluate curve length from start to end point */
	sts = om$send ( msg = message GRcurve.GRarclength (
					msg,
					&Curv->mod_env.md_env.matrix_type,
					Curv->mod_env.md_env.matrix,
					sPnt, sPnt, ePnt,
					&sPar, &sPar, &ePar,	
					Dist ),
			senderid = NULL_OBJID,
			targetid = Curv->obj_id.objid,
			targetos = Curv->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRcurve.GRarclength",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDfreeDistance (		IGRlong		*msg,
				struct	VDmeasure	*Meas	)
{
	IGRlong		sts=OM_S_SUCCESS;

	/* Delete curve */
	if (  (Meas->prop & VD_MEAS_CURV)
	   && (Meas->Ocrv.obj_id.objid != NULL_OBJID) ) {

		sts = gr$delete_object ( msg	     = msg,
					 md_env    = &Meas->Ocrv.mod_env,
					 object_id = &Meas->Ocrv.obj_id );
	        as$status ( sts    = sts,
	                    msg    = "gr$delete_object()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		Meas->Ocrv.obj_id.objid = NULL_OBJID;
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDmeasureLineCurve (		IGRlong		*msg,
				struct	VDmeasure	*Meas,
				struct	GRobj_env	*Curv	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		cnt=0;
struct	VDcollector	*Tpl;
struct	GRid		Spt, Ept, Mac;
struct	GRobj_env	Crv;
struct	GRsymbology	sym;
struct	GRvg_construct	cst;
struct	IGRpolyline	geo;

	/* Initialize */
	Tpl = NULL;
	Spt.objid = Ept.objid = Mac.objid = NULL_OBJID;
	Spt.osnum = Ept.osnum = Mac.osnum = Meas->Ocrv.mod_env.md_id.osnum;

	/* To construct out of the range tree */
	Meas->Ocrv.mod_env.md_id.objid = NULL_OBJID;

	/* Get active symbology */
       	ASget_active_symb ( &sym.level, &sym.display_attr );

	/* Fill construction list */
	vd_$fill_cnst_list ( Cnst_list  = cst,
                             Env_info   = &Meas->Ocrv.mod_env,
                             Level      = sym.level,
                             Display    = &sym.display_attr,
			     Geometry	= (IGRchar *) &geo );

	/* Is measure line|curve wanted ? */
	if (Meas->prop & VD_MEAS_CURV) {

		/* Curve case */
		if ( (Curv != NULL) && (Meas->prop & VD_MEAS_SUPP) ) {

			/* Get <crv_pdel> collector */
			sts = vd$getMacDefCollector ( msg      	= msg,
						      MacLib	= "PPMmacro",
						      MacDef	= "crv_pdel",
						      TplNum	= &cnt,
						      TplCol	= &Tpl );
		        as$status ( sts    = sts,
		                    msg    = "vd$getMacDefCollector(crv_pdel)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Fill geometry */
			geo.num_points	= 1;
			geo.points	= (IGRdouble *) &(Meas->Opnt)[0];

			/* Construct 1st point */
			sts = om$construct (
			classid = OPP_GR3dpoint_class_id,
			osnum   = Spt.osnum,
			p_objid = &Spt.objid,
			msg     =  message GRgraphics.GRaltconstruct ( &cst ) );
		        as$status ( sts    = sts,
		                    msg    = "om$construct(GR3dpoint)",
		                    test   = (!(sts & 0x00000001 & (*cst.msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Set <stpnt> */
			sts = vd$collectorSetRow ( msg  = msg,
						   idx  = 0,
						   Col  = Tpl,
						   Obj  = &Spt,
						   Env	= &Meas->Ocrv.mod_env );
		        as$status ( sts    = sts,
		                    msg    = "vd$collectorSetRow(stpnt)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Fill geometry */
			geo.num_points	= 1;
			geo.points	= (IGRdouble *) &(Meas->Opnt)[3];

			/* Construct 2nd point */
			sts = om$construct (
			classid = OPP_GR3dpoint_class_id,
			osnum   = Ept.osnum,
			p_objid = &Ept.objid,
			msg     =  message GRgraphics.GRaltconstruct ( &cst ) );
		        as$status ( sts    = sts,
		                    msg    = "om$construct(GR3dpoint)",
		                    test   = (!(sts & 0x00000001 & (*cst.msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Set <edpnt> */
			sts = vd$collectorSetRow ( msg  = msg,
						   idx  = 1,
						   Col  = Tpl,
						   Obj  = &Ept,
						   Env	= &Meas->Ocrv.mod_env );
		        as$status ( sts    = sts,
		                    msg    = "vd$collectorSetRow(edpnt)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Set <crv0> */
			sts = vd$collectorSetRow ( msg  = msg,
						   idx  = 2,
						   Col  = Tpl,
						   Obj  = &Curv->obj_id,
						   Env  = &Curv->mod_env );
		        as$status ( sts    = sts,
		                    msg    = "vd$collectorSetRow(crv0)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Place <crv_pdel> macro */
                	sts = VDplaceMacroOrEquip ( msg,
                                            	    "PPMmacro", "crv_pdel",
                                            	    NULL, NULL, NULL,
                                            	    cnt, Tpl,
                                            	    0, NULL, VD_OCC_CONS, NULL,
                                            	    VD_LAY_DEF,
                                            	    VD_COL_DEF,
                                            	    VD_WEI_DEF,
                                            	    VD_STY_DEF,
                                            	    VD_ONE_NOT,
                                            	    VD_ALL_NOT,
                                            	    NULL, "",
                                            	    AChdr_nodisplay
						    | AChdr_norange,
                                            	    &Mac );
		        as$status ( sts    = sts,
		                    msg    = "VDplaceMacroOrEquip(crv_pdel)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Get <curve> foot */
			sts = vd_$return_foot ( msg     = msg,
						name	= "curve",
						objId	= &Mac,
						objEnv	= &Meas->Ocrv.mod_env,
						footId	= &Crv.obj_id,
						footEnv = &Crv.mod_env );
		        as$status ( sts    = sts,
		                    msg    = "vd_$return_foot(curve)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Copy locally curve resulting from intersection */
			sts = gr$copy_object ( msg	 = msg,
					       object_id = &Crv.obj_id,
					       md_env	 = &Crv.mod_env,
					       new_env	 = &Meas->Ocrv.mod_env,
					       new_id	 = &Meas->Ocrv.obj_id,
					       display_flag = 0 );
		        as$status ( sts    = sts,
		                    msg    = "gr$copy_object()",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Display off curve */
			gr$display_object ( object_id = &Meas->Ocrv.obj_id,
					    md_env    = &Meas->Ocrv.mod_env,
					    mode      = GRbe );
		}

		/* Line case */
		else {	/* Fill geometry structure */
			geo.num_points	= 2;
			geo.points	= (IGRdouble *) Meas->Opnt;

			/* Construct line segment */
			sts = om$construct (
			classid = OPP_GR3dlineseg_class_id,
			osnum   = Meas->Ocrv.obj_id.osnum,
			p_objid = &Meas->Ocrv.obj_id.objid,
			msg     =  message GRgraphics.GRaltconstruct ( &cst ) );
		        as$status ( sts    = sts,
		                    msg    = "om$construct(GR3dlineseg)",
		                    test   = (!(sts & 0x00000001 & (*cst.msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
	}

wrapup:
	vd$collectorFree (Col = Tpl);
	if (Spt.objid != NULL_OBJID)
		gr$delete_object ( msg = msg, object_id = &Spt );
	if (Ept.objid != NULL_OBJID)
		gr$delete_object ( msg = msg, object_id = &Ept );
	if (Mac.objid != NULL_OBJID)
		gr$delete_object ( msg = msg, object_id = &Mac );
	return (sts);
}
/* ************************************************************************** */
		
/* ************************************************************************** */
IGRlong	VDcomputeDistance (		IGRlong		*msg,
				struct	VDmeasure	*Meas	)
{
	IGRlong		sts=OM_S_SUCCESS, loc;
	IGRint		i;
	IGRdouble	Prj1[3], Prj2[3];
struct	GRobj_env	Mac[4], Int[4];
	GRspacenum	ActiveOs;
struct	VDmeasure	measure;

	/* Initialize */
	*msg = MSFAIL;
	for ( i=0; i<3; i++ ) {
		Prj1[i] = 0.0;
		Prj2[i] = 0.0;
	}
	ActiveOs = Meas->Ocrv.mod_env.md_id.osnum;

	/* Set enviroment */
	for ( i=0; i<4; i++ ) {
		Mac[i].obj_id.objid	= NULL_OBJID;
		Mac[i].obj_id.osnum	= ActiveOs;
		Mac[i].mod_env		= Meas->Ocrv.mod_env;
		Int[i].obj_id.objid	= NULL_OBJID;
		Int[i].obj_id.osnum	= ActiveOs;
		Int[i].mod_env		= Meas->Ocrv.mod_env;
	}

	/* Compute distance */
	if	(  (!(Meas->prop & VD_MEAS_PLAN))
		&& (!(Meas->prop & VD_MEAS_SUPP)) ) {

		/* Minimum distance between two input objects */
		sts = VDminimumDistance ( msg, Meas );
	        as$status ( sts    = sts,
	                    msg    = "VDminimumDistance()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}
	else if (    (Meas->prop & VD_MEAS_PLAN)
		&& (!(Meas->prop & VD_MEAS_SUPP)) ) {

		/* Intersect the two objects with plane */
		sts = VDinterPlanObjects ( msg, 2, Meas->Iobj, &Meas->Iobj[2],
					   Mac );
	        as$status ( sts    = sts,
	                    msg    = "VDinterPlanObjects()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Get the resulting curves */
		sts = VDgetIntersections ( msg, 2, Mac, Int );
	        as$status ( sts    = sts,
	                    msg    = "VDgetIntersections()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Project points */
		sts = VDprojectPoints ( msg, &Meas->Ipnt[0], &Meas->Ipnt[3],
				        &Meas->Iobj[2], Prj1, Prj2 );
	        as$status ( sts    = sts,
	                    msg    = "VDprojectPoints()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	
		/* Minimum distance between two planar objects */
		measure = *Meas;
		measure.Iobj[0] = Int[0];
		measure.Iobj[1] = Int[1];
		for ( i=0; i<3; i++ ) {
			measure.Ipnt[0+i] = Prj1[i];
			measure.Ipnt[3+i] = Prj2[i];
		}
		sts = VDminimumDistance ( msg, &measure );
	        as$status ( sts    = sts,
	                    msg    = "VDminimumDistance()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		Meas->Odst = measure.Odst;
		for ( i=0; i<6; i++ )	Meas->Opnt[i] = measure.Opnt[i];
	}
	else if (  (!(Meas->prop & VD_MEAS_PLAN))
		&&   (Meas->prop & VD_MEAS_SUPP)  ) {

		/* Intersect the two objects with support */
		sts = VDinterSuppObjects ( msg, 2, Meas->Iobj, &Meas->Iobj[3],
					   Mac );
	        as$status ( sts    = sts,
	                    msg    = "VDinterSuppObjects()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Get the resulting curves */
		sts = VDgetIntersections ( msg, 2, Mac, Int );
	        as$status ( sts    = sts,
	                    msg    = "VDgetIntersections()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Project points */
		sts = VDprojectPoints ( msg, &Meas->Ipnt[0], &Meas->Ipnt[3],
				        &Meas->Iobj[3], Prj1, Prj2 );
	        as$status ( sts    = sts,
	                    msg    = "VDprojectPoints()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	
		/* Minimum distance between two objects on support */
		measure = *Meas;
		measure.Iobj[0] = Int[0];
		measure.Iobj[1] = Int[1];
		for ( i=0; i<3; i++ ) {
			measure.Ipnt[0+i] = Prj1[i];
			measure.Ipnt[3+i] = Prj2[i];
		}
		sts = VDminimumDistance ( msg, &measure );
	        as$status ( sts    = sts,
	                    msg    = "VDminimumDistance()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		for ( i=0; i<6; i++ )	Meas->Opnt[i] = measure.Opnt[i];

		/* Build othogonal plane */
		sts = VDorthoPlan ( msg, &Meas->Iobj[3],
				    &Meas->Opnt[0], &Meas->Opnt[3],
				    &Meas->Iobj[2] );
	        as$status ( sts    = sts,
	                    msg    = "VDorthoPlan()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Intersect the support with orthogonal plane */
		sts = VDinterPlanObjects ( msg, 1, &Meas->Iobj[3],
					   &Meas->Iobj[2], &Mac[3] );
	        as$status ( sts    = sts,
	                    msg    = "VDinterPlanObjects()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Get the resulting curve */
		sts = VDgetIntersections ( msg, 1, &Mac[3], &Int[3] );
	        as$status ( sts    = sts,
	                    msg    = "VDgetIntersections()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Get the length of the resulting curve */
		sts = VDgetCurveLength ( msg, &Int[3],
					 &Meas->Opnt[0], &Meas->Opnt[3],
					 &Meas->Odst );
	        as$status ( sts    = sts,
	                    msg    = "VDgetCurveLength()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}
	else {	/* Intersect the support with plane */
		sts = VDinterPlanObjects ( msg, 1, &Meas->Iobj[3],
					   &Meas->Iobj[2], &Mac[3] );
	        as$status ( sts    = sts,
	                    msg    = "VDinterPlanObjects()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Get the resulting curve */
		sts = VDgetIntersections ( msg, 1, &Mac[3], &Int[3] );
	        as$status ( sts    = sts,
	                    msg    = "VDgetIntersections()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	
		/* Minimum distance between object 1 and curve */
		measure = *Meas;
		measure.Iobj[1] = Int[3];
		sts = VDminimumDistance ( msg, &measure );
	        as$status ( sts    = sts,
	                    msg    = "VDminimumDistance()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		for ( i=0; i<3; i++)	Meas->Opnt[0+i] = measure.Opnt[0+i];
	
		/* Minimum distance between object 2 and curve */
		measure.Iobj[0] = Meas->Iobj[1];
		sts = VDminimumDistance ( msg, &measure );
	        as$status ( sts    = sts,
	                    msg    = "VDminimumDistance()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		for ( i=0; i<3; i++)	Meas->Opnt[3+i] = measure.Opnt[3+i];

		/* Get the length of the resulting curve */
		sts = VDgetCurveLength ( msg, &Int[3],
					 &Meas->Opnt[0], &Meas->Opnt[3],
					 &Meas->Odst );
	        as$status ( sts    = sts,
	                    msg    = "VDgetCurveLength()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Store measure line|curve in output structure */
	sts = VDmeasureLineCurve ( msg, Meas, &Int[3] );
        as$status ( sts    = sts,
                    msg    = "VDmeasureLineCurve()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set properties */
	Meas->prop |= VD_MEAS_DIST | VD_MEAS_SPNT | VD_MEAS_EPNT;

wrapup:
	for ( i=0; i<4; i++ ) {
		if (Int[i].obj_id.objid != NULL_OBJID)
			gr$delete_object ( msg	     = &loc,
					   md_env    = &Int[i].mod_env,
					   object_id = &Int[i].obj_id );
		if (Mac[i].obj_id.objid != NULL_OBJID)
			gr$delete_object ( msg	     = &loc,
					   md_env    = &Mac[i].mod_env,
					   object_id = &Mac[i].obj_id );
	}

	if (  (!(Meas->prop & VD_MEAS_PLAN))
	   && (Meas->Iobj[2].obj_id.objid != NULL_OBJID) ) {
		gr$delete_object ( msg	     = &loc,
				   md_env    = &Meas->Iobj[2].mod_env,
				   object_id = &Meas->Iobj[2].obj_id );
		Meas->Iobj[2].obj_id.objid = NULL_OBJID;
		Meas->Iobj[2].obj_id.osnum = ActiveOs;
	}

	if (  (!(Meas->prop & VD_MEAS_SUPP))
	   && (Meas->Iobj[3].obj_id.objid != NULL_OBJID) ) {
		gr$delete_object ( msg	     = &loc,
				   md_env    = &Meas->Iobj[3].mod_env,
				   object_id = &Meas->Iobj[3].obj_id );
		Meas->Iobj[3].obj_id.objid = NULL_OBJID;
		Meas->Iobj[3].obj_id.osnum = ActiveOs;
	}

	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDprepareDistance (		IGRlong		*msg,
				struct	GRobj_env	*Obj1,
				struct	GRobj_env	*Obj2,
				struct	GRobj_env	*Obj3,
				struct	GRobj_env	*Obj4,
					IGRdouble	*Pnt1,
					IGRdouble	*Pnt2,
				struct	GRid		*Win1,
				struct	GRid		*Win2,
				struct	VDmeasure	*Meas	)
{
	IGRlong		sts=OM_S_SUCCESS, siz=sizeof(struct GRmd_env), ret;
struct	GRmd_env	Env;
	GRspacenum	ActiveOs;
	IGRint		i;
struct	GRid		View;

	/* Set msg to error */
	*msg = MSFAIL;

	/* Set objects ID to NULL_OBJID */
	for ( i=0; i<4; i++)	Meas->Iobj[i].obj_id.objid = NULL_OBJID;
	Meas->Ocrv.obj_id.objid = NULL_OBJID;

	/* Check minimum entries */
	if (  (Obj1 == NULL) || (Obj2 == NULL)
	   || (Pnt1 == NULL) || (Pnt2 == NULL) )	goto wrapup;

	/* Get current environment */
        sts = gr$get_module_env ( msg    = msg,
                                  sizbuf = &siz,
                                  buffer = &Env,
                                  nret   = &ret );
        as$status ( sts    = sts,
                    msg    = "gr$get_module_env()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	ActiveOs = Env.md_id.osnum;

	/* Initialize input objects */
	Meas->Iobj[0]	= *Obj1;
	Meas->Iobj[1]	= *Obj2;

	if (Obj3 != NULL) {
		Meas->prop			|= VD_MEAS_PLAN;
		Meas->Iobj[2]			= *Obj3;
	}
	else {	Meas->Iobj[2].obj_id.objid	= NULL_OBJID;
		Meas->Iobj[2].obj_id.osnum	= ActiveOs;
		Meas->Iobj[2].mod_env		= Env;
	}

	if (Obj4 != NULL) {
		Meas->prop			|= VD_MEAS_SUPP;
		Meas->Iobj[3]			= *Obj4;
	}
	else {	Meas->Iobj[3].obj_id.objid	= NULL_OBJID;
		Meas->Iobj[3].obj_id.osnum	= ActiveOs;
		Meas->Iobj[3].mod_env		= Env;
	}

	/* Initialize input points */
	for ( i=0; i<3; i++ ) {
		Meas->Ipnt[0+i]			= Pnt1[i];
		Meas->Ipnt[3+i]			= Pnt2[i];
	}

	/* Get default view */
	if ( (Win1 == NULL) || (Win2 == NULL) ) {
		sts = VDgetDefaultView ( msg, ActiveOs, &View );
	        as$status ( sts    = sts,
	                    msg    = "VDgetDefaultView()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Initialize input windows */
	if (Win1 != NULL) 	Meas->Iwin[0]	= *Win1;
	else			Meas->Iwin[0]	= View;

	if (Win2 != NULL) 	Meas->Iwin[1]	= *Win2;
	else			Meas->Iwin[1]	= View;

	/* Initialize output fields */
	Meas->Odst	= 0.0;
	for ( i=0; i<6; i++ )	Meas->Opnt[i]	= 0.0;
	Meas->Ocrv.mod_env			= Env;
	Meas->Ocrv.obj_id.objid			= NULL_OBJID;
	Meas->Ocrv.obj_id.osnum			= ActiveOs;

	/* Compute distance */
	sts = VDcomputeDistance ( msg, Meas );
        as$status ( sts    = sts,
                    msg    = "VDcomputeDistance()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDmeasureDistance (		IGRlong		*msg,
				struct	GRobj_env	*Obj1,
				struct	GRobj_env	*Obj2,
				struct	GRobj_env	*Obj3,
				struct	GRobj_env	*Obj4,
					IGRdouble	*Pnt1,
					IGRdouble	*Pnt2,
					IGRdouble	*Dist,
					IGRdouble	*Spnt,
					IGRdouble	*Epnt	)
{
	IGRlong		sts=OM_S_SUCCESS;
struct	VDmeasure	Meas;

	/* Set properties to 0 */
	Meas.prop = 0;

	/* Call distance initilization + compute */
	sts = VDprepareDistance ( msg,
				  Obj1, Obj2, Obj3, Obj4,
				  Pnt1, Pnt2, NULL, NULL,
				  &Meas );
        as$status ( sts    = sts,
                    msg    = "VDprepareDistance()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get distance */
	if ( (Dist != NULL) && (Meas.prop & VD_MEAS_DIST) )
		*Dist = Meas.Odst;

	/* Get measure start point */
	if ( (Spnt != NULL) && (Meas.prop & VD_MEAS_SPNT) ) {
		Spnt[0] = Meas.Opnt[0];
		Spnt[1] = Meas.Opnt[1];
		Spnt[2] = Meas.Opnt[2];
	}

	/* Get measure end point */
	if ( (Epnt != NULL) && (Meas.prop & VD_MEAS_EPNT) ) {
		Epnt[0] = Meas.Opnt[3];
		Epnt[1] = Meas.Opnt[4];
		Epnt[2] = Meas.Opnt[5];
	}

wrapup:
	VDfreeDistance ( msg, &Meas );

	/* Refresh entry objects */
	if (Obj1 != NULL)
		gr$display_object ( object_id = &Obj1->obj_id,
				    md_env    = &Obj1->mod_env );
	if (Obj2 != NULL)
		gr$display_object ( object_id = &Obj2->obj_id,
				    md_env    = &Obj2->mod_env );
	if (Obj3 != NULL)
		gr$display_object ( object_id = &Obj3->obj_id,
				    md_env    = &Obj3->mod_env );
	if (Obj4 != NULL)
		gr$display_object ( object_id = &Obj4->obj_id,
				    md_env    = &Obj4->mod_env );

	return (sts);
}
/* ************************************************************************** */

end implementation Root;
