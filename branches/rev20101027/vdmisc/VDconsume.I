/*
	I/VDS	Copy
*/ 
class implementation VDSroot ;

#include <stdio.h>
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "EMSmsgdef.h"
/*
 * Includes of function prototypes.
 */
#include "v_virtualinf.h"

extern OMuword		OPP_ACpl_hold_class_id ;
/*----------------------------------------------------------------------------*/
static long VD_getConsumedFeet( consumedPart, env, count, list )

struct GRid	*consumedPart,
		list[] ;
struct GRmd_env	*env ;
int		count ; {

	long		sts ;
	int		i,
			total ;
	struct GRid	extraFoot ;

	for( i = 0 ; i < count ; i++ ) {
		sts = om$get_objid_at_index(	
				objid		= consumedPart->objid,
				osnum		= consumedPart->osnum,
				p_chanselect	= &AC_mto_graf_chns,
				index		= i,
				objidaddr	= &list[i].objid,
				osnumaddr	= &list[i].osnum ) ;
		if( !( sts & 1 ) ) {
			list[i].objid = NULL_OBJID ;
		}
	}
	/*
	 * Delete the extra feet -if any- which are not wanted, Note: we delete
	 * from the last one downwards since deleting them will collapse
	 * the owner-to-component channel.
	 */
	sts = om$get_channel_count(	objid		= consumedPart->objid,
					osnum		= consumedPart->osnum,
					p_chanselect	= &AC_mto_graf_chns,
					count		= (OMuint *) &total ) ;

	for( i = total - 1 ; i >= count ; i-- ) {
		extraFoot.objid = NULL_OBJID ;
		sts = om$get_objid_at_index(	
				objid		= consumedPart->objid,
				osnum		= consumedPart->osnum,
				p_chanselect	= &AC_mto_graf_chns,
				index		= i,
				objidaddr	= &extraFoot.objid,
				osnumaddr	= &extraFoot.osnum ) ;

		vd_$bulk_delete(	grids	= &extraFoot,
				theEnv	= env ) ;

	}
	return OM_S_SUCCESS ;

} /* VD_getConsumedFeet */
/*----------------------------------------------------------------------------*/
long VD_consume( msg, ParentPart, ftEnv, nbfeet, parentFeet, ParentEnv )

/*
  Abstract :
	Interface to ACconsume.
*/

