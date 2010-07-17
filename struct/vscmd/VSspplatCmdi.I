/* $Id: VSspplatCmdi.I,v 1.1.1.1 2001/01/04 21:10:28 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vscmd/VSspplatCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSspplatCmdi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/12/19  06:13:26  pinnacle
# Replaced: vscmd/VSspplatCmdi.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSspplatCmd ;

#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <FI.h>
#include "OMmacros.h"
#include "acrepdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsplate.h"
#include "vsoptdef.h"
#include "vsjoint.h"
#include "vsjntmacros.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsnamemacros.h"
#include "vsmiscmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsgrenvproto.h"
#include "vsioproto.h"
#include "vsnameproto.h"
#include "vsstrngproto.h"

#define CMD_NAME_TEXT 11
#define AUTOJN_TOGGLE 13

from GRvg		import	GRgetname,
				GRgetattr ;
from GRgraphics		import	GRconstruct ;
from VSdivFeature	import	VSget_sub_features ;
from NDmacro		import	ACreturn_foot ;
from ci_macro		import	init ;

extern OMuword		OPP_VSsubPlate_class_id ;
/*----------------------------------------------------------------------------*/
void VSfitNamesInString( nchars, before, after1, after2, buf )

int	nchars ;
char *before, *after1, *after2, *buf ; {

	int	lb	= strlen( before ),
		la1	= strlen( after1 ),
		la2	= strlen( after2 ),
		LB	= lb,
		LA1	= la1,
		LA2	= la2,
		total	= lb + la1 + la2,
		max	= nchars * 3 ;
	char	*b,
		*a1,
		*a2,
		newb [DI_PATH_MAX],
		newa1[DI_PATH_MAX],
		newa2[DI_PATH_MAX],
		unnamed[1+MS_MAX_MSG_LENGTH] ;

	ex$message( msgnumb = VS_gI_Unnamed, buff = unnamed ) ;
	if( !before || !*before ) before = unnamed ;
	if( !after1 || !*after1 ) after1 = unnamed ;
	if( !after2 || !*after2 ) after2 = unnamed ;

	while( total > max ) {
		     if( lb  > nchars ) lb--  ;
		else if( la1 > nchars ) la1-- ;
		else if( la2 > nchars ) la2-- ;
		total = lb + la1 + la2 ;
	}
	if( lb < LB ) {
		b = VSabbrvString( before, lb, newb ) ;
	} else	b = before ;

	if( la1 < LA1 ) {
		a1 = VSabbrvString( after1, la1, newa1 ) ;
	} else	a1 = after1 ;

	if( la2 < LA2 ) {
		a2 = VSabbrvString( after2, la2, newa2 ) ;
	} else	a2 = after2 ;

	sprintf( buf, "%s>%s,%s", b, a1, a2 ) ;

} /* VSfitNamesInString */
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
	 * In what follows it IS '=' not '=='.
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

	long			sts ;		/* OM return code	*/
	struct GRobj_env	*locObjs,	/* Located objects	*/
				parents[2] ;
	struct GRvg_construct	cst ;		/* Construction list	*/
	struct VScnst_list	attr ;		/* VS construction args	*/
	VSpartAttr		plPart,		/* Part attr. (plate)	*/
				jnPart ;	/* Part attr. (joint)	*/
	VSplateAttr		plate ;		/* Plate attributes	*/
	VSdivArgs		dvargs ;	/* Division information	*/
	VSjoinInfo		jnInfo ;	/* Joining information	*/
	char			name[DI_PATH_MAX];
						/* Sub-plate #1's name	*/
	struct GRid		subPlate[VS_K_MAX_SUBS] ;
						/* List of sub-plates	*/
	int 			i,		/* Loop index		*/
				j = 0,		/* Loop index		*/
				total,		/* Of located objects	*/
				isWritable,	/* Is pwd writable ?	*/
				dirInModel ;	/* Pwd in active file ?	*/

