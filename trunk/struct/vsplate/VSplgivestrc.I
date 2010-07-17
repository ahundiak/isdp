/*
	I/STRUCT
*/
class implementation VSplate ;

#include <string.h>
#include "vsRDBdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define EQ_STRING( s1, s2 ) !strcmp( (s1), (s2) )
/*----------------------------------------------------------------------------*/
method ACgive_structure(	int			*ok,
							*notUsed ;
				char			*attrName ;
				struct ret_struct	*attrVal ;
				struct GRmd_env		*myEnv ) {

	long			sts,		/* OM completion code	*/
				msg ;		/* Return status	*/
	VSpartAttr		myAttr ;	/* My part attributes	*/
	VSplateAttr		plate ;		/* My plate attributes	*/

	enum {
		getAttr,	/* Use GRvg.GRgetattr		*/
		getNothing,	/* Don't do anything		*/
		wrtMsg		/* Send to self wrt message	*/
	} msgType ;

	/*
	 * Get value for "virtual foot".
	 * Note that strings are truncated to fit RDB's specification of
	 * character string lengths.
	 */
	if( EQ_STRING( attrName, VS_K_plWidthAttr ) ) {
		double	w, l ;
		attrVal->type = double_type ;
		sts = om$send(	msg	= message VSplate.VSgetPlateWidthLength(
							&msg, myEnv, &w, &l ),
				targetid= my_id ) ;

		if( !( sts & 1 & msg ) ) {
			w = 0 ; sts = OM_S_SUCCESS ; msg = MSSUCC ;
		}
		attrVal->var.root_pm_st.value = w ;
		msgType		= getNothing ;

	} else if( EQ_STRING( attrName, VS_K_plLengthAttr ) ) {
		double	w, l ;
		attrVal->type = double_type ;
		sts = om$send(	msg	= message VSplate.VSgetPlateWidthLength(
							&msg, myEnv, &w, &l ),
				targetid= my_id ) ;
		if( !( sts & 1 & msg ) ) {
			l = 0 ; sts = OM_S_SUCCESS ; msg = MSSUCC ;
		}

		attrVal->var.root_pm_st.value = l ;
		msgType		= getNothing ;

	} else if( EQ_STRING( attrName, VS_K_plThcknsAttr ) ) {
		attrVal->type = double_type ;

		myAttr.Iwant	= VS_m_Thickness ;
		myAttr.specific	= (void *) &plate ;
		sts = om$send(	msg	= message GRvg.GRgetattr(
						&msg, (char *) &myAttr ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "GRvg.GRgetattr", wrapup ) ;

		attrVal->var.root_pm_st.value = plate.thickness ;
		msgType		= getNothing ;

	} else if( EQ_STRING( attrName, VS_K_prMbrGeoAttr ) ) {

		struct GRid	botSurf ;

		attrVal->type	= double_type ;
		msgType		= getNothing ;

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
			      				&msg,
			      				VS_K_plBotSfPath,
			      				&botSurf,
			      				NULL, NULL ),
				targetid= my_id ) ;

		if( !( sts & 1 & msg ) ) {
			/*
			 * Respond anyway.
			 */
			sts = OM_S_SUCCESS ; msg = MSSUCC ;
			attrVal->var.root_pm_st.value = VS_rdb_plFLAT ;

		} else if( vs$is_surface_planar(
					msg	= &msg,
					surfId	= &botSurf,
					surfEnv	= myEnv ) ) {
			attrVal->var.root_pm_st.value = VS_rdb_plFLAT ;
		} else {
			attrVal->var.root_pm_st.value = VS_rdb_plCURVED ;
		}

	} else {
		/*
		 * Not a virtual foot: get real foot structure.
		 */
		msgType		= wrtMsg ;

	}

	switch( msgType ) {

		case wrtMsg	:
	  

		sts = om$send(	msg	= message VSfeature.ACgive_structure(
								ok,
								notUsed,
								attrName,
								attrVal,
								myEnv ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
		msg = *ok ? MSSUCC : MSFAIL ;


		break ;

		case getNothing	: msg = MSSUCC ; sts = OM_S_SUCCESS ; break ;
		default		: msg = MSFAIL ; sts = OM_W_ABORT   ; break ;
	}		
	wrapup :
		*ok = ( msg & 1 ) != 0 ;
		return sts ;

} /* method ACgive_structure */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
