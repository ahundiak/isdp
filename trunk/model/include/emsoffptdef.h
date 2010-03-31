/*
This file contains the possible options for the method EMSedge.EMoffpt.

	SM	21-Jul-89	Creation.
*/

#define EMSoffpt_Right		0x0001	/* The off point is to be on the
					   right side wrt the logical direction
					   of the edge.*/
#define EMSoffpt_NoTravel	0x0002	/* If the off point in the given
					   direction, at a given distance lies
					   in a hole, the method will attempt
					   to travel across appropriate common
					   edge and give the point on the
					   adjoining surface. This option will
					   suppress such action. Under this
					   option the point will be returned
					   with EMS_I_InHole if the
					   point is in hole and no point
					   will be returned with EMS_I_Fail
					   if the point lies outside uv space.
					*/
#define EMSoffpt_Scalar		0x0004	/* Indicates that the off point is
					   desired at a given distance from the
					   edge and the caller does not care
					   whether it is on the right or
					   left of the edge.
					*/
#define EMSoffpt_NoHole      	0x0008  /* The off point should not lie in 
					   hole.
					*/
#define EMSoffpt_NoBdry		0x0010  /* The point should not lie on
					   an existing boundary.
					*/
#define EMSoffpt_OffDistUv	0x0020  /* The offset distance provided is
					   in uv space of the edge.
					*/