#define MAX_ABBRV	17
	char			info[MAX_ABBRV*3+10] ;
	VSjointAttr		jointAttr ;	/* Attributes of joints	*/

	if( me->oprtrCount < me->minOprtr ) {
		*msg = VS_K_NEED_OP ;
		return OM_S_SUCCESS ;
	}

	/*
	 * NOTE: me->oprtrCount is 1.
	 */
	total = me->oprndCount + me->oprtrCount ;

	if( !( locObjs = _MALLOC( total, struct GRobj_env ) ) ) {
		sts = VS_K_ABORT_CMD ; goto wrapup ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg, total, locObjs ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Unhilite located objects.
	 */
	vs$bulk_display(count = total, objenvs = locObjs, dpmode = GRbehe ) ;

	/*
	 * Loop on plates.
	 */
	for( j = 0 ; j < me->oprndCount ; j++ ) {

	parents[0] = locObjs[j] ;


	/*
	 * The last located object is the operator, all the others are the
	 * operands.
	 */
	parents[1] = locObjs[total-1] ;

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

	attr.parent_count	= 2 ;
	attr.parent_list	= parents ;
	attr.feature_att	= (char *) &dvargs ;
	/*
	 * We put the same the attributes of parent plate, they will be taken
	 * by sub-plates.
	 */
	dvargs.subFeatureAttr	= (void *) &plPart ;
	dvargs.subFeatureClassid= OPP_VSsubPlate_class_id ;
	dvargs.divInfo		= (void *) &jnInfo ;

	/*
	 * Get directories for possible sub-joints, created if the operand
	 * plate was joined to other features, so they can name themselves
	 * automatically. If, say, the operand plate was joined to another
	 * plate P, the resultant sub-plates must rejoin themselves to P
	 * after the operand plate has been divided.
	 */
	di$pwd( dirname = me->Cwd ) ;

	if( me->autoJoin ) {
		struct GRid	actJnUA ;

		/*
		 * Moreover, the user wants the sub-plates to be joined
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
		 * - 1 if both resultant sub-plates are joined together by their
		 *   edges.
		 *		-----------(joint)---------
		 *
		 * - 2 if each of the sub-plates is joined to a side of the
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

	if( dirInModel && isWritable ) {
		jnInfo.dir = me->Cwd ;
	} else {
		jnInfo.dir = NULL ;
	}
 
	/*
	 * Note: sub-plates will take their parent's rep.
	 */
	attr.representation	= AC_NO_REP ;

	plPart.Iwant	= VS_m_All ;
	plPart.specific	= (void *) &plate ;

	sts = om$send(	msg	= message GRvg.GRgetattr( msg,
							 (char *) &plPart ),
			targetid= parents[0]._objid,
			targetos= parents[0]._osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Sub-plate #0 will have parent's name, generate a name for sub-plate
	 * #1.
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
		 * Go on with next plate. Redisplay operand plate, erased
		 * by splitting process.
		 */
		vs$bulk_display( objenvs = locObjs + j, dpmode = GRbd ) ;

		om$send(msg	= message VSpartopCmd.setErrorStatus( *msg, 2 ),
			targetid= my_id ) ;
		continue ;
	}

	/*
	 * Retrieve sub-plates then display them.
	 */
	sts = om$send(	msg	= message VSdivFeature.VSget_sub_features(
							msg, &i, subPlate ),
			targetid= me->constructedObject.objid,
			targetos= me->constructedObject.osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	vs$bulk_display(count	= 2,
			grids	= subPlate,
			theEnv	= &me->cstEnv,
			dpmode	= GRbd ) ;

	/*
	 * Redisplay operator.
	 */
	vs$bulk_display( objenvs = parents + 1, dpmode = GRbd ) ;

	if( *name ) {
		ex$message(	in_buff		= info,
				justification	= CENTER_JUS,
				field		= ERROR_FIELD ) ;
		VS_Wait_timer( 100 ) ;
	}

	} /* End loop on plates */

	sts = OM_S_SUCCESS ; *msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) )	me->ret = VS_K_RESTART_CMD ;
		else				me->ret = VS_K_ACT_SUCCESS ;

		_FREE( locObjs ) ;

		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSspplatCmd ;
