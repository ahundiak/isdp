#include "OMerrordef.h"

class implementation clsg;

method printg( )

{
int i;

printf("\n*** clsg ***\n");
for (i=0; i<10; i++)
	{
	printf("num[%d]: %d\n", i, ME.clsf->num[i]);
	}

return( OM_S_SUCCESS );

}

end implementation clsg;
