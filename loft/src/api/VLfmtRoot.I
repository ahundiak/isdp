/* $Id: VLfmtRoot.I,v 1.1.1.1 2001/01/04 21:11:22 cvs Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:	src/api/VLfmtRoot.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLfmtRoot.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:22  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.1  1996/02/21  21:49:22  pinnacle
# Created: ./src/api/VLfmtRoot.I by azuurhou for loft
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			i-paris		creation date
 *
 ***************************************************************************/

class implementation VLabstract;

#include <stdio.h>
#include "vlprototype.h"
#include "OMerrordef.h"
#include "godef.h"
#include "msdef.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "expression.h"
#include "expmacros.h"
#include "asmacros.h"
#include "cotxmacros.h"
#include "fontdef.h"
#include "fontmacros.h"
#include "grmessage.h"
#include "csmacros.h"
#include "macro.h"
#include "parametric.h"
#include "vlglinedef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "vlPtools.h"
#include "vlAPImacros.h"

from	ACrg_collect	import	ACadd_list_attribute;
from	ACrg_collect	import	ACset_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;
from	ACrg_collect	import	AClist_attribute;

extern  GRclassid       OPP_VLbutLine_class_id;
extern	GRclassid		OPP_VLseaLine_class_id;
extern	GRclassid		OPP_VLwatLine_class_id;
extern	GRclassid		OPP_VLtrace_class_id;


extern  GRclassid		OPP_ACrg_collect_class_id;

extern  struct  GRid    NULL_GRID;


long VLformatAsRoot( struct GRid *objId, struct GRmd_env *objEnv, 
						struct GRid *asRoot, short curOs, short plug, char *plugTxt )
{
	long	sts;


	if( objId ){
		// make the source
		if( objEnv )
			sts = as$make_source( 	go_grid = *objId,
				               		mod_env = objEnv,
        	    	             	as_os   = curOs,
            	    	         	as_grid = asRoot );
		else
			sts = as$make_source( 	go_grid = *objId,
        	    	             	as_os   = curOs,
            	    	         	as_grid = asRoot );
	} 
	else if( plug ) {

		// create a plug
		asRoot->osnum = curOs;
		sts = exp$create(	exp_name = NULL,
                 			exp_syntax = plugTxt ? plugTxt : "Plug",
                 			p_exp_id = &(asRoot->objid),
                 			osnum = asRoot->osnum,
                 			type_rq = EXP_TEXT);

 		om$send(	msg	= message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
					senderid	= NULL_OBJID,
 					targetid = asRoot->objid,
 					targetos = asRoot->osnum );

	}
	else	sts = MSFAIL;

return sts;
}


/*-*/
long VLadd_mod_attribute( struct GRid *attBoxId, char *attName, double *attExp, char *attTxt )
{

	struct	ACrg_coll		ACrg;
 	long				sts, loc_msg;

	if( !attExp && !attTxt )	return	MSFAIL;

    	strcpy( ACrg.name,attName );
	if( attExp ){
    		ACrg.desc.type = AC_ATTRIB_DOUBLE;
    		ACrg.desc.value.att_exp = *attExp;
	} 
	else {
    		ACrg.desc.type = AC_ATTRIB_TEXT;
    		strcpy(ACrg.desc.value.att_txt, attTxt);
	}
	
	sts = om$send(	msg = message ACrg_collect.ACadd_list_attribute
							( &loc_msg, 1, &ACrg ),
					senderid = NULL_OBJID,
        	           		targetid = attBoxId->objid,
            	       		targetos = attBoxId->osnum );
	if(!(sts & loc_msg & 1)){ 	    	
		sts = om$send(	msg = message ACrg_collect.ACmod_list_attribute
							( &loc_msg, 1, &ACrg ),
					senderid = NULL_OBJID,
        	           		targetid = attBoxId->objid,
            	       		targetos = attBoxId->osnum );
	}
	if(!(sts & loc_msg & 1)){ return MSFAIL; }     	

return MSSUCC;
}

end implementation VLabstract;
