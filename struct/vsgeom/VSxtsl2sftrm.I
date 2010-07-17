/*
	I/STRUCT
*/
class implementation EMSsfsolid ;

#include <stdlib.h>
#include "OMmacros.h"
#include "msdef.h"
#include "EMSutlmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSsfparms.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "EMSsfintsort.h"
#include "emsbool.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"

extern OMuword		OPP_EMSproject_class_id,
			OPP_EMSprjcompsf_class_id,
			OPP_EMSsfsolid_class_id ;

from	EMSdpr		import	EMmake_primitive1 ;
/*----------------------------------------------------------------------------*/
long VSextend_sl_to_sf_and_trim(msg,
				prjSlEnv,
				prjSlId,
				begCapCv,
				trimSf,
				whichEnd,
				cst,
				compress,
				extSolid )

/*
 * Extends a solid to a surface and trims it against the surface.
 * The solid is expected to be an EMSsfsolid build on an EMSproject or
 * EMSprcompsf surface; the trimming surface is expected to be an EMSsubbs.
 * This function is interfaced by macro vs$extend_sl_to_sf_and_trim.
 */

long		*msg ;
struct GRmd_env	*prjSlEnv ;	/* Env. of solid of proj. to extend	*/
struct GRid	*prjSlId ;	/* Id of solid of proj. to extend	*/
struct GRobj_env*begCapCv,	/* Id of curve of begin cap		*/
		*trimSf ;
int		whichEnd ;	/* 0/1 : which end to extend and trim	*/
struct GRvg_construct
		*cst ;		/* Construction list for extended solid	*/
int		compress ;	/* Compress state tree ?		*/
struct GRid	*extSolid ; {	/* Extended solid			*/

	long			sts,		/* OM return code	*/
				rc ;
	struct EMSextend_info	extInfo ;	/* Extension info	*/
	struct EMsurface_params sfParams ;	/* Surface parameters	*/
	struct IGRbsp_curve	*bcapGeom ;	/* Geom. of begin cap	*/
	struct EMSsortpt_info	sortPts,	/* Sort points info	*/
				*badPts ;	/* From trimming	*/
	int			nbBadPts,	/* From trimming	*/
				count ;		/* Channel count	*/
	OM_S_CHANSELECT		toCmps ;
	OM_S_OBJECT_LINKAGE	ownedSf,	/* By input solid	*/
				newOwnerOL ;	/* Owner of trimming	*/
	struct GRid		newOwner,	/* Owner of trimming	*/
				prjSfId ;	/* Surface of proj.	*/

	bcapGeom = NULL ; extSolid->objid = NULL_OBJID ;

	switch( whichEnd ) {
		case 0 : extInfo.extension_type = EMSextend_begin_cap ; break ;
		case 1 : extInfo.extension_type = EMSextend_end_cap   ; break ;
		default: *msg = MSINARG ; sts = OM_E_INVARG ; goto wrapup ;
	}

	ems$make_chanselect( chan_label     = GRcmpowner_to_components,
			     chan_selector = &toCmps ) ;
	/*
	 * Get surface owned by EMSsfsolid -> EMSprjcompsf or EMSproject.
	 */
	*msg = EMS_E_OMerror ;
	sts = om$get_channel_objects(	
				objid		= prjSlId->objid,
				osnum		= prjSlId->osnum,
				p_chanselect	= &toCmps,
				size		= 1,
				list		= &ownedSf,
				count		= (OMuint *) &count ) ;
	__CheckRC( sts, 1, "om$get_channel_objects", wrapup ) ;

	prjSfId.objid	= ownedSf.S_objid ;
	prjSfId.osnum	= ownedSf.osnum ;
	
	if( vs$is_ancestry_valid(
				object	= &prjSfId,
				classid	= OPP_EMSprjcompsf_class_id ) ) {

		sts = om$send(	msg	= message EMSsurface.EMget_params(
							msg,
							NULL,
							prjSlEnv,
							NULL,
							&sfParams ),
				senderid	= prjSfId.objid,
				p_chanselect	= &toCmps,
				targetos	= prjSfId.osnum ) ;
		__CheckRC( sts, *msg, "EMSproject.EMget_params", wrapup ) ;	

	} else if( vs$is_ancestry_valid(
				object	= &prjSfId,
				classid	= OPP_EMSproject_class_id ) ) {

		sts = om$send(	msg	= message EMSsurface.EMget_params(
							msg,
							NULL,
							prjSlEnv,
							NULL,
							&sfParams ),
				senderid= prjSfId.objid,
				targetid= prjSfId.objid,
				targetos= prjSfId.osnum ) ;
		__CheckRC( sts, *msg, "EMSproject.EMget_params", wrapup ) ;
	} else { 
		*msg = MSINARG ; sts = OM_E_INVARG ; goto wrapup ;
	}
	VSvccpy( extInfo.bcap_ref_pt, sfParams.params.project.axis_point0 ) ;
	VSvccpy( extInfo.ecap_ref_pt, sfParams.params.project.axis_point1 ) ;

	extInfo.object_classid = OPP_EMSsfsolid_class_id ;

