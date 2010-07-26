/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GR3dcirarc is a subclass of GRcirarc and is a 
	3-D double precision representation of a circular arc.
Notes
	None
History	
	SDG     11/13/85 : Creation date.
	MAS	03/25/86 : Rewritten date.
	MAS	09/04/87 : Altered for 1.1 Release
*/

class specification GR3dcirarc (1:1) of GRcirarc;

instance GR3dcirarc		/* 3-D double object	*/
{
  IGRdouble radius;		/* length of radius	*/
  IGRdouble origin[3];		/* origin point		*/
  IGRdouble rot_matrix[9];	/* rotation matrix	*/
    				/* from local to world	*/
				/* coordinates		*/
  IGRdouble start_angle;	/* angle from primary	*/
				/* axis to starting pt. */
				/* of arc (in radians)  */
  IGRdouble sweep_angle;	/* sweep angle (radians)*/
};
override
GRgetarc;
#ifndef BASE_EMS
  override GRputarc, GRclipto ;

/* 
Motivation

GRputarc - overridden because the method must post the arc
	geometry, and parent classes do not have
	access to the instance data defined for this class.

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

end specification GR3dcirarc;
