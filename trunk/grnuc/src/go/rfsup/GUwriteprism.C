/* #######################    APOGEE COMPILED   ######################## */
/*

This function will write the prism geometry into the Interscript
meta file format.  Before calling this function you should write the
command into the file as follows:

	command[0] = 3;		
    	command[1] = 4;    
    	msg1 = sys_write( file_des, command, 2);

*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include <stdio.h>

extern int sys_write();

GUwrite_prism(prism,level,file_des)

struct IGRcv_prism *prism;
IGRshort	*level;
IGRint		*file_des;

{
    IGRint	status;


    IGRint	length;

    length = sizeof (double) * (17 + (prism->curve.num_poles * 3))  +
	     sizeof (short)  * 3 + sizeof (long);

    if (prism->curve.non_uniform)
    {
	length += sizeof (double) * prism->curve.num_knots;
    }

    if (prism->curve.rational)
    {
	length += sizeof (double) * prism->curve.num_poles;
    }
				/* write length				*/
    status=sys_write( file_des, (char *) &length, sizeof (IGRlong));
	
    if ( status != -1)
    {
				/* write level				*/
    	status = sys_write( file_des,(char *) level,sizeof (short));

	if ( status != -1)
	{
    	    status = sys_write( file_des,(char *) prism->matrix,
			sizeof (prism->matrix));

	    if (status != -1)
	    {
    	        status = sys_write( file_des,(char *) &(prism->height),
				sizeof (double));
			
		if ( status != -1)
		{
		    status = GUwrite_igm_curve(&prism->curve,
			3, file_des);
		}
	    }
	}
    }
    if (status == -1)
    {
    	status = MSFAIL;
    }

    return(status);
}
