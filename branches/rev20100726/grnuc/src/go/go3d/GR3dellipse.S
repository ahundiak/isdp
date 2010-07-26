/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GR3dellipse is the subclass of GRellipse and
	is a 3-D double precision floating point representation
	of an ellipse.
Notes
	None
History
	
	KMO	03/24/86 : Creation date
	MAS	09/04/87 : Altered for 1.1 Release
 */

class specification GR3dellipse (1:1) of GRellipse;

instance GR3dellipse
{
  IGRdouble prim_axis;		/* length of prim. axis */
  IGRdouble sec_axis;		/* length of sec. axis  */
  IGRdouble origin[3];		/* origin point	 	*/
  IGRdouble rot_matrix[9];	/* rotation matrix from	*/
				/* local to world coord */
};

override  GRputarc, GRclipto, GRgetarc;

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

end specification GR3dellipse;
