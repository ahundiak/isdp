/*************************************************************************


Author	: Bruno Demars

Creation: 24-JUL-1993

   Structures definitions for I/ROUTE topology management.

Change History

	 Date	    |   name  | modification's description
        ------------+---------+------------------------------------------

*************************************************************************/


#ifndef VRSttopo_include
#define VRSttopo_include

/* Describes special point and orientation on topology */
struct	VRTopo
	{
		struct GRid	SegId;		/* Segment Id 			*/
		IGRshort	nEndPoint;	/* Segment's end point (0 or 1) */
		IGRdouble	*pd3Width;	/* Width axis			*/
		IGRdouble	*pd3Depth;	/* Depth axis			*/
	};



#endif

