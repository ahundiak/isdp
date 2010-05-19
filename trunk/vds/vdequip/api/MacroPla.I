/* $Id: MacroPla.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/MacroPla.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: MacroPla.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/11/16  15:58:26  pinnacle
# Replaced: vdequip/api/MacroPla.I for:  by v241_int for vds.241
#
# Revision 1.1  1996/10/29  17:24:12  pinnacle
# Place Equipment API
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/19/96	i-paris		created
 *	11/16/96	mf		Corrected Error Management.
 *
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"exdef.h"
#include	"ex.h"
#include	"igrdp.h"
#include	"gr.h"
#include	"growner.h"
#include	"go.h"
#include	"griodef.h"
#include	"grio.h"
#include	"AS_status.h"
#include	"asmacros.h"
#include	"grmacros.h"
#include	"macro.h"
#include	"acrepdef.h"
#include	"acrepmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"nd.h"
#include	"nddef.h"
#include	"ndmacros.h"
#include	"msmacros.h"
#include	"parametric.h"
#include	"acdef.h"
#include	"acmacros.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"PDUerror.h"
#include	"ACdb_info.h"
#include	"expression.h"
#include	"expmacros.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"COmdef.h"
#include	"VDSutil.h"
#include	"VDScheckdef.h"
#include	"VDSpathdef.h"
#include	"VDSudp_mac.h"
#include	"v_miscmacros.h"
#include	"vdbmacros.h"
#include	"vdattmacros.h"

/*
#include	"VDapi.h"
*/

#include	"vdAPIequips.h"
#include	"vdmacprotos.h"

from	ACconst		import	ACmplace_from_def;
from	ACcpx		import	ACdrop;
from	ACexpand	import	ACmplace;
from	ACsym		import	ACmplace;
from	ci_macro	import	init;

extern	GRclassid	OPP_ACcond_def_class_id,
			OPP_ACmacro_defn_class_id,
			OPP_ci_mac_def_class_id;

extern	GRclassid	OPP_ACsym_class_id,
			OPP_ACconst_class_id,
			OPP_ACheader_class_id,
			OPP_ACexpand_class_id,
			OPP_ACci_header_class_id,
			OPP_nci_macro_class_id;

/* ************************************************************************** */
IGRlong	VDfillMacroTemplates (	IGRlong		*msg,
				IGRint		TplNum,
			struct	VDcollector	TplCol[],
			struct	GRid		**TplObj	)
{
	IGRlong		sts;
	IGRint		i;

	/* Initialize */
	sts  = OM_S_SUCCESS;
	*msg = MSFAIL;
	*TplObj = NULL;
	if (TplNum <= 0)	goto wrapup;

