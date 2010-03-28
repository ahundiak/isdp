/* #######################    APOGEE COMPILED   ######################## */
#include "coimport.h"
short CO_ni_index_in_range( FunctionIndex )
     
     long  FunctionIndex;
     
{
  extern int CO_ni_max_number_funcs;
  if (  (FunctionIndex > 0)  &&  (FunctionIndex <= CO_ni_max_number_funcs) )
    {
      return( 1 );
    }
  else
    {
      printf( "warning: function index is out of range.\n" );
      return( 0 );
    }
}

long CO_ni_dummy_func()

{
    return (1);
}
    
    

