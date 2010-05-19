/* $Id: VDplcmacro.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vdmisc/VDplcmacro.I
 *
 * Description: Implementation for "Place Macro" macro.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDplcmacro.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/10/29  14:49:08  pinnacle
# Created: vdmisc/VDplcmacro.I by rchennup for vds
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/29/97   Rama Rao     File Creation
 *************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include "AS_status.h"
#include "acmacros.h"
#include "asmacros.h"

/* -------------------------- FCT VDplMacro () ------------------------	*/
/*	This function place a macro
/*	
/* */

long VDplMacro(
	char			*macName,	/* I  : Macro name            */
	char			*name,		/* I  : occurrence name	      */
	int			tplNb,		/* I  : number of template    */
	struct	GRobj_env	*tplList, 	/* I  : list of template      */
	struct	GRsymbology	*symb,		/* I  : symbology 	      */
	struct	GRid		*occId,		/* I  : exemple occurence     */
	GRclassid		classid,	/* I  : classid of macro      */
	short			props,		/* I  : placement props	      */
	short			rep,		/* I  : macro representation  */
	char			asState,	/* I  : Assoc properties          */
	struct	GRmd_env	*curMdEnv, 	/* I  : Placement environment */
	struct	GRid		*macId )	/* O  : Macro Id 	      */
{
long	sts, msg;
struct	GRid	mac, defId;
struct	GRid	macTemp[200];
int		i, int_msg;
struct	GRid	my_occ;

	/* Initialization */
	mac.objid	= NULL_OBJID;
	mac.osnum	= curMdEnv->md_id.osnum;
	my_occ.objid	= NULL_OBJID;

	// check id macroName is loaded
        defId.objid    = NULL_OBJID;
        sts = ac$find_macro_defn(       action          = ACfind_load,
                                        macro_name      = macName,
                                        p_macro_defn_id = &defId );
        if( ! (sts&1) || defId.objid == NULL_OBJID ){
		printf(" Macro placement fails : definition %s not loaded \n", 
								macName );
 		return	MSFAIL;
	}

	// get associative objects
	for( i=0; i<tplNb; i++ ){
	
		sts = 
		as$make_source(	go_grid	= tplList[i].obj_id,
				mod_env	= &tplList[i].mod_env,
				as_os	= curMdEnv->md_id.osnum,
				as_grid = &macTemp[i] );
		as$status( sts = sts );
		if( ! (sts&1)){
			printf(" Macro placement fails : can not get assoc on %d/%d\n",
				 tplList[i].obj_id.objid, tplList[i].obj_id.osnum );
			return	MSFAIL;
		}
	}

	// construct macro object
	sts = om$construct(	classid	= classid,
				p_objid = &mac.objid,
				osnum	= mac.osnum );
	as$status( sts = sts );

	// compute the macro
	
	sts = om$send(	msg	 = message ACncpx.ACmplace_from_def(
						&int_msg,
						props,
						(char) rep,
						macName,
						tplNb,
						macTemp,
						occId ? occId : &my_occ,
						curMdEnv ),
			senderid = NULL_OBJID,
			targetid = mac.objid,
			targetos = mac.osnum );
	if( ! (sts&int_msg&1)){
		om$send(	msg	 = message ACncpx.NDdelete(curMdEnv),
				senderid = NULL_OBJID,
				targetid = mac.objid,
				targetos = mac.osnum );
		return	MSFAIL;
	}

	// set assoc state
	sts = om$send(	msg	 = message NDnode.NDchg_state
					( asState , asState ),
			senderid = NULL_OBJID,
			targetid = mac.objid,
			targetos = mac.osnum );
	as$status( sts = sts );

	// set symbology
	if( symb ){
		sts = om$send(	msg	= message GRvg.GRputsymb
					( &msg, symb ),
				senderid = NULL_OBJID,
				targetid = mac.objid,
				targetos = mac.osnum );
		as$status( sts = sts );
	}

	// set name 
	if( name ){
		sts = om$send(	msg	= message GRgraphics.GRputname
						( &msg, name ),
				senderid = NULL_OBJID,
				targetid = mac.objid,
				targetos = mac.osnum );
		as$status( sts = sts );
	}

	if( macId )	*macId = mac;

return	MSSUCC;
}

end implementation VDSroot;
