class implementation Adel ;

/* we need to tell D to delete us.. */
from Ddel import Telld;

#include "OMobjectcomm.h"
#include <stdio.h>

/*....................method definition ..................*/
/* sample parameter declaration ...*/

method  delete(int defer)
{
	int sts;
	printf(" executing class A override delete method ....\n");
	printf("-- defer value is: %d\n",defer);
	
        sts = OM_send_object(OM_e_wrt_message,message Root.delete(defer),
			    my_id,my_id );
        if (sts != OM_S_SUCCESS){
 		printf("Return code %d in OM_send_object ",sts);
		OM_report_error(sts);
	}

	printf(" Returning from class A override delete method ...\n");
	return(sts);
}	/* end of  method definition	*/


method respond_to_Ddel(char classname; int defer; int times)
{
	int sts;

	printf(" Telling Ddel to delete us .....\n");

/* send Ddel our classname so he can invoke our delete method..*/
/* he sent it to us so he could know who is asking to be deleted. */

        sts = OM_send_object(OM_e_wrt_object,
	      message Ddel.Telld(classname,defer,times),
  	      my_id,sender_id );
        if (sts != OM_S_SUCCESS){
 		printf("Error %d in OM_send_object ",sts);
		OM_report_error(sts);
	}
	printf(" Returning from 'tell ddel to delete us' method ..\n");
	return(sts);
}


end implementation Adel;
