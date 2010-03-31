
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

class specification NCVdpb (1:2) of global_class;


/*
!!!!!!!!!!!!!!! DELETE THIS CLASS FOR HSURF 2.0 !!!!!!!!!!!!!!!!!!!!!!!!!!

DESCRIPTION
	NC Verification parameter block.

		The purpose of this object is to initialize the parameter
		block for NC Verification.

HISTORY
	09/20/99	Created.			C. M. Jablonski
*/

#include "igrtypedef.h"


instance NCVdpb
	{
	IGRshort mode_flag;		/* simulation speed ( bits 0 - 3 )	*/
					/*					*/
					/* verification mode ( bit 4 )		*/
					/*	( 0 = swept volume,		*/
					/*	  1 = simulation )		*/
					/*					*/
					/* wireframe display ( bit 5 )		*/
					/*	( 0 = wireframe off,		*/
					/*	  1 = wireframe on )		*/
					/*					*/
					/* shading style ( bit 6 )		*/
					/*	( 0 = constant shading,		*/
					/*	  1 = smooth shading )		*/
					/*					*/
					/* shading mode ( bit 7 )		*/
					/*	( 0 = halftoned,		*/
					/*	  1 = direct-mapped )		*/
					/*					*/
					/* execution mode ( bit 8 )		*/
					/*	( 0 = continuous execution,	*/
					/*	  1 = single-step execution )	*/
	};


override wake_up;


end specification NCVdpb;