long 		*msg;
struct GRid	*ParentPart ;
int		nbfeet ;
struct GRid	parentFeet[] ;
struct GRmd_env	*ftEnv,
		*ParentEnv ; {

	long		sts ;		/* OM return code	*/
	struct GRid	virtual,	/* Virtual parent	*/
			consumed_Part ;
	short		set,
			props ;
	int 		i ;
	struct GRmd_env	parentEnv ;

	VD_setGRids( -1, nbfeet, parentFeet ) ;

	/*
	 * Get parent's module environment (for undisplay).
	 */
	if( !ParentEnv ) ParentEnv = &parentEnv ;
	sts = VD_getVirtualInfo( msg, ParentPart, ParentEnv, &virtual ) ;
	__CheckRC( sts, *msg, "VD_getVirtualInfo", wrapup ) ;

	/*
	 * CAUTION ! ACconsume does not undisplay object !
	 */
	vd_$bulk_display(	grids	= ParentPart,
				theEnv	= ParentEnv,
				dpmode	= GRbe ) ;

	/*
	 * `ftEnv' is the environment where we want feet to live, NOT that of
	 * the consumed object.
	 */
	sts = om$send(	msg	= message NDmacro.ACconsume(
					msg, "", TRUE, &consumed_Part, ftEnv ),
			senderid= ParentPart->objid,
			targetid= ParentPart->objid,
			targetos= ParentPart->osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACconsume", wrapup ) ;

	/*
	 * We just got a root-copy of the object: strip it of its feet.
	 */
	VD_getConsumedFeet( &consumed_Part, ftEnv, nbfeet, parentFeet ) ;

	set = 0 ;
	props = GR_RIGID_RELATIONSHIP ;
	for( i = 0 ; i < nbfeet ; i++ ) {

		if( !IF_NULL_OBJID( parentFeet[i].objid ) ) {

			 if( vd_$is_ancestry_valid(
				classid	= OPP_ACpl_hold_class_id,
				object	= parentFeet + i ) ) {

				/*
				 * Get rid of filler ACpl_hold objects. Note
				 * that `vd_$bulk_delete' will set  parentFeet[i]
				 * to NULL_OBJID.
				 */
				vd_$bulk_delete(	grids	= parentFeet + i,
						theEnv	= ftEnv ) ;
			} else {
				sts = om$send(
					msg	= message GRgraphics.GRchgprops(
	 						msg, &set, &props ),
					senderid= parentFeet[i].objid,
					targetos= parentFeet[i].osnum,
					targetid= parentFeet[i].objid);
				__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;
			}
		}
	}
	/*
	 * We must use Root.delete here so components will not be deleted.
	 */
	sts = om$send(	msg	= message Root.delete( 0 ),
			senderid= consumed_Part.objid,
			targetos= consumed_Part.osnum,
			targetid= consumed_Part.objid ) ;
	__CheckRC( sts, 1, "Root.delete", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VD_consume */
/*----------------------------------------------------------------------------*/
long VD_unconsume( msg, parentId, parentEnv, parentRep, compute )

long		*msg ;
struct GRid	*parentId ;
struct GRmd_env	*parentEnv ;
VD_dspRep	parentRep ;
int		compute ; {

	long			sts ;
	struct GRid		virtual ;
	struct GRmd_env		venv ;

	if( parentRep != AC_NO_REP ) {
		/*
		 * Caution! Parent may be a pretend which does not understand
		 * ACput_NV_rep.
		 */
		sts = VD_getVirtualInfo( msg, parentId, &venv, &virtual ) ;
		__CheckRC( sts, *msg, "VD_getVirtualInfo", wrapup ) ;

		sts = om$send(	msg	= message ACncpx.ACput_NV_rep(
								parentRep ),
				senderid= virtual.objid,
				targetid= virtual.objid,
				targetos= virtual.osnum ) ;
		__CheckRC( sts, 1, "NDmacro.ACput_NV_rep", wrapup ) ;
	}

	sts = om$send(	msg	= message NDmacro.ACunconsume( msg, "" ),
			senderid= parentId->objid,
			targetid= parentId->objid,
			targetos= parentId->osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACunconsume", wrapup ) ;

	if( compute ) {

		sts = om$send(	msg	= message NDnode.NDs_compute_node(
							msg, 0, parentEnv ),
				senderid= parentId->objid,
				targetid= parentId->objid,
				targetos= parentId->osnum ) ;

	}
	wrapup :
		return sts ;

} /* VD_unconsume */
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
/* ACC bug : won't accept ANSI declaration with args inside and definition
   with args outside a la K&R C when an arg has type (unsigned) short: here
   myOs causes it to choke...
 */
long VD_fixIfNoRep(	VD_dspRep	myRep,
			OM_S_OBJID	myId,
			OMuword		myOs,
			struct GRid	*parentId,
			VD_dspRep	*myNewRep )
#else
long VD_fixIfNoRep( myRep, myId, myOs, parentId, myNewRep )

VD_dspRep	myRep,
		*myNewRep ;
OM_S_OBJID	myId ;
OMuword		myOs ;
struct GRid	*parentId ;
#endif

{

	long	sts ;

	if( myRep == AC_NO_REP ) {
		if( parentId ) {

		struct GRid	virtual ;
		long		rc ;

			/*
			 * CAUTION: real parent may be a pretend, get virtual
			 * one.
			 */
			sts = VD_getVirtualInfo( &rc, parentId, NULL, &virtual );
			__CheckRC( sts, rc, "VD_getVirtualInfo", wrapup ) ;

			sts = om$send(	msg	= message ACncpx.ACget_NV_rep(
								myNewRep ),
					mode	= OM_e_wrt_message,
					senderid= myId,
					targetid= virtual.objid,
					targetos= virtual.osnum ) ;
			__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

		} else {
			struct GRsymbology	esymb ;

			ac$get_def_rep(	prep	= myNewRep,
					esymb	= &esymb ) ;
		}

		sts = om$send(	msg	= message ACncpx.ACput_NV_rep(
								*myNewRep ),
				mode	= OM_e_wrt_message,
				senderid= myId,
				targetid= myId,
				targetos= myOs ) ;
	} else {
		*myNewRep = myRep ;
		sts = OM_S_SUCCESS ;
	}

	wrapup :
		return sts ;

} /* VD_fixIfNoRep */
/*----------------------------------------------------------------------------*/
		
end implementation VDSroot ;
