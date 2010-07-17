/*
	I/STRUCT
*/
#include "acrepdef.h"
#include "vsbeamdef.h"
#include "vs.h"
/*----------------------------------------------------------------------------*/
void VSfixBeamRep( proposed, returned ) VSdspRep proposed, *returned ; {

	switch( proposed ) {
		case AC_2D_REP		:
		case AC_3D_REP		:
		case AC_ENV_REP		:
		case VS_m_2dSurface	:
		case VS_m_3dWFillet	: *returned = proposed ; break ;
		default			: *returned = proposed & ~AC_SUB_REP ; 
	}

} /* VSfixBeamRep */
/*----------------------------------------------------------------------------*/

