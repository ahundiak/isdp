/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "mapriv.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"

extern    IGRboolean    MAang2vc();

IGRlong GRcheckortho(msg,polyline,post_info,ortho)

IGRlong		*msg;
struct IGRpolyline *polyline;
struct GRpost_info *post_info;
IGRboolean	*ortho;
{
    IGRint	i,j;			/* loop variables		*/

    IGRlong	msg1, OMmsg;		/* return codes			*/

    IGRdouble	vector1[3],
		vector2[3],
		*vc1,
		*vc2,
		*pt1,
		*pt2,
		*temp,
		angle[3];


    *ortho = TRUE;
    *msg = MSSUCC;
    OMmsg =  OM_S_SUCCESS;

    if (post_info->construct_flag)
    {	
	/* for now, perform no check if object is being constructed.
	 */

	goto wrapup;
    }

    vc1 = vector1;
    vc2 = vector2;

    if ( polyline->num_points > 2)
    {
	/*  form vectors from adjacent segments
	 */

	vc1[0] =  polyline->points[3] - polyline->points[0];
	vc1[1] =  polyline->points[4] - polyline->points[1];
	vc1[2] =  polyline->points[5] - polyline->points[2];

	pt1 = &polyline->points[3];
	pt2 = &polyline->points[6];

    	for ( i = 2; i < polyline->num_points  && *ortho; ++i )
	{
	    for (j=0; j<3; ++j)
	    {
	    	vc2[j] = *pt1++ - *pt2++;
	    }

	    /*
      	     *  determine the angle between the adjacent vectors
  	     *  if the sine or cosine of the angle is near zero,
	     *  then the line string is considered orthogonal
	     */

	    
	    if (MAang2vc(&msg1,vc1,vc2,angle))
	    {
		/* this function should only fail due to 0 length
		 * segments.  Ignore this sort of failure.
		 */

	        if (( MAabsolute(angle[1]) > ( MAETA * 10000 )) && 
		    ( MAabsolute(angle[2]) > ( MAETA * 10000 )))
	        {
		    *ortho = FALSE;
		}
	     }
					/* increment pointers		*/
	     temp = vc1;
	     vc1 = vc2;
	     vc2 = temp;
	}
    }

wrapup:
    return (OMmsg);
}
