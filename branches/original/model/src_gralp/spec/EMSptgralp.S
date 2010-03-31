/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class specification EMSptgralp (2:0) of EMSgraloop;
/*
Abstract

    This class represents a point graphic loop on the surface. The 
    edge belonging to this loop must be of the class EMSptedge.

Notes

     Data types of the instance data inherited (in order) is -

     short int  - From Root
     short int  - From Root
     int        - From Root
     int        - pointer to 'notification' channel.

History
       SCW  27-MAR-91  2.0.1 Genesis
       DLB     07/10/91    Disable tagging.
*/

not_taggable;

override        GRgraphics;

from EMSloop  inherit  EMtrimyourself, 
                       EMextractyourself;

message EMptlpinit( long          *EMmsg; 
                    unsigned short  props );

override
	EMcloseyourself, 
	EMdisplay, 	/* Increase the weight and execute wrt message
			   EMSfeaturelp.EMdisplay. The weight needs to be
			   increased because with weight = 0, you cannot
			   see the point edge and since such an edge exists
			   by itself (not part of a non degenerate loop), 
			   the need to be able to see is kind of
			   important. */
	EMarea, 	/* return 0.0 */
	EMnext_edge,    /* Always return the same edge */
	EMpt_location,  /* Always say point is ONVRTX or OUTSIDE */
	EMreverse;      /* Ignore */

reject
	EMmodify_edge;  
	
end specification EMSptgralp;


