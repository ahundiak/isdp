/*
	I/STRUCT
*/
#include "acrepdef.h"
#include "vs.h"
#include "vsplatedef.h"
/*----------------------------------------------------------------------------*/
void VSfixPlateRep( proposed, returned ) VSdspRep proposed, *returned ; {

	switch( proposed ) {
		case AC_2D_REP		:
		case AC_3D_REP		:
		case AC_ENV_REP		:
		case VS_m_2dWCompute	: *returned = proposed ; break ;
		default			: *returned = proposed & ~AC_SUB_REP ; 
	}

} /* VSfixPlateRep */
/*----------------------------------------------------------------------------*/

