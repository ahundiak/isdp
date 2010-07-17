/*
	I/STRUCT
*/ 
class implementation VSbeam ;

#include <string.h>
#include "grerr.h"
#include "vssectiondef.h"
#include "vsRDBmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsRDBproto.h"

#define EQ_STRING( s1, s2 ) !strcmp( (s1), (s2) )
/*----------------------------------------------------------------------------*/
method VSgetProfileDef(	long		*msg ;
			struct GRid	*prflDef ; ) {

	long			sts ;		/* OM completion code	*/
	VSpartAttr		part ;		/* My part attributes	*/
        VSbeamAttr		myAttr ;	/* My attributes	*/
	struct GRid		srcBeam ;

	*msg	= MSFAIL ;

	/*
	 * Retrieve attributes.
	 * NOTE: vs$load_part_from_RDB needs the object space number
	 * where the cached profiles are stored. It is not the object
	 * space number of my object space if I am consuming a beam
	 * which is in another file: it is the object space number
	 * of the source beam higher up in the hierarchy.
	 * (there may be a profile of the type I want in my object
	 * space because a beam of my type has been placed here, but
	 * I am not sure of it). A way to find the beam higher up
	 * in the hierarchy is to bubble-up a message with the
	 * condition being an is-name-holder message.
	 */

	sts = om$send(	msg	= message NDmacro.ACbubble_up(
						msg,
						"",
						VS_K_ConsumedIx,
						message VSpart.VSisNameHolder(
							VS_K_READ_OMmsg ),
						message NDmacro.ACreturn_foot(
							msg,
							"",
							&srcBeam,
							NULL,
							NULL ),
						OM_e_wrt_object ),
			targetid=my_id ) ;

	part.Iwant	= VS_m_MatType | VS_m_PartFam | VS_m_PartNum ;
	part.specific	= (void *) &myAttr ;
	sts = om$send(	msg     = message GRvg.GRgetattr( msg, (char *) &part ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	vs$load_part_from_RDB(	msg		= msg,
				material	= part.info.material,
				family		= part.info.family,
				part		= part.info.partNum,
				osnum		= srcBeam.osnum,
				object		= prflDef ) ;
	__CheckRC( 1, *msg, "vs$load_part_from_RDB", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSgetProfileDef */
/*----------------------------------------------------------------------------*/
method VSgetSectionParameter(	long		*msg ;
				char		*parm ;
				struct GRmd_env	*myEnv ;
				double		*value ) {

	long			sts ;		/* OM completion code	*/
	int			ACrc ;		/* AC return code	*/
	struct GRid		xSection ;	/* Id of mac. occurrence*/
	char			*intName ;	/* Internal name of parm*/
        struct ret_struct	pmStruct ;	/* Value of parameter	*/
	
	/*
	 * Translate external name to internal name.
	 */
		if( EQ_STRING( parm, VS_K_bmHeightAttr	) ) {

			intName = VS_K_scHeight ;

	} else	if( EQ_STRING( parm, VS_K_bmWidthAttr	) ) {

			intName = VS_K_scWidth ;

	} else	if( EQ_STRING( parm, VS_K_bmFlgThkAttr	) ) {

			intName = VS_K_scFlgThk ;

	} else	if( EQ_STRING( parm, VS_K_bmWebThkAttr	) ) {

			intName = VS_K_scWebThk ;

	} else	if( EQ_STRING( parm, VS_K_bmFltRadAttr	) ) {

			intName = VS_K_scFltRad ;

	} else {
		*msg = GR_E_INV_REQUEST ;
		sts  = OM_W_NAMENOTFOUND ;
		goto wrapup ;
	}

	/*
	 * Retrieve cross-section.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetProfileDef(
							msg, &xSection ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	sts = om$send(	msg	= message ACcpx.ACfind_temp_struct(
								&ACrc,
								intName,
								&pmStruct,
								myEnv ),
			targetid= xSection.objid,
			targetos= xSection.osnum ) ;
	__CheckRC( sts, 1, "ACcpx.ACfind_temp_struct", wrapup ) ;

	/*
	 * Don't be too hard on failure, some sections may not recognize names.
	 */
	if( !ACrc )	*value = 0 ;
	else		*value = pmStruct.var.root_pm_st.value ;

	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* method VSgetSectionParameter */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
