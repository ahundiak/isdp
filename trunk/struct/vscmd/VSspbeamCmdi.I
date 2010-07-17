/* $Id: VSspbeamCmdi.I,v 1.1.1.1 2001/01/04 21:10:27 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:	vscmd/VSspbeamCmdi.I
 *
 * Description: Split Beam By Points
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSspbeamCmdi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:27  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/21  18:59:08  pinnacle
# TR179702512
#
# Revision 1.3  1997/12/19  06:11:44  pinnacle
# Replaced: vscmd/VSspbeamCmdi.I for:  by svkadamb for struct
#
# Revision 1.2  1997/06/16  18:56:06  pinnacle
# TR179700969
#
 *
 * History:
 *	MM/DD/YY   AUTHOR  DESCRIPTION
 *	06/16/97   ah	   added header
 *	06/16/97   ah	   TR179700969 Web Reference Points
 *      01/21/98   ah	   TR179700969 Cardinal Point 
 *      01/21/98   ah      TR179702512 Web Alignment Problem
 *************************************************************************/

class implementation VSspbeamCmd ;

#include <limits.h>
#include <string.h>
#include <stdio.h>
#include <FI.h>
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsbeam.h"
#include "vsoptdef.h"
#include "vsjoint.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsglobalmsg.h"
#include "vsnamemacros.h"
#include "vsmiscmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsdbgmacros.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
/*
 * Includes of function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsgrenvproto.h"
#include "vsnameproto.h"

#define CMD_NAME_TEXT 11
#define AUTOJN_TOGGLE 13

from GRvg		import	GRgetname,
				GRgetattr ;
from GRgraphics		import	GRconstruct ;
from VSdivFeature	import	VSget_sub_features ;
from ACncpx             import  ACget_STATE;

extern OMuword		OPP_VSsubBeam_class_id ;
extern void		VSfitNamesInString() ;

extern long VSbeamGetState(struct GRid *beamId, int *state);

/*----------------------------------------------------------------------------*/
method status_disp() {

	char	*form = me->status_display_form_ptr ;

	FIg_set_text( form, CMD_NAME_TEXT, me->msg ) ;
	FIg_set_state( form, AUTOJN_TOGGLE, me->autoJoin ) ;

	return om$send(	msg	= message VSpartopCmd.status_disp(),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

} /* method status_disp */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	int	rc ;
	long	msg ;
	double	JnPlcMode ;

  	switch( gadget_label ) {
		case FI_ACCEPT		:
			FIg_set_state_off( form_ptr, gadget_label ) ;
			om$send(msg	= message CEO.erase_form_by_label(
							form_label, 0, &rc ),
				targetid= my_id ) ;
			break ;

		case AUTOJN_TOGGLE	:
			me->autoJoin	= (int) value ;
			JnPlcMode	= value ;
			vs$putDpbCollAttr(	msg	= &msg,
						name	= VS_K_dpbActJnPlcMode,
						value	= &JnPlcMode ) ;
			msg = me->autoJoin ? VS_gI_JnOn : VS_gI_JnOff ;
			ex$message(	msgnumb		= msg,
					field		= ERROR_FIELD,
					justification	= CENTER_JUS ) ;
			break ;
	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method setJoiningAction( int ja ) {

	me->joiningAction = ja ;

	return OM_S_SUCCESS ;

} /* method setJoiningAction */
/*----------------------------------------------------------------------------*/
method dspAutoJoinMode() {

	long	msg ;
	double	JnPlcMode ;

	vs$getDpbCollAttr(	msg	= &msg,
				name	= VS_K_dpbActJnPlcMode,
				p_value	= &JnPlcMode ) ;
	if( !( msg & 1 ) ) JnPlcMode = 0 ;

	/*
	 * Intentional '=' and not '==' below.
	 */
	msg = ( me->autoJoin = JnPlcMode )	? VS_gI_JnOnStsFm
						: VS_gI_JnOffStsFm ;
	ex$message(	msgnumb		= msg,
			field		= ERROR_FIELD,
			justification	= CENTER_JUS ) ;

	return OM_S_SUCCESS ;

} /* method dspAutoJoinMode */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

#define MAX 10
	long			sts ;		/* OM return code	*/
	struct GRobj_env	*locObjs,	/* List of located objs	*/
				parents[MAX] ;	/* List of parents	*/
	struct GRvg_construct	cst ;		/* Construction list	*/
	struct VScnst_list	attr ;		/* VS construction args	*/
	VSpartAttr		bmPart,		/* Part attr. (beam)	*/
				jnPart ;	/* Part attr. (joint)	*/
	VSbeamAttr		beam ;		/* Beam attributes	*/
	VSdivArgs		dvargs ;	/* Division information	*/
	VSjoinInfo		jnInfo ;	/* Joining information	*/
	char			name[DI_PATH_MAX] ;
						/* Sub-beam #1's name	*/
	struct GRid		subBeam[VS_K_MAX_SUBS] ;
						/* List of sub-beams	*/
	int 			i,		/* Loop index		*/
				j,		/* Loop index		*/
				count,
				nbLocObjs,	/* Nb of located objs	*/
				isWritable,	/* Is pwd writable ?	*/
				dirInModel ;	/* Pwd in active file ?	*/
#define MAX_ABBRV	17
	char			info[MAX_ABBRV*3+10] ;
	VSjointAttr		jointAttr ;	/* Attributes of joints	*/

	locObjs = NULL ;

	if( me->oprtrCount < me->minOprtr ) {
		*msg = VS_K_NEED_OP ;
		return OM_S_SUCCESS ;
	} else if( me->oprtrCount > MAX - 1 ) {
		*msg = VS_K_TOO_MANY_OPS ;
		return OM_S_SUCCESS ;
	}

	nbLocObjs = me->oprtrCount + me->oprndCount ;

	if( !( locObjs = _MALLOC( nbLocObjs, struct GRobj_env ) ) ) {
		sts = OM_E_NODYNMEM ; goto wrapup ;
	}

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
						msg, nbLocObjs, locObjs ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Copy operators to parents buffer.
	 */
	for( j = 1, i = me->oprndCount ; i < nbLocObjs ; i++ ) {
		parents[j++] = locObjs[i] ;
	}

	/*
	 * Unhilite and erase operators if requested.
	 */
	if( !( me->partOpFlags & VS_m_POnoOperatorErase ) ) {
		vs$bulk_display(	count	= me->oprtrCount,
					objenvs = locObjs + me->oprndCount,
					dpmode	= GRbehe ) ;
	}

	/*
	 * Loop on beams.
	 */
	for( i = 0 ; i < me->oprndCount ; i++ ) {

	parents[0] = locObjs[i] ;

	/*
	 * Fill construction list, do not specify the display parameters
	 * since object will take its parent part's.
	 */
	vs$fill_cnst_list(	Cnst_list	= cst,
				Msg		= msg,
				Env_info	= &me->cstEnv,
				Display		= NULL,
				Level		= 0,
				Name		= name,
				Class_attr	= &attr ) ;

	attr.parent_count	= 1 + me->oprtrCount ;
	attr.parent_list	= parents ;
	attr.feature_att	= (char *) &dvargs ;
	dvargs.subFeatureAttr	= (void *) &bmPart ;
	dvargs.subFeatureClassid= OPP_VSsubBeam_class_id ;
	dvargs.divInfo		= (void *) &jnInfo ;

	/*
	 * Get directories for possible sub-joints, created if the operand
	 * beam was joined to other features, so they can name themselves
	 * automatically. If, say, the operand beam was joined to another
	 * plate P, the resultant sub-beams must rejoin themselves to P
	 * after the operand beam has been divided.
	 */
	di$pwd( dirname = me->Cwd ) ;

	if( me->autoJoin ) {
		struct GRid	actJnUA ;

		/*
		 * Moreover, the user wants the sub-beams to be joined
		 * either together or to the operator of the division.
		 */
		jnPart.Iwant		= VS_m_All ;
		jnPart.specific		= (void *) &jointAttr ;
		jnInfo.action		= me->joiningAction ;

		/*
		 * Get active joint attributes from the DPB.
		 */
		VSgetActNewJnAttr( msg, &jointAttr ) ;

		/*
		 * Get active collection of user-attributes for joints, if any.
		 */
		vs$getActiveUsrAttr(	msg		= msg,
					basename	= VS_K_jointUA,
					p_activeUA	= &actJnUA ) ;

		if( IF_NULL_OBJID( actJnUA.objid ) ) {
			jnPart.Iwant	&= ~VS_m_UsrAttr ;
		} else {
			jnPart.usrAttr	= actJnUA ;
		}

		vs$cnstDefaults(
				msg	= msg,
				symb_id	= me->ModuleInfo.md_id,
				symb	= &me->ActiveRep,
				matchKey= "joint",
				matchId	= &parents[0]._grid,
				path	= me->Cwd,
				level	= &me->ActiveLevel,
				display	= &me->ActiveDisplay ) ;

		/*
		 * NOTE : the new joints will use `jnInfo.dir' also to name
		 * themselves automatically. We can have either one or two
		 * new joints produced:
		 * - 1 if both resultant sub-beams are joined together by their
		 *   ends.
		 *		-----------(joint)---------
		 *
		 * - 2 if each of the sub-beams is joined to a side of the
		 *   divisor operator plate.
		 *
		 *				 ||
		 *		----------(joint)||(joint)---------
		 *				 ||
		 *
		 * We give both new joints the same construction list.
		 */
		vs$fill_cnst_list(	Cnst_list	= jnInfo.cst[0],
					Msg		= msg,
					Env_info	= &me->cstEnv,
					Display		= &me->ActiveDisplay,
					Level		= me->ActiveLevel,
					Class_attr	= &jnPart ) ;
		jnInfo.cst[1] = jnInfo.cst[0] ;
		jnInfo.rep[0] = jnInfo.rep[1] = me->ActiveRep.representation ;
	} else {
		dvargs.divInfo		= (void *) &jnInfo ;
		jnInfo.action		= VS_K_DO_NOT_JOIN ;
	}

	/*
	 * Checks that directory for joint is `usable'.
	 */	
	vs$isDirUsable(	dirname	= me->Cwd,
			inModel	= &dirInModel,
			writable= &isWritable ) ;

	jnInfo.dir = dirInModel && isWritable ? me->Cwd : NULL ;

	/*
	 * Note: sub-beams will take their parent's rep.
	 */
	attr.representation	= AC_NO_REP ;
	bmPart.Iwant		= VS_m_All ;
	bmPart.specific		= (void *) &beam ;

/* ################################################## */
/* TR179700969 Maintain proper web surface            */
/* TR179700969
 * TR179702512 
 * Take origin and cardinal point into account.
 * I am not sure if this method ever gets called for non-src beams
 * But if it does, then we are covered
*/
  {	
    int state  = 0;

    VSbeamGetState(&parents[0].obj_id,&state);
    if( state & VS_m_NdState )  bmPart.Iwant &= ~VS_m_detCard;
  }
/* ################################################### */

	/*
	 * The attributes will be taken by sub-beam #1. We put the
	 * same as those of parent beam.
	 */
	sts = om$send(	msg	= message GRvg.GRgetattr(
						msg, (char *) &bmPart ),
			targetid= parents[0]._objid,
			targetos= parents[0]._osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Sub-beam #0 will have parent's name, generate a name for
	 * sub-beam #1.
	 */
	sts = om$send(	msg	= message GRvg.GRgetname( msg, name ),
			targetid= parents[0]._objid,
			targetos= parents[0]._osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( *name ) {
		char	save[DI_PATH_MAX] ;

		strcpy( save, name ) ;
		VSbuildNameInSameDirIfPossible(	me->ModuleInfo._MD_OS,
						parents[0]._osnum,
						save,
						NULL,
						name ) ;

		VSfitNamesInString( MAX_ABBRV, save, save, name, info ) ;
	}

	/*
	 * Unhilite and erase operand beam.
	 */
	vs$bulk_display(count = 1, objenvs = parents, dpmode = GRbehe );

	/*
	 * Construct object.
	 */
	me->constructedObject.osnum = me->cstEnv._MD_OS ;

	sts = om$construct(
			classname= me->const_class,
			osnum	 = me->cstEnv._MD_OS,
			p_objid	 = &me->constructedObject.objid,
			msg	 = message GRgraphics.GRconstruct( &cst ) ) ;
	if( !( sts & 1 & *msg ) ) {
		/*
		 * Go on with next beam.
		 */
		vs$bulk_display( objenvs = locObjs + j, dpmode = GRbd ) ;
		om$send(msg	= message VSpartopCmd.setErrorStatus( *msg, 2 ),
			targetid= my_id ) ;
		continue ;
	}

	/*
	 * Retrieve sub-beams then display them.
	 */
	sts = om$send(	msg	= message VSdivFeature.VSget_sub_features(
							msg, &count, subBeam ),
			targetid= me->constructedObject.objid,
			targetos= me->constructedObject.osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

/* ############################################ */
/* Verify webState                              */
#ifdef WEB_DBG
  {
    int webState;
    webState = 0;
    sts = om$send(msg = message ACncpx.ACget_STATE(&webState),
				targetid= subBeam[0].objid,
				targetos= subBeam[0].osnum ) ;

    if( webState & VS_m_NdState ) { printf("1st subBeam TRUE\n"); }
    else                          { printf("1st subBeam FALSE\n");}

    webState = 0;
    sts = om$send(msg = message ACncpx.ACget_STATE(&webState),
				targetid= subBeam[1].objid,
				targetos= subBeam[1].osnum ) ;

    if( webState & VS_m_NdState ) { printf("2nd subBeam TRUE\n"); }
    else                          { printf("2nd subBeam FALSE\n");}
  }
#endif
/* ############################################### */

	vs$bulk_display(count	= 2,
			grids	= subBeam,
			theEnv	= &me->cstEnv,
			dpmode	= GRbd ) ;
	if( *name ) {
		int	field ;

		/*
		 * If we have several operand beams, write to the
		 * keyin field so further processing won't erase what
		 * has just been written; else routinely write to the
		 * error field.
		 */
		field = me->oprndCount == 1 ? ERROR_FIELD : KEYIN_FIELD ;

		ex$message(	in_buff		= info,
				justification	= CENTER_JUS,
				field		= field ) ;
		VS_Wait_timer( 100 ) ;
	}

	} /* End of loop on beams */

	/*
	 * Redisplay operators if requested.
	 */
	if( !( me->partOpFlags & VS_m_POnoOperatorErase ) ) {
		vs$bulk_display(	count	= me->oprtrCount,
					objenvs = locObjs + me->oprndCount,
					dpmode	= GRbd ) ;
	}

	sts = OM_S_SUCCESS ; *msg = MSSUCC ;

	wrapup :

		if( !( sts & 1 & *msg ) )	me->ret = VS_K_RESTART_CMD ;
		else				me->ret = VS_K_ACT_SUCCESS ;
		_FREE( locObjs ) ;

	return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSspbeamCmd ;
