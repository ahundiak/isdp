/*********************************************************************

Author	:	B Demars

Creation:	November 21th, 1990


		This file contains the definition of all
		structures concerning the VR components objects.
		
	
Change History :


		  date	|  name	|	modification's description
		--------+-------+-----------------------------------

*********************************************************************/

#ifndef	vr_compstr_include

#define vr_compstr_include

/* -- Definition of connect points geometry structure -- */

struct VRCpGeom
	{
		IGRdouble 	dPoint [3];
		IGRdouble	dConAxis [3];
		IGRdouble	dOrientation [3];
	};



#endif
