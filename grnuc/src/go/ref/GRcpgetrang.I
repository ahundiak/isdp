/* #######################    APOGEE COMPILED   ######################## */
/*\
Name

	GRgetrang -  retrieves the range of the object.

Synopsis
	GRgetrang(msg,matrix_type,matrix,world,range)

	IGRlong *msg		Completion code
	IGRshort *matrix_type   type of environment matrix
	IGRmatrix matrix	Environment matrix
	IGRboolean *world	flag to indicate coordinate
				to compute range in
				 0 - local coordinates
				 1 - world coordinates
	GRrange range		the range of the object

Description


Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	05/27/87	Design date.
        dhm     07/01/92        ANSI conversion.
\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetrang(IGRlong *msg; IGRshort *matrix_type;
		 IGRmatrix matrix; IGRboolean *world;GRrange range)
{
	IGRchar *ptr;
	IGRchar *old_ptr;
	IGRchar *old_scratch;

	IGRshort mat_type;
	IGRshort mx_size;

	IGRlong old_size;
	IGRlong in_buffer;
	IGRlong msg1;
	IGRlong i;
	IGRlong OMmsg;

	IGRdouble matrix2[16],
		buffer[1000];

	struct IGRbsp_curve *old_curve;
	struct IGRcv_prism prism;

	GRspacenum osnum = OM_Gw_current_OS;
        old_scratch = NULL;
        old_size = 0;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	/* The curve portion of the Curve prism is all that is 
	 * in the cache.  Determine if the object in the
	 * cache is the curve object
	 */
	    
	in_buffer = GRabsg_test(&msg1,matrix_type,matrix,&osnum,
			&me->cv_objid,&old_ptr);

	if (in_buffer)			/* save the curve definition	*/
	{
	  old_curve = (struct IGRbsp_curve *) old_ptr;

	  GRbc_size(old_curve->order,old_curve->num_poles,
		old_curve->rational,old_curve->num_boundaries,old_size);

	  if (old_size > sizeof(buffer))
	  {
	  	old_scratch = om$malloc(size = old_size);
	  }
	  else
	  {
		old_scratch = (IGRchar *) buffer;
	  }

	  if (old_scratch == 0)
	  {
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	  }

	  for (i = 0; i < old_size; i++)
	  {
	    old_scratch[i] = old_ptr[i];
	  }

	  GRabsg_del(old_ptr);
	}

	/* Generate the representation of the curve object
	 * stored in the instance data.  No context is applied,
	 * therefore send in an identity matrix.  There is no way
	 * to access the static information for the prism that
	 * was in the cache, so the generate must be handled
	 * locally.
	 */

    	MAidmx(&msg1,matrix2);
	mat_type = MAIDMX;

	OMmsg = om$send(mode = OM_e_wrt_object,
            msg = message GRvg.GRgenabsg(msg,&mat_type,matrix2,&ptr),
            senderid = my_id,
            targetid = me->cv_objid);

	if (! (1 & OMmsg))
	{
	  *msg = MSFAIL;
	  goto wrapup;
	}
				/* prism curve is one generated above*/
	prism.curve = *((struct IGRbsp_curve *)ptr);
	prism.height = me->height;
			
	/* check to see if the context matrix needs to be
	 * incorporated into the prism matrix.
	 */

	if ((*world) && (*matrix_type != MAIDMX))
	{			/* multiply in the context		*/
	    mx_size = 4;
	    MAmulmx(msg,&mx_size,&mx_size,&mx_size,matrix,
		me->matrix,prism.matrix);
	}
	else
	{			/* use matrix as stored in the element	*/
	    for (i=0; i<16; ++i)
	    {
		prism.matrix[i] = me->matrix[i];
	    }
	}
				/* calculate the range			*/
	MAcpextents(&msg1,&prism,&range[0],&range[3]);

	if (! (1 & msg1))
	{
	  *msg = MSFAIL;
	  OMmsg = OM_E_ABORT;
	}

	if (in_buffer)		/* restore the cache buffer		*/
	{
	    for (i = 0; i < old_size; i++)
	    {
		old_ptr[i] = old_scratch[i];
	    }
	    if (old_size > sizeof(buffer))
	    {
	      	om$dealloc(ptr = old_scratch);
	    }
	}
	
wrapup:
	return(OMmsg);
}

end implementation GRclippoly;

