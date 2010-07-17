/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <string.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "EMSmsgdef.h"
#include "vsRDBdef.h"
#include "vssectiondef.h"
#include "vsxsfrpldef.h"
#include "vsxsfrpl.h"
#include "vsxsfpmacros.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmeasmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern long	VStransFaceNumberToNm() ;
/*----------------------------------------------------------------------------*/
long VSmassPropsOfBmPlate( msg, bmId, bmEnv, prflAttr, plateNo, massProps )

long		*msg ;
struct GRid	*bmId ;
struct GRmd_env	*bmEnv ;
VSxsFrPlsAttr	*prflAttr ;
int		plateNo ;
VSintegral	*massProps ; {

	long		sts ;
	int		i ;
	VSxsPlContour	contour ;
	VSxsPlShpDesc	shapeDescr ;
	GRname		baseName,
			fullName ;
	struct GRid	faceId ;
	IGRvector	normal ;

	/*
	 * Find relevant face of beam corresponding to a plate side.
	 */
	sts = vs$getContour(	msg		= msg,
				nbPlates	= prflAttr->plCount,
				plates		= prflAttr->plDefs,
				nbCnxs		= prflAttr->cnxCount,
				connections	= prflAttr->plCnxs,
				contour		= &contour,
				shapeDescr	= &shapeDescr ) ;
	__CheckRC( sts, *msg, "vs$getContour", wrapup ) ;

	if( plateNo >= contour.npoints ) vs$inv_arg() ;

	VStransFaceNumberToNm( msg, shapeDescr.plToBmFace[plateNo], baseName ) ;
	__CheckRC( sts, *msg, "VStransFaceNumberToNm", wrapup ) ;

	DIstmcpy( fullName, VS_K_bmGrCmpName, VS_K_bmBody, baseName, NULL ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					msg, fullName, &faceId, NULL, NULL ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = vs$get_area_props(	msg	= msg,
					surfId	= &faceId,
					surfEnv	= bmEnv,
					area	= &massProps->area,
					centroid= massProps->centroid ) ;
	__CheckRC( sts, *msg, "vs$get_area_props", wrapup ) ;

	/*
	 * The volume we consider is that between the surface and another
	 * surface offset from the first one by a distance equal to thickness.
	 *
	 *	------------------------^
	 *		    x Gv	| thickness
	 *	------------x-Gs--------v
	 *
	 * Volume = area * thickness
	 * This evaluation is not exact if surface is not planar, but we suppose
	 * the thickness small compared to the curvature of the surface.
	 */
	massProps->volume =   massProps->area
			    * prflAttr->plDefs[plateNo].thickness ;
	/*
	 * Area of plate = 2 * area of surface.
	 */
	massProps->area *= 2 ;

	/*
	 * Center of gravity of volume (Gv) = Center of gravity of surface (Gs)
	 *				    + 0.5 * normal to surface
	 * Again, this evaluation is not exact if surface is not planar.
	 * Use normal at u=0.5, v=0.5. Note that since surface belongs to a
	 * solid, its normal is reversed (points toward the inside of the solid)
	 * which is what we want.
	 */
	sts = vs$get_normal(	msg	= msg,
				sfId	= &faceId,
				sfEnv	= bmEnv,
				normal	= normal ) ;
	__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

	for( i = 0 ; i < 3 ; i++ ) {
		massProps->centroid[i] += 0.5 * normal[i] ;
	}

	/*
	 * We do not need to fill the `mass', `MofI' fields here, this values
	 * are not needed by checkin.
	 */

	sts = OM_S_SUCCESS ;
	*msg= MSSUCC ;

	wrapup :
		return sts ;

} /* VSmassPropsOfBmPlate */
/*----------------------------------------------------------------------------*/
long VSgive_db_structureForBeamFrPlates( msg, bmId, bmEnv, index, ftNm, attr )

long			*msg ;
struct GRid		*bmId ;
struct GRmd_env		*bmEnv ;
int			index ;
char			*ftNm ;
struct ret_struct	*attr ; {

	long		sts ; 		/* OMreturn code		*/
	struct GRid	profileDef ;	/* (Cached) profile definition	*/
	VSxsFrPlsAttr	prflAttr ;	/* Attributes of profile	*/
	VSxsPlateDef	plDefs[VS_K_MAX_XSPLATES] ;
	VSxsPlConn	plCnxs[VS_K_MAX_XSPLATES] ;
	char		buf[VS_K_MAX_XSPLATES][1 + VS_K_rdbPartNumLen] ;
	VSintegral	massProps ;
	double		*p_massProp = NULL ;
	int		i,
			ACrc,
			truncated,
			useGiveStruct ;

	sts = om$send(	msg	= message VSbeam.VSgetProfileDef(
							msg, &profileDef ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	/*
	 * Init structure with buffers.
	 */
	prflAttr.plDefs	= plDefs ;
	prflAttr.plCnxs	= plCnxs ;
	for( i = 0 ; i < VS_K_MAX_XSPLATES ; i++ ) {
		prflAttr.thicknesses[i] = &buf[i][0] ;
	}
	sts = om$send(	msg	= message GRvg.GRgetattr(
						msg, (char *) &prflAttr ),
			senderid= profileDef.objid,
			targetid= profileDef.objid,
			targetos= profileDef.osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	if( index < 0 || index >= prflAttr.plCount ) vs$inv_arg() ;

	useGiveStruct = FALSE ;

	       if(    !strcmp( ftNm, VS_K_prPrtNumAttr )
		   || !strcmp( ftNm, VS_K_prFPtNumAttr ) ) {

		attr->type = text_type ;
		VSstrncpy(	attr->var.text_st.text_string,
				prflAttr.thicknesses[index],
				VS_K_rdbPartNumLen,
				&truncated ) ;

	} else if( !strcmp( ftNm, VS_K_prPrtFamAttr ) ) {
		/*
		 * Reminder : <beam family> = #<plate family>
		 */
		char	*p ;

		i = -1 ;
		sts = om$send(	msg	= message NDmacro.ACgive_structure(
						&ACrc, &i, ftNm, attr, bmEnv ),
				senderid= bmId->objid,
				targetid= bmId->objid,
				targetos= bmId->osnum ) ;
		*msg = ACrc ;
		__CheckRC( sts, *msg, "NDmacro.ACgive_structure", wrapup ) ;

		p = attr->var.text_st.text_string ;
		i = ( 1 + strlen( p + 1 ) ) * sizeof( char ) ;

		OM_BLOCK_MOVE(	/* From	*/ p + 1,
				/* To	*/ p,
				/* Size	*/ i ) ;

	} else if( !strcmp( ftNm, VS_K_plThcknsAttr ) ) {

		attr->type		   = double_type ;
		attr->var.root_pm_st.value = prflAttr.plDefs[index].thickness ;

	} else if( !strcmp( ftNm, VS_K_prMbrGeoAttr ) ) {

		/*
		 * HOW CAN I FIND THE GEOMETRY OF THE PLATE ?
		 */
		attr->type			= double_type ;
		attr->var.root_pm_st.value	= VS_rdb_plFLAT ;

	} else if( !strcmp( ftNm, VS_K_plWidthAttr ) ) {

		attr->type		   = double_type ;
		attr->var.root_pm_st.value = prflAttr.plDefs[index].length ;

	} else if( !strcmp( ftNm, VS_K_plLengthAttr ) ) {
		/*
		 * Use beam length.
		 */
		ftNm = VS_K_bmLengthAttr ;
		useGiveStruct = TRUE ;

	} else if( !strcmp( ftNm, VS_K_prVolumeAttr ) ) {

		/*
		 * ALL ZERO TILL I FIND HOW TO COMPUTE THEM.
		 */
		p_massProp	= &massProps.volume ;

	} else if( !strcmp( ftNm, VS_K_prSfAreaAttr ) ) {

		p_massProp	= &massProps.area ;

	} else if( !strcmp( ftNm, VS_K_prXGvCtrAttr ) ) {

		p_massProp	= massProps.centroid + 0 ;

	} else if( !strcmp( ftNm, VS_K_prYGvCtrAttr ) ) {

		p_massProp	= massProps.centroid + 1 ;

	} else if( !strcmp( ftNm, VS_K_prZGvCtrAttr ) ) {

		p_massProp	= massProps.centroid + 2 ;

	} else {
		useGiveStruct = TRUE ;
	}

	if( useGiveStruct ) {
		i = -1 ;
		sts = om$send(	msg	= message NDmacro.ACgive_structure(
						&ACrc, &i, ftNm, attr, bmEnv ),
				senderid= bmId->objid,
				targetid= bmId->objid,
				targetos= bmId->osnum ) ;
		*msg = ACrc ;
	}

	if( p_massProp ) {
		VSdspRep	bmRep ;

		attr->type = double_type ;

		sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &bmRep ),
				senderid= bmId->objid,
				targetid= bmId->objid,
				targetos= bmId->osnum ) ;

		/*
		 * Do not bother if beam in simple rep !.
		 */
		if( !( sts & 1 ) || ( bmRep & ~AC_SUB_REP ) == AC_2D_REP ) {
			attr->var.root_pm_st.value	= 0 ;
		} else {
			sts = VSmassPropsOfBmPlate(	msg,
							bmId,
							bmEnv,
							&prflAttr,
							index,
							&massProps ) ;
			if( !( sts & 1 & *msg ) ) {
				/*
				 * Failed! Output something anyway.
				 */
				attr->var.root_pm_st.value	= 0 ;
			} else {
				attr->var.root_pm_st.value	= *p_massProp ;
			}
		}
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSgive_db_structureForBeamFrPlates */
/*----------------------------------------------------------------------------*/
int VSisBeamComposite( bmId ) struct GRid *bmId ; {

	long			sts,
				msg ;
	VSpartAttr		attr ;

	attr.Iwant = VS_m_PartFam ;
	sts = om$send(	msg	= message GRvg.GRgetattr(
							&msg, (char *) &attr ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;

	return ( sts & 1 & msg ) && *attr.info.family == '#' ;

} /* VSisBeamComposite */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
