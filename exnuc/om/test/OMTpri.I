class implementation OMTpr;

#include "OMobjectcomm.h"
#include "OMindex.h"
#include "OMDB.h"

method display(OM_p_KEY_DESC p_key; int value; int *ret)

{



printf("\n***** DISPLAYING KEY ENTRY *****\n");
switch (p_key->type)
  {
  case KEY_2D_INT:
       printf("xmin : %d\n", (p_key->key.p_2dint)->xmin );
       printf("ymin : %d\n", (p_key->key.p_2dint)->ymin );
       printf("xmax : %d\n", (p_key->key.p_2dint)->xmax );
       printf("ymax : %d\n", (p_key->key.p_2dint)->ymax );
       break;

  case KEY_2D_DBL:
       printf("xmin : %f\n", (p_key->key.p_2ddbl)->xmin );
       printf("ymin : %f\n", (p_key->key.p_2ddbl)->ymin );
       printf("xmax : %f\n", (p_key->key.p_2ddbl)->xmax );
       printf("ymax : %f\n", (p_key->key.p_2ddbl)->ymax );
       break;

  case KEY_3D_INT:
       printf("xmin : %d\n", (p_key->key.p_3dint)->xmin );
       printf("ymin : %d\n", (p_key->key.p_3dint)->ymin );
       printf("zmin : %d\n", (p_key->key.p_3dint)->zmin );
       printf("xmax : %d\n", (p_key->key.p_3dint)->xmax );
       printf("ymax : %d\n", (p_key->key.p_3dint)->ymax );
       printf("zmax : %d\n", (p_key->key.p_3dint)->zmax );
       break;
  case KEY_3D_DBL:
       printf("xmin : %f\n", (p_key->key.p_3ddbl)->xmin );
       printf("ymin : %f\n", (p_key->key.p_3ddbl)->ymin );
       printf("zmin : %f\n", (p_key->key.p_3ddbl)->zmin );
       printf("xmax : %f\n", (p_key->key.p_3ddbl)->xmax );
       printf("ymax : %f\n", (p_key->key.p_3ddbl)->ymax );
       printf("zmax : %f\n", (p_key->key.p_3ddbl)->zmax );
       break;

  default:
       return(DB_E_TYPECONFLICT);
       break;
  }

printf("Data_record_pointer : %d\n\n\n", my_id); 
printf("*** value from arglist : %d ***\n", value );
*ret = 111;

return( OM_S_SUCCESS );
}



method skew_display( OM_p_KEY_DESC p_key )

{

switch ( p_key->type )

{  

  case KEY_2D_INT:
	  printf("Candidate rectangle:\n");
	  printf("\txmin:\t%d", (p_key->key.p_2dint)->xmin);
	  printf("\tymin:\t%d", (p_key->key.p_2dint)->ymin);
	  printf("\txmax:\t%d", (p_key->key.p_2dint)->xmax);
	  printf("\tymax:\t%d\n", (p_key->key.p_2dint)->ymax);
	  break;

  case KEY_2D_DBL:
	  printf("Candidate rectangle:\n");
          printf("\txmin:\t%.2f", (p_key->key.p_2ddbl)->xmin );
          printf("\tymin:\t%.2f", (p_key->key.p_2ddbl)->ymin );
          printf("\txmax:\t%.2f", (p_key->key.p_2ddbl)->xmax );
          printf("\tymax:\t%.2f\n", (p_key->key.p_2ddbl)->ymax );
          break;

  case KEY_3D_INT:
	  printf("Candidate rectangle:\n");	
          printf("\txmin:\t%d", (p_key->key.p_3dint)->xmin );
          printf("\tymin:\t%d", (p_key->key.p_3dint)->ymin );
          printf("\tzmin:\t%d", (p_key->key.p_3dint)->zmin );
          printf("\txmax:\t%d", (p_key->key.p_3dint)->xmax );
          printf("\tymax:\t%d", (p_key->key.p_3dint)->ymax );
          printf("\tzmax:\t%d\n", (p_key->key.p_3dint)->zmax );
          break;

  case KEY_3D_DBL:
	  printf("Candidate rectangle:\n");
          printf("\txmin:\t%.2f", (p_key->key.p_3ddbl)->xmin);
	  printf("\tymin:\t%.2f", (p_key->key.p_3ddbl)->ymin);
	  printf("\tzmin:\t%.2f", (p_key->key.p_3ddbl)->zmin);
	  printf("\txmax:\t%.2f", (p_key->key.p_3ddbl)->xmax);
	  printf("\tymax:\t%.2f", (p_key->key.p_3ddbl)->ymax);
	  printf("\tzmax:\t%.2f\n", (p_key->key.p_3ddbl)->zmax);

 }

return( OM_S_SUCCESS );

}

method time_display( )
{

#ifdef DEBUG
printf("\n*** RTREE TIME DISPLAY ***\n");
#endif

return(OM_S_SUCCESS);

}

end implementation OMTpr;
