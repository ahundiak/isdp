/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GR3dinfline is a subclass of GRinfline which is the 3-D 
	double precision representation of the infinite length line.
Notes
	None.
History	
	MAS     11/12/85 : Design date.
	MAS	09/04/87 : Altered for 1.1 Release
*/

class specification GR3dinfline (1:1) of GRinfline;

instance GR3dinfline
{
  IGRdouble points[6];
};

override GRclipto,GRputpolyline,GRgetpolyline;

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

end specification GR3dinfline;
