/* ************************************************************************** */
/*			I/LOFT miscellaneous macros.			      */
/*									      */
/*	Marc FOURNIER : COC shipbuilding (Rungis, France)		      */
/*			created 	27-Sep-1994	MF		      */
/*			upgraded	28-Sep-1994	MF		      */
/* ************************************************************************** */

#ifndef vlmiscmacros_include
#define	vlmiscmacros_include

/* ************************************************************************** */
/*				Functions prototypes			      */
/* ************************************************************************** */

#include	"gr.h"
#include	"igrdp.h"
#include	"go.h"
#include	"macro.h"
#include	"dp.h"
#include	"nddef.h"
#include	"OMminimum.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VLmiscMacro.I */
IGRint VLreturn_foot		__((	IGRlong *msg,
					IGRchar *name,
					struct GRid *objId,
					struct GRmd_env *objEnv,
					struct GRid *footId,
					struct GRmd_env *footEnv));

IGRint VLconstPlaceNameState	__((		IGRlong		*msg,
						GRclassid	classid,
						IGRint		prop,
						IGRchar		rep,
						IGRchar		*MacName,
						IGRint		number,
					struct	GRid		*template,
					struct	GRmd_env	*Env,
						IGRboolean	ChgState,
						IGRchar		mask,
						IGRchar		state,
						IGRchar		*MatchKey,
						IGRchar		*CobName,
						OM_E_WRT_FLAG	mode,
					struct	GRid		*MatchId,
						IGRchar		*CommonName,
					enum	GRdpmode	dpmode,
						OM_S_OBJID	CobMyId,
					struct	GRid		*occ_id,
					struct	GRsymbology	*occ_symb,
						IGRchar		*occ_path ));

#if defined(__cplusplus)
}
#endif

/* ************************************************************************** */
/*				Macro : vl$return_foot ()		      */
/* ************************************************************************** */
/*
Abstract
	Encapsulate stupid NDmacro.ACreturn_foot message.

Arguments
	OUT		IGRlong		*msg	 	Completion code.
	IN		IGRchar		*name		Name of the foot wanted.
	IN	struct	GRid		*objId		Object of target.
	IN	struct	GRmd_env	*objEnv		Environ of target.
	OUT	struct	GRid		*footId	 	Object returned.
	OUT	struct	GRmd_env	*footEnv 	Environ returned.
*/

#omdef vl$return_foot (	msg,
			name = "",
			objId,
			objEnv = NULL,
			footId,
			footEnv = NULL )

	VLreturn_foot ( (msg),
			(name),
			(objId),
			(objEnv),
			(footId),
			(footEnv) )
#endomdef

/* ************************************************************************** */
/*				Macro : vl$placeLoftMacro ()		      */
/* ************************************************************************** */
/*
Abstract
	Construct, place and automaticaly name a macro occurence.

Arguments
OUT		IGRlong		*msg 		Completion code.
IN		GRclassid	classid		Class to construct.
IN		IGRint		prop		Properties for ACmplace.
IN		IGRchar		rep		Representation for ACmplace.
IN		IGRchar		*MacName	Macro def. name for ACmplace.
IN		IGRint		number		Templates number for ACmplace.
IN	struct	GRid		*template	Templates array for ACmplace.
IN	struct	GRmd_env	*Env		Enviroment for ACmplace.
IN		IGRboolean	ChgState	 Apply change state
IN		IGRchar		mask		1st argument for NDchg_state
IN		IGRchar		state		2nd argument for NDchg_state
IN		IGRchar		*MatchKey	Match key for VLsymbNameDir.
IN		IGRchar		*CobName	Classname of COB.
IN	enum	OM_e_wrt_flag	mode		Mode to send VLsymbNameDir msg.
IN	struct	GRid		*MatchId	Match ID for VLsymbNameDir.
IN		IGRchar		*CommonName	Common name for VLsymbNameDir.
IN		OM_S_OBJID	CobMyId		ID of subcmd of VLlocateCmd.S
IN	enum	GRdpmode	dpmode		Display mode for VLsymbNameDir.
OUT	struct	GRid		*occ_id		Resulting occurence ID.
OUT	struct	GRsymbology	*occ_symb	Resulting occurence symbology
OUT		IGRchar		*occ_path	Resulting occurence EMS path

	Note :	If (MacName) == NULL	just om$construct() is executed.
		If (Env)  == NULL	active environment is taken.
		If (ChgState) == TRUE	state is changed.
		If (MatchKey)  == NULL	name isn't modified by transTable.
		If (occ_id)  == NULL	no ID is returned.
		If (occ_symb)  == NULL	no symbology is returned.
		If (occ_path)  == NULL	no path is returned.
*/

#omdef	vl$placeLoftMacro (	msg,
				classid = NULL,
				prop = AChdr_noprotect | AChdr_nodisplay,
				rep  = '\0',
				MacName = NULL,
				number = 0,
				template = NULL,
				Env = NULL,
				ChgState = TRUE,
				mask = ND_DONT_MVRT,
				state = ND_DONT_MVRT,
				MatchKey = NULL,
				CobName = "VLlocateCmd",
				mode = OM_e_wrt_message,
				MatchId = NULL,
				CommonName = NULL,
				dpmode = GRbd,
				CobMyId = NULL,
				occ_id = NULL,
				occ_symb = NULL,
				occ_path = NULL )

	VLconstPlaceNameState (	(msg),
				(classid),
				(prop),
				(rep),
				(MacName),
				(number),
				(template),
				(Env),
				(ChgState),
				(mask),
				(state),
				(MatchKey),
				(CobName),
				(mode),
				(MatchId),
				(CommonName),
				(dpmode),
				(CobMyId),
				(occ_id),
				(occ_symb),
				(occ_path) )
#endomdef
/* ************************************************************************** */

#endif