	/*
	 * Get geometry of begin cap curve.
	 */
	vs$get_geometry(	msg	= msg,
				grobjId	= &begCapCv->_grid,
				grobjEnv= &begCapCv->mod_env,
				geometry= &bcapGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * A word about what is going to happen here topology-wise is most
	 * welcome:
	 * The input to trim-a-surface is a solid (EMSsfsolid) build on a
	 * (composite) surface of projection (EMSprjcompsf,EMSproject) and
	 * a surface (EMSsubbs) :
	 *
	 *			EMSsfsolid
	 *			     |
	 *		+------------+----------+
	 *		|	     |		|
	 * EMSprjcompsf,EMSproject cap 1       cap 2
	 *
	 * Upon return of the message, the ownership graph will look like (say
	 * we extended at cap 2) :
	 *
	 *			EMSsfboolean
	 *			      |
	 *		+-------------+-----------+
	 *		|			  |
	 *	   EMSsfsolid		      EMSsubbs
	 *	        |
	 *      +---------------+
	 *	|		|
	 * EMSprjcompsf,     cap 1
	 * EMSproject
	 *
	 * ie. the solid (EMSsfsolid) target of the trim-a-surface message
	 * is now owned by a new object (EMSsfboolean).
	 *
	 * Since we now have got a surface (EMSsfboolean), we must turn it into
	 * a solid, after this operation, the ownership graph will be:
	 *
	 *				EMSsfsolid (a new one)
	 *					|
	 *				   EMSgencompsf
	 *					|
	 *	+-------------------------------+-----------------------+
	 *	|				|			|
	 * Components of EMSprjcompsf,	     cap 1		   EMSsubbs
	 * EMSproject
	 *
	 * ie. the old EMSsfsolid is gone, a new one has been created, which
	 * owns a EMSgencompsf made of the components of the old
	 * EMSprjcompsf, EMSproject (now gone too), the unaltered end cap
	 * and the trimming surface of the trim-a-surface message.
	 */
	extInfo.bcap_geom = bcapGeom ;
	
	nbBadPts	= 0 ;
	badPts		= NULL ;

	/*
	 * NOTE that `sortPts' is not initialized, but although the number
	 * of sort points is set to 0, it must be input: EMS uses the memory
	 * internally and we get a Memory Fault if we do not input it.
	 */
	sts = om$send(	msg	= message EMSsurface.EMtrim_a_surface(
							&rc,
		/* Id of operand #1		*/	prjSlId->objid,
		/* Env. of operand #1		*/	prjSlEnv,
		/* Number of trimming operands:	*/	1,
		/* Id of trimming operand :	*/	&trimSf->_objid,
		/* Env. of trimming operand :	*/	&trimSf->mod_env,
							cst,
		/* Extend operand # 1		*/	TRUE,
		/* Extension info		*/	&extInfo,
		/* Copy trimSf ? :		*/	FALSE,
		/* Number of sort points :	*/	0,
		/* Sort points info :		*/	&sortPts,
							EMSbool_difference,
		/* All elements solids ? :	*/	FALSE,
		/* OUT : number of bas points :	*/	&nbBadPts,
		/* OUT : bad points info :	*/	&badPts ),
			senderid= prjSlId->objid,
			targetid= prjSlId->objid,
			targetos= prjSlId->osnum ) ;

	if( nbBadPts ) _FREE( badPts ) ;

	*msg = VSchgEMSseverity( rc ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Now get newly-created owner (EMSsfboolean).
	 */
	{
	  OM_S_CHANSELECT toOwner ;
	  ems$make_chanselect( chan_label    = GRconnector_to_owners,
			       chan_selector = &toOwner ) ;
	  sts = om$get_channel_objects(	objid		= prjSlId->objid,
					osnum		= prjSlId->osnum,
					p_chanselect	= &toOwner,
					list		= &newOwnerOL,
					size		= 1,
					count		= (OMuint *) &count ) ;
	  __CheckRC( sts, 1, "om$get_channel_objects", wrapup ) ;
	}

	newOwner.objid = newOwnerOL.S_objid ;
	newOwner.osnum = newOwnerOL.osnum ;

	/*
	 * Compress tree : EMSsfboolean -> EMSgencompsf.
	 */
	if( compress ) {
		sts = om$send(	msg	= message EMSdpr.EMmake_primitive1(
						msg, prjSlEnv, &newOwner ),
				senderid= newOwner.objid,
				targetid= newOwner.objid,
				targetos= newOwner.osnum ) ;
		__CheckRC( sts, *msg, "EMSdpr.EMmake_primitive1", wrapup ) ;
	}

	/*
	 * ... and cap it :
	 *	EMSgencompsf -> EMSsfsolid	if compressed
	 *	EMSsfboolean -> EMSsfsolid	if not compressed.
	 */
	sts = vs$cap_surface(	msg	= msg,
				cst	= cst,
				surface	= &newOwner,
				solid	= extSolid ) ;
	__CheckRC( sts, *msg, "vs$cap_surface", wrapup ) ;

	wrapup :
		_FREE( bcapGeom ) ;
		return sts ;

} /* VSextend_sl_to_sf_and_trim */
/*----------------------------------------------------------------------------*/

end implementation EMSsfsolid ;
