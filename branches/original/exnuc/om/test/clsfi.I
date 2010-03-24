#include "OMerrordef.h"

class implementation clsf;

method fillnum( )

{
int i;

printf("\n*** fillnum ***\n");
for (i=0;i<10;i++)
	{
	ME.clsf->num[i]=i;
	printf("num[%d]: %d\n", i,ME.clsf->num[i]);
	}
ME.clsf->fnum=100;

return(OM_S_SUCCESS);
}

method fillvla( )

{
int sts;
int i;

sts = om$vla_set_dimension(varray=ME.clsf->display,size=5);
if (!(sts&1)) return(sts);

for (i=0;i<5;i++)
	ME.clsf->display[i] = 100 + i;

return(OM_S_SUCCESS);

}

method display_vla( )

{
int i;

printf("\n*** display_vla ***\n");
for (i=0;i<5;i++)
	printf("*** %d\n", ME.clsf->display[i]);

return(OM_S_SUCCESS);
}

end implementation clsf;
