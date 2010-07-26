/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRmodify_height -  redefines the geometric representation
	      of a clipping polygon by changing a defining point
	      of the geometry.

Synopsis
	GRmodify_height(msg,md_env,vert_loc,point,boreline)

	IGRlong *msg			completion code
	struct GRmd_env *md_env		environment information
	struct GRparms *vert_loc 	information to locate vertex
	IGRpoint point			point to determine closest vertex
	struct IGRline *boreline 	boreline to find new point

Description

	This method sends the GRmodify_height message to the object 
	defining the underlying geometry of the object.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "mapriv.h"
#include "OMmacros.h"
#include "godef.h"
#include "refpriv.h"

from GRreffile import GRupdrefrng;

extern    IGRboolean    MAinvmx();
extern    IGRboolean    MA2lnproj();

method GRmodify_height(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *vert_loc; IGRpoint point; 
		struct IGRline *boreline)
{
	IGRchar 	*ptr;		/* abstract geometry pointer	*/

	IGRboolean	top;

	IGRshort 	mx_size;

	IGRlong		OMmsg;		/* OM return value		*/

	IGRint		num;

	IGRdouble	delta[3],
			point1[3],
			point2[3],
			points[6],
			t1,t2,
			pt1[3],
			pt2[3];

	IGRmatrix	inv_mx;
      
	GRobjid		ref_id;

  	struct IGRline  local_boreline,
			object_line;

	struct IGRcv_prism *prism;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	/* Remove the clipping polygon and the reference file
	 * attachment object from the R-tree
	 */

	if (! IF_NULL_OBJID(md_env->md_id.objid))
	{
	    ref_id = NULL_OBJID;

	    OMmsg = GRrfremrtree(msg,md_env,&my_id,&ref_id);

	}
	if (1 & OMmsg & *msg)
	{	
	    GRgetprism(msg,&md_env->md_env.matrix_type,
		md_env->md_env.matrix,&ptr,i);

	    if (!( 1 & *msg))
	    {
		OMmsg = OM_E_ABORT;
		goto wrapup;
	    }
		
	    prism = (struct IGRcv_prism *)ptr;
		
	    /* transform the input boreline to local coordinates
	     * of the clipping polygon.
	     */

	    local_boreline.point1 = points;
	    local_boreline.point2 = &points[3];
	    mx_size = 4;

	    if (MAinvmx(msg,&mx_size,prism->matrix,inv_mx))
	    {
	        num = 1;

	        MAptsxform(msg,&num,inv_mx,boreline->point1,
		    local_boreline.point1);
	        MAptsxform(msg,&num,inv_mx,boreline->point2,
		    local_boreline.point2);

		/* To determine which face is being modified.
	   	 * Transform input point to local
		 * coordinates.
		 */

		MAptsxform(msg,&num,inv_mx,point,point1);

		/* project the boreline to the line formed from the
	 	 * input point and the cooresponding point on the 
	 	 * opposite face to determine the z distance.
	 	 */

		object_line.point1 = point1;
		object_line.point2 = point2;

		point2[0] = point1[0];
		point2[1] = point1[1];

		if (MAabsolute(point1[2] ) < 
	   	 	MAabsolute(me->height - point1[2]) )
		{
	    	    top = TRUE;
	    	    point2[2] = me->height;
 		}
		else
		{
	    	    top = FALSE;
	    	    point2[2] = 0.0;
		}

		MA2lnproj(msg,&local_boreline,&object_line,
				pt1,pt2,&t1,&t2);

		if ( 1 & *msg)
		{
	    	    MAsubvc(msg,pt2,point1,delta);
		    me->height += 
			    (top ? (-delta[2]) : delta[2]);

		    if (top)
		    {
		        /* the front face is being modified.
		         * We must compute a new origin. Leave the
		         * delta z component the same. Transform
		         * the delta vector to world coords to 
		         * compute the new origin for the matrix.
		         */
				
		        delta[0] = 0.0;
		        delta[1] = 0.0;

		        MAptsxform(msg,&num,me->matrix,delta,
				delta);

		        me->matrix[3] = delta[0];
		        me->matrix[7] = delta[1];
		        me->matrix[11] = delta[2];
			   
		    }		    
		    GRabsg_del_all();
		}
	    }
  	}
        if (1 & OMmsg & *msg)
    	{
	    /* Modify the scan range stored in the reference
	     * file object.
	     */

	    OMmsg = om$send (msg = message GRreffile.GRupdrefrng
	    	(msg,&md_env->md_env.matrix_type,
		 md_env->md_env.matrix),
	      	targetid = ref_id);
	    
    	}

wrapup:

        /* If the module id sent in is not NULL_OBJID
         * add the clipping polygon and the reffile object to 
	 * the R-tree.
         */     

    	if ( ! IF_NULL_OBJID(md_env->md_id.objid))
    	{
    	    GRrfaddrtree(msg,md_env,&my_id,&ref_id,NULL);
        }

        GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

    return(OMmsg);
}

end implementation GRclippoly;
