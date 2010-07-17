/* $Id: VLrpDataFunk.I,v 1.2 2001/01/16 19:39:54 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	loft/src/report/VLrpDataFunk.I
 *
 * Description:	ASCII file functions filling data arrays.
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VLrpDataFunk.I,v $
 * Revision 1.2  2001/01/16 19:39:54  ramarao
 * *** empty log message ***
 *
# Revision 1.8  2000/11/26  18:47:28  pinnacle
# Replaced: loft/src/report/VLrpDataFunk.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/06/19  13:47:28  pinnacle
# Replaced: loft/src/report/VLrpDataFunk.I for:  by rchennup for Service Pack
#
# Revision 1.3  2000/02/18  13:15:38  pinnacle
# mf
#
# Revision 1.2  1998/10/03  18:35:14  pinnacle
# tr179801544
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/14/94  MF      Creation
 * 09/09/98  RC      Added header and fixed TR#179801544
 * 05/31/00  MF      Avondale Steel Bands & Key Lines
 *************************************************************************/

class implementation VLabstract;

#include        <stdio.h>
#include        <string.h>
#include        "vlprototype.h"
#include        "ACattrib.h"
#include        "AS_status.h"
#include        "bsvalues.h"
#include        "bserr.h"
#include        "msmacros.h"

#include	"vlmsg.h"
#include	"vsslc.h"
#include	"vsmiscmacros.h"

#include	"vlfloor.h"
#include	"vlpinjig.h"
#include	"vltemplate.h"
#include	"vlstifbend.h"
#include	"vlmiscmacros.h"
#include	"vlforkmacros.h"
#include	"vlkline.h"

#include	"bsalloccv.h"
#include	"bscrossp.h"
#include	"bsfreecv.h"
#include	"bslenvec.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"
#include	"bsprj_cv_pl.h"

from	ACdyn_col	import	AClist_attribute;
from    ACrg_collect    import  ACget_named_attribute;
from	GRcurve		import	GRtotlength;
from	GRgencs		import	GRgetmatrix;
from	GRlinear	import	GRgetpolyline;
from	VLpinjig	import	VLget_attributes;
from	VLjunction	import	VLreturn_collect;

extern	GRclassid	OPP_text_exp_class_id;
extern  IGRdouble 	VLgetFootValue();

/*
#define	TRACE
*/

#define	KL_P_TRAN	"Transverse Process"
#define	KL_P_LONG	"Longitudinal Process"
#define	KL_P_DIAG	"Diagonal Process"

/* ************************************************************************** */
IGRlong	VLfillBalanceData ( num, List, Sort, msg)

		IGRint		num;	/*I Number of <VLbalance> objects     */
	struct	GRobj_env	List[]; /*I Array of <VLbalance> objects      */
	struct	VLsortTpl	**Sort; /*O Array of data 		      */
		IGRlong		*msg;	/*O Completion code		      */

