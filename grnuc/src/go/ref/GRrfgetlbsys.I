/* #######################    APOGEE COMPILED   ######################## */

/*\
Name
	GRgetlbsys - generates the local bounded system
        	representation for a reference file attachment
		object.

Synopsis
	GRgetlbsys(msg,matrix_type,matrix,lbsys)

	IGRlong *msg		Completion code
	IGRshort *matrix_type   type of transformation matrix
	IGRmatrix matrix      	transformation matrix
	struct IGRlbsys *lbsys  local bounded system

Description
        This method converts a reference file attachment into a
	local bounded system representation.  

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
    	MSINVARG  - invalid matrix
	MSFAIL - error
Notes
	None.
History
	MAS   	10/10/86 	Creation Date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"

extern    IGRboolean    MAmulmx();

method GRgetlbsys(IGRlong *msg; IGRshort *matrix_type;
                 IGRmatrix matrix; struct IGRlbsys *lbsys)
{
    IGRboolean status;		/* generic function return        */

    IGRshort   four = 4;     	/* dimension of matrices          */

    IGRlong    msg1;            /* working completion code        */
    IGRlong   OMmsg;
    IGRmatrix  tmatrix,tmatrix2;

    *msg = MSSUCC;          /* initialize to success          */
    OMmsg = OM_S_SUCCESS;

    if (*matrix_type != MAIDMX)
    {   
	MAlswcmx(&msg1,me->vw_origin,me->vw_rotation,tmatrix2);

        /* form transformation from reference file local 
     	 * coordinates to the world coordinates of the 
     	 * current file	:
	 *    CMw     Rw    CMw     CMw = current file world
	 *     --  *  -- =  --      Rw = reference file world
	 *     Rw     Rl    Rl      Rl = reference file local
     	 */

       	status = MAmulmx(&msg1,&four,&four,&four,me->ref_to_master_matrix,
		     tmatrix2,tmatrix);

    	if (1 & status)
    	{
	    /* form transformation to take you from the 
	     * current file to the master file.
	     *    Mw     CMw   Mw      Mw = master file world
	     *    --  *  -- =  --      CMw = current master world
	     *    CMw    Rl    Rl      Rl = reference file local
	     */

             status = MAmulmx(&msg1,&four,&four,&four,matrix,
		     tmatrix,lbsys->matrix);
        }
    }
    else
    {
		
	MAlswcmx(&msg1,me->vw_origin,me->vw_rotation,tmatrix2);

    	/* form matrix to take you from local coordinates of
     	 * the reference file to master file world coordinates
	 *     Mw     Rw    Mw      Mw = master file world
	 *     --  *  -- =  --      Rw = reference file world
	 *     Rw     Rl    Rl      Rl = reference file local
     	 */

       	status = MAmulmx(&msg1,&four,&four,&four,me->ref_to_master_matrix,
		     tmatrix2,lbsys->matrix);
    }

    if (1 & status)
    {
       	lbsys->diag_pt1[0] = me->vw_volume[0];
       	lbsys->diag_pt1[1] = me->vw_volume[1];
       	lbsys->diag_pt1[2] = me->vw_volume[2];

       	lbsys->diag_pt2[0] = me->vw_volume[3];
       	lbsys->diag_pt2[1] = me->vw_volume[4];
       	lbsys->diag_pt2[2] = me->vw_volume[5];
 
    }
    else			/* something was wrong with one 	*/
    {				/* of the matrices			*/
	*msg = MSINARG;
    	OMmsg = OM_E_ABORT;
    }

    return (OMmsg);

}
end implementation GRreffile;
