/* #######################    APOGEE COMPILED   ######################## */
/*	
Abstract
	This class specification is for a 3-D double precision 
	representation of a point.
Notes
	None.
History
	MAS     11/12/85 : Design date.
	MAS	09/04/87 : Altered for 1.1 Release
*/

class specification GR3dpoint (1:1) of GRpoint;

instance GR3dpoint			/* 3-D double precision point	*/
{
  IGRdouble point[3];
};
override
  GRgetpolyline; 

#ifndef BASE_EMS
override GRputpolyline, GRclipto; 

/* 
Motivation

GRgetpolyline - overridden because the method must generate the
	geometry, and parent classes do not have
	access to the instance data defined for this class.

GRputpolyline - overridden because the method must post the
	geometry into the instance data of the object,
	and parent classes do not have access to the instance
	data defined for this class.

GRclipto - overridden because the method must return specific 
	information about what this object becomes when it is 
	clipped and parent classes do not have knowledge of 
	this information.

*/

override debug;         /* dump instance data */
#endif
end specification  GR3dpoint;

