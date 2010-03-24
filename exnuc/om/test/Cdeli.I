class implementation Cdel ;

/* we need to tell D to delete us.. */
from Ddel import Telld;

#include "OMobjectcomm.h"
#include <stdio.h>

/*....................method definition ..................*/
/* sample parameter declaration ...*/
method  delete(int defer)
{
	int sts;
	printf(" executing class C override delete method ....\n");
	
        sts = OM_send_object(OM_e_wrt_message,message Bdel.delete(defer),
			    my_id,my_id );
        if (sts != OM_S_SUCCESS){
 		printf("Error %d in OM_send_object ",sts);
		OM_report_error(sts);
	}

	printf(" returning from class C override delete method ..\n");
	return(sts);
}	/* end of  method definition	*/


end implementation Cdel;
