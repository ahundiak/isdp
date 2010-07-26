class implementation Cprdel ;

/* we need to tell D to delete us.. */
from Ddel import Telld;

#include "OMobjectcomm.h"
#include <stdio.h>

/*....................method definition ..................*/
/* sample parameter declaration ...*/
method  delete(int defer)
{
	int sts;
	printf(" executing class C prime override delete method ....\n");
	printf(" Note: this method will fail ..\n");

	return(OM_E_ERROR);

}	/* end of  method definition	*/


end implementation Cprdel;
