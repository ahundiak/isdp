/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "gocmacros.h"

extern    IGRchar    *GRabsg_alloc();

IGRboolean GRgetbuffer(msg,mx_type,matrix,num_poles,order,
		       rational,num_boundaries,objid,ptr)

IGRlong 	*msg; 			/* return message		*/
IGRshort 	*mx_type; 		/* matrix type			*/
IGRmatrix 	matrix;			/* environment matrix		*/
IGRlong 	*num_poles; 		/* number of poles		*/
IGRshort 	*order;			/* order of curve		*/
IGRboolean 	*rational; 		/* rational flag		*/
IGRshort 	*num_boundaries;	/* number of boundaries		*/
GRobjid 	*objid; 		/* object id			*/
IGRchar 	**ptr;			/* pointer to partioned buffer	*/

{
	IGRlong	i;			/* loop index			*/
	struct GRabsg_hdr absg_hdr;	/* structure for allocation	*/
	struct IGRbsp_curve *curve;	/* curve structure		*/


	*msg = MSSUCC;			/* initialize to success	*/

					/* calculate buffer size	*/
	GRbc_size(*order,*num_poles,*rational,
		  *num_boundaries,absg_hdr.geometry_size);
					/* set up struct for allocation	*/
	absg_hdr.id.objid = *objid;
	absg_hdr.id.osnum = OM_Gw_current_OS;
	absg_hdr.matrix_type = *mx_type;
	for (i = 0; i < 16; ++i)
	{
	    absg_hdr.matrix[i] = matrix[i];
	}
					/* allocate buffer		*/
	*ptr = GRabsg_alloc (msg,&absg_hdr);

	if  (1 & *msg)			/* allocation succeeded		*/
	{
	    curve = (struct IGRbsp_curve *) *ptr;
					/* partition the buffer		*/
	    GRbc_partition(curve,*order,*num_poles,*rational,
			   *num_boundaries)
	}
	else
	{
	    *msg = MSFAIL;		/* set error message		*/
	}

    return (*msg == MSSUCC);

}
