#include "OMerrordef.h"

class implementation clsq;

method fill_info( )

{
int sts;
int i;

sts = om$vla_set_dimension(varray=ME.clsq->info,size=15);
if (!(sts&1)) return(sts);

for (i=0;i<15;i++)
	ME.clsq->info[i] = 10 + i;

return(OM_S_SUCCESS);

}

method display_info( )

{
int i;

printf("\n*** info_vla ***\n");
for (i=0;i<15;i++)
	printf("*** %d\n", ME.clsq->info[i]);

return(OM_S_SUCCESS);
}

end implementation clsq;
