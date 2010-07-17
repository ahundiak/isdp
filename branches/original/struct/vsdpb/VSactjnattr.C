/*
	I/STRUCT
*/
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsglobals.h"
#include "vsdpbdef.h"
#include "vsjoint.h"
#include "vsdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsuattmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSgetActJnAttr( msg, actJnAttr )

long		*msg ;
VSjointAttr	*actJnAttr ; {

	vs$get_act_pm( msg	= msg,
		     param	= VS_e_dpb_J_weldAttr,
		     p_arg	= &actJnAttr->weldAttr ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	vs$get_act_pm(	msg	= msg,
			param	= VS_e_dpb_J_Allowance,
			p_arg	= &actJnAttr->allowance ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	vs$getDpbCollAttr(	msg	= msg,
				name	= VS_K_dpbActJnGrvAng,
				p_value	= &actJnAttr->grooveAngle ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	vs$getDpbCollAttr(	msg	= msg,
				name	= VS_K_dpbActJnPitch,
				p_value	= &actJnAttr->pitch ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	vs$getDpbCollAttr(	msg	= msg,
				name	= VS_K_dpbActJnIncrLn,
				p_value	= &actJnAttr->incrLength ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	vs$getDpbCollAttr(	msg	= msg,
				name	= VS_K_dpbActJnUsrSym,
				p_value	= actJnAttr->usrSymbol ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	wrapup :
		return *msg & 1 ;

} /* VSgetActJnAttr */
/*----------------------------------------------------------------------------*/

