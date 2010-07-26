/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgenprism - returns the geometry of the object in
		internal format.

Synopsis
     	GRgenprism(msg,mat_type,matrix,geometry)

	IGRlong *msg		Completion code
	IGRshort *mat_type	Environment matrix type
	IGRmatrix matrix	Environment matrix 
	IGRchar	**geometry	pointer to pointer to geometry

Description
	This method returns the abstract geometry definition
	of a clipping polygon.  This format is an IGRcv_prism
	structure.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	05/21/87	Design date.
	jhw	11/15/89	Added a check for curve objid/osnum
        dhm     07/01/92        ANSI conversion.
\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgenprism(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRchar **geometry)
{
    IGRchar	*ptr;
    
    IGRshort    matrix_type,	
		*type;			/* type matrix			*/

    IGRlong	OMmsg,			/* return codes			*/
		msg1,
		prism_generated,
		i;			/* loop index			*/

    IGRdouble	*mx,
		identity_matrix[16];

    struct IGRbsp_curve *bc;		/* curve pointer		*/
    static struct IGRcv_prism prism;	/* prism structure		*/
    static IGRshort	saved_type=-1;
    static IGRmatrix    mat;
    static OMuword	curve_osnum;    /* osnum of curve which updated cache */
    static OM_S_OBJID   curve_objid;    /* objid of curve which updated cache */
    *msg = MSSUCC;			/* initialize return values	*/
    OMmsg = OM_S_SUCCESS;
    prism_generated = 0;

    /* if the input environment matrix is not an identity matrix, we
     * must set one up.  The matrix sent to the GRgenabsg method must
     * be an identity matrix.  The context matrix is incorporated
     * into the matrix sent back in the prism.
     */

    if (*mat_type == MAIDMX)		/* set up pointers		*/
    {
	mx = &matrix[0];
	type =  mat_type;
    }
    else
    {
        MAidmx(&msg1,identity_matrix);
    	matrix_type = MAIDMX;
	mx = &identity_matrix[0];
	type = &matrix_type;
    }

    /*
     * check to see if the context is different from the currently
     * stored context.
     */

    if (saved_type == -1 )
    {
	prism_generated = 1;
    }
    else
    {
	if (saved_type == *mat_type)
	{
    	    for (i=0; (i<16 && (! prism_generated)) ; ++i)
    	    {
		if (mat[i] != matrix[i])
		{
	    	    prism_generated =1;
		}
	    }
	}
	else
	{
	    prism_generated = 1;
	}
    }

    /* Test to see if the curve object for the face is in the cache
     */

    if (! prism_generated )
    {
    	if ( (curve_objid != me->cv_objid) ||
             (curve_osnum != OM_Gw_current_OS) ||
             ! GRabsg_test(msg,type,mx,&OM_Gw_current_OS,&me->cv_objid,&ptr) )
    	{
	    prism_generated = 1;
    	}
    }
    
    if (prism_generated)
    {
	OMmsg = om$send(msg = message GRvg.GRgenabsg
	    	(msg,type,mx,&ptr),
	    targetid = me->cv_objid);
    }

    if (1 & OMmsg & *msg) 
    {
   	*geometry = (IGRchar *)&prism;

	if (prism_generated)
	{
            /*
             * Update the prism cache.
             */
	    bc = (struct IGRbsp_curve *) ptr;
            prism.curve = *bc;
	    prism.height = me->height;

	    for (i=0; i<16; ++i)
	    {
	    	prism.matrix[i] = me->matrix[i];
		mat[i] = matrix[i];
	    }
        
	    if (*mat_type != MAIDMX)
	    {
	    	MAcpxform(msg,&prism,matrix,&prism);
	    }

            /*
             * Update the matrix type.
             */
	    saved_type = *mat_type;
	
            /*
             * Update the id of the curve which was last 
             * used to update the prism cache.
             */
            curve_objid = me->cv_objid;
            curve_osnum = OM_Gw_current_OS;

	}
    }
    else
    {
	OMmsg = OM_E_ABORT;
    }

    return( OMmsg );
}
end implementation GRclippoly;
