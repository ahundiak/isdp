/* $Id: VDSmkCompSrf.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / VDSmkCompSrf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSmkCompSrf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  Filename :		VDSmkCompSrf.I
/*  Revision date :	92/11/06
/*  Author :		Alain CLAUDE
/*  Description :
/*	Implement VDmakeCompSrf() needed by the srf_comp ci_macro (associative
/*	composite surface)
/*
/*  Note :
/*	The previous release of srf_comp.u was doing a boolean union of 
/*	the located surfaces (which costed much more time for the same 
/*	result in simple cases), and was failing in making a composite
/*	from the 3 surfaces from John Mellen to produce the ship hull.
/*	
/*  History :
/*	06 Nov 92	Creation date
/*	08 Feb 93	Handle error case EMS_I_Fail
/* */

class implementation Root ;
   
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "OMmacros.h"
#include "grmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"

#include "msmacros.h"

extern	GRclassid	OPP_EMSsfstitch_class_id ;

from GRgraphics import GRconstruct, GRdelete ;
from EMSsurface import EMgetactiveid ;
from EMSsfstitch import EMmake_comp ;
from EMSdpr import EMmake_primitive1 ;


/*
	----------------------------------------------------------
 */


IGRlong VDmakeCompSrf(msg, surf_list, num_surf, construct_list, composite)
   IGRlong 			*msg ;			/* O */
   GRobjid			*surf_list ;		/* I */
   IGRint			num_surf ;		/* I */
   struct GRvg_construct	*construct_list ;	/* I */
   GRobjid			*composite ;		/* O */

/*
   Description :

	Given a list of surfaces (properly defined) in the same object
	space (e.g. a copy has been done previously), a stitched surface
	is built, and then a compress tree is done to create a surface.
 */

{
IGRlong			status, SMmsg ;
struct GRid		aux_comp ; /* auxiliary object for construction */
struct GRid		active_id, top_lm_id ;

/*
	Make a composite surface (e.g. EMSsfstitch)
 */

aux_comp.objid = NULL_OBJID ;	/* initialization to handle error cases */
aux_comp.osnum = construct_list->env_info->md_id.osnum ;
status = om$construct(	classid	= OPP_EMSsfstitch_class_id,
		p_objid	= &aux_comp.objid,
		osnum 	= aux_comp.osnum,
		msg 	= message GRgraphics.GRconstruct(construct_list)) ;
as$status(action = GOTO_VALUE, value = wrapup) ;

status = om$send(msg = message EMSsfstitch.EMmake_comp(
			&SMmsg,
			num_surf,
			surf_list,
			construct_list->env_info,
			NULL, NULL, NULL, NULL, NULL),
		senderid = NULL_OBJID,
		targetid = aux_comp.objid,
		targetos = aux_comp.osnum) ; 
as$status() ; if (! (status & 1)) SMmsg = EMS_I_Fail ;

if (SMmsg != EMS_S_Success) { /* because EMS_I_Fail is odd */

        /* Composite surface can not be made */
        if (SMmsg == EMS_I_Fail) { ex$message(msgnumb = EMS_I_00090) ; }
        else { status = OM_E_ABORT ; as$status() ; }

        goto wrapup ;
        } /* error case */

/*
	Compress state tree
 */

status = om$send(msg = message EMSsurface.EMgetactiveid
					(&SMmsg, &active_id, &top_lm_id),
		senderid = NULL_OBJID,
		targetid = aux_comp.objid,
		targetos = aux_comp.osnum) ; 
as$status(action = GOTO_VALUE, value = wrapup) ;
if (!(SMmsg & 1)) {
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = wrapup) ;
	}

status = om$send(msg = message EMSdpr.EMmake_primitive1
			(&SMmsg, construct_list->env_info, &aux_comp),
		senderid = NULL_OBJID,
		targetid = active_id.objid,
		targetos = active_id.osnum) ; 
as$status(action = GOTO_VALUE, value = wrapup) ;
if (!(SMmsg & 1)) {
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = wrapup) ;
	}

/*
	Success : output composite surface
 */

	*composite = aux_comp.objid ;
	*msg = MSSUCC ; 
	return OM_S_SUCCESS ;

/*
	Error case only : delete the constructed composite
 */

wrapup:

	if (aux_comp.objid != NULL_OBJID) {

		#ifdef DEBUG
		printf("Delete composite object \n") ;
		#endif

		status = om$send(msg = message GRgraphics.GRdelete
				(&SMmsg, construct_list->env_info),
			senderid = NULL_OBJID,
			targetid = aux_comp.objid,
			targetos = aux_comp.osnum) ; as$status() ;
		}

	*composite = NULL_OBJID ;
 	*msg = MSFAIL ;
	return OM_E_ABORT ;

} /* function VDSmakeCompSrf() */


/*
	----------------------------------------------------------
 */


end implementation Root ;
 

