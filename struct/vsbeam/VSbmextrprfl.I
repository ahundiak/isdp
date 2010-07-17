/*
	I/STRUCT
*/ 
class implementation VSbeam ;

#include "bserr.h"
#include "bstypes.h"
#include "vsdpb.h"
#include "EMSssprops.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "matypemx.h"
/*----------------------------------------------------------------------------*/
method VSextractProfile(
			long			*msg ;
			struct GRmd_env         *env ;
			struct GRobj_env	*surface,
						*axis ;
			double			pntParm ;
                        struct GRvg_construct	*cst ;
                        VSdspRep		profileRep ;
			struct GRid   		*xsId ) {
/*
 * This method is understood by all beams.
 */
	long			sts ;		/* OM return code	*/
	struct GRid		xDef ;		/* Id of profile def	*/
	struct GRobj_env	cachedXS,	/* Id of profile curve	*/
				offsetXS,	/* Id of offset profile	*/
				*toXForm,	/* Id of curve to x-form*/
				suppSf,		/* Support surface	*/
				suppAxis ;	/* Support axis		*/
	IGRmatrix  		Xmatrix ;	/* Mapping matrix	*/
	short   		Xmat_type ;	/* Type of above matrix	*/

	toXForm	= NULL ;
        sts	= OM_S_SUCCESS ;

	if( ! surface ) {
		sts = om$send(	msg	= message VSbeam.VSgetSupportSf(
							msg, env, &suppSf ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSbeam.VSgetSupportSf", wrapup ) ;
		surface = &suppSf ;
	}
	if( ! axis ) {
		sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
							msg, env, &suppAxis ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;
		axis = &suppAxis ;
	}

        /*
         * Compute cross-section referential.
         * Reminder: z - along tangent of trace curve
         *           y - along normal to surface
         *           x - cross product of the two above.
         *           O - where section is to be placed.
         */
        sts = om$send(  msg     = message VSbeam.VSgetCrossSectionCS(
                                                                msg,
								env,
								surface,
								axis,
								pntParm,
								&xDef,
                                                                Xmatrix ),
                        targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

	sts = vs$get_graphic_section(	msg		= msg,
					sectDef		= &xDef,
					representation	= profileRep,
					section		= &cachedXS ) ;
	__CheckRC( sts, *msg, "vs$get_graphic_section", wrapup ) ;

	/*
	 * If envelope representation, I must offset the profile by the
	 * value of the fireproofing thickness if any.
	 */
	if( profileRep & AC_ENV_REP ) {
		VSpartAttr	part ;

		part.Iwant	= VS_m_FpThck ;

		sts = om$send(	msg	= message GRvg.GRgetattr(
							msg, (char *) &part ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

		if( part.info.fpthickness != 0. ) {
			sts = vs$offsetCurve(	msg	= msg,
						cvEnv	= &cachedXS.mod_env,
						cvId	= &cachedXS._grid,
						offset	= part.info.fpthickness,
						cst	= cst,
						offCvId	= &offsetXS._grid ) ;
			__CheckRC( sts, *msg, "vs$offsetCurve", wrapup ) ;

			/*
			 * CAUTION: if vs$offsetCurve could not offset, it
			 * returns the original curve which we then want
			 * copied when mapped to site.
			 */
			if( IF_EQ_GRID( offsetXS._grid, cachedXS._grid ) ) {
				toXForm = &cachedXS ;
			} else {
				offsetXS.mod_env = *cst->env_info ;
				toXForm = &offsetXS ;
			}
		} else toXForm = &cachedXS ;
	} else	toXForm = &cachedXS ;

	/*
	 * Place section.
	 */
	MAtypemx( msg, Xmatrix, &Xmat_type ) ;

	sts = vs$mapProfileToSite(	
			msg		= msg,
			cst		= cst,
			mapMx		= Xmatrix,
			mxType		= &Xmat_type,
			/*
			 * Copy if from cache.
			 */
			copy		= toXForm == &cachedXS,
			originPrfl	= toXForm,
			onSitePrfl	= xsId ) ;
	__CheckRC( sts, *msg, "vs$mapProfileToSite", wrapup ) ;

	wrapup :
		 return sts ;

} /* method VSextractProfile */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
