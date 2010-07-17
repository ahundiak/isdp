/* $Id: VSplcJntCmdi.I,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSplcJntCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplcJntCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1997/12/19  06:10:52  pinnacle
# Replaced: vscmd/VSplcJntCmdi.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  12:16:26  pinnacle
# Replaced: vscmd/VSplcJntCmdi.I for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/

/*
	I/STRUCT
*/
class implementation VSplcJntCmd ;

#include <string.h>
#include "OMmacros.h"
#include "growner.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "VDScheckdef.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsoptdef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsnamemacros.h"
#include "vsmiscmacros.h"
#include "vsjntmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsdbgmacros.h"

from	VSfeature	import	VSputJoint ;
from	GRvg		import	GRgetname ;
from 	ACdb_info  	import  ACset_db_info ; 
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	locElmnts[2] ;	/* Located elements	*/
	struct GRvg_construct	cst ;		/* Construction list	*/
	VSpartAttr		jnPart ;	/* Part attr. (joint)	*/
	VSjointAttr		jointAttr ;	/* Attributes of joints	*/
	int			isWritable,	/* Is pwd writable ?	*/
				dirInModel ;	/* Pwd in active file ?	*/
	char			*jnDir ;	/* Directory for joint	*/
	struct GRid		actJnUA,	/* Act. usr attributes	*/
				joint ;		/* Created joint	*/
	GRname			jnPathName ;	/* Name of joint	*/
        struct ACdb_info        dbInfo ;        /* dbinfo               */

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg, 2, locElmnts ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Unhilite located objects.
	 */
	vs$bulk_display( count = 2, objenvs = locElmnts, dpmode = GRhe ) ;

	vs$cnstDefaults(	msg	= msg,
				symb_id	= me->ModuleInfo.md_id,
				symb	= &me->ActiveRep,
				matchKey= me->matchKey,
				matchId = &locElmnts[0]._grid,
				path	= me->Cwd,
				level	= &me->ActiveLevel,
				display	= &me->ActiveDisplay ) ;


	vs$fill_cnst_list(	Cnst_list	= cst,
				Msg		= msg,
				Env_info	= &me->cstEnv,
				Display		= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Class_attr	= &jnPart ) ;

	jnPart.specific	= (void *) &jointAttr ;
	jnPart.Iwant	= VS_m_All ;

	/*
	 * Get active joint attributes from the DPB.
	 */
	VSgetActNewJnAttr( msg, &jointAttr ) ;

	/*
	 * Get active collection of user-attributes for joints.
	 */
	vs$getActiveUsrAttr(	msg		= msg,
				basename	= VS_K_jointUA,
				p_activeUA	= &actJnUA ) ;

	if( IF_NULL_OBJID( actJnUA.objid ) ) {
		jnPart.Iwant	&= ~VS_m_UsrAttr ;
	} else {
		jnPart.usrAttr	= actJnUA ;
	}

	/*
	 * See if directory where joint will name itself is usable.
	 */
	vs$isDirUsable(	dirname	= me->Cwd,
			inModel	= &dirInModel,
			writable= &isWritable ) ;

	jnDir = dirInModel && isWritable ? me->Cwd : NULL ;

	sts = om$send(	msg	= message VSfeature.VSputJoint(
						msg,
						&locElmnts[0].mod_env,
						locElmnts + 1,
						NULL,
						me->ActiveRep.representation,
						&cst,
						jnDir,
						&joint ),
			targetid= locElmnts[0]._objid,
			targetos= locElmnts[0]._osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSputJoint", wrapup ) ;

	sts = om$send(	msg	= message GRvg.GRgetname( msg, jnPathName ),
			targetid= joint.objid,
			targetos= joint.osnum ) ;

	if( ( sts & 1 & *msg ) && *jnPathName ) {
		ex$message(	msgnumb	= VS_gI_CreatedObj,
				type	= "%s",
				var	= `jnPathName` ) ;
	}

	vs$bulk_display( grids = &joint, theEnv	= cst.env_info ) ;

	/* Put db info */
 	dbInfo.quantity   = VD_CKIN_STRUCT_JNT_OBJ;
 	sts = om$send(msg = message ACdb_info.ACset_db_info(msg,
								&dbInfo),
                 	targetid = joint.objid,
                 	targetos = joint.osnum);


	sts = OM_S_SUCCESS ; *msg = MSSUCC ;

	wrapup :

	if( !( sts & 1 & *msg ) ) {
		om$send(msg	= message VSpartopCmd.setErrorStatus( *msg, 2 ),
			targetid= my_id ) ;
		me->ret = VS_K_RESTART_CMD ;
	} else {
		me->ret = VS_K_ACT_SUCCESS ;
	}

	return OM_S_SUCCESS ;


} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSplcJntCmd ;
