/* $Id: MacroDef.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/MacroDef.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: MacroDef.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
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
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/19/96	i-paris		created
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
#include	"macro.h"
#include	"acdef.h"
#include	"acmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"ACrg_collect.h"
#include	"msmacros.h"
#include	"nddef.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"VDSpathdef.h"
#include	"VDSutil.h"
#include	"v_miscmacros.h"

#include	"vdAPIequips.h"
#include	"vdmacprotos.h"

from	ACcpx		import	find_macro;
from	ACmacro_defn	import	ACgive_temp_desc, ACgive_upscan;
from	NDnode		import	NDget_objects;

extern	GRclassid	OPP_ACcond_def_class_id,
			OPP_ci_mac_def_class_id;

/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetMacroDefinition (		IGRlong		*msg,
					IGRchar		*MacLib,
					IGRchar		MacDef[],
					GRspacenum	ActiveOS,
				struct	VDdescriptor	*Desc	)
{
	IGRlong		sts;
	IGRchar		name[DI_PATH_MAX];
	
	/* Set msg to error */
	*msg  = MSFAIL;

	/* Attach macro library */
	if (MacLib != NULL) {
		sts = ac$construct_path ( mode = AC_ADD_PATH, name = MacLib );
		as$status ( sts	   = sts,
			    msg	   = "ac$construct_path()",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Define relative or absolute macro definition name */
	if (MacLib != NULL) {
		/* Get active file name */
		sts = di$give_pathname ( osnum = ActiveOS, pathname = name );
		as$status ( sts	   = sts,
			    msg	   = "di$translate(MACRO DEFINITION)",
			    test   = (sts != DIR_S_SUCCESS),
			    action = GOTO_VALUE,
			    value  = wrapup );
		sprintf ( name,
			  "%s:constructs_lib:%s:constructs:%s",
			  name, MacLib, MacDef );
	}
	else	strcpy ( name, MacDef );

	/* Get macro definition ID */
	sts = ac$find_macro_defn ( action	   = ACfind_load,
				   macro_name	   = name,
				   p_macro_defn_id = &Desc->MacDef );
	as$status ( sts	   = sts,
		    msg	   = "ac$find_macro_defn()",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set msg to success */
	if (MacLib != NULL)	strcpy ( Desc->MacLib, MacLib );
	strcpy ( Desc->MacNam, MacDef );

	/* Fill output descriptor (if needed) */
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetMacroDescription (		IGRlong		*msg,
					IGRchar		*MacLib,
					IGRchar		MacDef[],
					GRspacenum	ActiveOS,
				enum	ACm_poss_hdr	Htyp,
				struct	VDdescriptor	*Desc	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		Tmax=0;
struct	sup		*xdup;
	
	/* Initialize */
	*msg = MSFAIL;
	if (Desc == NULL)	goto wrapup;
	Desc->HdrSym = 0;
	Desc->HdrTyp = HDR_CONS;
	xdup         = NULL;

	/* Get macro definition */
	sts = VDgetMacroDefinition ( msg, MacLib, MacDef, ActiveOS, Desc );
	as$status ( sts	   = sts,
		    msg	   = "VDgetMacroDefinition",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set msg to error */
	*msg = MSFAIL;

	/* Get macro properties */
	sts = om$send ( msg = message ACmacro_defn.ACgive_upscan
					( &Tmax, &Desc->prop, &xdup ),
			senderid = NULL_OBJID,
			targetid = Desc->MacDef.objid,
			targetos = Desc->MacDef.osnum );
	as$status ( sts	   = sts,
		    msg	   = "ACmacro_defn.ACgive_upscan",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Not place conditional macro in drop mode */
	if (vd_$is_ancestry_valid ( object  = &Desc->MacDef,
				    classid = OPP_ACcond_def_class_id ) ) {
ex$message ( field   = ERROR_FIELD,
	     in_buff = "Conditional Macro can't be placed in DROP mode" );
		Desc->prop |= ACno_drop;
	}

	/* Define macro type */
	Desc->MacTyp = mac_exp;
	if (vd_$is_ancestry_valid ( object  = &Desc->MacDef,
				    classid = OPP_ci_mac_def_class_id ) ) {
		Desc->MacTyp = mac_ci;
		if ( (Htyp != HDR_CONS) && (Htyp != HDR_SYMB) ) {
ex$message ( field   = ERROR_FIELD,
	     in_buff = "CI Macro is placed in CONSTRUCTION mode" );
			Desc->HdrTyp = HDR_CONS;
		}
	}
	else if (Desc->prop & ACcant_place_sym) {
		Desc->MacTyp = mac_exp;
		if ( (Desc->prop & ACno_symbol) && (Htyp == HDR_SYMB) ) {
ex$message ( field   = ERROR_FIELD,
	     in_buff = "Macro is placed in CONSTRUCTION mode" );
			Desc->HdrTyp = HDR_CONS;
		}
		if ( (Desc->prop & ACno_construct) && (Htyp == HDR_CONS) ) {
ex$message ( field   = ERROR_FIELD,
	     in_buff = "Macro is placed in DROP mode" );
			Desc->HdrTyp = HDR_DROP;
		}
		if ( (Desc->prop & ACno_drop) && (Htyp == HDR_DROP) ) {
ex$message ( field   = ERROR_FIELD,
	     in_buff = "Macro is placed in DROP mode" );
			Desc->HdrTyp = HDR_CONS;
		}
	}
	else {	Desc->MacTyp = mac_sym;
		Desc->HdrTyp = HDR_SYMB;
	}

	/* Set msg to success */
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetTemplDescription (		IGRlong		*msg,
					IGRchar		*MacLib,
					IGRchar		MacDef[],
					GRspacenum	ActiveOS,
					IGRint		*num,
				struct	stemp		**stp	)
{
	IGRlong		sts=OM_S_SUCCESS;
struct	VDdescriptor	desc;
	
	/* Initialize */
	*num = 0;
	*stp = NULL;

	/* Get macro definition */
	sts = VDgetMacroDefinition ( msg, MacLib, MacDef, ActiveOS, &desc );
	as$status ( sts	   = sts,
		    msg	   = "VDgetMacroDefinition",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve templates description (if needed) */
	*msg = MSFAIL;
	sts = om$send ( msg = message ACmacro_defn.ACgive_temp_desc
					( num, stp ),
			senderid = NULL_OBJID,
			targetid = desc.MacDef.objid,
			targetos = desc.MacDef.osnum );
	as$status ( sts	   = sts,
		    msg	   = "ACmacro_defn.ACgive_temp_desc",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetCollectorFromMacroDef (		IGRlong		*msg,
						IGRchar		*MacLib,
						IGRchar		*MacDef,
						IGRint		*TplNum,
					struct	VDcollector	**TplCol )
{
	IGRlong		sts=OM_S_SUCCESS, siz=sizeof(struct GRmd_env), ret;
struct	GRmd_env	Env;
	IGRint		i, num=0;
struct	stemp		*stp;

	/* Initialize */
	stp  = NULL;
	*msg = MSFAIL;

	/* Check entry */
	if ( (MacDef == NULL) || (MacDef[0] == '\0') )	goto wrapup;
	if ( (TplNum == NULL) && (TplCol == NULL) )	goto wrapup;

	/* Get current environment */
	sts = gr$get_module_env ( msg    = msg,
				  sizbuf = &siz,
				  buffer = &Env,
				  nret   = &ret );
	as$status ( sts	   = sts,
		    msg	   = "gr$get_module_env()",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get template description */
	sts = VDgetTemplDescription ( msg, MacLib, MacDef, Env.md_id.osnum,
				      &num, &stp );
	as$status ( sts	   = sts,
		    msg	   = "VDgetTemplDescription()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set templates collector (if needed) */
	if (TplNum != NULL) {

		*TplNum = num;

		/* Construct templates' collector */
		sts = vd$collectorConstruct ( msg = msg,
					      Num = *TplNum,
					      Col = TplCol );
		as$status ( sts	   = sts,
			    msg	   = "vd$collectorConstruct()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Set templates' collector */
		for ( i=0; i<*TplNum; i++ ) {
			sts = vd$collectorSetRow ( msg = msg,
						   idx = i,
						   Col = (*TplCol),
						   Nam = stp[i].name,
						   Typ = &stp[i].type );
			as$status ( sts	   = sts,
				    msg	   = "vd$collectorSetRow(Nam i)",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
		}
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDgetCollectorFromMacroOcc (		IGRlong		*msg,
					struct	VDcollector	*OccCol,
						IGRint		*TplNum,
					struct	VDcollector	**TplCol )
{
	IGRlong		sts=OM_S_SUCCESS, siz=sizeof(struct GRmd_env), ret;
struct	GRmd_env	Env;
struct	GRid		OccId, DefId, *TplId;
struct	stemp		*stp;
	IGRint		i, num=0;

	/* Initialize */
	*TplNum  = 0;
	*TplCol  = NULL;
	TplId    = NULL;
	stp      = NULL;

	/* Get current environment */
	sts = gr$get_module_env ( msg    = msg,
				  sizbuf = &siz,
				  buffer = &Env,
				  nret   = &ret );
	as$status ( sts	   = sts,
		    msg	   = "gr$get_module_env()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set default values */
	OccId.objid = DefId.objid = NULL_OBJID;
	OccId.osnum = DefId.osnum = Env.md_id.osnum;

	/* Expand input collector */
	sts = VDexpCollector ( msg, 1, OccCol );
	as$status ( sts	   = sts,
		    msg	   = "VDexpCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get occurence ID */
	sts = vd$collectorGetRow ( msg = msg,
				   idx = 0,
				   Col = OccCol,
				   Obj = &OccId );
	as$status ( sts	   = sts,
		    msg	   = "vd$collectorGetRow(Obj 0)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get definition ID */
	sts = om$send ( msg = message ACcpx.find_macro ( &DefId ),
			senderid = NULL_OBJID,
			targetid = OccId.objid,
			targetos = OccId.osnum );
	as$status ( sts	   = sts,
		    msg	   = "ACcpx.find_macro",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve templates description */
        sts = om$send ( msg = message ACmacro_defn.ACgive_temp_desc
                                        ( &num, &stp ),
                        senderid = NULL_OBJID,
                        targetid = DefId.objid,
                        targetos = DefId.osnum );
        as$status ( sts    = sts,
                    msg    = "ACmacro_defn.ACgive_temp_desc",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory */
	TplId = om$calloc ( num = num, structure = struct GRid );

	/* Get templates ID */
	sts = om$send ( msg = message NDnode.NDget_objects
			( ND_ROOT, TplId, num, NULL, 0, num, TplNum ),
			senderid = NULL_OBJID,
			targetid = OccId.objid,
			targetos = OccId.osnum );
	as$status ( sts	   = sts,
		    msg	   = "NDnode.NDget_objects",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Allocate memory for output VDcollector */
	if ( (*TplNum) > num ) {
		*TplNum = 0;
		*msg = MSFAIL;
		goto wrapup;
	}
	else {	sts = vd$collectorConstruct ( msg = msg,
					      Num = *TplNum,
					      Col = TplCol );
		as$status ( sts	   = sts,
			    msg	   = "vd$collectorConstruct()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Fill output VDcollector */
	for ( i=0; i<*TplNum; i++ ) {
		sts = vd$collectorSetRow ( msg = msg,
					   idx = i,
					   Col = *TplCol,
					   Nam = stp[i].name,
					   Obj = &TplId[i],
					   Env = &Env,
					   Typ = &stp[i].type );
		as$status ( sts	   = sts,
			    msg	   = "vd$collectorSetRow(Nam,Obj,Env i)",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* ID to Collector */
	sts = VDexpCollector ( msg, *TplNum, *TplCol );
	as$status ( sts	   = sts,
		    msg	   = "VDexpCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:
	if (TplId) {	om$dealloc (ptr = TplId);	TplId = NULL;	}
	return (sts);
}
/* ************************************************************************** */

end implementation Root;
