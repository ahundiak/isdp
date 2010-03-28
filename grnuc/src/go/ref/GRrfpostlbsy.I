/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRpostlbsys

Synopsis

	GRpostlbsys(msg,md_info,post_info,lbsys)     

	IGRlong *msg		Completion code
	struct GRmd_env *md_info 
				environment information structure
     	struct GRpost_info *post_info  
				processing control information
	struct IGRlbsys *lbsys 	pointer to geometry 

Description

	This method applies the input environment matrix 
	(if it is not an identity matrix) to the input geometry.  
	The object is then entered into the instance data
	of the GRreffile object.

	The objects new range is placed in the R-tree.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	GRSNOINVTRAN - environment matrix is not invertible
	GRSDGNEXCEED - range exceeds design limits
	MSFAIL - error

Notes
	If a failure occurs, the object's instance data will 
	not be modified.

History
	MAS	10/22/86 	Design date.
        dhm     07/07/92        ANSI conversion.
\*/

class implementation GRreffile;


#include "grimport.h"
#include "godef.h"
#include "madef.h"
#include "msdef.h"
#include "grerr.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "OMmacros.h"

extern IGRboolean	MAinvmx(),
			MAmulmx(),
			MAlbextents();

method GRpostlbsys(IGRlong *msg; struct GRmd_env *md_info;
		  struct GRpost_info *post_info;
		  struct IGRlbsys *lbsys)
{
    IGRboolean		world;		/* flag for GRgetrang		*/
    IGRboolean		constr_flag;	/* flag for update context	*/

    IGRlong             OMmsg;		/* return status for method	*/
    IGRlong		msg1;		/* local return code		*/
    IGRint		i;		/* loop index			*/

    IGRshort		mx_size;	/* matrix size			*/

    IGRmatrix		tmatrix,	/* transformation matrix	*/
			saved_mx;	

    GRrange		old_range,new_range;

    struct IGRlbsys 	new_lbsys,*lbs;	/* local bounded systems	*/


/*
 *  initialize variables
 */
	OMmsg = OM_S_SUCCESS;		/* initialize variables		*/
	*msg = MSSUCC;

	mx_size = 4;
        lbs = NULL;

/*
 *  update properties word
 */

	if (! post_info->construct_flag)
	{
	    me->properties |= GRIS_MODIFIED;
	}

	if (md_info->md_env.matrix_type != MAIDMX)
	{
	    if (MAinvmx(msg,&mx_size,md_info->md_env.matrix,tmatrix))
	    {
		MAlbxform(msg,lbsys,tmatrix,&new_lbsys);
  		lbs = &new_lbsys;
	    }
	    else			/* matrix not invertible	*/
	    {
		OMmsg = OM_E_ABORT;
		*msg = GRSNOINVTRAN;
	    }
	}
	else
	{
	    lbs = (struct IGRlbsys *)lbsys;/* use input system		*/
	}

        if (1 & *msg & OMmsg)		/* check status			*/
	{				/* get new range		*/
	    if ( MAlbextents (&msg1,lbs,new_range,&new_range[3]))
	    {
				/* check to see if it is off design cube*/
		for (i=0; i<3; ++i)
		{		
		    if ((new_range[i] < GRDGNLIMITS_MIN_D)  ||
		        (new_range[i+3] > GRDGNLIMITS_MAX_D) )
		    {			/* don't allow alteration	*/
		        *msg = GRSDGNEXCEED;
			OMmsg = OM_E_ABORT;
			i = 10;
		    }
		}
		if ((1 & *msg) &&
		    ( ! IF_NULL_OBJID(md_info->md_id.objid) ))
		{
		    world = FALSE;
				/* get the old range of the lbsys	*/
 	            if (1 & (OMmsg = om$send(
			msg = message GRvg.GRgetrang(
				msg,&md_info->md_env.matrix_type,
				md_info->md_env.matrix,
				&world,old_range),
			targetid = my_id)))
	      	    {
				/* update the range in the R_tree	*/
		        OMmsg = GRupdaterng(&msg1,md_info,post_info,&my_id,
				&me->properties,old_range,new_range);
	            }
		}
	    }
	}
        if (1 & *msg & OMmsg)	/* check status before posting		*/
        {

	    for (i=0; i<16; ++i)
	    {
		saved_mx[i] = me->ref_to_master_matrix[i];
	    }
				/* transform to local coordinates	*/
    	    MAwclsmx(&msg1,me->vw_origin,me->vw_rotation,
		     tmatrix);

	    /* the world to view matrix formed above is multiplied
	     * by the matrix formed by multiplying the input matrix
	     * and the inverse of the environment matrix.
	     * This creates a reference file world to master file
	     * world matrix.
	     */

            if ( MAmulmx(&msg1,&mx_size,&mx_size,&mx_size,lbs->matrix,
			 tmatrix,me->ref_to_master_matrix))
	    {
		/* the inverse of the  reference file to master file
		 * transformation is also stored.
		 */

               	if (!MAinvmx(&msg1,&mx_size,me->ref_to_master_matrix,
			     me->master_to_ref_matrix))
		{
		    OMmsg = OM_E_ABORT;
		    *msg = MSINARG;
		}
		else
		{
		    constr_flag = FALSE;

		    OMmsg = GRupdcontext(msg,md_info,saved_mx,
			&constr_flag,&my_id,NULL);
		}
            }
	    else
	    {
		OMmsg = OM_E_ABORT;
		*msg = MSINARG;
	    }
	}

        return (OMmsg);
}
end implementation GRreffile;
