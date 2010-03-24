class implementation c1;

#include "OMminimum.h"
#include "OMspecify.h"
#include "OMmacros.h"
#include "OMerrordef.h"

method assign_a ( int num )
{
  ME.c1->anum = num;
  printf (" >>> assign_a::  anum set to %d\t <<<\n", ME.c1->anum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return(OM_S_SUCCESS);
}


method inc_a ()
{
  printf (" >>> inc_a::  anum incremented to %d\t <<<\n", ++ME.c1->anum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return(OM_S_SUCCESS);
}


method show_a ()
{
/*
  printf (" >>> show_a::  anum is %d\t <<<\n", ME.c1->anum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
*/
  return(OM_S_SUCCESS);
}


method var_assign_char (int newsize)
{
 int	i;
 int	size;
 int	sts;
 char   j;

 printf ( " --- in var_assign_char ---\n" );
 /* get size of variable array */
 size = om$dimension_of(varray=ME.c1->ch);
 printf( "size of ME.c1->ch is : %d\n", size);
 if (size != newsize) /* resize array */
 {
   if(!(1&(sts=om$vla_set_dimension( varray=ME.c1->ch, size=newsize ))))
   {
	om$report_error(sts=sts);
	exit(1);
   }
 }
 /* assign array elements values */
 for(i=0, j='c'; i<newsize; i++)
 {
	ME.c1->ch[i] = j;
 }
 return(OM_S_SUCCESS);
}


method var_show_char()
{
    int	i, size;

    printf(" --- in var_show_char ---\n");
    size = om$dimension_of(varray=ME.c1->ch);
 printf( "size of ME.c1->ch is : %d\n", size);
    for(i=0; i<size; i++)  printf(" Var Ch %d : %c \n", i, ME.c1->ch[i]);
    return(OM_S_SUCCESS);
}


end implementation c1;