{
		IGRint		sts=OM_S_SUCCESS, i;
		VStktxt		name;

	/*c Initialize */
	*Sort = NULL;
	if (!num)	goto wrapup;

	/*c Allocate memory for data array */
	*Sort = om$calloc ( num = num, structure = struct VLsortTpl);

	/*c Fill data array */
        for ( i=0; i<num; i++) {

		/*c Index */
		(*Sort)[i].idx = i;

		/*c Occurence name */
		sts = om$send ( msg = message GRgraphics.GRgetname ( msg, name),
				senderid = NULL_OBJID,
				targetid = List[i].obj_id.objid,
				targetos = List[i].obj_id.osnum );
		if (!(sts & 0x00000001 & (*msg)))
                        strcpy( (*Sort)[i].name, "Unamed");
                else    strcpy( (*Sort)[i].name, &strrchr(name,':')[1]);

		/*c Number of objects */
		(*Sort)[i].num = 0;
                sts = om$send ( msg = message GRowner.GRget_number_components
						( msg, &(*Sort)[i].num) ,
				senderid = NULL_OBJID,
				targetid = List[i].obj_id.objid,
				targetos = List[i].obj_id.osnum );
                as$status ( sts    = sts,
			    msg    = "GRowner.GRget_number_components",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/*c X angle */
		(*Sort)[i].x = VLgetFootValue ( &List[i].obj_id, NAM_BF_XANG)
			     * 180.0 / M_PI;

		/*c Y angle */
		(*Sort)[i].y = VLgetFootValue ( &List[i].obj_id, NAM_BF_YANG)
			     * 180.0 / M_PI;

		/*c Z angle */
		(*Sort)[i].z = VLgetFootValue ( &List[i].obj_id, NAM_BF_ZANG)
			     * 180.0 / M_PI;

		/*c Number of VSplates */
		(*Sort)[i].num -= MACRO_B_FFEET +
		(IGRint) VLgetFootValue ( &List[i].obj_id, NAM_BF_NPLT);
	}

	/* Sort the input objects by name */
	qsort ( *Sort, num, sizeof(struct VLsortTpl), (int (*)())VLsortName);

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLfillPinjig1 ( Lst, npin, ncrn, Corn, npnl, Panl, Data, H1V1, msg )

	struct	GRobj_env	*Lst;	/*I  <VLpinjig> object		      */
		IGRint		*npin;	/*O Number of pins		      */
		IGRint		*ncrn;	/*O Number of corners		      */
		VLpinCorn	**Corn;	/*O Corners positions array	      */
		IGRint		*npnl;	/*O Number of panel corners	      */
		VLpinCorn	**Panl;	/*O Panel corners positions array     */
	struct	ACrg_coll	**Data;	/*O Data array positions	      */
		IGRpoint	H1V1;	/*O H1V1 pinjig position	      */
		IGRlong		*msg;	/*O Completion code		      */

{
		IGRint		sts=OM_S_SUCCESS;
		VStktxt		name;
	struct	ACrg_coll	glob[IDX_PB_MAX];

	/* Initialize */
	*npin = 0;
	*ncrn = 0;
	*npnl = 0;
	if (*Data) {	om$dealloc (ptr = *Data);	*Data = NULL;	}
	if (*Corn) {	om$dealloc (ptr = *Corn);	*Corn = NULL;	}
	if (*Panl) {	om$dealloc (ptr = *Corn);	*Corn = NULL;	}

	/* Number of <pinjig> and H1V1 position */
	sts = om$send ( msg = message VLpinjig.VLget_attributes
					( msg, NULL, npin, TRUE, NULL, glob),
			senderid = NULL_OBJID,
			targetid = Lst->obj_id.objid,
			targetos = Lst->obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "VLpinjig.VLget_attributes",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Fill H1V1 array */
	H1V1[0] = glob[IDX_PB_XPT].desc.value.att_exp;
	H1V1[1] = glob[IDX_PB_YPT].desc.value.att_exp;
	H1V1[2] = glob[IDX_PB_ZPT].desc.value.att_exp;

	/* Get all the corners */
	VLpinCorners ( msg, Lst, *npin, ncrn, Corn, npnl, Panl );
	as$status ( sts    = sts,
		    msg    = "VLpinCorners()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Allocate memory for <ACrg_coll> */
	*Data = om$calloc ( num = 3 + IDX_PB_MAX, structure = struct ACrg_coll);

	/*c Store generic data in Data */
	strcpy ( (*Data)[0].name, "occ_nam");
	strcpy ( (*Data)[1].name, "pin_num");
	strcpy ( (*Data)[2].name, "crn_num");

	(*Data)[0].desc.type = AC_ATTRIB_TEXT;
	(*Data)[1].desc.type = AC_ATTRIB_DOUBLE;
	(*Data)[2].desc.type = AC_ATTRIB_DOUBLE;

	sts = om$send ( msg = message GRgraphics.GRgetname ( msg, name),
			senderid = NULL_OBJID,
			targetid = Lst->obj_id.objid,
			targetos = Lst->obj_id.osnum );
	if (!(sts & 0x00000001 & (*msg)))
		strcpy( (*Data)[0].desc.value.att_txt, "Unamed");
	else	strcpy( (*Data)[0].desc.value.att_txt, &strrchr(name,':')[1]);
	(*Data)[1].desc.value.att_exp = (IGRdouble)(*npin);
	(*Data)[2].desc.value.att_exp = (IGRdouble)(*ncrn);

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLfillPinjig2 ( Lst, idx, H1V1, Data, msg)

	struct	GRobj_env	*Lst;	/*I  <VLpinjig> object		      */
		IGRint		idx;	/*I  Index of pin		      */
		IGRpoint	H1V1;	/*I H1V1 pinjig position	      */
	struct	ACrg_coll	*Data;	/*IO All the positions		      */
		IGRlong		*msg;	/*O  Completion code		      */

{
		IGRint		sts=OM_S_SUCCESS, i, npin=0, nfix=3;
	struct	ACrg_coll	elem[IDX_PB_MAX];

	/*c Adjust pin location */
	sts = VLgetPinAttributes ( msg, &Lst->obj_id, idx, elem );
	as$status ( sts    = sts,
		    msg    = "VLgetPinAttributes()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	elem[IDX_PB_XPT].desc.value.att_exp -= H1V1[0];
	if( elem[IDX_PB_XPT].desc.value.att_exp < 0.0 )
	  elem[IDX_PB_XPT].desc.value.att_exp *= -1;

	elem[IDX_PB_YPT].desc.value.att_exp -= H1V1[1];
	if( elem[IDX_PB_YPT].desc.value.att_exp < 0.0 )
	  elem[IDX_PB_YPT].desc.value.att_exp *= -1;

	elem[IDX_PB_ZPT].desc.value.att_exp -= H1V1[2];
	if( elem[IDX_PB_ZPT].desc.value.att_exp < 0.0 )
	  elem[IDX_PB_ZPT].desc.value.att_exp *= -1;

	/* Height don't need to be substracted from the Z point. 
	   Commented for TR#179801544 */

//	elem[IDX_PB_HEI].desc.value.att_exp -= H1V1[2];
	elem[IDX_PB_ANG].desc.value.att_exp *= 180.0 / M_PI;

	/*c Retrieve generic data */
	npin = (IGRint)Data[1].desc.value.att_exp;

	/*c Store values in Data */
	for ( i=0; i<IDX_PB_MAX; i++) {
		strcpy ( Data[nfix+i].name, elem[i].name);
		Data[nfix+i].desc.type = elem[i].desc.type;
	}
Data[nfix+IDX_PB_COL].desc.value.att_exp = elem[IDX_PB_COL].desc.value.att_exp;
Data[nfix+IDX_PB_LIN].desc.value.att_exp = elem[IDX_PB_LIN].desc.value.att_exp;
Data[nfix+IDX_PB_XPT].desc.value.att_exp = elem[IDX_PB_XPT].desc.value.att_exp;
Data[nfix+IDX_PB_YPT].desc.value.att_exp = elem[IDX_PB_YPT].desc.value.att_exp;
Data[nfix+IDX_PB_ZPT].desc.value.att_exp = elem[IDX_PB_ZPT].desc.value.att_exp;
Data[nfix+IDX_PB_HEI].desc.value.att_exp = elem[IDX_PB_HEI].desc.value.att_exp;
Data[nfix+IDX_PB_ANG].desc.value.att_exp = elem[IDX_PB_ANG].desc.value.att_exp;
Data[nfix+IDX_PB_IDX].desc.value.att_exp = elem[IDX_PB_IDX].desc.value.att_exp;
	strcpy ( Data[nfix+IDX_PB_NAM].desc.value.att_txt,
		 elem[IDX_PB_NAM].desc.value.att_txt );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLfillChtTemplateData ( List, nobj, Reg, Spi, msg)

	struct	GRobj_env	*List;	/*I	Object <VLtplMgr>     	      */
		IGRint		*nobj;	/*O	Number of <VLtplObj>	      */
		VLpltTpl	**Reg;	/*O	Regular Template Data 	      */
		VLpltTpl	**Spi;	/*O	Spine Template Data   	      */
		IGRlong		*msg;	/*O	Completion code	      	      */

{
		IGRint		sts=OM_S_SUCCESS, Fidx=0, Lidx=0, suc, i;
	struct	GRid		spine, cs_id, regul;
		IGRpoint	Wpt1, Wpt2;
		VStktxt		Sname, Rname;
		IGRdouble	tmp1, tmp2;

	/* Initialize */
	*nobj = 0;
	if (*Reg) {	om$dealloc (ptr = *Reg);	*Reg = NULL;	}
	if (*Spi) {	om$dealloc (ptr = *Spi);	*Spi = NULL;	}
	spine.objid = NULL_OBJID;
	Sname[0]    = '\0';

	/* Extract basic info from <VLtplMgr> */
	sts = VLextractTplFromMgr ( msg, &List->obj_id, &Fidx, &Lidx, &spine );
	as$status ( sts    = sts,
		    msg    = "VLextractTplFromMgr()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	*nobj = Lidx - Fidx;

	/* Extract info on spine-template (if any) */
	if (spine.objid != NULL_OBJID) {

		/* <VLtplMgr> projected or not ? */
		sts = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
					( &suc, IDX_TM_B_CS, &cs_id),
				senderid = NULL_OBJID,
				targetid = List->obj_id.objid,
				targetos = List->obj_id.osnum );
		as$status ( sts    = sts,
			    msg    = "ACfind_exp_temp_obj(B_CS)",
			    test   = (!(sts & 0x00000001 & suc)),
			    action = GOTO_VALUE,
			    value  = wrapup );

		if (!vs$is_ancestry_valid ( object  = &cs_id,
                                  	    classid = OPP_text_exp_class_id )) {
			spine.objid = NULL_OBJID;
			ex$message (msgnumb = VL_E_NO_SPINE_TEMPLATE);
		}
		else {	sts = VLextractSpineTplInfo ( msg, &spine,
						      Wpt1, Wpt2, Sname );
			as$status ( sts    = sts,
				    msg    = "VLextractSpineTplInfo()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
		}

		/* Allocate memory for spine template */
		*Spi = om$calloc ( num = *nobj, structure = VLpltTpl );
	}

	/* Allocate memory for regular templates */
	*Reg = om$calloc ( num = *nobj, structure = VLpltTpl );

	/* Loop on regular templates */
	for ( i=0; i<*nobj; i++) {

		/* Get the variable foot */
		Rname[0] = '\0';
		sprintf ( Rname, "%s%d", NAM_TM_VARF, i+1);
		sts = vl$return_foot ( msg     = msg,
				       name    = Rname,
	                               objId   = &List->obj_id,
	                               footId  = &regul );
		as$status ( sts    = sts,
			    msg    = "vl$return_foot(VARF)",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Feed data structures */
		if (spine.objid == NULL_OBJID) {
			sts = VLextractTemplateCht ( msg,
						     &regul,
						     NULL,
						     NULL,
						     (*Reg)[i].nam,
						     &(*Reg)[i].hei,
						     &(*Reg)[i].cht,
						     &(*Reg)[i].ang,
						     (*Reg)[i].lea,
						     &tmp1,
						     &tmp2 );
			as$status ( sts    = sts,
				    msg    = "VLextractTemplateCht()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
		}
		else {	sts = VLextractTemplateCht ( msg,
						     &regul,
						     Wpt1,
						     Wpt2,
						     (*Reg)[i].nam,
						     &(*Reg)[i].hei,
						     &(*Reg)[i].cht,
						     &(*Reg)[i].ang,
						     (*Reg)[i].lea,
						     &(*Spi)[i].hei,
						     &(*Spi)[i].cht );
			as$status ( sts    = sts,
				    msg    = "VLextractTemplateCht()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
			strcpy ( (*Spi)[i].nam, Sname );
			strcpy ( (*Spi)[i].frm,
				 &strrchr ( (*Reg)[i].nam, '_')[1] );
		}
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLfillHeiTemplateData1 ( List, ntpl, Tpl, msg)

	struct	GRobj_env	*List;	/*I	Object <VLtplMgr>     	      */
		IGRint		*ntpl;	/*O	Number of <VLtplObj>	      */
		VLpltTpl	**Tpl;	/*O	Template Data	 	      */
		IGRlong		*msg;	/*O	Completion code	      	      */

{
		IGRint		sts=OM_S_SUCCESS, Fidx=0, Lidx=0, nspi=0, i;
		VStktxt		name, Mnam;
	struct	GRid		spine;

	/* Initialize */
	(*Tpl) = NULL;
	spine.objid = NULL_OBJID;

	/* Get name of <VLtplMgr> */
        sts = om$send ( msg = message GRgraphics.GRgetname ( msg, name),
                        senderid = NULL_OBJID,
                        targetid = List->obj_id.objid,
                        targetos = List->obj_id.osnum );
        if (!(sts & 0x00000001 & (*msg)))
                strcpy( Mnam, "Unamed");
        else    strcpy( Mnam, &strrchr(name,':')[1]);

	/* Extract <VLtplObj> from <VLtplMgr> */
        spine.objid = NULL_OBJID;
        sts = VLextractTplFromMgr ( msg, &List->obj_id, &Fidx, &Lidx, &spine);
        as$status ( sts    = sts,
                    msg    = "VLextractTplFromMgr()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        *ntpl = Lidx - Fidx;
	if (!(*ntpl))	goto wrapup;
	if (spine.objid != NULL_OBJID)	nspi = 1;

	/* Allocate memory */
	*Tpl = om$calloc ( num = (*ntpl + nspi) * 80, structure = VLpltTpl );

	/* Build <VLtplObj> names */
	for ( i=0; i<*ntpl; i++) {
		strcpy ( (*Tpl)[i].nam, Mnam);
		(*Tpl)[i].frm[0] = '\0';
		sprintf ( (*Tpl)[i].frm, "%s%d", NAM_TM_VARF, i+1);
	}
	if (spine.objid != NULL_OBJID) {
		strcpy ( (*Tpl)[*ntpl].nam, Mnam);
                strcpy ( (*Tpl)[*ntpl].frm, NAM_TM_TSPI);
	}

	/* Adjust real array size */
	(*ntpl) += nspi;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLfillHeiTemplateData2 ( List, step, Tpl, nval, Val, msg)

	struct	GRobj_env	*List;	/*I	Object <VLtplMgr>     	      */
		IGRdouble	step;	/*I	Step value		      */
		VLpltTpl	*Tpl;	/*IO	Template Data	 	      */
		IGRint		*nval;	/*O	Number of heights	      */
		IGRdouble	**Val;	/*O	Heights array		      */
		IGRlong		*msg;	/*O	Completion code	      	      */

{
		IGRint		sts=OM_S_SUCCESS, idx=0;
		VStktxt		name;
	struct	GRid		contour;
	struct	ret_struct	str;

	/* Initialize */
	*nval = 0;
	if (*Val) {	om$dealloc (ptr = *Val);	*Val = NULL;	}

	/* Get contour foot of template object involved */
	name[0] = '\0';
	sprintf ( name, "%s:%s", Tpl->frm, NAM_TO_CONT);
	sts = vl$return_foot ( msg     = msg,
                               name    = name,
                               objId   = &List->obj_id,
                               footId  = &contour );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(CONT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Compute heights */
	sts = VLcomputeTemplateHeights ( &contour, &List->mod_env, step,
					 nval, Val, msg );
	as$status ( sts    = sts,
                    msg    = "VLcomputeTemplateHeights()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get code name of template object involved */
	name[0] = '\0';
	sprintf ( name, "%s:%s", Tpl->frm, NAM_TO_REFP);
	sts = om$send ( msg = message NDmacro.ACgive_structure
			( (IGRint *) msg, &idx, name, &str, &List->mod_env ),
			senderid = NULL_OBJID,
			targetid = List->obj_id.objid,
			targetos = List->obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "ACgive_structure",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if (str.var.text_st.text_string)
		strcpy ( Tpl->frm, str.var.text_st.text_string);

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLcomputeTemplateHeights ( Tpl, Env, step, nval, Val, msg)

	struct	GRid		*Tpl;	/*I	Object <VLtplObj:contour>     */
	struct	GRmd_env	*Env;	/*I	Environment info	      */
		IGRdouble	step;	/*I	Step value		      */
		IGRint		*nval;	/*O	Number of computed heights    */
		IGRdouble	*Val[];	/*O	Array of computed heights     */
		IGRlong		*msg;	/*O	Completion code	      	      */

{
		IGRint		sts=OM_S_SUCCESS, num=0;
	struct	GRid		component[4];
		IGRpoint	spt, ept;
		IGRvector	dir, ort, vec;
		BSrc		rc;
	struct	GRobj_env	Crv;
	struct	IGRbsp_curve	*crv, *prj;

	/* Initialize */
	*nval = 0;
	*Val  = NULL;
	crv   = NULL;
	prj   = NULL;

	/* Retrieve contour components */
	sts = om$send ( msg = message GRowner.GRget_components
				( msg, Env, component, 4, &num, 0, 4 ),
			senderid = NULL_OBJID,
			targetid = Tpl->objid,
			targetos = Tpl->osnum );
	as$status ( sts    = sts,
		    msg    = "GRowner.GRget_components",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve endpoints of start segment of contour */
	sts = VLendpts ( msg, &component[3], Env, spt, ept);
	as$status ( sts    = sts,
		    msg    = "VLendpts()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Compute projection direction */
	BSmkvec ( &rc, ort, spt, ept);
	if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSmkvec()\n");
                            goto wrapup; }
	BSnorvec ( &rc, ort);
	if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSnorvec()\n");
                            goto wrapup; }

	/* Retrieve endpoints of top segment of contour */
	sts = VLendpts ( msg, &component[2], Env, spt, ept);
	as$status ( sts    = sts,
		    msg    = "VLendpts()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Compute segment direction */
	BSmkvec ( &rc, dir, spt, ept);
	if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSmkvec()\n");
                            goto wrapup; }
	BSnorvec ( &rc, dir);
	if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSnorvec()\n");
                            goto wrapup; }

	/* Retrieve down curve of contour */
	Crv.mod_env = *Env;
	Crv.obj_id  = component[0];
	sts = VLgetGeometry ( &Crv, FALSE, NULL_OBJID, (IGRchar **)&crv, msg);
	as$status ( sts    = sts,
		    msg    = "VLgetGeometry()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Project curve in (spt,dir,ort) plane */
	BScrossp ( &rc, dir, ort, vec);
	if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BScrossp()\n");
                            goto wrapup; }
	BSnorvec ( &rc, vec);
	if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSnorvec()\n");
                            goto wrapup; }
	BSalloccv ( crv->order, crv->num_poles, crv->rational,
		    crv->num_boundaries, &prj, &rc);
	if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSalloccv()\n");
                            goto wrapup; }
	BSprj_cv_pl ( &rc, crv, spt, vec, vec, prj);
	if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSprj_cv_pl()\n");
                            goto wrapup; }

	/* Compute heights */
	sts = VLgetHeights ( &Crv.mod_env, &Crv.obj_id, spt, ept, step, dir,
			     ort, prj, nval, Val, msg );
	as$status ( sts    = sts,
		    msg    = "VLgetHeights()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:
	if (prj) {	BSfreecv ( &rc, prj);	prj = NULL;	}
	if (crv) {	om$dealloc (ptr = crv);	crv = NULL;	}
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLcomputeBendLineHeights ( Lin, List, step, nval, Val, msg)

	struct	GRobj_env	*Lin;	/*I	Object bended line 	      */
	struct	GRobj_env	*List;	/*I	Object <VLstifBend>	      */
		IGRdouble	step;	/*I	Step value		      */
		IGRint		*nval;	/*O	Number of computed heights    */
		IGRdouble	*Val[];	/*O	Array of computed heights     */
		IGRlong		*msg;	/*O	Completion code	      	      */

{
		IGRint		sts=OM_S_SUCCESS, suc, i;
	struct	GRid		cs_id;
		IGRmatrix	cs_mat;
		IGRvector	Xvec, Yvec;
	struct	GRobj_env	Contour;
		IGRpoint	pts[5];
	struct	IGRpolyline	poly;
	struct	IGRbsp_curve	*crv;

	/* Initialize */
	*nval = 0;
	*Val  = NULL;
	crv   = NULL;
	poly.num_points = 5;
	poly.points     = (IGRdouble *) pts;

	/* Retrieve the coordinate system template matrix */
	sts = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
				( &suc, IDX_SBT_CSYS, &cs_id),
			senderid = NULL_OBJID,
			targetid = List->obj_id.objid,
			targetos = List->obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "ACfind_exp_temp_obj(CSYS)",
		    test   = (!(sts & 0x00000001 & suc)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, cs_mat),
			senderid = NULL_OBJID,
			targetid = cs_id.objid,
			targetos = cs_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRgencs.GRgetmatrix",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Store direction and orthogonal vectors */
	for ( i=0; i<3; i++) {	Xvec[i] = cs_mat[4*i];
				Yvec[i] = cs_mat[4*i+1];	}

	/*c Retrieve contour foot */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_SBF_CONT,
                               objId   = &List->obj_id,
			       objEnv  = &List->mod_env,
                               footId  = &Contour.obj_id,
			       footEnv = &Contour.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(CONT)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve contour components */
	suc = 1;
	sts = om$send ( msg = message GRlinear.GRgetpolyline (
					msg,
					&Contour.mod_env.md_env.matrix_type,
					Contour.mod_env.md_env.matrix,
					&suc, &poly ),
			senderid = NULL_OBJID,
			targetid = Contour.obj_id.objid,
			targetos = Contour.obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRlinear.GRgetpolyline",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get bended line geometry */
	sts = VLgetGeometry ( Lin, FALSE, NULL_OBJID, (IGRchar **)&crv, msg);
	as$status ( sts    = sts,
		    msg    = "VLgetGeometry()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Compute heights */
	sts = VLgetHeights ( &Lin->mod_env, &Lin->obj_id,
			     &poly.points[0], &poly.points[3], step,
			     Xvec, Yvec, crv, nval, Val, msg );
	as$status ( sts    = sts,
		    msg    = "VLgetHeights()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:
	if (crv) {	om$dealloc (ptr = crv);	crv = NULL;	}
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLfillSteelBand ( Lst, Info, Data, msg )

	struct	GRobj_env	*Lst;	/*I <VLsteelBand> object	      */
		VLsteelBandInfo	*Info;	/*O Steel Band info		      */
		VLsteelBandData	**Data;	/*O Steel Band data array 	      */
		IGRlong		*msg;	/*O Completion code		      */

{
		IGRint		sts=OM_S_SUCCESS, i;
	struct	GRid		foot;
		IGRchar		name[80];

	/* Initialize */
	Info->band[0] = '\0';
	Info->unit[0] = '\0';
	Info->desc[0] = '\0';
	Info->jobN[0] = '\0';
	Info->numP = 0;

	/* Get number of points */
        sts = om$send ( msg = message GRowner.GRget_number_components
				( msg, &(Info->numP) ) ,
			senderid = NULL_OBJID,
                        targetid = Lst->obj_id.objid,
                        targetos = Lst->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRowner.GRget_number_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	Info->numP -= 1;
#ifdef TRACE
printf ( "VLfillSteelBand : [%2d,%5d] have %d points\n",
	 Lst->obj_id.osnum, Lst->obj_id.objid, Info->numP );
#endif
	/* Fill Info structure */
	sts = VLgetSteelBandInformation ( Lst,
					  Info->band,
					  Info->unit,
					  Info->desc,
					  Info->jobN,
					  &Info->stock,
					  &Info->endstock,
					  msg );
        as$status ( sts    = sts,
                    msg    = "VLgetSteelBandInformation",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory for <VLsteelBandData> array */
	*Data = om$calloc ( num = Info->numP, structure = VLsteelBandData);

	/* Fill <VLsteelBandData> array */
	for ( i=0; i<Info->numP; i++ ) {
		sts = VLgetSteelBandAttributes
			( Lst, i,
			&(*Data)[i].idx, (*Data)[i].nam, &(*Data)[i].dst,
			msg );
	        as$status ( sts    = sts,
	                    msg    = "VLgetSteelBandAttributes",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRdouble KLgetDistance ( foot, name )
	struct	GRid	*foot;
	IGRchar		*name;
{
	IGRint		sts=OM_S_SUCCESS;
	IGRlong		msg=OM_S_SUCCESS;
	IGRdouble	dst;

	sts = vl$getForkAttr ( msg	= &msg,
			       forkId	= foot,
			       name	= name,
			       value	= &dst );
        as$status ( sts    = sts,
                    msg    = "vl$getForkAttr()",
                    test   = (!(sts & 0x00000001 & msg)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	return (dst);

wrapup:
	return (-1.0);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRchar * KLgetName ( foot, name )
	struct	GRid	*foot;
	IGRchar		*name;
{
	IGRint		sts=OM_S_SUCCESS;
	IGRlong		msg=OM_S_SUCCESS;
	IGRchar		nam[ATTR_TXT];

	sts = vl$getForkAttr ( msg	= &msg,
			       forkId	= foot,
			       name	= name,
			       text 	= nam );
        as$status ( sts    = sts,
                    msg    = "vl$getForkAttr()",
                    test   = (!(sts & 0x00000001 & msg)),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (nam);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRint VLsortKLdata ( a, b )

        VLkeyLineData	*a, *b;

{
	IGRint	n=0;

	n = strcmp ( a->lin, b->lin );
	if (n == 0) {
		if      (a->dst < b->dst)	n = -1;
		else 				n =  1;
	}

        return (n);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRboolean VLcompKLdata ( a, b )

        VLkeyLineData	*a, *b;

{
	if ( (strcmp ( a->pro, b->pro ) == 0)
	&&   (strcmp ( a->lin, b->lin ) == 0)
	&&   (strcmp ( a->nam, b->nam ) == 0)
	&&   (a->dst == b->dst) )
		return TRUE;
	else
		return FALSE;
}
/* ************************************************************************** */

/* ************************************************************************** */
void VLcopyKLdata ( to, fr )

        VLkeyLineData	*to, *fr;

{
	strcpy ( to->pro, fr->pro );
	strcpy ( to->lin, fr->lin );
	strcpy ( to->nam, fr->nam );
	to->dst = fr->dst;
	return;
}

/* ************************************************************************** */
IGRboolean VLduplicateKLdata ( n, D )

	IGRint		*n;
        VLkeyLineData	**D;
{
	IGRint		i, j, cnt=0, *Dup;
	IGRboolean	ret=FALSE;
	VLkeyLineData	*New;

#ifdef TRACE
printf ( ">>VLduplicateKLdata : count = %d\n", *n );
for ( i=0; i<(*n); i++ ) {
	printf ( "\t%2d is <%s, %s, %s, %g>\n", i,
		 (*D)[i].pro, (*D)[i].lin, (*D)[i].nam, (*D)[i].dst );
}
#endif

	/* Initialize */
	Dup = NULL;
	New = NULL;

	/* Allocate memory */
	Dup = om$calloc ( num = (*n), structure = IGRint );
#ifdef TRACE
printf ( "VLduplicateKLdata : %d bytes allocated to Dup\n",
	 (*n) * sizeof(IGRint) );
#endif

	/* Find duplicates */
	for ( i=0; i<(*n); i++ ) {
		Dup[i] = 1;
		for ( j=0; j<i; j++ ) {
			if (VLcompKLdata ( &(*D)[i], &(*D)[j] )) {
				Dup[i] = 0;
				j = i;
			}
		}
	}

	/* Count non duplicates */
	for ( i=0; i<(*n); i++ )	cnt += Dup[i];
#ifdef TRACE
printf ( "VLduplicateKLdata : %d duplicates\n", (*n) - cnt );
#endif

	/* Resize et refill array without duplicates */
	if ( ((*n) - cnt) > 0) {
	
		New = om$calloc ( num = cnt, structure = VLkeyLineData );
#ifdef TRACE
printf ( "VLduplicateKLdata : %d bytes allocated to New\n",
	 cnt * sizeof(VLkeyLineData) );
#endif

		for ( i=0, j=0; i<(*n); i++ ) {
			if (Dup[i] == 1) {
			 	VLcopyKLdata ( &New[j], &(*D)[i] );
				j++;
			}
		}

		(*n) = cnt;
		(*D) = (VLkeyLineData *)
			om$realloc ( ptr  = (IGRchar *)(*D),
				     size = (*n) * sizeof(VLkeyLineData) );
#ifdef TRACE
printf ( "VLduplicateKLdata : %d bytes reallocated to D\n",
	 (*n) * sizeof(VLkeyLineData) );
#endif
		for ( i=0; i<(*n); i++ )
			VLcopyKLdata ( &(*D)[i], &New[i] );
#ifdef TRACE
printf ( "VLduplicateKLdata : copy non duplicates to array\n" );
#endif

		ret = TRUE;
	}

	if (Dup) {	om$dealloc (ptr = Dup);		Dup = NULL; }
	if (New) {	om$dealloc (ptr = New);		New = NULL; }
#ifdef TRACE
printf ( "<<VLduplicateKLdata : count = %d\n", *n );
for ( i=0; i<(*n); i++ ) {
	printf ( "\t%2d is <%s, %s, %s, %g>\n", i,
		 (*D)[i].pro, (*D)[i].lin, (*D)[i].nam, (*D)[i].dst );
}
#endif
	return (ret);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLgetKLinfo ( Lst, Info, msg )

	struct	GRobj_env	*Lst;	/*I <VLkeyLine> object		      */
		VLkeyLineInfo	*Info;	/*O Key line info		      */
		IGRlong		*msg;	/*O Completion code		      */

{
		IGRint		sts=OM_S_SUCCESS, cnt=0;
        struct  GRid            foot;

        /* Initialize */
        Info->numT = 0;
        Info->numL = 0;
        Info->numD = 0;

        /* Get VLjunction at index */
        foot.objid = NULL_OBJID;
        sts = vl$return_foot ( msg	= msg,
                               name	= NAM_KL_KLIN,
                               objId	= &(Lst->obj_id),
                               objEnv	= &(Lst->mod_env),
                               footId	= &foot );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        /* Get UnitNumber */
	sts = vl$getForkAttr ( msg	= msg,
			       forkId	= &foot,
			       name	= "UnitNumber",
			       text	= Info->unit );
	if (!(sts & 0x00000001 & (*msg))) {
		strcpy ( Info->unit, "Unknown" );
		sts  = OM_S_SUCCESS;
		*msg = OM_S_SUCCESS;
	}
#ifdef TRACE
printf ( "VLgetKLinfo : UnitNumber is <%s>\n", Info->unit );
#endif
        /* Get JobNumber */
	sts = vl$getForkAttr ( msg	= msg,
			       forkId	= &foot,
			       name	= "JobNumber",
			       text	= Info->jobN );
	if (!(sts & 0x00000001 & (*msg))) {
		strcpy ( Info->jobN, "Unknown" );
		sts  = OM_S_SUCCESS;
		*msg = OM_S_SUCCESS;
	}
#ifdef TRACE
printf ( "VLgetKLinfo : JobNumber is <%s>\n", Info->jobN );
#endif
	/* Get number of feet */
        sts = om$send ( msg = message GRowner.GRget_number_components
				( msg, &cnt ) ,
			senderid = NULL_OBJID,
                        targetid = Lst->obj_id.objid,
                        targetos = Lst->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRowner.GRget_number_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Evaluate number of transverse, longitudinal & diagonal max number */
	Info->numT = cnt - 11;
	Info->numL = cnt - 11;
	Info->numD = 8;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLfillKeyLine ( Lst, Info, Tran, Long, Diag, msg )

	struct	GRobj_env	*Lst;	/*I <VLkeyLine> object		      */
		VLkeyLineInfo	*Info;	/*O Key line info		      */
		VLkeyLineData	**Tran;	/*O Key line data (transverse) 	      */
		VLkeyLineData	**Long;	/*O Key line data (longitudinal)      */
		VLkeyLineData	**Diag;	/*O Key line data (diagonal) 	      */
		IGRlong		*msg;	/*O Completion code		      */

{
		IGRint		sts=OM_S_SUCCESS, cnt=0, i=0;
        struct  GRid            foot;
	struct	GRobj_env	Geom;
        struct  ACrg_coll       attr;
		IGRchar		name[ATTR_NAME];
		IGRdouble	dst;
		IGRint		iT=0, iL=0;

        /* Get Info */
	sts = VLgetKLinfo ( Lst, Info, msg );
        as$status ( sts    = sts,
                    msg    = "VLgetKLinfo()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get DIAGONAL data */
	(*Diag) = om$calloc ( num = Info->numD, structure = VLkeyLineData );

	for ( i=0; i<Info->numD; i++ ) {

		sprintf ( name, "%s%d", NAM_KL_DIAG, i+1 );
		foot.objid = NULL_OBJID;
	        sts = vl$return_foot ( msg	= msg,
	                               name	= name,
	                               objId	= &(Lst->obj_id),
	                               objEnv	= &(Lst->mod_env),
	                               footId	= &foot );
	        as$status ( sts    = sts,
	                    msg    = "vl$return_foot",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		strcpy ( (*Diag)[i].pro, KL_P_DIAG );
		strcpy ( (*Diag)[i].lin, "Not used" );
		strcpy ( (*Diag)[i].nam,
			 KLgetName ( &foot, NAM_KB_DIAGNAM) );

		Geom.obj_id.objid = NULL_OBJID;
		sts = vl$getForkGeom ( msg     = msg,
				       forkId  = &foot,
				       forkEnv = &(Lst->mod_env),
				       footId  = &(Geom.obj_id),
				       footEnv = &(Geom.mod_env) );
	        as$status ( sts    = sts,
	                    msg    = "vl$getForkGeom",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		sts = om$send ( msg = message GRcurve.GRtotlength (
					msg,
					&Geom.mod_env.md_env.matrix_type,
					Geom.mod_env.md_env.matrix,
					&((*Diag)[i].dst) ),
				senderid = NULL_OBJID,
				targetid = Geom.obj_id.objid,
				targetos = Geom.obj_id.osnum );
	        as$status ( sts    = sts,
	                    msg    = "GRcurve.GRtotlength",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Get TRANSVERSE & LONGITUDINAL data */
	if (Info->numT > 0)
		(*Tran) = om$calloc ( num = Info->numT,
				      structure = VLkeyLineData );
	if (Info->numL > 0)
		(*Long) = om$calloc ( num = Info->numL,
				      structure = VLkeyLineData );

	for ( i=0; i<Info->numT; i++ ) {

		IGRchar	T[80], L[80];

		sprintf ( name, "%s%d", NAM_KL_PNT, i+1 );
		foot.objid = NULL_OBJID;
	        sts = vl$return_foot ( msg	= msg,
	                               name	= name,
	                               objId	= &(Lst->obj_id),
	                               objEnv	= &(Lst->mod_env),
	                               footId	= &foot );
	        as$status ( sts    = sts,
	                    msg    = "vl$return_foot",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
#ifdef TRACE
strcpy ( T, KLgetName(&foot,NAM_KPJ_TNAM) );
strcpy ( L, KLgetName(&foot,NAM_KPJ_LNAM) );
printf ( "<%s>\trow=%g\tcolumn=%g\tT:<%s>\tL:<%s>\n", name,
	 KLgetDistance(&foot,"Row"), KLgetDistance(&foot,"Column"), T, L );
#endif
		dst = KLgetDistance ( &foot, NAM_KPJ_TDIST );
		if (dst >= 0.0) {
			strcpy ( (*Tran)[iT].pro, KL_P_TRAN );
			strcpy ( (*Tran)[iT].lin,
				 KLgetName ( &foot, NAM_KPJ_LNAM) );
			strcpy ( (*Tran)[iT].nam,
				 KLgetName ( &foot, NAM_KPJ_TNAM) );
			(*Tran)[iT].dst = dst;
			iT++;
		}
#ifdef TRACE
else	printf ( "\t<%s> has no TRANSVERSE\n", name );
#endif

		dst = KLgetDistance ( &foot, NAM_KPJ_LDIST );
		if (dst >= 0.0) {
			strcpy ( (*Long)[iL].pro, KL_P_LONG );
			strcpy ( (*Long)[iL].lin,
				 KLgetName ( &foot, NAM_KPJ_TNAM) );
			strcpy ( (*Long)[iL].nam,
				 KLgetName ( &foot, NAM_KPJ_LNAM) );
			(*Long)[iL].dst = dst;
			iL++;
		}
#ifdef TRACE
else	printf ( "\t<%s> has no LONGITUDINAL\n", name );
#endif

	}
	Info->numT = iT;
	Info->numL = iL;

	/* Sort data */
	qsort ( (*Tran), Info->numT, sizeof(VLkeyLineData),
		(int (*)())VLsortKLdata );
	qsort ( (*Long), Info->numL, sizeof(VLkeyLineData),
		(int (*)())VLsortKLdata );

	/* Eliminate duplicates */
	VLduplicateKLdata ( &(Info->numT), Tran );
	VLduplicateKLdata ( &(Info->numL), Long );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
void VLsprintfKLmatrix ( Info, Matrix, nRow, nCol, FileName, idx, TableName )

	VLkeyLineInfo   *Info;
	IGRchar		**Matrix;
	IGRint		nRow;
	IGRint		nCol;
	IGRchar		*FileName;
	IGRint		idx;
	IGRchar		*TableName;
{
	IGRchar		name[80];
	FILE		*pFile;
	time_t		cTime;
	IGRint		i, j;

	pFile = NULL;
        sprintf ( name, "%s%d%s", FileName, idx, ".txt" );
        pFile = fopen ( name, "w" );

        fprintf ( pFile, "\t\t\t\tKEY LINE\n" );
        fprintf ( pFile, "JOB NUMBER\t%s\t\tUNIT\t%s\n",
                          Info->jobN, Info->unit );
        time (&cTime);
        cftime ( name, "%D", &cTime );
        fprintf ( pFile, "DATE\t%s", name );
        cftime ( name, "%H:%M", &cTime );
        fprintf ( pFile, " %s\n", name );
        fprintf ( pFile, "NAME\t\tTABLE:\t%s\n\n", TableName );

        for ( i=0; i<nRow; i++ ) {
        	for ( j=0; j<nCol; j++ )
                	fprintf ( pFile, "%s\t", Matrix[j+i*nCol] );
                fprintf ( pFile, "\n" );
        }

        fclose (pFile);
        pFile = NULL;

	return;
}
/* ************************************************************************** */

end implementation VLabstract;
