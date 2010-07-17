/*
	I/STRUCT
*/
class implementation VSproffrplts ;

#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vssectiondef.h"
#include "vsdatamacros.h"
#include "vsRDBmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
long VSgetCmpPrflParms( msg, osnum, material, family, part,
					p_count, p_names, p_values )
long	*msg ;
OMuword	osnum ;
char	*material,
	*family,
	*part,
	***p_names ;
int	*p_count ;
double	**p_values ; {

	int			ACrc ;
	long			sts ;	/* OM return code		*/
	struct GRid		cmpProf ;
	struct ret_struct	rs ;
	struct GRmd_env		modEnv ;
%safe
	static double		parmVals[4] ;
	static char		*parmNams[4] ;
%endsafe

	*p_count = 0 ; *p_names = NULL ; *p_values = NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	vs$load_part_from_RDB(	msg		= msg,
				material	= material,
				family		= family,
				part		= part,
				osnum		= osnum,
				object		= &cmpProf ) ;

	if( !( *msg & 1 ) ) { sts = OM_W_ABORT ; goto wrapup ; }

	sts = om$send(	msg	= message ACcpx.ACfind_temp_struct(
					&ACrc, VS_K_scHeight, &rs, &modEnv ),
			senderid= cmpProf.objid,
			targetid= cmpProf.objid,
			targetos= cmpProf.osnum ) ;
	if( sts & 1 & ACrc ) {
		parmVals[*p_count] = rs.var.root_pm_st.value ;
		parmNams[*p_count] = VS_K_scHeight ;
		(*p_count)++ ;
	}

	sts = om$send(	msg	= message ACcpx.ACfind_temp_struct(
					&ACrc, VS_K_scWidth, &rs, &modEnv ),
			senderid= cmpProf.objid,
			targetid= cmpProf.objid,
			targetos= cmpProf.osnum ) ;
	if( sts & 1 & ACrc ) {
		parmVals[*p_count] = rs.var.root_pm_st.value ;
		parmNams[*p_count] = VS_K_scWidth ;
		(*p_count)++ ;
	}
	
	sts = om$send(	msg	= message ACcpx.ACfind_temp_struct(
					&ACrc, VS_K_scFlgThk, &rs, &modEnv ),
			senderid= cmpProf.objid,
			targetid= cmpProf.objid,
			targetos= cmpProf.osnum ) ;
	if( sts & 1 & ACrc ) {
		parmVals[*p_count] = rs.var.root_pm_st.value ;
		parmNams[*p_count] = VS_K_scFlgThk ;
		(*p_count)++ ;
	}

	sts = om$send(	msg	= message ACcpx.ACfind_temp_struct(
					&ACrc, VS_K_scWebThk, &rs, &modEnv ),
			senderid= cmpProf.objid,
			targetid= cmpProf.objid,
			targetos= cmpProf.osnum ) ;
	if( sts & 1 & ACrc ) {
		parmVals[*p_count] = rs.var.root_pm_st.value ;
		parmNams[*p_count] = VS_K_scWebThk ;
		(*p_count)++ ;
	}

	if( *p_count ) {
		VScopyList( msg, parmNams, *p_count, p_names ) ;
		*p_values= (double *) VSmemdup( parmVals,
						*p_count * sizeof( double ) ) ;
		if( !*p_names || !*p_values ) {
			*p_names = NULL ; *p_values = NULL ; *p_count = 0 ;
			vs$mem_fail() ;
		}
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		return sts ;

} /* VSgetCmpPrflParms */
/*----------------------------------------------------------------------------*/

end implementation VSproffrplts ;

