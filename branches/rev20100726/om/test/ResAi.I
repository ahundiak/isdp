class implementation ResA;

#include "OMminimum.h"
#include "OMspecify.h"
#include "OMmacros.h"
#include "OMerrordef.h"

method assign_a ( int num )
{
  ME.ResA->anum = num;
  printf (" >>> assign_a::  anum set to %d\t <<<\n", ME.ResA->anum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return(OM_S_SUCCESS);
}


method inc_a ()
{
  printf (" >>> inc_a::  anum incremented to %d\t <<<\n", ++ME.ResA->anum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return(OM_S_SUCCESS);
}


method show_a ()
{
  printf (" >>> show_a::  anum is %d\t <<<\n", ME.ResA->anum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return(OM_S_SUCCESS);
}

method var_assign_dbl (int newsize)
{
 int	i;
 int	size;
 int	sts;
 double j;

 printf ( " --- in var_assign_dbl ---\n" );
 /* get size of variable double array */
 size = om$dimension_of(varray=ME.ResA->db);
 printf( "size of ME.ResA->db is : %d\n", size);
 if (size != newsize) /* resize array */
 {
   if(!(1&(sts=om$vla_set_dimension(varray=ME.ResA->db, size=newsize ))))
   {
	om$report_error(sts=sts);
	exit(1);
   }
 }
 /* assign array elements values */
 for(i=0, j=1.1; i<newsize; i++, j+=1.1)
 {
	ME.ResA->db[i] = j;
 }
 return(OM_S_SUCCESS);
}


method var_assign_long (int newsize)
{
 int	i;
 int	size;
 int	sts;
 long   j;

 printf ( " --- in var_assign_long ---\n" );
 /* get size of variable array */
 size = om$dimension_of(varray=ME.ResA->lg);
 printf( "size of ME.ResA->lg is : %d\n", size);
 if (size != newsize) /* resize array */
 {
   if(!(1&(sts=om$vla_set_dimension( varray=ME.ResA->lg, size=newsize ))))
   {
	om$report_error(sts=sts);
	exit(1);
   }
 }
 /* assign array elements values */
 for(i=0, j=1; i<newsize; i++, j+=1)
 {
	ME.ResA->lg[i] = j;
 }
 return(OM_S_SUCCESS);
}


method var_assign_short (int newsize)
{
 int	i;
 int	size;
 int	sts;
 short	j;

 printf ( " --- in var_assign_short ---\n" );
 /* get size of variable array */
 size = om$dimension_of(varray=ME.ResA->sh);
 printf( "size of ME.ResA->sh is : %d\n", size);
 if (size != newsize) /* resize array */
 {
   if(!(1&(sts=om$vla_set_dimension( varray=ME.ResA->sh, size=newsize ))))
   {
	om$report_error(sts=sts);
	exit(1);
   }
 }
 /* assign array elements values */
 for(i=0, j=1; i<newsize; i++, j+=1)
 {
	ME.ResA->sh[i] = j;
 }
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
 size = om$dimension_of(varray=ME.ResA->ch);
 printf( "size of ME.ResA->ch is : %d\n", size);
 if (size != newsize) /* resize array */
 {
   if(!(1&(sts=om$vla_set_dimension( varray=ME.ResA->ch, size=newsize ))))
   {
	om$report_error(sts=sts);
	exit(1);
   }
 }
 /* assign array elements values */
 for(i=0, j='c'; i<newsize; i++)
 {
	ME.ResA->ch[i] = j;
 }
 return(OM_S_SUCCESS);
}


method var_assign_struct (int newsize)
{
 int		i;
 int		size;
 int	sts;
 struct complex j;

 printf ( " --- in var_assign_struct ---\n" );
 /* get size of variable array */
 size = om$dimension_of(varray=ME.ResA->cplx);
 printf( "size of ME.ResA->cplx is : %d\n", size);
 if (size != newsize) /* resize array */
 {
   if(!(1&(sts=om$vla_set_dimension( varray=ME.ResA->cplx, size=newsize ))))
   {
	om$report_error(sts=sts);
	exit(1);
   }
 }
 /* assign array elements values */
 for(i=0, j.num=1; i<newsize; i++, j.num++)
 {
	ME.ResA->cplx[i].num = j.num;
	ME.ResA->cplx[i].cplxch[0] = 's';
 }
 return(OM_S_SUCCESS);
}


method var_show_dbl()
{
    int	i, size;

    printf(" --- in var_show_dbl ---\n");
    size = om$dimension_of(varray=ME.ResA->db);
 printf( "size of ME.ResA->db is : %d\n", size);
    for(i=0; i<size; i++)  printf(" Var Dbl %d : %.2f \n", i, ME.ResA->db[i]);
    return(OM_S_SUCCESS);
}


method var_show_long()
{
    int	i, size;

    printf(" --- in var_show_long ---\n");
    size = om$dimension_of(varray=ME.ResA->lg);
 printf( "size of ME.ResA->lg is : %d\n", size);
    for(i=0; i<size; i++)  printf(" Var Dbl %d : %d \n", i, ME.ResA->lg[i]);
    return(OM_S_SUCCESS);
}


method var_show_short()
{
    int	i, size;

    printf(" --- in var_show_short ---\n");
    size = om$dimension_of(varray=ME.ResA->sh);
 printf( "size of me->sh is : %d\n", size);
    for(i=0; i<size; i++)  printf(" Var Dbl %d : %d \n", i, ME.ResA->sh[i]);
    return(OM_S_SUCCESS);
}


method var_show_char()
{
    int	i, size;

    printf(" --- in var_show_char ---\n");
    size = om$dimension_of(varray=ME.ResA->ch);
 printf( "size of ME.ResA->ch is : %d\n", size);
    for(i=0; i<size; i++)  printf(" Var Ch %d : %c \n", i, ME.ResA->ch[i]);
    return(OM_S_SUCCESS);
}



method var_show_struct()
{
    int	i, size;

    printf(" --- in var_show_struct ---\n");
    size = om$dimension_of(varray=ME.ResA->cplx);
 printf( "size of ME.ResA->cplx is : %d\n", size);
    for(i=0; i<size; i++)
    {
	printf(" Var Cplx %d : num is %d; char is %c \n", i, ME.ResA->cplx[i].num,	ME.ResA->cplx[i].cplxch[0]);
    }
    return(OM_S_SUCCESS);
}


end implementation ResA;
