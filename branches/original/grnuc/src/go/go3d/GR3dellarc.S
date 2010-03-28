/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GR3dellarc is a subclass of GRellarc and is a 
	3-D double precision representation of an elliptical arc.
Notes
	None
History	
	SDG     11/15/85 : Creation date.
	RDH	03/25/86 : Rewrite.
	MAS	09/04/87 : Altered for 1.1 Release
*/

class specification GR3dellarc (1:1) of GRellarc;

instance GR3dellarc		/* 3-D double object	*/
{
  IGRdouble prim_axis;		/* length of prim axis	*/
  IGRdouble sec_axis;		/* length of sec axis 	*/
  IGRdouble origin[3];		/* origin point		*/
  IGRdouble rot_matrix[9];	/* rotation matrix	*/
    				/* from local to world	*/
				/* coordinates		*/
  IGRdouble start_angle;	/* angle from primary	*/
				/* axis to starting pt. */
				/* of arc (in radians)  */
  IGRdouble sweep_angle;	/* sweep angle (radians)*/
};

override  GRputarc, GRclipto, GRgetarc;

/* 
Motivation

GRputarc - overridden because the method must post the
	abstract geometry into the instance data of the object,
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

end specification GR3dellarc;
