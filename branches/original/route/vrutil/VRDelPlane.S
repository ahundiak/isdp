/* $Id: VRDelPlane.S,v 1.1.1.1 2001/01/04 21:13:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vrutil/VRDelPlane.S
 *
 * Description:
 *
 *  Specification file for Delete Plane command.
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRDelPlane.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:13:13  cvs
 *     Initial import to CVS
 *
# Revision 1.1  2000/03/15  19:03:48  pinnacle
# added for CR179900493
#
 *
 * History:
 *      MM/DD/YY        AUTHOR      DESCRIPTION
 *
 *      03/14/2000		Alwin		Creation 
 *
 * -------------------------------------------------------------------*/

class specification VRDelPlane (0:0) of VDS_LOCATE;

instance VRDelPlane
{
	IGRshort		nObjectCount;
	struct GRid		*pAffectObjectList;
};

/* Initialize the  memeber variables */
message VRinit( long *sts );

/* This method would get the list of objects which are affected by deleting
the VRplane object */
message VRGetAffectedObjectsList( long *sts );

/* Release the allocated memory */
message VRReleaseMemory( long *sts );

/* Unhighlight the elements affected */
message VRResetDisplay( long *sts );

/* Add the object to affected object list, if its not already in the list */
message VRAddObjectToList( long *sts; struct GRid ObjectId );

/* Delete the VRplane object */
message VRDeletePlane( long *sts );

end specification VRDelPlane;
