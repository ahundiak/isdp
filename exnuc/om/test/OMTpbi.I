class implementation OMTpb;
#include "OMerrordef.h"

method OMTpb_constr( char *p_key; long *rec )

{

ME.OMTpb->p_key = p_key;
ME.OMTpb->rec = my_id;
*rec = my_id;

return( OM_S_SUCCESS );

}


method display( int value; int *ret )
{

printf("--- OMTpr.display  my_id: %d\n", ME.OMTpb->rec );
*ret = 111;
}

method time_display( )
{

#ifdef DEBUG
printf("\n*** TIME BTREE DISPLAY ***\n");
#endif

return(OM_S_SUCCESS);
}

end implementation OMTpb;
