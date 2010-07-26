/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "madef.h"
#include "msdef.h"

IGRboolean GRcomputectx(msg,env_type,env_matrix,ref_to_master_matrix,
	context_type,context_matrix)

IGRlong		*msg;		/* return code				*/
IGRshort	*env_type;	/* matrix type				*/
IGRmatrix	env_matrix;	/* environment matrix			*/
IGRmatrix	ref_to_master_matrix;
IGRshort	*context_type;	/* matrix type				*/
IGRmatrix	context_matrix;	/* environment matrix			*/
{
    IGRshort    mx_size;

    IGRlong 	i,
		msg1;

    *msg = MSSUCC;

    if (*env_type != MAIDMX)
    {
        mx_size = 4;
	MAmulmx(&msg1,&mx_size,&mx_size,&mx_size,
	   env_matrix,ref_to_master_matrix, context_matrix);
    }
    else
    {
	for (i=0; i<16; ++i)
	{
	    context_matrix[i] = ref_to_master_matrix[i];
    	}
    }

    MAtypemx(msg,context_matrix,context_type);

    return (*msg == MSSUCC);
}
