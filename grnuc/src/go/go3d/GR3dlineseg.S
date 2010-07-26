/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GR3dlineseg is the subclass of GRlineseg which is the 
	3-D double precision representation.
Notes
	None.
History	
	MAS     11/12/85 : Design date.
	RDH	03/25/86 : Rewrite
	MAS	09/04/87 : Altered for 1.1 Release
*/

class specification GR3dlineseg (1:1) of GRlineseg;

instance GR3dlineseg
{
  IGRdouble points[6];
};

override
  GRgetpolyline;

#ifndef BASE_EMS
override GRputpolyline,GRclipto;

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

end specification GR3dlineseg;
