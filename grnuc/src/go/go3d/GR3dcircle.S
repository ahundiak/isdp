/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GR3dcircle is a subclass of GRcircle and is a 
	3-D double precision representation of a circle.
Notes
	None
History	
	SDG     11/12/85 : Creation date.
	SDG	 3/24/86 : Revision date.
	MAS	09/04/87 : Altered for 1.1 Release
*/

class specification GR3dcircle (1:1) of GRcircle;

instance GR3dcircle		/* 3-D double object	*/
{
  IGRdouble radius;		/* length of radius	*/
  IGRdouble origin[3];		/* origin point		*/
  IGRdouble rot_matrix[9];	/* rotation matrix	*/
    				/* from local to world	*/
				/* coordinates		*/
};
override
GRgetarc;

#ifndef BASE_EMS
override GRputarc, GRclipto ;

/* 
Motivation

GRputarc - overridden because the method must post the
	geometry into the instance data of the object,
	and parent classes do not have access to the instance
	data defined for this class.

GRgetarc - overridden because the method must generate the
	IGRarc structure and the parent classes do not have
	access to the instance data defined for this class.

GRclipto - overridden because the method must return specific 
	information about what this object becomes when it is 
	clipped and parent classes do not have knowledge of 
	this information.
*/

override debug;         /* dump instance data */
#endif

end specification GR3dcircle;
