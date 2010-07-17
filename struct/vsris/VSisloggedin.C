/*
	I/STRUCT
*/
#include <standards.h>

extern int VdsRisAttach __(( void )) ;
/*----------------------------------------------------------------------------*/
int VSisLoggedIntoRDB __(( void )) {

	return VdsRisAttach() ;

} /* VSisLoggedIntoRDB */
/*----------------------------------------------------------------------------*/

