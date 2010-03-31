/* ###################   APOGEE COMPILED   ################## */

class specification ECtasurfs (1:0) of ECelement;


/*

ABSTRACT:  

This Command Object gives a measure of tangency between two surfaces along an
edge joining the two surfaces by calculating the surface normals along the 
edge on both surfaces and expressing the deviation.

HISTORY:
    
 BL	06/19/89	Creation date.
 BL	07/07/89	Added an include file EMSbnddef.h, since EMSbnd.h 
			depends on EMSbnddef.h.
 BL	08/17/89	Added the init method into override list.

*/

# ifndef EMSbnddef_include
# include "EMSbnddef.h"
# endif

# ifndef EMSbnd_include
# include "EMSbnd.h"
# endif


instance ECtasurfs
{
   IGRboolean  pick_edge;
   IGRboolean  graph_only;  /* for checking output into database or graph */
   IGRint  num_pts;
   IGRdouble  norm_len;  /* the normals' length, if output to database */
   struct IGRbsp_curve  curve;
   struct EX_button  button; /* for the location of legend */
   struct EMSstitch_info  pair;  /* store the common edges' objids and 
					the stitched surfaces' objids */

};

override init, wakeup, delete, execute;

end specification ECtasurfs;

