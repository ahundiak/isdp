/* $Id: SMmakeLtdVol.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMmakeLtdVol.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMmakeLtdVol.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
/*  History :
/*	alc 29 Oct 92 Creation date
/*	    20 Jan 93 Temporary kludge because EMSsolid.EMorient_yourself()
/*	              is not working in some cases
/*	    08 Feb 93 Handle error case EMS_I_Fail
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

#include "EMSopt.h"
#include "msmacros.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"

extern	GRclassid	OPP_EMSsfstitch_class_id ;
extern	GRclassid	OPP_EMSslstitch_class_id ;

extern EFmksolid() ;

from GRgraphics import GRconstruct, GRdelete ;
from EMSsurface import EMgetactiveid, EMdisplay_edges ;
from EMSsfstitch import EMmake_comp, EMgetsolidclass ;
from EMSdpr import EMmake_primitive1 ;
from EMSsolid import EMorient_yourself ;

/*
	----------------------------------------------------------
 */


IGRlong SMmakeLtdVolume(msg, surf_list, num_surf, construct_list, volume)
   IGRlong 			*msg ;			/* O */
   GRobjid			*surf_list ;		/* I */
   IGRint			num_surf ;		/* I */
   struct GRvg_construct	*construct_list ;	/* I */
   struct GRid			*volume ;		/* O */

/*
   Description :

	Given a list of surfaces (properly defined) in the same object
	space (e.g. a copy has been done previously), a stitched surface
	is built, and then converted into a solid of class EMSslstitch.
	Then a compress tree is done.  The result is a free form solid 
	(EMSgensolid).

   Note : 

	The list of input surfaces is consumed by this operation in both 
	cases : success or failure (wad).
 */

{
IGRlong			status, SMmsg ;
struct GRid		aux_comp ; /* auxiliary object for construction */
struct GRid		active_id, top_lm_id ;
char			new_class[256] ;
IGRint			i ;
IGRboolean		stitchable ;
extern			sleep() ;
extern IGRboolean 	EFcomp_stitchable() ;
			/* defined in $MODEL/src_testco/imp/EFmksolid.I */


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
        } /* error case - Feb 93 */

/*
	Check closure 
 */

stitchable = EFcomp_stitchable(&SMmsg, aux_comp.objid, aux_comp.osnum,
                               construct_list->env_info, NULL, 0) ;
if (!(SMmsg & 1)) {
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = wrapup) ;
	}

if (stitchable) {
   /* There are stitchable edges */
   IGRint edge_count ;
   status = om$send(msg = message EMSsurface.EMdisplay_edges(&SMmsg, 
	construct_list->env_info, EMS_OPT_CONNECTABLE, GRhd, &edge_count),
                  senderid = NULL_OBJID,
                  targetid = aux_comp.objid,
                  targetos = aux_comp.osnum) ;
   as$status(action = GOTO_VALUE, value = wrapup) ;
   if (!(SMmsg & 1)) {
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = wrapup) ;
	}

   ex$message(msgnumb = EMS_S_ConnEdhilite);
   sleep(2);
   goto wrapup ; /* error case */
   }


/*
	Convert it into a solid (e.g. EMSslstitch)
 */

status = om$send(msg = message EMSsfstitch.EMgetsolidclass(&SMmsg, new_class),
		senderid = NULL_OBJID,
		targetid = aux_comp.objid,
		targetos = aux_comp.osnum) ; 
as$status(action = GOTO_VALUE, value = wrapup) ;
if (!(SMmsg & 1)) {
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = wrapup) ;
	}

status = om$change_class(	objid = aux_comp.objid,
                          	osnum = aux_comp.osnum,
                           	classname = new_class) ;
as$status(action = GOTO_VALUE, value = wrapup) ;

status = om$send(msg = message EMSsolid.EMorient_yourself
				(&SMmsg, NULL, construct_list->env_info),
		senderid = NULL_OBJID,
		targetid = aux_comp.objid,
		targetos = aux_comp.osnum) ; 

#if 0
	/* temporary 93/01/20 */
as$status(action = GOTO_VALUE, value = wrapup) ;
if (!(SMmsg & 1)) {
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = wrapup) ;
	}
#endif

if (!(status & SMmsg & 1)) {
	printf("Warning from EMSsolid.EMorient_yourself() \n") ;
	}


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
	Success : output volume
 */

	*volume = aux_comp ;
	*msg = MSSUCC ; 
	return OM_S_SUCCESS ;

/*
	Error case only : delete the constructed composite (it implies
	that the list of input surfaces will be also destroyed)
 */

wrapup:

	if (aux_comp.objid == NULL_OBJID) {
	   /* Delete the list of input surfaces */
	   for (i = 0 ; i < num_surf ; i ++) {
	      status = om$send(msg = message GRgraphics.GRdelete
			(&SMmsg, construct_list->env_info),
		senderid = NULL_OBJID,
		targetid = surf_list[i],
		targetos = construct_list->env_info->md_id.osnum) ; 
	      as$status() ;
	      }
	   }

	else {
	   /* Delete composite object */
	   status = om$send(msg = message GRgraphics.GRdelete
			(&SMmsg, construct_list->env_info),
		senderid = NULL_OBJID,
		targetid = aux_comp.objid,
		targetos = aux_comp.osnum) ; 
	   as$status() ;
	   }

	volume->objid = NULL_OBJID ;
 	*msg = MSFAIL ;
	return OM_E_ABORT ;

} /* function SMmakeLtdVolume() */


/*
	----------------------------------------------------------
 */


end implementation Root ;
 