	/* Allocate memory */
	*TplObj = om$calloc ( num = TplNum, structure = struct GRid );
        as$status ( sts    = sts,
                    msg    = "om$calloc()",
                    test   = ( (*TplObj) == NULL),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Expand and make source in collector */
	sts = VDexpCollector ( msg, TplNum, TplCol );
	as$status ( sts	   = sts,
		    msg	   = "VDexpCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	sts = VDmakCollector ( msg, TplNum, TplCol );
	as$status ( sts	   = sts,
		    msg	   = "VDmakCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Loop on VDcollector */
	for ( i=0; i<TplNum; i++ ) {
		sts = vd$collectorGetRow ( msg = msg,
					   idx = i,
					   Col = TplCol,
					   Obj = &(*TplObj)[i] );
		as$status ( sts	   = sts,
			    msg	   = "vd$collectorGetRow(Obj i)",
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
IGRlong	VDplaceMacroOccurence (		IGRlong		*msg,
					IGRint		TplNum,
				struct	GRid		TplObj[],
				struct	GRmd_env	*Env,
				struct	VDdescriptor	*Desc,
				struct	GRsymbology	*symb,
					IGRchar		*DirPath,
					IGRchar		*RootName,
					IGRint		prop,
				struct	GRid		*OccId	)
{
	IGRint		i, sts=OM_S_SUCCESS, cst, suc;
	IGRlong		loc;
	IGRchar		rep, Name[DI_PATH_MAX];
struct	GRid		Nul, tmpId;
struct	NDcp_struct	cp_info;


	/* Initialize */
	OccId->objid = Nul.objid = tmpId.objid = NULL_OBJID;
	OccId->osnum = Nul.osnum = tmpId.osnum = Env->md_id.osnum;
	cp_info.list = NULL;
	Desc->prop |= prop;
	rep  = AC_NO_REP;
	cst = (Desc->MacTyp * 16) | Desc->HdrTyp;

	/* Construct and place macro occurence */
	switch (cst) {

	case sym_sym:
		sts = om$construct ( classid = OPP_ACsym_class_id,
				     osnum   = OccId->osnum,
				     p_objid = &OccId->objid );
		as$status ( sts	   = sts,
			    msg	   = "om$construct(ACsym)",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );
		sts = om$send ( msg = message ACsym.ACmplace
			( &suc, Desc->prop, Desc->MacNam, TplNum, TplObj, Env ),
				senderid = NULL_OBJID,
				targetid = OccId->objid,
				targetos = OccId->osnum );
		*msg = suc;
		as$status ( sts	   = sts,
			    msg	   = "ACsym.ACmplace",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
		break;

	case exp_cons:
	case exp_symb:
	case exp_grap:
		if ( (cst == exp_cons) || (cst == exp_grap) ) {
			sts = om$construct ( classid = OPP_ACconst_class_id,
					     osnum   = OccId->osnum,
					     p_objid = &OccId->objid );
			as$status ( sts	   = sts,
				    msg	   = "om$construct(ACconst)",
				    test   = (!(sts & 0x00000001)),
				    action = GOTO_VALUE,
				    value  = wrapup );
			}
		else {	sts = om$construct ( classid = OPP_ACheader_class_id,
					     osnum   = OccId->osnum,
					     p_objid = &OccId->objid );
			as$status ( sts	   = sts,
				    msg	   = "om$construct(ACheader)",
				    test   = (!(sts & 0x00000001)),
				    action = GOTO_VALUE,
				    value  = wrapup );
			}
		sts = om$send ( msg = message ACconst.ACmplace_from_def
	( &suc, Desc->prop, rep, Desc->MacNam, TplNum, TplObj, &Nul, Env ),
				senderid = NULL_OBJID,
				targetid = OccId->objid,
				targetos = OccId->osnum );
		*msg = suc;
		as$status ( sts	   = sts,
			    msg	   = "ACconst.ACmplace_from_def",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
		break;

	case exp_drop:
		sts = om$construct ( classid = OPP_ACexpand_class_id,
				     osnum   = OccId->osnum,
				     p_objid = &OccId->objid );
		as$status ( sts	   = sts,
			    msg	   = "om$construct(ACexpand)",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );
		sts = om$send ( msg = message ACexpand.ACmplace
		( &suc, 0, Desc->MacNam, TplNum, TplObj, &cp_info, Env ),
				senderid = NULL_OBJID,
				targetid = OccId->objid,
				targetos = OccId->osnum );
		*msg = suc;
		as$status ( sts	   = sts,
			    msg	   = "ACexpand.ACmplace",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
		break;

	case ci_sym:
		sts = om$construct ( classid = OPP_ACci_header_class_id,
				     osnum   = OccId->osnum,
				     p_objid = &OccId->objid );
		as$status ( sts	   = sts,
			    msg	   = "om$construct(ACci_header)",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );
		sts = om$send ( msg = message ACconst.ACmplace_from_def
	( &suc, Desc->prop, rep, Desc->MacNam, TplNum, TplObj, &Nul, Env ),
				senderid = NULL_OBJID,
				targetid = OccId->objid,
				targetos = OccId->osnum );
		*msg = suc;
		as$status ( sts	   = sts,
			    msg	   = "ACconst.ACmplace_from_def",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
		break;

	case ci_cons:
	case ci_grap:
		sts = om$construct ( classid = OPP_nci_macro_class_id,
				     osnum   = OccId->osnum,
				     p_objid = &OccId->objid );
		as$status ( sts	   = sts,
			    msg	   = "om$construct(nci_macro)",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );
		sts = om$send ( msg = message ci_macro.init
		( &suc, Desc->prop, Desc->MacNam, TplNum, TplObj, 0, Env ),
				senderid = NULL_OBJID,
				targetid = OccId->objid,
				targetos = OccId->osnum );
		*msg = suc;
		as$status ( sts	   = sts,
			    msg	   = "ci_macro.init",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
		break;

	default:
printf( "VDplaceMacroOccurence() unknown combination macro_type=%d, Htyp=%d\n",
	Desc->MacTyp, Desc->HdrTyp );
			
	}

	/* Change symbology & properties of macro occurence */
	if (Desc->HdrTyp != HDR_DROP) {
		if (Desc->HdrSym)
			COmchg_var_symb ( Desc->HdrSym, OccId, symb->level,
					  &symb->display_attr, Env );
		if (!(Desc->prop & AChdr_norange)) {
			sts = gr$display_object ( object_id = OccId,
						  md_env    = Env );
			as$status ( sts	   = sts,
				    msg	   = "gr$display_object()",
				    test   = (!(sts & 0x00000001)),
				    action = GOTO_VALUE,
				    value  = wrapup );
		}
	}
	if (Desc->HdrTyp == HDR_GRAPHIC) {
		sts = om$send ( msg = message ACcpx.ACdrop ( Env ),
				senderid = NULL_OBJID,
				targetid = OccId->objid,
				targetos = OccId->osnum );
		as$status ( sts	   = sts,
			    msg	   = "ACcpx.ACdrop",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}
	else if (Desc->HdrTyp == HDR_DROP) {

		for ( i=0; i<cp_info.nb_obj; i++ ) {
			if (!(cp_info.list[i].position & ND_BODY))
				continue;
			tmpId.objid = cp_info.list[i].clone;
			if (Desc->HdrSym)
				COmchg_var_symb ( Desc->HdrSym, &tmpId,
						  symb->level,
						  &symb->display_attr, Env );
			sts = gr$display_object ( object_id = &tmpId,
						  md_env    = Env );
			as$status ( sts	   = sts,
				    msg	   = "gr$display_object",
				    test   = (!(sts & 0x00000001)),
				    action = GOTO_VALUE,
				    value  = wrapup );
		}

		if (cp_info.list != NULL) {
			om$dealloc (ptr = cp_info.list);
			 cp_info.list = NULL;
		}

		sts = om$send ( msg = message ACcpx.ACdrop ( Env ),
				senderid = NULL_OBJID,
				targetid = OccId->objid,
				targetos = OccId->osnum );
		as$status ( sts	   = sts,
			    msg	   = "ACcpx.ACdrop",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Name occurence */
	if (RootName == NULL)	strcpy ( Name, Desc->MacNam );
	else			strcpy ( Name, RootName );
	sts = VDincrementalName ( msg, OccId, DirPath, Name );
	as$status ( sts	   = sts,
		    msg	   = "VDincrementalName",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:
	/* Delete macro occurence if something fails */
	if (!(sts & 0x00000001 & (*msg)))
		sts = gr$delete_object ( msg       = &loc,
					 md_env    = Env,
					 object_id = OccId );

	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDplaceMacro (		IGRlong		*msg,
				IGRint		TplNum,
			struct	VDcollector	TplCol[],
			struct	VDdescriptor	*Desc,
				IGRchar		*DirPath,
				IGRchar		*RootName,
				IGRint		prop,
			struct	GRobj_env	*OccId	)
{
	IGRlong		sts=OM_S_SUCCESS;
struct	GRid		*TplObj;
struct	GRsymbology	symbology;

	/* Initialize */
	TplObj  = NULL;
	*msg = MSFAIL;

	/* Check entries */
	if ( (TplNum > 0) && (TplCol == NULL) )	goto wrapup;

	/* Fill templates array */
	sts = VDfillMacroTemplates ( msg, TplNum, TplCol, &TplObj );
	as$status ( sts	   = sts,
		    msg	   = "VDfillMacroTemplates()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Check templates types */
	sts = VDchkCollector ( msg, TplNum, TplCol );
	as$status ( sts	   = sts,
		    msg	   = "VDchkCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get active symbology */
	ASget_active_symb ( &symbology.level, &symbology.display_attr );

	/* Construct and place macro occurence */
	sts = VDplaceMacroOccurence ( msg, TplNum, TplObj, &OccId->mod_env,
				      Desc, &symbology, DirPath, RootName, prop,
				      &OccId->obj_id );
	as$status ( sts	   = sts,
		    msg	   = "VDplaceMacroOccurence()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:
	if (TplObj) {      om$dealloc (ptr = TplObj);         TplObj  = NULL;    }
	return (sts);
}
/* ************************************************************************** */

end implementation Root;
