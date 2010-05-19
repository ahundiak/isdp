/* $Id: Collector.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/Collector.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: Collector.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/10/12  21:34:48  pinnacle
# tr179900817
#
# Revision 1.2  1999/07/23  14:53:36  pinnacle
# tr179900746
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/10/29  17:24:12  pinnacle
# Place Equipment API
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	10/19/96   i-paris	created
 *	07/13/99   adz		Expressions were being created in transient
 *				object space (space #1). Now obtain current
 *				environment in function, VDexpCollRow.
 *                              Done for tr179900746
 *	08/20/99   ejm		TR179900817: Added NDchg_state for expression
 *				objects so that they will delete themselves
 *				if the macro they belong to is deleted.
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include	<string.h>
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"OMprimitives.h"
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"msdef.h"
#include	"AS_status.h"
#include	"DIdef.h"
#include	"gr.h"
#include	"igrdp.h"
#include	"go.h"
#include	"growner.h"
#include	"grdpbdef.h"
#include	"exmacros.h"
#include	"grdpbmacros.h"
#include	"asmacros.h"
#include	"macro.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"nddef.h"

#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"

#include	"VDSpathdef.h"
#include	"VDSutil.h"
#include	"VDSudp_mac.h"

#include	"vdAPIequips.h"
#include	"vdmacprotos.h"

//#define		vdsDEBUG  1
#include	"v_dbgmacros.h"

from	GRgraphics	import	GRgetname;
from	NDnode		import	NDgive_structure, NDchg_state;

IGRlong	VDcstCollRow (		IGRlong		*msg,
			struct	VDcollector	*Col	)
{
	IGRlong		sts=OM_S_SUCCESS, siz=sizeof(struct GRmd_env), ret;

	/* Initialize */
	*msg = MSFAIL;

	/* Check collector */
	if (Col == NULL)	goto wrapup;

	/* Initialize Collector */
	Col->name[0]		= '\0';
	Col->prop		= VD_COL_INIT;
	Col->txt[0]		= '\0';
	Col->val		= 0.0;
	Col->obj.obj_id.objid	= NULL_OBJID;
	Col->typ		= -1;
	Col->lst.w_count	= 0;
	Col->lst.w_flags	= OM_CLST_subclass;
	Col->lst.p_classes	= NULL;

	/* Get current environment */
	sts = gr$get_module_env ( msg    = msg,
				  sizbuf = &siz,
				  buffer = &Col->obj.mod_env,
				  nret   = &ret );
	as$status ( sts    = sts,
		    msg    = "gr$get_module_env()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set current environment in Collector */
	Col->obj.obj_id.osnum	= Col->obj.mod_env.md_id.osnum;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDcstCollector (	IGRlong		*msg,
				IGRint		cnt,
			struct	VDcollector	**Col	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;

	/* Initialize */
	*msg = MSFAIL;

	/* Check entry */
	if ( (Col == NULL) || (*Col != NULL) )	goto wrapup;
	if (cnt <= 0) 				goto wrapup;

	/* Allocate memory */
	*Col = om$calloc ( num = cnt, structure = struct VDcollector );
	if (*Col == NULL)	goto wrapup;

	/* Initialize each collector row */
	for ( i=0; i<cnt; i++ ) {
		sts = VDcstCollRow ( msg, &(*Col)[i] );
		as$status ( sts    = sts,
			    msg    = "VDcstCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetCollRow (		IGRlong		*msg,
			struct	VDcollector	*Col,
				IGRchar		*Nam,
			struct	GRid		*Obj,
			struct	GRmd_env	*Env,
				IGRdouble	*Val,
				IGRchar		*Txt,
			struct	OM_sd_classlist	**Cla,
				IGRboolean	public	)
{
	IGRlong		sts=OM_S_SUCCESS;

	/* Initialize */
	*msg = MSFAIL;

	/* Check access */
	if ( (public == TRUE) && (!(Col->prop & VD_COL_FREE)) )
		goto wrapup;

	/* Get NAME (if needed) */
	if ( (Nam != NULL) && (Col->name[0] != '\0') )
		strcpy ( Nam, Col->name );

	/* Get OBJID (if needed) */
	if ( (Obj != NULL) && (Col->prop & VD_COL_OBJID) )
		*Obj = Col->obj.obj_id;

	/* Get MDENV (if needed) */
	if ( (Env != NULL) && (Col->prop & VD_COL_MDENV) )
		*Env = Col->obj.mod_env;

	/* Get VALUE (if needed) */
	if ( (Val != NULL) && (Col->prop & VD_COL_VALUE) )
		*Val = Col->val;

	/* Get TEXT (if needed) */
	if ( (Txt != NULL) && (Col->prop & VD_COL_TEXT) )
		strcpy ( Txt, Col->txt );

	/* Get CLASS (if needed) */
	if (  (Cla != NULL) && (Col->prop & VD_COL_CLASS) )
		*Cla = &(Col->lst);

	/* Set success flag */
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetCollector (	IGRlong		*msg,
				IGRint		idx,
			struct	VDcollector	*Col,
				IGRchar		*Nam,
			struct	GRid		*Obj,
			struct	GRmd_env	*Env,
				IGRdouble	*Val,
				IGRchar		*Txt,
			struct	OM_sd_classlist	**Cla,
				IGRboolean	public	)
{
	IGRlong		sts=OM_S_SUCCESS;

	/* Initialize */
	*msg = MSFAIL;

	/* Check collector */
	if (Col == NULL)	goto wrapup;

	/* Access to idx collector data */
	sts = VDgetCollRow ( msg, &Col[idx],
			     Nam, Obj, Env, Val, Txt, Cla, public );
	as$status ( sts    = sts,
		    msg    = "VDgetCollRow()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
void	VDgetClassID (		IGRchar		*nam,
			struct	VDcollector	*Col	)
{
	OMuword		clid=0;
	IGRint		i;
	IGRboolean	Add=TRUE;

	/* Check entries */
	if ( (nam == NULL) || (Col == NULL) || (Col->lst.p_classes == NULL) )
		return;

	/* Get classid matching to "nam" */
	om$get_classid ( classname = nam, p_classid = &clid );

	/* Did we already got it ? */
	for ( i=0; i<Col->lst.w_count; i++ ) {
		if (Col->lst.p_classes[i] == clid) {
			Add = FALSE;
			break;
		}
	}

	/* Add it if needed */
	if (Add == TRUE) {
		Col->lst.p_classes[Col->lst.w_count] = clid;
		(Col->lst.w_count)++;
	}
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDtypeToClass (		IGRlong		*msg,
			struct	VDcollector	*Col	)
{
	IGRlong		sts=OM_S_SUCCESS;

	/* Initialize */
	*msg = MSFAIL;

	/* Check entry */
	if (!(Col->prop & VD_COL_TYPE))	goto wrapup;

	/* Allocate memory */
	Col->lst.p_classes = om$calloc ( num = 12, structure = OMuword );

	/* Convert type into eligible class */
	if	(Col->typ & macro_generic)
		VDgetClassID ( "ACcpx", Col );
	else if (Col->typ & class_generic)
		VDgetClassID ( "text_exp", Col );
	else {	if (Col->typ & line_generic)
			VDgetClassID ( "GRlineseg", Col );
		if (Col->typ & point_generic)
			VDgetClassID ( "GRpoint", Col );
		if (Col->typ & conic_generic)
			VDgetClassID ( "GRconic", Col );
		if (Col->typ & curve_generic)
			VDgetClassID ( "GRcurve", Col );
		if (Col->typ & parameter_generic) {
			if	(Col->typ == double_type)
				VDgetClassID ( "expression", Col );
			else if (Col->typ == text_type)
				VDgetClassID ( "text_exp", Col );
			else {	VDgetClassID ( "expression", Col );
				VDgetClassID ( "text_exp", Col );	}
		}
		if (Col->typ & lbs_generic)
			VDgetClassID ( "GRlbsys", Col );
		if (Col->typ & ref_generic)
			VDgetClassID ( "GRgencs", Col );
		if (Col->typ & debug_type)
			VDgetClassID ( "GRplanar", Col );
		if (Col->typ & other_generic)
			VDgetClassID ( "GRgraphics", Col );
	}

	/* Set success flag */
	Col->prop |= VD_COL_CLASS;
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDsetCollRow (		IGRlong		*msg,
			struct	VDcollector	*Col,
				IGRchar		*Nam,
			struct	GRid		*Obj,
			struct	GRmd_env	*Env,
				IGRdouble	*Val,
				IGRchar		*Txt,
				IGRint		*Typ,
				IGRboolean	public	)
{
	IGRlong		sts=OM_S_SUCCESS;

	/* Initialize */
	*msg = MSFAIL;

	/* Set NAME (if needed) */
	if (Nam != NULL) {
		if (strlen (Nam) < VD_COL_NAM_LEN) {
			strcpy ( Col->name, Nam );
		}
	}

	/* Set OBJID (if needed) */
	if (Obj != NULL) {
		Col->prop		|= VD_COL_OBJID;
		Col->obj.obj_id		= *Obj;
	}

	/* Set MDENV (if needed) */
	if (Env != NULL) {
		Col->prop		|= VD_COL_MDENV;
		Col->obj.mod_env	= *Env;
	}

	/* Set VALUE (if needed) */
	if (Val != NULL) {
		Col->prop		|= VD_COL_VALUE;
		Col->val		= *Val;
	}

	/* Set TEXT (if needed) */
	if (Txt != NULL) {
		if (strlen (Txt) < VD_COL_NAM_LEN) {
			Col->prop	|= VD_COL_TEXT;
			strcpy ( Col->txt, Txt );
		}
	}

	/* Set TYPE (if needed) */
	if (Typ != NULL) {
		Col->prop		|= VD_COL_TYPE;
		Col->typ		= *Typ;
		sts = VDtypeToClass ( msg, Col );
		as$status ( sts    = sts,
			    msg    = "VDtypeToClass()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Set access property */
	if (public == TRUE)	Col->prop |= VD_COL_FREE;

	/* Set success flag */
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDsetCollector (	IGRlong		*msg,
				IGRint		idx,
			struct	VDcollector	*Col,
				IGRchar		*Nam,
			struct	GRid		*Obj,
			struct	GRmd_env	*Env,
				IGRdouble	*Val,
				IGRchar		*Txt,
				IGRint		*Typ,
				IGRboolean	public	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRushort	prop=0;

	/* Initialize */
	*msg = MSFAIL;

	/* Check collector */
	if (Col == NULL)	goto wrapup;

	/* Access to idx collector data */
	sts = VDsetCollRow ( msg, &Col[idx],
			     Nam, Obj, Env, Val, Txt, Typ, public );
	as$status ( sts    = sts,
		    msg    = "VDsetCollRow()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Expand data */
	if (Obj)	prop |= VD_COL_OBJID;
	if (Env)	prop |= VD_COL_MDENV;
	if (Val)	prop |= VD_COL_VALUE;
	if (Txt)	prop |= VD_COL_TEXT;
	if (Typ)	prop |= VD_COL_TYPE;
	sts = VDexpCollRow ( msg, &Col[idx], prop );
	as$status ( sts    = sts,
		    msg    = "VDexpCollRow()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
void	VDoutCollRow (		IGRint		idx,
			struct	VDcollector	*Col,
				IGRboolean	public	)
{
	/* Print row */
	if (  (public == FALSE)
	   || ( (public == TRUE) && (Col->prop & VD_COL_FREE) ) ) {
		printf( "\tRow %2d <%s>", idx, Col->name );
		if (Col->prop & VD_COL_OBJID)
			printf( "\t[%d|%d]",
				Col->obj.obj_id.osnum,
				Col->obj.obj_id.objid );
		if (Col->prop & VD_COL_VALUE)
			printf( "\t%g", Col->val );
		if (Col->prop & VD_COL_TEXT)
			printf( "\t<%s>", Col->txt );
		if ( (public == FALSE) && (Col->prop & VD_COL_TYPE) )
			printf( "\ttype=0x%08x", Col->typ );
		printf ( "\n" );
	}
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDoutCollector (	IGRint		cnt,
			struct	VDcollector	*Col,
				IGRchar		*msg,
				IGRboolean	public	)
{
	IGRint	i;

	/* Check collector */
	if (Col == NULL)	return	MSFAIL;

	/* Print collector header */
	if ( (msg == NULL) || (msg[0] == '\0') )
		printf ( "\n\tCollector have %d rows\n", cnt );
	else	printf ( "\n%s\tCollector have %d rows\n", msg, cnt );

	/* Print collector rows */
	for ( i=0; i<cnt; i++ )	VDoutCollRow ( i, &Col[i], public );

	return OM_S_SUCCESS;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDenvCollector (	IGRint		idx,
			struct	VDcollector	*Col,
			struct	GRmd_env	*Env	)
{
	/* Check collector */
	if (Col == NULL)	return MSFAIL;
	else			*Env = Col[idx].obj.mod_env;

	return OM_S_SUCCESS;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDmakCollRow (		IGRlong		*msg,
			struct	VDcollector	*Col	)
{
	IGRlong		sts=OM_S_SUCCESS;
struct	GRobj_env	Obj;
struct	GRid		Src;

	/* Make source on OBJID with MDENV */
	if (Col->prop & VD_COL_OBJID) {

		/* Get MDENV */
		sts = VDgetCollRow ( msg, Col, NULL, NULL, &Obj.mod_env,
				     NULL, NULL, NULL, FALSE );
		if (!(sts & 0x00000001 & (*msg))) {
			sts = VDenvCollector ( 0, Col, &Obj.mod_env );
			as$status ( sts    = sts,
				    msg    = "VDenvCollector()",
				    test   = (!(sts & 0x00000001)),
				    action = GOTO_VALUE,
				    value  = wrapup );
			*msg = MSSUCC;
		}

		/* Get OBJID */
		sts = VDgetCollRow ( msg, Col, NULL, &Obj.obj_id, NULL,
				     NULL, NULL, NULL, FALSE );
		as$status ( sts    = sts,
			    msg    = "VDgetCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Make source */
		sts = as$make_source ( go_grid = Obj.obj_id,
				       mod_env = &Obj.mod_env,
				       as_grid = &Src );
		as$status ( sts    = sts,
			    msg    = "as$make_source()",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Copy source data in collector */
		sts = VDsetCollRow ( msg, Col, NULL, &Src, &Obj.mod_env,
				     NULL, NULL, NULL, FALSE );
		as$status ( sts    = sts,
			    msg    = "VDsetCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDmakCollector (	IGRlong		*msg,
				IGRint		cnt,
			struct	VDcollector	*Col	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;

	/* Initialize */
	*msg = MSFAIL;

	/* Check collector */
	if (Col == NULL)	goto wrapup;

	/* Loop on collector rows */
	for ( i=0; i<cnt; i++ ) {

		sts = VDmakCollRow ( msg, &Col[i] );
		as$status ( sts    = sts,
			    msg    = "VDmakCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDexpCollRow (		IGRlong		*msg,
			struct	VDcollector	*Col,
				IGRushort	prop	)
{
	IGRlong		sts=OM_S_SUCCESS;
struct	GRid		Objid;
struct	GRid		curId;  /* FIX */
	IGRchar		nam[DI_PATH_MAX], txt[DI_PATH_MAX];
	IGRint		idx=0;
	IGRdouble	val=0.0;

	SetProc( VDexpCollRow ); Begin

	/* Initialize */
	*msg = MSFAIL;

	ex$get_cur_mod( id = &curId.objid, osnum = &curId.osnum );
	__DBGpr_obj(" Current Object ", curId );

	/* From OBJID to TEXT */
	if ( (prop & VD_COL_OBJID) && (!(prop & VD_COL_TEXT)) ) {

		__DBGpr_com(" From OBJID to TEXT " );
		/* Get OBJID */
		sts = VDgetCollRow ( msg, Col, NULL, &Objid, NULL,
				     NULL, NULL, NULL, FALSE );
		as$status ( sts    = sts,
			    msg    = "VDgetCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Get OBJID name */
		nam[0] = '\0';
		txt[0] = '\0';
		sts = om$send ( msg = message GRgraphics.GRgetname ( msg, nam ),
				senderid = NULL_OBJID,
				targetid = Objid.objid,
				targetos = Objid.osnum );
		if ( (sts & 0x00000001 & (*msg)) && (nam[0] != '\0') ) {
			strcpy ( txt, &strrchr ( nam, ':')[1] );
			if (strlen(txt) < VD_COL_NAM_LEN) {
			sts = VDsetCollRow ( msg, Col, NULL, NULL, NULL, NULL,
					     txt, NULL, FALSE );
			as$status ( sts    = sts,
				    msg    = "VDsetCollRow()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
			}
		}
		else {	sts  = OM_S_SUCCESS;
			*msg = MSSUCC;	}
	}

	/* From TEXT to OBJID */
	if ( (prop & VD_COL_TEXT) && (!(prop & VD_COL_OBJID)) ) {

		__DBGpr_com(" From TEXT to OBJID " );
		/* Get TEXT */
		nam[0] = '\0';
		sts = VDgetCollRow ( msg, Col, NULL, NULL, NULL,
				     NULL, nam, NULL, FALSE );
		as$status ( sts    = sts,
			    msg    = "VDgetCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		__DBGpr_str(" name ", nam );

		/* Translate TEXT */
		Objid.objid = NULL_OBJID;
		sts = vds$translate ( objname = nam,
				      p_objid = &Objid.objid,
				      p_osnum = &Objid.osnum,
				      p_index = &idx );
		if ( (sts & 0x00000001) && (Objid.objid != NULL_OBJID) ) {
			__DBGpr_obj(" Add Object ", Objid );
			sts = VDsetCollRow ( msg, Col, NULL, &Objid, NULL, NULL,
					     NULL, NULL, FALSE );
			as$status ( sts    = sts,
				    msg    = "VDsetCollRow()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
		}
		else {
		  __DBGpr_com(" Create text expression ");

		  Objid.objid = NULL_OBJID;
		  sts = exp$create ( exp_syntax	= nam,
				   osnum        = curId.osnum,
				   exp_name	= NULL,
				   type_rq 	= EXP_TEXT,
			     	   p_exp_id	= &Objid.objid,
			     	   p_osnum	= &Objid.osnum	);
		  as$status ( sts    = sts,
			    msg    = "exp$create()",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );

		  /* State state for expression */
		  sts = om$send ( msg = message NDnode.NDchg_state
			( ND_DEL_NO_CH|ND_WAIT_DEL, ND_DEL_NO_CH|ND_WAIT_DEL ),
			senderid = NULL_OBJID,
			targetid = Objid.objid,
			targetos = Objid.osnum );

		  as$status ( sts    = sts,
			msg    = "NDnode.NDchg_state(expression,TEXT)",
			test   = (!(sts & 0x00000001)),
			action = GOTO_VALUE,
			value  = wrapup );

		  /* Set OBJID */
		  __DBGpr_obj(" Add New Object ", Objid );
		  sts = VDsetCollRow ( msg, Col, NULL, &Objid, NULL,
				     NULL, NULL, NULL, FALSE );
		  as$status ( sts    = sts,
			    msg    = "VDsetCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
		  *msg = MSSUCC;
		  sts = OM_S_SUCCESS ;
		}
	}

	/* From VALUE to OBJID */
	if ( (prop & VD_COL_VALUE) && (!(prop & VD_COL_OBJID)) ) {

		__DBGpr_com(" From VALUE to OBJID " );
		/* Get VALUE */
		sts = VDgetCollRow ( msg, Col, NULL, NULL, NULL,
				     &val, NULL, NULL, FALSE );
		as$status ( sts    = sts,
			    msg    = "VDgetCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Create expression */
		Objid.objid = NULL_OBJID;
		sts = exp$create ( exp_value	= val,
				   osnum        = curId.osnum,
			     	   p_exp_id	= &Objid.objid,
			     	   p_osnum	= &Objid.osnum	);
		as$status ( sts    = sts,
			    msg    = "exp$create()",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* State state for expression */
		sts = om$send ( msg = message NDnode.NDchg_state
			( ND_DEL_NO_CH|ND_WAIT_DEL, ND_DEL_NO_CH|ND_WAIT_DEL ),
			senderid = NULL_OBJID,
			targetid = Objid.objid,
			targetos = Objid.osnum );

		as$status ( sts    = sts,
			msg    = "NDnode.NDchg_state(expression,VALUE)",
			test   = (!(sts & 0x00000001)),
			action = GOTO_VALUE,
			value  = wrapup );

		/* Set OBJID */
		  __DBGpr_obj(" Add New Object ", Objid );
		sts = VDsetCollRow ( msg, Col, NULL, &Objid, NULL,
				     NULL, NULL, NULL, FALSE );
		as$status ( sts    = sts,
			    msg    = "VDsetCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	*msg = MSSUCC;

wrapup:
	End
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDexpCollector (	IGRlong		*msg,
				IGRint		cnt,
			struct	VDcollector	*Col	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;

	/* Initialize */
	*msg = MSFAIL;

	/* Check collector */
	if (Col == NULL)	goto wrapup;

	/* Expand collector rows */
	for ( i=0; i<cnt; i++ ) {

		sts = VDexpCollRow ( msg, &Col[i], Col[i].prop );
		as$status ( sts    = sts,
			    msg    = "VDexpCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDchkCollRow (		IGRlong		*msg,
			struct	VDcollector	*Col	)
{
	IGRlong		sts=OM_S_SUCCESS;
struct	GRobj_env	Obj;
struct	ret_struct	str;

	/* Initialize */
	*msg = MSFAIL;

	/* Something to check ? */
	if (Col->prop & VD_COL_TYPE) {
		if (Col->typ & other_generic) {
			*msg = MSSUCC;
			goto wrapup;
		}
	}
	else {	printf( "Error in VDchkCollRow() : prop = 0x%08x", Col->prop );
		goto wrapup;	}

	if (Col->prop & VD_COL_OBJID) {

		sts = VDgetCollRow ( msg, Col, NULL, &Obj.obj_id, &Obj.mod_env,
				     NULL, NULL, NULL, FALSE );
		as$status ( sts    = sts,
			    msg    = "VDchkCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		sts = om$send ( msg = message NDnode.NDgive_structure
					( msg, &str, &Obj.mod_env ),
				senderid = NULL_OBJID,
				targetid = Obj.obj_id.objid,
				targetos = Obj.obj_id.osnum );
		as$status ( sts    = sts,
			    msg    = "NDnode.NDgive_structure",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		if (!(str.type & Col->typ)) {
printf( "Error in VDchkCollRow() : def. type 0x%08x, tpl. type 0x%08x\n",
	Col->typ, str.type );
			goto wrapup;
		}
	}

	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDchkCollector (	IGRlong		*msg,
				IGRint		cnt,
			struct	VDcollector	*Col	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;

	/* Initialize */
	*msg = MSFAIL;

	/* Check collector */
	if (Col == NULL)	goto wrapup;

	/* Expand collector rows */
	for ( i=0; i<cnt; i++ ) {

		sts = VDchkCollRow ( msg, &Col[i] );
		as$status ( sts    = sts,
			    msg    = "VDchkCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */


end implementation Root;
